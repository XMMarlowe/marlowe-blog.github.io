---
title: ThreadLocal原理和使用场景
author: Marlowe
tags: 线程
categories: 并发
abbrlink: 58836
date: 2021-03-10 15:31:01
---
每一个Thread对象均含有一个ThreadLocalMap类型的成员变量threadLocals,它存储本线程中所有ThreadLocal对象及其对应的值。
<!--more-->
### 简介

ThreadLocal保存当前线程的变量，当前线程内，可以任意获取，但每个线程往ThreadLocal中读写数据是线程隔离，互不影响。

**如果你创建了一个ThreadLocal变量，那么访问这个变量的每个线程都会有这个变量的本地副本，这也是ThreadLocal变量名的由来。他们可以使用 get（） 和 set（） 方法来获取默认值或将其值更改为当前线程所存的副本的值，从而避免了线程安全问题。**

```java
ThreadLocalMap源码：

static class Entry extends WeakReference<ThreadLocal<?>> {
            /** The value associated with this ThreadLocal. */
            Object value;

            Entry(ThreadLocal<?> k, Object v) {
                super(k);
                value = v;
            }
        }
```
`ThreadLocalMap`由一个个`Entry`对象构成
`Entry`继承自`WeakReference<ThreadLoca1<?>>`,一个`Entry`由`ThreadLocal`对象和`Object`构成。由此可见，`Entry` 的key是ThreadLocal对象,并且是一个弱引用。 当没指向key的强引用后, 该key就会被垃圾收集器回收。

**注意**

### ThreadLocal存在内存泄露

**强引用(StrongReference)：** 使用最普遍的引用(new),一个对象具有强引用，不会被GC回收。当JVM的内存空间不足时，宁愿抛出OutOfMemoryError使得程序异常终止也不愿意回收具有强引用的存活着的对象。
如果想取消强引用和某个对象之间的关联，可以显式的将引用赋值为null，这样可以是JVM在合适的时候回收该对象。

**弱引⽤(WeakReference)：** 在GC的时候，不管内存空间足不足都会回收这个对象。可以在缓存中使用弱引用。

当我们了解完，ThreadLocalMap 中使⽤的 key是以弱引用指向ThreadLocal，这时候垃圾回收器线程运行，发现弱引用就回收，key被回收。ThreadLocalMap里对应的Entry的key会变成null。这时候尴尬出现了，ThreadLocalMap里对应的Entry的value则无法被访问到，value作为一个强引用垃圾回收不到也不能被访问，即造成了内存溢出。

### ThreadLocal正确的使用方法(如何解决内存泄漏)

1. 在使用完ThreadLocal后，主动调用remove方法进行清理。
2. 将ThreadLocal变量定义成private static, 这样就一 直存在ThreadLocal的强引用，也就能保证任何时候都能通过ThreadLocal的弱引用访问到Entry的value值， 进而清除掉。



```java
ThreadLocal set()方法
public void set(T value) {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null)
            map.set(this, value);
        else
            createMap(t, value);
    }
```
当执行set方法时，ThreadLocal首先会获取当前线程对象，然后获取当前线程的ThreadLocalMap对象。再以当前ThreadLocal对象为key,将值存储进ThreadLocalMap对象中。



```java
ThreadLocal get()方法
public T get() {
        Thread t = Thread.currentThread();
        ThreadLocalMap map = getMap(t);
        if (map != null) {
            ThreadLocalMap.Entry e = map.getEntry(this);
            if (e != null) {
                @SuppressWarnings("unchecked")
                T result = (T)e.value;
                return result;
            }
        }
        return setInitialValue();
    }
```
get方法执行过程类似。ThreadLocal首先会获取当前线程对象,然后获取当前线程的ThreadLocalMap对象。再以当前ThreadLocal对象为key,获取对应的value。

由于每一条线程均含有各自私有的ThreadLocalMap容器，这些容器相互独立互不影响，因此不会存在线程安全性问题，从而也无需使用同步机制来保证多条线程访问容器的互斥性。




使用场景：
1、在进行对象跨层传递的时候，使用ThreadLocal可以避免多次传递，打破层次间的约束。
2、线程间数据隔离。
3、进行事务操作，用于存储线程事务信息。
4、数据库连接，Session会话管理。