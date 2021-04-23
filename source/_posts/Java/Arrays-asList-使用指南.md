---
title: Arrays.asList()使用指南
author: Marlowe
tags: Arrays
categories: Java
abbrlink: 39116
date: 2020-03-13 10:40:40
---
Arrays.asList()将数组转换为集合后,底层其实还是数组
<!--more-->
![20210313104312](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210313104312.png)
```java
public class Test1 {
    public static void main(String[] args) {
        String[] str = new String[]{"111", "222"};
        List<String> list = Arrays.asList(str);
        list.add("333");
        list.forEach(a->{
            System.out.println(a);
        });
    }
}

```

```java
运行报错：
Exception in thread "main" java.lang.UnsupportedOperationException
	at java.util.AbstractList.add(AbstractList.java:148)
	at java.util.AbstractList.add(AbstractList.java:108)
	at test.Test1.main(Test1.java:16)
```

### 使用注意事项
**传递的数组必须是对象数组，而不是基本类型**
```java
int[] myArray = {1, 2, 3};
List myList = Arrays.asList(myArray);
System.out.println(myList.size());//1
System.out.println(myList.get(0));//数组地址值
System.out.println(myList.get(1));//报错：ArrayIndexOutOfBoundsException: 1
int[] array = (int[]) myList.get(0);
System.out.println(array[0]);//1
```
当传入一个原生数据类型数组时，Arrays.asList() 的真正得到的参数就不是数组中的元素，而是数组对象本身！此时List 的唯一元素就是这个数组，这也就解释了上面的代码。

我们使用包装类型数组就可以解决这个问题。
```java
Integer[] myArray = {1, 2, 3};
List myList = Arrays.asList(myArray);
System.out.println(myList.size());//3
System.out.println(myList.get(0));//1
System.out.println(myList.get(1));//2
```
**使用集合的修改方法:add()、remove()、clear()会抛出异常。**
```java
List myList = Arrays.asList(1, 2, 3);
myList.add(4);//运行时报错：UnsupportedOperationException
myList.remove(1);//运行时报错：UnsupportedOperationException
myList.clear();//运行时报错：UnsupportedOperationException
```
Arrays.asList() 方法返回的并不是 java.util.ArrayList ，而是 java.util.Arrays 的一个内部类,这个内部类并没有实现集合的修改方法或者说并没有重写这些方法。
```java
List myList = Arrays.asList(1, 2, 3);
System.out.println(myList.getClass());//class java.util.Arrays$ArrayList
```
查看remove() 方法，可以知道为啥抛出UnsupportedOperationException。
```java
public E remove(int index) {
    throw new UnsupportedOperationException();
}
```


### 如何正确的将数组转换为ArrayList？
#### 1、最简便的方法
```java
List list = new ArrayList<>(Arrays.asList("a", "b", "c"))
```

#### 2、使用Java8的Stream
```java
Integer [] myArray = { 1, 2, 3 };
List myList = Arrays.stream(myArray).collect(Collectors.toList());
//基本类型也可以实现转换（依赖boxed的装箱操作）
int [] myArray2 = { 1, 2, 3 };
List myList = Arrays.stream(myArray2).boxed().collect(Collectors.toList());
```






### 参考
[Arrays.asList()使用指南](https://snailclimb.gitee.io/javaguide/#/docs/java/basis/Java%E5%9F%BA%E7%A1%80%E7%9F%A5%E8%AF%86%E7%96%91%E9%9A%BE%E7%82%B9?id=_21-arraysaslist%e4%bd%bf%e7%94%a8%e6%8c%87%e5%8d%97)