---
title: Java中父类和子类的加载顺序
author: Marlowe
tags: 类加载
categories: Java
abbrlink: 60234
date: 2021-08-28 18:31:02
---

加载顺序：父类静态属性（成员变量） > 父类静态代码块 > 子类静态属性 > 子类静态代码块 > 父类非静态属性 > 父类非静态代码块 > 父类构造器 > 子类非静态属性 > 子类非静态代码块 > 子类构造器
<!--more-->

### 加载顺序

简而言之就是先静态后非静态，先父类后子类，具体顺序如下：

1. 父类静态变量
2. 父类静态代码块（若有多个按代码先后顺序执行）
3. 子类静态变量
4. 子类静态代码块（若有多个按代码先后顺序执行）
5. 父类非静态变量
6. 父类非静态代码块（若有多个按代码先后顺序执行）
7. 父类构造函数
8. 子类非静态变量
9. 子类非静态代码块（若有多个按代码先后顺序执行）
10. 子类构造函数

所有的静态资源都只会加载一次，非静态资源可以重复加载。

### 小结

这里帮大家小结几个特点：
    
1. 静态属性和代码块，当且仅当该类在程序中第一次被 new 或者第一次被类加载器调用时才会触发（不考虑永久代的回收）。也正是因为上述原因，**类优先于对象** 加载/new，即 **静态优先于非静态**。
2. 属性（成员变量）优先于构造方法，可以这么理解，加载这整个类，需要先知道类具有哪些属性，并且这些属性初始化完毕之后，这个类的对象才算是**完整的**。另外，非静态代码块其实就是对象 new 的准备工作之一，算是一个不接受任何外来参数的构造方法。因此，**属性 > 非静态代码块 > 构造方法。**
3. 有趣的是，**静态部分（前4个）是父类 > 子类**，而 **非静态部分（后6个）也是父类 > 子类。**
4. 另外容易忽略的是，非静态代码块在每次 new 对象时都会运行，可以理解：**非静态代码块是正式构造方法前的准备工作**（非静态代码块 > 构造方法）。

### 测试代码：

```java
public class Main {

    static class A {
        static Hi hi = new Hi("A");

        Hi hi2 = new Hi("A2");

        static {
            System.out.println("A static");
        }

        {
            System.out.println("AAA");
        }

        public A() {
            System.out.println("A init");
        }
    }


    static class B extends A {
        static Hi hi = new Hi("B");

        Hi hi2 = new Hi("B2");

        static {
            System.out.println("B static");
        }

        {
            System.out.println("BBB");
        }

        public B() {
            System.out.println("B init");
        }
    }

    static class Hi {
        public Hi(String str) {
            System.out.println("Hi " + str);
        }
    }

    public static void main(String[] args) {
        System.out.println("初次 new B：");
        B b = new B();
        System.out.println();
        System.out.println("第二次 new B：");
        b = new B();
    }

}
```

结果：

```bash
初次 new B：
Hi A
A static
Hi B
B static
Hi A2
AAA
A init
Hi B2
BBB
B init

第二次 new B：
Hi A2
AAA
A init
Hi B2
BBB
B init
```

