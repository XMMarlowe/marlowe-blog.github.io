---
title: ArrayList扩容机制
author: Marlowe
tags: List
categories: Java
abbrlink: 58678
date: 2020-03-15 14:23:43
---

<!--more-->

```java
1、添加元素时，首先进行判断是否大于默认容量10
2、如果，小于默认容量，直接在原来基础上+1，元素添加完毕
3、如果，大于默认容量，则需要进行扩容，扩容核心是grow()方法
   3.1 扩容之前，首先创建一个新的数组，且旧数组被复制到新的数组中
       这样就得到了一个全新的副本，我们在操作时就不会影响原来数组了
   3.2 然后通过位运算符将新的容量更新为旧容量的 1.5 倍
   3.3 如果新的容量比最小需要容量小，则最小需要容量为当前数组新容量，
   如果minCapacity大于最大容量，则新容量则为`Integer.MAX_VALUE`，否则，新容量大小则为 MAX_ARRAY_SIZE 即为 `Integer.MAX_VALUE - 8`。

```

grow()方法：
```java
    /**
     * 要分配的最大数组大小
     */
    private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

    /**
     * ArrayList扩容的核心方法。
     */
    private void grow(int minCapacity) {
        // oldCapacity为旧容量，newCapacity为新容量
        int oldCapacity = elementData.length;
        //将oldCapacity 右移一位，其效果相当于oldCapacity /2，
        //我们知道位运算的速度远远快于整除运算，整句运算式的结果就是将新容量更新为旧容量的1.5倍，
        int newCapacity = oldCapacity + (oldCapacity >> 1);
        //然后检查新容量是否大于最小需要容量，若还是小于最小需要容量，那么就把最小需要容量当作数组的新容量，
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
       // 如果新容量大于 MAX_ARRAY_SIZE,进入(执行) `hugeCapacity()` 方法来比较 minCapacity 和 MAX_ARRAY_SIZE，
       //如果minCapacity大于最大容量，则新容量则为`Integer.MAX_VALUE`，否则，新容量大小则为 MAX_ARRAY_SIZE 即为 `Integer.MAX_VALUE - 8`。
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // minCapacity is usually close to size, so this is a win:
        elementData = Arrays.copyOf(elementData, newCapacity);
    }

```
