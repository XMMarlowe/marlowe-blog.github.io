---
title: 为什么AQS底层是CAS + volatile
author: Marlowe
tags:
  - AQS
  - CAS
  - volatile
categories: 并发
abbrlink: 33571
date: 2021-04-28 15:13:44
---

<!--more-->

### CAS操作和volatile简述

#### CAS操作

##### CAS是什么？

CAS是compare and swap的缩写，从字面上理解就是比较并更新；主要是通过 **处理器的指令** 来保证操作的原子性 。

CAS 操作包含三个操作数：

* 内存位置（V）
* 预期原值（A）
* 更新值(B)

**简单来说：** 从内存位置V上取到存储的值，将值和预期值A进行比较，如果值和预期值A的结果相等，那么我们就把新值B更新到内存位置V上，如果不相等，那么就重复上述操作直到成功为止。

例如：JDK中的 unsafe 类中的 compareAndSwapInt 方法：

```java
unsafe.compareAndSwapInt(this, stateOffset, expect, update);
```

* stateOffset 变量值在内存中存放的位置；
* expect 期望值；
* update 更新值；

##### CAS的优点

CAS是一种无锁化编程，是一种非阻塞的轻量级的乐观锁；相比于synchronized阻塞式的重量级的悲观锁来说，性能会好很多 。

**但是注意：** synchronized关键字在不断的优化下（锁升级优化等），性能也变得十分的好。

#### volatile 关键字

##### volatile是什么？

volatile是java虚拟机提供的一种轻量级同步机制。

##### volatile的作用

* 可以保证被volatile修饰的变量的读写具有原子性，不保证复合操作（i++操作等）的原子性；

* 禁止指令重排序；

* 被volatile修饰的的变量修改后，可以马上被其它线程感知到，保证可见性；

### CAS + volatile = 同步代码块

总述同步代码块的实现原理：

1. 使用 volatile 关键字修饰一个int类型的同步标志位state，初始值为0；
2. 加锁/释放锁时使用CAS操作对同步标志位state进行更新；
   * 加锁成功，同步标志位值为 1，加锁状态；
   * 释放锁成功，同步标志位值为0，初始状态；

#### 加锁实现

##### 加锁流程图

![加锁流程图](https://img-blog.csdnimg.cn/img_convert/a36292a0708da5e2c8cd0632b5529843.png)


##### 加锁代码

```java
 **
 * 加锁，非公平方式获取锁
 */
public final void lock() {
  
    while (true) {
        // CAS操作更新同步标志位
        if (compareAndSetState(0, 1)) {
            // 将独占锁的拥有者设置为当前线程
            exclusiveOwnerThread = Thread.currentThread();

            System.out.println(Thread.currentThread() + "  lock success ! set lock owner is current thread .  " +
                    "state：" + state);

            try {
                // 睡眠一小会，模拟更加好的效果
                Thread.sleep(100);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

            // 跳出循环
            break;

        } else {
            // TODO 如果同步标志位是1，并且锁的拥有者是当前线程的话，则可以设置重入，但本方法暂未实现
            if (1 == state && Thread.currentThread() == exclusiveOwnerThread) {
                // 进行设置重入锁
            }

            System.out.println(Thread.currentThread() + "  lock fail ! If the owner of the lock is the current thread," +
                    "  the reentrant lock needs to be set；else Adds the current thread to the blocking queue .");

            // 将线程阻塞，并将其放入阻塞列表
            parkThreadList.add(Thread.currentThread());
            LockSupport.park(this);

            // 线程被唤醒后会执行此处，并且继续执行此 while 循环
            System.out.println(Thread.currentThread() + "  The currently blocking thread is awakened !");
        }
    }
}
```

#### 锁释放实现

##### 释放锁流程图

![释放锁流程图](https://img-blog.csdnimg.cn/img_convert/9f7d067573d3e26d2962fa03c355b410.png)

##### 释放锁代码

```java
/**
 * 释放锁
 *
 * @return
 */
public final boolean unlock() {
    // 判断锁的拥有者是否为当前线程
    if (Thread.currentThread() != exclusiveOwnerThread) {
        throw new IllegalMonitorStateException("Lock release failed !  The owner of the lock is not " +
                "the current thread.");
    }
    // 将同步标志位设置为0，初始未加锁状态
    state = 0;
    // 将独占锁的拥有者设置为 null
    exclusiveOwnerThread = null;

    System.out.println(Thread.currentThread() + "  Release the lock successfully, and then wake up " +
            "the thread node in the blocking queue !  state：" + state);

    if (parkThreadList.size() > 0) {
        // 从阻塞列表中获取阻塞的线程
        Thread thread = parkThreadList.get(0);
        // 唤醒阻塞的线程
        LockSupport.unpark(thread);
        // 将唤醒的线程从阻塞列表中移除
        parkThreadList.remove(0);
    }

    return true;
}
```

#### 完整代码如下

```java
import sun.misc.Unsafe;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.locks.LockSupport;


/**
 * @PACKAGE_NAME: com.lyl.thread6
 * @ClassName: AqsUtil
 * @Description: 使用 CAS + volatile 同步标志位  =  实现 迷你版AQS ;
 * <p>
 * <p>
 * 注意：本类只简单实现了基本的非公平方式的独占锁的获取与释放; 像重入锁、公平方式获取锁、共享锁等都暂未实现
 * <p/>
 * @Date: 2021-01-15 10:55
 * @Author: [ 木子雷 ] 公众号
 **/
public class AqsUtil {

    /**
     * 同步标志位
     */
    private volatile int state = 0;

    /**
     * 独占锁拥有者
     */
    private transient Thread exclusiveOwnerThread;

    /**
     * JDK中的rt.jar中的Unsafe类提供了硬件级别的原子性操作
     */
    private static final Unsafe unsafe;

    /**
     * 存放阻塞线程的列表
     */
    private static List<Thread> parkThreadList = new ArrayList<>();

    /**
     * 同步标志位 的“起始地址”偏移量
     */
    private static final long stateOffset;


    static {
        try {
            unsafe = getUnsafe();
            // 获取 同步标志位status 的“起始地址”偏移量
            stateOffset = unsafe.objectFieldOffset(AqsUtil.class.getDeclaredField("state"));
        } catch (NoSuchFieldException e) {
            throw new Error(e);
        }
    }


    /**
     * 通过反射 获取 Unsafe 对象
     *
     * @return
     */
    private static Unsafe getUnsafe() {
        try {
            Field field = Unsafe.class.getDeclaredField("theUnsafe");
            field.setAccessible(true);
            return (Unsafe) field.get(null);
        } catch (Exception e) {
            return null;
        }
    }


    /**
     * 加锁，非公平方式获取锁
     */
    public final void lock() {
        
        while (true) {
          
            if (compareAndSetState(0, 1)) {
                // 将独占锁的拥有者设置为当前线程
                exclusiveOwnerThread = Thread.currentThread();

                System.out.println(Thread.currentThread() + "  lock success ! set lock owner is current thread .  " +
                        "state：" + state);

                try {
                    // 睡眠一小会，模拟更加好的效果
                    Thread.sleep(100);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }

                // 跳出循环
                break;

            } else {
                // TODO 如果同步标志位是1，并且锁的拥有者是当前线程的话，则可以设置重入，但本方法暂未实现
                if (1 == state && Thread.currentThread() == exclusiveOwnerThread) {
                    // 进行设置重入锁
                }

                System.out.println(Thread.currentThread() + "  lock fail ! If the owner of the lock is the current thread," +
                        "  the reentrant lock needs to be set；else Adds the current thread to the blocking queue .");

                // 将线程阻塞，并将其放入阻塞队列
                parkThreadList.add(Thread.currentThread());
                LockSupport.park(this);

                // 线程被唤醒后会执行此处，并且继续执行此 while 循环
                System.out.println(Thread.currentThread() + "  The currently blocking thread is awakened !");
            }
        }
    }


    /**
     * 释放锁
     *
     * @return
     */
    public final boolean unlock() {
        if (Thread.currentThread() != exclusiveOwnerThread) {
            throw new IllegalMonitorStateException("Lock release failed !  The owner of the lock is not " +
                    "the current thread.");
        }
        // 将同步标志位设置为0，初始未加锁状态
        state = 0;
        // 将独占锁的拥有者设置为 null
        exclusiveOwnerThread = null;

        System.out.println(Thread.currentThread() + "  Release the lock successfully, and then wake up " +
                "the thread node in the blocking queue !  state：" + state);

        if (parkThreadList.size() > 0) {
            // 从阻塞列表中获取阻塞的线程
            Thread thread = parkThreadList.get(0);
            // 唤醒阻塞的线程
            LockSupport.unpark(thread);
            // 将唤醒的线程从阻塞列表中移除
            parkThreadList.remove(0);
        }

        return true;
    }


    /**
     * 使用CAS 安全的更新 同步标志位
     *
     * @param expect
     * @param update
     * @return
     */
    public final boolean compareAndSetState(int expect, int update) {
        return unsafe.compareAndSwapInt(this, stateOffset, expect, update);
    }

}
```

#### 测试运行

##### 测试代码

```java
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * @PACKAGE_NAME: com.lyl.thread6
 * @ClassName: SynCodeBlock
 * @Description: 简单的测试
 * @Date: 2021-01-15 10:26
 * @Author: [ 木子雷 ] 公众号
 **/
public class SynCodeBlock {


    public static void main(String[] args) {
        // 10 个线程的固定线程池
        ExecutorService logWorkerThreadPool = Executors.newFixedThreadPool(10);

        AqsUtil aqsUtil = new AqsUtil();

        int i = 10;
        while (i > 0) {
            logWorkerThreadPool.execute(new Runnable() {
                @Override
                public void run() {
                    test(aqsUtil);
                }
            });
            --i;
        }
    }


    public static void test(AqsUtil aqsUtil) {

        // 加锁
        aqsUtil.lock();

        try {
            System.out.println("正常的业务处理");
        } finally {
            // 释放锁
            aqsUtil.unlock();
        }
    }

}
```

##### 运行结果

```java
例如上面测试程序启动了10个线程同时执行同步代码块，可能此时只有线程 thread-2 获取到了锁，其余线程由于没有获取到锁被阻塞进入到了阻塞列表中；

当获取锁的线程释放了锁后，会唤醒阻塞列表中的线程，并且是按照进入列表的顺序被唤醒；此时被唤醒的线程会再次去尝试获取锁，如果此时有新线程同时尝试获取锁，那么此时也存在竞争了，这就是非公平方式抢占锁（不会按照申请锁的顺序获取锁）。
```

#### 扩展

上面的代码中没有实现线程自旋操作，下面看看该怎么实现呢？

##### 首先说说为什么需要自旋操作

因为在某些场景下，同步资源的锁定时间很短，如果没有获取到锁的线程，为了这点时间就进行阻塞的话，就有些得不偿失了；因为进入阻塞时会进行线程上下文的切换，这个消耗是很大的；

使线程进行自旋的话就很大可能会避免阻塞时的线程上下文切换的消耗；并且一般情况下都会设置一个线程自旋的次数，超过这个次数后，线程还未获取到锁的话，也要将其阻塞了，防止线程一直自旋下去白白浪费CPU资源。

##### 代码如下


![CAS](https://img-blog.csdnimg.cn/img_convert/fb5aac64d5cd89afbb18e3417718aa26.png)



### 参考

[根据AQS原理使用CAS + volatile实现同步代码块](https://blog.csdn.net/feichitianxia/article/details/112820488)