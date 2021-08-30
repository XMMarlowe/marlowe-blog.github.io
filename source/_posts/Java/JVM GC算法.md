---
title: JVM GC算法
author: Marlowe
tags:
  - JVM
  - 垃圾回收
categories: Java
abbrlink: 50446
date: 2020-04-09 15:13:36
---

<!--more-->

### 两个概念：

**新生代：** 存放生命周期较短的对象的区域。
**老年代：** 存放生命周期较长的对象的区域。

**相同点：** 都在Java堆上。

### 1. 标记-清除算法
**执行步骤：**

* 标记：遍历内存区域，对需要回收的对象打上标记。
* 清除：再次遍历内存，对已经标记过的内存进行回收。

**图解：**
<center>

![回收前](https://img-blog.csdnimg.cn/20190505183834528.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzIxMzUxNw==,size_16,color_FFFFFF,t_70)
</center>

<center>

![回收后](https://img-blog.csdnimg.cn/20190505183935598.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzIxMzUxNw==,size_16,color_FFFFFF,t_70)
</center>

**缺点：**

* 效率问题；遍历了两次内存空间（第一次标记，第二次清除）。
* 空间问题：容易产生大量内存碎片，当再需要一块比较大的内存时，无法找到一块满足要求的，因而不得不再次出发GC。

### 2. 复制算法
将内存划分为等大的两块，每次只使用其中的一块。当一块用完了，触发GC时，将该块中存活的对象复制到另一块区域，然后一次性清理掉这块没有用的内存。下次触发GC时将那块中存活的的又复制到这块，然后抹掉那块，循环往复。

**图解**

<center>

![回收前](https://img-blog.csdnimg.cn/20190505185528553.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzIxMzUxNw==,size_16,color_FFFFFF,t_70)
</center>


<center>

![回收后](https://img-blog.csdnimg.cn/20190505185631986.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzIxMzUxNw==,size_16,color_FFFFFF,t_70)
</center>

**优点**

* 相对于标记–清理算法解决了内存的碎片化问题。
* 效率更高（清理内存时，记住首尾地址，一次性抹掉）。

**缺点：**

* 内存利用率不高，每次只能使用一半内存。

**改进**

研究表明，新生代中的对象大都是“朝生夕死”的，即生命周期非常短而且对象活得越久则越难被回收。在发生GC时，需要回收的对象特别多，存活的特别少，因此需要搬移到另一块内存的对象非常少，所以不需要1：1划分内存空间。而是将整个新生代按照8 ： 1 ： 1的比例划分为三块，最大的称为Eden（伊甸园）区，较小的两块分别称为To Survivor和From Survivor。

首次GC时，只需要将Eden存活的对象复制到To。然后将Eden区整体回收。再次GC时，将Eden和To存活的复制到From，循环往复这个过程。这样每次新生代中可用的内存就占整个新生代的90%，大大提高了内存利用率。

但不能保证每次存活的对象就永远少于新生代整体的10%，此时复制过去是存不下的，因此这里会用到另一块内存，称为老年代，进行分配担保，将对象存储到老年代。若还不够，就会抛出OOM。

老年代：存放新生代中经过多次回收仍然存活的对象（默认15次）。



### 3. 标记-整理算法

因为前面的复制算法当对象的存活率比较高时，这样一直复制过来，复制过去，没啥意义，且浪费时间。所以针对老年代提出了“标记整理”算法。


**执行步骤：**

* 标记：对需要回收的进行标记
* 整理：让存活的对象，向内存的一端移动，然后直接清理掉没有用的内存。

**图解：**

<center>

![回收前](https://img-blog.csdnimg.cn/20190505192310919.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzIxMzUxNw==,size_16,color_FFFFFF,t_70)
</center>

<center>

![回收后](https://img-blog.csdnimg.cn/20190505192333188.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl80MzIxMzUxNw==,size_16,color_FFFFFF,t_70)
</center>

### 4. 分代收集算法

当前大多商用虚拟机都采用这种分代收集算法，这个算法并没有新的内容，只是根据对象的存活的时间的长短，将内存分为了新生代和老年代，这样就可以针对不同的区域，采取对应的算法。如：

* 新生代，每次都有大量对象死亡，有老年代作为内存担保，采取复制算法。
* 老年代，对象存活时间长，采用标记整理，或者标记清理算法都可。

**为什么采用分代收集算法？**

这是基于两个共识

* 绝大多数对象都是朝生夕死的

* 熬过越多次垃圾收集过程的对象就越难以消亡


这两个分代假说共同奠定了多款常用的垃圾收集器的一致的**设计原则**:收集器应该将Java堆**划分出不同的区域，然后将回收对象依据其年龄(年龄即对象熬过垃圾收集过程的次数)分配到不同的区域之中存储**。显而易见，如果一个区域中**大多数对象都是朝生夕灭**，难以熬过垃圾收集过程的话，**那么把它们集中放在一起**，每次回收时**只关注如何保留少量存活而不是去标记那些大量将要被回收的对象**，就能以较低代价回收到大量的空间;如果**剩下的都是难以消亡的对象，那把它们集中放在一块**，虚拟机便可以**使用较低的频率来回收这个区域**，这就**同时兼顾了垃圾收集的时间开销和内存的空间有效利用**。

在Java堆划分出不同的区域之后，垃圾收集器才可以每次只回收其中某一个或者某些部分的区域 ——因而才有了“Minor GC”“Major GC”“Full GC”这样的回收类型的划分;也才能够针对不同的区域安 排与里面存储对象存亡特征相匹配的垃圾收集算法——因而发展出了“标记-复制算法”“标记-清除算 法”“标记-整理算法”等针对性的垃圾收集算法。这里笔者提前提及了一些新的名词，它们都是本章的 重要角色，稍后都会逐一登场，现在读者只需要知道，这一切的出现都始于分代收集理论。

                                                           


### MinorGC和Majaor/Full GC的区别

* MinorGC：发生在新生代的垃圾回收，因为新生代的特点，MinorGC非常频繁，且回收速度比较快，每次回收的量也很大。
* Majaor/Full GC：发生在老年代的垃圾回收，也称MajorGC，速度比较慢，相对于MinorGC慢10倍左右。进行一次FullGC通常会伴有多次多次MinorGC。


### 参考
[JVM垃圾回收算法](https://blog.csdn.net/weixin_43213517/article/details/89853530)

[java为什么要分代回收_JVM为什么要分代回收](https://blog.csdn.net/weixin_34597791/article/details/114809782)