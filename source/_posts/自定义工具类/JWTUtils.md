---
title: JWTUtils
author: Marlowe
tags: JWT
categories: 自定义工具类
abbrlink: 23300
date: 2021-03-02 14:36:50
---
Jwt 学习
<!--more-->
1. 引入jwt依赖
```xml
<dependency>
    <groupId>com.auth0</groupId>
    <artifactId>java-jwt</artifactId>
    <version>3.4.0</version>
</dependency>
```
2. 编写JWTUtils工具类
```java
public class JWTUtils {

    private static final String SIGN = "!QDJHFKSHFK:";

    /**
     * 生成token header.payload.sign
     *
     * @param map
     * @return
     */
    public static String getToken(Map<String, String> map) {
        Calendar instance = Calendar.getInstance();
        // 默认7天过期
        instance.add(Calendar.DATE, 7);

        // 创建jwt builder
        JWTCreator.Builder builder = JWT.create();

        // payload
        map.forEach((k, v) -> {
            builder.withClaim(k, v);
        });
        // 指定令牌过期时间和签名
        String token = builder.withExpiresAt(instance.getTime())
                .sign(Algorithm.HMAC256(SIGN));
        return token;
    }


    /**
     * 验证token 合法性
     *
     * @param token
     */
    public static void verify(String token) {
        JWT.require(Algorithm.HMAC256(SIGN)).build().verify(token);
    }


    /**
     * 获取token信息
     *
     * @param token
     * @return
     */
    public static DecodedJWT getTokenInfo(String token) {
        DecodedJWT verify = JWT.require(Algorithm.HMAC256(SIGN)).build().verify(token);
        return verify;
    }

}
```
3. 编写JWTinterceptor类
```java
public class JWTInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        Map<Object, Object> map = new HashMap<>();
        // 获取请求头令牌
        String token = request.getHeader("token");
        try {
            // 验证令牌
            JWTUtils.verify(token);
            // 放行请求
            return true;
        } catch (SignatureVerificationException e) {
            e.printStackTrace();
            map.put("msg", "无效签名");
        } catch (TokenExpiredException e) {
            e.printStackTrace();
            map.put("msg", "token过期");
        } catch (AlgorithmMismatchException e) {
            e.printStackTrace();
            map.put("msg", "token算法不一致");
        } catch (Exception e) {
            e.printStackTrace();
            map.put("msg", "token 无效");
        }
        map.put("state", false);
        String json = new ObjectMapper().writeValueAsString(map);
        response.setContentType("application/json;charset=UTF-8");
        response.getWriter().println(json);
        return false;
    }
}
```
4. 编写拦截器配置类
```java
@Configuration
public class InterceptorConfig implements WebMvcConfigurer{
    @Override
    public vpid addInterceptors(InterceptorRegistry registry){
        registry.addInterceptor(new JWTInterceptor())
        .addPathPatterns("/xxx")
        .excludePathPatterns("/xxx");
    }
}
```