---
title: 简述ConcurrentLinkedQueue原理
author: Marlowe
tags: ConcurrentLinkedQueue
categories: Java
abbrlink: 33172
date: 2021-05-17 17:07:42
---

<!--more-->

### 简介

在并发编程中我们有时候需要使用线程安全的队列。如果我们要实现一个线程安全的队列有两种实现方式一种是使用阻塞算法，另一种是使用非阻塞算法。使用阻塞算法的队列可以用一个锁（入队和出队用同一把锁）或两个锁（入队和出队用不同的锁）等方式来实现，而非阻塞的实现方式则可以使用循环CAS的方式来实现，下面我们一起来研究下Doug Lea是如何使用非阻塞的方式来实现线程安全队列ConcurrentLinkedQueue的。

ConcurrentLinkedQueue是一个基于链接节点的无界线程安全队列，它采用先进先出的规则对节点进行排序，当我们添加一个元素的时候，它会添加到队列的尾部，当我们获取一个元素时，它会返回队列头部的元素。它采用了“wait－free”算法来实现，该算法在Michael & Scott算法上进行了一些修改。

ConcurrentLinkedQueue的类图如下：

![类图](https://img-blog.csdn.net/20180625103613871?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4MjkzNTY0/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

ConcurrentLinkedQueue由head节点和tail节点组成，每个节点（Node）由节点元素（item）和指向下一个节点的引用(next)组成，节点与节点之间就是通过这个next关联起来，从而组成一张链表结构的队列。


### ConcurrentLinkedQueue源码详解

我们前面介绍了，ConcurrentLinkedQueue的节点都是Node类型的：

```java
private static class Node<E> {
    volatile E item;
    volatile Node<E> next;
 
    Node(E item) {
        UNSAFE.putObject(this, itemOffset, item);
    }
 
    boolean casItem(E cmp, E val) {
        return UNSAFE.compareAndSwapObject(this, itemOffset, cmp, val);
    }
 
    void lazySetNext(Node<E> val) {
        UNSAFE.putOrderedObject(this, nextOffset, val);
    }
 
    boolean casNext(Node<E> cmp, Node<E> val) {
        return UNSAFE.compareAndSwapObject(this, nextOffset, cmp, val);
    }
 
    private static final sun.misc.Unsafe UNSAFE;
    private static final long itemOffset;
    private static final long nextOffset;
 
    static {
        try {
            UNSAFE = sun.misc.Unsafe.getUnsafe();
            Class<?> k = Node.class;
            itemOffset = UNSAFE.objectFieldOffset
                (k.getDeclaredField("item"));
            nextOffset = UNSAFE.objectFieldOffset
                (k.getDeclaredField("next"));
        } catch (Exception e) {
            throw new Error(e);
        }
    }
}
```
Node类也比较简单，不再解释，ConcurrentLinkedQueue类有下面两个构造方法：

```java
// 默认构造方法，head节点存储的元素为空，tail节点等于head节点
public ConcurrentLinkedQueue() {
    head = tail = new Node<E>(null);
}
 
// 根据其他集合来创建队列
public ConcurrentLinkedQueue(Collection<? extends E> c) {
    Node<E> h = null, t = null;
    // 遍历节点
    for (E e : c) {
        // 若节点为null，则直接抛出NullPointerException异常
        checkNotNull(e);
        Node<E> newNode = new Node<E>(e);
        if (h == null)
            h = t = newNode;
        else {
            t.lazySetNext(newNode);
            t = newNode;
        }
    }
    if (h == null)
        h = t = new Node<E>(null);
    head = h;
    tail = t;
}
```

默认情况下head节点存储的元素为空，tail节点等于head节点。

```java
head = tail = new Node<E>(null);
```

下面我们主要来看一下ConcurrentLinkedQueue的入队与出队操作。

### 入队操作

入队列就是将入队节点添加到队列的尾部。为了方便理解入队时队列的变化，以及head节点和tail节点的变化，每添加一个节点我就做了一个队列的快照图：

![入队操作](https://img-blog.csdn.net/20180625144049602?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4MjkzNTY0/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

上图所示的元素添加过程如下：

* **添加元素1：** 队列更新head节点的next节点为元素1节点。又因为tail节点默认情况下等于head节点，所以它们的next节点都指向元素1节点。
* **添加元素2：** 队列首先设置元素1节点的next节点为元素2节点，然后更新tail节点指向元素2节点。
* **添加元素3：** 设置tail节点的next节点为元素3节点。
* **添加元素4：** 设置元素3的next节点为元素4节点，然后将tail节点指向元素4节点。
入队操作主要做两件事情，第一是将入队节点设置成当前队列尾节点的下一个节点。第二是更新tail节点，如果tail节点的next节点不为空，则将入队节点设置成tail节点，如果tail节点的next节点为空，则将入队节点设置成tail的next节点，所以tail节点不总是尾节点，理解这一点很重要。

上面的分析让我们从单线程入队的角度来理解入队过程，但是多个线程同时进行入队情况就变得更加复杂，因为可能会出现其他线程插队的情况。如果有一个线程正在入队，那么它必须先获取尾节点，然后设置尾节点的下一个节点为入队节点，但这时可能有另外一个线程插队了，那么队列的尾节点就会发生变化，这时当前线程要暂停入队操作，然后重新获取尾节点。

下面我们来看ConcurrentLinkedQueue的add(E e)入队方法：

```java
public boolean add(E e) {
    return offer(e);
}
 
public boolean offer(E e) {
    // 如果e为null，则直接抛出NullPointerException异常
    checkNotNull(e);
    // 创建入队节点
    final Node<E> newNode = new Node<E>(e);
 
    // 循环CAS直到入队成功
    // 1、根据tail节点定位出尾节点（last node）；2、将新节点置为尾节点的下一个节点；3、casTail更新尾节点
    for (Node<E> t = tail, p = t;;) {
        // p用来表示队列的尾节点，初始情况下等于tail节点
        // q是p的next节点
        Node<E> q = p.next;
        // 判断p是不是尾节点，tail节点不一定是尾节点，判断是不是尾节点的依据是该节点的next是不是null
        // 如果p是尾节点
        if (q == null) {
            // p is last node
            // 设置p节点的下一个节点为新节点，设置成功则casNext返回true；否则返回false，说明有其他线程更新过尾节点
            if (p.casNext(null, newNode)) {
                // Successful CAS is the linearization point
                // for e to become an element of this queue,
                // and for newNode to become "live".
                // 如果p != t，则将入队节点设置成tail节点，更新失败了也没关系，因为失败了表示有其他线程成功更新了tail节点
                if (p != t) // hop two nodes at a time
                    casTail(t, newNode);  // Failure is OK.
                return true;
            }
            // Lost CAS race to another thread; re-read next
        }
        // 多线程操作时候，由于poll时候会把旧的head变为自引用，然后将head的next设置为新的head
        // 所以这里需要重新找新的head，因为新的head后面的节点才是激活的节点
        else if (p == q)
            // We have fallen off list.  If tail is unchanged, it
            // will also be off-list, in which case we need to
            // jump to head, from which all live nodes are always
            // reachable.  Else the new tail is a better bet.
            p = (t != (t = tail)) ? t : head;
        // 寻找尾节点
        else
            // Check for tail updates after two hops.
            p = (p != t && t != (t = tail)) ? t : q;
    }
}
```

从源代码角度来看整个入队过程主要做两件事情：

* 第一是定位出尾节点
* 第二是使用CAS算法能将入队节点设置成尾节点的next节点，如不成功则重试。

第一步定位尾节点。tail节点并不总是尾节点，所以每次入队都必须先通过tail节点来找到尾节点，尾节点可能就是tail节点，也可能是tail节点的next节点。代码中循环体中的第一个if就是判断tail是否有next节点，有则表示next节点可能是尾节点。获取tail节点的next节点需要注意的是p节点等于q节点的情况，出现这种情况的原因我们后续再来介绍。

第二步设置入队节点为尾节点。p.casNext(null, newNode)方法用于将入队节点设置为当前队列尾节点的next节点，q如果是null表示p是当前队列的尾节点，如果不为null表示有其他线程更新了尾节点，则需要重新获取当前队列的尾节点。

#### tail节点不一定为尾节点的设计意图

对于先进先出的队列入队所要做的事情就是将入队节点设置成尾节点，doug lea写的代码和逻辑还是稍微有点复杂。那么我用以下方式来实现行不行？

```java
public boolean offer(E e) {
    checkNotNull(e);
    final Node<E> newNode = new Node<E>(e);
    
    for (;;) {
        Node<E> t = tail;
        
        if (t.casNext(null ,newNode) && casTail(t, newNode)) {
            return true;
        }
    }
}
```

让tail节点永远作为队列的尾节点，这样实现代码量非常少，而且逻辑非常清楚和易懂。但是这么做有个缺点就是每次都需要使用循环CAS更新tail节点。如果能减少CAS更新tail节点的次数，就能提高入队的效率。

在JDK 1.7的实现中，doug lea使用hops变量来控制并减少tail节点的更新频率，并不是每次节点入队后都将 tail节点更新成尾节点，而是当tail节点和尾节点的距离大于等于常量HOPS的值（默认等于1）时才更新tail节点，tail和尾节点的距离越长使用CAS更新tail节点的次数就会越少，但是距离越长带来的负面效果就是每次入队时定位尾节点的时间就越长，因为循环体需要多循环一次来定位出尾节点，但是这样仍然能提高入队的效率，因为从本质上来看它通过增加对volatile变量的读操作来减少了对volatile变量的写操作，而对volatile变量的写操作开销要远远大于读操作，所以入队效率会有所提升。

在JDK 1.8的实现中，tail的更新时机是通过p和t是否相等来判断的，其实现结果和JDK 1.7相同，即当tail节点和尾节点的距离大于等于1时，更新tail。

ConcurrentLinkedQueue的入队操作整体逻辑如下图所示：

![入队操作](https://img-blog.csdn.net/20180625162704934?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4MjkzNTY0/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)


### 出队操作

出队列的就是从队列里返回一个节点元素，并清空该节点对元素的引用。让我们通过每个节点出队的快照来观察下head节点的变化：

![出队操作](https://img-blog.csdn.net/20180625144156632?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4MjkzNTY0/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

从上图可知，并不是每次出队时都更新head节点，当head节点里有元素时，直接弹出head节点里的元素，而不会更新head节点。只有当head节点里没有元素时，出队操作才会更新head节点。采用这种方式也是为了减少使用CAS更新head节点的消耗，从而提高出队效率。让我们再通过源码来深入分析下出队过程。

```java
public E poll() {
    restartFromHead:
    for (;;) {
        // p节点表示首节点，即需要出队的节点
        for (Node<E> h = head, p = h, q;;) {
            E item = p.item;
 
            // 如果p节点的元素不为null，则通过CAS来设置p节点引用的元素为null，如果成功则返回p节点的元素
            if (item != null && p.casItem(item, null)) {
                // Successful CAS is the linearization point
                // for item to be removed from this queue.
                // 如果p != h，则更新head
                if (p != h) // hop two nodes at a time
                    updateHead(h, ((q = p.next) != null) ? q : p);
                return item;
            }
            // 如果头节点的元素为空或头节点发生了变化，这说明头节点已经被另外一个线程修改了。
            // 那么获取p节点的下一个节点，如果p节点的下一节点为null，则表明队列已经空了
            else if ((q = p.next) == null) {
                // 更新头结点
                updateHead(h, p);
                return null;
            }
            // p == q，则使用新的head重新开始
            else if (p == q)
                continue restartFromHead;
            // 如果下一个元素不为空，则将头节点的下一个节点设置成头节点
            else
                p = q;
        }
    }
}
```
该方法的主要逻辑就是首先获取头节点的元素，然后判断头节点元素是否为空，如果为空，表示另外一个线程已经进行了一次出队操作将该节点的元素取走，如果不为空，则使用CAS的方式将头节点的引用设置成null，如果CAS成功，则直接返回头节点的元素，如果不成功，表示另外一个线程已经进行了一次出队操作更新了head节点，导致元素发生了变化，需要重新获取头节点。

在入队和出队操作中，都有p == q的情况，那这种情况是怎么出现的呢？我们来看这样一种操作：

![队列操作](https://img-blog.csdn.net/20180625154414464?watermark/2/text/aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3FxXzM4MjkzNTY0/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70)

在弹出一个节点之后，tail节点有一条指向自己的虚线，这是什么意思呢？我们来看poll()方法，在该方法中，移除元素之后，会调用updateHead方法：

```java
final void updateHead(Node<E> h, Node<E> p) {
    if (h != p && casHead(h, p))
        // 将旧的头结点h的next域指向为h
        h.lazySetNext(h);
}
```

我们可以看到，在更新完head之后，会将旧的头结点h的next域指向为h，上图中所示的虚线也就表示这个节点的自引用。

如果这时，再有一个线程来添加元素，通过tail获取的next节点则仍然是它本身，这就出现了p == q的情况，出现该种情况之后，则会触发执行head的更新，将p节点重新指向为head，所有“活着”的节点（指未删除节点），都能从head通过遍历可达，这样就能通过head成功获取到尾节点，然后添加元素了。

### 其他相关方法


#### peek()方法

```java
// 获取链表的首部元素（只读取而不移除）
public E peek() {
    restartFromHead:
    for (;;) {
        for (Node<E> h = head, p = h, q;;) {
            E item = p.item;
            if (item != null || (q = p.next) == null) {
                updateHead(h, p);
                return item;
            }
            else if (p == q)
                continue restartFromHead;
            else
                p = q;
        }
    }
}
```
从源码中可以看到，peek操作会改变head指向，执行peek()方法后head会指向第一个具有非空元素的节点。

#### size()方法

```java
public int size() {
    int count = 0;
    // first()获取第一个具有非空元素的节点，若不存在，返回null
    // succ(p)方法获取p的后继节点，若p == p的后继节点，则返回head
    for (Node<E> p = first(); p != null; p = succ(p))
        if (p.item != null)
            // Collection.size() spec says to max out
            // 最大返回Integer.MAX_VALUE
            if (++count == Integer.MAX_VALUE)
                break;
    return count;
}
```
size()方法用来获取当前队列的元素个数，但在并发环境中，其结果可能不精确，因为整个过程都没有加锁，所以从调用size方法到返回结果期间有可能增删元素，导致统计的元素个数不精确。

#### remove(Object o)方法

```java
public boolean remove(Object o) {
    // 删除的元素不能为null
    if (o != null) {
        Node<E> next, pred = null;
 
        for (Node<E> p = first(); p != null; pred = p, p = next) {
            boolean removed = false;
            E item = p.item;
 
            // 节点元素不为null
            if (item != null) {
                // 若不匹配，则获取next节点继续匹配
                if (!o.equals(item)) {
                    next = succ(p);
                    continue;
                }
 
                // 若匹配，则通过CAS操作将对应节点元素置为null
                removed = p.casItem(item, null);
            }
 
            // 获取删除节点的后继节点
            next = succ(p);
            // 将被删除的节点移除队列
            if (pred != null && next != null) // unlink
                pred.casNext(p, next);
            if (removed)
                return true;
        }
    }
    return false;
}
```

#### contains(Object o)方法

```java
public boolean contains(Object o) {
    if (o == null) return false;
 
    // 遍历队列
    for (Node<E> p = first(); p != null; p = succ(p)) {
        E item = p.item;
        // 若找到匹配节点，则返回true
        if (item != null && o.equals(item))
            return true;
    }
    return false;
}
```

该方法和size方法类似，有可能返回错误结果，比如调用该方法时，元素还在队列里面，但是遍历过程中，该元素被删除了，那么就会返回false。

### 总结

ConcurrentLinkedQueue 的非阻塞算法实现可概括为下面 5 点：

* 使用 CAS 原子指令来处理对数据的并发访问，这是非阻塞算法得以实现的基础。
* head/tail 并非总是指向队列的头 / 尾节点，也就是说允许队列处于不一致状态。 这个特性把入队 / 出队时，原本需要一起原子化执行的两个步骤分离开来，从而缩小了入队 / 出队时需要原子化更新值的范围到唯一变量。这是非阻塞算法得以实现的关键。
* 由于队列有时会处于不一致状态。为此，ConcurrentLinkedQueue 使用三个不变式来维护非阻塞算法的正确性。
* 以批处理方式来更新 head/tail，从整体上减少入队 / 出队操作的开销。
* 为了有利于垃圾收集，队列使用特有的 head 更新机制；为了确保从已删除节点向后遍历，可到达所有的非删除节点，队列使用了特有的向后推进策略。

### 参考

[Java并发编程之ConcurrentLinkedQueue详解](https://blog.csdn.net/qq_38293564/article/details/80798310)