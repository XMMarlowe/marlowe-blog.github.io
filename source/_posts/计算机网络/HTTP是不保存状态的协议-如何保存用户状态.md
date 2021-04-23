---
title: 'HTTP是不保存状态的协议,如何保存用户状态?'
author: Marlowe
tags: HTTP
categories: 计算机网络
abbrlink: 61490
date: 2021-02-09 22:42:30
---

<!--more-->

HTTP 是一种不保存状态，即无状态（stateless）协议。也就是说 HTTP 协议自身不对请求和响应之间的通信状态进行保存。那么我们保存用户状态呢？Session 机制的存在就是为了解决这个问题，Session 的主要作用就是通过服务端记录用户的状态。典型的场景是购物车，当你要添加商品到购物车的时候，系统不知道是哪个用户操作的，因为 HTTP 协议是无状态的。服务端给特定的用户创建特定的 Session 之后就可以标识这个用户并且跟踪这个用户了（一般情况下，服务器会在一定时间内保存这个 Session，过了时间限制，就会销毁这个Session）。

在服务端保存 Session 的方法很多，最常用的就是内存和数据库(比如是使用内存数据库redis保存)。既然 Session 存放在服务器端，那么我们如何实现 Session 跟踪呢？大部分情况下，我们都是通过在 Cookie 中附加一个 Session ID 来方式来跟踪。

**Cookie 被禁用怎么办?**

最常用的就是利用 URL 重写把 Session ID 直接附加在URL路径的后面。

<center>

![HTTP无状态协议](https://my-blog-to-use.oss-cn-beijing.aliyuncs.com/2019-6/HTTP%E6%98%AF%E6%97%A0%E7%8A%B6%E6%80%81%E7%9A%84.png)
</center>

