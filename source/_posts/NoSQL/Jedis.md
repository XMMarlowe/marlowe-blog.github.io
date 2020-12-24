---
title: Jedis
author: Marlowe
tags:
  - Redis
  - Jedis
categories: NoSQL
abbrlink: 26793
date: 2020-12-23 21:19:43
---
...
<!--more-->

### 简介
Jedis 是 Redis官方推荐的Java连接开发工具，使用Java操作Redis中间件。

### 测试
1. 导入对应的依赖
```xml
<!--导入jedis的依赖-->
    <dependencies>
        <dependency>
            <groupId>redis.clients</groupId>
            <artifactId>jedis</artifactId>
            <version>3.2.0</version>
        </dependency>
        <dependency>
            <groupId>com.alibaba</groupId>
            <artifactId>fastjson</artifactId>
            <version>1.2.62</version>
        </dependency>
    </dependencies>
```
2. 编码测试
* 连接数据库
* 操作命令
* 断开连接
```java
public class TestPing {

    public static void main(String[] args) {
        // 1、new Jedis对象
        Jedis jedis = new Jedis("127.0.0.1", 6379);

        System.out.println(jedis.ping());
    }

}
```
输出：
![20201223212734](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201223212734.png)

操作事务：
```java
public class TestTx {
    public static void main(String[] args) {
        Jedis jedis = new Jedis("127.0.0.1", 6379);

        jedis.flushDB();
        JSONObject jsonObject = new JSONObject();
        jsonObject.put("hello", "world");
        jsonObject.put("name", "marlowe");

        // 开启事务
        Transaction multi = jedis.multi();
        String result = jsonObject.toJSONString();

        try {
            multi.set("user1", result);
            multi.set("user2", result);
            // 代码抛出异常，事务执行失败
            int i = 1 / 0;
            // 执行事务
            multi.exec();
        } catch (Exception e) {
            // 放弃事务
            multi.discard();
            e.printStackTrace();
        } finally {
            System.out.println(jedis.get("user1"));
            System.out.println(jedis.get("user2"));
            jedis.close();
        }
    }
}
```
输出：
![20201223214213](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201223214213.png)