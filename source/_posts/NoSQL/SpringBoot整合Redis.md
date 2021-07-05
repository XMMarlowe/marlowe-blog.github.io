---
title: SpringBoot整合Redis
author: Marlowe
tags:
  - Redis
  - SpringBoot
categories: NoSQL
abbrlink: 13813
date: 2020-12-23 21:59:54
---
<!--more-->

说明：SpringBoot2.x之后，原来使用jedis被替换为了lettuce
jedis：采用的直连，多个线程操作的话，是不安全的，如果想要避免不安全，使用jedis pool连接池！ 更像BIO模式
lettuce：采用netty，示例可以在多个线程中共享，不存在线程不安全的情况！可以减少线程数据了，更像NIO模式

### 原码分析：
```java
@Bean
@ConditionalOnMissingBean(name = "redisTemplate")// 我们可以自定义一个redisTemplate来替换这个默认的！
@ConditionalOnSingleCandidate(RedisConnectionFactory.class)
public RedisTemplate<Object, Object> redisTemplate(RedisConnectionFactory redisConnectionFactory) {
    // 默认的RedisTemplate没有过多的设置，redis对象都是需要序列化！
    // 两个泛型都是Object，Object的类型，我们使用需要强制转换<String,Object>
    RedisTemplate<Object, Object> template = new RedisTemplate<>();
    template.setConnectionFactory(redisConnectionFactory);
    return template;
}

@Bean
@ConditionalOnMissingBean // 由于tring是redis中最常使用的类型，所以单独提取出来了一个bean！
@ConditionalOnSingleCandidate(RedisConnectionFactory.class)
public StringRedisTemplate stringRedisTemplate(RedisConnectionFactory redisConnectionFactory) {
    StringRedisTemplate template = new StringRedisTemplate();
    template.setConnectionFactory(redisConnectionFactory);
    return template;
}
```

### 整合测试

1. 导入依赖
```xml
<!--操作redis-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-redis</artifactId>
</dependency>
```
2. 配置连接
```xml
spring.redis.host=127.0.0.1
spring.redis.port=6379
```
3. 测试
```java
@Test
void contextLoads() {

    // 获取redis的连接对象
    // RedisConnection connection = redisTemplate.getConnectionFactory().getConnection();
    // connection.flushDb();
    // connection.flushAll();
    redisTemplate.opsForValue().set("mykey", "kuangshen");
    System.out.println(redisTemplate.opsForValue().get("mykey"));
}
```



