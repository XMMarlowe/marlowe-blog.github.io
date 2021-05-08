---
title: Object类中常用方法
author: Marlowe
tags: Object
categories: Java
abbrlink: 3496
date: 2021-04-23 22:04:31
---

<!--more-->

### 取得对象信息的方法：toString()

该方法在打印对象时被调用，将对象信息变为字符串返回，默认输出对象地址。

编译器默认调用toString()方法输出对象，但输出的是对象的地址，我们并不能看懂它的意思。那么就要通过重写Object类的toString()方法来输出对象属性信息。

### 对象相等判断方法：equals()
public boolean equals(Object obj);用于比较当前对象与目标对象是否相等，**默认是比较引用是否指向同一对象**。为public方法，子类可重写。

```java
public class Object{
    public boolean equals(Object obj) {
        return (this == obj);
    }
}
```

**为什么需要重写equals方法？**

因为如果不重写equals方法，当将自定义对象放到map或者set中时；如果这时两个对象的hashCode相同，就会调用equals方法进行比较，这个时候会调用Object中默认的equals方法，而默认的equals方法只是比较了两个对象的引用是否指向了同一个对象，显然大多数时候都不会指向，这样就会将重复对象存入map或者set中。这就 破坏了map与set不能存储重复对象的特性，会造成内存溢出 。



**重写equals方法的几条约定：**

1. 自反性：即x.equals(x)返回true，x不为null；
2. 对称性：即x.equals(y)与y.equals(x）的结果相同，x与y不为null；
3. 传递性：即x.equals(y)结果为true, y.equals(z)结果为true，则x.equals(z)结果也必须为true；
4. 一致性：即x.equals(y)返回true或false，在未更改equals方法使用的参数条件下，多次调用返回的结果也必须一致。x与y不为null。
5. 如果x不为null, x.equals(null)返回false。


建议equals及hashCode两个方法，需要重写时，两个都要重写，一般都是将自定义对象放至Set中，或者Map中的key时，需要重写这两个方法。

---

### 对象签名:hashCode()

该方法用来返回其所在对象的物理地址（哈希码值），常会和equals方法同时重写，确保相等的两个对象拥有相等的hashCode。

public native int hashCode();这是一个public的方法，所以 子类可以重写 它。这个方法返回当前对象的hashCode值，这个值是一个整数范围内的（-2^31 ~ 2^31 - 1）数字。

对于hashCode有以下几点约束：

1. 在 Java 应用程序执行期间，在对同一对象多次调用 hashCode 方法时，必须一致地返回相同的整数，前提是将对象进行 equals 比较时所用的信息没有被修改；
2. 如果两个对象 x.equals(y) 方法返回true，则x、y这两个对象的hashCode必须相等。
3. 如果两个对象x.equals(y) 方法返回false，则x、y这两个对象的hashCode可以相等也可以不等。 但是，为不相等的对象生成不同整数结果可以提高哈希表的性能。
4. 默认的hashCode是将内存地址转换为的hash值，重写过后就是自定义的计算方式；也可以通过System.identityHashCode(Object)来返回原本的hashCode。

```java
public class HashCodeTest {
    private int age;
    private String name;
    @Override
    public int hashCode() {
        Object[] a = Stream.of(age, name).toArray();
        int result = 1;
        for (Object element : a) {
            result = 31 * result + (element == null ? 0 : element.hashCode());
        }
        return result;
    }
}
```
推荐使用Objects.hash(Object… values)方法。相信看源码的时候，都看到计算hashCode都使用了31作为基础乘数， 为什么使用31呢？我比较赞同与理解result * 31 = (result<<5) - result。JVM底层可以自动做优化为位运算，效率很高；还有因为31计算的hashCode冲突较少，利于hash桶位的分布。



### getClass()

public final native ClassgetClass()：这是一个public的方法，我们可以直接通过对象调用。

类加载的第一阶段类的加载就是将.class文件加载到内存，并生成一个java.lang.Class对象的过程。getClass()方法就是获取这个对象，这是当前类的对象在运行时类的所有信息的集合。这个方法是反射三种方式之一。

**反射三种方式：**

1. 对象的getClass()
2. 类名.class
3. Class.forName()



### clone()

protected native Object clone() throws CloneNotSupportedException;

此方法返回当前对象的一个副本。

这是一个protected方法，提供给子类重写。但需要实现Cloneable接口，这是一个标记接口，如果没有实现，当调用object.clone()方法，会抛出CloneNotSupportedException。

```java
public class CloneTest implements Cloneable {
    private int age;
    private String name;
    //省略get、set、构造函数等
    @Override
    protected CloneTest clone() throws CloneNotSupportedException {
        return (CloneTest) super.clone();
    }
    public static void main(String[] args) throws CloneNotSupportedException {
        CloneTest cloneTest = new CloneTest(23, "9龙");
        CloneTest clone = cloneTest.clone();
        System.out.println(clone == cloneTest);
        System.out.println(cloneTest.getAge()==clone.getAge());
        System.out.println(cloneTest.getName()==clone.getName());
    }
}
//输出结果
//false
//true
//true
```


从输出我们看见，clone的对象是一个新的对象；但原对象与clone对象的 String类型 的name却是同一个引用，这表明，super.clone方法对成员变量如果是引用类型，进行是浅拷贝。

那什么是浅拷贝？对应的深拷贝？

浅拷贝：拷贝的是引用。

深拷贝：新开辟内存空间，进行值拷贝。

那如果我们要进行深拷贝怎么办呢？看下面的例子。

```java
class Person implements Cloneable{
    private int age;
    private String name;
     //省略get、set、构造函数等
     @Override
    protected Person clone() throws CloneNotSupportedException {
        Person person = (Person) super.clone();
        //name通过new开辟内存空间
        person.name = new String(name);
        return person;
   }
}
public class CloneTest implements Cloneable {
    private int age;
    private String name;
    //增加了person成员变量
    private Person person;
    //省略get、set、构造函数等
    @Override
    protected CloneTest clone() throws CloneNotSupportedException {
        CloneTest clone = (CloneTest) super.clone();
        clone.person = person.clone();
        return clone;
    }
    public static void main(String[] args) throws CloneNotSupportedException {
       CloneTest cloneTest = new CloneTest(23, "9龙");
        Person person = new Person(22, "路飞");
        cloneTest.setPerson(person);
        CloneTest clone = cloneTest.clone();
        System.out.println(clone == cloneTest);
        System.out.println(cloneTest.getAge() == clone.getAge());
        System.out.println(cloneTest.getName() == clone.getName());
        Person clonePerson = clone.getPerson();
        System.out.println(person == clonePerson);
        System.out.println(person.getName() == clonePerson.getName());
    }
}
//输出结果
//false
//true
//true
//false
//false
```
可以看到，即使成员变量是引用类型，我们也实现了深拷贝。 如果成员变量是引用类型，想实现深拷贝，则成员变量也要实现Cloneable接口，重写clone方法。


### wait()/ wait(long)/ wait(long,int)

这三个方法是用来 线程间通信用 的，作用是 阻塞当前线程 ，等待其他线程调用notify()/notifyAll()方法将其唤醒。这些方法都是public final的，不可被重写。

**注意：**

1. 此方法只能在当前线程获取到对象的锁监视器之后才能调用，否则会抛出IllegalMonitorStateException异常。
2. 调用wait方法，线程会将锁监视器进行释放；而Thread.sleep，Thread.yield()并不会释放锁 。
3. wait方法会一直阻塞，直到其他线程调用当前对象的notify()/notifyAll()方法将其唤醒；而wait(long)是等待给定超时时间内（单位毫秒），如果还没有调用notify()/nofiyAll()会自动唤醒；waite(long,int)如果第二个参数大于0并且小于999999，则第一个参数+1作为超时时间；

```java
public final void wait() throws InterruptedException {
        wait(0);
    } 
public final native void wait(long timeout) throws InterruptedException;
public final void wait(long timeout, int nanos) throws InterruptedException {
        if (timeout < 0) {
            throw new IllegalArgumentException("timeout value is negative");
        }
        if (nanos < 0 || nanos > 999999) {
            throw new IllegalArgumentException(
                                "nanosecond timeout value out of range");
        }
        if (nanos > 0) {
            timeout++;
        }
        wait(timeout);
    }
```

### notify()/notifyAll()
前面说了， 如果当前线程获得了当前对象锁，调用wait方法，将锁释放并阻塞；这时另一个线程获取到了此对象锁，并调用此对象的notify()/notifyAll()方法将之前的线程唤醒。 这些方法都是public final的，不可被重写。

1. public final native void notify(); 随机唤醒之前在当前对象上调用wait方法的一个线程
2. public final native void notifyAll(); 唤醒所有之前在当前对象上调用wait方法的线程



### finalize()

protected void finalize() throws Throwable ;

此方法是在垃圾回收之前，JVM会调用此方法来清理资源。此方法可能会将对象重新置为可达状态，导致JVM无法进行垃圾回收。

我们知道java相对于C++很大的优势是程序员不用手动管理内存，内存由jvm管理；如果我们的引用对象在堆中没有引用指向他们时，当内存不足时，JVM会自动将这些对象进行回收释放内存，这就是我们常说的垃圾回收。但垃圾回收没有讲述的这么简单。

**finalize()方法具有如下4个特点：**

1. 永远不要主动调用某个对象的finalize()方法，该方法由垃圾回收机制自己调用；
2. finalize()何时被调用，是否被调用具有不确定性；
3. 当JVM执行可恢复对象的finalize()可能会将此对象重新变为可达状态；
4. 当JVM执行finalize()方法时出现异常，垃圾回收机制不会报告异常，程序继续执行。

