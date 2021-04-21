---
title: Java并发之Unsafe类
author: Marlowe
tags: Unsafe
categories: 并发
abbrlink: 10892
date: 2021-04-21 22:07:17
---

<!--more-->

Unsafe是位于sun.misc包下的一个类，主要提供一些用于执行低级别、不安全操作的方法，如直接访问系统内存资源、自主管理内存资源等，这些方法在提升Java运行效率、增强Java语言底层资源操作能力方面起到了很大的作用。但由于Unsafe类使Java语言拥有了类似C语言指针一样操作内存空间的能力，这无疑也增加了程序发生相关指针问题的风险。在程序中过度、不正确使用Unsafe类会使得程序出错的概率变大，使得Java这种安全的语言变得不再“安全”，因此对Unsafe的使用一定要慎重。

这个类尽管里面的方法都是 public 的，但是并没有办法使用它们，JDK API 文档也没有提供任何关于这个类的方法的解释。总而言之，对于 Unsafe 类的使用都是受限制的，只有授信的代码才能获得该类的实例，当然 JDK 库里面的类是可以随意使用的。

![20210421220925](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210421220925.png)

### 参考
[Java并发之Unsafe类](https://blog.unclezs.com/Java/%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B/Java%E5%B9%B6%E5%8F%91%E4%B9%8BUnsafe%E7%B1%BB.html)