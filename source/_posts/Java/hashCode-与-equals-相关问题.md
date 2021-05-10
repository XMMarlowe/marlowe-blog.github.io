---
title: hashCode()与 equals()相关问题
author: Marlowe
tags:
  - hashcode
  - equals
categories: Java
abbrlink: 51318
date: 2021-05-08 21:29:19
---

<!--more-->

### hashCode()介绍

**hashCode() 的作用是获取哈希码**，也称为散列码；它实际上是返回一个 int 整数。这个**哈希码的作用是确定该对象在哈希表中的索引位置**。hashCode()定义在 JDK 的 Object 类中，这就意味着 Java 中的任何类都包含有 hashCode() 函数。另外需要注意的是： Object 的 hashcode 方法是本地方法，也就是用 c 语言或 c++ 实现的，该方法通常用来将对象的 内存地址 转换为整数之后返回。

```java
public native int hashCode();
```

散列表存储的是键值对(key-value)，它的特点是：能根据“键”快速的检索出对应的“值”。这其中就利用到了散列码！（可以快速找到所需要的对象）

### 对于hashCode有以下几点约束：

1. 在 Java 应用程序执行期间，在对同一对象多次调用 hashCode 方法时，必须一致地返回相同的整数，前提是将对象进行 equals 比较时所用的信息没有被修改；
2. 如果两个对象 x.equals(y) 方法返回true，则x、y这两个对象的hashCode必须相等。
3. 如果两个对象x.equals(y) 方法返回false，则x、y这两个对象的hashCode可以相等也可以不等。 但是，为不相等的对象生成不同整数结果可以提高哈希表的性能。
4. 默认的hashCode是将内存地址转换为的hash值，重写过后就是自定义的计算方式；也可以通过System.identityHashCode(Object)来返回原本的hashCode。

```java
public class HashCodeTest {
    private int age;
    private String name;
    @Override
    public int hashCode() {
        Object[] a = Stream.of(age, name).toArray();
        int result = 1;
        for (Object element : a) {
            result = 31 * result + (element == null ? 0 : element.hashCode());
        }
        return result;
    }
}
```
推荐使用Objects.hash(Object… values)方法。相信看源码的时候，都看到计算hashCode都使用了31作为基础乘数， 为什么使用31呢？我比较赞同与理解result * 31 = (result<<5) - result。JVM底层可以自动做优化为位运算，效率很高；还有因为31计算的hashCode冲突较少，利于hash桶位的分布。

### equals()介绍

public boolean equals(Object obj);用于比较当前对象与目标对象是否相等，**默认是比较引用是否指向同一对象**。为public方法，子类可重写。

```java
public class Object{
    public boolean equals(Object obj) {
        return (this == obj);
    }
}
```

### 为什么要有 hashCode？

**我们以“HashSet 如何检查重复”为例子来说明为什么要有 hashCode？**

当你把对象加入 HashSet 时，HashSet 会先计算对象的 hashcode 值来判断对象加入的位置，同时也会与其他已经加入的对象的 hashcode 值作比较，如果没有相符的 hashcode，HashSet 会假设对象没有重复出现。但是如果发现有相同 hashcode 值的对象，这时会调用 equals() 方法来检查 hashcode 相等的对象是否真的相同。如果两者相同，HashSet 就不会让其加入操作成功。如果不同的话，就会重新散列到其他位置。（摘自我的 Java 启蒙书《Head First Java》第二版）。这样我们就大大减少了 equals 的次数，相应就大大提高了执行速度。

### 为什么需要重写equals方法？

因为如果不重写equals方法，当将自定义对象放到map或者set中时；如果这时两个对象的hashCode相同，就会调用equals方法进行比较，这个时候会调用Object中默认的equals方法，而默认的equals方法只是比较了两个对象的引用是否指向了同一个对象，显然大多数时候都不会指向，这样就会将重复对象存入map或者set中。这就 破坏了map与set不能存储重复对象的特性，会造成内存溢出 。

### 重写equals方法的几条约定

1. 自反性：即x.equals(x)返回true，x不为null；
2. 对称性：即x.equals(y)与y.equals(x）的结果相同，x与y不为null；
3. 传递性：即x.equals(y)结果为true, y.equals(z)结果为true，则x.equals(z)结果也必须为true；
4. 一致性：即x.equals(y)返回true或false，在未更改equals方法使用的参数条件下，多次调用返回的结果也必须一致。x与y不为null。
5. 如果x不为null, x.equals(null)返回false。


建议equals及hashCode两个方法，需要重写时，两个都要重写，一般都是将自定义对象放至Set中，或者Map中的key时，需要重写这两个方法。

### 为什么重写 equals 时必须重写 hashCode 方法？

如果两个对象相等，则 hashcode 一定也是相同的。两个对象相等,对两个对象分别调用 equals 方法都返回 true。但是，两个对象有相同的 hashcode 值，它们也不一定是相等的 。因此，equals 方法被覆盖过，则 hashCode 方法也必须被覆盖。

**hashCode()的默认行为是对堆上的对象产生独特值。如果没有重写 hashCode()，则该 class 的两个对象无论如何都不会相等（即使这两个对象指向相同的数据）**


### 为什么两个对象有相同的 hashcode 值，它们也不一定是相等的？

因为 hashCode() 所使用的杂凑算法也许刚好会让多个对象传回相同的杂凑值。越糟糕的杂凑算法越容易碰撞，但这也与数据值域分布的特性有关（所谓碰撞也就是指的是不同的对象得到相同的 hashCode。

我们刚刚也提到了 HashSet,如果 HashSet 在对比的时候，同样的 hashcode 有多个对象，它会使用 equals() 来判断是否真的相同。**也就是说 hashcode 只是用来缩小查找成本。**
