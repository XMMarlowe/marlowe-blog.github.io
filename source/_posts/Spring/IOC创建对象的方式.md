---
title: IOC创建对象的方式
author: Marlowe
tags:
  - IOC
  - Spring
categories: Spring
abbrlink: 7420
date: 2020-12-04 21:02:41
---

IOC创建对象的三种方式...
<!--more-->

1. 下标

```java
<!--第一种方式：下标赋值-->
<bean id="user" class="com.marlowe.pojo.User">
    <constructor-arg index="0" value="狂神说Java"></constructor-arg>
</bean>
```
2. 类型

```java
<!--第二种方式：不建议使用！通过类型创建-->
<bean id="user" class="com.marlowe.pojo.User">
    <constructor-arg type="java.lang.String" value="狂神"></constructor-arg>
</bean>
```

3. 参数名

```java
<!--第三种方式，直接通过参数名来设置-->
<bean id="user" class="com.marlowe.pojo.User">
    <constructor-arg name="name" value="狂神说Java"></constructor-arg>
</bean>
```

总结：在配置文件加载的时候，容器中管理的对象就已经初始化了！