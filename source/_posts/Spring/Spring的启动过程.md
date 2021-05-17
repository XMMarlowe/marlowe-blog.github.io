---
title: Spring的启动过程
author: Marlowe
tags: Spring
categories: Spring
abbrlink: 34967
date: 2021-05-16 15:51:21
---

<!--more-->

spring的启动是建筑在servlet容器之上的，所有web工程的初始位置就是web.xml,它配置了servlet的上下文（context）和监听器（Listener），下面就来看看web.xml里面的配置：

```xml
<!--上下文监听器，用于监听servlet的启动过程-->
<listener>
        <description>ServletContextListener</description>
      <!--这里是自定义监听器，个性化定制项目启动提示-->
        <listener-class>com.trace.app.framework.listeners.ApplicationListener</listener-class>
    </listener>

<!--dispatcherServlet的配置，这个servlet主要用于前端控制，这是springMVC的基础-->
    <servlet>
        <servlet-name>service_dispatcher</servlet-name>
        <servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
        <init-param>
            <param-name>contextConfigLocation</param-name>
            <param-value>/WEB-INF/spring/services/service_dispatcher-servlet.xml</param-value>
        </init-param>
        <load-on-startup>1</load-on-startup>
    </servlet>

<!--spring资源上下文定义，在指定地址找到spring的xml配置文件-->
    <context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/spring/application_context.xml</param-value>
    </context-param>
<!--spring的上下文监听器-->
    <listener>
        <listener-class>
            org.springframework.web.context.ContextLoaderListener
        </listener-class>
    </listener>

<!--Session监听器，Session作为公共资源存在上下文资源当中，这里也是自定义监听器-->
    <listener>
        <listener-class>
            com.trace.app.framework.listeners.MySessionListener
        </listener-class>
    </listener>
```
接下来就一点的来解析这样一个启动过程。

### spring的上下文监听器

代码如下：

```xml
<context-param>
        <param-name>contextConfigLocation</param-name>
        <param-value>/WEB-INF/spring/application_context.xml</param-value>
</context-param>

<listener>
        <listener-class>
            org.springframework.web.context.ContextLoaderListener
        </listener-class>
 </listener>
```

spring的启动其实就是IOC容器的启动过程，通过上述的第一段配置`<context-param>`是初始化上下文，然后通过后一段的的<listener>来加载配置文件，其中调用的spring包中的`ContextLoaderListener`这个上下文监听器，`ContextLoaderListener`是一个实现了`ServletContextListener`接口的监听器，他的父类是 `ContextLoader`，在启动项目时会触发`contextInitialized`上下文初始化方法。下面我们来看看这个方法：

```java
public void contextInitialized(ServletContextEvent event) {
        initWebApplicationContext(event.getServletContext());
}
```
可以看到，这里是调用了父类`ContextLoader`的`initWebApplicationContext(event.getServletContext())`;方法，很显然，这是对ApplicationContext的初始化方法，也就是到这里正是进入了springIOC的初始化。

接下来再来看看`initWebApplicationContext`又做了什么工作，先看看代码：

```java
if (servletContext.getAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE) != null) {
            throw new IllegalStateException(
                    "Cannot initialize context because there is already a root application context present - " +
                    "check whether you have multiple ContextLoader* definitions in your web.xml!");
        }

        Log logger = LogFactory.getLog(ContextLoader.class);
        servletContext.log("Initializing Spring root WebApplicationContext");
        if (logger.isInfoEnabled()) {
            logger.info("Root WebApplicationContext: initialization started");
        }
        long startTime = System.currentTimeMillis();

        try {
            // Store context in local instance variable, to guarantee that
            // it is available on ServletContext shutdown.
            if (this.context == null) {
                this.context = createWebApplicationContext(servletContext);
            }
            if (this.context instanceof ConfigurableWebApplicationContext) {
                ConfigurableWebApplicationContext cwac = (ConfigurableWebApplicationContext) this.context;
                if (!cwac.isActive()) {
                    // The context has not yet been refreshed -> provide services such as
                    // setting the parent context, setting the application context id, etc
                    if (cwac.getParent() == null) {
                        // The context instance was injected without an explicit parent ->
                        // determine parent for root web application context, if any.
                        ApplicationContext parent = loadParentContext(servletContext);
                        cwac.setParent(parent);
                    }
                    configureAndRefreshWebApplicationContext(cwac, servletContext);
                }
            }
            servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, this.context);

            ClassLoader ccl = Thread.currentThread().getContextClassLoader();
            if (ccl == ContextLoader.class.getClassLoader()) {
                currentContext = this.context;
            }
            else if (ccl != null) {
                currentContextPerThread.put(ccl, this.context);
            }

            if (logger.isDebugEnabled()) {
                logger.debug("Published root WebApplicationContext as ServletContext attribute with name [" +
                        WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE + "]");
            }
            if (logger.isInfoEnabled()) {
                long elapsedTime = System.currentTimeMillis() - startTime;
                logger.info("Root WebApplicationContext: initialization completed in " + elapsedTime + " ms");
            }

            return this.context;
        }
        catch (RuntimeException ex) {
            logger.error("Context initialization failed", ex);
            servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, ex);
            throw ex;
        }
        catch (Error err) {
            logger.error("Context initialization failed", err);
            servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, err);
            throw err;
        }
```

这个方法还是有点长的，其实仔细看看，出去异常错误处理，这个方法主要做了三件事：

1. 创建WebApplicationContext。
2. 加载对应的spring配置文件中的Bean。
3. 将WebApplicationContext放入ServletContext（Java Web的全局变量）中。

上述代码中`createWebApplicationContext(servletContext)`方法即是完成创建WebApplicationContext工作，也就是说这个方法创建爱你了上下文对象，支持用户自定义上下文对象，但必须继承ConfigurableWebApplicationContext，而Spring MVC默认使用ConfigurableWebApplicationContext作为ApplicationContext（它仅仅是一个接口）的实现。

再往下走，有一个方法`configureAndRefreshWebApplicationContext`就是用来加载spring配置文件中的Bean实例的。这个方法于封装ApplicationContext数据并且初始化所有相关Bean对象。它会从web.xml中读取名为 contextConfigLocation的配置，这就是spring xml数据源设置，然后放到ApplicationContext中，最后调用**传说中的**`refresh`方法执行所有Java对象的创建。

最后完成ApplicationContext创建之后就是将其放入ServletContext中，注意它存储的key值常量。

```java
servletContext.setAttribute(WebApplicationContext.ROOT_WEB_APPLICATION_CONTEXT_ATTRIBUTE, this.context);
```

### 启动流程图

![20210516155634](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210516155634.png)

### Spring 启动过程

使用AnnotationConfigApplicationContext来跟踪一下启动流程:
* **this()：** 初始化reader和scanner
* **scan(basePackages)：** 使用scanner组件扫描basePackage下的所有对象，将配置类的BeanDefinition注册到容器中。
* **refresh()：** 刷新容器。

**prepareRefresh：** 刷新前的预处理

**obtainFreshBeanFactory:** 获取在容器初始化时创建的BeanFactory

**prepareBeanFactory:** BeanFactory的预处理工作，会向容器中添加一些组件。

**postProcessBeanFactory:** 子类重写该方法， 可以实现在BeanFactory创建并预处理完成后做进一步的设置。

**invokeBeanFactoryPostProcessors:** 在BeanFactory初始化之 后执行BeanFactory的后处理器。

**registerBeanPostProcessors:** 向容器中注册Bean的后处理器 ，他的主要作用就是干预Spring初始化Bean的流程， 完成代理、自动注入、循环依赖等这些功能。

**initMessageSource:** 初始化messagesource组件， 主要用于国际化。

**initApplicationEventMulticaster:** 初始化事件分发器

**onRefresh:** 留给子容器，子类重写的方法，在容器刷新的时候可以自定义一些逻辑。

**registerListeners:** 注册监听器。

**finishBeanFactoryInitialization:** 完成BeanFactory的初始化， 主要作用是初始化所有剩下的单例Bean。

**finishRefresh:** 完成整个容器的初始化，发布BeanFactory容器刷新完成的事件。|





### 总结

1. 首先，对于一个web应用，其部署在web容器中，web容器提供其一个全局的上下文环境，这个上下文就是ServletContext，其为后面的spring IoC容器提供宿主环境；

2. 其次，在web.xml中会提供有`contextLoaderListener`。在web容器启动时，会触发容器初始化事件，此时 `contextLoaderListener`会监听到这个事件，其`contextInitialized`方法会被调用，在这个方法中，spring会初始 化一个启动上下文，这个上下文被称为根上下文，即`WebApplicationContext`，这是一个接口类，确切的说，其实际的实现类是 `XmlWebApplicationContext`。这个就是spring的IoC容器，其对应的Bean定义的配置由web.xml中的 context-param标签指定。在这个IoC容器初始化完毕后，spring以`WebApplicationContext.ROOTWEBAPPLICATIONCONTEXTATTRIBUTE`为属性Key，将其存储到ServletContext中，便于获取；

3. 再次，`contextLoaderListener`监听器初始化完毕后，开始初始化web.xml中配置的Servlet，这里是DispatcherServlet，这个servlet实际上是一个标准的前端控制器，用以转发、匹配、处理每个servlet请 求。DispatcherServlet上下文在初始化的时候会建立自己的IoC上下文，用以持有spring mvc相关的bean。在建立DispatcherServlet自己的IoC上下文时，会利用`WebApplicationContext.ROOTWEBAPPLICATIONCONTEXTATTRIBUTE`先从ServletContext中获取之前的根上下文(即WebApplicationContext)作为自己上下文的parent上下文。有了这个 parent上下文之后，再初始化自己持有的上下文。这个DispatcherServlet初始化自己上下文的工作在其initStrategies方 法中可以看到，大概的工作就是初始化处理器映射、视图解析等。这个servlet自己持有的上下文默认实现类也是 `XmlWebApplicationContext`。初始化完毕后，spring以与servlet的名字相关(此处不是简单的以servlet名为 Key，而是通过一些转换，具体可自行查看源码)的属性为属性Key，也将其存到ServletContext中，以便后续使用。这样每个servlet 就持有自己的上下文，即拥有自己独立的bean空间，同时各个servlet共享相同的bean，即根上下文(第2步中初始化的上下文)定义的那些 bean。

### 参考

[Spring的启动流程](https://www.jianshu.com/p/280c7e720d0c)

好文推荐：[【Spring启动过程分析】启动流程简介](https://blog.csdn.net/csdnlijingran/article/details/88666611)

好文推荐：[SPRING容器启动过程](https://zhuanlan.zhihu.com/p/32830470)





