---
title: Java中的异常体系
author: Marlowe
tags:
  - Java
  - 异常
categories: Java
abbrlink: 53205
date: 2020-03-09 15:58:09
---

<!--more-->



### Java 异常类层次结构图

![20210514162423](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210514162423.png)

![20210514162459](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210514162459.png)

在 Java 中，所有的异常都有一个共同的祖先 `java.lang` 包中的 `Throwable` 类。`Throwable` 类有两个重要的子类 `Exception`（异常）和 `Error`（错误）。`Exception` 能被程序本身处理(try-catch)， `Error`是无法处理的(只能尽量避免)。

`Exception` 和 `Error` 二者都是 Java 异常处理的重要子类，各自都包含大量子类。

* **Exception:** 程序本身可以处理的异常，可以通过 `catch` 来进行捕获。`Exception` 又可以分为 受检查异常(必须处理) 和 不受检查异常(可以不处理)。
* **Error：** `Error` 属于程序无法处理的错误 ，我们没办法通过 `catch` 来进行捕获 。例如，Java 虚拟机运行错误（`Virtual MachineError`）、虚拟机内存不够错误(`OutOfMemoryError`)、类定义错误（`NoClassDefFoundError`）等 。这些异常发生时，Java 虚拟机（JVM）一般会选择线程终止。

#### 受检查异常

Java 代码在编译过程中，如果受检查异常没有被 `catch/throw` 处理的话，就没办法通过编译 。除了`RuntimeException`及其子类以外，其他的`Exception`类及其子类都属于受检查异常 。常见的受检查异常有： IO 相关的异常、`ClassNotFoundException 、SQLException`...。

#### 不受检查异常

Java 代码在编译过程中 ，我们即使不处理不受检查异常也可以正常通过编译。

`RuntimeException`及其子类都统称为非受检查异常，例如：`NullPointerException、NumberFormatException`（字符串转换为数字）、`ArrayIndexOutOfBoundsException`（数组越界）、`ClassCastException`（类型转换错误）、`ArithmeticException`（算术错误）等。

### 自定义异常实现

自定义异常类步骤:

* 创建一个类继承异常父类Exception
* 在具体的实现方法首部抛出异常类(自己创建的那个类)，throws的运用
* 在具体的实现方法的内部抛出异常信息,throw的运用

创建一个类继承异常父类Exception

```java
public class EmailException extends Exception {
 
  EmailException(String msg) {
    super(msg);
  }

}
```

### Throwable 类常用方法

* **public string getMessage():** 返回异常发生时的简要描述
* **public string toString():** 返回异常发生时的详细信息
* **public string getLocalizedMessage():** 返回异常对象的本地化信息。使用 `Throwable` 的子类覆盖这个方法，可以生成本地化信息。如果子类没有覆盖该方法，则该方法返回的信息与 `getMessage（）`返回的结果相同
* **public void printStackTrace():** 在控制台上打印 `Throwable` 对象封装的异常信息

### try-catch-finally

* **try块：** 用于捕获异常。其后可接零个或多个 `catch` 块，如果没有 `catch` 块，则必须跟一个 `finally` 块。
* **catch块：** 用于处理 `try` 捕获到的异常。
* **finally 块：** 无论是否捕获或处理异常，`finally` 块里的语句都会被执行。当在 `try` 块或 `catch` 块中遇到 `return` 语句时，`finally` 语句块将在方法返回之前被执行。

**在以下 3 种特殊情况下，finally 块不会被执行：**

1. 在 `try` 或 `finally` 块中用了 `System.exit(int)` 退出程序。但是，如果 `System.exit(int)` 在异常语句之后，`finally` 还是会被执行
2. 程序所在的线程死亡。
3. 关闭 CPU。

**注意：** 当 try 语句和 finally 语句中都有 return 语句时，在方法返回之前，finally 语句的内容将被执行，并且 finally 语句的返回值将会覆盖原始的返回值。如下：
```java
public class Test {
    public static int f(int value) {
        try {
            return value * value;
        } finally {
            if (value == 2) {
                return 0;
            }
        }
    }
}
```
如果调用 f(2)，返回值将是 0，因为 finally 语句的返回值覆盖了 try 语句块的返回值。

### 使用 try-with-resources 来代替try-catch-finally

1. **适用范围（资源的定义）：** 任何实现 `java.lang.AutoCloseable`或者 `java.io.Closeable` 的对象
2. **关闭资源和 finally 块的执行顺序：** 在 `try-with-resources` 语句中，任何 `catch` 或 `finally` 块在声明的资源关闭后运行

《Effecitve Java》中明确指出：

> 面对必须要关闭的资源，我们总是应该优先使用 `try-with-resources` 而不是`try-finally`。随之产生的代码更简短，更清晰，产生的异常对我们也更有用。`try-with-resources`语句让我们更容易编写必须要关闭的资源的代码，若采用`try-finally`则几乎做不到这点。

Java 中类似于`InputStream、OutputStream 、Scanner 、PrintWriter`等的资源都需要我们调用`close()`方法来手动关闭，一般情况下我们都是通过`try-catch-finally`语句来实现这个需求，如下：
```java
        //读取文本文件的内容
        Scanner scanner = null;
        try {
            scanner = new Scanner(new File("D://read.txt"));
            while (scanner.hasNext()) {
                System.out.println(scanner.nextLine());
            }
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } finally {
            if (scanner != null) {
                scanner.close();
            }
        }
```

使用 Java 7 之后的 `try-with-resources` 语句改造上面的代码:

```java
try (Scanner scanner = new Scanner(new File("test.txt"))) {
    while (scanner.hasNext()) {
        System.out.println(scanner.nextLine());
    }
} catch (FileNotFoundException fnfe) {
    fnfe.printStackTrace();
}
```
当然多个资源需要关闭的时候，使用 `try-with-resources` 实现起来也非常简单，如果你还是用`try-catch-finally`可能会带来很多问题。

通过使用分号分隔，可以在`try-with-resources`块中声明多个资源。

```java
try (BufferedInputStream bin = new BufferedInputStream(new FileInputStream(new File("test.txt")));
             BufferedOutputStream bout = new BufferedOutputStream(new FileOutputStream(new File("out.txt")))) {
            int b;
            while ((b = bin.read()) != -1) {
                bout.write(b);
            }
        }
        catch (IOException e) {
            e.printStackTrace();
        }
```




### 总结

* 所有异常类都是Throwable的子类
* 异常可分为Error(错误)和Exception(异常)两类
* Exception又可分为RuntimeException(运行时异常)和非运行时异常两类
* Error是程序无法处理的错误，一旦出现这个错误，则程序被迫停止运行。
* Exception不会导致程序停止，分为`RuntimeException`运行时异常和`CheckedException`检查异常。
* `RuntimeException`常常发生在程序运行过程中，会导致程序**当前线程**执行失败。`CheckedException`常常发生在程序编译过程中，会导致程序编译不通过。