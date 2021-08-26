---
title: 如何在List种移除元素
author: Marlowe
tags: List
categories: Java
abbrlink: 17758
date: 2021-05-08 22:01:59
---

<!--more-->

### Itr对象源码

```java
private class Itr implements Iterator<E> {	
    int cursor;       // index of next element to return	
    int lastRet = -1; // index of last element returned; -1 if no such	
    int expectedModCount = modCount;	
	
    Itr() {}	
	
    public boolean hasNext() {	
        return cursor != size;	
    }	
	
    @SuppressWarnings("unchecked")	
    public E next() {	
        checkForComodification();	
        int i = cursor;	
        if (i >= size)	
            throw new NoSuchElementException();	
        Object[] elementData = ArrayList.this.elementData;	
        if (i >= elementData.length)	
            throw new ConcurrentModificationException();	
        cursor = i + 1;	
        return (E) elementData[lastRet = i];	
    }	
	
    public void remove() {	
        if (lastRet < 0)	
            throw new IllegalStateException();	
        checkForComodification();	
	
        try {	
            ArrayList.this.remove(lastRet);	
            cursor = lastRet;	
            lastRet = -1;	
            expectedModCount = modCount;	
        } catch (IndexOutOfBoundsException ex) {	
            throw new ConcurrentModificationException();	
        }	
    }	
	
    @Override	
    @SuppressWarnings("unchecked")	
    public void forEachRemaining(Consumer<? super E> consumer) {	
        Objects.requireNonNull(consumer);	
        final int size = ArrayList.this.size;	
        int i = cursor;	
        if (i >= size) {	
            return;	
        }	
        final Object[] elementData = ArrayList.this.elementData;	
        if (i >= elementData.length) {	
            throw new ConcurrentModificationException();	
        }	
        while (i != size && modCount == expectedModCount) {	
            consumer.accept((E) elementData[i++]);	
        }	
        // update once at end of iteration to reduce heap write traffic	
        cursor = i;	
        lastRet = i - 1;	
        checkForComodification();	
    }	
	
  /**报错的地方*/	
    final void checkForComodification() {	
        if (modCount != expectedModCount)	
            throw new ConcurrentModificationException();	
    }	
}
```
通过代码我们发现 Itr 是 ArrayList 中定义的一个私有内部类，在 next、remove方法中都会调用 checkForComodification 方法，该方法的作用是判断 modCount != expectedModCount是否相等，如果不相等则抛出ConcurrentModificationException异常。每次正常执行 remove 方法后，都会对执行 expectedModCount = modCount 赋值，保证两个值相等！

那么问题基本上已经清晰了，在 foreach 循环中执行 list.remove(item);，对 list 对象的 modCount 值进行了修改，而 list 对象的迭代器的 expectedModCount 值未进行修改，因此抛出了ConcurrentModificationException 异常。

### 采用倒序移除
```java
public static void main(String[] args) {	
  List<String> list = new ArrayList<String>();	
  list.add("11");	
  list.add("11");	
  list.add("12");	
  list.add("13");	
  list.add("14");	
  list.add("15");	
  list.add("16");	
  System.out.println("原始list元素："+ list.toString());	
  CopyOnWriteArrayList<String> copyList = new CopyOnWriteArrayList<>(list);	
  	
  //通过下表移除等于11的元素	
  for (int i = list.size() - 1; i >= 0; i--) {	
    String item = list.get(i);	
    if("11".equals(item)) {	
      list.remove(i);	
    }	
  }	
  System.out.println("通过下表移除后的list元素："+ list.toString());	
  	
  //通过对象移除等于11的元素	
  for (int i = copyList.size() - 1; i >= 0; i--) {	
    String item = copyList.get(i);	
    if("11".equals(item)) {	
      copyList.remove(item);	
    }	
  }	
  System.out.println("通过对象移除后的list元素："+ list.toString());	 	
}
```
输出结果：
```java
原始list元素：[11, 11, 12, 13, 14, 15, 16]	
通过下表移除后的list元素：[12, 13, 14, 15, 16]	
通过对象移除后的list元素：[12, 13, 14, 15, 16]
```

### for的解决办法

```java
public static void main(String[] args) {	
  List<String> list = new ArrayList<String>();	
  list.add("11");	
  list.add("11");	
  list.add("12");	
  list.add("13");	
  list.add("14");	
  list.add("15");	
  list.add("16");	
  System.out.println("原始list元素："+ list.toString());	
  CopyOnWriteArrayList<String> copyList = new CopyOnWriteArrayList<>(list);	
  	
  //通过对象移除等于11的元素	
  for (String item : copyList) {	
    if("11".equals(item)) {	
      copyList.remove(item);	
    }	
  }	
  System.out.println("通过对象移除后的list元素："+ copyList.toString());	 	
}
```
输出结果：

```java
原始list元素：[11, 11, 12, 13, 14, 15, 16]	
通过对象移除后的list元素：[12, 13, 14, 15, 16]
```

### 使用迭代器移除

```java
public static void main(String[] args) {	
  List<String> list = new ArrayList<String>();	
  list.add("11");	
  list.add("11");	
  list.add("12");	
  list.add("13");	
  list.add("14");	
  list.add("15");	
  list.add("16");	
  System.out.println("原始list元素："+ list.toString());	
  	
  //通过迭代器移除等于11的元素	
  Iterator<String> iterator = list.iterator();	
  while(iterator.hasNext()) {	
    String item = iterator.next();	
    if("11".equals(item)) {	
      iterator.remove();	
    }	
  }	
  System.out.println("通过迭代器移除后的list元素："+ list.toString());	 	
}
```

输出结果：
```java
原始list元素：[11, 11, 12, 13, 14, 15, 16]	
通过迭代器移除后的list元素：[12, 13, 14, 15, 16]
```

### jdk1.8的写法

```java

public static void main(String[] args) {	
  List<String> list = new ArrayList<String>();	
  list.add("11");	
  list.add("11");	
  list.add("12");	
  list.add("13");	
  list.add("14");	
  list.add("15");	
  list.add("16");	
  System.out.println("原始list元素："+ list.toString());	
  	
  //jdk1.8移除等于11的元素	
  list.removeIf(item -> "11".equals(item));	
  System.out.println("移除后的list元素："+ list.toString());	 	
}
```

输出结果：

```java
原始list元素：[11, 11, 12, 13, 14, 15, 16]	
通过迭代器移除后的list元素：[12, 13, 14, 15, 16]
```

### 参考

[java中List元素移除元素的那些坑](https://blog.csdn.net/javageektech/article/details/96668890)




