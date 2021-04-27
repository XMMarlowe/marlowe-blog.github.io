---
title: Java如何开启线程?怎么保证线程安全?
author: Marlowe
tags:
  - Java
  - 线程
  - 线程安全
categories: 并发
abbrlink: 41203
date: 2021-04-26 21:57:17
---

<!--more-->

### 线程和进程的区别
进程是操作系统进行资源分配的最小单元。线程是操作系统进行任务调度分配的最小单元，线程隶属于进程。

### 如何开启线程？

1. 继承Thread类,重写run方法。
2. 实现Runnable接口， 实现run方法。
3. 实现Callable接口， 实现call方法。通过FutureTask创建一个线程，获取到线程执行的返回值。
4. 通过线程池来开启线程。


### 怎么保证线程安全？

**加锁**

1. JVM提供的锁，也就是Synchronized关键字。
2. JDK提供的各种锁。






