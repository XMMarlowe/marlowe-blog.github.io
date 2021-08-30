---
title: Kafka高吞吐量的原因
author: Marlowe
tags: Kafka
categories: 中间件
abbrlink: 61806
date: 2021-08-27 18:35:17
---

简单介绍一下Kafka高吞吐量的原因。
<!--more-->

### 1、顺序读写

* kafka的消息是不断追加到文件中的，这个特性使kafka可以充分利用磁盘的顺序读写性能。
* 顺序读写不需要硬盘磁头的寻道时间，只需很少的扇区旋转时间，所以速度远快于随机读写。

### 2、零拷贝

在Linux kernel2.2 之后出现了一种叫做 **"零拷贝(zero-copy)"系统调用**机制，就是**跳过“用户缓冲区”的拷贝**，**建立一个磁盘空间和内存的直接映射，数据不再复制到“用户态缓冲区”**

常用模式：

![20210827183718](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210827183718.png)

kafka使用如下模式：

![20210827183737](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210827183737.png)

### 3、分区

kafka中的topic中的内容可以被分为多分partition存在,每个partition又分为多个段segment,所以每次操作都是针对一小部分做操作，很轻便，并且增加并行操作的能力。

![20210827183800](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210827183800.png)

### 4、批量发送

kafka允许进行批量发送消息，producter发送消息的时候，可以将消息缓存在本地,等到了固定条件发送到kafka

1. 等消息条数到固定条数
2. 一段时间发送一次

### 5、数据压缩

Kafka还支持对消息集合进行压缩，Producer可以通过GZIP或Snappy格式对消息集合进行压缩。

压缩的好处就是减少传输的数据量，减轻对网络传输的压力

* **批量发送和数据压缩一起使用效果最好**，单条做数据压缩的话，效果不明显


