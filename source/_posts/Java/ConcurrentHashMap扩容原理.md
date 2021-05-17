---
title: ConcurrentHashMap扩容原理
author: Marlowe
tags:
  - 扩容
  - ConcurrentHashMap
categories: Java
abbrlink: 12001
date: 2021-05-17 16:56:14
---
ConcurrentHashMap从名称是可以看出，它是一个HashMap而且是线程安全的。在多线程编程中使用非常广泛。
ConcurrentHashMap的实现方式，在jdk6,7,8中都不一样。本文只针对jdk8中的实现作一些说明。
<!--more-->

### ConcurrentHashMap实现原理

 先来看看ConcurrentHashMap底层是发何实现的。总的来说，它是采用Node<K,V>类型(继承了Map.Entry)的数组table+单向链表+红黑树的结构。table数组的大小默认为16，数组中的每一项称为桶(bucket),桶中存放的是链表或者是红黑树结构，取决于链表的长度是否达到了阀值8（大于等于8）(默认)，如果是，接着再判断数组的长度是否小于64，如果小于则优先扩容table容量来解决单个桶中元素增多的问题，如果不是则转换成红黑树结构存放。

![ConcurrentHashMap](https://img-blog.csdnimg.cn/20190301235455454.png?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3hwc2FsbHdlbGw=,size_16,color_FFFFFF,t_70)

再次，我们看到ConcurrentHashMap类中，Unsafe类。说明线程安全的实现是基于CAS算法的无锁化修改值的操作，它可以大大降低锁带来的性能消耗。其基本思想是不停的去比较当前内存中的变量值与给定的值是否相同(值相等且引用也相等)，如果相同则修改成指定的值，否则什么也不做。这与乐观锁的思想类似。**缺点就是消耗CPU性能。**

```java
private static final sun.misc.Unsafe U;
U = sun.misc.Unsafe.getUnsafe();
 
static final <K,V> Node<K,V> tabAt(Node<K,V>[] tab, int i) {
    return (Node<K,V>)U.getObjectVolatile(tab, ((long)i << ASHIFT) + ABASE);
}
 
static final <K,V> boolean casTabAt(Node<K,V>[] tab, int i,
                                    Node<K,V> c, Node<K,V> v) {
    return U.compareAndSwapObject(tab, ((long)i << ASHIFT) + ABASE, c, v);
}
 
static final <K,V> void setTabAt(Node<K,V>[] tab, int i, Node<K,V> v) {
    U.putObjectVolatile(tab, ((long)i << ASHIFT) + ABASE, v);
}
```
### 源码分析

先来看看ConcurrentHashMap扩容是如何发生的，主要是在put一个KV时，如果达到某些阀值则会重新new一个nextTable其长度是原table的2倍。

```java
public V put(K key, V value) {
    return putVal(key, value, false);
}
 
/** Implementation for put and putIfAbsent */
//onlyIfAbsent的意思是在put一个KV时，如果K已经存在什么也不做则返回null
//如果不存在则put操作后返回V值
final V putVal(K key, V value, boolean onlyIfAbsent) {
    //ConcurrentHashMap中是不能有空K或空V的
    if (key == null || value == null) throw new NullPointerException();
    //hash算法得到hash值
    int hash = spread(key.hashCode());
    int binCount = 0;
    for (Node<K,V>[] tab = table;;) {
        Node<K,V> f; int n, i, fh;
        //如果table是空的，就去初始化，下一个循环就不是空的了
        if (tab == null || (n = tab.length) == 0)
            tab = initTable();
            //如果没有取到值，即取i位的元素是空的，为什么i取值是(n-1)&hash??
            //这是hash的精华所在，在这里可以先思考一下
            //此时直接到KV包装成Node节点放在i位置即可
        else if ((f = tabAt(tab, i = (n - 1) & hash)) == null) {
            if (casTabAt(tab, i, null,
                         new Node<K,V>(hash, key, value, null)))
                break;                   // no lock when adding to empty bin
        }
        //MOVED，定义为-1。标记原table正在执行扩容任务，可以去帮忙(支持多线程扩容)
        else if ((fh = f.hash) == MOVED)
            tab = helpTransfer(tab, f);
        else {
            //这种情况是，在i的位置找到了一个元素，说明此元素的K与之间的某个K的hash结果是一样的
            //
            V oldVal = null;
            synchronized (f) {//同步锁住第一个元素
                if (tabAt(tab, i) == f) {//为了安全起见，再一次判断
                    if (fh >= 0) {//节点的hash值大于0，说明是一个链表结构
                        binCount = 1;//记录链表的元素个数
                        for (Node<K,V> e = f;; ++binCount) {
                            K ek;
                            //判断给定的key是否与取出的key相同，如果是则替换元素
                            if (e.hash == hash &&
                                ((ek = e.key) == key ||
                                 (ek != null && key.equals(ek)))) {
                                oldVal = e.val;
                                if (!onlyIfAbsent)
                                    e.val = value;
                                break;//直接跳出，这是一种思想。在编程时可以减少一些if else判断
                            }
                            //否则就是不相等，那就把此元素放在链表的最后一个元素
                            Node<K,V> pred = e;
                            if ((e = e.next) == null) {
                                pred.next = new Node<K,V>(hash, key,
                                                          value, null);
                                break;
                            }
                        }
                    }
                    //如果不是链表，而是红黑树
                    else if (f instanceof TreeBin) {
                        Node<K,V> p;
                        binCount = 2;
                        //把元素放入树中的对应位置 
                        if ((p = ((TreeBin<K,V>)f).putTreeVal(hash, key,
                                                       value)) != null) {
                            oldVal = p.val;
                            if (!onlyIfAbsent)
                                p.val = value;
                        }
                    }
                }
            }
            if (binCount != 0) {
                //链表的元素大于等于8时，就把链表转换为红黑树
                if (binCount >= TREEIFY_THRESHOLD)
                    treeifyBin(tab, i);
                if (oldVal != null)
                    return oldVal;
                break;
            }
        }
    }
    //新添加一个元素，size加1，可能会触发扩容
    addCount(1L, binCount);
    return null;
}
```

**上面是对put操作的整个流程的分析，可以看出需要关注的几个点**

* hash算法及table下标i的计算方法
* 首次放元素时，initTable方法做了哪些事情
* 当前为正在扩容时help做了哪些操作？
* table中的元素有可能是链表结构，也有可能是红黑树结构
* 什么条件下会去执行链表转换成红黑树？

下面，我们先来看看链表转成红黑树的方法操作

```java
/**
 * Replaces all linked nodes in bin at given index unless table is
 * too small, in which case resizes instead.
 */
private final void treeifyBin(Node<K,V>[] tab, int index) {
    Node<K,V> b; int n, sc;
    if (tab != null) {
        //先判断table的长度是否小于64，如果小于，则优先使用扩容来解决问题
        if ((n = tab.length) < MIN_TREEIFY_CAPACITY)
        //扩容为原来的一位，调整某一个桶中元素过多的问题(超出了8个))
        //会触发某些桶中的元素重新分配，避免在一个桶中有太多的元素影响访问效率
            tryPresize(n << 1);
            
            //桶中存在结点，并且此结点的hash值大于0，调整红黑树的结构
        else if ((b = tabAt(tab, index)) != null && b.hash >= 0) {
            synchronized (b) {//锁住节点，把元素添加到树中
                if (tabAt(tab, index) == b) {
                    TreeNode<K,V> hd = null, tl = null;
                    for (Node<K,V> e = b; e != null; e = e.next) {
                        TreeNode<K,V> p =
                            new TreeNode<K,V>(e.hash, e.key, e.val,
                                              null, null);
                        if ((p.prev = tl) == null)
                            hd = p;
                        else
                            tl.next = p;
                        tl = p;
                    }
                    setTabAt(tab, index, new TreeBin<K,V>(hd));
                }
            }
        }
    }
}
```

还有一个就是addCount方法，这个方法在执行时，有可能会触发扩容操作

```java
private final void addCount(long x, int check) {
   ............省略无关代码.....
    if (check >= 0) {
        Node<K,V>[] tab, nt; int n, sc;
        while (s >= (long)(sc = sizeCtl) && (tab = table) != null &&
               (n = tab.length) < MAXIMUM_CAPACITY) {
            int rs = resizeStamp(n);
            if (sc < 0) {
                if ((sc >>> RESIZE_STAMP_SHIFT) != rs || sc == rs + 1 ||
                    sc == rs + MAX_RESIZERS || (nt = nextTable) == null ||
                    transferIndex <= 0)
                    break;
                if (U.compareAndSwapInt(this, SIZECTL, sc, sc + 1))
                    transfer(tab, nt);//可见是通过原子修改sizectl的值来判断是否需要扩容操作
            }
            else if (U.compareAndSwapInt(this, SIZECTL, sc,
                                         (rs << RESIZE_STAMP_SHIFT) + 2))
                transfer(tab, null);
            s = sumCount();
        }
    }
}
```

在多线的环境下，用volatile的方式读取sizectrl属性的值，来判断map所处的状态，通过cas修改操作来告诉其它线程Map的状态类型。不同的数值类型，代表着不同的状态：

* 未初始化
    * 等于0，表示未指定初始化容量，则使用默认容量
    * 大于0，为指定的初始化容量
* 初始化中
    * 等于-1，表示正在初始化，并且通过cas告诉其它线程
* 正常状态
    * 等于原table长度n*0.75，扩容阀值
* 扩容中
    * 小于0，表示有其他线程正在执行扩容操作
    * 等于(resizeStamp(n) << RESIZE_STAMP_SHIFT) + 2表示此时只有一个线程在执行扩容


接下来我们来看看扩容方法

```java
/**
 * Moves and/or copies the nodes in each bin to new table. See
 * above for explanation.
 */
private final void transfer(Node<K,V>[] tab, Node<K,V>[] nextTab) {
    int n = tab.length, stride;
    //取CPU的数量，确定每次迁移的Node的数量，确保不会少于MIN_TRANSFER_STRIDE=16个
    if ((stride = (NCPU > 1) ? (n >>> 3) / NCPU : n) < MIN_TRANSFER_STRIDE)
        stride = MIN_TRANSFER_STRIDE; // subdivide range
    if (nextTab == null) {            // initiating
        try {
            @SuppressWarnings("unchecked")
            //扩容一倍
            Node<K,V>[] nt = (Node<K,V>[])new Node<?,?>[n << 1];
            nextTab = nt;
        } catch (Throwable ex) {      // try to cope with OOME
            sizeCtl = Integer.MAX_VALUE;
            return;
        }
        nextTable = nextTab;
        //扩容索引，表示已经分配给扩容线程的table数组索引位置。
        //主要用来协调多个线程，安全地获取迁移"桶"。
        transferIndex = n;
    }
    int nextn = nextTab.length;
    //标记当前节点已经迁移完成，它的hash值是MOVED=-1
    ForwardingNode<K,V> fwd = new ForwardingNode<K,V>(nextTab);
    boolean advance = true;
    boolean finishing = false; // to ensure sweep before committing nextTab
   //1 逆序迁移已经获取到的hash桶集合，如果迁移完毕，则更新transferIndex，获取下一批待迁移的hash桶
   //2 如果transferIndex=0，表示所以hash桶均被分配，将i置为-1，准备退出transfer方法
     for (int i = 0, bound = 0;;) {
        Node<K,V> f; int fh;
        while (advance) {
            int nextIndex, nextBound;
            if (--i >= bound || finishing)
                advance = false;
            else if ((nextIndex = transferIndex) <= 0) {
                i = -1;
                advance = false;
            }
            else if (U.compareAndSwapInt
                     (this, TRANSFERINDEX, nextIndex,
                      nextBound = (nextIndex > stride ?
                                   nextIndex - stride : 0))) {
                bound = nextBound;
                i = nextIndex - 1;
                advance = false;
            }
        }
        if (i < 0 || i >= n || i + n >= nextn) {
            int sc;
            if (finishing) {
                nextTable = null;
                table = nextTab;
                sizeCtl = (n << 1) - (n >>> 1);
                return;
            }
            /**
             第一个扩容的线程，执行transfer方法之前，会设置 sizeCtl = (resizeStamp(n) << RESIZE_STAMP_SHIFT) + 2)
             后续帮其扩容的线程，执行transfer方法之前，会设置 sizeCtl = sizeCtl+1
             每一个退出transfer的方法的线程，退出之前，会设置 sizeCtl = sizeCtl-1
             那么最后一个线程退出时：
             必然有sc == (resizeStamp(n) << RESIZE_STAMP_SHIFT) + 2)，即 (sc - 2) == resizeStamp(n) << RESIZE_STAMP_SHIFT
            */
          //不相等，说明不到最后一个线程，直接退出transfer方法
 
            if (U.compareAndSwapInt(this, SIZECTL, sc = sizeCtl, sc - 1)) {
                if ((sc - 2) != resizeStamp(n) << RESIZE_STAMP_SHIFT)
                    return;
                finishing = advance = true;
                i = n; // recheck before commit
            }
        }
        else if ((f = tabAt(tab, i)) == null)
            advance = casTabAt(tab, i, null, fwd);
        else if ((fh = f.hash) == MOVED)
            advance = true; // already processed
        else {//开始迁移
            synchronized (f) {
                if (tabAt(tab, i) == f) {
                    Node<K,V> ln, hn;
                    //迁移链表，将node链表分成两个新的链表
                    if (fh >= 0) {
                        int runBit = fh & n;
                        Node<K,V> lastRun = f;
                        for (Node<K,V> p = f.next; p != null; p = p.next) {
                            int b = p.hash & n;//取桶中每个节点的hash值
                            if (b != runBit) {
                                runBit = b;
                                lastRun = p;
                            }
                        }
                        if (runBit == 0) {
                            ln = lastRun;
                            hn = null;
                        }
                        else {
                            hn = lastRun;
                            ln = null;
                        }
                        for (Node<K,V> p = f; p != lastRun; p = p.next) {
                            int ph = p.hash; K pk = p.key; V pv = p.val;
                            if ((ph & n) == 0)
                                ln = new Node<K,V>(ph, pk, pv, ln);
                            else
                                hn = new Node<K,V>(ph, pk, pv, hn);
                        }
                        //将node链表放在新的table对应的位置 
                        setTabAt(nextTab, i, ln);
                        setTabAt(nextTab, i + n, hn);
                        setTabAt(tab, i, fwd);
                        advance = true;
                    }
                    //迁移红黑树
                    else if (f instanceof TreeBin) {
                        TreeBin<K,V> t = (TreeBin<K,V>)f;
                        TreeNode<K,V> lo = null, loTail = null;
                        TreeNode<K,V> hi = null, hiTail = null;
                        int lc = 0, hc = 0;
                        for (Node<K,V> e = t.first; e != null; e = e.next) {
                            int h = e.hash;
                            TreeNode<K,V> p = new TreeNode<K,V>
                                (h, e.key, e.val, null, null);
                            if ((h & n) == 0) {
                                if ((p.prev = loTail) == null)
                                    lo = p;
                                else
                                    loTail.next = p;
                                loTail = p;
                                ++lc;
                            }
                            else {
                                if ((p.prev = hiTail) == null)
                                    hi = p;
                                else
                                    hiTail.next = p;
                                hiTail = p;
                                ++hc;
                            }
                        }
                        ln = (lc <= UNTREEIFY_THRESHOLD) ? untreeify(lo) :
                            (hc != 0) ? new TreeBin<K,V>(lo) : t;
                        hn = (hc <= UNTREEIFY_THRESHOLD) ? untreeify(hi) :
                            (lc != 0) ? new TreeBin<K,V>(hi) : t;
                        setTabAt(nextTab, i, ln);
                        setTabAt(nextTab, i + n, hn);
                        setTabAt(tab, i, fwd);
                        advance = true;
                    }
                }
            }
        }
    }
}
```

关于上面迁移链表的操作，比较有意思，我们来分析一下。还记得，在putVal方法有有一段代码

```java
else if ((f = tabAt(tab, i = (n - 1) & hash)) == null)
```

用于计算tab中元素的下标的，n就是tab的长度，只会是2的x次幂，先来熟悉一下&运算，它是指对应的二进制位上，如果都是1则结果为1，否则为0。假设现在，tab的长度为16，换成二进制就是10000，减1就是01111，取hash的值，这个值有点特别，就是从右起第x位(log以2为底的16)=4(从0开始数)。如果是10000&此数，则结果一定是0，例如：


```java
0000000000010000                0000000000001111
0101001000001001 结果为0         0101001000001001 结果是9，即i下标是9
```

如果此时tab扩容到32，也就是100000，再来看看(n-1)&hash的结果

```java
0000000000011111
0101001000001001 结果也是9，即i下标是9
```
说明，如果右起第x位为0的话，runbit==0成立，此时扩容到原来的2倍的话在新数组中的下标是不变的，所在可以看到把ln链表直接放到nextTable的i位了。

再来看看，右起第x位为1的情况

```java
0000000000010000                    0000000000001111
0101001000011001  结果为16不等于0     0101001000011001 结果是9，即i下标是9
```

如果此时扩容到了32，也就是100000时，再来看看(n-1)&hash的结果

```java
0000000000011111
0101001000011001 结果是16+8+1=25
```
即扩容后新下标变成了25，也就是原来的下标9再加扩容的量16，就是i+n的结果，所以对于hn来说在新table中的位置就变成了i+n了。

### 总结

通过代码我们可以看出，这里面的思想还是值得学习借鉴的。下标取(n-1)&hash并不是随便设计出来的，而是经过精心设计的。扩容后，桶的数量发生了变化，但无论是当前时刻使用的是新table还是扩容后的table访问的位置相对table长度来说都没有发生变化，为访问get提供便利。扩容时也不用重新计算hash值，同时结合多线程操作扩容提升操作效率。


### 参考

[ConcurrentHashMap扩容原理](https://blog.csdn.net/xpsallwell/article/details/88071038)















