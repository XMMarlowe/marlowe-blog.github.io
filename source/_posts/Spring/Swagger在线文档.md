---
title: Swagger在线文档
author: Marlowe
tags:
  - Swagger
  - SpringBoot
  - 配置
categories: Spring
abbrlink: 38097
date: 2020-12-06 18:30:51
---
Swagger在线文档使用教程...
<!--more-->
### SpringBoot集成Swagger
1. 新建一个SpringBoot项目==>web
2. 导入相关依赖
```xml
<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger2</artifactId>
    <version>2.9.2</version>
</dependency>

<dependency>
    <groupId>io.springfox</groupId>
    <artifactId>springfox-swagger-ui</artifactId>
    <version>2.9.2</version>
</dependency>
```
3. 编写HelloWorld
4. 配置Swagger
```java
@Configuration
@EnableSwagger2
public class SwaggerConfig {
}
```
5. 测试运行 http://localhost:8080/swagger-ui.html
![20201206181535](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201206181535.png)

### 配置Swagger信息
Swagger的bean示例Docket
```java
@Configuration
@EnableSwagger2
public class SwaggerConfig {

    /**
     * 配置了Swagger的Docket的bean实例
     *
     * @return
     */
    @Bean
    public Docket docket() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo());
    }

    public ApiInfo apiInfo() {

        // 作者信息
        Contact contact = new Contact("Marlowe", "https://xmmarlowe.github.io", "marlowe246@qq.com");

        return new ApiInfo("Visit CQUT Swagger API Documentation",
                "Api Documentation",
                "v1.0", "urn:tos",
                contact, "Apache 2.0",
                "http://www.apache.org/licenses/LICENSE-2.0", new ArrayList());
    }
}
```
![20201206182952](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201206182952.png)

### Swagger配置扫描接口
Docket.select()
```java
/**
     * 配置了Swagger的Docket的bean实例
     *
     * @return
     */
    @Bean
    public Docket docket() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                .select()
                /**
                 * RequestHandlerSelectors，配置要扫描接口的方式
                 * basePackage:指定要扫描的包
                 * any():扫描全部
                 * none():不扫描
                 * withClassAnnotation:扫描类上的注解，参数是一个注解的反射对象
                 * withMethodAnnotation：扫描方法上的注解
                 */
                .apis(RequestHandlerSelectors.basePackage("com.marlowe.swagger.controller"))
                // paths(): 过滤什么路径
                .paths(PathSelectors.ant("/marlowe/**"))
                .build();
    }
```
**配置是否启动swagger**
```java
/**
     * 配置了Swagger的Docket的bean实例
     *
     * @return
     */
    @Bean
    public Docket docket() {
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                // enable是否启动Swagger，如果为false，则swagger不能在浏览器中访问
                .enable(false)
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.marlowe.swagger.controller"))
                .build();
    }
```
![20201206185424](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20201206185424.png)

**我只希望我的Swagger在生产环境中使用，在发布的时候不使用？**
* 判断是不是生产环境 flag = false
* 注入enable(flag)
```java
/**
     * 配置了Swagger的Docket的bean实例
     *
     * @return
     */
    @Bean
    public Docket docket(Environment environment) {
        // 设置要现实的swagger环境
        Profiles profiles = Profiles.of("dev", "test");

        // 获取项目的环境：
        boolean flag = environment.acceptsProfiles(profiles);
        
        return new Docket(DocumentationType.SWAGGER_2)
                .apiInfo(apiInfo())
                // enable是否启动Swagger，如果为false，则swagger不能在浏览器中访问
                .enable(flag)
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.marlowe.swagger.controller"))
                .build();
    }
```
配置API文档的分组
```java
.groupName("Marlowe")
```
如何配置多个分组；多个Docket实例即可
```java
@Bean
public Docket docket1() {
    return new Docket(DocumentationType.SWAGGER_2).groupName("A");
}

@Bean
public Docket docket2() {
    return new Docket(DocumentationType.SWAGGER_2).groupName("B");
}

@Bean
public Docket docket3() {
    return new Docket(DocumentationType.SWAGGER_2).groupName("C");
}
```
实体类配置
```java
package com.marlowe.swagger.pojo;

import io.swagger.annotations.ApiModel;
import io.swagger.annotations.ApiModelProperty;

/**
 * @program: swagger-demo
 * @description:
 * @author: Marlowe
 * @create: 2020-12-06 19:39
 **/
@ApiModel("用户实体类")
public class User {
    @ApiModelProperty("用户名")
    public String username;
    @ApiModelProperty("密码")
    public String password;
}

```
controller
```java
package com.marlowe.swagger.controller;

import com.marlowe.swagger.pojo.User;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import io.swagger.annotations.ApiParam;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * @program: swagger-demo
 * @description:
 * @author: Marlowe
 * @create: 2020-12-06 18:07
 **/
@Api(tags = "hello控制类")
@RestController
public class HelloController {

    @GetMapping(value = "/hello")
    public String hello() {
        return "hello";
    }

    @PostMapping(value = "/user")
    public User user() {
        return new User();
    }

    @ApiOperation("Hello 控制类")
    @GetMapping(value = "/hello2")
    public String hello2(@ApiParam("用户名") String username) {
        return "hello" + username;
    }

    @ApiOperation("Post 控制类")
    @GetMapping(value = "/postt")
    public User post(@ApiParam("用户") User user) {
        return user;
    }
}

```
总结：
1. 可以通过Swagger给一些比较难理解的属性或者接口，增加注释信息
2. 接口文档实时更新
3. 可以在线测试

【注意点】在正式发布的时候，关闭Swagger！！！ 处于安全考虑，并且节省内存！
