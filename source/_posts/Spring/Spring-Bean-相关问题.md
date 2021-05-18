---
title: Spring Bean 相关问题
author: Marlowe
tags:
  - Spring
  - Bean
categories: Spring
abbrlink: 23081
date: 2021-05-16 11:09:23
---

<!--more-->

### Spring 中 bean 的创建过程

**首先:** 简单来说，Spring框架中的Bean经过四个阶段:实例化 -> 属性赋值 -> 初始化 -> 销毁

**然后:** 具体来说，Spring中Bean 经过了以下几个步骤:

1. 实例化: new xxx(); 两个时机: 1、当客户端向容器申请一 个Bean时，2、 当容器在初始化一 个Bean时发现还需要依赖另一个Bean。BeanDefinition 对象保存。 -- 到底new一个对象还是创建一个动态代理？
2. 设置对象属性(依赖注入): Spring通过BeanDefinition找到对象依赖的其他对象，并将这些对象赋予当前对象。
3. 处理Aware接口: Spring会检测对象是否实现了xxxAware接口，如果实现了，就会调用对应的方法。
BeanNameAware、BeanClassLoaderAware、 BeanFactoryAware、 ApplicationContextAware
4. BeanPostProcessor前置处理: 调用BeanPostProcessor的postProcessBeforelnitialization方法
5. InitializingBean: Spring检测对象如果实现了这个接口， 就会执行他的afterPropertiesSet()方法， 定制初始化逻辑。
6. init-method: `<bean init-method=xXx>` 如果Spring发现Bean配置了这个属性，就会调用他的配置方法，执行初
始化逻辑。@PostConstruct
7. BeanPostProcessor后置处理: 调用BeanPostProcessor的postProcessAfterlnitialization方法

> 到这里，这个Bean的创建过程就完成了，Bean就可以正常使用了。

8. DisposableBean: 当Bean实现了这个接口， 在对象销毁前就会调用destory(方法。
9. destroy-method: `<bean destroy-method=xxx>` @PreDestroy

### Spring 中的 bean 的作用域有哪些?

* **singleton:** 唯一 bean 实例，Spring 中的 bean 默认都是单例的。
* **prototype:** 每次请求都会创建一个新的 bean 实例。
* **request:** 每一次HTTP请求都会产生一个新的bean，该bean仅在当前HTTP request内有效。
* **session:** 每一次HTTP请求都会产生一个新的 bean，该bean仅在当前 HTTP session 内有效。
* **global-session：** 全局session作用域，仅仅在基于portlet的web应用中才有意义，Spring5已经没有了。Portlet是能够生成语义代码(例如：HTML)片段的小型Java Web插件。它们基于portlet容器，可以像servlet一样处理HTTP请求。但是，与 servlet 不同，每个 portlet 都有不同的会话


### Spring 中的单例 bean 的线程安全问题了解吗？

的确是存在安全问题的。因为，当多个线程操作同一个对象的时候，对这个对象的成员变量的写操作会存在线程安全问题。

但是，一般情况下，我们常用的 `Controller`、`Service`、`Dao` 这些 Bean 是无状态的。无状态的 Bean 不能保存数据，因此是线程安全的。

常见的有 2 种解决办法：

1. 在类中定义一个 `ThreadLocal` 成员变量，将需要的可变成员变量保存在 `ThreadLocal` 中（推荐的一种方式）。
2. 改变 Bean 的作用域为 “prototype”：每次请求都会创建一个新的 bean 实例，自然不会存在线程安全问题。

### Spring 框架中的Bean是线程安全的吗？如果线程不安全，要如何处理？

Spring容器本身没有提供Bean的线程安全策略，因此，也可以说Spring容器中的Bean不是线程安全的。

要如何处理线程安全问题，就要分情况来分析。

**Spring中的作用域:**
1、sington 
2、prototype: 为每个Bean请求创建给实例。
3、request: 为每个request请求创建一个实例，请求完成后失效。
4、session: 与request是类似的。 
5、global-session: 全局作用域。

**对于线程安全问题:**

1> 对于prototype作用域，每次都是生成一个新的对象，所以不存在线程安全问题。
2> sington作用域:默认就是线程不完全的。 但是对于开发中大部分的Bean,其实是无状态的，不需要保证线程安全。所以在平常的MVC开发中，是不会有线程安全问题的。

> 无状态表示这个实例没有属性对象，不能保存数据， 是不变的类。比如: controller. service、 dao
有状态表示示例是有属性对象，可以保存数据，是线程不安全的，比如pojo.

但是如果要保证线程安全，可以将Bean的作用域改为prototype比如像Model View。

另外还可以采用ThreadLocal来解决线程安全问题。ThreadLocal为每 个线程保存一个副本变量， 每个线程只操作自己的副本变量。



###  @Component 和 @Bean 的区别是什么？

1. 作用对象不同: `@Component` 注解作用于类，而`@Bean`注解作用于方法。
2. `@Component`通常是通过类路径扫描来自动侦测以及自动装配到Spring容器中（我们可以使用 `@ComponentScan` 注解定义要扫描的路径从中找出标识了需要装配的类自动装配到 Spring 的 bean 容器中）。`@Bean` 注解通常是我们在标有该注解的方法中定义产生这个 bean,`@Bean`告诉了Spring这是某个类的示例，当我需要用它的时候还给我。
3. `@Bean` 注解比 `Component` 注解的自定义性更强，而且很多地方我们只能通过 `@Bean` 注解来注册bean。比如当我们引用第三方库中的类需要装配到`Spring`容器时，则只能通过 `@Bean`来实现。

`@Bean`注解使用示例：

```java
@Configuration
public class AppConfig {
    @Bean
    public TransferService transferService() {
        return new TransferServiceImpl();
    }

}
```
上面的代码相当于下面的 xml 配置

```xml
<beans>
    <bean id="transferService" class="com.acme.TransferServiceImpl"/>
</beans>
```
下面这个例子是通过 @Component 无法实现的。

```java
@Bean
public OneService getService(status) {
    case (status)  {
        when 1:
                return new serviceImpl1();
        when 2:
                return new serviceImpl2();
        when 3:
                return new serviceImpl3();
    }
}
```

### 将一个类声明为Spring的 bean 的注解有哪些?

我们一般使用 `@Autowired` 注解自动装配 bean，要想把类标识成可用于 `@Autowired` 注解自动装配的 bean 的类,采用以下注解可实现：

* **@Component：**通用的注解，可标注任意类为 `Spring` 组件。如果一个Bean不知道属于哪个层，可以使用`@Component` 注解标注。
* **@Repository:** 对应持久层即 Dao 层，主要用于数据库相关操作。
* **@Service:** 对应服务层，主要涉及一些复杂的逻辑，需要用到 Dao层。
* **@Controller:** 对应 Spring MVC 控制层，主要用于接受用户请求并调用 Service 层返回数据给前端页面。

### Spring 中的 bean 生命周期?

* Bean 容器找到配置文件中 Spring Bean 的定义。
* Bean 容器利用 Java Reflection API 创建一个Bean的实例。
* 如果涉及到一些属性值 利用 `set()`方法设置一些属性值。
* 如果 Bean 实现了 `BeanNameAware` 接口，调用 `setBeanName()`方法，传入Bean的名字。
* 如果 Bean 实现了 `BeanClassLoaderAware` 接口，调用 `setBeanClassLoader()`方法，传入 `ClassLoader`对象的实例。
* 与上面的类似，如果实现了其他 `*.Aware`接口，就调用相应的方法。
* 如果有和加载这个 Bean 的 Spring 容器相关的 `BeanPostProcessor` 对象，执行`postProcessBeforeInitialization()` 方法
* 如果Bean实现了`InitializingBean`接口，执行`afterPropertiesSet()`方法。
* 如果 Bean 在配置文件中的定义包含 init-method 属性，执行指定的方法。
* 如果有和加载这个 Bean的 Spring 容器相关的 `BeanPostProcessor` 对象，执行`postProcessAfterInitialization()` 方法
* 当要销毁 Bean 的时候，如果 Bean 实现了 `DisposableBean` 接口，执行 `destroy()` 方法。
* 当要销毁 Bean 的时候，如果 Bean 在配置文件中的定义包含 destroy-method 属性，执行指定的方法。

图示：

![20210516114740](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210516114740.png)

与之比较类似的中文版本:

![20210516114807](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210516114807.png)

### 参考

[Spring bean](https://snailclimb.gitee.io/javaguide/#/docs/system-design/framework/spring/Spring%E5%B8%B8%E8%A7%81%E9%97%AE%E9%A2%98%E6%80%BB%E7%BB%93?id=_5-spring-bean)