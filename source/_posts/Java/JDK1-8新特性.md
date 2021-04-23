---
title: JDK1.8新特性
author: Marlowe
tags: JDK
categories: Java
abbrlink: 46653
date: 2020-04-16 15:55:02
---
Java 8 (又称为 jdk 1.8) 是 Java 语言开发的一个主要版本。 Oracle 公司于 2014 年 3 月 18 日发布 Java 8 ，它支持函数式编程，新的 JavaScript 引擎，新的日期 API，新的Stream API 等。
<!--more-->

### Lambda 表达式
Lambda 允许把函数作为一个方法的参数（函数作为参数传递到方法中）。

**以下是lambda表达式的重要特征:**

* **可选类型声明：** 不需要声明参数类型，编译器可以统一识别参数值。
* **可选的参数圆括号：** 一个参数无需定义圆括号，但多个参数需要定义圆括号。
* **可选的大括号：** 如果主体包含了一个语句，就不需要使用大括号。
* **可选的返回关键字：** 如果主体只有一个表达式返回值则编译器会自动返回值，大括号需要指定明表达式返回了一个数值。

#### 变量作用域
lambda 表达式只能引用标记了 final 的外层局部变量，这就是说不能在 lambda 内部修改定义在域外的局部变量，否则会编译错误。
```java
public class Java8Tester {
 
   final static String salutation = "Hello! ";
   
   public static void main(String args[]){
      GreetingService greetService1 = message -> 
      System.out.println(salutation + message);
      greetService1.sayMessage("Runoob");
   }
    
   interface GreetingService {
      void sayMessage(String message);
   }
}
```

我们也可以直接在 lambda 表达式中访问外层的局部变量：
```java
public class Java8Tester {
    public static void main(String args[]) {
        final int num = 1;
        Converter<Integer, String> s = (param) -> System.out.println(String.valueOf(param + num));
        s.convert(2);  // 输出结果为 3
    }
 
    public interface Converter<T1, T2> {
        void convert(int i);
    }
}
```

lambda 表达式的局部变量可以不用声明为 final，但是必须不可被后面的代码修改（即隐性的具有 final 的语义）
```java
int num = 1;  
Converter<Integer, String> s = (param) -> System.out.println(String.valueOf(param + num));
s.convert(2);
num = 5;  
//报错信息：Local variable num defined in an enclosing scope must be final or effectively final
```

在 Lambda 表达式当中不允许声明一个与局部变量同名的参数或者局部变量。
```java
String first = "";  
Comparator<String> comparator = (first, second) -> Integer.compare(first.length(), second.length());  //编译会出错 
```



### 方法引用
方法引用提供了非常有用的语法，可以直接引用已有Java类或对象（实例）的方法或构造器。与lambda联合使用，方法引用可以使语言的构造更紧凑简洁，减少冗余代码。

* 方法引用通过方法的名字来指向一个方法。

* 方法引用可以使语言的构造更紧凑简洁，减少冗余代码。

* 方法引用使用一对冒号 :: 。

下面，我们在 Car 类中定义了 4 个方法作为例子来区分 Java 中 4 种不同方法的引用。
```java
package com.runoob.main;
 
@FunctionalInterface
public interface Supplier<T> {
    T get();
}
 
class Car {
    //Supplier是jdk1.8的接口，这里和lamda一起使用了
    public static Car create(final Supplier<Car> supplier) {
        return supplier.get();
    }
 
    public static void collide(final Car car) {
        System.out.println("Collided " + car.toString());
    }
 
    public void follow(final Car another) {
        System.out.println("Following the " + another.toString());
    }
 
    public void repair() {
        System.out.println("Repaired " + this.toString());
    }
}
```
**构造器引用：** 它的语法是Class::new，或者更一般的Class< T >::new实例如下：
```java
final Car car = Car.create( Car::new );
final List< Car > cars = Arrays.asList( car );
```
**静态方法引用：** 它的语法是Class::static_method，实例如下：
```java
cars.forEach( Car::collide );
```
**特定类的任意对象的方法引用：** 它的语法是Class::method实例如下：
```java
cars.forEach( Car::repair );
```
**特定对象的方法引用：** 它的语法是instance::method实例如下：
```java
final Car police = Car.create( Car::new );
cars.forEach( police::follow );
```


### 默认方法
简单说，默认方法就是接口可以有实现方法，而且不需要实现类去实现其方法。

我们只需在方法名前面加个 default 关键字即可实现默认方法。

**为什么要有这个特性？**
首先，之前的接口是个双刃剑，好处是面向抽象而不是面向具体编程，缺陷是，当需要修改接口时候，需要修改全部实现该接口的类，目前的 java 8 之前的集合框架没有 foreach 方法，通常能想到的解决办法是在JDK里给相关的接口添加新的方法及实现。然而，对于已经发布的版本，是没法在给接口添加新方法的同时不影响已有的实现。所以引进的默认方法。他们的目的是为了解决接口的修改与现有的实现不兼容的问题。

#### 语法
默认方法语法格式如下：
```java
public interface Vehicle {
   default void print(){
      System.out.println("我是一辆车!");
   }
}
```
### 多个默认方法
一个接口有默认方法，考虑这样的情况，一个类实现了多个接口，且这些接口有相同的默认方法，以下实例说明了这种情况的解决方法：

```java
public interface Vehicle {
   default void print(){
      System.out.println("我是一辆车!");
   }
}
 
public interface FourWheeler {
   default void print(){
      System.out.println("我是一辆四轮车!");
   }
}
```
第一个解决方案是创建自己的默认方法，来覆盖重写接口的默认方法：
```java
public class Car implements Vehicle, FourWheeler {
   default void print(){
      System.out.println("我是一辆四轮汽车!");
   }
}
```
第二种解决方案可以使用 super 来调用指定接口的默认方法：
```java
public class Car implements Vehicle, FourWheeler {
   public void print(){
      Vehicle.super.print();
   }
}
```

#### 静态默认方法

Java 8 的另一个特性是接口可以声明（并且可以提供实现）静态方法,通过`类名.方法名`调用。例如：
```java
public interface Vehicle {
   default void print(){
      System.out.println("我是一辆车!");
   }
    // 静态方法
   static void blowHorn(){
      System.out.println("按喇叭!!!");
   }
}
```

### 新工具
新的编译工具，如：Nashorn引擎 jjs、 类依赖分析器jdeps。

### Stream API
新添加的Stream API（java.util.stream） 把真正的函数式编程风格引入到Java中。

Java 8 API添加了一个新的抽象称为流Stream，可以让你以一种声明的方式处理数据。

Stream 使用一种类似用 SQL 语句从数据库查询数据的直观方式来提供一种对 Java 集合运算和表达的高阶抽象。

Stream API可以极大提高Java程序员的生产力，让程序员写出高效率、干净、简洁的代码。

这种风格将要处理的元素集合看作一种流， 流在管道中传输， 并且可以在管道的节点上进行处理， 比如筛选， 排序，聚合等。

元素流在管道中经过中间操作（intermediate operation）的处理，最后由最终操作(terminal operation)得到前面处理的结果。

```java
+--------------------+       +------+   +------+   +---+   +-------+
| stream of elements +-----> |filter+-> |sorted+-> |map+-> |collect|
+--------------------+       +------+   +------+   +---+   +-------+
```
以上的流程转换为 Java 代码为：
```java
List<Integer> transactionsIds = 
widgets.stream()
             .filter(b -> b.getColor() == RED)
             .sorted((x,y) -> x.getWeight() - y.getWeight())
             .mapToInt(Widget::getWeight)
             .sum();
```
#### 生成流
在 Java 8 中, 集合接口有两个方法来生成流：

* stream() − 为集合创建串行流。

* parallelStream() − 为集合创建并行流。

```java
List<String> strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
List<String> filtered = strings.stream().filter(string -> !string.isEmpty()).collect(Collectors.toList());
```

#### forEach
Stream 提供了新的方法 'forEach' 来迭代流中的每个数据。以下代码片段使用 forEach 输出了10个随机数：
```java
Random random = new Random();
random.ints().limit(10).forEach(System.out::println);
```
#### map
map 方法用于映射每个元素到对应的结果，以下代码片段使用 map 输出了元素对应的平方数：
```java
List<Integer> numbers = Arrays.asList(3, 2, 2, 3, 7, 3, 5);
// 获取对应的平方数
List<Integer> squaresList = numbers.stream().map( i -> i*i).distinct().collect(Collectors.toList());
```
#### filter
filter 方法用于通过设置的条件过滤出元素。以下代码片段使用 filter 方法过滤出空字符串：
```java
List<String>strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
// 获取空字符串的数量
long count = strings.stream().filter(string -> string.isEmpty()).count();
```
#### limit
limit 方法用于获取指定数量的流。 以下代码片段使用 limit 方法打印出 10 条数据：
```java
Random random = new Random();
random.ints().limit(10).forEach(System.out::println);
```
#### sorted
sorted 方法用于对流进行排序。以下代码片段使用 sorted 方法对输出的 10 个随机数进行排序：
```java
Random random = new Random();
random.ints().limit(10).sorted().forEach(System.out::println);
```
#### 并行（parallel）程序
parallelStream 是流并行处理程序的代替方法。以下实例我们使用 parallelStream 来输出空字符串的数量：
```java
List<String> strings = Arrays.asList("abc", "", "bc", "efg", "abcd","", "jkl");
// 获取空字符串的数量
long count = strings.parallelStream().filter(string -> string.isEmpty()).count();
```
### Date Time API
加强对日期与时间的处理。

在旧版的 Java 中，日期时间 API 存在诸多问题，其中有：

* **非线程安全** − java.util.Date 是非线程安全的，所有的日期类都是可变的，这是Java日期类最大的问题之一。

* **设计很差** − Java的日期/时间类的定义并不一致，在java.util和java.sql的包中都有日期类，此外用于格式化和解析的类在java.text包中定义。java.util.Date同时包含日期和时间，而java.sql.Date仅包含日期，将其纳入java.sql包并不合理。另外这两个类都有相同的名字，这本身就是一个非常糟糕的设计。

* **时区处理麻烦** − 日期类并不提供国际化，没有时区支持，因此Java引入了java.util.Calendar和java.util.TimeZone类，但他们同样存在上述所有的问题。


Java 8 在 java.time 包下提供了很多新的 API。以下为两个比较重要的 API：

* **Local(本地)** − 简化了日期时间的处理，没有时区的问题。

* **Zoned(时区)** − 通过制定的时区处理日期时间。

新的java.time包涵盖了所有处理日期，时间，日期/时间，时区，时刻（instants），过程（during）与时钟（clock）的操作。
### Optional 类
Optional 类已经成为 Java 8 类库的一部分，用来解决空指针异常。

Optional 类是一个可以为null的容器对象。如果值存在则isPresent()方法会返回true，调用get()方法会返回该对象。

Optional 是个容器：它可以保存类型T的值，或者仅仅保存null。Optional提供很多有用的方法，这样我们就不用显式进行空值检测。

Optional 类的引入很好的解决空指针异常。

#### 类声明
以下是一个 `java.util.Optional<T> 类` 的声明：
```java
public final class Optional<T> extends Object
```

#### Optional 实例
我们可以通过以下实例来更好的了解 Optional 类的使用：
```java
import java.util.Optional;
 
public class Java8Tester {
   public static void main(String args[]){
   
      Java8Tester java8Tester = new Java8Tester();
      Integer value1 = null;
      Integer value2 = new Integer(10);
        
      // Optional.ofNullable - 允许传递为 null 参数
      Optional<Integer> a = Optional.ofNullable(value1);
        
      // Optional.of - 如果传递的参数是 null，抛出异常 NullPointerException
      Optional<Integer> b = Optional.of(value2);
      System.out.println(java8Tester.sum(a,b));
   }
    
   public Integer sum(Optional<Integer> a, Optional<Integer> b){
    
      // Optional.isPresent - 判断值是否存在
        
      System.out.println("第一个参数值存在: " + a.isPresent());
      System.out.println("第二个参数值存在: " + b.isPresent());
        
      // Optional.orElse - 如果值存在，返回它，否则返回默认值
      Integer value1 = a.orElse(new Integer(0));
        
      //Optional.get - 获取值，值需要存在
      Integer value2 = b.get();
      return value1 + value2;
   }
}
```
执行以上脚本，输出结果为：

```java
$ javac Java8Tester.java 
$ java Java8Tester
第一个参数值存在: false
第二个参数值存在: true
10
```

### Nashorn, JavaScript 引擎
Java 8提供了一个新的Nashorn javascript引擎，它允许我们在JVM上运行特定的javascript应用。
