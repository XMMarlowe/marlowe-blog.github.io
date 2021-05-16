---
title: 获取class对象六种方法
author: Marlowe
tags:
  - Java
  - 对象
categories: Java
abbrlink: 18735
date: 2021-05-10 15:52:02
---

<!--more-->

### 简述

Class类是Java反射机制的入口，封装了一个类或接口的运行时信息，通过调用Class类的方法可以获取这些信息。
Class类有如下特点：
1、该类在java.lang包中，不需要引包
2、该类被final修饰，不可被继承
3、该类实现了Serializable接口
4、该类的构造方法被private修饰，不能通过关键字new创建该类的对象

### 获取对应class类对象

1、（建议）通过Class类静态forName(“类包名.类名”)
2、类名.class获取Class类实例
3、如果已创建了引用类型的对象，则可以通过调用对象中的getClass()方法获取Class类实例
4、基本数据类型，可以通过包装类.TYPE/class获取Class类实例
5、如果是数组，可以通过数组元素的类型[].class获取Class类实例
6、可以通过调用子类Class实例的getSuperClass()方法获取其父类的Class类实例

```java
public class Test{
	public static void main(String[] args) {
		Class clazz = null;
		try {
			//a.Class.forName("包.类")
			clazz = Class.forName("Student");
			System.out.println(clazz.getName());
		} catch (ClassNotFoundException e) {
			e.printStackTrace();
		}
		//2.类名.class
		clazz = Student.class;
		System.out.println(clazz.getName());
		//3.对象名.class
		clazz = new Student().getClass();
		System.out.println(clazz.getName());
		//4.基本数据类型对应的class对象：包装类.TYPE
		clazz = Integer.TYPE;
		System.out.println(clazz.getName());
		clazz = Integer.class;
		System.out.println(clazz.getName());
		//5.数组类型对应class：元素类型[].class
		clazz = String[].class;
		System.out.println(clazz.getName());
		//6.某个类父类所对应的class对象
		clazz = Student.class.getSuperclass();
		System.out.println(clazz.getName());
	}
}
```