---
title: Java中的异常体系
author: Marlowe
tags:
  - Java
  - 异常
categories: Java
abbrlink: 53205
date: 2021-03-09 15:58:09
---

<!--more-->

* 所有异常类都是Throwable的子类
* 异常可分为Error(错误)和Exception(异常)两类
* Exception又可分为RuntimeException(运行时异常)和非运行时异常两类
* Error是程序无法处理的错误，一旦出现这个错误，则程序被迫停止运行。
* Exception不会导致程序停止，分为`RuntimeException`运行时异常和`CheckedException`检查异常。
* `RuntimeException`常常发生在程序运行过程中，会导致程序**当前线程**执行失败。`CheckedException`常常发生在程序编译过程中，会导致程序编译不通过。

![20210309155959](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210309155959.png)