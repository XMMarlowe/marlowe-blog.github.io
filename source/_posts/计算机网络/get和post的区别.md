---
title: get和post的区别
author: Marlowe
date: 2021-04-10 10:42:32
tags: 
  - get
  - post
categories: 计算机网络
---
<!--more-->

### 功能不同

1. get是从服务器上获取数据。

2. post是向服务器传送数据。 


### 过程不同

1. get是把参数数据队列加到提交表单的ACTION属性所指的URL中，值和表单内各个字段一一对应，在URL中可以看到。

2. post是通过HTTP post机制，将表单内各个字段与其内容放置在HTML HEADER内一起传送到ACTION属性所指的URL地址。用户看不到这个过程。 

### 获取值不同

1. 对于get方式，服务器端用Request.QueryString获取变量的值。

2. 对于post方式，服务器端用Request.Form获取提交的数据。 

### 传送数据量不同
1. get传送的数据量较小，不能大于2KB。

2. post传送的数据量较大，一般被默认为不受限制。但理论上，IIS4中最大量为80KB，IIS5中为100KB。 

### 安全性不同
1. get安全性非常低。

2. post安全性较高。 

如果没有加密，他们安全级别都是一样的，随便一个监听器都可以把所有的数据监听到。