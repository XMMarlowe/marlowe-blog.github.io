---
title: Java数组拷贝的几种方式
author: Marlowe
tags:
  - Java
  - 数组
categories: Java
abbrlink: 6424
date: 2021-05-23 16:48:25
---
目前在Java中数据拷贝提供了如下方式：1、clone 2、System.arraycopy 3、Arrays.copyOf 4、Arrays.copyOfRange。
<!--more-->

### clone 方法

clone方法是从Object类继承过来的，基本数据类型（int ，boolean，char，byte，short，float ，double，long）都可以直接使用clone方法进行克隆，注意String类型是因为其值不可变所以才可以使用。

#### int 类型示例

```java
int[] a1 = {1, 3};
int[] a2 = a1.clone();

a1[0] = 666;
System.out.println(Arrays.toString(a1));   //[666, 3]
System.out.println(Arrays.toString(a2));   //[1, 3]
```

#### String类型示例

```java
String[] a1 = {"a1", "a2"};
String[] a2 = a1.clone();

a1[0] = "b1"; //更改a1数组中元素的值
System.out.println(Arrays.toString(a1));   //[b1, a2]
System.out.println(Arrays.toString(a2));   //[a1, a2]
```

### System.arraycopy

```java
System.arraycopy方法是一个本地的方法，源码里定义如下：
```

其参数含义为：

```java
（原数组， 原数组的开始位置， 目标数组， 目标数组的开始位置， 拷贝个数）
```

#### 用法示例

```java
int[] a1 = {1, 2, 3, 4, 5};
int[] a2 = new int[10];

System.arraycopy(a1, 1, a2, 3, 3);
System.out.println(Arrays.toString(a1)); // [1, 2, 3, 4, 5]
System.out.println(Arrays.toString(a2)); // [0, 0, 0, 2, 3, 4, 0, 0, 0, 0]
```

当使用这个方法的时候，需要复制到一个已经分配内存单元的数组。

### Arrays.copyOf

Arrays.copyOf底层其实也是用的System.arraycopy 源码如下：

```java
public static <T,U> T[] copyOf(U[] original, int newLength, Class<? extends T[]> newType) {
    @SuppressWarnings("unchecked")
    T[] copy = ((Object)newType == (Object)Object[].class)
        ? (T[]) new Object[newLength]
        : (T[]) Array.newInstance(newType.getComponentType(), newLength);
    System.arraycopy(original, 0, copy, 0,
                     Math.min(original.length, newLength));
    return copy;
}
```

参数含义：

```java
（原数组，拷贝的个数）
```

#### 用法示例

```java
int[] a1 = {1, 2, 3, 4, 5};
int[] a2 = Arrays.copyOf(a1, 3);

System.out.println(Arrays.toString(a1)) // [1, 2, 3, 4, 5]
System.out.println(Arrays.toString(a2)) // [1, 2, 3]
```

使用该方法无需我们事先使用new关键字对对象进行内存单元的分配

### Arrays.copyOfRange

Arrays.copyOfRange底层其实也是用的System.arraycopy，只不过封装了一个方法

```java
public static <T,U> T[] copyOfRange(U[] original, int from, int to, Class<? extends T[]> newType) {
    int newLength = to - from;
    if (newLength < 0)
        throw new IllegalArgumentException(from + " > " + to);
    @SuppressWarnings("unchecked")
    T[] copy = ((Object)newType == (Object)Object[].class)
        ? (T[]) new Object[newLength]
        : (T[]) Array.newInstance(newType.getComponentType(), newLength);
    System.arraycopy(original, from, copy, 0,
                     Math.min(original.length - from, newLength));
    return copy;
}
```

参数含义

```java
（原数组，开始位置，拷贝的个数）
```

用法示例：

```java
int[] a1 = {1, 2, 3, 4, 5};
int[] a2 = Arrays.copyOfRange(a1, 0, 1);

System.out.println(Arrays.toString(a1)) // [1, 2, 3, 4, 5]
System.out.println(Arrays.toString(a2)) // [1]
```

最后需要注意的是基本类型的拷贝是不影响原数组的值的，如果是引用类型，就不能在这用了，因为数组的拷贝是浅拷贝，对于基本类型可以，对于引用类型是不适合的。

### 那么如何实现对象的深度拷贝呢？

#### 实现Cloneable接口

实现Cloneable接口，并重写clone方法，注意一个类不实现这个接口，直接使用clone方法是编译通不过的。

```java
/**
 * Created by Joe on 2018/2/13.
 */
public class Dog implements Cloneable {
    private String id;
    private String name;

	public Dog(String id, String name) {
        this.id = id;
        this.name = name;
    }

    // 省略 getter 、 setter 以及 toString 方法

    @Override
    public Dog clone() throws CloneNotSupportedException {
        Dog dog = (Dog) super.clone();

        return dog;
    }
}
```
示例：

```java
Dog dog1 = new Dog("1", "Dog1");
Dog dog2 = dog1.clone();

dog2.setName("Dog1 changed");

System.out.println(dog1); // Dog{id='1', name='Dog1'}
System.out.println(dog2); // Dog{id='1', name='Dog1 changed'}
```

#### 组合类深拷贝

如果一个类里面，又引用其他的类，其他的类又有引用别的类，那么想要深度拷贝必须所有的类及其引用的类都得实现Cloneable接口，重写clone方法，这样以来非常麻烦，简单的方法是让所有的对象实现序列化接口（Serializable），然后通过序列化反序列化的方法来深度拷贝对象。

```java
public Dog myClone() {
	Dog dog = null;

	try {
		//将对象序列化成为流，因为写在流是对象里的一个拷贝
		//而原始对象扔在存在JVM中，所以利用这个特性可以实现深拷贝
		ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
		ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteArrayOutputStream);
		objectOutputStream.writeObject(this);

		//将流序列化为对象
		ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(byteArrayOutputStream.toByteArray());
		ObjectInputStream objectInputStream = new ObjectInputStream(byteArrayInputStream);
		dog = (Dog) objectInputStream.readObject();
	} catch (IOException | ClassNotFoundException e) {
		e.printStackTrace();
	}

	return dog;
}
```

### 参考

[Java - 数组拷贝的几种方式](https://blog.csdn.net/u011669700/article/details/79323251)

