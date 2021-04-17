---
title: Java反射相关知识点
author: Marlowe
date: 2021-04-16 16:00:16
tags: 
  - 反射
  - Java
categories: Java
---

<!--more-->

### 什么是反射？
反射是在运行状态中，**对于任意一个类，** 都能够知道这个类的所有属性和方法；**对于任意一个对象，** 都能够调用它的任意一个方法和属性；这种**动态获取的信息以及动态调用对象的方法**的功能称为 Java 语言的反射机制。
### 哪里用到反射机制？

1. JDBC中，利用反射动态加载了数据库驱动程序。
2. Web服务器中利用反射调用了Sevlet的服务方法。
3. Eclispe等开发工具利用反射动态刨析对象的类型与结构，动态提示对象的属性和方法。
4. 很多框架都用到反射机制，注入属性，调用方法，如Spring。

### 什么叫对象序列化，什么是反序列化，实现对象序列化需要做哪些工作？

1. **对象序列化：** 将对象中的数据编码为字节序列的过程。
2. **反序列化：** 将对象的编码字节重新反向解码为对象的过程。
3. JAVA提供了API实现了对象的序列化和反序列化的功能，使用这些API时需要遵守如下**约定：**
   * 被序列化的对象类型需要实现序列化接口，此接口是标志接口，没有声明任何的抽象方法，JAVA编译器识别这个接口，自动的为这个类添加序列化和反序列化方法。
   * 为了保持序列化过程的稳定，建议在类中添加序列化版本号。
   * 不想让字段放在硬盘上就加transient

4. 以下情况需要使用 Java 序列化：
   * 想把的内存中的对象状态保存到一个文件中或者数据库中时候；
   * 想用套接字在网络上传送对象的时候；
   * 想通过RMI（远程方法调用）传输对象的时候。
### 反射机制的优缺点？

1. **优点：** 可以动态执行，在运行期间根据业务功能动态执行方法、访问属性，最大限度发挥了java的灵活性。
2. **缺点：** 让我们在运行时有了分析操作类的能力，这同样也增加了安全问题。比如可以无视泛型参数的安全检查（泛型参数的安全检查发生在编译时）。另外，反射的性能也要稍差点，不过，对于框架来说实际是影响不大的。

### Java反射机制的作用
1. 在运行时判断任意一个对象所属的类
2. 在运行时构造任意一个类的对象
3. 在运行时判断任意一个类所具有的成员变量和方法
4. 在运行时调用任意一个对象的方法

### 获取 Class 对象的四种方式
如果我们动态获取到这些信息，我们需要依靠 Class 对象。Class 类对象将一个类的方法、变量等信息告诉运行的程序。Java 提供了四种方式获取 Class 对象:

**1. 知道具体类的情况下可以使用：**
```java
Class alunbarClass = TargetObject.class;
```
但是我们一般是不知道具体类的，基本都是通过遍历包下面的类来获取 Class 对象，通过此方式获取 Class 对象不会进行初始化。


**2. 通过 Class.forName()传入类的路径获取：**
```java
Class alunbarClass1 = Class.forName("cn.javaguide.TargetObject");
```

**3.通过对象实例instance.getClass()获取：**

```java
TargetObject o = new TargetObject();
Class alunbarClass2 = o.getClass();
```
**4.通过类加载器xxxClassLoader.loadClass()传入类路径获取:**

```java
class clazz = ClassLoader.LoadClass("cn.javaguide.TargetObject");
```
通过类加载器获取 Class 对象不会进行初始化，意味着不进行包括初始化等一些列步骤，静态块和静态对象不会得到执行


### 反射的一些基本操作

**简单用代码演示一下反射的一些操作!**

1.创建一个我们要使用反射操作的类 TargetObject。

```java
package cn.javaguide;

public class TargetObject {
    private String value;

    public TargetObject() {
        value = "JavaGuide";
    }

    public void publicMethod(String s) {
        System.out.println("I love " + s);
    }

    private void privateMethod() {
        System.out.println("value is " + value);
    }
}
```
2.使用反射操作这个类的方法以及参数

```java
package cn.javaguide;

import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;

public class Main {
    public static void main(String[] args) throws ClassNotFoundException, NoSuchMethodException, IllegalAccessException, InstantiationException, InvocationTargetException, NoSuchFieldException {
        /**
         * 获取TargetObject类的Class对象并且创建TargetObject类实例
         */
        Class<?> tagetClass = Class.forName("cn.javaguide.TargetObject");
        TargetObject targetObject = (TargetObject) tagetClass.newInstance();
        /**
         * 获取所有类中所有定义的方法
         */
        Method[] methods = tagetClass.getDeclaredMethods();
        for (Method method : methods) {
            System.out.println(method.getName());
        }
        /**
         * 获取指定方法并调用
         */
        Method publicMethod = tagetClass.getDeclaredMethod("publicMethod",
                String.class);

        publicMethod.invoke(targetObject, "JavaGuide");
        /**
         * 获取指定参数并对参数进行修改
         */
        Field field = tagetClass.getDeclaredField("value");
        //为了对类中的参数进行修改我们取消安全检查
        field.setAccessible(true);
        field.set(targetObject, "JavaGuide");
        /**
         * 调用 private 方法
         */
        Method privateMethod = tagetClass.getDeclaredMethod("privateMethod");
        //为了调用private方法我们取消安全检查
        privateMethod.setAccessible(true);
        privateMethod.invoke(targetObject);
    }
}
```
输出内容：

```java
publicMethod
privateMethod
I love JavaGuide
value is JavaGuide
```



### 参考
[Java反射常见面试题](https://blog.csdn.net/qq_37875585/article/details/89340495)
