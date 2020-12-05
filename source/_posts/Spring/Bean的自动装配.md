---
title: Bean的自动装配
author: Marlowe
tags:
  - Bean
  - Spring
categories: Spring
abbrlink: 47955
date: 2020-12-05 11:55:53
---
bean的三种自动装配方式...
<!--more-->

* 自动装配是Spring满足bean依赖的一种方式
* Spring会在上下文中自动寻找，并自动给bean装配属性

在Spring中有三种装配方式
1. 在xml中显示的配置
2. 在java中显示配置
3. 隐式的自动装配bean【重要】

### 测试
环境搭建：一个人有两个宠物
```java
public class People {
    private String name;
    private Cat cat;
    private Dog dog;
}
```
#### byName自动装配
```xml
<!--
byName:会自动在容器上下文中查找和自己对象set方法后面的值对应的bean id！
-->
<bean id="people" class="com.marlowe.pojo.People" autowire="byName">
    <property name="name" value="陈浩南"/>
</bean>
```

#### byType自动装配
```xml
<bean class="com.marlowe.pojo.Cat"/>
<bean class="com.marlowe.pojo.Dog"/>
<!--
byName:会自动在容器上下文中查找，和自己对象set方法后面的值对应的bean id！
byType:会自动在容器上下文中查找，和自己对象属性类型相同的bean！
-->
<bean id="people" class="com.marlowe.pojo.People" autowire="byType">
    <property name="name" value="陈浩南"/>
</bean>
```

小结：
* byName的时候，需要保证所有bean的id唯一，并且这个bean需要和自动注入的属性的set方法的值一致！**（原理是将set方法后面部分转换成小写，再与id进行比对，例如：setDog ==> id = "dog"、setdog1 ==> id = "dog1"等可以自动注入、但是setDog ==> id = "Dog"就不行）**
* byType的时候，需要保证所有bean的class唯一，并且这个bean需要和自动注入的属性的类型一致！

#### 使用注解实现自动装配

JDK1.5支持的注解，Spring2.5就支持注解了！
要使用注解须知：
1. 导入约束。context约束
2. 配置注解的支持 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:context="http://www.springframework.org/schema/context"
    xsi:schemaLocation="http://www.springframework.org/schema/beans
        https://www.springframework.org/schema/beans/spring-beans.xsd
        http://www.springframework.org/schema/context
        https://www.springframework.org/schema/context/spring-context.xsd">

    <context:annotation-config/>

</beans>
```
**@Autowired**
 直接在属性上使用即可！也可以在set方式上使用！
 使用Autowired，我们可以不用编写set方法了，前提是你这个自动装配的属性在IOC（Spring）容器中存在，且符合名字byName！

 科普：
 ```java
 @Nullable  字段标记了这个注解，说明这个字段可以为null
 ```
 ```java
 public @interface Autowired {
    boolean required() default true;
}
 ```
 测试代码
 ```java
 public class People {
    // 如果显示定义了Autowired的required属性为false，说明这个对象可以为null，否则不允许为空
    @Autowired(required = false)
    private Cat cat;
    @Autowired
    private Dog dog;
    private String name;
 }
 ```

如果@Autowired自动装配的环境比较复杂，自动装配无法通过一个注解【@Autowired】完成额时候、我们可以使用@Qualifier(value = "xxx")去配置@Autowired的使用，指定一个唯一的bean对象注入！
```java
@Autowired
@Qualifier(value = "cat11")
private Cat cat;

@Autowired
@Qualifier(value = "dog11")
private Dog dog;
```

**@Resource注解**
```java
public class People {
    @Resource(name = "cat1")
    private Cat cat;

    @Resource
    private Dog dog;
}
```
小结：
@Autowired和@Resource的区别：
* 都是用来自动装配的，都可以放在属性字段上
* @Autowired 通过byType的方式实现，而且必须要求这个对象存在！【常用】
* @Resource默认通过byName的方式实现，如果找不到名字，则通过byType实现！如果两个都找不到的情况下，就报错！【常用】
* 执行顺序不同：@Autowired 通过byType的方式实现。@Resource默认通过byName的方式实现。
