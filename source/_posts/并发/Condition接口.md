---
title: Condition接口
author: Marlowe
tags: Condition
categories: 并发
abbrlink: 52091
date: 2021-05-16 21:33:40
---

<!--more-->

### 简介

wait()、notify()与synchronized配合可以实现等待通知，condition和Lock配合同样也可以实现等待通知，但是两者之前还是有区别的。

Condition定义了等待/通知两种类型的方法，当前线程调用这些方法时，需要提前获取到Condition对象关联的锁，**Condition对象是由Lock对象创建出来的(Lock.newCondition)**，换句话说，Condition是依赖Lock对象的。


### Condition常用API

**void await():**
当前线程从运行状态进入等待状态或者中断，直到被通知唤醒。
**boolean await(long time, TimeUnit unit)；**
当前线程进入等待状态，直到被通知、中断或者超时
**boolean awaitUntil(Date deadline)**
当前线程进入等待状态，直到被通知、中断或者到达指定的时间。到达指定的时间返回
false，否则返回true（还没有导致指定时间就被唤醒）
**void signal():**
唤醒一个等待在Condition上的线程，但是必须获得与该Condition相关的锁
**void signalAll():**
唤醒所有等待在Condition上的线程，但是必须获得与该Condition相关的锁

#### 案例：实现有界队列

有界队列是一种特殊的队列，当队列为空时，队列的获取操作将会阻塞获取线程，直到队列中有新增元素，当队列已满时，队列的插入操作将会阻塞插入线程，直到队列出现“空位”

```java
/**
 * 使用Condition实现有界队列
 */
public class BoundedQueue<T> {
    //数组队列
    private Object[] items;
    //添加下标
    private int addIndex;
    //删除下标
    private int removeIndex;
    //当前队列数据数量
    private int count;
    //互斥锁
    private Lock lock = new ReentrantLock();
    //队列不为空的条件
    private Condition notEmpty = lock.newCondition();
    //队列没有满的条件
    private Condition notFull = lock.newCondition();

    public BoundedQueue(int size) {
        items = new Object[size];
    }

    //添加一个元素，如果数组满了，添加线程进入等待状态，直到有“空位”
    public void add(T t){
        lock.lock();
        try {
              while(count == items.length)
                  notFull.wait();
              items[addIndex] = t;
              if(++addIndex == items.length)
                  addIndex = 0;
              ++count;
              //唤醒一个等待删除的线程
              notEmpty.signal();
        } catch (Exception e) {
            e.printStackTrace();
        } finally{
            lock.unlock();
        }
    }
    //由头部删除一个元素，如果数组空，则删除线程进入等待状态，知道有新元素加入
    public T remove() throws InterruptedException {
        lock.lock();
        try {
            while(count == 0){
                notEmpty.await();
            }
            Object res = items[removeIndex];
            if(++removeIndex==items.length)
                removeIndex=0;
            --count;
            //唤醒一个等待插入的线程
            notFull.signal();
            return (T)res;
        } finally{
            lock.unlock();
        }
    }
}
```

BoundedQueue通过add(T t)方法添加一个元素，通过remove()方法移出一个元素。以添加方法为例。

**首先需要获得锁，目的是确保数组修改的可见性和排他性。** 当数组数量等于数组长度时，表示数组已满，则调用notFull.await()，当前线程随之释放锁并进入等待状态。如果数组数量不等于数组长度，表示数组未满，则添加元素到数组中，同时通知等待在notEmpty上的线程，数组中已经有新元素可以获取。

**在添加和删除方法中使用while循环而非if判断，目的是防止过早或意外的通知，只有条件符合才能够退出循环。**

### Condition实现分析

**ConditionObject**是同步器**AbstractQueuedSynchronizer**的内部类，每个Condition对象都包含着一个等待队列，该队列是Condition对象实现等待/通知功能的关键。


#### 1、等待队列

等待队列是一个FIFO的队列，在队列中的每个节点都包含了一个线程引用，**该线程就是在Condition对象上等待的线程。** 如果一个线程调用了Condition.await()方法，那么该线程将会释放锁、构造成节点加入等待队列并进入等待状态。事实上，节点的定义复用了同步器中节点的定义，也就是说，同步队列和等待队列中节点类型都是同步器的静态内部类**AbstractQueuedSynchronizer.Node**。

一个Condition包含一个等待队列，Condition拥有首节点（firstWaiter）和尾节（lastWaiter）。当前线程调用Condition.await()方法，将会以当前线程构造节点，并将节点从尾部加入等待队列。

**注意：上述节点引用更新的过程并没有使用CAS保证，原因在于调用await()方法的线程必定是获取了锁的线程，也就是说该过程是由锁来保证线程安全的。**

![20210516215105](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210516215105.png)

#### 2、等待

调用Condition的await()方法，会使**当前线程进入等待队列并释放锁**，同时线程状态变为等待状态。**调用该方法之前，当前线程一定获取了Condition相关联的锁。**

如果从队列（同步队列和等待队列）的角度看await()方法，**当调用await()方法时，相当于同步队列的首节点（获取了锁的节点）移动到Condition的等待队列中。**

在**AQS**中提供了**ConditionObject**内部类，如果调用该内部列中的**await**方法，首先调用该方法的线程会成功获取了锁的线程，也就是同步队列中的首节点，其次**该方法会将当前线程构造成节点并加入等待队列中，然后释放同步状态，唤醒同步队列中的后继节点，然后当前线程会进入等待状态。**

如果从队列的角度去看，同步队列中当前线程加入Condition的等待队列。

![20210516215251](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210516215251.png)

#### 3、通知

调用Condition的 **signal()** 方法，**将会唤醒在等待队列中等待时间最长的节点（首节点），在唤醒节点之前，会将节点移到同步队列中。**

通过调用**AQS**的 **enq(Node node)** 方法，等待队列中的头节点线程安全地移动到同步队列。当节点移动到同步队列后，当前线程再使用LockSupport唤醒该节点的线程。

Condition的 **signalAll()** 方法，**相当于对等待队列中的每个节点均执行一次 signal() 方法**，效果就是将等待队列中所有节点全部移动到同步队列中，并唤醒每个节点的线程。

![20210516215423](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210516215423.png)

### 参考

[Condition接口](https://blog.csdn.net/ma_chen_qq/article/details/82990283)