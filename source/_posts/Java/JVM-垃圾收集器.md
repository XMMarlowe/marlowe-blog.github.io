---
title: JVM 垃圾收集器
author: Marlowe
tags:
  - JVM
  - GC
categories: Java
abbrlink: 180
date: 2020-04-10 22:39:51
---

<!--more-->


### 不同的垃圾收集器

下图是HotSpot虚拟机1.6版Undate 22d的所有收集器：
<center>

![垃圾收集器](https://img-blog.csdnimg.cn/20190102223741403.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3dlaXhpbl8zODU2OTQ5OQ==,size_16,color_FFFFFF,t_70)
JVM 垃圾收集器
</center>

**注：** 如果两个收集器之间存在连线，就说明它们可以搭配使用。


### 七种垃圾收集器:

#### 1. Serial（串行GC）-复制
Serial是一个新生代收集器，曾经是JDK1.3.1之前新生代唯一的垃圾收集器。采用复制算法。

Serial是一个单线程收集器，会使用一个CPU、一条线程去完成垃圾回收，并且在进行垃圾回收的时候必须暂停其他所有的工作线程，直到垃圾收集结束（这被称为“Stop The World”）。

Serial收集器仍然是虚拟机运行在Client模式下的默认新生代收集器。它的优点是：简单而高效（与其他收集器的单线程比）。对于限定单个CPU的环境来说，Seria收集器由于没有线程交互的开销，专心做垃圾收集自然可以获得最高的单线程收集效率。

Serial/Serial Old收集器运行示意图如下：

![Serial收集器](https://gitee.com/chenssy/blog-home/raw/master/image/series-images/javaCore/jvm/2019120001694_7.png)

#### 2. ParNew（并行GC）复制
ParNew收集器也是一个新生代收集器，是Serial收集器的多线程版本。也采用复制算法。除了使用多条线程进行垃圾回收之外，其他行为与Serial收集器一样。

ParNew收集器在单CPU的环境中效果不会比Serial收集器更好，甚至由于存在线程交互的开销，性能可能会更差。

ParNew收集器在多CPU环境下是更高效的，它默认开启的收集线程数与CPU的数量相同。

ParNew/Serial Old收集器运行示意图如下：

![ParNew](https://gitee.com/chenssy/blog-home/raw/master/image/series-images/javaCore/jvm/2019120001694_8.png)

#### 3. Parallel Scavenge（并行回收GC）标记-复制
Parallel Scavenge收集器也是一个新生代收集器。也是用复制算法，同时也是并行的多线程收集器。

Parallel Scavenge收集器的特点是关注点与其他收集器不同，Parallel Scavenge的关注点是“吞吐量（Throughput）”，吞吐量就是CPU用于运行用户代码的时间与CPU总消耗时间的比值，即吞吐量=运行用户代码时间/(运行用户代码时间+垃圾收集时间)。其他收集器关注的是“垃圾收集时的停顿时间”。

停顿时间越短就越适合需要与用户交互的程序，良好的响应速度能提升用户的体验； 而高吞吐量则可以最高效率地利用CPU时间，尽快地完成程序的运算任务，适合在后台运算不需要太多交互的任务。

Parallel Scavenge收集器可以通过参数控制最大垃圾收集停顿时间和吞吐量大小。注意：GC停顿时间缩短是以牺牲吞吐量和新生代空间来换取的。因为：系统把新生代空间调小一些，收集的速度就快一些，也就导致垃圾收集要更频繁（空间不够用），比如原来10秒收集一次，一次停顿100毫秒，现在5秒收集一次，每次停顿70毫秒，停顿时间的确在下降，但吞吐量也降下来了。

此外Parallel Scavenge收集器可通过参数开关控制GC自动动态调整参数来提供最合适的停顿时间或最大吞吐量，这种调节方式称为GC自适应的调节策略（GC Ergonomics）。

自适应调节策略也是Parallel Scavenge收集器与ParNew收集器的一个重要区别。

**注：** Parallel Scavenge收集器无法与CMS收集器配合使用。（原因是Parallel Scavenge收集器及G1收集器都没有使用传统的GC收集器代码框架，而是另外独立实现的）

#### 4. Serial Old（MSC）（串行GC）标记-整理

Serial Old是Serial收集器的老年代版本。同样是一个单线程收集器，使用“标记-整理”算法。这个收集器的主要意义是被Client模式下的虚拟机使用。在Server模式下，它主要还有两大用途：一个是在JDK1.5及以前的版本中与Parallel Scavenge收集器搭配使用，另外一个就是作为CMS收集器的后备预案，在并发收集发生Concurrent Mode Failure的时候使用。

#### 5. CMS(Concurrent Mark Sweep)（并发GC）标记-清除

CMS(Concurrent Mark Sweep)收集器是一种以获取最短回收停顿时间为目标的收集器。最符合重视服务响应速度。希望系统停顿时间最短的应用。

该收集器是基于“标记-清除”算法实现的。过程分为4个步骤：

初始标记（CMS initial mark）、并发标记（CMS concurrent mark）、重新标记（CMS remark）、并发清除（CMS concurrent sweep）.

其中初始标记、重新标记这两个步骤仍然需要“Stop The World”。**初始标记**仅仅只是标记一下GC Roots能直接关联到的对象，**速度很快**，**并发标记**阶段就是进行GC Roots Tracing的过程，而**重新标记**阶段则是为了修正并发标记期间，因用户程序继续运行而导致标记产生变动的那一部分对象的标记记录，这个阶段的停顿时间一般会比初始标记阶段稍长一些，但远比并发标记的时间短。

**核心思想，就是将STW打散，让-部分GC线程与用户线程并发执行。整个GC过程分为四个阶段**

1. 初始标记阶段: STW只标记出根对象直接引用的对象。
2. 并发标记:继续标记其他对象，与应用程序是并发执行。
3. 重新标记: STW 对并发执行阶段的对象进行重新标记。
4. 并发清除:并行。将产生的垃圾清除。清除过程中，应用程序又会不断的产生新的垃圾，叫做浮动垃圾。这些垃圾就要留到下一次GC过程中清除。



Concurrent Mark Sweep收集器运行示意图如下：
![CMS](https://gitee.com/chenssy/blog-home/raw/master/image/series-images/javaCore/jvm/2019120001694_10.png)
#### 6. Parallel Old（并行GC）标记-整理
Parallel Old是Parallel Scavenge收集器的老年代版本。使用多线程和“标记-整理”算法。单线程的老年代Serial Old收集器在服务端性能比较差，即使新生代使用了Parallel Scavenge收集器也未必能在整体应用上获得吞吐量最大化的效果。

在注重吞吐量及CPU资源敏感的场合，都可以优先考虑Parallel Scavenge收集器加上Parallel Old收集器组合使用。

Parallel Scavenge/ Parallel Old收集器运行示意图如下：
![Parallel Old](https://gitee.com/chenssy/blog-home/raw/master/image/series-images/javaCore/jvm/2019120001694_9.png)

#### 7. G1(Garbage First)（JDK1.7update14才可以正式商用）
G1收集器是一款面向服务端应用的收集器，它能充分利用多CPU、多核环境。因此它是一款并行与并发收集器，并且它能建立可预测的停顿时间模型。

在G1中分代概念仍然保留。虽然G1不需要和其他收集器配合，可以独立管理GC堆，但它能够采用不同的方式去处理新创建的对象和已经存活了一段时间、熬过多次GC的旧对象，以获取更好的收集效果。

**G1将内存分成多个大小相等的独立区域，虽然还保留着新生代和老年代的概念，但是新生代和老年代不再是物理隔离的，它们都是一部分Region(不需要连续)的集合。**

**GC分四个阶段**

1. 初始标记标记出GCRoot直接引用的对象。STW
2. 标记Region,通过RSet标记出上-个阶段标记的Region引用到的Old区Region。
3. 并发标记阶段:跟CMS的步骤是差不多的。只是遍历的范围不再是整个Old区，而只需要遍历第二步标记出来的Region。
4. 重新标记:跟CMS中的重 新标记过程是差不多的。
5. 垃圾清理:与CMS不同的是，G1可以采用拷贝算法，直接将整个Region中的对象拷贝到另一个Region。而这个阶段，G1只选择垃圾较多的Region来清理，并不是完全清理。

**G1收集器的优点：**

**1）空间整合：**

    G1从整体看是基于标记-整理算法实现的收集器，从局部看是基于复制算法。这两种算法都意味着G1运行期间不会产生大量内存空间碎片。

**2）可预测的停顿：**

    降低停顿时间是G1和CMS共同关注的，但G1能建立可预测的停顿时间模型，让使用者明确指定在一个长度为M毫秒的时间片段内，GC的时间不得超过N毫秒。

**3）有计划的垃圾回收：**

    G1可以有计划的在Java堆中进行全区域的垃圾收集。G1跟踪各个Region里面的垃圾堆的价值大小(回收所获得的空间大小，以及回收所需要的时间)，在后台维护一个优先列表，每次根据允许的收集时间，优先回收价值最大的Region。这就是Garbage-First的由来。


**说明：**
1. 1~3用于年轻代垃圾回收：年轻代的垃圾回收称为minor GC
2. 4~6用于年老代垃圾回收（当然也可以用于方法区的回收）：年老代的垃圾回收称为full GC
3. G1独立完成"分代垃圾回收"

**注意：** 并行与并发

1. 并行：多条垃圾回收线程同时操作
2. 并发：垃圾回收线程与用户线程一起操作

### 一些问题

#### 什么是STW？

STW: Stop-The-World。是在垃圾回收算法执行过程当中，需要将JVM内存冻结的一种状态。在STW状态下，JAVA的所有线程都是停止执行的-GC线程除外，native方法可以执行， 但是，不能与JVM交互。GC各种算法优化的重点，就是减少STW,同时这也是JVM调优的重点。

#### 什么是三色标记？

CMS的核心算法就是三色标记。

三色标记:是一种逻辑上的抽象。将每个内存对象分成三种颜色。
**黑色:** 表示自己和成员变量都已经标记完毕。
**灰色:** 自己标记完了，但是成员变量还没有完全标记完。
**白色:** 自己未标记完。

CMS通过增量标记increment update的方式来解决漏标的问题。

### 参考
[JVM几种垃圾回收器介绍](https://www.cnblogs.com/blythe/p/7488061.html)
[读《深入理解java虚拟机》（三）垃圾回收器](http://cmsblogs.com/?p=17120)