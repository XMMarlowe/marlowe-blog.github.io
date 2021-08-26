---
title: Springboot整合Shiro：实现Redis缓存
author: Marlowe
tags:
  - Shiro
  - Redis
  - SpringBoot
categories: 个人项目
abbrlink: 41158
date: 2021-08-24 21:59:15
---
项目整合Shiro后，在没有配置缓存的时候，会存在这样的问题。每发起一个请求，就会调用一次授权方法。用户基数大请求多的时候，会对数据库造成很大的压力。所以我们需要配置缓存，将用户信息放在缓存里，从而减小数据库压力。
<!--more-->

### 自定义Realm中两个核心方法

#### 认证：doGetAuthenticationInfo

```java
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
```

#### 授权：doGetAuthorizationInfo
```java
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
```

### 自定义缓存管理器

我们这里用redis做缓存，下面说下配置redis缓存的方法。

（1）application.yml中配置redis的相关参数

```yml
###redis
spring:
    redis:
        host: localhost
        port: 6379
        jedis:
            pool:
                max-idle: 8
                min-idle: 0
                max-active: 8
                max-wait: -1
        timeout: 0
```

（2）pom.xml文件中引入shiro-redis依赖

```yml
<!-- shiro+redis缓存插件 -->
<dependency>
    <groupId>org.crazycake</groupId>
    <artifactId>shiro-redis</artifactId>
    <version>2.4.2.1-RELEASE</version>
</dependency>
```

（3）ShiroConfig.java中添加相应的配置

```java
 /**
     * redisManager
     *
     * @return
     */
    public RedisManager redisManager() {
        RedisManager redisManager = new RedisManager();
        redisManager.setHost(host);
        redisManager.setPort(port);
        // 配置过期时间
        redisManager.setExpire(1800);
        return redisManager;
    }

    /**
     * 设置cacheManager为redisManager 
     *
     * @return
     */
    public RedisCacheManager cacheManager() {
        RedisCacheManager redisCacheManager = new RedisCacheManager();
        redisCacheManager.setRedisManager(redisManager());
        return redisCacheManager;
    }

    /**
     * redisSessionDAO
     */
    public RedisSessionDAO redisSessionDAO() {
        RedisSessionDAO redisSessionDAO = new RedisSessionDAO();
        redisSessionDAO.setRedisManager(redisManager());
        return redisSessionDAO;
    }

    /**
     * sessionManager
     */
    public DefaultWebSessionManager SessionManager() {
        DefaultWebSessionManager sessionManager = new DefaultWebSessionManager();
        sessionManager.setSessionDAO(redisSessionDAO());
        return sessionManager;
    }
```

（4）将session管理器和cache管理器注入到SecurityManager中

```java
  @Bean
    public SecurityManager securityManager(){
        DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
        //将自定义的realm交给SecurityManager管理
        securityManager.setRealm(new CustomRealm());
        // 自定义缓存实现 使用redis
        securityManager.setCacheManager(cacheManager());
        // 自定义session管理 使用redis
        securityManager.setSessionManager(SessionManager());
        return securityManager;
    }
```
（5）redis-server.exe启动redis，启动项目，完成。
未登录时，在redis中查看数据，得到空的结果。（empty list or set）
完成认证和授权后可以在redis中得到相应的信息。

### 参考

[Springboot整合Shiro：实现Redis缓存](https://www.jianshu.com/p/fa40df4865aa)
