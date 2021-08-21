---
title: '多线程之间按顺序调用，实现 A-> B -> C 三个线程启动,AA打印5次，BB打印10次，CC打印15次'
author: Marlowe
tags:
  - 线程
  - Condition
categories: 并发
abbrlink: 56565
date: 2021-08-17 22:14:36
---

<!--more-->

### 实现场景

多线程之间按顺序调用，实现 A-> B -> C 三个线程启动，要求如下：
AA打印5次，BB打印10次，CC打印15次
紧接着
AA打印5次，BB打印10次，CC打印15次
…
来10轮

代码如下：

```java
package com.marlowe.demos;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * @program: JavaThreadDemo
 * @description: 锁绑定等多个条件Condition
 * 多线程之间按顺序调用，实现 A-> B -> C 三个线程启动，要求如下：
 * AA打印5次，BB打印10次，CC打印15次
 * 紧接着
 * AA打印5次，BB打印10次，CC打印15次
 * …
 * 来3轮
 * @author: Marlowe
 * @create: 2021-08-13 14:11
 **/
public class SyncAndReentrantLockDemo {
    public static void main(String[] args) {
        ShareResource shareResource = new ShareResource();
        int num = 3;
        new Thread(() -> {
            for (int i = 0; i < num; i++) {
                shareResource.print5();
            }
        }, "A").start();

        new Thread(() -> {
            for (int i = 0; i < num; i++) {
                shareResource.print10();
            }
        }, "B").start();

        new Thread(() -> {
            for (int i = 0; i < num; i++) {
                shareResource.print15();
            }
        }, "C").start();
    }
}


class ShareResource {
    /**
     * A:1  B:2 C:3
     */
    private int number = 1;

    /**
     * 创建一个可重入如锁
     */
    private Lock lock = new ReentrantLock();

    private Condition condition1 = lock.newCondition();
    private Condition condition2 = lock.newCondition();
    private Condition condition3 = lock.newCondition();

    public void print5() {
        lock.lock();
        try {
            // 判断
            while (number != 1) {
                // 不等于1，需要等待
                condition1.await();
            }
            // 干活
            for (int i = 0; i < 5; i++) {
                System.out.println(Thread.currentThread().getName() + "\t" + number + "\t" + i);
            }
            // 唤醒 （干完活后，需要通知C线程执行）
            number = 2;
            // 通知2号去干活了
            condition2.signal();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            lock.unlock();
        }
    }

    public void print10() {
        lock.lock();
        try {
            // 判断
            while (number != 2) {
                // 不等于2，需要等待
                condition2.await();
            }
            // 干活
            for (int i = 0; i < 10; i++) {
                System.out.println(Thread.currentThread().getName() + "\t" + number + "\t" + i);
            }
            // 唤醒 （干完活后，需要通知C线程执行）
            number = 3;
            // 通知3号去干活了
            condition3.signal();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            lock.unlock();
        }
    }


    public void print15() {
        lock.lock();
        try {
            // 判断
            while (number != 3) {
                // 不等于3，需要等待
                condition3.await();
            }
            // 干活
            for (int i = 0; i < 15; i++) {
                System.out.println(Thread.currentThread().getName() + "\t" + number + "\t" + i);
            }
            // 唤醒 （干完活后，需要通知C线程执行）
            number = 1;
            // 通知1号去干活了
            condition1.signal();
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            lock.unlock();
        }
    }

}
```

结果：

```
"D:\Program Files\Java\jdk1.8\bin\java.exe" "-javaagent:D:\Program Files\IntelliJ IDEA 2021.1.3\lib\idea_rt.jar=56930:D:\Program Files\IntelliJ IDEA 2021.1.3\bin" -Dfile.encoding=UTF-8 -classpath "D:\Program Files\Java\jdk1.8\jre\lib\charsets.jar;D:\Program Files\Java\jdk1.8\jre\lib\deploy.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\access-bridge-64.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\cldrdata.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\dnsns.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\jaccess.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\jfxrt.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\localedata.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\nashorn.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\sunec.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\sunjce_provider.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\sunmscapi.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\sunpkcs11.jar;D:\Program Files\Java\jdk1.8\jre\lib\ext\zipfs.jar;D:\Program Files\Java\jdk1.8\jre\lib\javaws.jar;D:\Program Files\Java\jdk1.8\jre\lib\jce.jar;D:\Program Files\Java\jdk1.8\jre\lib\jfr.jar;D:\Program Files\Java\jdk1.8\jre\lib\jfxswt.jar;D:\Program Files\Java\jdk1.8\jre\lib\jsse.jar;D:\Program Files\Java\jdk1.8\jre\lib\management-agent.jar;D:\Program Files\Java\jdk1.8\jre\lib\plugin.jar;D:\Program Files\Java\jdk1.8\jre\lib\resources.jar;D:\Program Files\Java\jdk1.8\jre\lib\rt.jar;D:\IDE_Project\JavaLearning\JavaThreadDemo\target\classes" com.marlowe.demos.SyncAndReentrantLockDemo
A	1	0
A	1	1
A	1	2
A	1	3
A	1	4
B	2	0
B	2	1
B	2	2
B	2	3
B	2	4
B	2	5
B	2	6
B	2	7
B	2	8
B	2	9
C	3	0
C	3	1
C	3	2
C	3	3
C	3	4
C	3	5
C	3	6
C	3	7
C	3	8
C	3	9
C	3	10
C	3	11
C	3	12
C	3	13
C	3	14
A	1	0
A	1	1
A	1	2
A	1	3
A	1	4
B	2	0
B	2	1
B	2	2
B	2	3
B	2	4
B	2	5
B	2	6
B	2	7
B	2	8
B	2	9
C	3	0
C	3	1
C	3	2
C	3	3
C	3	4
C	3	5
C	3	6
C	3	7
C	3	8
C	3	9
C	3	10
C	3	11
C	3	12
C	3	13
C	3	14
A	1	0
A	1	1
A	1	2
A	1	3
A	1	4
B	2	0
B	2	1
B	2	2
B	2	3
B	2	4
B	2	5
B	2	6
B	2	7
B	2	8
B	2	9
C	3	0
C	3	1
C	3	2
C	3	3
C	3	4
C	3	5
C	3	6
C	3	7
C	3	8
C	3	9
C	3	10
C	3	11
C	3	12
C	3	13
C	3	14

Process finished with exit code 0

```