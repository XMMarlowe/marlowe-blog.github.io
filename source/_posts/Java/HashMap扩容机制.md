---
title: HashMap扩容机制
author: Marlowe
tags: HashMap
categories: Java
abbrlink: 49291
date: 2020-03-16 10:33:21
---
聊聊HashMap扩容机制
<!--more-->

### 1、什么时候才需要扩容

* 在首次调用put方法的时候，初始化数组table
* 当HashMap中的元素个数超过数组大小(数组长度)*loadFactor(负载因子)时，就会进行数组扩容，loadFactor的默认值(DEFAULT_LOAD_FACTOR)是0.75,这是一个折中的取值。也就是说，默认情况下，数组大小为16，那么当HashMap中的元素个数超过16×0.75=12(这个值就是阈值或者边界值threshold值)的时候，就把数组的大小扩展为2×16=32，即扩大一倍，然后重新计算每个元素在数组中的位置，而这是一个非常耗性能的操作，所以如果我们已经预知HashMap中元素的个数，那么预知元素的个数能够有效的提高HashMap的性能。
* 当HashMap中的其中一个链表的对象个数如果达到了8个，此时如果数组长度没有达到64，那么HashMap会先扩容解决，如果已经达到了64，那么这个链表会变成红黑树，节点类型由Node变成TreeNode类型。当然，如果映射关系被移除后，下次执行resize方法时判断树的节点个数低于6，也会再把树转换为链表。

#### 为什么选择长度为6的时候转回链表？

6和8，中间有个差值7可以有效防止链表和树频繁转换。假设一下，如果设计成链表个数超过8则链表转换成树结构，链表个数小于8则树结构转换成链表，如果一个HashMap不停的插入、删除元素，链表个数在8左右徘徊，就会频繁的发生树转链表、链表转树，效率会很低。

#### 什么是红黑树?
红黑树是一种自平衡的二叉查找树。
![20210316145248](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210316145248.png)

**性质：**

1. 节点是红色或黑色。

2. 根节点是黑色。

3. 每个叶子节点都是黑色的空节点（NIL节点）。

4. 每个红色节点的两个子节点都是黑色。(从每个叶子到根的所有路径上**不能有两个连续的红色节点**)

5. 从任一节点到其每个叶子的所有路径都包含相同数目的黑色节点。

根据上面的定义，可以推算出：

1. 因为黑色节点数量要一样，红色不能连着来，从而**路径全黑时最短，红黑交替时最长**。因此可以推算出：红黑树从根到叶子节点的最长的路径不会比于最短的路径的长超过两倍。红黑树是一种弱平衡二叉树，在相同的节点情况下，**AVL树的高度<=红黑树**。
2. 红黑树的高度最坏情况下为2log(N+1)。因此它也可以在O(log n)时间内做查找，插入和删除。

#### 红黑树相比于BST和AVL树有什么优点？

* 红黑树是**牺牲了严格的高度平衡的优越条件为代价**，它只要求**部分地达到平衡**要求，**降低了对旋转的要求**，从而提高了性能。红黑树能够以O(log2 n)的时间复杂度进行**搜索、插入、删除**操作。此外，由于它的设计，任何不平衡**都会在三次旋转之内**解决。当然，还有一些更好的，但实现起来更复杂的数据结构能够做到一步旋转之内达到平衡，但红黑树能够给我们一个比较“便宜”的解决方案。

* **相比于BST**，因为红黑树可以能**确保树的最长路径不大于两倍的最短路径的长度**，所以可以看出它的**查找效果是有最低保证的**。在最坏的情况下也可以保证O(logN)的，这是要好于二叉查找树的。**因为二叉查找树最坏情况可以让查找达到O(N)。**

* 红黑树的算法时间复杂度和AVL相同，**但AVL树搜索效率更高**，因为AVL是绝对平衡的，任意一个左右子树高度差小于等于1，所以在**插入和删除**中所做的后期维护操作肯定会**比红黑树要耗时好多**，但是他们的查找效率都是O(logN)，所以红黑树应用还是高于AVL树的. 实际上**插入 AVL 树和红黑树的速度取决于你所插入的数据.如果你的数据分布较好,则比较宜于采用 AVL树**(例如随机产生系列数),但是如果你想处理**比较杂乱的情况,则红黑树是比较快的**。

所以简单说，如果你的应用中，**搜索的次数远远大于插入和删除**，那么选择AVL，如果**搜索，插入删除次数几乎差不多**，应该选择红黑树。

#### 红黑树的应用

 红黑树是在1972年由Rudolf Bayer发明的，当时被称为平衡二叉B树（symmetric binary B-trees）。后来，在1978年被 Leo J. Guibas 和 Robert Sedgewick 修改为如今的“红黑树”。   实际上，Robert Sedgewick在《算法（第4版）》 中说过，红黑树等价于2-3树。其中2-节点等价于普通平衡二叉树的节点，3-节点本质上是非平衡性的缓存。   也就是说在添加、删除节点之后需要重平衡时，相当于2-节点 与3-节点间的转换，由于3-节点的缓存作用，能够吸收一部分不平衡性，从而减少旋转次数，减少重平衡时间。   尽管由于红黑树的最大高度高于AVL树导致此查询时稍慢，但是差距不大，而添加、删除数据时红黑树快于AVL树，红黑树的旋转次数为O(1)，即最多旋转3次；而AVL的旋转次数为O(logN)，即最多向上旋转至根节点。整体来看，红黑树的综合效率高于AVL树，红黑树比AVL树的应用范围更广泛！ 

**AVL的应用：**

Windows NT内核

**红黑树的应用：**

1. JDK1.8及之后版本的Map实现，比如HashMap、TreeMap。
2. 广泛用于C++的STL中,map和set都是用红黑树实现的.
3. 著名的linux进程调度Completely Fair Scheduler,用红黑树管理进程控制块,进程的虚拟内存区域都存储在一颗红黑树上,每个虚拟地址区域都对应红黑树的一个节点,左指针指向相邻的地址虚拟存储区域,右指针指向相邻的高地址虚拟地址空间.
4. IO多路复用epoll的实现采用红黑树组织管理sockfd，以支持快速的增删改查.
5. ngnix中,用红黑树管理timer,因为红黑树是有序的,可以很快的得到距离当前最小的定时器。

### 2、HashMap的扩容是什么

进行扩容，会伴随着一次重新hash分配，并且会遍历hash表中所有的元素，是非常耗时的。在编写程序中，要尽量避免resize。

HashMap在进行扩容时，使用的rehash方式非常巧妙，因为每次扩容都是翻倍，与原来计算的 (n-1)&hash的结果相比，只是多了一个bit位，所以节点要么就在原来的位置，要么就被分配到"**原位置+旧容量**"这个位置。

怎么理解呢？例如我们从16扩展为32时，具体的变化如下所示：

![20210908135502](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210908135502.png)

因此元素在重新计算hash之后，因为n变为2倍，那么n-1的标记范围在高位多1bit(红色)，因此新的index就会发生这样的变化：

![20210316105037](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210316105037.png)

说明：5是假设计算出来的原来的索引。这样就验证了上述所描述的：扩容之后所以节点要么就在原来的位置，要么就被分配到"原位置+旧容量"这个位置。

因此，我们在扩充HashMap的时候，不需要重新计算hash，只需要看看原来的hash值新增的那个bit是1还是0就可以了，是0的话索引没变，是1的话索引变成“原索引+oldCap(**原位置+旧容量**)”。可以看看下图为16扩充为32的resize示意图：

![20210908135551](https://aishu-marlowe.oss-cn-beijing.aliyuncs.com/20210908135551.png)

正是因为这样**巧妙的rehash**方式，既省去了重新计算hash值的时间，而且同时，由于新增的1bit是0还是1可以认为是随机的，在resize的过程中保证了rehash之后每个桶上的节点数一定小于等于原来桶上的节点数，保证了rehash之后不会出现更严重的hash冲突，均匀的把之前的冲突的节点分散到新的桶中了。

### 3、HashMap源码分析

#### 构造方法

HashMap 中有四个构造方法，它们分别如下：

```java
    // 默认构造函数。
    public HashMap() {
        this.loadFactor = DEFAULT_LOAD_FACTOR; // all   other fields defaulted
     }

     // 包含另一个“Map”的构造函数
     public HashMap(Map<? extends K, ? extends V> m) {
         this.loadFactor = DEFAULT_LOAD_FACTOR;
         putMapEntries(m, false);//下面会分析到这个方法
     }

     // 指定“容量大小”的构造函数
     public HashMap(int initialCapacity) {
         this(initialCapacity, DEFAULT_LOAD_FACTOR);
     }

     // 指定“容量大小”和“加载因子”的构造函数
     public HashMap(int initialCapacity, float loadFactor) {
         if (initialCapacity < 0)
             throw new IllegalArgumentException("Illegal initial capacity: " + initialCapacity);
         if (initialCapacity > MAXIMUM_CAPACITY)
             initialCapacity = MAXIMUM_CAPACITY;
         if (loadFactor <= 0 || Float.isNaN(loadFactor))
             throw new IllegalArgumentException("Illegal load factor: " + loadFactor);
         this.loadFactor = loadFactor;
         this.threshold = tableSizeFor(initialCapacity);
     }
```

**putMapEntries 方法：**

```java
final void putMapEntries(Map<? extends K, ? extends V> m, boolean evict) {
    int s = m.size();
    if (s > 0) {
        // 判断table是否已经初始化
        if (table == null) { // pre-size
            // 未初始化，s为m的实际元素个数
            float ft = ((float)s / loadFactor) + 1.0F;
            int t = ((ft < (float)MAXIMUM_CAPACITY) ?
                    (int)ft : MAXIMUM_CAPACITY);
            // 计算得到的t大于阈值，则初始化阈值
            if (t > threshold)
                threshold = tableSizeFor(t);
        }
        // 已初始化，并且m元素个数大于阈值，进行扩容处理
        else if (s > threshold)
            resize();
        // 将m中的所有元素添加至HashMap中
        for (Map.Entry<? extends K, ? extends V> e : m.entrySet()) {
            K key = e.getKey();
            V value = e.getValue();
            putVal(hash(key), key, value, false, evict);
        }
    }
}
```

#### put 方法

HashMap 只提供了 put 用于添加元素，putVal 方法只是给 put 方法调用的一个方法，并没有提供给用户使用。

**对 putVal 方法添加元素的分析如下：**

1. 如果定位到的数组位置没有元素 就直接插入。
2. 如果定位到的数组位置有元素就和要插入的 key 比较，如果 key 相同就直接覆盖，如果 key 不相同，就判断 p 是否是一个树节点，如果是就调用`e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value)`将元素添加进入。如果不是就遍历链表插入(插入的是链表尾部)。

```java
public V put(K key, V value) {
    return putVal(hash(key), key, value, false, true);
}

final V putVal(int hash, K key, V value, boolean onlyIfAbsent,
                   boolean evict) {
    Node<K,V>[] tab; Node<K,V> p; int n, i;
    // table未初始化或者长度为0，进行扩容
    if ((tab = table) == null || (n = tab.length) == 0)
        n = (tab = resize()).length;
    // (n - 1) & hash 确定元素存放在哪个桶中，桶为空，新生成结点放入桶中(此时，这个结点是放在数组中)
    if ((p = tab[i = (n - 1) & hash]) == null)
        tab[i] = newNode(hash, key, value, null);
    // 桶中已经存在元素
    else {
        Node<K,V> e; K k;
        // 比较桶中第一个元素(数组中的结点)的hash值相等，key相等
        if (p.hash == hash &&
            ((k = p.key) == key || (key != null && key.equals(k))))
                // 将第一个元素赋值给e，用e来记录
                e = p;
        // hash值不相等，即key不相等；为红黑树结点
        else if (p instanceof TreeNode)
            // 放入树中
            e = ((TreeNode<K,V>)p).putTreeVal(this, tab, hash, key, value);
        // 为链表结点
        else {
            // 在链表最末插入结点
            for (int binCount = 0; ; ++binCount) {
                // 到达链表的尾部
                if ((e = p.next) == null) {
                    // 在尾部插入新结点
                    p.next = newNode(hash, key, value, null);
                    // 结点数量达到阈值(默认为 8 )，执行 treeifyBin 方法
                    // 这个方法会根据 HashMap 数组来决定是否转换为红黑树。
                    // 只有当数组长度大于或者等于 64 的情况下，才会执行转换红黑树操作，以减少搜索时间。否则，就是只是对数组扩容。
                    if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
                        treeifyBin(tab, hash);
                    // 跳出循环
                    break;
                }
                // 判断链表中结点的key值与插入的元素的key值是否相等
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    // 相等，跳出循环
                    break;
                // 用于遍历桶中的链表，与前面的e = p.next组合，可以遍历链表
                p = e;
            }
        }
        // 表示在桶中找到key值、hash值与插入元素相等的结点
        if (e != null) {
            // 记录e的value
            V oldValue = e.value;
            // onlyIfAbsent为false或者旧值为null
            if (!onlyIfAbsent || oldValue == null)
                //用新值替换旧值
                e.value = value;
            // 访问后回调
            afterNodeAccess(e);
            // 返回旧值
            return oldValue;
        }
    }
    // 结构性修改
    ++modCount;
    // 实际大小大于阈值则扩容
    if (++size > threshold)
        resize();
    // 插入后回调
    afterNodeInsertion(evict);
    return null;
}
```

**我们再来对比一下 JDK1.7 put 方法的代码**

**对于 put 方法的分析如下：**

① 如果定位到的数组位置没有元素 就直接插入。
② 如果定位到的数组位置有元素，遍历以这个元素为头结点的链表，依次和插入的 key 比较，如果 key 相同就直接覆盖，不同就采用头插法插入元素。

```java
public V put(K key, V value)
    if (table == EMPTY_TABLE) {
    inflateTable(threshold);
}
    if (key == null)
        return putForNullKey(value);
    int hash = hash(key);
    int i = indexFor(hash, table.length);
    for (Entry<K,V> e = table[i]; e != null; e = e.next) { // 先遍历
        Object k;
        if (e.hash == hash && ((k = e.key) == key || key.equals(k))) {
            V oldValue = e.value;
            e.value = value;
            e.recordAccess(this);
            return oldValue;
        }
    }

    modCount++;
    addEntry(hash, key, value, i);  // 再插入
    return null;
}
```

#### get 方法

```java
public V get(Object key) {
    Node<K,V> e;
    return (e = getNode(hash(key), key)) == null ? null : e.value;
}

final Node<K,V> getNode(int hash, Object key) {
    Node<K,V>[] tab; Node<K,V> first, e; int n; K k;
    if ((tab = table) != null && (n = tab.length) > 0 &&
        (first = tab[(n - 1) & hash]) != null) {
        // 数组元素相等
        if (first.hash == hash && // always check first node
            ((k = first.key) == key || (key != null && key.equals(k))))
            return first;
        // 桶中不止一个节点
        if ((e = first.next) != null) {
            // 在树中get
            if (first instanceof TreeNode)
                return ((TreeNode<K,V>)first).getTreeNode(hash, key);
            // 在链表中get
            do {
                if (e.hash == hash &&
                    ((k = e.key) == key || (key != null && key.equals(k))))
                    return e;
            } while ((e = e.next) != null);
        }
    }
    return null;
}
```

#### resize()方法源码

进行扩容，会伴随着一次重新 hash 分配，并且会遍历 hash 表中所有的元素，是非常耗时的。在编写程序中，要尽量避免 resize。

```java
final Node<K,V>[] resize() {
    //得到当前数组
    Node<K,V>[] oldTab = table;
    //如果当前数组等于null长度返回0，否则返回当前数组的长度
    int oldCap = (oldTab == null) ? 0 : oldTab.length;
    //当前阀值点 默认是12(16*0.75)
    int oldThr = threshold;
    int newCap, newThr = 0;
    //如果老的数组长度大于0
    //开始计算扩容后的大小
    if (oldCap > 0) {
        // 超过最大值就不再扩充了，就只好随你碰撞去吧
        if (oldCap >= MAXIMUM_CAPACITY) {
            //修改阈值为int的最大值
            threshold = Integer.MAX_VALUE;
            return oldTab;
        }
        /*
        	没超过最大值，就扩充为原来的2倍
        	1)(newCap = oldCap << 1) < MAXIMUM_CAPACITY 扩大到2倍之后容量要小于最大容量
        	2)oldCap >= DEFAULT_INITIAL_CAPACITY 原数组长度大于等于数组初始化长度16
        */
        else if ((newCap = oldCap << 1) < MAXIMUM_CAPACITY &&
                 oldCap >= DEFAULT_INITIAL_CAPACITY)
            //阈值扩大一倍
            newThr = oldThr << 1; // double threshold
    }
    //老阈值点大于0 直接赋值
    else if (oldThr > 0) // 老阈值赋值给新的数组长度
        newCap = oldThr;
    else {// 直接使用默认值
        newCap = DEFAULT_INITIAL_CAPACITY;//16
        newThr = (int)(DEFAULT_LOAD_FACTOR * DEFAULT_INITIAL_CAPACITY);
    }
    // 计算新的resize最大上限
    if (newThr == 0) {
        float ft = (float)newCap * loadFactor;
        newThr = (newCap < MAXIMUM_CAPACITY && ft < (float)MAXIMUM_CAPACITY ?
                  (int)ft : Integer.MAX_VALUE);
    }
    //新的阀值 默认原来是12 乘以2之后变为24
    threshold = newThr;
    //创建新的哈希表
    @SuppressWarnings({"rawtypes","unchecked"})
    //newCap是新的数组长度-->32
    Node<K,V>[] newTab = (Node<K,V>[])new Node[newCap];
    table = newTab;
    //判断旧数组是否等于空
    if (oldTab != null) {
        // 把每个bucket都移动到新的buckets中
        //遍历旧的哈希表的每个桶，重新计算桶里元素的新位置
        for (int j = 0; j < oldCap; ++j) {
            Node<K,V> e;
            if ((e = oldTab[j]) != null) {
                //原来的数据赋值为null 便于GC回收
                oldTab[j] = null;
                //判断数组是否有下一个引用
                if (e.next == null)
                    //没有下一个引用，说明不是链表，当前桶上只有一个键值对，直接插入
                    newTab[e.hash & (newCap - 1)] = e;
                //判断是否是红黑树
                else if (e instanceof TreeNode)
                    //说明是红黑树来处理冲突的，则调用相关方法把树分开
                    ((TreeNode<K,V>)e).split(this, newTab, j, oldCap);
                else { // 采用链表处理冲突
                    Node<K,V> loHead = null, loTail = null;
                    Node<K,V> hiHead = null, hiTail = null;
                    Node<K,V> next;
                    //通过上述讲解的原理来计算节点的新位置
                    do {
                        // 原索引
                        next = e.next;
                     	//这里来判断如果等于true e这个节点在resize之后不需要移动位置
                        if ((e.hash & oldCap) == 0) {
                            if (loTail == null)
                                loHead = e;
                            else
                                loTail.next = e;
                            loTail = e;
                        }
                        // 原索引+oldCap
                        else {
                            if (hiTail == null)
                                hiHead = e;
                            else
                                hiTail.next = e;
                            hiTail = e;
                        }
                    } while ((e = next) != null);
                    // 原索引放到bucket里
                    if (loTail != null) {
                        loTail.next = null;
                        newTab[j] = loHead;
                    }
                    // 原索引+oldCap放到bucket里
                    if (hiTail != null) {
                        hiTail.next = null;
                        newTab[j + oldCap] = hiHead;
                    }
                }
            }
        }
    }
    return newTab;
}
```

#### treeifyBin方法

```java
final void treeifyBin(Node<K, V>[] tab, int hash)
    {
        int n, index;
        Node<K, V> e;
        if (tab == null || (n = tab.length) < MIN_TREEIFY_CAPACITY)
            // resize()方法这里不过多介绍，感兴趣的可以去看上面的链接。
            resize();
        // 通过hash求出bucket的位置。
        else if ((e = tab[index = (n - 1) & hash]) != null)
        {
            TreeNode<K, V> hd = null, tl = null;
            do
            {
                // 将每个节点包装成TreeNode。
                TreeNode<K, V> p = replacementTreeNode(e, null);
                if (tl == null)
                    hd = p;
                else
                {
                    // 将所有TreeNode连接在一起此时只是链表结构。
                    p.prev = tl;
                    tl.next = p;
                }
                tl = p;
            } while ((e = e.next) != null);
            if ((tab[index] = hd) != null)
                // 对TreeNode链表进行树化。
                hd.treeify(tab);
        }
    }
```

#### treeify方法

```java
final void treeify(Node<K, V>[] tab)
    {
        TreeNode<K, V> root = null;
        // 以for循环的方式遍历刚才我们创建的链表。
        for (TreeNode<K, V> x = this, next; x != null; x = next)
        {
            // next向前推进。
            next = (TreeNode<K, V>) x.next;
            x.left = x.right = null;
            // 为树根节点赋值。
            if (root == null)
            {
                x.parent = null;
                x.red = false;
                root = x;
            } else
            {
                // x即为当前访问链表中的项。
                K k = x.key;
                int h = x.hash;
                Class<?> kc = null;
                // 此时红黑树已经有了根节点，上面获取了当前加入红黑树的项的key和hash值进入核心循环。
                // 这里从root开始，是以一个自顶向下的方式遍历添加。
                // for循环没有控制条件，由代码内break跳出循环。
                for (TreeNode<K, V> p = root;;)
                {
                    // dir：directory，比较添加项与当前树中访问节点的hash值判断加入项的路径，-1为左子树，+1为右子树。
                    // ph：parent hash。
                    int dir, ph;
                    K pk = p.key;
                    if ((ph = p.hash) > h)
                        dir = -1;
                    else if (ph < h)
                        dir = 1;
                    else if ((kc == null && (kc = comparableClassFor(k)) == null)
                            || (dir = compareComparables(kc, k, pk)) == 0)
                        dir = tieBreakOrder(k, pk);

                    // xp：x parent。
                    TreeNode<K, V> xp = p;
                    // 找到符合x添加条件的节点。
                    if ((p = (dir <= 0) ? p.left : p.right) == null)
                    {
                        x.parent = xp;
                        // 如果xp的hash值大于x的hash值，将x添加在xp的左边。
                        if (dir <= 0)
                            xp.left = x;
                        // 反之添加在xp的右边。
                        else
                            xp.right = x;
                        // 维护添加后红黑树的红黑结构。
                        root = balanceInsertion(root, x);
                        
                        // 跳出循环当前链表中的项成功的添加到了红黑树中。
                        break;
                    }
                }
            }
        }
        // Ensures that the given root is the first node of its bin，自己翻译一下。
        moveRootToFront(tab, root);
    }
```

第一次循环会将链表中的首节点作为红黑树的根，而后的循环会将链表中的的项通过比较hash值然后连接到相应树节点的左边或者右边，插入可能会破坏树的结构所以接着执行balanceInsertion。

#### balanceInsertion方法

```java
static <K, V> TreeNode<K, V> balanceInsertion(TreeNode<K, V> root, TreeNode<K, V> x)
    {
        // 正如开头所说，新加入树节点默认都是红色的，不会破坏树的结构。
        x.red = true;
        // 这些变量名不是作者随便定义的都是有意义的。
        // xp：x parent，代表x的父节点。
        // xpp：x parent parent，代表x的祖父节点
        // xppl：x parent parent left，代表x的祖父的左节点。
        // xppr：x parent parent right，代表x的祖父的右节点。
        for (TreeNode<K, V> xp, xpp, xppl, xppr;;)
        {
            // 如果x的父节点为null说明只有一个节点，该节点为根节点，根节点为黑色，red = false。
            if ((xp = x.parent) == null)
            {
                x.red = false;
                return x;
            } 
            // 进入else说明不是根节点。
            // 如果父节点是黑色，那么大吉大利（今晚吃鸡），红色的x节点可以直接添加到黑色节点后面，返回根就行了不需要任何多余的操作。
            // 如果父节点是红色的，但祖父节点为空的话也可以直接返回根此时父节点就是根节点，因为根必须是黑色的，添加在后面没有任何问题。
            else if (!xp.red || (xpp = xp.parent) == null)
                return root;
            
            // 一旦我们进入到这里就说明了两件是情
            // 1.x的父节点xp是红色的，这样就遇到两个红色节点相连的问题，所以必须经过旋转变换。
            // 2.x的祖父节点xpp不为空。
            
            // 判断如果父节点是否是祖父节点的左节点
            if (xp == (xppl = xpp.left))
            {
                // 父节点xp是祖父的左节点xppr
                // 判断祖父节点的右节点不为空并且是否是红色的
                // 此时xpp的左右节点都是红的，所以直接进行上面所说的第三种变换，将两个子节点变成黑色，将xpp变成红色，然后将红色节点x顺利的添加到了xp的后面。
                // 这里大家有疑问为什么将x = xpp？
                // 这是由于将xpp变成红色以后可能与xpp的父节点发生两个相连红色节点的冲突，这就又构成了第二种旋转变换，所以必须从底向上的进行变换，直到根。
                // 所以令x = xpp，然后进行下下一层循环，接着往上走。
                if ((xppr = xpp.right) != null && xppr.red)
                {
                    xppr.red = false;
                    xp.red = false;
                    xpp.red = true;
                    x = xpp;
                }
                // 进入到这个else里面说明。
                // 父节点xp是祖父的左节点xppr。
                // 祖父节点xpp的右节点xppr是黑色节点或者为空，默认规定空节点也是黑色的。
                // 下面要判断x是xp的左节点还是右节点。
                else
                {
                    // x是xp的右节点，此时的结构是：xpp左->xp右->x。这明显是第二中变换需要进行两次旋转，这里先进行一次旋转。
                    // 下面是第一次旋转。
                    if (x == xp.right)
                    {
                        root = rotateLeft(root, x = xp);
                        xpp = (xp = x.parent) == null ? null : xp.parent;
                    }
                    // 针对本身就是xpp左->xp左->x的结构或者由于上面的旋转造成的这种结构进行一次旋转。
                    if (xp != null)
                    {
                        xp.red = false;
                        if (xpp != null)
                        {
                            xpp.red = true;
                            root = rotateRight(root, xpp);
                        }
                    }
                }
            } 
            // 这里的分析方式和前面的相对称只不过全部在右测不再重复分析。
            else
            {
                if (xppl != null && xppl.red)
                {
                    xppl.red = false;
                    xp.red = false;
                    xpp.red = true;
                    x = xpp;
                } else
                {
                    if (x == xp.left)
                    {
                        root = rotateRight(root, x = xp);
                        xpp = (xp = x.parent) == null ? null : xp.parent;
                    }
                    if (xp != null)
                    {
                        xp.red = false;
                        if (xpp != null)
                        {
                            xpp.red = true;
                            root = rotateLeft(root, xpp);
                        }
                    }
                }
            }
        }
    }
```



### 参考
[面试题：HashMap扩容机制](https://blog.csdn.net/qq_29860591/article/details/113726055)



