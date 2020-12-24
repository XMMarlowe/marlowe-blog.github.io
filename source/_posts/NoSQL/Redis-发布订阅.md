---
title: Redis 发布订阅
author: Marlowe
date: 2020-12-24 15:22:32
tags: Redis
categories: NoSQL
--- 
<!--more-->
Redis 发布订阅(pub/sub)是一种消息通信模式：发送者(pub)发送消息，订阅者(sub)接受消息。微博、微信、关注系统！
Redis客户端可以订阅任意数量的频道。
订阅/发布消息图：
第一个：消息发送者，第二个：频道，第三个：消息订阅者
![20201224152827](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201224152827.png)
**使用场景**
1. 实时消息系统
2. 实时聊天(频道当做聊天室，将信息回显给所有人即可)
3. 订阅，关注系统

稍微复杂的场景就会使用消息中间件MQ

