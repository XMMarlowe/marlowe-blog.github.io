---
title: Java反射相关知识点
author: Marlowe
tags:
  - 反射
  - Java
categories: Java
abbrlink: 40692
date: 2021-04-16 16:00:16
---

<!--more-->

### 什么是反射？

反射是在运行状态中，**对于任意一个类，** 都能够知道这个类的所有属性和方法；**对于任意一个对象，** 都能够调用它的任意一个方法和属性；这种**动态获取的信息以及动态调用对象的方法**的功能称为 Java 语言的反射机制。

### 哪里用到反射机制？

1. JDBC中，利用反射 **(Class.forName(xxx))** 动态加载了数据库驱动程序。
2. Web服务器中利用反射调用了Sevlet的服务方法。
3. Eclispe等开发工具利用反射动态刨析对象的类型与结构，动态提示对象的属性和方法。
4. 很多框架都用到反射机制，注入属性，调用方法，如Spring。

### 反射的基本原理(一)

我们根据方法的反射调用来分析下源码，看看Method.invoke是如何实现的。

```java
@CallerSensitive
    public Object invoke(Object obj, Object... args)
        throws IllegalAccessException, IllegalArgumentException,
           InvocationTargetException
    {
        if (!override) {
            if (!Reflection.quickCheckMemberAccess(clazz, modifiers)) {
                Class<?> caller = Reflection.getCallerClass();
                checkAccess(caller, clazz, obj, modifiers);
            }
        }
        MethodAccessor ma = methodAccessor;             // read volatile
        if (ma == null) {
            ma = acquireMethodAccessor();
        }
        return ma.invoke(obj, args);
    }
```

通过源码可以看到其实invoke方法实际上是委派给了MethodAccessor来处理，MethodAccessor是一个接口，有两个具体实现方法（methodAccessorImpl 是一个抽象的实现方法另外两个实现对象继承此对象），委托实现和本地实现。从代码中可以看到第一次调用时本地methodAccessor是空，所以会调用acquireMethodAccessor（）方法。

![20210828220415](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210828220415.png)

接下来看下获取MethodAccessor实现方法，首先检查是否已经创建，如果创建了就使用创建的，如果没有创建就调用工厂方法创建一个。

```java
private MethodAccessor acquireMethodAccessor() {
        // 首先检查是否已经创建了实现，如果创建了就使用创建的，如果没有就地要用工厂方法创建一个
        MethodAccessor tmp = null;
        if (root != null) tmp = root.getMethodAccessor();
        if (tmp != null) {
            methodAccessor = tmp;
        } else {
            // Otherwise fabricate one and propagate it up to the root
            tmp = reflectionFactory.newMethodAccessor(this);
            setMethodAccessor(tmp);
        }

        return tmp;
    }
```

看下反射工厂的newMethodAccessor 方法，从下面可以看到先是检查初始化，然后判断是否开启动态代理实现，如果开启了就会使用动态实现方式（直接生成字节码方式），如果没有开启就会生成一个委派实现，委派实现的具体实现是使用本地实现来完成。

```java
public MethodAccessor newMethodAccessor(Method var1) {
        checkInitted();
        if (noInflation && !ReflectUtil.isVMAnonymousClass(var1.getDeclaringClass())) {
            return (new MethodAccessorGenerator()).generateMethod(var1.getDeclaringClass(), var1.getName(), var1.getParameterTypes(), var1.getReturnType(), var1.getExceptionTypes(), var1.getModifiers());
        } else {
            NativeMethodAccessorImpl var2 = new NativeMethodAccessorImpl(var1);
            DelegatingMethodAccessorImpl var3 = new DelegatingMethodAccessorImpl(var2);
            var2.setParent(var3);
            return var3;
        }
    }
```

看到这里可能会有一个疑问，为什么使用委派实现穿插在中间，这是因为Java反射实现机制还有一种动态生成字节码，通过invoke指令直接调用目标的方法，委派实现是为了在动态实现和本地实现之间进行切换。

动态实现和本地实现相比，执行速度要快上20倍，这是因为动态实现直接执行字节码，不用从java到c++ 再到java 的转换，但是因为生成字节码的操作比较耗费时间，所以如果仅一次调用的话反而是本地时间快3到4倍。

为了防止很多反射调用只调用一次，java 虚拟机设置了一个阀值等于15（通过-Dsun.reflect.inflationThreshold 参数来调整），当一个反射调用次数达到15次时，委派实现的委派对象由本地实现转换为动态实现，这个过程称之为Inflation。

反射调用的Inflation机制可以通过参数（-Dsun.reflect.noInflation=true）来关闭（对应代码是newMethodAccessor 方法中的if 判断）。这样在反射调用开始的时候就会直接使用动态实现，而不会使用委派实现或者本地实现。

### 反射的基本原理(二)

#### 整体流程

调用反射的总体流程如下：

* **准备阶段**：编译期装载所有的类，将每个类的元信息保存至Class类对象中，每一个类对应一个Class对象
* **获取Class对象**：调用x.class/x.getClass()/Class.forName() 获取x的Class对象clz（这些方法的底层都是native方法，是在JVM底层编写好的，涉及到了JVM底层，就先不进行探究了）
* **进行实际反射操作**：通过clz对象获取Field/Method/Constructor对象进行进一步操作

整体过程中，需要注意的是进行实际反射操作的这个阶段，我们需要关注的点有：

* 我们是如何通过Class获取到Field/Method/Construcor的？
* 获取到的Field是如何具有对象属性值的？
* 获取到的Method是如何调用的？

下面就来详细解释这些问题：

#### 如何通过Class获取Field/Method/Construcor

探究Class类源码的时候，我们发现Class类中包含的ReflectionData，用于保存进行反射操作的基础信息

![20210829001652](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210829001652.png)

这显然是我们获取Field/Method/Constructor的直接来源，那么这个数据结构中的值又是从哪里来的呢？我们以Field的获取为例进行探究，我们先看看getDeclaredField这个方法：

![20210829001710](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210829001710.png)

内部调用了privateGetDeclaredFields方法，我们进去看：

![20210829001731](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210829001731.png)

第一处是从reflectionData直接取，reflectionData是弱引用，这算是一种缓存获取；第二处是直接调用getDeclaredFields0()这个方法获取，这是一个native方法，应当是从JVM内直接获取

至于Method和Constructor的获取则是大同小异，

至此我们基本搞清楚了Class是如何获取Field/Method/Constructor的了

#### Field是如何具有对象属性值

很显然，因为Field对象是来自JVM的，JVM中自然保存着对象的详细属性值，因此通过反射获取到的Field就能包含着原始对象的属性值

#### 获取到的Method如何调用

通过对源码的查看，调用Method的过程大致如下：

![20210829001819](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210829001819.png)

如上图所示，我们大致经历了一个这样的过程：

* Method对象通过MethodAcessor的invoke调用方法 ->
* 通过反射工厂生成MethodAcessor对象 ->
* 生成NativeMethodAcessorImpl，最终由DelegatingMethodAccessorImpl代理 ->
* 调用时先进入的是DelegatingMethodAccessorImpl的invoke方法 ->
* DelegatingMethodAcessorImpl是代理对象，实质上最终调用的是NativeMethodAcessorImpl的invoke方法
* 所有的方法反射都是先走NativeMethodAccessorImpl，默认调了15次之后，才生成一个GeneratedMethodAccessorXXX类，生成好之后就会走这个生成的类的invoke方法了

> 最后一点调用十五次阈值的原因在于：存在两种MethodAcessor，Native 版本一开始启动快，但是随着运行时间边长，速度变慢。Java 版本一开始加载慢，但是随着运行时间边长，速度变快。正是因为两种存在这些问题，所以第一次加载的时候我们会发现使用的是 NativeMethodAccessorImpl 的实现，而当反射调用次数超过 15 次之后，则使用 MethodAccessorGenerator 生成的 MethodAccessorImpl 对象去实现反射。

这其实是借助代理模式实现了一个性能优化手段，这种利用代理模式灵活适配的思想很值得学习。  

### 反射调用的性能开销

接下来我们就来看下反射调用的性能开销，在反射调用方法的例子中，我们先后调用了Class.forName,Class.getMethod,以及Method.invoke 三个操作。其中Class.forName 会调用本地方法，Class.getMethod 会遍历该类的公有方法。如果没有匹配到它还会遍历父级的公有方法，可以知道这两个操作非常耗费时间。

值得注意的是，以getMethod 方法为代表的查询操作，会返回一份查询结果的拷贝信息。因此我们避免在热点代码中使用返回Method数组的getMethods 或者getDeclareMethods方法，以减少不必要的堆空间的消耗。

在实际的开发中 ，我们通常会在应用程序中缓存Class.forName 和 Class.getMethod 的结果。因为下面我们就针对Method.invoke 反射调用的性能开销进行分析。

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
