---
title: Spring Gateway、Zuul、Nginx的区别
author: Marlowe
categories: 分布式&微服务
abbrlink: 35733
date: 2021-08-06 20:25:04
tags: 
  - Spring
  - Gateway
  - Nginx
---

Spring Cloud GateWay学习之微服务网关Zuul、Gateway、nginx的区别。

<!--more-->

### Spring Cloud GateWay 是什么

网关，Spring Cloud Gateway是Spring官方基于Spring 5.0，Spring Boot 2.0和Project Reactor等技术开发的网关，Spring Cloud Gateway旨在为微服务架构提供一种简单而有效的统一的API路由管理方式。Spring Cloud Gateway作为Spring Cloud生态系中的网关，目标是替代ZUUL，其不仅提供统一的路由方式，并且基于Filter链的方式提供了网关基本的功能，例如：安全，监控/埋点，和限流等。

#### GateWay整体流程

![20210821142742](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210821142742.png)

### Spring Cloud GateWay 作用

* 协议转换，路由转发
* 流量聚合，对流量进行监控，日志输出
* 作为整个系统的前端工程，对流量进行控制，有限流的作用
* 作为系统的前端边界，外部流量只能通过网关才能访问系统
* 可以在网关层做权限判断
* 可以在网关层做缓存

### 微服务网关Zuul、Gateway、nginx的区别

#### zuul

* 是Netflix的，早期在微服务中使用较广泛，是基于servlet实现的，阻塞式的api，不支持长连接。
* **只能同步，不支持异步。**
* 不依赖spring-webflux，可以扩展至其他微服务框架。
* 内部没有实现限流、负载均衡，其负载均衡的实现是采用 Ribbon  + Eureka 来实现本地负载均衡。
* 代码简单，注释多，易理解。

#### Gateway

* 是springcloud自己研制的微服务网关，是基于Spring5构建，，能够实现响应式非阻塞式的Api，支持长连接。
* **支持异步**。
* **功能更强大，内部实现了限流、负载均衡**等，扩展性也更强。Spring Cloud Gateway明确的区分了 Router 和 Filter，并且一个很大的特点是内置了非常多的开箱即用功能，并且都可以通过 SpringBoot 配置或者手工编码链式调用来使用。
* 依赖于spring-webflux，仅适合于Spring Cloud套件。
* 代码复杂，注释少。

#### nginx

* C语言编写，采用服务器实现负载均衡，高性能的HTTP和反向代理web服务器。

Nginx适合于服务器端负载均衡,Zuul和gateway 是本地负载均衡，适合微服务中实现网关。Spring Cloud Gateway 天然适合Spring Cloud 生态。

### Nginx在微服务中的地位

最后简单聊一下nginx，在过去几年微服务架构还没有流行的日子里，nginx已经得到了广大开发者的认可，其性能高、扩展性强、可以灵活利用lua脚本构建插件的特点让人没有抵抗力。

有一个能满足我所有需求还很方便我扩展的东西，还免费，凭啥不用？？

但是，如今很多微服务架构的项目中不会选择nginx，我认为原因有以下几点：
微服务框架一般来说是配套的，集成起来更容易
如今微服务架构中，仅有很少的公司会面对无法解决的性能瓶颈，而他们也不会因此使用nginx，而是选择开发一套适合自己的微服务框架
spring boot对于一些模板引擎如FreeMarker、themleaf的支持是非常好的，很多应用还没有达到动、静态文件分离的地步，对nginx的需求程度并不大。
无论如何，nginx作为一个好用的组件，最终使不使用它都是由业务来驱动的，只要它能为我们方便的解决问题，那用它又有何不可呢？

### 小结

通过总结发现，在微服务架构中网关上的选择，最好的方式是使用现在比较成熟的Spring Cloud套件，其提供了Spring Cloud Gateway网关，或是结合公司情况来开发一套适合自己的微服务套件，至少从网关上可以看出来其内部实现并不难，同时也比较期待开源项目Nacos、Spring Cloud Alibaba 建设情况，期待它能构建一个高活跃社区的、稳定的、适合中国特色（大流量、高并发）的微服务基础架构。

竞争是发展的催化剂。在这个网关服务层出不穷的年代，各公司都铆足力气打造自己的网关产品，尽量让自己的产品成为用户的第一选择。而广大开发者也在享受这样的红利，使用高性能的网关来开发自己的应用。作为广大开发者的一员，我们欣然接受这样良性竞争的出现，并且也乐于尝试市面上出现的任何新产品，谁也说不准某一个产品以后就会成为优选的代名词。虽然从现在网关的性能差距看来，后发优势明显，但在可预见的将来，各网关迟早会到达性能瓶颈，在性能差距不大并且产品稳定之后，就会有各种差异化特性出现。而等到网关产品进入百舸争流的时代之后，用户就可以不再根据性能，而是根据自己的需求选择适合的网关服务了。


### 参考

[Spring Cloud GateWay学习之微服务网关Zuul、Gateway、nginx的区别和Spring Cloud GateWay的使用。](https://juejin.cn/post/6943147637491105806#heading-7)

