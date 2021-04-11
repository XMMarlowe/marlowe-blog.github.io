---
title: 常见的IO模型有哪些？Java中的BIO，NIO，AIO的区别
author: Marlowe
tags: I/O模型
categories: Java
abbrlink: 28269
date: 2021-03-15 14:22:22
---
从应用程序的视角来看的话，我们的应用程序对操作系统的内核发起 IO 调用（系统调用），操作系统负责的内核执行具体的 IO 操作。也就是说，我们的应用程序实际上只是发起了 IO 操作的调用而已，具体 IO 的执行是由操作系统的内核来完成的。
<!--more-->

### 简介

当应用程序发起I/O调用后，会经历两个步骤：
* 内核等待 I/O 设备准备好数据
* 内核将数据从内核空间拷贝到用户空间。

UNIX系统5种I/O模型：
* 同步阻塞 I/O
* 同步非阻塞 I/O
* I/O 多路复用
* 信号驱动 I/O 
* 异步 I/O

### Java中三种常见的I/O模型
#### BIO (Blocking I/O)
BIO 属于同步阻塞 IO 模型 。

同步阻塞 IO 模型中，应用程序发起 read 调用后，会一直阻塞，直到在内核把数据拷贝到用户空间。
![20210315205847](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210315205847.png)

在客户端连接数量不高的情况下，是没问题的。但是，当面对十万甚至百万级连接的时候，传统的 BIO 模型是无能为力的。因此，我们需要一种更高效的 I/O 处理模型来应对更高的并发量。

#### NIO (Non-blocking/New I/O)
Java 中的 NIO 于 Java 1.4 中引入，对应 java.nio 包，提供了 Channel , Selector，Buffer 等抽象。NIO 中的 N 可以理解为 Non-blocking，不单纯是 New。它支持面向缓冲的，基于通道的 I/O 操作方法。 对于高负载、高并发的（网络）应用，应使用 NIO 。

Java 中的 NIO 可以看作是 I/O 多路复用模型。也有很多人认为，Java 中的 NIO 属于同步非阻塞 IO 模型。
![20210315210124](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210315210124.png)

同步非阻塞 IO 模型中，应用程序会一直发起 read 调用，等待数据从内核空间拷贝到用户空间的这段时间里，线程依然是阻塞的，直到在内核把数据拷贝到用户空间。

相比于同步阻塞 IO 模型，同步非阻塞 IO 模型确实有了很大改进。通过轮询操作，避免了一直阻塞。

但是，这种 IO 模型同样存在问题：**应用程序不断进行 I/O 系统调用轮询数据是否已经准备好的过程是十分消耗 CPU 资源的。**

这个时候，**I/O 多路复用模型** 就上场了。
![20210315210244](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210315210244.png)

IO 多路复用模型中，线程首先发起 select 调用，询问内核数据是否准备就绪，等内核把数据准备好了，用户线程再发起 read 调用。read 调用的过程（数据从内核空间->用户空间）还是阻塞的。

IO 多路复用模型，通过减少无效的系统调用，减少了对 CPU 资源的消耗。

Java 中的 NIO ，有一个非常重要的选择器 ( Selector ) 的概念，也可以被称为 多路复用器。通过它，只需要一个线程便可以管理多个客户端连接。当客户端数据到了之后，才会为其服务。

![20210315210543](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210315210543.png)

#### AIO (Asynchronous I/O)

AIO 也就是 NIO 2。Java 7 中引入了 NIO 的改进版 NIO 2,它是异步 IO 模型。

异步 IO 是基于事件和回调机制实现的，也就是应用操作之后会直接返回，不会堵塞在那里，当后台处理完成，操作系统会通知相应的线程进行后续的操作。
![20210315210610](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210315210610.png)

目前来说 AIO 的应用还不是很广泛。Netty 之前也尝试使用过 AIO，不过又放弃了。这是因为，Netty 使用了 AIO 之后，在 Linux 系统上的性能并没有多少提升。

最后，来一张图，简单总结一下 Java 中的 BIO、NIO、AIO。
![20210315210710](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210315210710.png)





### 参考
[京东数科二面:常见的10模型有哪些? Java中的BIO、NIO、 AIO有啥区别?](https://www.cnblogs.com/javaguide/p/io.html)




