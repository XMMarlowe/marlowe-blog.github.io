---
title: Redis 对比 MySQL，为什么 redis 是快的？
author: Marlowe
abbrlink: 63998
date: 2021-04-15 23:00:53
tags: 
  - Redis
  - MySQL
categories: NoSQL
---

<!--more-->


1.Redis是基于内存存储的，MySQL是基于磁盘存储的

2.Redis存储的是k-v格式的数据。时间复杂度是O(1),常数阶，而MySQL引擎的底层实现是B+Tree，时间复杂度是O(logn)，对数阶。Redis会比MySQL快一点点。

3.MySQL数据存储是存储在表中，查找数据时要先对表进行全局扫描或者根据索引查找，这涉及到磁盘的查找，磁盘查找如果是按条点查找可能会快点，但是顺序查找就比较慢；而Redis不用这么麻烦，本身就是存储在内存中，会根据数据在内存的位置直接取出。

4.Redis是单线程的多路复用IO，单线程避免了线程切换的开销，而多路复用IO避免了IO等待的开销，在多核处理器下提高处理器的使用效率可以对数据进行分区，然后每个处理器处理不同的数据。


### 参考
[Redis为什么会比MySQL快？](https://blog.csdn.net/weixin_44758458/article/details/91982767)