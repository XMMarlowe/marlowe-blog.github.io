---
title: Mybatis传参的几种方式
author: Marlowe
tags: Mybatis
categories: Spring
abbrlink: 10483
date: 2021-06-01 19:35:26
---

<!--more-->

### #｛｝

#### 第一种情形，传入单个参数  userId

service层：

```java
@Override
public User getUserInfo(Integer userId) {
    User user = userMapper.getUserInfo(userId);
 
    //省略 业务代码...
    
    return user;
}
```
mapper层：

```java
User getUserInfo(Integer userId);
```
mapper.xml：

```xml
<!--查询-->
<select id="getUserInfo" resultType="com.demo.elegant.pojo.User">
    select userId 
    from users
    where userId=#{userId};
</select>
```

#### 第二种情况，传入多个参数  userId,sex  使用索引对应值

按照顺序传参

注意mapper层和xml层！

service层：

```java
@Override
public User getUserInfo(Integer userId,String sex) {
    User user = userMapper.getUserInfo(userId,sex);
    //省略 业务代码...
    return user;
}
```

mapper层：
```java
User getUserInfo(Integer userId,String sex);
```

mapper.xml：

```xml
<!--查询-->
<select id="getUserInfo" resultType="com.demo.elegant.pojo.User">
    select userId
    from users
    where userId=#{0} and sex=#{1};
</select>
```

#### 第三种情形，传入多个参数  userId,sex 使用注解@Param 

service层：

```java
@Override
public User getUserInfo(Integer userId,String sex) {
    User user = userMapper.getUserInfo(userId,sex);
    //省略 业务代码...
    return user;
}
```


mapper层：
```java
User getUserInfo(@Param("userId")Integer userId,@Param("sex")String sex);
```


mapper.xml：

```xml
<!--查询-->
<select id="getUserInfo" resultType="com.demo.elegant.pojo.User">
    select userId
    from users
    where userId=#{userId} and sex=#{sex};
</select>
```

#### 第四种情形，传入多个参数   使用User实体类传入

service层：

```java
@Override
public User getUserInfo(User user) {
    User userInfo = userMapper.getUserInfo(user);
    //省略 业务代码...
    return userInfo;
}
```


mapper层：
```java
User getUserInfo(User User);
```


mapper.xml：

```xml
<!--查询-->
<select id="getUserInfo"  parameterType="User"  resultType="com.demo.elegant.pojo.User">
    select userId
    from users
    where userId=#{userId} and sex=#{sex};
</select>
```


#### 第五种情形，传入多个参数， 使用Map类传入

service层：

```java
@Override
public User getUserInfo(Map map) {
    User user = userMapper.getUserInfo(map);
    //省略 业务代码...
    return user;
}
```


mapper层：
```java
User getUserInfo(Map map);
```


mapper.xml：

```xml
<!--查询-->
<select id="getUserInfo"  parameterType="Map"  resultType="com.demo.elegant.pojo.User">
    select userId
    from users
    where userId=#{userId} and sex=#{sex};
</select>
```

#### 第六种情形，传入多个参，使用 map封装实体类传入

这种情况其实使用场景比较少，因为上面的各种知识其实已经够用了

service层：

```java
@Override
public User getUserInfo1(Integer userId,String sex) {
    User userInfo = new User(userId,sex);
    Map<String,Object> map=new HashMap<String,Object>();
    map.put("user",userInfo);
 
    User userResult=  userMapper.getUserInfo(map);
    //省略 业务代码...
    return userResult;
}
```


mapper层：
```java
User getUserInfo(Map map);
```


mapper.xml：

```xml
<!--查询-->
<select id="getUserInfo"  parameterType="Map"  resultType="com.demo.elegant.pojo.User">
    select userId
    from users
    where userId=#{userInfo.userId} and sex=#{userInfo.sex};
</select>
```


#### 第七种情形，即需要传入实体类，又需要传入多个单独参，使用注解@Param 

service层：

```java
@Override
public User getUserInfo(User user,Integer age) {
    User userResult = userMapper.getUserInfo(user,age);
    //省略 业务代码...
    return userResult;
}
```


mapper层：
```java
User getUserInfo(@Param("userInfo") User user,@Param("age") Integer age);
```


mapper.xml：

```xml
<!--查询-->
<select id="getUserInfo"   resultType="com.demo.elegant.pojo.User">
    select userId
    from users
    where userId=#{userInfo.userId} and sex=#{userInfo.sex} and age=#{age};
</select>
```

#### List传参

service层：

```java
List<Integer>list= new ArrayList>();
 list. add(44);
 list. add(45);
 list. add(46);
List<SysUser> sysUser= sysUserMapper. selectList(list);
```


mapper层：
```java
List<SysUser> selectList(List<Integer> ids);
```


mapper.xml：

```xml
<select id="selectList"resultMap"BaseResultMap">
 select
 <include refid="Base_Column_List"/>
 from sys_user
 where id in
 <foreach item="item" index="index" collection="list"open="("separator","close=")"> #{item}
 </foreach>
 </select>
```

#### 数组传参

service层：

```java
List<SysUser> sysuser= sysUserMapper. selectlist(new Integer[]{44,45,46});
```


mapper层：
```java
List<SysUser> selectList(Integer[]ids);
```


mapper.xml：

```xml
<select id="selectList"resultMap"BaseResultMap">
 select
 <include refid="Base Column_List"/>
 from sys user
 where id in
 <foreach item="item" index="index collection="array"open="("separator="," close=")"> #{item}
 </foreach>
 </select>
```

### $｛｝

使用这个的时候，只需要注意，如果是传递字段名或者表名，是直接做参数传入即可，

但是如果作为sql'语句里面使用的值， 记得需要手动拼接 ' ' 号。

例如， 传入单个参数 sex：

service层：

```java
@Override
public User getUserInfo(String sex) {
 
    sex="'"+sex+"'";
    User user = userMapper.getUserInfo(sex);
    //省略 业务代码...
    return user;
}
```


mapper层：
```java
User getUserInfo(String sex);
```

mapper.xml：

```xml
<!--查询-->
<select id="getUserInfo"   resultType="com.demo.elegant.pojo.User">
    select userId
    from users
    where sex=${sex};
</select>
```

多个参数，那也就是使用注解@Param取名字解决即可。





