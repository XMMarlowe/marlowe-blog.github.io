---
title: RESTful相关面试题
author: Marlowe
tags: RESTful
categories: 春招面试
abbrlink: 63314
date: 2021-04-10 18:43:48
---
RESTful也可以称为“面向资源编程”。
<!--more-->

### 谈谈对RESTful规范的理解

* RESTful是一套编写接口的协议，协议规定如何编写，以及如何设置返回值，状态码等信息。
* 最显著的特点：
    * RESTful：给用户一个url，根据method不同在后端做不同的处理，比如post 创建数据、get 获取数据、put和patch 修改数据、delete 删除数据。
    * no REST：给调用者很多url，每个url代表一个功能，比如：add_user/delte_user/edit_user/