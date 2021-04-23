---
title: Java中的集合类及关系图
author: Marlowe
tags:
  - 集合类
  - 类图
categories: Java
abbrlink: 25436
date: 2020-04-11 10:07:50
---

<!--more-->

<center>

![Java中的集合类及关系图](https://img2018.cnblogs.com/blog/1550523/201909/1550523-20190906160542354-841416466.png)
</center>


List 和 Set 继承自 Collection 接口。

Set 无序不允许元素重复。HashSet 和 TreeSet 是两个主要的实现类。

List 有序且允许元素重复。ArrayList、LinkedList 和 Vector 是三个主要的实现 类。

Map 也属于集合系统，但和 Collection 接口没关系。Map 是 key 对 value 的映 射集合，其中 key 列就是一个集合。key 不能重复，但是 value 可以重复。 HashMap、TreeMap 和 Hashtable 是三个主要的实现类。 SortedSet 和 SortedMap 接口对元素按指定规则排序，SortedMap 是对 key 列 进行排序。