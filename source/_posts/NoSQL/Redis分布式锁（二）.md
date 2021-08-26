---
title: Redis分布式锁（二）
author: Marlowe
tags: Redis
categories: NoSQL
abbrlink: 49827
date: 2021-08-22 14:45:29
---

<!--more-->

### Redis分布式锁01

JVM层面的加锁，单机版的锁

* synchronized
* ReentraLock

```java
class X {
    private final ReentrantLock lock = new ReentrantLock();
    // ...

    public void m() {
        lock.lock();  // block until condition holds//不见不散
        try {
            // ... method body
        } finally {
            lock.unlock()
        }
    }
     
     
    public void m2() {

       	if(lock.tryLock(timeout, unit)){//过时不候
            try {
            // ... method body
            } finally {
                lock.unlock()
            }   
        }else{
            // perform alternative actions
        }
   }
 }
```

### Redis分布式锁02

分布式部署后，单机锁还是出现超卖现象，需要分布式锁

![20210822145208](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210822145208.png)

Redis具有极高的性能，且其命令对分布式锁支持友好，借助SET命令即可实现加锁处理。

[SET](https://redis.io/commands/set)

* EX seconds – Set the specified expire time, in seconds.
* PX milliseconds – Set the specified expire time, in milliseconds.
* NX – Only set the key if it does not already exist.
* XX – Only set the key if it already exist.

在Java层面

```java
public static final String REDIS_LOCK = "redis_lock";

@Autowired
private StringRedisTemplate stringRedisTemplate;

public void m(){
    String value = UUID.randomUUID().toString() + Thread.currentThread().getName();

    Boolean flag = stringRedisTemplate.opsForValue().setIfAbsent(REDIS_LOCK, value);


    if(!flag) {
        return "抢锁失败";
    }
 
    ...//业务逻辑
    
    stringRedisTemplate.delete(REDIS_LOCK);
}
```


### Redis分布式锁03

**上面Java源码分布式锁问题：** 出现异常的话，可能无法释放锁，必须要在代码层面finally释放锁。

解决方法：try…finally…

```java
public static final String REDIS_LOCK = "redis_lock";

@Autowired
private StringRedisTemplate stringRedisTemplate;

public void m(){
    String value = UUID.randomUUID().toString() + Thread.currentThread().getName();

    try{
		Boolean flag = stringRedisTemplate.opsForValue().setIfAbsent(REDIS_LOCK, value);

   		if(!flag) {
        	return "抢锁失败";
	    }
        
    	...//业务逻辑
            
    }finally{
	    stringRedisTemplate.delete(REDIS_LOCK);   
    }
}
```

---

**另一个问题：** 部署了微服务jar包的机器挂了，代码层面根本没有走到finally这块，没办法保证解锁，这个key没有被删除，需要加入一个过期时间限定key。

```java
public static final String REDIS_LOCK = "redis_lock";

@Autowired
private StringRedisTemplate stringRedisTemplate;

public void m(){
    String value = UUID.randomUUID().toString() + Thread.currentThread().getName();

    try{
		Boolean flag = stringRedisTemplate.opsForValue().setIfAbsent(REDIS_LOCK, value);
		//设定时间
        stringRedisTemplate.expire(REDIS_LOCK, 10L, TimeUnit.SECONDS);
        
   		if(!flag) {
        	return "抢锁失败";
	    }
        
    	...//业务逻辑
            
    }finally{
	    stringRedisTemplate.delete(REDIS_LOCK);   
    }
}
```

### Redis分布式锁04

**新问题**：设置key+过期时间分开了，必须要合并成一行具备原子性。

解决方法：

```java
public static final String REDIS_LOCK = "redis_lock";

@Autowired
private StringRedisTemplate stringRedisTemplate;

public void m(){
    String value = UUID.randomUUID().toString() + Thread.currentThread().getName();

    try{
		Boolean flag = stringRedisTemplate.opsForValue()//使用另一个带有设置超时操作的方法
            .setIfAbsent(REDIS_LOCK, value, 10L, TimeUnit.SECONDS);
		//设定时间
        //stringRedisTemplate.expire(REDIS_LOCK, 10L, TimeUnit.SECONDS);
        
   		if(!flag) {
        	return "抢锁失败";
	    }
        
    	...//业务逻辑
            
    }finally{
	    stringRedisTemplate.delete(REDIS_LOCK);   
    }
}
```

---
**另一个新问题：** 张冠李戴，删除了别人的锁

![20210822145629](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210822145629.png)

解决方法：只能自己删除自己的，不许动别人的。

```java
public static final String REDIS_LOCK = "redis_lock";

@Autowired
private StringRedisTemplate stringRedisTemplate;

public void m(){
    String value = UUID.randomUUID().toString() + Thread.currentThread().getName();

    try{
		Boolean flag = stringRedisTemplate.opsForValue()//使用另一个带有设置超时操作的方法
            .setIfAbsent(REDIS_LOCK, value, 10L, TimeUnit.SECONDS);
		//设定时间
        //stringRedisTemplate.expire(REDIS_LOCK, 10L, TimeUnit.SECONDS);
        
   		if(!flag) {
        	return "抢锁失败";
	    }
        
    	...//业务逻辑
            
    }finally{
        if(stringRedisTemplate.opsForValue().get(REDIS_LOCK).equals(value)) {
            stringRedisTemplate.delete(REDIS_LOCK);
        }
    }
}
```

### Redis分布式锁05

**问题：** finally块的判断 + del删除操作不是原子性的

* 用lua脚本

* 用redis自身的事务

事务介绍

* Redis的事条是通过MULTI，EXEC，DISCARD和WATCH这四个命令来完成。
* Redis的单个命令都是原子性的，所以这里确保事务性的对象是命令集合。
* Redis将命令集合序列化并确保处于一事务的命令集合连续且不被打断的执行。
* Redis不支持回滚的操作。

![20210822145902](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210822145902.png)

### Redis分布式锁06

继续上一章节，解决之道

```java
public static final String REDIS_LOCK = "redis_lock";

@Autowired
private StringRedisTemplate stringRedisTemplate;

public void m(){
    String value = UUID.randomUUID().toString() + Thread.currentThread().getName();

    try{
		Boolean flag = stringRedisTemplate.opsForValue()//使用另一个带有设置超时操作的方法
            .setIfAbsent(REDIS_LOCK, value, 10L, TimeUnit.SECONDS);
		//设定时间
        //stringRedisTemplate.expire(REDIS_LOCK, 10L, TimeUnit.SECONDS);
        
   		if(!flag) {
        	return "抢锁失败";
	    }
        
    	...//业务逻辑
            
    }finally{
        while(true){
            stringRedisTemplate.watch(REDIS_LOCK);
            if(stringRedisTemplate.opsForValue().get(REDIS_LOCK).equalsIgnoreCase(value)){
                stringRedisTemplate.setEnableTransactionSupport(true);
                stringRedisTemplate.multi();
                stringRedisTemplate.delete(REDIS_LOCK);
                List<Object> list = stringRedisTemplate.exec();
                if (list == null) {
                    continue;
                }
            }
            stringRedisTemplate.unwatch();
            break;
        } 
    }
}
```

### Redis分布式锁07

Redis调用Lua脚本通过eval命令保证代码执行的原子性

RedisUtils：

```java
import redis.clients.jedis.JedisPool;
import redis.clients.jedis.JedisPoolConfig;

public class RedisUtils {

	private static JedisPool jedisPool;
	
	static {
		JedisPoolConfig jpc = new JedisPoolConfig();
		jpc.setMaxTotal(20);
		jpc.setMaxIdle(10);
		jedisPool = new JedisPool(jpc);
	}
	
	public static JedisPool getJedis() throws Exception{
		if(jedisPool == null)
			throw new NullPointerException("JedisPool is not OK.");
		return jedisPool;
	}
	
}
```

```java
public static final String REDIS_LOCK = "redis_lock";

@Autowired
private StringRedisTemplate stringRedisTemplate;

public void m(){
    String value = UUID.randomUUID().toString() + Thread.currentThread().getName();

    try{
		Boolean flag = stringRedisTemplate.opsForValue()//使用另一个带有设置超时操作的方法
            .setIfAbsent(REDIS_LOCK, value, 10L, TimeUnit.SECONDS);
		//设定时间
        //stringRedisTemplate.expire(REDIS_LOCK, 10L, TimeUnit.SECONDS);
        
   		if(!flag) {
        	return "抢锁失败";
	    }
        
    	...//业务逻辑
            
    }finally{
    	Jedis jedis = RedisUtils.getJedis();
    	
    	String script = "if redis.call('get', KEYS[1]) == ARGV[1] "
    			+ "then "
    			+ "    return redis.call('del', KEYS[1]) "
    			+ "else "
    			+ "    return 0 "
    			+ "end";
    	
    	try {
    		
    		Object o = jedis.eval(script, Collections.singletonList(REDIS_LOCK),// 
    				Collections.singletonList(value));
    		
    		if("1".equals(o.toString())) {
    			System.out.println("---del redis lock ok.");
    		}else {
    			System.out.println("---del redis lock error.");
    		}
    		
    		
    	}finally {
    		if(jedis != null) 
    			jedis.close();
    	}
    }
}
```

### Redis分布式锁08

确保RedisLock过期时间大于业务执行时间的问题

Redis分布式锁如何续期？

集群 + CAP对比ZooKeeper 对比ZooKeeper，重点，CAP

* Redis - AP -redis异步复制造成的锁丢失，比如：主节点没来的及把刚刚set进来这条数据给从节点，就挂了。
* ZooKeeper - CP

CAP

* C：Consistency（强一致性）
* A：Availability（可用性）
* P：Partition tolerance（分区容错性）

综上所述

Redis集群环境下，**我们自己写的也不OK**，直接上RedLock之Redisson落地实现。


### Redis分布式锁09

[Redisson官方网站](https://redisson.org/)

Redisson配置类:
```java
import org.redisson.Redisson;
import org.redisson.config.Config;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;


@Configuration
public class RedisConfig {

    @Bean
    public Redisson redisson() {
    	Config config = new Config();
    	config.useSingleServer().setAddress("redis://127.0.0.1:6379").setDatabase(0);
    	return (Redisson)Redisson.create(config);
    }
    
}
```
Redisson模板

```java
public static final String REDIS_LOCK = "REDIS_LOCK";

@Autowired
private Redisson redisson;

@GetMapping("/doSomething")
public String doSomething(){

    RLock redissonLock = redisson.getLock(REDIS_LOCK);
    redissonLock.lock();
    try {
        //doSomething
    }finally {
        redissonLock.unlock();
    }
}
```
---

回到实例

```java
import org.redisson.Redisson;
import org.redisson.api.RLock;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class GoodController{

	public static final String REDIS_LOCK = "REDIS_LOCK";
	
    @Autowired
    private StringRedisTemplate stringRedisTemplate;

    @Value("${server.port}")
    private String serverPort;
    
    @Autowired
    private Redisson redisson;
    
    @GetMapping("/buy_goods")
    public String buy_Goods(){
    	
    	//String value = UUID.randomUUID().toString() + Thread.currentThread().getName();
    	
    	RLock redissonLock = redisson.getLock(REDIS_LOCK);
    	redissonLock.lock();
    	try {
	        String result = stringRedisTemplate.opsForValue().get("goods:001");// get key ====看看库存的数量够不够
	        int goodsNumber = result == null ? 0 : Integer.parseInt(result);
	        if(goodsNumber > 0){
	            int realNumber = goodsNumber - 1;
	            stringRedisTemplate.opsForValue().set("goods:001", String.valueOf(realNumber));
	            System.out.println("成功买到商品，库存还剩下: "+ realNumber + " 件" + "\t服务提供端口" + serverPort);
	            return "成功买到商品，库存还剩下:" + realNumber + " 件" + "\t服务提供端口" + serverPort;
	        }else{
	            System.out.println("商品已经售完/活动结束/调用超时,欢迎下次光临" + "\t服务提供端口" + serverPort);
	        }
	
	        return "商品已经售完/活动结束/调用超时,欢迎下次光临" + "\t服务提供端口" + serverPort;
    	}finally {
    		redissonLock.unlock();
    	}
    }
    
}
```

### Redis分布式锁10

让代码更加严谨

```java
public static final String REDIS_LOCK = "REDIS_LOCK";

@Autowired
private Redisson redisson;

@GetMapping("/doSomething")
public String doSomething(){

    RLock redissonLock = redisson.getLock(REDIS_LOCK);
    redissonLock.lock();
    try {
        //doSomething
    }finally {
    	//添加后，更保险
		if(redissonLock.isLocked() && redissonLock.isHeldByCurrentThread()) {
    		redissonLock.unlock();
    	}
    }
}
```

可避免如下异常：

```java
IllegalMonitorStateException: attempt to unlock lock，not loked by current thread by node id:da6385f-81a5-4e6c-b8c0
```

### Redis分布式锁总结回顾

synchronized单机版oK，上分布式

nginx分布式微服务单机锁不行

取消单机锁，上Redis分布式锁setnx

只加了锁，没有释放锁，出异常的话，可能无法释放锁,必须要在代码层面finally释放锁

宕机了，部署了微服务代码层面根本没有走到finally这块，没办法保证解锁，这个key没有被删除，
需要有lockKey的过期时间设定

为redis的分布式锁key，增加过期时间，此外，还必须要setnx+过期时间必须同一行

必须规定只能自己删除自己的锁,你不能把别人的锁删除了，防止张冠李戴，1删2，2删3

Redis集群环境下，我们自己写的也不oK直接上RedLock之Redisson落地实现


### 参考
[Java开发常见面试题详解（LockSupport，AQS，Spring循环依赖，Redis）](https://blog.csdn.net/u011863024/article/details/115270840)