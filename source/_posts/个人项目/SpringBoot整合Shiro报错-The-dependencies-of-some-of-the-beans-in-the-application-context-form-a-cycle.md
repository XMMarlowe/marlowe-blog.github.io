---
title: >-
  SpringBoot整合Shiro报错:The dependencies of some of the beans in the application
  context form a cycle
author: Marlowe
tags:
  - SpringBoot
  - Shiro
  - 问题教程
categories: 个人项目
abbrlink: 48542
date: 2021-06-30 15:51:03
---

SpringBoot整合Shiro遇到循环依赖问题...
<!--more-->

### 问题代码：ShiroConfig.java

```java
@Configuration
public class ShiroConfig {

    /**
     * SecurityManager
     *
     * @param userRealm
     * @return
     */
    @Bean
    public DefaultSecurityManager securityManager(UserRealm userRealm) {
        // 创建securityManager
        DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
        // 使用自定义Realm
        securityManager.setRealm(userRealm);

        // 关闭shiro自带的session
        DefaultSubjectDAO subjectDAO = new DefaultSubjectDAO();
        DefaultSessionStorageEvaluator defaultSessionStorageEvaluator = new DefaultSessionStorageEvaluator();
        // 禁止session
        defaultSessionStorageEvaluator.setSessionStorageEnabled(false);
        subjectDAO.setSessionStorageEvaluator(defaultSessionStorageEvaluator);

        securityManager.setSubjectDAO(subjectDAO);
        return securityManager;
    }

    // ShiroFilter 注入 JWTFilter, 并设置为主过滤器
    @Bean
    public ShiroFilterFactoryBean shiroFilterFactoryBean(SecurityManager securityManager, JWTFilter jwtFilter) {
        ShiroFilterFactoryBean shiroFilterFactoryBean = new ShiroFilterFactoryBean();

        // 添加我们自定义的过滤器并取名为jwt  ***很重要***
        Map<String, Filter> newFilters = new HashMap<>();
        newFilters.put("jwt", jwtFilter);
        shiroFilterFactoryBean.setFilters(newFilters);

        // 注入securityManager
        shiroFilterFactoryBean.setSecurityManager(securityManager);

        // 定义规则
        Map<String, String> map = new LinkedHashMap<>();
        // anon(写在authc的前面): 不进行认证都能访问
        map.put("/login", "anon");
        map.put("/register", "anon");

        // 放行swagger
        map.put("/swagger/**", "anon");
        map.put("/v2/api-docs", "anon");
        map.put("/swagger-ui.html", "anon");
        map.put("/swagger-resources/**", "anon");
        map.put("/webjars/**", "anon");
        map.put("/favicon.ico", "anon");
        map.put("/captcha.jpg", "anon");
        map.put("/csrf", "anon");

        // 其他所有请求都由JWTFilter处理
        map.put("/**", "jwt");
        shiroFilterFactoryBean.setFilterChainDefinitionMap(map);

        return shiroFilterFactoryBean;
    }

    /**
     * 不向 Spring容器中注册 JWTFilter Bean，防止 Spring 将 JWTFilter 注册为全局过滤器
     * 全局过滤器会对所有请求进行拦截，而本例中只需要拦截除 /login 和 /logout 外的请求
     * 另一种简单做法是：不将 JWTFilter 放入 Spring 容器
     * <p>
     * 不添加下面这个 Bean 的话, 会出现 /** jwt 会拦截所有请求的情况
     */
    @Bean
    public FilterRegistrationBean<Filter> registration(JWTFilter jwtFilter) {
        FilterRegistrationBean<Filter> registration = new FilterRegistrationBean<>(jwtFilter);
        registration.setEnabled(false);
        return registration;
    }

}
```
### 报错信息：

![20210630155731](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210630155731.png)

### 解决方案

在ShiroConfig.java类中添加如下方法：

```java
@Bean
public AuthorizationAttributeSourceAdvisor authorizationAttributeSourceAdvisor(@Qualifier("securityManager") SecurityManager securityManager) {
    AuthorizationAttributeSourceAdvisor advisor = new AuthorizationAttributeSourceAdvisor();
    advisor.setSecurityManager(securityManager);
    return advisor;
}
```

