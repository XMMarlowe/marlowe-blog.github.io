---
title: 常见的IO模型有哪些？Java中的BIO，NIO，AIO的区别
author: Marlowe
tags: I/O模型
categories: Java
abbrlink: 28269
date: 2020-03-15 14:22:22
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

##### Channel

Java NIO中的所有I/O操作都基于Channel对象，就像流操作都要基于Stream对象一样，因此很有必要先了解Channel是什么。以下内容摘自JDK 1.8的文档
> A channel represents an open connection to an entity such as a hardware device, a file, a network socket, or a program component that is capable of performing one or more distinct I/O operations, for example reading or writing.

从上述内容可知，一个Channel（通道）代表和某一实体的连接，这个实体可以是文件、网络套接字等。也就是说，通道是Java NIO提供的一座桥梁，用于我们的程序和操作系统底层I/O服务进行交互。

通道是一种很基本很抽象的描述，和不同的I/O服务交互，执行不同的I/O操作，实现不一样，因此具体的有FileChannel、SocketChannel等。

通道使用起来跟Stream比较像，可以读取数据到Buffer中，也可以把Buffer中的数据写入通道。

![20210503161918](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210503161918.png)

当然，也有区别，主要体现在如下两点：

* 一个通道，既可以读又可以写，而一个Stream是单向的（所以分 InputStream 和 OutputStream）
* 通道有非阻塞I/O模式

**实现**
Java NIO中最常用的通道实现是如下几个，可以看出跟传统的 I/O 操作类是一一对应的。

* FileChannel：读写文件
* DatagramChannel: UDP协议网络通信
* SocketChannel：TCP协议网络通信
* ServerSocketChannel：监听TCP连接


##### Buffer

NIO中所使用的缓冲区不是一个简单的byte数组，而是封装过的Buffer类，通过它提供的API，我们可以灵活的操纵数据，下面细细道来。

与Java基本类型相对应，NIO提供了多种 Buffer 类型，如ByteBuffer、CharBuffer、IntBuffer等，区别就是读写缓冲区时的单位长度不一样（以对应类型的变量为单位进行读写）。

Buffer中有3个很重要的变量，它们是理解Buffer工作机制的关键，分别是:

* capacity （总容量）
* position （指针当前位置）
* limit （读/写边界位置）

Buffer的工作方式跟C语言里的字符数组非常的像，类比一下，capacity就是数组的总长度，position就是我们读/写字符的下标变量，limit就是结束符的位置。Buffer初始时3个变量的情况如下图:

![20210503162055](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210503162055.png)

在对Buffer进行读/写的过程中，position会往后移动，而 limit 就是 position 移动的边界。由此不难想象，在对Buffer进行写入操作时，limit应当设置为capacity的大小，而对Buffer进行读取操作时，limit应当设置为数据的实际结束位置。（注意：将Buffer数据 **写入** 通道是Buffer **读取** 操作，从通道 **读取** 数据到Buffer是Buffer **写入** 操作）

在对Buffer进行读/写操作前，我们可以调用Buffer类提供的一些辅助方法来正确设置 position 和 limit 的值，主要有如下几个:
* flip(): 设置 limit 为 position 的值，然后 position 置为0。对Buffer进行读取操作前调用。
* rewind(): 仅仅将 position 置0。一般是在重新读取Buffer数据前调用，比如要读取同一个Buffer的数据写入多个通道时会用到。
* clear(): 回到初始状态，即 limit 等于 capacity，position 置0。重新对Buffer进行写入操作前调用。
* compact(): 将未读取完的数据（position 与 limit 之间的数据）移动到缓冲区开头，并将 position 设置为这段数据末尾的下一个位置。其实就等价于重新向缓冲区中写入了这么一段数据。

##### Selector
**简介**

Selector（选择器）是一个特殊的组件，用于采集各个通道的状态（或者说事件）。我们先将通道注册到选择器，并设置好关心的事件，然后就可以通过调用select()方法，静静地等待事件发生。

通道有如下4个事件可供我们监听：

* Accept：有可以接受的连接
* Connect：连接成功
* Read：有数据可读
* Write：可以写入数据了

**为什么要用Selector**

前文说了，如果用阻塞I/O，需要多线程（浪费内存），如果用非阻塞I/O，需要不断重试（耗费CPU）。Selector的出现解决了这尴尬的问题，非阻塞模式下，通过Selector，我们的线程只为已就绪的通道工作，不用盲目的重试了。比如，当所有通道都没有数据到达时，也就没有Read事件发生，我们的线程会在select()方法处被挂起，从而让出了CPU资源。

##### 三大组件总结

* channel类似于一流。 每个channel对应一 个buffer缓冲区。 channel会注册到selector。
* select会根据channel上发生的读写事件，将请求交由某个空闲的线程处理。selector对应一 个或者多个线程。
* Buffer和Channel都是可读可写的。


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




