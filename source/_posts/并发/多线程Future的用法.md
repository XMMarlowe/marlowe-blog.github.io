---
title: 多线程Future的用法
author: Marlowe
abbrlink: 23984
date: 2021-04-17 16:49:20
tags: Future
categories: 并发
---

<!--more-->

在并发编程时，一般使用runnable，然后扔给线程池完事，这种情况下不需要线程的结果。

所以run的返回值是void类型。

如果是一个多线程协作程序，比如斐波那契数列，1，1，2，3，5，8…使用多线程来计算。
但后者需要前者的结果，就需要用callable接口了。
callable用法和runnable一样，只不过调用的是call方法，该方法有一个泛型返回值类型，你可以任意指定。

线程是属于异步计算模型，所以你不可能直接从别的线程中得到函数返回值。
这时候，Future就出场了。Futrue可以监视目标线程调用call的情况，当你调用Future的get()方法以获得结果时，当前线程就开始阻塞，直接call方法结束返回结果。

下面三段简单的代码可以很简明的揭示这个意思：

runnable接口实现的没有返回值的并发编程。

![20210417165022](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210417165022.png)

callable实现的存在返回值的并发编程。（call的返回值String受泛型的影响）


![20210417165040](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210417165040.png)

同样是callable，使用Future获取返回值。

![20210417165057](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210417165057.png)


### 参考
[多线程Future的用法](https://blog.csdn.net/u010916338/article/details/80980695)

