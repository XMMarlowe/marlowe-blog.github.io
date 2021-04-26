---
title: synchronized和Lock区别
author: Marlowe
tags:
  - 多线程
  - Java
  - 锁
categories: 并发
abbrlink: 48506
date: 2020-12-02 22:19:29
---
简述 synchronized 和 Lock 区别...
<!--more-->

1. synchronized 内置的Java关键字；Lock 是一个Java类
2. synchronized 无法判断获取锁的状态；Lock 可以判断是否获取了锁
3. synchronized 会自动释放锁；Lock 必须要手动释放锁！ 如果不释放，**死锁**
4. synchronized 线程1（获得锁，阻塞）、线程2（等待、傻傻的等）；Lock 锁就不一定会等待下去
5. synchronized 可重入锁，不可以中断的，非公平的；Lock ，可重入锁，可以判断锁，非公平（可以自己设置）
6. synchronized 适合锁少量的代码同步问题；Lock 适合锁大量的！
7. Synchronized关键字，用来加锁。Volatile只是保持变 量的线程可见性。通常适用于一个线程写，多个线程读的场景。

### Volatile能不能保证线程安全？
不能。Volatile关键字只能保证线程可见性，不能保证原子性。详情见站内`volatile关键字`一文。


