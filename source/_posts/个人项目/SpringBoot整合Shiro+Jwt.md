---
title: SpringBoot整合Shiro+Jwt
author: Marlowe
abbrlink: 41808
date: 2021-06-12 08:55:50
tags: 
  - Spring
  - Shiro
  - Jwt
categories: 个人项目
---

RBAC项目中用到的Shiro、Jwt相关配置以及工具类

<!--more-->

### Maven 依赖

```pom
<!--shiro-->
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-spring-boot-web-starter</artifactId>
    <version>1.5.3</version>
</dependency>

<!--JWT-->
<dependency>
    <groupId>com.auth0</groupId>
    <artifactId>java-jwt</artifactId>
    <version>3.3.0</version>
</dependency>
```

### Jwt相关

#### JWTUtils.java

```java
package com.marlowe.rbac.utils;

import com.auth0.jwt.JWT;
import com.auth0.jwt.JWTVerifier;
import com.auth0.jwt.algorithms.Algorithm;
import com.auth0.jwt.exceptions.JWTDecodeException;
import com.auth0.jwt.interfaces.DecodedJWT;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.io.UnsupportedEncodingException;
import java.util.Date;

/**
 * 要有属性的setter, 不然不能从application配置文件中注入自定义的值
 *
 * @auther yincaiTA
 * @date 2021/3/16 11:27
 * @description jwt生成和校验的工具类
 */
@Component
@ConfigurationProperties(prefix = "self.jwt")
public class JWTUtils {

    /**
     * 密钥
     */
    private String secret;
    /**
     * 过期时间(ms)
     */
    private long expire;
    /**
     * 前端请求头部
     */
    private String header;

    /**
     * 校验token是否正确并对应一个用户
     *
     * @param token    令牌
     * @param username 用户名
     * @param secret   加密密钥
     * @return 校验是否通过, 看token中是否包含 username并且 = real_database_username 的信息
     */
    public boolean verify(String token, String username, String secret) {
        try {
            Algorithm algorithm = Algorithm.HMAC256(secret);
            JWTVerifier verifier = JWT.require(algorithm)
                    .withClaim("username", username)
                    .build();
            verifier.verify(token);
            return true;
        } catch (Exception exception) {
            return false;
        }
    }

    /**
     * 获得token中的信息无需secret解密也能获得
     *
     * @return token中包含的用户名
     */
    public String getUsername(String token) {
        try {
            DecodedJWT jwt = JWT.decode(token);
            return jwt.getClaim("username").asString();
        } catch (JWTDecodeException e) {
            return null;
        }
    }

    /**
     * 生成签名, x min后过期x
     *
     * @param username 用户名
     * @param secret   加密密钥
     * @return 加密的token
     */
    public String sign(String username, String secret) {
        try {
            Date date = new Date(System.currentTimeMillis() + this.expire);
            Algorithm algorithm = Algorithm.HMAC256(secret);
            // 附带username信息
            return JWT.create()
                    .withClaim("username", username)
                    .withExpiresAt(date)
                    .sign(algorithm);
        } catch (UnsupportedEncodingException e) {
            return null;
        }
    }

    /**
     * 判断过期
     *
     * @param token 令牌
     * @return token 是否过期
     */
    public boolean isExpire(String token) {
        DecodedJWT jwt = JWT.decode(token);
        return System.currentTimeMillis() > jwt.getExpiresAt().getTime();
    }

    public String getSecret() {
        return secret;
    }

    public long getExpire() {
        return expire;
    }

    public String getHeader() {
        return header;
    }

    public void setSecret(String secret) {
        this.secret = secret;
    }

    public void setExpire(long expire) {
        this.expire = expire;
    }

    public void setHeader(String header) {
        this.header = header;
    }
}
```

#### JWTToken.java

```java
package com.marlowe.rbac.config.shiro.jwt;

import org.apache.shiro.authc.AuthenticationToken;

/**
 * @auther yincaiTA
 * @date 2021/3/17 08:29
 * @description 证书或令牌 定义为 token
 */
public class JWTToken implements AuthenticationToken {

    // 证书/密钥
    private String token;

    public JWTToken() {
    }

    public JWTToken(String token) {
        this.token = token;
    }

    @Override
    public Object getPrincipal() {
        return token;
    }

    @Override
    public Object getCredentials() {
        return token;
    }
}
```

#### JWTFilter.java

```java
package com.marlowe.rbac.config.shiro.jwt;

import com.auth0.jwt.exceptions.JWTDecodeException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.marlowe.rbac.commons.result.Result;
import com.marlowe.rbac.utils.JWTUtils;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.AuthenticationException;
import org.apache.shiro.web.filter.authc.BasicHttpAuthenticationFilter;
import org.apache.shiro.web.util.WebUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;

/**
 * @auther yincaiTA
 * @date 2021/3/17 10:06
 * @description JWTToken检验过滤器 前端请求带token时进行处理
 */
@Component
public class JWTFilter extends BasicHttpAuthenticationFilter {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Autowired
    private JWTUtils jwtUtils;

    /*
        @Override isAccessAllowed() 时, 该方法是 在认证之前执行
        如果已经认证的用户, 直接放行(即 subject.isAuthenticated() 为 true)
     */

    /**
     * 因为是前后端分离, 所以除了ShiroConfig中定义了放行的路径外, 其余路径皆会访问到这个方法, 因为 subject.isAuthenticated() 总是false
     * 拦截校验
     */
    @Override
    protected boolean onAccessDenied(ServletRequest request, ServletResponse response) {
        // 完成token登入
        // 1. 检查请求头中是否含有token
        HttpServletRequest httpServletRequest = (HttpServletRequest) request;
        String token = httpServletRequest.getHeader(this.jwtUtils.getHeader());
        // 2. 如果客户端没有携带token，拦下请求
        if (null == token || "".equals(token)) {
            this.responseTokenError(response, "请求头异常或token为空值!");
            return false;
        }
        // 3. 如果有，对进行进行token验证
        JWTToken jwtToken = new JWTToken(token);
        try {
            SecurityUtils.getSubject().login(jwtToken);
        } catch (AuthenticationException e) {
            responseTokenError(response, e.getMessage());
            return false;
        } catch (JWTDecodeException e) {
            responseTokenError(response, e.getCause().getMessage());
            return false;
        }

        // 放行 访问controller
        return true;
    }

    /**
     * 拦截器的前置拦截, 前后端分离, 项目中除了需要跨域全局配置之外, 我们再拦截器中也需要提供跨域支持. 这样, 拦截器才不会在进入Controller之前就被限制了
     * 对跨域提供支持
     */
    @Override
    protected boolean preHandle(ServletRequest request, ServletResponse response) throws Exception {
        HttpServletRequest httpServletRequest = (HttpServletRequest) request;
        HttpServletResponse httpServletResponse = (HttpServletResponse) response;
        httpServletResponse.setHeader("Access-control-Allow-Origin", httpServletRequest.getHeader("Origin"));
        httpServletResponse.setHeader("Access-Control-Allow-Methods", "GET,POST,OPTIONS,PUT,DELETE");
        httpServletResponse.setHeader("Access-Control-Allow-Headers", httpServletRequest.getHeader("Access-Control-Request-Headers"));
        // 跨域时会首先发送一个option请求，这里我们给option请求直接返回正常状态
        if (httpServletRequest.getMethod().equals(RequestMethod.OPTIONS.name())) {
            httpServletResponse.setStatus(HttpStatus.OK.value());
            return false;
        }
        return super.preHandle(request, response);
    }

    /**
     * 无需转发，直接返回Response信息 Token认证错误
     */
    private void responseTokenError(ServletResponse response, String msg) {
        HttpServletResponse httpServletResponse = WebUtils.toHttp(response);
        httpServletResponse.setStatus(HttpStatus.OK.value());
        httpServletResponse.setCharacterEncoding("UTF-8");
        httpServletResponse.setContentType("application/json; charset=utf-8");
        try {
            PrintWriter out = httpServletResponse.getWriter();
            HashMap<String, Object> errorData = new HashMap<>();
            errorData.put("errorCode", "-1");
            errorData.put("errorMsg", msg);
            Result result = Result.ok(errorData);
            // 序列化响应信息
            String data = this.objectMapper.writeValueAsString(result);
            out.append(data);
        } catch (IOException e) {
            e.printStackTrace();
            System.out.println(e.getMessage());
        }
    }

}
```


### Shiro相关

#### UserRealm.java

```java
package com.marlowe.rbac.config.shiro.realms;


import cn.hutool.core.collection.CollectionUtil;
import com.auth0.jwt.exceptions.JWTDecodeException;
import com.marlowe.rbac.config.shiro.jwt.JWTToken;
import com.marlowe.rbac.entity.Permission;
import com.marlowe.rbac.entity.User;
import com.marlowe.rbac.service.IRoleService;
import com.marlowe.rbac.service.IUserService;
import com.marlowe.rbac.utils.JWTUtils;
import org.apache.shiro.authc.*;
import org.apache.shiro.authz.AuthorizationInfo;
import org.apache.shiro.authz.SimpleAuthorizationInfo;
import org.apache.shiro.realm.AuthorizingRealm;
import org.apache.shiro.subject.PrincipalCollection;
import org.apache.shiro.util.ByteSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * @auther yincaiTA
 * @date 2021/3/16 11:27
 * @description 用户Realm
 */
@Component
public class UserRealm extends AuthorizingRealm {

    @Autowired
    private IUserService userService;

    @Autowired
    private IRoleService roleService;

    @Autowired
    private JWTUtils jwtUtils;

    /**
     * shiro默认采用 UsernamePasswordToken进行处理
     * 而现在我们只处理 JWTToken类型的 token
     */
    @Override
    public boolean supports(AuthenticationToken token) {
        return token instanceof JWTToken;
    }

    /**
     * 授权(为了方便 直接在一张表中描述了角色和权限)
     *
     * @param principals 身份信息
     * @return AuthorizationInfo授权信息
     */
    @Override
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principals) {
        //获取身份信息
        User user = (User) principals.getPrimaryPrincipal();
        System.out.println("调用授权验证：" + user.getUsername());
        // 根据主身份信息获取角色和权限信息
        User realUser = userService.findRolesByUserName(user.getUsername());
        // 授权角色信息
        if (!CollectionUtil.isEmpty(realUser.getRoles())) {
            //权限信息对象info,用来存放查出的用户的所有的角色（Role）及权限（permission）
            SimpleAuthorizationInfo simpleAuthorizationInfo = new SimpleAuthorizationInfo();
            System.out.println(realUser.getRoles()+"-------------------------");
            realUser.getRoles().forEach(role -> {
                // 添加角色信息
                simpleAuthorizationInfo.addRole(role.getName());
                System.out.println(role.getName()+"================================");

                 //添加权限信息
                List<Permission> permissions = roleService.findPermissionsByRoleId(role.getId());
                if (!CollectionUtil.isEmpty(permissions)) {
                    permissions.forEach(permission -> {
                        simpleAuthorizationInfo.addStringPermission(permission.getName());
                        System.out.println(permission.getName()+"==============AAAAAAAAAA==================");
                    });
                }
            });
            return simpleAuthorizationInfo;
        }
        return null;
    }

    /**
     * 认证(因为是已经登陆的用户才会有token 所以不用进行密码验证 并且 shiro也是跳过login的)
     *
     * @param auth 认证信息
     * @return AuthenticationInfo 认证信息
     * @throws AuthenticationException 认证异常
     */
    @Override
    protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken auth) throws AuthenticationException {
        // 处理的是 JWTToken, .getPrincipal() 和 .getCredentials() 都是返回token字符串
        String token = (String) auth.getPrincipal();

        String username;
        try {
            // 从令牌中获取username值  这里可能发生解码异常
            username = this.jwtUtils.getUsername(token);

            // token不包含username信息 || token值中的密钥 是胡乱编造
            if (username == null || !this.jwtUtils.verify(token, username, this.jwtUtils.getSecret())) {
                // 因为token过期了 verify会直接判断false, 所以不能在之后判断是否过期  isExpire也有可能发生解码异常
                if (this.jwtUtils.isExpire(token)) {
                    throw new ExpiredCredentialsException("token过期，请重新登入！");
                }
                // 校验未通过
                throw new IncorrectCredentialsException("token值异常(2)!!!");
            }

        } catch (JWTDecodeException | IllegalArgumentException e) {
            // token的3部分缺失 / 根本解不了码
            e.printStackTrace();
            throw new IncorrectCredentialsException("token值异常(1)!!!!");
        } catch (AuthenticationException e) {
            // 过期/值异常 等
            e.printStackTrace();
            throw new IncorrectCredentialsException(e.getMessage());
        }

        // 数据库查询用户并返回
        User user = this.userService.findUserByUsername(username);
        if (user == null) {
            throw new UnknownAccountException("账号不存在!");
        }

        // 通过认证 直接将user传递给授权过程 反正都通过了认证了 就不需要再在授权过程再走一遍 token->username->user 的过程了
        return new SimpleAuthenticationInfo(user, token, this.getName());
    }

}
```

#### ShiroConfig.java

```java
package com.marlowe.rbac.config.shiro;

import com.marlowe.rbac.config.shiro.jwt.JWTFilter;
import com.marlowe.rbac.config.shiro.realms.UserRealm;
import org.apache.shiro.mgt.DefaultSecurityManager;
import org.apache.shiro.mgt.DefaultSessionStorageEvaluator;
import org.apache.shiro.mgt.DefaultSubjectDAO;
import org.apache.shiro.mgt.SecurityManager;
import org.apache.shiro.spring.security.interceptor.AuthorizationAttributeSourceAdvisor;
import org.apache.shiro.spring.web.ShiroFilterFactoryBean;
import org.apache.shiro.web.mgt.DefaultWebSecurityManager;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.servlet.Filter;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * @auther yincaiTA
 * @date 2021/3/17 10:25
 * @description shiro配置类
 */
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

        // UnavailableSecurityManagerException: No SecurityManager accessible to the calling code,
        //     either bound to the org.apache.shiro.util.ThreadContext or as a vm static singleton.  This is an invalid application configuration.
        //     加上其中一个即可 但是加上了就会出现 /login 也会被拦截的情况, 但是不加又会出现 JWTFilter中注入不了JWTUtils的情况
//        SecurityUtils.setSecurityManager(securityManager);
//        ThreadContext.bind(securityManager);  // 就是导包的问题！！！！  shiro-spring-boot-starter -> 换成 shiro-spring-boot-web-starter
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
//        map.put("/logout", "anon");

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
//
//    /**
//     * 下面的代码是添加注解支持
//     */
//    @Bean
//    @DependsOn("lifecycleBeanPostProcessor")
//    public DefaultAdvisorAutoProxyCreator defaultAdvisorAutoProxyCreator() {
//        DefaultAdvisorAutoProxyCreator defaultAdvisorAutoProxyCreator = new DefaultAdvisorAutoProxyCreator();
//        // 强制使用cglib，防止重复代理和可能引起代理出错的问题，https://zhuanlan.zhihu.com/p/29161098
//        defaultAdvisorAutoProxyCreator.setProxyTargetClass(true);
//        return defaultAdvisorAutoProxyCreator;
//    }
//
//    @Bean
//    public LifecycleBeanPostProcessor lifecycleBeanPostProcessor() {
//        return new LifecycleBeanPostProcessor();
//    }

    @Bean
    public AuthorizationAttributeSourceAdvisor authorizationAttributeSourceAdvisor(@Qualifier("securityManager") SecurityManager securityManager) {
        AuthorizationAttributeSourceAdvisor advisor = new AuthorizationAttributeSourceAdvisor();
        advisor.setSecurityManager(securityManager);
        return advisor;
    }
}
```