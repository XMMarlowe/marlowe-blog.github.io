---
title: try-catch与throw的区别
author: Marlowe
tags: 异常
categories: Java
abbrlink: 10413
date: 2021-08-19 22:21:34
---

简述try-catch与throw的区别。

<!--more-->

在 java 中，捕获处理一般有2种方式，throws 和 try-catch。

区别在于：

1. 要么声明异常，也就是在方法名后面加上throws exception_name,…, 方法本身只是抛出异常，由函数调用者来捕获异常。 若产生异常，异常会沿着调用栈下移，一直找到与之匹配的处理方法，若到达调用栈底仍未找到，程序终止；
2. 要么捕获异常。通过try-catch方法，catch子句中放置处理异常的语句；
3. 对于会觉得会有异常抛出的程序块，用try{}包住，然后用catch来抓住这个异常，在catch中对异常做处理， 在try中如果有异常的话，程序会转到catch而不会中断，通常这两个是配合使用的,如果你不想因为程序有错，而抛出一大堆异常的话，你就把该程序try起来，try和catch只能获取程序运行时引发的异常，而throw语句可以引发明确的异常，程序到了throw语句这后就立即停止，不会执行后面的程序；

部分常见异常如下：

* 算术异常类：ArithmeticExecption
* 空指针异常类：NullPointerException
* 类型强制转换异常：ClassCastException
* 数组负下标异常：NegativeArrayException
* 数组下标越界异常：ArrayIndexOutOfBoundsException
* 违背安全原则异常：SecturityException
* 文件已结束异常：EOFException
* 文件未找到异常：FileNotFoundException
* 字符串转换为数字异常：NumberFormatException
* 操作数据库异常：SQLException
* 输入输出异常：IOException
* 方法未找到异常：NoSuchMethodException
