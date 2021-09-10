---
title: Java线程安全的集合类
author: Marlowe
tags: 集合类
categories: Java
abbrlink: 1493
date: 2021-08-29 16:54:56
---

<!--more-->

### 一、早期线程安全的集合

我们先从早期的线程安全的集合说起，它们是Vector和HashTable

#### 1.Vector

Vector和ArrayList类似，是长度可变的数组，与ArrayList不同的是，Vector是线程安全的，它给几乎所有的public方法都加上了synchronized关键字。由于加锁导致性能降低，在不需要并发访问同一对象时，这种强制性的同步机制就显得多余，所以现在Vector已被弃用。

#### 2.HashTable
HashTable和HashMap类似，不同点是HashTable是线程安全的，它给几乎所有public方法都加上了synchronized关键字，还有一个不同点是HashTable的K，V都不能是null，但HashMap可以，它现在也因为性能原因被弃用了。

### 二、Collections包装方法

Vector和HashTable被弃用后，它们被ArrayList和HashMap代替，但它们不是线程安全的，所以Collections工具类中提供了相应的包装方法把它们包装成线程安全的集合

```java
List<E> synArrayList = Collections.synchronizedList(new ArrayList<E>());

Set<E> synHashSet = Collections.synchronizedSet(new HashSet<E>());

Map<K,V> synHashMap = Collections.synchronizedMap(new HashMap<K,V>());

...
```

Collections针对每种集合都声明了一个线程安全的包装类，在原集合的基础上添加了锁对象，集合中的每个方法都通过这个锁对象实现同步。

### 三、java.util.concurrent包中的集合

#### 1.ConcurrentHashMap

ConcurrentHashMap和HashTable都是线程安全的集合，它们的不同主要是加锁粒度上的不同。HashTable的加锁方法是给每个方法加上synchronized关键字，这样锁住的是整个Table对象。而ConcurrentHashMap是更细粒度的加锁。

在JDK1.8之前，ConcurrentHashMap加的是分段锁，也就是Segment锁，每个Segment含有整个table的一部分，这样不同分段之间的并发操作就互不影响。

JDK1.8对此做了进一步的改进，它取消了Segment字段，直接在table元素上加锁，实现对每一行进行加锁，进一步减小了并发冲突的概率。

#### 2.CopyOnWriteArrayList和CopyOnWriteArraySet

它们是加了写锁的ArrayList和ArraySet，锁住的是整个对象，但读操作可以并发执行。

#### 3.

除此之外还有ConcurrentSkipListMap、ConcurrentSkipListSet、ConcurrentLinkedQueue、ConcurrentLinkedDeque等，至于为什么没有ConcurrentArrayList，原因是无法设计一个通用的而且可以规避ArrayList的并发瓶颈的线程安全的集合类，只能锁住整个list，这用Collections里的包装类就能办到。
