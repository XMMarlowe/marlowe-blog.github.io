---
title: ConcurrentHashMap 和 Hashtable 的区别
author: Marlowe
abbrlink: 48033
date: 2020-03-16 09:56:52
tags: 
  - HashMap
  - 线程安全
categories: Java
---
`ConcurrentHashMap` 和 `Hashtable` 的区别主要体现在实现线程安全的方式上不同。
<!--more-->

* **底层数据结构：** JDK1.7 的 ConcurrentHashMap 底层采用 `分段的数组+链表` 实现，JDK1.8 采用的数据结构跟 HashMap1.8 的结构一样，`数组+链表/红黑二叉树`。Hashtable 和 JDK1.8 之前的 HashMap 的底层数据结构类似都是采用 `数组+链表` 的形式，数组是 HashMap 的主体，链表则是主要为了解决哈希冲突而存在的；
* **实现线程安全的方式（重要）：** ① 在 JDK1.7 的时候，ConcurrentHashMap（分段锁） 对整个桶数组进行了分割分段(Segment)，每一把锁只锁容器其中一部分数据，多线程访问容器里不同数据段的数据，就不会存在锁竞争，提高并发访问率。 **到了 JDK1.8 的时候已经摒弃了 Segment 的概念，而是直接用 Node 数组+链表+红黑树的数据结构来实现，并发控制使用 synchronized 和 CAS 来操作。**（JDK1.6 以后 对 synchronized 锁做了很多优化） 整个看起来就像是优化过且线程安全的 HashMap，虽然在 JDK1.8 中还能看到 Segment 的数据结构，但是已经简化了属性，只是为了兼容旧版本；② Hashtable(同一把锁) :使用 synchronized 来保证线程安全，效率非常低下。当一个线程访问同步方法时，其他线程也访问同步方法，可能会进入阻塞或轮询状态，如使用 put 添加元素，另一个线程不能使用 put 添加元素，也不能使用 get，竞争会越来越激烈效率越低。

**两者的对比图**：
HashTable:
![20210316200957](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210316200957.png)

JDK1.7 的 ConcurrentHashMap：
![20210316201014](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210316201014.png)

JDK1.8 的 ConcurrentHashMap：
![20210316201027](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210316201027.png)
JDK1.8 的 ConcurrentHashMap 不再是 Segment 数组 + HashEntry 数组 + 链表，而是 Node 数组 + 链表 / 红黑树。不过，Node 只能用于链表的情况，红黑树的情况需要使用 **TreeNode**。当冲突链表达到一定长度时，链表会转换成红黑树。