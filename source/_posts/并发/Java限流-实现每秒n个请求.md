---
title: Java限流-实现每秒n个请求
author: Marlowe
tags:
  - Java
  - 限流
categories: 并发
abbrlink: 12824
date: 2021-05-15 14:33:10
---

<!--more-->


### 概要

在大数据量高并发访问时，经常会出现服务或接口面对暴涨的请求而不可用的情况，甚至引发连锁反映导致整个系统崩溃。此时你需要使用的技术手段之一就是限流，当请求达到一定的并发数或速率，就进行等待、排队、降级、拒绝服务等。在限流时，常见的两种算法是漏桶和令牌桶算法算法。

### 限流算法

令牌桶(Token Bucket)、漏桶(leaky bucket)和计数器算法是最常用的三种限流的算法。

#### 1. 令牌桶算法

![20210515153109](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210515153109.png)

令牌桶算法的原理是系统会以一个恒定的速度往桶里放入令牌，而如果请求需要被处理，则需要先从桶里获取一个令牌，当桶里没有令牌可取时，则拒绝服务。 当桶满时，新添加的令牌被丢弃或拒绝。

代码示例：
```java
public class RateLimiterDemo {
    private static RateLimiter limiter = RateLimiter.create(5);
 
    public static void exec() {
        limiter.acquire(1);
        try {
            // 处理核心逻辑
            TimeUnit.SECONDS.sleep(1);
            System.out.println("--" + System.currentTimeMillis() / 1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }
}
```
Guava RateLimiter 提供了令牌桶算法可用于平滑突发限流策略。
该示例为每秒中产生5个令牌，每200毫秒会产生一个令牌。
limiter.acquire() 表示消费一个令牌。当桶中有足够的令牌时，则直接返回0，否则阻塞，直到有可用的令牌数才返回，返回的值为阻塞的时间。

#### 2. 漏桶算法

![20210515153205](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210515153205.png)

它的主要目的是控制数据注入到网络的速率，平滑网络上的突发流量，数据可以以任意速度流入到漏桶中。漏桶算法提供了一种机制，通过它，突发流量可以被整形以便为网络提供一个稳定的流量。 漏桶可以看作是一个带有常量服务时间的单服务器队列，如果漏桶为空，则不需要流出水滴，如果漏桶（包缓存）溢出，那么水滴会被溢出丢弃。

#### 3. 计数器限流算法

计数器限流算法也是比较常用的，主要用来限制总并发数，比如数据库连接池大小、线程池大小、程序访问并发数等都是使用计数器算法。

代码示例1：

```java
public class CountRateLimiterDemo1 {
 
    private static AtomicInteger count = new AtomicInteger(0);
 
    public static void exec() {
        if (count.get() >= 5) {
            System.out.println("请求用户过多，请稍后在试！"+System.currentTimeMillis()/1000);
        } else {
            count.incrementAndGet();
            try {
                //处理核心逻辑
                TimeUnit.SECONDS.sleep(1);
                System.out.println("--"+System.currentTimeMillis()/1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            } finally {
                count.decrementAndGet();
            }
        }
    }
}
```
使用AomicInteger来进行统计当前正在并发执行的次数，如果超过域值就简单粗暴的直接响应给用户，说明系统繁忙，请稍后再试或其它跟业务相关的信息。

> 弊端：使用 AomicInteger 简单粗暴超过域值就拒绝请求，可能只是瞬时的请求量高，也会拒绝请求。

代码示例2：
```java
public class CountRateLimiterDemo2 {
 
    private static Semaphore semphore = new Semaphore(5);
 
    public static void exec() {
        if(semphore.getQueueLength()>100){
            System.out.println("当前等待排队的任务数大于100，请稍候再试...");
        }
        try {
            semphore.acquire();
            // 处理核心逻辑
            TimeUnit.SECONDS.sleep(1);
            System.out.println("--" + System.currentTimeMillis() / 1000);
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            semphore.release();
        }
    }
}
```

使用Semaphore信号量来控制并发执行的次数，如果超过域值信号量，则进入阻塞队列中排队等待获取信号量进行执行。如果阻塞队列中排队的请求过多超出系统处理能力，则可以在拒绝请求。

> 相对Atomic优点：如果是瞬时的高并发，可以使请求在阻塞队列中排队，而不是马上拒绝请求，从而达到一个流量削峰的目的。

### 参考

[Java限流策略](https://www.cnblogs.com/java1024/p/7725632.html)