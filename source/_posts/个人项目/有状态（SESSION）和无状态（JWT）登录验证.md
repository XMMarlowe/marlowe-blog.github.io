---
title: 有状态（SESSION）和无状态（JWT）登录验证
author: Marlowe
tags:
  - Session
  - Jwt
categories: 个人项目
abbrlink: 56678
date: 2021-08-24 22:33:41
---

简单对比Session和Jwt的优缺点

<!--more-->

### 有状态（SESSION）

所谓有状态，就是的就是传统的 cookie session ，cookie的身份验证是有状态的。这意味着验证的记录或者会话(session)必须同时保存在服务器端和客户端。服务器端需要跟踪记录session并存至数据库，同时前端需要在cookie中保存一个sessionID，作为session的唯一标识符，可看做是session的“身份证”。前端退出的话就清cookie。后端强制前端重新认证的话就清或者修改session。

#### 优点

* 相较于无状态的验证机制，传统的session可以直接从后端主动控制下线，删除session，方便实现互t等功能
* session保存在服务端，相对比较安全
* 有状态的session可以较为准确统计在线人数

#### 缺点

* 有状态的存储session需要服务器空间
* 扩展不方便，需要session同步，借助redis实现共享等

### 无状态（JWT）

#### 优点

* json通用性，方便跨语言
* 不需要在服务端保存会话信息, 易于应用的扩展
* 占用字节很小，方便传输

#### 缺点

* JWT的加解密耗费CPU计算资源
* 不能方便的管理会话
* 注销没有即时性，如果token泄露，注销状态下仍可登录操作