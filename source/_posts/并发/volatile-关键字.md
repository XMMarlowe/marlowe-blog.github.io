---
title: volatile 关键字
author: Marlowe
tags: volatile
categories: 并发
abbrlink: 38250
date: 2021-03-18 10:30:02
---
volatile 是Java虚拟机提供的轻量级同步机制，保证可见性，不保证原子性，禁止指令重排。
<!--more-->

### 1、CPU缓存模型

**为什么要弄一个 CPU 高速缓存呢？**
类比我们开发网站后台系统使用的缓存（比如 Redis）是为了解决程序处理速度和访问常规关系型数据库速度不对等的问题。 **CPU 缓存则是为了解决 CPU 处理速度和内存处理速度不对等的问题。**

我们甚至可以把 **内存可以看作外存的高速缓存**，程序运行的时候我们把外存的数据复制到内存，由于内存的处理速度远远高于外存，这样提高了处理速度。

**总结：** CPU Cache **缓存的是内存数据用于解决 CPU 处理速度和内存不匹配的问题，内存缓存的是硬盘数据用于解决硬盘访问速度过慢的问题。**

![20210318103319](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210318103319.png)

CPU Cache **的工作方式：**

先复制一份数据到 CPU Cache 中，当 CPU 需要用到的时候就可以直接从 CPU Cache 中读取数据，当运算完成后，再将运算得到的数据写回 Main Memory 中。但是，这样存在 **内存缓存不一致性的问题 ！** 比如我执行一个 i++操作的话，如果两个线程同时执行的话，假设两个线程从 CPU Cache 中读取的 i=1，两个线程做了 1++运算完之后再写回 Main Memory 之后 i=2，而正确结果应该是 i=3。

**CPU 为了解决内存缓存不一致性问题可以通过制定缓存一致协议或者其他手段来解决。**

### 2、讲一下 JMM(Java 内存模型)

在 JDK1.2 之前，Java 的内存模型实现总是从**主存**（即共享内存）读取变量，是不需要进行特别的注意的。而在当前的 Java 内存模型下，线程可以把变量保存**本地内存**（比如机器的寄存器）中，而不是直接在主存中进行读写。这就可能造成一个线程在主存中修改了一个变量的值，而另外一个线程还继续使用它在寄存器中的变量值的拷贝，**造成数据的不一致。**

![20210318103632](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210318103632.png)

要解决这个问题，就需要把变量声明为**volatile**，这就指示 JVM，这个变量是共享且不稳定的，每次使用它都到主存中进行读取。

所以，**volatile 关键字 除了防止 JVM 的指令重排 ，还有一个重要的作用就是保证变量的可见性。**

![20210318103709](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210318103709.png)

**关于JMM的一些同步约定：**
1. 线程解锁前，必须把共享变量**立刻**刷回主存。
2. 线程加锁前，必须读取主存中的最新值到工作内存中。
3. 加锁和解锁是同一把锁。


**关于主内存与工作内存之间的具体交互协议，即一个变量如何从主内存拷贝到工作内存、如何从工作内存同步到主内存之间的实现细节，Java内存模型定义了以下八种操作来完成：**

* **lock（锁定）**：作用于主内存的变量，把一个变量标识为一条线程独占状态。
* **unlock（解锁）**：作用于主内存变量，把一个处于锁定状态的变量释放出来，释放后的变量才可以被其他线程锁定。
* **read（读取）**：作用于主内存变量，把一个变量值从主内存传输到线程的工作内存中，以便随后的load动作使用
* **load（载入）**：作用于工作内存的变量，它把read操作从主内存中得到的变量值放入工作内存的变量副本中。
* **use（使用）**：作用于工作内存的变量，把工作内存中的一个变量值传递给执行引擎，每当虚拟机遇到一个需要使用变量的值的字节码指令时将会执行这个操作。
* **assign（赋值）**：作用于工作内存的变量，它把一个从执行引擎接收到的值赋值给工作内存的变量，每当虚拟机遇到一个给变量赋值的字节码指令时执行这个操作。
* **store（存储）**：作用于工作内存的变量，把工作内存中的一个变量的值传送到主内存中，以便随后的write的操作。
* **write（写入）**：作用于主内存的变量，它把store操作从工作内存中一个变量的值传送到主内存的变量中。

**Java内存模型还规定了在执行上述八种基本操作时，必须满足如下规则：**

* 如果要把一个变量从主内存中复制到工作内存，就需要按顺寻地执行read和load操作， 如果把变量从工作内存中同步回主内存中，就要按顺序地执行store和write操作。但Java内存模型只要求上述操作必须按顺序执行，而没有保证必须是连续执行。
* 不允许read和load、store和write操作之一单独出现
* 不允许一个线程丢弃它的最近assign的操作，即变量在工作内存中改变了之后必须同步到主内存中。
* 不允许一个线程无原因地（没有发生过任何assign操作）把数据从工作内存同步回主内存中。
* 一个新的变量只能在主内存中诞生，不允许在工作内存中直接使用一个未被初始化（load或assign）的变量。即就是对一个变量实施use和store操作之前，必须先执行过了assign和load操作。
* 一个变量在同一时刻只允许一条线程对其进行lock操作，但lock操作可以被同一条线程重复执行多次，多次执行lock后，只有执行相同次数的unlock操作，变量才会被解锁。lock和unlock必须成对出现
* 如果对一个变量执行lock操作，将会清空工作内存中此变量的值，在执行引擎使用这个变量前需要重新执行load或assign操作初始化变量的值
* 如果一个变量事先没有被lock操作锁定，则不允许对它执行unlock操作；也不允许去unlock一个被其他线程锁定的变量。
* 对一个变量执行unlock操作之前，必须先把此变量同步到主内存中（执行store和write操作）。

代码示例：
开启两个线程，一个主线程，一个新线程。
```java
public class Test3 {

    private static int num = 0;

    public static void main(String[] args) {
        new Thread(() -> { // 线程1对主内存的变化是不知道的
            while (num == 0) {

            }
        }).start();

        try {
            TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        num = 1;
        System.out.println(num);
    }
}
```
结果：
```java
1

// 程序一直执行
```
问题：程序不知道主内存的值已经被修改为1

### 3、volatile
> 1. 保证可见性

代码示例：
```java
public class Test3 {
    /**
     * 不加 volatile 程序会死循环！
     * 加 volatile 可以保证变量可见性
     */
    private volatile static int num = 0;

    public static void main(String[] args) {
        new Thread(() -> {
            while (num == 0) {

            }
        }).start();

        try {
            TimeUnit.SECONDS.sleep(1);
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        num = 1;
        System.out.println(num);
    }
}
```
结果：
```java
1

Process finished with exit code 0
```

> 2. 不保证原子性

原子性：不可分割
线程A在执行任务的时候，是不能被打扰的，也不能被分割，要么同时成功，要么同时失败。

代码示例：
```java
public class TestVolatile {

    // volatile 不保证原子性
    private volatile static int num = 0;

    public static void add() {
        // 不是原子性操作
        num++;
    }

    public static void main(String[] args) {
        // 理论上num结果应该为2w
        for (int i = 1; i <= 20; i++) {
            new Thread(() -> {
                for (int j = 0; j < 1000; j++) {
                    add();
                }
            }).start();
        }

        while (Thread.activeCount() > 2) {
            Thread.yield();
        }
        System.out.println(Thread.currentThread().getName() + " " + num);
    }
}
```
结果：
```java
main 19782 // 结果每次可能不一样，但不会变为2w
```

**如果不加lock和synchronized,怎么样保证原子性?**

![f822b9563ace44088174c496091d75c](http://marlowe.oss-cn-beijing.aliyuncs.com/img/f822b9563ace44088174c496091d75c.png)

**使用原子类解决原子性问题**

代码示例:
```java
public class TestVolatile {

    // volatile 不保证原子性
    private volatile static AtomicInteger num = new AtomicInteger();

    public static void add() {
        // AtomicInteger +1 方法  不是简单的 +1 操作，而是用的CAS
        num.getAndIncrement();
    }

    public static void main(String[] args) {
        // 理论上num结果应该为2w
        for (int i = 1; i <= 20; i++) {
            new Thread(() -> {
                for (int j = 0; j < 1000; j++) {
                    add();
                }
            }).start();
        }

        while (Thread.activeCount() > 2) {
            Thread.yield();
        }
        System.out.println(Thread.currentThread().getName() + " " + num);
    }
}
```

结果：
```java
main 20000
```

这些类的底层都直接和操作系统挂钩！在内存中修改值！Unsafe类是一个很特殊的存在。

> 3. 禁止指令重排

什么是指令重排：你写的程序，计算机并不是按照你写的那样去执行的。
源代码--> 编译器优化的重排--> 指令并行也可能重排--> 内存系统也会重排--> 执行.

**前提：处理器在进行指令重排的时候，会考虑数据之间的依赖性！**


```java
int x = 1; // 1
int y = 2; // 2
x = x + 5; // 3
y = x * x; // 4

我们所期望的：1234 但是可能执行的时候会变成 2134 1324
```

#### volatile如何保证可见性？

volatile 主要是利用了java的先行发生原则 （简单介绍先行发生原则：在计算机科学中，先行发生原则是两个事件的结果之间的关系，如果一个事件发生在另一个事件之前，结果必须反映，即使这些事件实际上是乱序执行的（通常是优化程序流程））。

**volatile相关的规则：**
1. 对于一个volatile变量的写操作先行发生于后面对这个变量的读操作。
2. 因此当线程1执行了vlt=5；写操作是必然先发生2线程读操作。即线程2从主内存读到的数据一定是线程1写过的数据那就是5。所以volatile主要利用了先行发生原则保证线程之间的可见性。

#### volatile如何避免指令重排？（底层实现）

**内存屏障**，是一个CPU指令。 作用：
1. 保证特定操作的执行顺序。
2. 可以保证某些变量的内存可见性（利用这些特性，volatile实现了可见性）。

volatile 可以保证可见性，不能保证原子性，由于内存屏障，可以保证避免指令重排的现象产生！

由于编译器和处理器都能执行指令重排优化，如果在指令之间插入一条内存屏障则会告诉编译器和cup不管在任何情况下，无论任何指令都不能和这条内存屏障进行指令重排，也就是说通过插入内存屏障禁止在内存屏障前后的指令执行重排序优化。内存屏障的另外一个作用就是强制刷出各种CPU的缓存数据，因此在任何CPU上的线程都能读取到这些数据的最新值。

![volatile禁止指令重排](https://img-blog.csdnimg.cn/20200704151144615.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3UwMTQzODUyNjc=,size_16,color_FFFFFF,t_70#pic_center)



### 4、并发编程的三个重要特性
1. **原子性 :** 一个的操作或者多次操作，要么所有的操作全部都得到执行并且不会收到任何因素的干扰而中断，要么所有的操作都执行，要么都不执行。synchronized 可以保证代码片段的原子性。
2. **可见性 ：** 当一个变量对共享变量进行了修改，那么另外的线程都是立即可以看到修改后的最新值。volatile 关键字可以保证共享变量的可见性。
3. **有序性 ：** 代码在执行的过程中的先后顺序，Java 在编译器以及运行期间的优化，代码的执行顺序未必就是编写代码时候的顺序。volatile 关键字可以禁止指令进行重排序优化。

### 5、说说 synchronized 关键字和 volatile 关键字的区别

synchronized 关键字和 volatile 关键字是两个互补的存在，而不是对立的存在！

* volatile 关键字是线程同步的轻量级实现，所以**volatile 性能肯定比synchronized关键字要好。但是volatile 关键字只能用于变量而 synchronized 关键字可以修饰方法以及代码块**。
* volatile **关键字能保证数据的可见性，但不能保证数据的原子性。** synchronized **关键字两者都能保证。**
* volatile **关键字主要用于解决变量在多个线程之间的可见性，而** synchronized **关键字解决的是多个线程之间访问资源的同步性。**


### 5、参考
[volatile 关键字](https://snailclimb.gitee.io/javaguide/#/docs/java/multi-thread/2020%E6%9C%80%E6%96%B0Java%E5%B9%B6%E5%8F%91%E8%BF%9B%E9%98%B6%E5%B8%B8%E8%A7%81%E9%9D%A2%E8%AF%95%E9%A2%98%E6%80%BB%E7%BB%93?id=_2-volatile-%e5%85%b3%e9%94%ae%e5%ad%97)