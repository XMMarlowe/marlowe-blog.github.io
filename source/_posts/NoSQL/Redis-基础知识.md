---
title: Redis 基础知识
author: Marlowe
tags:
  - Redis
categories: NoSQL
abbrlink: 51737
date: 2020-12-19 16:19:14
---
Redis 基础知识
<!--more-->
> Redis 是单线程的！

Redis 是很快的，官方表示，Redis 是基于内存操作，CPU 不是Redis性能瓶颈，Redis 的瓶颈是根据机器的内存和网络带宽，既然可以使用单线程实现，就使用单线程了。

Redis 是C语言写的，官方提供的数据位100000+的QPS，完全不比同样的使用key-value的Memecache差。

**Redis 单线程为什么还这么快？**
1. 误区1： 高性能服务器一定是多线程的？
2. 误区2： 多线程(CPU上下文会切换)一定比单线程效率高？

核心：Redis 是将所有的数据全部放在内存中的，所以说使用单线程去操作效率就是最高的，多线程(CPU上下文切换：耗时的操作！！)对于内存系统来说，如果没有上下文切换效率就是最高的！多次读写都是在一个CPU上，在内存情况下，这就是最佳的方案！
