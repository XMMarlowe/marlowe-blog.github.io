---
title: 'sleep(),wait(),join(),yield()的区别'
author: Marlowe
tags: 线程
categories: 并发
abbrlink: 22900
date: 2021-03-09 17:12:15
---
<!--more-->

### sleep

### wait


### join


### yield


1. 锁池
所有需要竞争同步锁的线程都会放在锁池当中，比如当前对象的锁已经被其中一个线程得到，则其他线程需要在这个锁池等待，当前面的线程释放同步锁后锁池中的线程去竞争同步锁，当某个线程得到后会进入就绪队列进行等待cpu资源分配。
2. 等待池
当我们调用wait()方法后，线程会放到等待池当中，等待池的线程是不会去竞争同步锁。只有调用了notify()或notifyAll()后等待的线程才会开始去竞争锁，notify()是随机从等待池中选出一个线程放到锁池，而notifyAll()是将等待池的所有线程放到锁池当中。


1. sleep是Thread类的静态本地方法，wait是Object类的本地方法。
2. sleep方法不会释放lock，但wait会释放，而且会加入到等待队列中。
```java
sleep就是把cpu的执行资格和执行权释放出去，不在运行此线程，当定时时间结束后再取回cpu资源，参与cpu的调度，获取到cpu资源后就可以继续运行了。而如果sleep时线程有所，那么sleep不会释放这个锁，而是把锁带着进入了冻结状态，也就是说其他需要这个锁的线程根本不可能获取到这个锁。也即无法执行程序。如果在睡眠期间其他线程调用了这个线程的interrupt方法，那么这个线程也会抛出interruptexception异常返回，这个点和wait是一样的。
```
3. sleep方法不依赖于同步器synchronized，但是wait需要依赖synchronized关键字。
4. sleep不需要被唤醒(休眠之后退出阻塞),但是wait需要(不指定时间需要被别人中断)。
5. sleep一般用于当前线程休眠，或者轮循暂停操作，wait则多用于多线程之间的通信。
6. sleep会放出cpu执行时间且强制上下文切换，而wait则不一定，wait后可能还是有机会重新竞争到锁继续执行的。

yield() 执行后线程直接进入就绪状态，马上释放了cpu的执行权，但是依然保留了cpu的执行资格，所以有可能cpu下次进行线程调度还会让这个线程获取到执行权继续执行。

join() 执行后线程进入阻塞状态，例如在线程B中调用线程A的join()，则线程B会进入到阻塞队列，直到线程A结束或中断线程。
```java
public static void main(String[] args) throws InterruptedException {
        Thread t1 = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Thread.sleep(3000);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
                System.out.println("222222");
            }
        });
        t1.start();
        t1.join();
        // 这行代码需等t1线程执行结束才会继续执行
        System.out.println("11111");
    }
```
```java
结果：
222222
11111
```

### 说说 sleep() 方法和 wait() 方法区别和共同点?

* 两者最主要的区别在于：**sleep() 方法没有释放锁，而 wait() 方法释放了锁** 。
* 两者都可以暂停线程的执行。
* wait() 通常被用于线程间交互/通信，sleep() 通常被用于暂停执行。
* wait() 方法被调用后，线程不会自动苏醒，需要别的线程调用同一个对象上的 notify() 或者 notifyAll() 方法。sleep() 方法执行完成后，线程会自动苏醒。或者可以使用 wait(long timeout) 超时后线程会自动苏醒。