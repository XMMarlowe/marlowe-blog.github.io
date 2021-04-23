---
title: public、private、protected、default的区别
author: Marlowe
tags:
  - public
  - private
  - protected
  - default
categories: Java
abbrlink: 27501
date: 2020-04-20 13:49:35
---

<!--more-->

#### public
Java语言中访问限制最宽的修饰符，一般称之为“公共的”。被其修饰的类、属性以及方法不仅可以跨类访问，而且允许跨包（package）访问。


#### private
Java语言中对访问权限限制的最窄的修饰符，一般称之为“私有的”。被其修饰的类、属性以及方法只能被该类的对象访问，其子类不能访问，更不能允许跨包访问。

#### protected
介于public 和 private 之间的一种访问修饰符，一般称之为“保护形”。被其修饰的类、属性以及方法只能被类本身的方法及子类访问，即使子类在不同的包中也可以访问。


#### default

即不加任何访问修饰符，通常称为“默认访问模式”。该模式下，只允许在同一个包中进行访问。

![20210420165145](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210420165145.png)