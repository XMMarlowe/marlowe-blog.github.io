---
title: 初识CAS与ABA问题
author: Marlowe
tags:
  - CAS
  - ABA
categories: 并发
abbrlink: 33465
date: 2021-03-25 20:34:19
---

<!--more-->
### 什么是CAS？
CAS是英文单词CompareAndSwap的缩写，中文意思是：比较并替换。CAS需要有3个操作数：内存地址V，旧的预期值A，即将要更新的目标值B。 CAS指令执行时，当且仅当内存地址V的值与预期值A相等时，将内存地址V的值修改为B，否则就什么都不做。整个比较并替换的操作是一个原子操作。它体现的一种乐观锁的思想，比如多个线程要对一个共享的整型变量执行 +1 操作

获取共享变量时，为了保证该变量的可见性，需要使用 volatile 修饰。结合 CAS 和 volatile 可以实现无锁并发，适用于竞争不激烈、多核 CPU 的场景下。

* 因为没有使用 synchronized，所以线程不会陷入阻塞，这是效率提升的因素之一
* 但如果竞争激烈，可以想到重试必然频繁发生，反而效率会受影响

CAS 底层依赖于一个 Unsafe 类来直接调用操作系统底层的 CAS 指令

伪代码：
```java
// 需要不断尝试
while(true) { 
  int 旧值 = 共享变量;//比如拿到了当前值 0 
  int 结果 = 旧值 + 1;//在旧值 0 的基础上增加 1 ，正确结果是 1 

  //这时候如果别的线程把共享变量改成了 5，本线程的正确结果 1 就作
  //废了，这时候 compareAndSwap 返回 false，重新尝试，直到： compareAndSwap 返回 
  //true，表示我本线程做修改的同时，别的线程没有干扰
  if( compareAndSwap ( 旧值, 结果 )) { 
    // 成功，退出循环 
  }
}
```

代码示例：
```java
public class CASDemo {

    public static void main(String[] args) {

        AtomicInteger atomicInteger = new AtomicInteger(2020);
        // public final boolean compareAndSet(int expect, int update)
        // 如果我的期望值达到了，就更新，否则不更新  CAS是CPU的并发原语！
        System.out.println(atomicInteger.compareAndSet(2020, 2021));
        System.out.println(atomicInteger.get());

        System.out.println(atomicInteger.compareAndSet(2020, 2021));
        System.out.println(atomicInteger.get());
    }
}
```
结果：
```java
true
2021
false
2021
```

### CAS 缺点

CAS虽然很高效的解决了原子操作问题，但是CAS仍然存在三大问题。

#### ABA问题

在多线程场景下CAS会出现ABA问题，关于ABA问题这里简单科普下，例如有2个线程同时对同一个值(初始值为A)进行CAS操作，这三个线程如下

1. 线程1，期望值为A，欲更新的值为B
2. 线程2，期望值为A，欲更新的值为B

线程1抢先获得CPU时间片，而线程2因为其他原因阻塞了，线程1取值与期望的A值比较，发现相等然后将值更新为B，然后这个时候**出现了线程3，期望值为B，欲更新的值为A**，线程3取值与期望的值B比较，发现相等则将值更新为A，此时线程2从阻塞中恢复，并且获得了CPU时间片，这时候线程2取值与期望的值A比较，发现相等则将值更新为B，虽然线程2也完成了操作，但是线程2并不知道值已经经过了A->B->A的变化过程。

#### ABA问题带来的危害

**例1：**
小明在提款机，提取了50元，因为提款机问题，有两个线程，同时把余额从100变为50
线程1（提款机）：获取当前值100，期望更新为50，
线程2（提款机）：获取当前值100，期望更新为50，
线程1成功执行，线程2某种原因block了，这时，某人给小明汇款50
线程3（默认）：获取当前值50，期望更新为100，
这时候线程3成功执行，余额变为100，
线程2从Block中恢复，获取到的也是100，compare之后，继续更新余额为50！！！
此时可以看到，实际余额应该为100（100-50+50），但是实际上变为了50（100-50+50-50）这就是ABA问题带来的成功提交。

**例2：**

假如你的老板很有洁癖，现在桌子上有一杯水，在你非常渴的情况下发现这个盛满水的杯子，你一饮而尽。之后再给杯子里重新倒满水。然后你离开，当老板回来时看到杯子还是盛满水，他当然不知道是否被人喝完重新倒满。

**解决方法：** 在变量前面加上版本号，每次变量更新的时候变量的版本号都+1，即A->B->A就变成了1A->2B->3A。


#### 循环会耗时

如果CAS操作失败，就需要循环进行CAS操作(循环同时将期望值更新为最新的)，如果长时间都不成功的话，那么会造成CPU极大的开销。
**解决办法：** 限制自旋次数，防止进入死循环。

#### 只能保证一个共享变量的原子操作

CAS的原子操作只能针对一个共享变量。

**解决方法：** 如果需要对多个共享变量进行操作，可以使用加锁方式(悲观锁)保证原子性，或者可以把多个共享变量合并成一个共享变量进行CAS操作。





### CAS:ABA问题

#### 什么是ABA问题？

ABA问题通俗一点的说，就是一个从内存里面读取到了值A，正在改的时候也检查到了还是A，但是真实的值是被改成了B再改回了A的。

#### 怎么解决ABA问题?

解决ABA问题就是给操作数加上一个“版本号”，就像Mysql的乐观锁一样。而Java中提供了AtomicStampedReference类来实现这个功能。

AtomicStampedReference类可以给一个引用标记上一个标记位，来保证原子性。AtomicStampedReference可以给一个引用标记上一个整型的版本戳，来保证原子性。

代码测试：
```java
public class CASTest {
    public static String A = "A";
    public static String B = "B";
    public static String C = "C";
    public static AtomicStampedReference<String> atomic = new AtomicStampedReference<>(A, 0);

    public static void main(String[] args) {
        //线程1来了，先检查是否和当前值一样,我准备把A改成C了,并且拿到线程1比较时候的stamp
        boolean same = atomic.attemptStamp(A, 1);
        int stamp = atomic.getStamp();
        //线程2来了，我准备把A换成B了
        atomic.compareAndSet(A, B, atomic.getStamp(), atomic.getStamp() + 1);
        //线程3来了，我准备把B换回A了
        atomic.compareAndSet(A, B, atomic.getStamp(), atomic.getStamp() + 1);
        //到线程1来修改了A成C了
        if (same) {
            boolean b = atomic.compareAndSet(A, C, stamp, stamp + 1);
            System.out.println(b?"修改成功":"修改失败ABA了");
        }
    }
}
```

### CAS的应用

我们知道CAS操作并不会锁住共享变量，也就是一种非阻塞的同步机制，CAS就是乐观锁的实现。

1. 乐观锁
**乐观锁**总是假设最好的情况，每次去操作数据都认为不会被别的线程修改数据，**所以在每次操作数据的时候都不会给数据加锁，** 即在线程对数据进行操作的时候，**别的线程不会阻塞**仍然可以对数据进行操作，只有在需要更新数据的时候才会去判断数据是否被别的线程修改过，如果数据被修改过则会拒绝操作并且返回错误信息给用户。
2. 悲观锁
**悲观锁**总是假设最坏的情况，每次去操作数据时候都认为会被的线程修改数据，**所以在每次操作数据的时候都会给数据加锁，** 让别的线程无法操作这个数据，别的线程会一直阻塞直到获取到这个数据的锁。这样的话就会影响效率，比如当有个线程发生一个很耗时的操作的时候，别的线程只是想获取这个数据的值而已都要等待很久。

Java利用CAS的乐观锁、原子性的特性高效解决了多线程的安全性问题，例如JDK1.8中的集合类ConcurrentHashMap、关键字volatile、ReentrantLock等。




### 参考
[认识CAS与ABA问题](https://blog.unclezs.com/Java/%E5%B9%B6%E5%8F%91%E7%BC%96%E7%A8%8B/%E8%AE%A4%E8%AF%86CAS%E4%B8%8EABA%E9%97%AE%E9%A2%98.html)

[CAS原理分析及ABA问题详解](https://juejin.cn/post/6844903796129136647#heading-1)



