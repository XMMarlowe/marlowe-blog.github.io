---
title: Synchronized与ReentrantLock
author: Marlowe
tags:
  - Synchronized
  - ReentrantLock
categories: 并发
abbrlink: 20540
date: 2021-04-28 14:19:05
---
Java 里面，最基本的互斥同步手段就是 synchronized 关键字，这是一种块结构( Block Structured ）的同步语法。还有就是 Java 类库中新提供了 java. util.concurrent 包，其中的 java.util.concurrent.locks.Lock 接口便成了 Java 另一 全新的互斥 同步手段。
<!--more-->

### Synchronized
* 被 synchronized 修饰的同步块对同一条线程来说是可重人的 这意味着同一线程反复进入同步块也不会出现自己把自己锁死的情况。
* 被synchronized 修饰的同步块在持有锁的线程执行完毕并释放锁之前，会元条件地阻塞后面其他线程的进入 意味着无法像处理某些数据库中 的锁那样，强制已获取锁的线程释放锁；也无法强制正在等待锁的线程中断等待或超时退出。

#### 三种使⽤⽅式

1. **修饰实例⽅法:** 作⽤于当前对象实例加锁，进⼊同步代码前要获得当前对象实例的锁
2. **修饰静态⽅法:** 也就是给当前类加锁，会作⽤于类的所有对象实例，因为静态成员不属于任何⼀个实例对象，是类成员（ static 表明这是该类的⼀个静态资源，不管new了多少个对象，只有⼀份）。所以如果⼀个线程A调⽤⼀个实例对象的⾮静态 synchronized ⽅法，⽽线程B需要调⽤这个实例对象所属类的静态 synchronized ⽅法，是允许的，不会发⽣互斥现象，因为访问**静态synchronized ⽅法占⽤的锁是当前类的锁，⽽访问⾮静态 synchronized ⽅法占⽤的锁是当前实例对象锁。**
3. **修饰代码块：** 指定加锁对象，对给定对象加锁，进⼊同步代码库前要获得给定对象的锁。

**总结：** synchronized 关键字加到 static 静态⽅法和 synchronized(class)代码块上都是是给 Class类上锁。synchronized 关键字加到实例⽅法上是给对象实例上锁。尽量不要使⽤synchronized(String a) 因为JVM中，字符串常量池具有缓存功能！

#### 底层实现

**作用于对象的时候**

当synchronized作用于对象时候（即代码块方式），JVM会使用字节码monitorenter，monitorexit来进行同步代码块区分:
```java
 4: monitorenter
 5: getstatic     #3                  // Field java/lang/System.out:Ljava/io/PrintStream;
 8: sipush        666
11: invokevirtual #4                  // Method java/io/PrintStream.println:(I)V
14: aload_1
15: monitorexit
```
在执行 monitorenter 指令时，首先要去尝试获取对象的锁 如果这个对象没被锁定，或者当前线程已经持有了那个对象的锁，就把锁的计数器的值增加一，而在执行 monitorexit 指令时会将锁计数器的值减一，一旦计数器的值为零，锁随即就被释放了 如果获取对象锁失败，那当前线程就应当被阻塞等待，直到请求锁定的对象被持有它的线程释放为止。

#### 锁的优化

Java HotSpot 虚拟机中，每个对象都有对象头（包括 class 指针和 Mark Word）。Mark Word 平时存储这个对象的 哈希码 、 分代年龄 ，当加锁时，这些信息就根据情况被替换为 标记位 、 线程锁记录指 针 、 重量级锁指针 、 线程ID 等内容。

高效并发是从 JDK 升级到 JDK 后一项重要的改进项， Hotspot 虚拟机开发团队在这个版本上花费了大 的资源去实现各种锁优化技术，如适应性自旋（ Adaptive Spinning锁消除（ Lock Elimination ）、锁膨胀（ Lock Coarsening 、轻量级锁（ Lightweight Locking）、偏向锁（ Biased Locking ）等，这些技术都是为了在线程之间更高效地共享数据及解决竞争问题，从而提高程序的执行效率。

* 对象头 Mark Word
![20210428142749](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210428142749.png)
* 锁之间的转换
![20210428142829](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210428142829.png)

##### 偏向锁

轻量级锁在无竞争的情况下使用 CAS 操作去代替使用互斥量，而偏向锁在无竞争的情况下会把整个同步都会消除掉。

偏向锁中的“偏”，就是偏心的“偏”、偏袒的“偏” 它的意思是这个锁会偏向于第一个获得它的线程，如果在接下来的执行过程中，该锁一直没有被其他的线程获取，则持有偏向锁的线程将永远不需要再进行同步。

一旦出现另外一个线程去尝试获取这个锁的情况，偏向模式就马上宣告结束。根据锁对象目前是否处于被锁定的状态决定是否撤销偏向（偏向模式设置为“ 0”），撤销后标志位恢复到未锁定（标志位为“01 ”）或轻量级锁定（标志位为“00 ”）的状态

注意：

* 撤销偏向锁这个过程中所有线程需要暂停（STW）
* 访问对象的 hashCode 时候，如果对象处于偏向锁，也会撤销偏向锁，并且转换为重量级锁
* 如果对象虽然被多个线程访问，但没有竞争，这时偏向了线程 T1 的对象仍有机会重新偏向 T2，重偏向会重置对象的 Thread ID
* 撤销偏向和重偏向都是批量进行的，以类为单位
* 如果撤销偏向到达某个阈值，整个类的所有对象都会变为不可偏向的
* 可以主动使用 -XX:-UseBiasedLocking 禁用偏向锁

##### 轻量级锁

倘若偏向锁失败，虚拟机并不会立即升级为重量级锁，它还会尝试使用一种称为轻量级锁的优化手段(1.6之后加入的)。轻量级锁不是为了代替重量级锁，它的本意是在没有多线程竞争的前提下，减少传统的重量级锁使用操作系统互斥量产生的性能消耗，因为使用轻量级锁时，不需要申请互斥量。另外，轻量级锁的加锁和解锁都用到了CAS操作。

1. 加锁：
在代码进入同步块的时候，如果此同步对象没有被锁定（锁标志位为“01 ”状态），那么虚拟机就会在当前线程栈帧中创建一个名字为Lock Record的空间，用于存储当前对象的MarK Word的拷贝（方便后期比较），虚拟机将会使用CAS把对象的Mark Word更新为指向Lock Recod的指针。

   * 转化之前的对象头
    ![20210428143055](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210428143055.png)

   * 转换之后的对象头
    ![20210428143132](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210428143132.png)

如果这个更新操作成功了，则代表这个对象获得了这个对象的锁，锁状态变成轻量级锁的“00”。如果失败了，则代表有多个线程正在竞争这个对象的锁，这个时候虚拟机再检查对象的Mark Word的指针是不是指向了当前线程存的Lock Record，如果是则直接进入同步代码块（锁重入）。如果不是则代表锁已经被其他线程占用了。当线程数量两个及以上时候，则可能进行锁膨胀。

2. 解锁
将Lock Recod存的Mark Word替换回去，同样是使用CAS操作，假如能够成功替换，那整个同步过程就顺利完成了；如果替换失败，则说明有其他线程尝试过获取该锁，就要在释放锁的同时，唤醒被挂起的线程。

轻量级锁能提升程序同步性能的依据是“对于绝大部分的锁，在整个同步周期内都是不存在竞争的”这一经验法则 如果没有竞争，轻量级锁便通过 CAS 操作成功避免了使用互斥量的开销；但如果确实存在锁竞争，除了互斥量的本身开销 ，还额外发生了CAS作的开销 因此在有竞争的情况下，轻量级锁反而会比传统的重量级锁更慢。

##### 锁膨胀
如果在尝试加轻量级锁的过程中，CAS 操作无法成功，这时一种情况就是有其它线程为此对象加上了轻量级锁（有竞争），如果出现两条及以上的线程争用同一个锁的情况，后来的那条会自旋（循环等待）一定次数来等待锁，如果还是获取不到锁，这时需要进行锁膨胀，将轻量级锁变为重量级锁。

![20210428143229](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210428143229.png)

##### 重量级锁
重量级锁竞争的时候，还可以使用自旋来进行优化，如果当前线程自旋成功（即这时候持锁线程已经退出了同步块，释放了锁），这时当前线程就可以避免阻塞。

在 Java 6 之后自旋锁是自适应的，比如对象刚刚的一次自旋操作成功过，那么认为这次自旋成功的可能性会高，就多自旋几次；反之，就少自旋甚至不自旋，总之，比较智能。

##### synchronized的其他优化
1. **减少上锁时间：** 同步代码块中尽量短
2. **减少锁的粒度：** 将一个锁拆分为多个锁提高并发度
3. **锁粗化：** 多次循环进入同步块不如同步块内多次循环 另外 JVM 可能会做如下优化，把多次 append 的加锁操作粗化为一次（因为都是对同一个对象加锁，没必要重入多次）
4. **锁消除：** JVM 会进行代码的逃逸分析，例如某个加锁对象是方法内局部变量，不会被其它线程所访问到，这时候就会被即时编译器忽略掉所有同步操作。
5. **读写分离：** CopyOnWriteArrayList、ConyOnWriteSet等

### ReentrantLock
重人锁（ ReentrantLock ）是 Lock 接口最常见的一种实现，顾名思义，它与 synchronized样是可重人的 在基本用法上， ReentrantLock 也与 synchronized 很相似，只是代码写法上稍有区别而已 不过， ReentrantLock synchronized 相比增加了一些高级功能，主要有以下 等待可中断、可实现公平锁及锁可以绑定多个条件

* **等待可中断：** 是指当持有锁的线程长期不释放锁的时候，正在等待的线程可以选择放弃等待，改为处理其他事情 可中断特性对处理执行时间非常长的同步块很有帮助
* **公平锁：** 是指多个线程在等待同一个锁时，必须按照申请锁的时间顺序来依次获得锁；而非公平锁则不保证这一点，在锁被释放时，任何－个等待锁的线程都有机会获得锁 synchronized 中的锁是非公平的， ReentrantLock 默认情况下也是非公平
的，但可以通过带布尔值的构造函数要求使用公平锁 不过一旦使用了公平锁，将会导致 ReentrantLock 的性能急剧下降，会明显 吞吐量
* **锁绑定多个条件：** 是指一个 ReentrantLock 象可以同时绑定多个 Condition 对象synchronized 中，锁对象的 wait() 跟的 notify()或者 notifyAll ()方法配合可以实现一个隐含的条件，如果要和多于一个的条件关联的时候，就不得不额外添加一个锁；而 ReentrantLock 则无须这样做，多次调用 newCondition（）方法即可。


### Synchronized 和 ReentrantLock 的对比
**① 两者都是可重入锁**

两者都是可重入锁。“可重入锁”概念是：自己可以再次获取自己的内部锁。比如一个线程获得了某个对象的锁，此时这个对象锁还没有释放，当其再次想要获取这个对象的锁的时候还是可以获取的，如果不可锁重入的话，就会造成死锁。同一个线程每次获取锁，锁的计数器都自增1，所以要等到锁的计数器下降为0时才能释放锁。

**② synchronized 依赖于 JVM 而 ReenTrantLock 依赖于 API**

synchronized 是依赖于 JVM 实现的，前面我们也讲到了 虚拟机团队在 JDK1.6 为 synchronized 关键字进行了很多优化，但是这些优化都是在虚拟机层面实现的，并没有直接暴露给我们。ReenTrantLock 是 JDK 层面实现的（也就是 API 层面，需要 lock() 和 unlock 方法配合 try/finally 语句块来完成），所以我们可以通过查看它的源代码，来看它是如何实现的。

**③ ReenTrantLock 比 synchronized 增加了一些高级功能**

相比synchronized，ReenTrantLock增加了一些高级功能。主要来说主要有三点：**①等待可中断；②可实现公平锁；③可实现选择性通知（锁可以绑定多个条件）**

* **ReenTrantLock提供了一种能够中断等待锁的线程的机制**，通过lock.lockInterruptibly()来实现这个机制。也就是说正在等待的线程可以选择放弃等待，改为处理其他事情。
* **ReenTrantLock可以指定是公平锁还是非公平锁。而synchronized只能是非公平锁。所谓的公平锁就是先等待的线程先获得锁**。 ReenTrantLock默认情况是非公平的，可以通过 ReenTrantLock类的**ReentrantLock(boolean fair)** 构造方法来制定是否是公平的。
* synchronized关键字与wait()和notify/notifyAll()方法相结合可以实现等待/通知机制，ReentrantLock类当然也可以实现，但是需要借助于Condition接口与newCondition() 方法。Condition是JDK1.5之后才有的，它具有很好的灵活性，比如可以实现多路通知功能也就是在一个Lock对象中可以创建多个Condition实例（即对象监视器），**线程对象可以注册在指定的Condition中，从而可以有选择性的进行线程通知，在调度线程上更加灵活。 在使用notify/notifyAll()方法进行通知时，被通知的线程是由 JVM 选择的，用ReentrantLock类结合Condition实例可以实现“选择性通知” ，** 这个功能非常重要，而且是Condition接口默认提供的。而synchronized关键字就相当于整个Lock对象中只有一个Condition实例，所有的线程都注册在它一个身上。如果执行notifyAll()方法的话就会通知所有处于等待状态的线程这样会造成很大的效率问题，而Condition实例的signalAll()方法 只会唤醒注册在该Condition实例中的所有等待线程。

如果你想使用上述功能，那么选择ReenTrantLock是一个不错的选择。

**④ 性能已不是选择标准**

在JDK1.6之前，synchronized 的性能是比 ReenTrantLock 差很多。具体表示为：synchronized 关键字吞吐量随线程数的增加，下降得非常严重。而ReenTrantLock 基本保持一个比较稳定的水平。我觉得这也侧面反映了， synchronized 关键字还有非常大的优化余地。后续的技术发展也证明了这一点，我们上面也讲了在 JDK1.6 之后 JVM 团队对 synchronized 关键字做了很多优化。**JDK1.6 之后，synchronized 和 ReenTrantLock 的性能基本是持平了。所以网上那些说因为性能才选择 ReenTrantLock 的文章都是错的！JDK1.6之后，性能已经不是选择synchronized和ReenTrantLock的影响因素了！而且虚拟机在未来的性能改进中会更偏向于原生的synchronized，所以还是提倡在synchronized能满足你的需求的情况下，优先考虑使用synchronized关键字来进行同步！优化后的synchronized和ReenTrantLock一样，在很多地方都是用到了CAS操作。**

### 图解

![20210428150837](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210428150837.png)

### 参考

[Synchronized与ReentrantLock](https://blog.unclezs.com/Java/%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B/Synchronized%E4%B8%8EReentrantLock.html)

好文推荐：[带你探索ReentrantLock源码的快乐](https://mp.weixin.qq.com/s?__biz=Mzk0NjE3NDQyOA==&mid=2247483947&idx=1&sn=49261a16b47ecc9e629e7655bb11f10b&chksm=c30b6298f47ceb8eb6724c52b8c6767b43b0b6304acada3f3535e2c5efbef633c0639834f34c&token=1605614249&lang=zh_CN#rd)




