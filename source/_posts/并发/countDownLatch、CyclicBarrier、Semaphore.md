---
title: countDownLatch、CyclicBarrier、Semaphore
author: Marlowe
tags: 
  - countDownLatch
  - CyclicBarrier
  - Semaphore
categories: 并发
abbrlink: 7997
date: 2020-12-27 01:13:41
---
### countDownLatch

#### 简介
* countDownLatch这个类使一个线程等待其他线程各自执行完毕后再执行。
* 是通过一个计数器来实现的，计数器的初始值是线程的数量。每当一个线程执行完毕后，计数器的值就-1，当计数器的值为0时，表示所有线程都执行完毕，然后在闭锁上等待的线程就可以恢复工作了。
* 减法计数器

#### 原理
`countDownLatch.countDown();` // 数量-1
`countDownLatch.await();` // 等待计数器归零，然后向下执行
每次有线程调用countDown(),数量减一，假设计数器变为0,countDownLatch.await();就会被唤醒，继续执行！

代码示例：
```java
public class CountDownLatchDemo {
    public static void main(String[] args) throws InterruptedException {
        // 总数是6，必须要执行任务的时候，再使用！
        CountDownLatch countDownLatch = new CountDownLatch(6);

        for (int i = 0; i <= 6; i++) {
            new Thread(() -> {
                System.out.println(Thread.currentThread().getName() + " Go out");
                countDownLatch.countDown();
            }, String.valueOf(i)).start();

        }
        // 等待计数器归零，然后再向下执行
        countDownLatch.await();
        System.out.println("close door");
    }
}
```
结果：
```
// x顺序不确定，但只有6个线程结束后才向下执行
x Go out
x Go out
x Go out
x Go out
x Go out
x Go out
Close door
```

---

### CyclicBarrier

#### 简介
* 从字面上的意思可以知道，这个类的中文意思是“循环栅栏”。大概的意思就是一个可循环利用的屏障。

* 加法计数器

举个例子，就像生活中我们会约朋友们到某个餐厅一起吃饭，有些朋友可能会早到，有些朋友可能会晚到，但是这个餐厅规定必须等到所有人到齐之后才会让我们进去。这里的朋友们就是各个线程，餐厅就是 CyclicBarrier。

#### 作用
CyclicBarrier的作用是**让所有线程都等待完成后才会继续下一步行动。**

代码示例：
```java
public class CyclicBarrierDemo {
    public static void main(String[] args) {

        // 召唤龙珠的线程
        CyclicBarrier cyclicBarrier = new CyclicBarrier(7, () -> {
            System.out.println("召唤神龙成功！");
        });
        for (int i = 1; i <= 7; i++) {
            // 定义一个final 中间变量接收i
            final int temp = i;
            new Thread(() -> {
                System.out.println(Thread.currentThread().getName() + "收集了" + temp + "个龙珠");
                try {
                    cyclicBarrier.await();
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } catch (BrokenBarrierException e) {
                    e.printStackTrace();
                }
            }).start();
        }
    }
}
```
**结果**
```java
Thread-1收集了2个龙珠
Thread-2收集了3个龙珠
Thread-0收集了1个龙珠
Thread-3收集了4个龙珠
Thread-4收集了5个龙珠
Thread-5收集了6个龙珠
Thread-6收集了7个龙珠
召唤神龙成功！
```

--- 

### Semaphore

#### 简介
一般用来控制同时访问特定共享资源的线程数，它通过协调各个线程来保证使用公共资源的合理性。

#### 作用
* Semaphore的作用是**控制并发访问的线程数目。**
* 多个共享资源互斥使用，开发限流！

#### 原理
`semaphore.acquire()` // 获得，假设已经满了，等待，等待被释放为止
`semaphore.release()` // 释放，会将当前的信号量释放 + 1，然后唤醒等待线程！

代码示例：
```java
public class SemaphoreDemo {
    public static void main(String[] args) {
        //  线程数量，停车位，限流
        Semaphore semaphore = new Semaphore(3);

        for (int i = 1; i <= 6; i++) {
            new Thread(() -> {
                try {
                    // 得到
                    semaphore.acquire();
                    System.out.println(Thread.currentThread().getName() + "抢到车位");
                    TimeUnit.SECONDS.sleep(2);
                    System.out.println(Thread.currentThread().getName() + "离开车位");
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
                    // 释放
                    semaphore.release();
                }
            }, String.valueOf(i)).start();
        }
    }
}
```
结果：
```java
1 抢到车位
2 抢到车位
3 抢到车位
1 离开车位
2 离开车位
3 离开车位
4 抢到车位
6 抢到车位
5 抢到车位
4 离开车位
6 离开车位
5 离开车位
```



### CountDownLatch和CyclicBarrier区别

1. countDownLatch是一个计数器，线程完成一个记录一个，计数器递减，只能只用一次
2. CyclicBarrier的计数器更像一个阀门，需要所有线程都到达，然后继续执行，计数器递增，提供reset功能，可以多次使用。
