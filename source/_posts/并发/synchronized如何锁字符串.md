---
title: synchronized如何锁字符串?
author: Marlowe
tags:
  - synchronized
  - 字符串
  - intern
categories: 并发
abbrlink: 45266
date: 2021-09-03 21:10:08
---

记录一下synchronized锁字符串的问题，以及解决方案。
<!--more-->

### 一、问题阐述

在日常项目中可能存在需要防止用户数据并发操作的问题，需要对代码块加锁保护。例如：用户输入存数据库，重复数据不存DB；用户操作缓存数据等，这里想尽可能把锁的对象放小，因此通常都是锁用户而不是锁整个类或者代码块；然而在用synchronized(userId)的时候可能会存在一些问题。

### 二、synchronized 锁字符串的问题

使用synchronized 锁字符串存在的问题，下面示例锁一个字符串。

```java
public class ThreadTest implements Runnable{

    @Override
    public void run(){
        String threadName = Thread.currentThread().getName();
        synchronized (threadName) {
            //线程进入
            System.out.println(threadName + " thread start");
            try {
                //进入后睡眠
                Thread.sleep(1000);
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
            //线程结束
            System.out.println(threadName + " thread end");
        }
    }

    public static void main(String[] args) {
        for (int i = 0; i < 3; i++) {
            Thread thread = new Thread(new ThreadTest(), "dd");
            thread.start();
        }
    }

}
```

运行结果如下

```
dd thread start
dd thread start
dd thread start
dd thread end
dd thread end
dd thread end
```

可以发现还是并发执行了，因为synchronized (name)锁的对象不是同一个，仅仅是值相等，此时的字符串是在堆栈中。将代码修改为如下:

```java
public static void main(String[] args) {
        for (int i = 0; i < 3; i++) {
            String name = "dd";
            Thread thread = new Thread(new ThreadTest(), name);
            thread.start();
        }
    }
```

或者在修改锁的内容为synchronized (threadName.intern())，得到运行结果为:

通过上面结果可以看出此时synchronized 可以锁住字符串了，由此可以得出我们日常中如果通过锁字符串对象的方式是锁不住字符串。因此字符串对象不是同一个地址，因此如果想要锁住用户ID，需要把用户ID添加到字符串常量池中。如果通过User user = new User()的方式锁user.getUserId()是无法有效锁住用户的。

看下下面的例子:

```java
public static void main(String[] args) {
        String name = "a";
        String nameObj = new String("a");

        System.out.println(name.equals(nameObj));
        System.out.println(name == nameObj);
        System.out.println(name == nameObj.intern());
}
```

运行结果为:

```
true
false
true
```

通过上面的结果可以看出，name字符串常量和nameObj字符串对象的值相等，地址不同。通过new的对象是在堆栈中，字符串常量是存放在常量池中，通过nameObj.intern()把字符串对象放入常量池中，则地址是同一个。

### 三、synchronized 锁字符串用String的intern()存在的问题

通过上面的demo可以得出，使用synchronized 锁字符串，需要将字符串添加到字符串常量池中。日常使用中通过通过new对象的方式创建对象，再取对象的字段，因此需要使用intern把字符串放入常量池中，但是直接使用String的intern全部把字符串放入常量池会存在一些问题。显然在数据量很大的情况下，将所有字符串都放入常量池是不合理的，常量池大小依赖服务器内存，且只有等待fullGC，极端情况下会导致频繁fullGC。并且在数据量很大的情况下，将字符串放入常量是存在性能问题。

可以用google的guava包的interner类:

```java
Interner<String> interner = Interners.newWeakInterner();
interner.intern(userId);
```

看下具体的intern()实现源码

```java
@Override
    public E intern(E sample) {
      while (true) {
        // trying to read the canonical...
        InternalEntry<E, Dummy, ?> entry = map.getEntry(sample);
        if (entry != null) {
          E canonical = entry.getKey();
          if (canonical != null) { // only matters if weak/soft keys are used
            return canonical;
          }
        }

        // didn't see it, trying to put it instead...
        Dummy sneaky = map.putIfAbsent(sample, Dummy.VALUE);
        if (sneaky == null) {
          return sample;
        } else {
          /* Someone beat us to it! Trying again...
           *
           * Technically this loop not guaranteed to terminate, so theoretically (extremely
           * unlikely) this thread might starve, but even then, there is always going to be another
           * thread doing progress here.
           */
        }
      }
    }
  }
```

主要看下 putIfAbsent方法:

```java
  @CanIgnoreReturnValue
  @Override
  public V putIfAbsent(K key, V value) {
    checkNotNull(key);
    checkNotNull(value);
    int hash = hash(key);
    return segmentFor(hash).put(key, hash, value, true);
  }
```

Interner类的InternerBuilder

```java
public static class InternerBuilder {
    private final MapMaker mapMaker = new MapMaker();
    private boolean strong = true;

    private InternerBuilder() {}

    /**
     * Instructs the {@link InternerBuilder} to build a strong interner.
     *
     * @see Interners#newStrongInterner()
     */
    public InternerBuilder strong() {
      this.strong = true;
      return this;
    }

    /**
     * Instructs the {@link InternerBuilder} to build a weak interner.
     *
     * @see Interners#newWeakInterner()
     */
    @GwtIncompatible("java.lang.ref.WeakReference")
    public InternerBuilder weak() {
      this.strong = false;
      return this;
    }

    /**
     * Sets the concurrency level that will be used by the to-be-built {@link Interner}.
     *
     * @see MapMaker#concurrencyLevel(int)
     */
    public InternerBuilder concurrencyLevel(int concurrencyLevel) {
      this.mapMaker.concurrencyLevel(concurrencyLevel);
      return this;
    }

    public <E> Interner<E> build() {
      if (!strong) {
        mapMaker.weakKeys();
      }
      return new InternerImpl<E>(mapMaker);
    }
  }
```

Interner是通过MapMaker构造ConcurrentMap来实现弱引用，ConcurrentMap用分段的方式保证安全。这里个人觉得比常量池的优点就在于这里是弱引用的方式，便于map的回收，常量池只能依赖于fullGC，这里的回收在不使用或内存不够用条件下即可被回收（Minor GC阶段）。

### 参考

[synchronized锁字符串存在的问题以及intern常量池基础问题](https://www.codeleading.com/article/98393243662/)








