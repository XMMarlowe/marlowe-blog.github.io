---
title: CPU占用过高定位分析思路
author: Marlowe
tags: CPU
categories: 操作系统
abbrlink: 47228
date: 2021-08-17 21:59:34
---
CPU占用过高分析思路，以及解决方案。
<!--more-->

### 思路

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

### 解决方案

#### 1. 先用top命令找出CPU占比最高的

![20210828095105](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828095105.png)

#### 2. ps -ef或者jps进一步定位，得知是一个怎么样的一个后台程序作搞屎棍

**ps -ef具体什么意思：**

* -e和-A的意思是一样的，即显示有关其他用户进程的信息，包括那些没有控制终端的进程。
* -f显示用户id，进程id，父进程id，最近CPU使用情况，进程开始时间等等。

![20210828095534](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828095534.png)

#### 3. 定位到具体线程或者代码

* ps -mp 进程 -o THREAD,tid,time
  * -m 显示所有的线程
  * -p pid进程使用cpu的时间
  * -o 该参数后是用户自定义格式

![20210828095951](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828095951.png)

#### 4. 将线程ID转为16进制格式（英文小写格式）

命令`printf %x 3929` 将3929转换为十六进制(f59)

上一个步骤我们找到了这个线程的ID为 3929 但是这是十进制的，所以我们要转化为16进制：为f59。

#### 5. jstack 进程ID | grep tid（16进制线程ID小写英文）-A60
`-A60` 显示前60行信息

比如：`jstack 3929 | grep f59 -A60`

#### 6. 最后，可以直接定位出哪一行有问题

![20210828101304](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828101304.png)