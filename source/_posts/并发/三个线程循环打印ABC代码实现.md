---
title: 三个线程循环打印ABC代码实现
author: Marlowe
tags:
  - 并发
  - 线程
categories: 并发
abbrlink: 46791
date: 2021-05-16 21:06:06
---

三个线程分别打印A，B，C，要求这三个线程一起运行，打印n次，输出形如“ABCABCABC....”的字符串。

<!--more-->

### Semaphore

```java
package concurrent;

import java.util.concurrent.Semaphore;

public class PrintABCBySemaphore {

    private int times;
    private Semaphore semaphoreA =new Semaphore(1);
    private Semaphore semaphoreB =new Semaphore(0);
    private Semaphore semaphoreC =new Semaphore(0);

    public PrintABCBySemaphore(int times) {
        this.times=times;
    }


    public static void main(String[] args) {
        PrintABCBySemaphore printABCBySemaphore =new PrintABCBySemaphore(10);
        new Thread(printABCBySemaphore::printA).start();
        new Thread(printABCBySemaphore::printB).start();
        new Thread(printABCBySemaphore::printC).start();
    }
    public void printA() {
        print("A",semaphoreA,semaphoreB);
    }
    public void printB() {
        print("B",semaphoreB,semaphoreC);
    }
    public void printC() {
        print("C",semaphoreC,semaphoreA);
    }


    public void print(String name,Semaphore current,Semaphore next) {
        for(int i=0;i<times;i++) {
            try {
                current.acquire();
            } catch (InterruptedException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
            System.out.println(Thread.currentThread().getName() +":" + i+ " :" + name);
            next.release();
        }

    }
}
```

### Lock

```java
package concurrent;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class PrintABCByLock {

    private int times;
    private int state;
    private Lock lock =new ReentrantLock();

    public PrintABCByLock(int times) {
        this.times=times;
    }


    public static void main(String[] args) {
        PrintABCByLock printABC =new PrintABCByLock(10);
        new Thread(printABC::printA).start();
        new Thread(printABC::printB).start();
        new Thread(printABC::printC).start();
    }
    public void printA() {
        print("A",0);
    }
    public void printB() {
        print("B",1);
    }
    public void printC() {
        print("C",2);
    }

    public void print(String name,int stateNow) {
        for (int i = 0; i < times;) {
            lock.lock();
            if(stateNow == state % 3) {
                state++;
                i++;
                System.out.println(Thread.currentThread().getName()
                        + ":i=" + i + ":stateNow="+stateNow
                        + ":" +name);
            }
            lock.unlock();
        }
    }
}
```

### Condition

```java
package concurrent;

import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class PrintABCByLockCondition {

    public static void main(String[] args) {
        final Business business = new Business();

        new Thread(new Runnable() {

            @Override
            public void run() {
                for (int i = 0; i < 10; i++) {
                    business.sub2("B");
                }
            }
        }).start();

        new Thread(new Runnable() {
            @Override
            public void run() {
                for (int i = 0; i < 10; i++) {
                    business.sub3("C");
                }
            }
        }).start();

        for (int i = 0; i < 10; i++) {
            business.sub1("A");
        }
    }
    static class Business {
        private int flag = 1;
        Lock lock = new ReentrantLock();
        Condition condition1 = lock.newCondition();
        Condition condition2 = lock.newCondition();
        Condition condition3 = lock.newCondition();

        public void sub1(String s) {
            lock.lock();
            try{
                while(flag != 1) {
                    condition1.await();
                }
                System.out.println("A线程输出" + s);
                flag = 2;
                condition2.signal();
            }catch (Exception e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }

        public void sub2(String s) {
            lock.lock();
            try{
                while(flag != 2) {
                    condition2.await();
                }
                System.out.println("B线程输出" + s);
                flag = 3;
                condition3.signal();
            }catch (Exception e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }

        public void sub3(String s) {
            lock.lock();
            try{
                while(flag != 3) {
                    condition3.await();
                }
                System.out.println("C线程输出" + s);
                flag = 1;
                condition1.signal();
            }catch (Exception e) {
                e.printStackTrace();
            } finally {
                lock.unlock();
            }
        }
    }
}
```


### 参考

[并发编程】如果让你用三个线程循环打印ABC，你有几种写法？](https://www.cnblogs.com/zendwang/p/java-concurrent-three-thread-print-abc.html)
