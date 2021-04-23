---
title: Java8四大函数式接口
author: Marlowe
tags: 函数式接口
categories: Java
abbrlink: 12083
date: 2020-03-25 13:00:01
---
只有一个方法的接口叫做函数式接口。
Function、Predicate、Consumer、Supplier
<!--more-->
函数式接口的作用：简化编程模型，在新版本的框架底层大量应用！

```java
@FunctionalInterface
public interface Runnable {
    public abstract void run();
}
//  foreach（消费者类型的函数式接口）
```
### Function
函数型接口：有一个输入参数，有一个输出。

源码：
```java
@FunctionalInterface
public interface Function<T, R> {

    /**
     * Applies this function to the given argument.
     *
     * @param t the function argument
     * @return the function result
     */
    R apply(T t);
}
```
代码示例：
```java
// 只要是函数型接口，可以用lambda表达式简化
public static void main(String[] args) {
        Function function = new Function<String, String>() {
            @Override
            public String apply(String string) {
                return string;
            }
        };
        System.out.println(function.apply("hello"));
    }

// 简化写法
public static void main(String[] args) {
        Function<String, String> function = (str) -> {
            return str;
        };
        System.out.println(function.apply("hello"));
    }
```
结果：
```java
hello
```


### Predicate
断定型接口：有一个输入参数，返回值只能是布尔值。

源码：
```java
@FunctionalInterface
public interface Predicate<T> {

    /**
     * Evaluates this predicate on the given argument.
     *
     * @param t the input argument
     * @return {@code true} if the input argument matches the predicate,
     * otherwise {@code false}
     */
    boolean test(T t);
}
```

代码示例：
```java
    /**
     * 判断字符串是否为空
     * @param args
     */
    public static void main(String[] args) {
        Predicate<String> predicate = (str) ->{
            return str.isEmpty();
        };
        System.out.println(predicate.test("11"));
    }
```
结果：
```java
false
true
```

### Consumer
消费型接口：只有输入，没有返回值。

源码：
```java
@FunctionalInterface
public interface Consumer<T> {

    /**
     * Performs this operation on the given argument.
     *
     * @param t the input argument
     */
    void accept(T t);
}
```

代码示例：
```java
    /**
     * 打印字符串
     *
     * @param args
     */
    public static void main(String[] args) {
        Consumer<String> consumer = str -> {
            System.out.println(str);
        };
        consumer.accept("consumer");
    }
```

结果：
```java
consumer
```



### Supplier
供给型接口：没有参数，只有返回值。
```java
@FunctionalInterface
public interface Supplier<T> {

    /**
     * Gets a result.
     *
     * @return a result
     */
    T get();
}
```

代码示例：
```java
    /**
     * 返回固定值 1024
     *
     * @param args
     */
    public static void main(String[] args) {
        Supplier<Integer> supplier = () -> {
            return 1024;
        };
        System.out.println(supplier.get());
    }
```

结果：
```java
1024
```









