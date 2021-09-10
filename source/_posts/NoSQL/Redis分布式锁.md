---
title: Redis分布式锁
author: Marlowe
tags: Redis
categories: NoSQL
abbrlink: 64631
date: 2021-05-06 16:55:54
---

<!--more-->

### 问题描述

随着业务发展的需要，原单体单机部署的系统被演化成分布式集群系统后，由于分布式系统多线程、多进程并且分布在不同机器上，这将使原单机部署情况下的并发控制锁策略失效，单纯的Java API并不能提供分布式锁的能力。为了解决这个问题就需要一种跨JVM的互斥机制来控制共享资源的访问，这就是分布式锁要解决的问题！

#### 分布式锁主流的实现方案

1. 基于数据库实现分布式锁
2. 基于缓存（Redis等）
3. 基于Zookeeper


每一种分布式锁解决方案都有各自的优缺点：
1. 性能：redis最高
2. 可靠性：zookeeper最高

#### 使用redis实现分布式锁

#### redis:命令

```bash
# set sku:1:info “OK” NX PX 10000
```
EX second：设置键的过期时间为 second 秒。 SET key value EX second 效果等同于 SETEX key second value 。
PX millisecond：设置键的过期时间为 millisecond 毫秒。 SET key value PX millisecond 效果等同于 PSETEX key millisecond value 。
NX：只在键不存在时，才对键进行设置操作。 SET key value NX 效果等同于 SETNX key value 。
XX：只在键已经存在时，才对键进行设置操作。

![20210506170123](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170123.png)

1. 多个客户端同时获取锁（setnx）
2. 获取成功，执行业务逻辑{从db获取数据，放入缓存}，执行完成释放锁（del）
3. 其他客户端等待重试


#### 代码测试


```java
@GetMapping("testLock")
public void testLock(){
    //1获取锁，setne
    Boolean lock = redisTemplate.opsForValue().setIfAbsent("lock", "111");
    //2获取锁成功、查询num的值
    if(lock){
        Object value = redisTemplate.opsForValue().get("num");
        //2.1判断num为空return
        if(StringUtils.isEmpty(value)){
            return;
        }
        //2.2有值就转成成int
        int num = Integer.parseInt(value+"");
        //2.3把redis的num加1
        redisTemplate.opsForValue().set("num", ++num);
        //2.4释放锁，del
        redisTemplate.delete("lock");

    }else{
        //3获取锁失败、每隔0.1秒再获取
        try {
            Thread.sleep(100);
            testLock();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```
重启，服务集群，通过网关压力测试：
ab -n 1000 -c 100 http://192.168.140.1:8080/test/testLock

![20210506170249](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170249.png)

查看redis中num的值：

![20210506170305](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170305.png)

基本实现。
问题：setnx刚好获取到锁，业务逻辑出现异常，导致锁无法释放
解决：设置过期时间，自动释放锁。

#### 优化之设置锁的过期时间

设置过期时间有两种方式：

1. 首先想到通过expire设置过期时间（缺乏原子性：如果在setnx和expire之间出现异常，锁也无法释放）
2. 在set时指定过期时间（推荐）

![20210506170350](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170350.png)

设置过期时间：

![20210506170416](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170416.png)


**问题：** 可能会释放其他服务器的锁。

**场景：** 如果业务逻辑的执行时间是7s。执行流程如下
1. index1业务逻辑没执行完，3秒后锁被自动释放。
2. index2获取到锁，执行业务逻辑，3秒后锁被自动释放。
3. index3获取到锁，执行业务逻辑
4. index1业务逻辑执行完成，开始调用del释放锁，这时释放的是index3的锁，导致index3的业务只执行1s就被别人释放。
最终等于没锁的情况。

**解决：** setnx获取锁时，设置一个指定的唯一值（例如：uuid）；释放前获取这个值，判断是否自己的锁

#### 优化之UUID防误删

![20210506170540](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170540.png)


![20210506170609](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170609.png)


**问题：** 删除操作缺乏原子性。
**场景：**
1. index1执行删除时，查询到的lock值确实和uuid相等
uuid=v1
set(lock,uuid)；

![20210506170647](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170647.png)

2. index1执行删除前，lock刚好过期时间已到，被redis自动释放
在redis中没有了lock，没有了锁。

![20210506170701](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170701.png)


3. index2获取了lock
index2线程获取到了cpu的资源，开始执行方法
uuid=v2
set(lock,uuid)；
4. index1执行删除，此时会把index2的lock删除
index1 因为已经在方法中了，所以不需要重新上锁。index1有执行的权限。index1已经比较完成了，这个时候，开始执行

![20210506170719](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170719.png)

删除的index2的锁！

#### 优化之LUA脚本保证删除的原子性

```java
@GetMapping("testLockLua")
public void testLockLua() {
    //1 声明一个uuid ,将做为一个value 放入我们的key所对应的值中
    String uuid = UUID.randomUUID().toString();
    //2 定义一个锁：lua 脚本可以使用同一把锁，来实现删除！
    String skuId = "25"; // 访问skuId 为25号的商品 100008348542
    String locKey = "lock:" + skuId; // 锁住的是每个商品的数据

    // 3 获取锁
    Boolean lock = redisTemplate.opsForValue().setIfAbsent(locKey, uuid, 3, TimeUnit.SECONDS);

    // 第一种： lock 与过期时间中间不写任何的代码。
    // redisTemplate.expire("lock",10, TimeUnit.SECONDS);//设置过期时间
    // 如果true
    if (lock) {
        // 执行的业务逻辑开始
        // 获取缓存中的num 数据
        Object value = redisTemplate.opsForValue().get("num");
        // 如果是空直接返回
        if (StringUtils.isEmpty(value)) {
            return;
        }
        // 不是空 如果说在这出现了异常！ 那么delete 就删除失败！ 也就是说锁永远存在！
        int num = Integer.parseInt(value + "");
        // 使num 每次+1 放入缓存
        redisTemplate.opsForValue().set("num", String.valueOf(++num));
        /*使用lua脚本来锁*/
        // 定义lua 脚本
        String script = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";
        // 使用redis执行lua执行
        DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
        redisScript.setScriptText(script);
        // 设置一下返回值类型 为Long
        // 因为删除判断的时候，返回的0,给其封装为数据类型。如果不封装那么默认返回String 类型，
        // 那么返回字符串与0 会有发生错误。
        redisScript.setResultType(Long.class);
        // 第一个要是script 脚本 ，第二个需要判断的key，第三个就是key所对应的值。
        redisTemplate.execute(redisScript, Arrays.asList(locKey), uuid);
    } else {
        // 其他线程等待
        try {
            // 睡眠
            Thread.sleep(1000);
            // 睡醒了之后，调用方法。
            testLockLua();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```

Lua 脚本详解：

![20210506170821](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170821.png)

[Redis Lua脚本的执行原理](https://segmentfault.com/a/1190000018808492)


项目中正确使用：

1. 定义key，key应该是为每个sku定义的，也就是每个sku有一把锁。
String locKey ="lock:"+skuId; // 锁住的是每个商品的数据
Boolean lock = redisTemplate.opsForValue().setIfAbsent(locKey, uuid,3,TimeUnit.SECONDS);

![20210506170844](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210506170844.png)

### Lua脚本执行原理



### 总结

1、加锁
```java
// 1. 从redis中获取锁,set k1 v1 px 20000 nx
String uuid = UUID.randomUUID().toString();
Boolean lock = this.redisTemplate.opsForValue()
      .setIfAbsent("lock", uuid, 2, TimeUnit.SECONDS);
```
2、使用lua释放锁

```java
// 2. 释放锁 del
String script = "if redis.call('get', KEYS[1]) == ARGV[1] then return redis.call('del', KEYS[1]) else return 0 end";
// 设置lua脚本返回的数据类型
DefaultRedisScript<Long> redisScript = new DefaultRedisScript<>();
// 设置lua脚本返回类型为Long
redisScript.setResultType(Long.class);
redisScript.setScriptText(script);
redisTemplate.execute(redisScript, Arrays.asList("lock"),uuid);
```

3、重试

```java
Thread.sleep(500);
testLock();
```

为了确保分布式锁可用，我们至少要确保锁的实现同时满足以下四个条件：
- 互斥性。在任意时刻，只有一个客户端能持有锁。
- 不会发生死锁。即使有一个客户端在持有锁的期间崩溃而没有主动解锁，也能保证后续其他客户端能加锁。
- 解铃还须系铃人。加锁和解锁必须是同一个客户端，客户端自己不能把别人加的锁给解了。
- 加锁和解锁必须具有原子性。









