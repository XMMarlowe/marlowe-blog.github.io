---
title: Java四种引用-强、软、弱、虚
author: Marlowe
tags: Java
categories: Java
abbrlink: 57806
date: 2021-05-21 22:28:04
---

<!--more-->

### Java的四种对象引用的基本概念

从JDK1.2版本开始，把对象的引用分为四种级别，从而使程序更加灵活的控制对象的生命周期。这四种级别由高到低依次为：强引用、软引用、弱引用和虚引用。

#### 1、强引用

`Object obj =new Object();`

上述Object这类对象就具有强引用，属于不可回收的资源，垃圾回收器绝不会回收它。当内存空间不足，Java虚拟机宁愿抛出OutOfMemoryError错误，使程序异常终止，也不会靠回收具有强引用的对象，来解决内存不足的问题。

值得注意的是：如果想中断或者回收强引用对象，可以显式地将引用赋值为null，这样的话JVM就会在合适的时间，进行垃圾回收。

下图是堆区的内存示意图，分为新生代，老生代，而垃圾回收主要也是在这部分区域中进行。

![20210521223039](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210521223039.png)

#### 2、软引用（SoftReference）

如果一个对象只具有软引用，那么它的性质属于可有可无的那种。如果此时内存空间足够，垃圾回收器就不会回收它，如果内存空间不足了，就会回收这些对象的内存。只要垃圾回收器没有回收它，该对象就可以被程序使用。

软引用可用来实现内存敏感的告诉缓存。软引用可以和一个引用队列联合使用，如果软件用所引用的对象被垃圾回收，Java虚拟机就会把这个软引用加入到与之关联的引用队列中。

```java
Object obj = new Object();
ReferenceQueue queue = new ReferenceQueue();
SoftReference reference = new SoftReference(obj, queue);
//强引用对象滞空，保留软引用
obj = null;
```

当内存不足时，软引用对象被回收时，reference.get()为null，此时软引用对象的作用已经发挥完毕，这时将其添加进**ReferenceQueue** 队列中

如果要判断哪些软引用对象已经被清理：

```java
SoftReference ref = null;
while ((ref = (SoftReference) queue.poll()) != null) {
    //清除软引用对象
}
```

#### 3、弱引用(WeakReference)

如果一个对象具有弱引用，那其的性质也是可有可无的状态。

而弱引用和软引用的区别在于：弱引用的对象拥有更短的生命周期，只要垃圾回收器扫描到它，不管内存空间充足与否，都会回收它的内存。

同样的弱引用也可以和引用队列一起使用。

```java
Object obj = new Object();
ReferenceQueue queue = new ReferenceQueue();
WeakReference reference = new WeakReference(obj, queue);
//强引用对象滞空，保留软引用
obj = null;
```

#### 4、虚引用（PhantomReference）

虚引用和前面的软引用、弱引用不同，它并不影响对象的生命周期。如果一个对象与虚引用关联，则跟没有引用与之关联一样，在任何时候都可能被垃圾回收器回收。

注意：虚引用必须和引用队列关联使用，当垃圾回收器准备回收一个对象时，如果发现它还有虚引用，就会把这个虚引用加入到与之关联的引用队列中。

程序可以通过判断引用队列中是否已经加入了虚引用，来了解被引用的对象是否将要被垃圾回收。如果程序发现某个虚引用已经被加入到引用队列，那么就可以在所引用的对象的内存被回收之前采取必要的行动。

```java
Object obj = new Object();
ReferenceQueue queue = new ReferenceQueue();
PhantomReference reference = new PhantomReference(obj, queue);
//强引用对象滞空，保留软引用
obj = null;
```

#### 引用总结

1. 对于强引用，平时在编写代码时会经常使用。

2. 而其他三种类型的引用，使用得最多就是软引用和弱引用，这两种既有相似之处又有区别，他们都来描述非必须对象。

3. 被软引用关联的对象只有在内存不足时才会被回收，而被弱引用关联的对象在JVM进行垃圾回收时总会被回收。

![20210521223329](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210521223329.png)

---


### 四种对象引用的差异对比

Java中4种引用的级别由高到低依次为：

> 强引用 > 软引用 > 弱引用 > 虚引用

垃圾回收时对比：

![20210521223423](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210521223423.png)

### 对象可及性的判断

在很多的时候，一个对象并不是从根集直接引用的，而是一个对象被其他对象引用，甚至同时被几个对象所引用，从而构成一个以根集为顶的树形结构。

![20210521223526](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210521223526.png)

在这个树形的引用链中，箭头的方向代表了引用的方向，所指向的对象是被引用对象。由图可以看出，从根集到一个对象可以由很多条路径。

比如到达对象5的路径就有① -> ⑤，③ ->⑦两条路径。由此带来了一个问题，那就是某个对象的可及性如何判断：

（1）单条引用路径可及性判断：

在这条路径中，最弱的一个引用决定对象的可及性。

（2）多条引用路径可及性判断：

几条路径中，最强的一条的引用决定对象的可及性。

比如，我们假设图2中引用①和③为强引用，⑤为软引用，⑦为弱引用，对于对象5按照这两个判断原则，路径①-⑤取最弱的引用⑤，因此该路径对对象5的引用为软引用。同样，③-⑦为弱引用。在这两条路径之间取最强的引用，于是对象5是一个软可及对象。

**比较容易理解的是Java垃圾回收器会优先清理可及强度低的对象**

另外两个重要的点：

**强可达的对象一定不会被清理**

**JVM保证抛出out of memory之前，清理所有的软引用对象**

最后总结成一张表格：

|引用类型|	被垃圾回收时间|	用途|	生存时间|
|:---:|:---:|:---:|:---:|
|强引用|	从来不会|	对象的一般状态|	JVM停止运行时终止|
|软引用|	在内存不足时|	对象缓存|	内存不足时终止|
|弱引用|	在垃圾回收时|	对象缓存|	垃圾回收时终止|
|虚引用|	Unkonwn|	Unkonwn|	Unkonwn|

### 引用队列ReferenceQueue的介绍

引用队列配合Reference的子类等使用,当引用对象所指向的对象被垃圾回收后,该Reference则被追加到引用队列的末尾.

#### ReferenceQueue源码分析(简要)

(1)ReferenceQueue是一个链表,这两个指针代表着头和尾

```java
private Reference<? extends T> head = null;
private Reference<? extends T> tail = null;
```

(2)下面看下其共有的方法

**取出元素:**

```java
Reference<? extends T> ReferenceQueue#poll()
```
如果Reference指向的对象存在则返回null,否则返回这个Reference

```java
public Reference<? extends T> poll() {
    synchronized (lock) {
        if (head == null)
            return null;

        return reallyPollLocked();
    }
}
```

下面是具体将Reference取出的方法:

```java
private Reference<? extends T> reallyPollLocked() {
    if (head != null) {
        Reference<? extends T> r = head;
        if (head == tail) {
            tail = null;
            head = null;
        } else {
            head = head.queueNext;
        }

        //更新链表,将sQueueNextUnenqueued这个虚引用对象加入,并且已经表明该Reference已经被移除了,并且取出.
        r.queueNext = sQueueNextUnenqueued;
        return r;
    }

    return null;
}
```

**取出元素,如果队列属于空队列,那么久阻塞到其有元素为止**

```java
Reference<? extends T> ReferenceQueue#remove()
```
和remove()的区别是,设置一个阻塞时间

```java
Reference<? extends T> ReferenceQueue#remove(long timeout)
```
具体实现

```java
public Reference<? extends T> remove(long timeout)
    throws IllegalArgumentException, InterruptedException
{
    if (timeout < 0) {
        throw new IllegalArgumentException("Negative timeout value");
    }
    synchronized (lock) {
        Reference<? extends T> r = reallyPollLocked();
        if (r != null) return r;
        long start = (timeout == 0) ? 0 : System.nanoTime();
        //阻塞的具体实现过程,以及通过时间来控制的阻塞
        for (;;) {
            lock.wait(timeout);
            r = reallyPollLocked();
            if (r != null) return r;
            if (timeout != 0) {
                long end = System.nanoTime();
                timeout -= (end - start) / 1000_000;
                if (timeout <= 0) return null;
                start = end;
            }
        }
    }
}
```

### WeakHashMap的相关介绍

在Java集合中有一种特殊的Map类型即WeakHashMap,在这种Map中存放了键对象的弱引用,当一个键对象被垃圾回收器回收时,那么相应的值对象的引用会从Map中删除.

WeakHashMap能够节约储存空间,可用来缓存那些非必须存在的数据.

而WeakHashMap是主要通过expungeStaleEntries()这个方法来实现的,而WeakHashMap也内置了一个ReferenceQueue,来获取键对象的引用情况.

这个方法,相当于遍历ReferenceQueue然后,将已经被回收的键对象,对应的值对象滞空.

```java
private void expungeStaleEntries() {
    for (Object x; (x = queue.poll()) != null; ) {
        synchronized (queue) {
            @SuppressWarnings("unchecked")
                Entry<K,V> e = (Entry<K,V>) x;
            int i = indexFor(e.hash, table.length);

            Entry<K,V> prev = table[i];
            Entry<K,V> p = prev;
            while (p != null) {
                Entry<K,V> next = p.next;
                if (p == e) {
                    if (prev == e)
                        table[i] = next;
                    else
                        prev.next = next;
                    // Must not null out e.next;
                    // stale entries may be in use by a HashIterator
                    //通过滞空,来帮助垃圾回收
                    e.value = null; 
                    size--;
                    break;
                }
                prev = p;
                p = next;
            }
        }
    }
}
```

而且需要注意的是:

expungeStaleEntries()并不是自动调用的,需要外部对WeakHashMap对象进行查询或者操作,才会进行自动释放的操作.如下我们看个例子:

下面例子是不断的增加1000*1000容量的WeakHashMap存入List中

```java
public static void main(String[] args) throws Exception {  

    List<WeakHashMap<byte[][], byte[][]>> maps = new ArrayList<WeakHashMap<byte[][], byte[][]>>();  

    for (int i = 0; i < 1000; i++) {  
        WeakHashMap<byte[][], byte[][]> d = new WeakHashMap<byte[][], byte[][]>();  
        d.put(new byte[1000][1000], new byte[1000][1000]);  
        maps.add(d);  
        System.gc();  
        System.err.println(i);  
    } 
}  
```
由于Java默认内存是64M，所以再不改变内存参数的情况下，该测试跑不了几步循环就内存溢出了。果不其然，WeakHashMap这个时候并没有自动帮我们释放不用的内存。

```java
public static void main(String[] args) throws Exception {  

        List<WeakHashMap<byte[][], byte[][]>> maps = new ArrayList<WeakHashMap<byte[][], byte[][]>>();  

        for (int i = 0; i < 1000; i++) {  
            WeakHashMap<byte[][], byte[][]> d = new WeakHashMap<byte[][], byte[][]>();  
            d.put(new byte[1000][1000], new byte[1000][1000]);  
            maps.add(d);  
            System.gc();  
            System.err.println(i);  

            for (int j = 0; j < i; j++) {  
                System.err.println(j+  " size" + maps.get(j).size());  
            }  
        }  
    }  
```

而通过访问WeakHashMap的size()方法,这些就可以跑通了.

这样就能够说明了WeakHashMap并不是自动进行键值的垃圾回收操作的,而需要做对WeakHashMap的访问操作这时候才进行对键对象的垃圾回收清理.

来一张总结图:

![20210521224224](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210521224224.png)

由图可以看出,WeakHashMap中只要调用其操作方法,那么就会调用其expungeStaleEntries().

### 参考

[Java四种引用---强、软、弱、虚的知识点总结](https://blog.csdn.net/l540675759/article/details/73733763)






