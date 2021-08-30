---
title: Java对象创建的4种方式
author: Marlowe
tags: 对象
categories: Java
abbrlink: 27099
date: 2021-05-08 21:42:11
---

<!--more-->


### 1、使用 new 关键字创建对象

这是常用的创建对象的方法，语法格式如下：
类名 对象名=new 类名()；

### 2、调用 java.lang.Class 或者 java.lang.reflect.Constuctor 类的 newlnstance() 实例方法

在 Java 中，可以使用 java.lang.Class 或者 java.lang.reflect.Constuctor 类的 newlnstance() 实例方法来创建对象，代码格式如下：
java.lang.Class Class 类对象名称=java.lang.Class.forName(要实例化的类全称);
类名 对象名=(类名)Class类对象名称.newInstance();

调用 java.lang.Class 类中的 forName() 方法时，需要将要实例化的类的全称（比如 com.mxl.package.Student）作为参数传递过去，然后再调用 java.lang.Class 类对象的 newInstance() 方法创建对象。

### 3、调用对象的 clone() 方法

该方法不常用，使用该方法创建对象时，要实例化的类必须继承 java.lang.Cloneable 接口。 调用对象的 clone() 方法创建对象的语法格式如下：
类名对象名=(类名)已创建好的类对象名.clone();

### 4、调用 java.io.ObjectlnputStream 对象的 readObject() 方法


### 示例代码

```java
public class Student implements Cloneable
{   
    //实现 Cloneable 接口
    private String Name;    //学生名字
    private int age;    //学生年龄
    public Student(String name,int age)
    {    //构造方法
        this.Name=name;
        this.age=age;
    }
    public Student()
    {
        this.Name="name";
        this.age=0;
    }
    public String toString()
    {
        return"学生名字："+Name+"，年龄："+age;
    }
    public static void main(String[] args)throws Exception
    {
        System.out.println("---------使用 new 关键字创建对象---------");
       
        //使用new关键字创建对象
        Student student1=new Student("小刘",22);
        System.out.println(student1);
        System.out.println("-----------调用 java.lang.Class 的 newInstance() 方法创建对象-----------");
       
        //调用 java.lang.Class 的 newInstance() 方法创建对象
        Class cl=Class.forName("Student");
        Student student2=(Student)cl.newInstance();
        System.out.println(student2);
        System.out.println("-------------------调用对象的 clone() 方法创建对象----------");
        //调用对象的 clone() 方法创建对象
        Student student3=(Student)student2.clone();
        System.out.println(student3);
    }
}
```

**无论釆用哪种方式创建对象，Java 虚拟机在创建一个对象时都包含以下步骤：**

1. 给对象分配内存。
2. 将对象的实例变量自动初始化为其变量类型的默认值。
3. 初始化对象，给实例变量赋予正确的初始值。

**注意：** 每个对象都是相互独立的，在内存中占有独立的内存地址，并且每个对象都具有自己的生命周期，当一个对象的生命周期结束时，对象就变成了垃圾，由 Java 虚拟机自带的垃圾回收机制处理。
