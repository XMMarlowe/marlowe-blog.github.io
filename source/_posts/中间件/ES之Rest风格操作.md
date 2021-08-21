---
title: ES之Rest风格操作
author: Marlowe
tags:
  - RESTful
  - ES
categories: 中间件
abbrlink: 26163
date: 2020-12-08 12:24:51
---
<!--more-->

### 关于索引的基本操作

```java
PUT /索引名/~类型名~/文档id
{请求体}
```
![20201208122740](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208122740.png)

完成了自动增加索引！数据也成功的添加了
![20201208122933](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208122933.png)

**指定字段的类型**
```json
PUT /test2
{
  "mappings": {
    "properties": {
      "name": {
        "type": "text"
      },
      "age": {
        "type": "long"
      },
      "birthday": {
        "type": "date"
      }
    }
  }
}
```
**创建规则**
![20201208123425](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208123425.png)

可以通过GET请求获取具体信息
![20201208123727](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208123727.png)

**查看默认信息**
![20201208123934](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208123934.png)

如果自己的文档字段没有指定，那么es会给我们默认配置字段类型！
![20201208124022](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208124022.png)

扩展：通过命令elasticsearch索引情况！
通过GET _cat/ 可以获得es当前的很多信息！
![20201208124333](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208124333.png)

**更新方法**
1. 以前的方法
![20201208124648](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208124648.png)

2. 现在的方法
![20201208125151](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208125151.png)

**删除索引**
通过DELETE命令删除、根据你的请求来判断是删除索引还是删除文档记录！
使用RESTFUL风格是ES推荐大家使用的！
![20201208125311](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208125311.png)

### 关于文档的基本操作(重点)
#### 基本操作
1. 添加数据
```json
PUT /kuangshen/user/2
{
  "name": "张三",
  "age": 20,
  "desc": "法外狂徒张三",
  "tags": ["旅游","温暖","渣男"]
}
```
![20201208131423](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208131423.png)
2. 获取数据 GET
```json
GET /kuangshen/user/1
```
![20201208131525](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208131525.png)

3. 更新数据 PUT
![20201208131638](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208131638.png)

4. POST _update
PUT如果不传递值就会被覆盖，
POST灵活度更高
![20201208131919](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208131919.png)

5. 简单的搜索
```json
GET /kuangshen/user/1
```
简单的条件查询,可以根据默认的映射规则，产生基本的查询！
```json
GET /kuangshen/user/_search?q=name:狂神说java
```
![20201208132659](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208132659.png)
#### 复杂操作搜索
select(排序，分页，高亮，模糊查询，精准查询！)

![20201208132907](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208132907.png)
hits：
索引和文档的信息
查询的结果总数
然后就是查询出来的具体的文档
数据中心的所有东西都可以遍历出来了
分数：我们可以通过分数来判断谁更加符合搜索结果
![20201208133306](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208133306.png)

输出结果，只需要指定的字段
![20201208133702](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208133702.png)

之后Java操作es，所有的方法和对象就是这里面的key！

排序
![20201208134107](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208134107.png)

分页查询
![20201208134351](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208134351.png)
数据下标还是从0开始的，和学的所有的数据结构是一样的！
/search/{current}/{pagesize}
布尔值查询
must（and）,所有的条件都要符合 where id = 1 and name = xxx
多条件查询
![20201208135813](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208135813.png)

should（or）,所有的条件都要符合 where id = 1 or name = xxx
![20201208140038](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208140038.png)

must_not (not)
![20201208140200](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208140200.png)

过滤器 filter
![20201208140541](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208140541.png)

匹配多个条件
![20201208141030](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208141030.png)

term查询是直接通过倒排索引指定的词条进行精确的查找！

**关于分词**
* term，直接查询精确的
* match，会使用分词器解析！(先分析文档，然后再通过分析的文档进行查询！)

**两个类型 text keyword**

![20201208142103](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208142103.png)

![20201208142121](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208142121.png)

keyword 字段类型不会被分词器解析
![20201208142435](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208142435.png)

多个值匹配的精确查询
![20201208142917](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208142917.png)

高亮查询
![20201208143250](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208143250.png)

自定义搜索高亮条件
![20201208143506](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201208143506.png)

这些MySQL也能做，只是MySQL效率比较低！
* 匹配
* 按照条件匹配
* 精确匹配
* 区间范围匹配
* 区间字段匹配
* 多条件查询
* 高亮查询


