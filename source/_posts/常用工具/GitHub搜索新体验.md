---
title: GitHub搜索新体验
author: Marlowe
tags: GitHub
categories: 常用工具
abbrlink: 42585
date: 2021-08-15 21:59:53
---

简单介绍GitHub一些常用操作
<!--more-->

### GitHub操作之in限制搜索

in关键词限制搜索范围：

* 公式 ：xxx(关键词) in:name或description或readme
  * xxx in:name 项目名包含xxx的
  * xxx in:description 项目描述包含xxx的
  * xxx in:readme 项目的readme文件中包含xxx的组合使用
* 组合使用
  * 搜索项目名或者readme中包含秒杀的项目
  * xxx in:name,readme

### GitHub作之star和fork范围搜索

* 公式：
  * xxx关键字 stars 通配符 :> 或者 :>=
  * 区间范围数字： stars:数字1…数字2
* 案例
  * 查找stars数大于等于5000的springboot项目：springboot stars:>=5000
  * 查找forks数在1000~2000之间的springboot项目：springboot forks:1000…5000
* 组合使用
  * 查找star大于1000，fork数在500到1000的springboot项目：springboot stars:>1000 forks:500…1000

### GitHub操作之awesome搜索

* 公式：awesome 关键字：awesome系列，一般用来收集学习、工具、书籍类相关的项目
* 搜索优秀的redis相关的项目，包括框架，教程等 awesome redis

### GitHub操作之#L数字

* 一行：地址后面紧跟 #L10
  * https://github.com/abc/abc/pom.xml#L13
* 多行：地址后面紧跟 #Lx - #Ln
  * https://github.com/moxi624/abc/abc/pom.xml#L13-L30


### GitHub操作之T搜索

在项目仓库下按键盘T，进行项目内搜索

![20210821103849](https://marlowe.oss-cn-beijing.aliyuncs.com/img/20210821103849.png)

[更多github快捷键](https://docs.github.com/en/get-started/using-github/keyboard-shortcuts)

### GitHub操作之搜索区域活跃用户

* location：地区
* language：语言
* 例如：location:beijing language:java