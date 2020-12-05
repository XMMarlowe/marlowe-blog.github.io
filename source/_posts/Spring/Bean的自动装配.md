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
