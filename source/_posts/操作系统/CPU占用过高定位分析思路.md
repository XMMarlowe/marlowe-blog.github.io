---
title: CPU占用过高定位分析思路
author: Marlowe
tags: CPU
categories: 操作系统
abbrlink: 47228
date: 2021-08-17 21:59:34
---
CPU占用过高分析思路
<!--more-->

* 1.先用top命令找出CPU占比最高的
* 2.`ps -ef`或者`jps`进一步定位，得知是一个怎么样的一个后台程序（ps -ef|grep java|grep -v grep）
* 3.定位到具体线程或者代码
  * 3.1 ps -mp 进程编号 -o THREAD,tid,time
           -m显示所有的线程
           -p pid进程使用cpu的时间
           -o 该参数后是用户自定义格式
* 4.将需要的线程ID转换为16进制格式（英文小写格式）
  * 4.1、printf "%x\n" 有问题的线程ID
* 5.jstack 进程id | grep tid(16进制线程ID小写英文) -A60
       前60行