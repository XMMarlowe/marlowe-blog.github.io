---
title: Shiro原理及执行流程
author: Marlowe
tags: Shiro
categories: 权限
abbrlink: 57130
date: 2021-08-03 19:48:05
---
Shiro 是一个功能强大且易于使用的Java安全框架，它执行身份验证、授权、加密和会话管理。使用Shiro易于理解的API，您可以快速轻松地保护任何应用程序—从最小的移动应用程序到最大的web和企业应用程序。
<!--more-->

### Shiro的核心架构

![image-20200520220413190](https://marlowe.oss-cn-beijing.aliyuncs.com/img/image-20200520220413190.png)

#### 1、Subject

`Subject即主体`，外部应用与subject进行交互，subject记录了当前操作用户，将用户的概念理解为当前操作的主体，可能是一个通过浏览器请求的用户，也可能是一个运行的程序。	Subject在shiro中是一个接口，接口中定义了很多认证授相关的方法，外部程序通过subject进行认证授，而subject是通过SecurityManager安全管理器进行认证授权

#### 2、SecurityManager

`SecurityManager即安全管理器`，对全部的subject进行安全管理，它是shiro的核心，负责对所有的subject进行安全管理。通过SecurityManager可以完成subject的认证、授权等，实质上SecurityManager是通过Authenticator进行认证，通过Authorizer进行授权，通过SessionManager进行会话管理等。

`SecurityManager是一个接口，继承了Authenticator, Authorizer, SessionManager这三个接口。`

#### 3、Authenticator

`Authenticator即认证器`，对用户身份进行认证，Authenticator是一个接口，shiro提供ModularRealmAuthenticator实现类，通过ModularRealmAuthenticator基本上可以满足大多数需求，也可以自定义认证器。

#### 4、Authorizer

`Authorizer即授权器`，用户通过认证器认证通过，在访问功能时需要通过授权器判断用户是否有此功能的操作权限。

#### 5、Realm

`Realm即领域`，相当于datasource数据源，securityManager进行安全认证需要通过Realm获取用户权限数据，比如：如果用户身份数据在数据库那么realm就需要从数据库获取用户身份信息。

- ​	注意：不要把realm理解成只是从数据源取数据，在realm中还有认证授权校验的相关的代码。

#### 6、SessionManager

`sessionManager即会话管理`，shiro框架定义了一套会话管理，它不依赖web容器的session，所以shiro可以使用在非web应用上，也可以将分布式应用的会话集中在一点管理，此特性可使它实现单点登录。

#### 7、SessionDAO

`SessionDAO即会话dao`，是对session会话操作的一套接口，比如要将session存储到数据库，可以通过jdbc将会话存储到数据库。

#### 8、CacheManager

`CacheManager即缓存管理`，将用户权限数据存储在缓存，这样可以提高性能。

#### 9、Cryptography

​	`Cryptography即密码管理`，shiro提供了一套加密/解密的组件，方便开发。比如提供常用的散列、加/解密等功能。

### Shiro中的认证

#### 1、认证

身份认证，就是判断一个用户是否为合法用户的处理过程。最常用的简单身份认证方式是系统通过核对用户输入的用户名和口令，看其是否与系统中存储的该用户的用户名和口令一致，来判断用户身份是否正确。

#### 2、shiro中认证的关键对象

- **Subject：主体**

访问系统的用户，主体可以是用户、程序等，进行认证的都称为主体； 

- **Principal：身份信息**

是主体（subject）进行身份认证的标识，标识必须具有`唯一性`，如用户名、手机号、邮箱地址等，一个主体可以有多个身份，但是必须有一个主身份（Primary Principal）。

- **credential：凭证信息**

是只有主体自己知道的安全信息，如密码、证书等。

#### 3、认证流程

![20210817233539](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210817233539.png)

### Shiro中的授权

#### 1、授权

授权，即访问控制，控制谁能访问哪些资源。主体进行身份认证后需要分配权限方可访问系统的资源，对于某些资源没有权限是无法访问的。

#### 2、关键对象

**授权可简单理解为who对what(which)进行How操作：**

`Who，即主体（Subject）`，主体需要访问系统中的资源。

`What，即资源（Resource)`，如系统菜单、页面、按钮、类方法、系统商品信息等。资源包括`资源类型`和`资源实例`，比如`商品信息为资源类型`，类型为t01的商品为`资源实例`，编号为001的商品信息也属于资源实例。

`How，权限/许可（Permission)`，规定了主体对资源的操作许可，权限离开资源没有意义，如用户查询权限、用户添加权限、某个类方法的调用权限、编号为001用户的修改权限等，通过权限可知主体对哪些资源都有哪些操作许可。

#### 3、授权流程

![20210817233657](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210817233657.png)