---
title: SpringCloud和SpringCloud Alibaba的区别？
author: Marlowe
tags:
  - SpringCloud
  - SpringCloud Alibaba
categories: 分布式&微服务
abbrlink: 19519
date: 2021-08-27 22:58:52
---

<!--more-->

### 前言

现在软件后端开发普遍都偏向微服务开发了，而我们Java程序员开发有谁不知道 Spring呢？

Spring社区有大一统java的趋势，快速构建一个单体单元 SpringBoot，分布式微服务解决方案 SpringCloud以及核心的 SpringFrameWork和各种组件等等。

今天的主角之一就是 SpringCloud，它是一个分布式的微服务解决方案。区别于 Dubbo， Dubbo只是一个远程rpc调用框架。而前者则是一整套的解决方案，包括**服务注册、服务调用、负载均衡、服务网关、服务降级与熔断、分布式配置管理、消息总线**等等技术。也就是说 SpringCloud自成一个生态。

### 正文

那么 SpringCloud用的这么爽，为啥还需要 SpringCloudAlibaba呢？

所谓一句话“**新东西的出现必然是因为市场需求的需要**“。我们开发人员或者准开发人员有了这个需求了。因为 SpringCloud进入到了维护阶段

首先因为 SpringCloud版本迭代非常快，每发布一个realease之后又会紧接着发布下一个版本，所以可能会积累一系列的bug，日积月累的使用肯定会出现这样那样的问题。

进入到维护模式，意味着不会再有新的组件技术出现。只是在原来的基础上修修补补，处理一些merge和PR请求。

技术上不更新，总要有人去做的吧，几年前 Dubbo被 SpringCloud所取代。相同的剧本，可惜阿里巴巴和 Spring社区都是巨头，巨头之间战斗要考虑很多，于是它们想到了合作， SpringCloud与alibaba相结合，技术上有人负责更新新的组件，也还可以继续使用 Spring社区的技术，阿里另外一方面也可以推广一波阿里云和各种商业软件，双赢局面。于是 SpringCloudAlibaba诞生了。

![20210827233526](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210827233526.png)

### Spring Cloud Alibaba

Spring Cloud Alibaba是Spring cloud的子项目，符合SpringCloud的标准，致力于提供微服务开发的一站式解决方案。此项目包含开发分布式应用微服务的必需组件，方便开发者通过 Spring Cloud 编程模型轻松使用这些组件来开发分布式应用服务。

依托 Spring Cloud Alibaba，您只需要添加一些注解和少量配置，就可以将 Spring Cloud 应用接入阿里微服务解决方案，通过阿里中间件来迅速搭建分布式应用系统。

同 Spring Cloud 一样，Spring Cloud Alibaba 也是一套微服务解决方案，包含开发分布式应用微服务的必需组件，方便开发者通过 Spring Cloud 编程模型轻松使用这些组件来开发分布式应用服务。

依托 Spring Cloud Alibaba，您只需要添加一些注解和少量配置，就可以将 Spring Cloud 应用接入阿里微服务解决方案，通过阿里中间件来迅速搭建分布式应用系统。

#### 主要功能

* **服务限流降级**：默认支持 WebServlet、WebFlux, OpenFeign、RestTemplate、Spring Cloud Gateway, Zuul, Dubbo 和 RocketMQ 限流降级功能的接入，可以在运行时通过控制台实时修改限流降级规则，还支持查看限流降级 Metrics 监控。
* **服务注册与发现**：适配 Spring Cloud 服务注册与发现标准，默认集成了 Ribbon 的支持。
* **分布式配置管理**：支持分布式系统中的外部化配置，配置更改时自动刷新。
* **消息驱动能力**：基于 Spring Cloud Stream 为微服务应用构建消息驱动能力。
* **分布式事务**：使用 @GlobalTransactional 注解， 高效并且对业务零侵入地解决分布式事务问题。
* **阿里云对象存储**：阿里云提供的海量、安全、低成本、高可靠的云存储服务。支持在任何应用、任何时间、任何地点存储和访问任意类型的数据。
* **分布式任务调度**：提供秒级、精准、高可靠、高可用的定时（基于 Cron 表达式）任务调度服务。同时提供分布式的任务执行模型，如网格任务。网格任务支持海量子任务均匀分配到所有 Worker（schedulerx-client）上执行。
* **阿里云短信服务**：覆盖全球的短信服务，友好、高效、智能的互联化通讯能力，帮助企业迅速搭建客户触达通道。

作为 Spring Cloud 体系下的新实现，Spring Cloud Alibaba 跟官方的组件或其它的第三方实现如 Netflix, Consul，Zookeeper 等对比，具备了更多的功能:

![20210827233807](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210827233807.png)

### Spring Cloud Alibaba 包含组件

#### 组件

##### Sentinel

阿里巴巴开源产品，把流量作为切入点，从流量控制、熔断降级、系统负载保护等多个维度保护服务的稳定性。

##### Nacos

阿里巴巴开源产品，一个更易于构建云原生应用的动态服务发现、配置管理和服务管理平台。

##### RocketMQ

Apache RocketMQ™ 基于 Java 的高性能、高吞吐量的分布式消息和流计算平台。

##### Dubbo

Apache Dubbo™ 是一款高性能 Java RPC 框架。

##### Seata

阿里巴巴开源产品，一个易于使用的高性能微服务分布式事务解决方案。

##### Alibaba Cloud OSS

阿里云对象存储服务（Object Storage Service，简称 OSS），是阿里云提供的海量、安全、低成本、高可靠的云存储服务。您可以在任何应用、任何时间、任何地点存储和访问任意类型的数据。

##### Alibaba Cloud SchedulerX

阿里中间件团队开发的一款分布式任务调度产品，支持周期性的任务与固定时间点触发任务。

##### Alibaba Cloud SMS

覆盖全球的短信服务，友好、高效、智能的互联化通讯能力，帮助企业迅速搭建客户触达通道。

这幅图是 Spring Cloud Alibaba 系列组件，其中包含了阿里开源组件，阿里云商业化组件，以及集成Spring Cloud 组件。

![20210827234023](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210827234023.png)

![20210827234036](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210827234036.png)

Spring Cloud Alibaba 虽然诞生时间不久，但是背靠大树好乘凉，赖于阿里巴巴强大的技术影响力，已经成为微服务解决方案的重要选择之一。如果使用了SpringCloudAlibaba，最好使用alibaba整个体系产品。

#### 总结

我认为 Spring Cloud Alibaba的优势有以下几点：

##### 阿里巴巴强大的技术输出能力

阿里巴巴无疑是国内开源技术领域的最有影响力的公司之一，已经有Dubbo、Druid，FastJson等成功的开源组件，再加上阿里不遗余力的推广，社区发展也非常快，并且国内很多大厂名企，都在使用并且API都是中文。

##### 搭建简单，学习成本低

##### 良好的可视化界面

##### 集成Dubbo

利用Dubbo在微服务领域的超高人气Dubbo是国内应用最广的分布式服务框架之一，基于Dubbo改造的Dubbox等也有很多公司在使用，

Spring Cloud Alibaba对Dubbo做了比较好的集成，可以吸引不少使用Dubbo的开发者。

##### 云原生趋势

集成阿里云商业化组件云原生（Cloud Native）是今年技术领域特别热门的一个词，云原生是一种专门针对云上应用而设计的方法，用于构建和部署应用，以充分发挥云计算的优势。

Spring Cloud Alibaba 集成了阿里云的商业化组件，可以说天然支持云原生特性。

