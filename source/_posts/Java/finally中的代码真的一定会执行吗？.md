---
title: finally中的代码真的一定会执行吗？
author: Marlowe
tags: finally
categories: Java
abbrlink: 13855
date: 2020-04-10 22:17:23
---
finally中的代码在某些情况下不一定能执行...
<!--more-->

### 1. 在执行异常处理代码之前程序已经返回

```java
public static boolean getTrue(boolean flag) {
        if (flag) {
            return flag;
        }
        try {
            flag = true;
            return flag;
        } finally {
            System.out.println("我是一定会执行的代码？");
        }
    }
```
如果上述代码传入的参数为true那finally中的代码就不会执行了。

### 2. 在执行异常处理代码之前程序抛出异常

```java
public static boolean getTrue(boolean flag) {
        int i = 1/0;
        try {
            flag = true;
            return flag;
        } finally {
            System.out.println("我是一定会执行的代码？");
        }
    }
```

这里会抛出异常，finally中的代码同样不会执行。原理同1中差不多，只有与 finally 相对应的 try 语句块得到执行的情况下，finally 语句块才会执行。
就算try语句执行了finally中的代码一定会执行吗，答案是no，请看下面两种情况。

### 3. finally之前执行了System.exit()

```java
public static boolean getTrue(boolean flag) {
        try {
            flag = true;
            System.exit(1);
            return flag;
        } finally {
            System.out.println("我是一定会执行的代码？");
        }
    }
```
System.exit是用于结束当前正在运行中的java虚拟机，参数为0代表程序正常退出，非0代表程序非正常退出。道理也很简单整个程序都结束了，拿什么来执行finally呢。

### 4. 所有后台线程终止时，后台线程会突然终止
   
```java
public static void main(String[] args) {
        Thread t1 = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Thread.sleep(5);
                } catch (Exception e) {
                }finally{
                    System.out.println("我是一定会执行的代码？");
                }
            }
        });
        t1.setDaemon(true);//设置t1为后台线程
        t1.start();
        System.out.println("我是主线程中的代码,主线程是非后台线程。");
    }
```

上述代码，后台线程t1中有finally块，但在执行前，主线程终止了，导致后台线程立即终止，故finally块无法执行


### 总结

1. 与finally相对应的try语句得到执行的情况下，finally才有可能执行。
2. finally执行前，程序或线程终止，finally不会执行。

