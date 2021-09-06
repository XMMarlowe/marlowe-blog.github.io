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

### 区别

#### 区别1:最终执行的SQL不同

```sql
select * from user where name = #{name}
```

最终执行的SQL为:select * from user where name = '123'

```sql
select * from user where name = ${name}
```

最终执行的SQL为:select * from user where name =123,

这个SQL在执行的时候会报错的,为了避免报错,需要修改为:name=’KaTeX parse error: Expected 'EOF', got '#' at position 25: …要加上单引号才可以 看到了吗,#̲{name}解析之后的SQL中…{name}最终解析的SQL中的参数name=123,没有单引号。

#### 区别2:动态SQL解析阶段解析的不同

(1)MyBatis的强大特性:动态 SQL，也是它优于其他 ORM 框架的一个重要原因。

(2)mybatis 在对 sql 语句进行预编译之前，会对 sql 进行动态解析，解析为一个 BoundSql 对象，也是在此处对动态 SQL 进行处理的。在动态 SQL 解析阶段， #{ } 和 ${ } 会有不同的表现

```sql
select * from user where name = #{name}; 
```

 #{}在动态解析的时候， 会解析成一个参数标记符。就是解析之后的语句是

```sql
select * from user where name = ?; 
```

那么我们使用 ${}的时候

```sql
select * from user where name = ${name}; 
```

${}在动态解析的时候，会将我们传入的参数当做String字符串填充到我们的语句中，就会变成下面的语句

```sql
select * from user where name = dato; 
```

预编译之前的 SQL 语句已经不包含变量了，完全已经是常量数据了。相当于我们普通没有变量的sql了。

**综上所得**

${ } 变量的替换阶段是在动态 SQL 解析阶段，而 #{ }变量的替换是在 DBMS 中。

#### 区别3:

 #方式能够很大程度防止sql注入(使用占位符,最终的参数会有单引号)。
$方式无法防止Sql注入(直接解析了,没有单引号,这样的话可以直接写SQL呀,比如select * from ${tableName},当tableName的值为:‘user;delete from user’,这样最终解析的SQL为:select * from user;delete from user,这个就会有SQL注入的问题)。

### Mybatis中何时使用jdbcType?

(1)这个SQL有时候这样写:

```sql
select * from user where name = #{name},
```

有时候可以这样写:

```sql
select * from user where name = #{name,jdbcType=VARCHAR},
```

到底什么时候使用jdbcType呢,什么时候不使用呢???

(2)当传入的参数name的值为空的时候,这个需要带上jdbcType=VARCHAR这个,其他不为空的情况下就不用带jdbcType=VARCHAR

(3)如果参入的参数name的值为空,而没有加上jdbcType这个来限定类型的话,执行的SQL会报异常

```
Error querying database.  Cause: org.postgresql.util.PSQLException: ERROR: could not determine data type of parameter $1
```




