---
title: Lock类相关知识点
author: Marlowe
tags: Lock
categories: 并发
abbrlink: 64142
date: 2021-07-28 00:25:18
---

之前已经说道，JVM提供了synchronized关键字来实现对变量的同步访问以及用wait和notify来实现线程间通信。在jdk1.5以后，JAVA提供了Lock类来实现和synchronized一样的功能，并且还提供了Condition来显示线程间通信。
Lock类是Java类来提供的功能，丰富的api使得Lock类的同步功能比synchronized的同步更强大。

<!--more-->

### 1、Lock类

Lock类实际上是一个接口，我们在实例化的时候实际上是实例化实现了该接口的类Lock lock = new ReentrantLock();。用synchronized的时候，synchronized可以修饰方法，或者对一段代码块进行同步处理。

前面讲过，针对需要同步处理的代码设置对象监视器，比整个方法用synchronized修饰要好。Lock类的用法也是这样，通过Lock对象lock，用lock.lock来加锁，用lock.unlock来释放锁。在两者中间放置需要同步处理的代码。

具体的例子如下：

```java
public class MyConditionService {

    private Lock lock = new ReentrantLock();
    public void testMethod(){
        lock.lock();
        for (int i = 0 ;i < 5;i++){
            System.out.println("ThreadName = " + Thread.currentThread().getName() + (" " + (i + 1)));
        }
        lock.unlock();
    }
}
```

测试的代码如下：

```java
MyConditionService service = new MyConditionService();
    new Thread(service::testMethod).start();
    new Thread(service::testMethod).start();
    new Thread(service::testMethod).start();
    new Thread(service::testMethod).start();
    new Thread(service::testMethod).start();

    Thread.sleep(1000 * 5);
```

结果太长就不放出来，具体可以看我源码。总之，就是每个线程的打印1-5都是同步进行，顺序没有乱。

通过下面的例子，可以看出Lock对象加锁的时候也是一个对象锁，持续对象监视器的线程才能执行同步代码，其他线程只能等待该线程释放对象监视器。

```java
public class MyConditionMoreService {

    private Lock lock = new ReentrantLock();
    public void methodA(){
        try{
            lock.lock();
            System.out.println("methodA begin ThreadName=" + Thread.currentThread().getName() +
                    " time=" + System.currentTimeMillis());
            Thread.sleep(1000 * 5);

            System.out.println("methodA end ThreadName=" + Thread.currentThread().getName() +
                    " time=" + System.currentTimeMillis());
        }catch (Exception e){
            e.printStackTrace();
        }finally {
            lock.unlock();
        }
    }

    public void methodB(){
        try{
            lock.lock();
            System.out.println("methodB begin ThreadName=" + Thread.currentThread().getName() +
                    " time=" + System.currentTimeMillis());
            Thread.sleep(1000 * 5);

            System.out.println("methodB end ThreadName=" + Thread.currentThread().getName() +
                    " time=" + System.currentTimeMillis());
        }catch (Exception e){
            e.printStackTrace();
        }finally {
            lock.unlock();
        }
    }
}
```

测试代码如下：

```java
public void testMethod() throws Exception {
        MyConditionMoreService service = new MyConditionMoreService();
        ThreadA a = new ThreadA(service);
        a.setName("A");
        a.start();

        ThreadA aa = new ThreadA(service);
        aa.setName("AA");
        aa.start();

        ThreadB b = new ThreadB(service);
        b.setName("B");
        b.start();

        ThreadB bb = new ThreadB(service);
        bb.setName("BB");
        bb.start();

        Thread.sleep(1000 * 30);
    }
    
public class ThreadA extends Thread{

    private MyConditionMoreService service;

    public ThreadA(MyConditionMoreService service){
        this.service = service;
    }

    @Override
    public void run() {
        service.methodA();
    }
}

public class ThreadB extends Thread{

    private MyConditionMoreService service;

    public ThreadB(MyConditionMoreService service){
        this.service = service;
    }

    @Override
    public void run() {
        super.run();
        service.methodB();
    }
}
```

结果如下：

```java
methodA begin ThreadName=A time=1485590913520
methodA end ThreadName=A time=1485590918522
methodA begin ThreadName=AA time=1485590918522
methodA end ThreadName=AA time=1485590923525
methodB begin ThreadName=B time=1485590923525
methodB end ThreadName=B time=1485590928528
methodB begin ThreadName=BB time=1485590928529
methodB end ThreadName=BB time=1485590933533
```

可以看出Lock类加锁确实是对象锁。针对同一个lock对象执行的lock.lock是获得对象监视器的线程才能执行同步代码 其他线程都要等待。

在这个例子中，加锁，和释放锁都是在try-finally。这样的好处是在任何异常发生的情况下，都能保障锁的释放。

### 2、Lock类其他功能

如果Lock类只有lock和unlock方法也太简单了，Lock类提供了丰富的加锁的方法和对加锁的情况判断。主要有:

* 实现锁的公平
* 获取当前线程调用lock的次数，也就是获取当前线程锁定的个数
* 获取等待锁的线程数
* 查询指定的线程是否等待获取此锁定
* 查询是否有线程等待获取此锁定
* 查询当前线程是否持有锁定
* 判断一个锁是不是被线程持有
* 加锁时如果中断则不加锁，进入异常处理
* 尝试加锁，如果该锁未被其他线程持有的情况下成功

#### 实现公平锁

在实例化锁对象的时候，构造方法有2个，一个是无参构造方法，一个是传入一个boolean变量的构造方法。当传入值为true的时候，该锁为公平锁。默认不传参数是非公平锁。

> 公平锁：按照线程加锁的顺序来获取锁
非公平锁：随机竞争来得到锁
此外，JAVA还提供isFair()来判断一个锁是不是公平锁。

#### 获取当前线程锁定的个数

Java提供了getHoldCount()方法来获取当前线程的锁定个数。所谓锁定个数就是当前线程调用lock方法的次数。一般一个方法只会调用一个lock方法，但是有可能在同步代码中还有调用了别的方法，那个方法内部有同步代码。这样，getHoldCount()返回值就是大于1。

#### 下面的方法用来判断等待锁的情况

##### 获取等待锁的线程数
Java提供了getQueueLength()方法来得到等待锁释放的线程的个数。

##### 查询指定的线程是否等待获取此锁定
Java提供了hasQueuedThread(Thread thread)查询该Thread是否等待该lock对象的释放。

##### 查询是否有线程等待获取此锁定
同样，Java提供了一个简单判断是否有线程在等待锁释放即hasQueuedThreads()。

#### 下面的方法用来判断持有锁的情况

##### 查询当前线程是否持有锁定

Java不仅提供了判断是否有线程在等待锁释放的方法，还提供了是否当前线程持有锁即isHeldByCurrentThread()，判断当前线程是否有此锁定。

##### 判断一个锁是不是被线程持有

同样，Java提供了简单判断一个锁是不是被一个线程持有，即isLocked()

#### 下面的方法用来实现多种方式加锁

##### 加锁时如果中断则不加锁，进入异常处理

Lock类提供了多种选择的加锁方法，lockInterruptibly()也可以实现加锁，但是当线程被中断的时候，就会加锁失败，进行异常处理阶段。一般这种情况出现在该线程已经被打上interrupted的标记了。

##### 尝试加锁，如果该锁未被其他线程持有的情况下成功

Java提供了tryLock()方法来进行尝试加锁，只有该锁未被其他线程持有的基础上，才会成功加锁。

上面介绍了Lock类来实现代码的同步处理，下面介绍Condition类来实现wait/notify机制。

### 3、参考

[Java多线程基础——Lock类](https://www.cnblogs.com/qifengshi/p/6354890.html)