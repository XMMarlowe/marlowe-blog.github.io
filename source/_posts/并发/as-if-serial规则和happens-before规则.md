---
title: as-if-serial规则和happens-before规则
author: Marlowe
tags:
  - as-if-serial
  - happens-before
categories: 并发
abbrlink: 39231
date: 2021-04-28 20:41:41
---
我们知道为了提高并行度，优化程序性能，编译器和处理器会对代码进行指令重排序。但为了不改变程序的执行结果，尽可能地提高程序执行的并行度，我们需要了解as-if-serial规则和happens-before规则。
<!--more-->

### as-if-serial规则

as-if-serial语义的意思指：**不管怎么重排序（编译器和处理器为了提高并行度），（单线程）程序的执行结果不能被改变。** 编译器、runtime和处理器都必须遵守as-if-serial语义。
为了遵守as-if-serial语义，**编译器和处理器不会对存在数据依赖关系的操作做重排序，因为这种重排序会改变执行结果。** 但是，如果操作之间不存在数据依赖关系，这些操作可能被编译器和处理器重排序。示例代码如下：

```java
int a=1;
int b=2;
int c=a+b;
```
a和c之间存在数据依赖关系，同时b和c之间也存在数据依赖关系。因此在最终执行的指令序列中，c不能被重排序到A和B的前面（c排到a和b的前面，程序的结果将会被改变）。但a和b之间没有数据依赖关系，编译器和处理器可以重排序a和b之间的执行顺序。



### happens-before（先行发生）规则

#### 定义

JMM可以通过happens-before关系向程序员提供跨线程的内存可见性保证（如果A线程的写操作a与B线程的读操作b之间存在happens-before关系，尽管a操作和b操作在不同的线程中执行，但JMM向程序员保证a操作将对b操作可见）。具体的定义为：

1. **如果一个操作happens-before另一个操作，那么第一个操作的执行结果将对第二个操作可见，而且第一个操作的执行顺序排在第二个操作之前。**
2. 两个操作之间存在happens-before关系，并不意味着Java平台的具体实现必须要按照happens-before关系指定的顺序来执行。**如果重排序之后的执行结果，与按happens-before关系来执行的结果一致，那么JMM允许这种重排序。**


#### 八大规则

|规则|	解释|
|:----:|:----:|:----:|
|程序次序规则|	在一个线程内，代码按照书写的控制流顺序执行|
|管程锁定规则|	一个 unlock 操作先行发生于后面对同一个锁的 lock 操作|
|volatile 变量规则|	volatile 变量的写操作先行发生于后面对这个变量的读操作|
|线程启动规则|	Thread 对象的 start() 方法先行发生于此线程的每一个动作|
|线程终止规则|	线程中所有的操作都先行发生于对此线程的终止检测(通过 Thread.join() 方法结束、 Thread.isAlive() 的返回值检测)|
|线程中断规则|	对线程 interrupt() 方法调用优先发生于被中断线程的代码检测到中断事件的发生 (通过 Thread.interrupted() 方法检测)|
|对象终结规则|	一个对象的初始化完成(构造函数执行结束)先行发生于它的 finalize() 方法的开始|
|传递性|	如果操作 A 先于 操作 B 发生，操作 B 先于 操作 C 发生，那么操作 A 先于 操作 C|


### as-if-serial规则和happens-before规则的区别

1. as-if-serial语义保证单线程内程序的执行结果不被改变，happens-before关系保证**正确同步的多线程**程序的执行结果不被改变。
2. as-if-serial语义给编写单线程程序的程序员创造了一个幻觉：单线程程序是按程序的顺序来执行的。happens-before关系给编写正确同步的多线程程序的程序员创造了一个幻觉：正确同步的多线程程序是按happens-before指定的顺序来执行的。
3. as-if-serial语义和happens-before这么做的目的，都是为了在不改变程序执行结果的前提下，尽可能地提高程序执行的并行度。


### 参考
[Java并发理论（二）：as-if-serial规则和happens-before规则详解](https://blog.csdn.net/Carson_Chu/article/details/106417831)

