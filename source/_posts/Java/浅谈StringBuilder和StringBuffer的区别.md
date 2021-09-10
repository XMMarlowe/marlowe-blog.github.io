---
title: 浅谈StringBuilder和StringBuffer的区别
author: Marlowe
tags: String
categories: Java
abbrlink: 29428
date: 2021-08-28 21:36:34
---
String StringBuffer 和 StringBuilder 的区别是什么? String 为什么是不可变的?
<!--more-->

### 可变性

简单的来说：String 类中使用 final 关键字修饰字符数组来保存字符串，private final char value[]，所以String 对象是不可变的。

> 在 Java 9 之后，String 、StringBuilder 与 StringBuffer 的实现改用 byte 数组存储字符串 private final byte[] value
> **为什么使用byte字节而舍弃了char字符:**
> 节省内存占用，byte占一个字节(8位)，char占用2个字节（16），相较char节省一半的内存空间。节省gc压力。
针对初始化的字符，对字符长度进行判断选择不同的编码方式。如果是 LATIN-1 编码，则右移0位，数组长度即为字符串长度。而如果是 UTF16 编码，则右移1位，数组长度的二分之一为字符串长度。

而 StringBuilder 与 StringBuffer 都继承自 AbstractStringBuilder 类，在 AbstractStringBuilder 中也是使用字符数组保存字符串char[]value 但是没有用 final 关键字修饰，所以这两种对象都是可变的。

StringBuilder 与 StringBuffer 的构造方法都是调用父类构造方法也就是AbstractStringBuilder 实现的，大家可以自行查阅源码。

AbstractStringBuilder.java
```java
abstract class AbstractStringBuilder implements Appendable, CharSequence {
    /**
     * The value is used for character storage.
     */
    char[] value;

    /**
     * The count is the number of characters used.
     */
    int count;

    AbstractStringBuilder(int capacity) {
        value = new char[capacity];
    }}
```

### 线程安全性

String 中的对象是不可变的，也就可以理解为常量，线程安全。AbstractStringBuilder 是 StringBuilder 与 StringBuffer 的公共父类，定义了一些字符串的基本操作，如 expandCapacity、append、insert、indexOf 等公共方法。StringBuffer 对方法加了**同步锁(synchronized)** 或者对调用的方法加了同步锁，所以是线程安全的。StringBuilder 并没有对方法进行加同步锁，所以是非线程安全的。

### 性能

每次对 String 类型进行改变的时候，都会生成一个新的 String 对象，然后将指针指向新的 String 对象。StringBuffer 每次都会对 StringBuffer 对象本身进行操作，而不是生成新的对象并改变对象引用。相同情况下使用 StringBuilder 相比使用 StringBuffer 仅能获得 10%~15% 左右的性能提升，但却要冒多线程不安全的风险。

### 对于三者使用的总结

1. 操作少量的数据: 适用 String
2. 单线程操作字符串缓冲区下操作大量数据: 适用 StringBuilder
3. 多线程操作字符串缓冲区下操作大量数据: 适用 StringBuffer




