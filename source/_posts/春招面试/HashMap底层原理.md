---
title: HashMap底层原理
author: Marlowe
tags: HashMap
categories: 春招面试
abbrlink: 10092
date: 2021-03-15 14:23:01
---
<!--more-->

### JDK1.7
数据结构则是采用的位桶和链表相结合的形式完成了，即拉链法。具体如下图所示：
![20210315223328](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210315223328.png)

HashMap里面存储的是静态内部类Entry的对象，这个对象其实也是一个key-value的结构。





