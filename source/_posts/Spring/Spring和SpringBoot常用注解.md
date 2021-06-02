---
title: Spring和SpringBoot常用注解
author: Marlowe
tags: 注解
categories: Spring
abbrlink: 45369
date: 2021-05-28 13:34:35
---
总结Spring和SpringBoot常用注解...
<!--more-->

### Spring常用注解

#### 1、用于注册bean对象注解

##### @Component

**作用：**

调用无参构造创建一个bean对象，并把对象存入Spring的IoC容器，交由Spring容器进行管理。相当于在xml中配置一个Bean。

**属性：**

value：指定Bean的id。如果不指定value属性，默认Bean的id是当前类的类名，首字母小写。

**子注解：**

以下三个注解是从@Component派生出来的，它们的作用与@Component是一样的，Spring增加这三个注解是为了在语义行区分MVC三层架构对象。

@Component：用于注册非表现层、业务层、持久层的对
@Controller：用于注册表现层对象  
@Service：用于注册业务层对象  
@Reposity：用于注册持久层对象

##### @Bean

**作用：**

用于把当前方法的返回值（对象）作为Bean对象存入Spring的IoC容器中（注册Bean）

**属性：**

name/value：用于指定Bean的id。当不写时，默认值是当前方法的名称。注意：当我们使用注解配置方法时，如果方法有参数，Spring框架会去容器中查找有没有可用的Bean对象，查找的方式和Autowired注解的方式是一样的。

**案例：**

```java
@Configuration
public class JdbcConfig {
    /**
     * 用于创建QueryRunner对象
     * @param dataSource
     * @return
     */
    @Bean(value = "queryRunner")
    public QueryRunner createQueryRunner(DataSource dataSource) {
        return new QueryRunner(dataSource);
    }

    /**
     * 创建数据源对象
     * @return
     */
    @Bean(value = "dataSource")
    public DataSource createDataSource() {
        try {
            ComboPooledDataSource comboPooledDataSource = new ComboPooledDataSource();
            comboPooledDataSource.setDriverClass("com.mysql.jdbc.Driver");
            comboPooledDataSource.setJdbcUrl("jdbc:mysql://localhost:3306/mydatabase");
            comboPooledDataSource.setUser("root");
            comboPooledDataSource.setPassword("root");
            return comboPooledDataSource;
        }catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}
```

#### 2、用于依赖注入的注解

##### @Autowired

**作用：**

@Autowire和@Resource都是Spring支持的注解形式动态装配Bean的方式。Autowire默认按照类型(byType)装配，如果想要按照名称(byName)装配，需结合@Qualifier注解使用。

**属性：**

required：@Autowire注解默认情况下要求依赖对象必须存在。如果不存在，则在注入的时候会抛出异常。如果允许依赖对象为null，需设置required属性为false。

**案例：**
```java
@Autowired /* Autowire默认按照类型(byType)装配 */
// @Autowired(required = false) /* @Autowire注解默认情况下要求依赖对象必须存在。如果不存在，则在注入的时候会抛出异常。如果允许依赖对象为null，需设置required属性为false。 */
// @Qualifier("userService") /* 按照名称(byName)装配 */
private UserService userService;
```

##### @Qualifier

**作用：**

@Autowired是按照名称(byName)装配，使用了@Qualifier注解之后就变成了按照名称(byName)装配。它在给字段注入时不能独立使用，必须和@Autowire一起使用；但是给方法参数注入时，可以独立使用。

**属性：**

value：用于指定要注入的bean的id，其中，该属性可以省略不写。

**案例：**
```java
@Autowire
@Qualifier(value="userService") 
//@Qualifier("userService")     //value属性可以省略不写
private UserService userService;
```

##### @Resource

**作用：**

@Autowire和@Resource都是Spring支持的注解形式动态装配bean的方式。@Resource默认按照名称(byName)装配，名称可以通过name属性指定。如果没有指定name，则注解在字段上时，默认取（name=字段名称）装配。如果注解在setter方法上时，默认取（name=属性名称）装配。

**属性：**

name：用于指定要注入的bean的id
type：用于指定要注入的bean的type

**装配顺序:**

1. 如果同时指定name和type属性，则找到唯一匹配的bean装配，未找到则抛异常；
2. 如果指定name属性，则按照名称(byName)装配，未找到则抛异常；
3. 如果指定type属性，则按照类型(byType)装配，未找到或者找到多个则抛异常；
4. 既未指定name属性，又未指定type属性，则按照名称(byName)装配；如果未找到，则按照类型(byType)装配。

**案例：**
```java
@Resource(name="userService")
//@Resource(type="userService")
//@Resource(name="userService", type="UserService")
private UserService userService;
```

##### @Value

**作用：**

通过@Value可以将外部的值动态注入到Bean中，可以为基本类型数据和String类型数据的变量注入数据

**案例：**

```java
// 1.基本类型数据和String类型数据的变量注入数据
@Value("tom") 
private String name;
@Value("18") 
private Integer age;


// 2.从properties配置文件中获取数据并设置到成员变量中
// 2.1jdbcConfig.properties配置文件定义如下
jdbc.driver \= com.mysql.jdbc.Driver  
jdbc.url \= jdbc:mysql://localhost:3306/eesy  
jdbc.username \= root  
jdbc.password \= root

// 2.2获取数据如下
@Value("${jdbc.driver}")  
private String driver;

@Value("${jdbc.url}")  
private String url;  
  
@Value("${jdbc.username}")  
private String username;  
  
@Value("${jdbc.password}")  
private String password;
```

#### 3、生命周期相关的注解

##### @PostConstruct

**作用：**

指定初始化方法

**案例：**

```java
@PostConstruct  
public void init() {  
    System.out.println("初始化方法执行");  
}
```

##### @PreDestroy

**作用：**

指定销毁方法

**案例：**

```java
@PreDestroy  
public void destroy() {  
    System.out.println("销毁方法执行");  
}
```

### SpringBoot常用注解

springboot中的常用注解有：@SpringBootApplication、@Repository、@Service、@RestController、@ResponseBody、@Component、@ComponentScan等等。

#### 1、@SpringBootApplication

这个注解是Spring Boot最核心的注解，用在 Spring Boot的主类上，标识这是一个 Spring Boot 应用，用来开启 Spring Boot 的各项能力。实际上这个注解是@Configuration,@EnableAutoConfiguration,@ComponentScan三个注解的组合。由于这些注解一般都是一起使用，所以Spring Boot提供了一个统一的注解@SpringBootApplication。

#### 2、@EnableAutoConfiguration

允许 Spring Boot 自动配置注解，开启这个注解之后，Spring Boot 就能根据当前类路径下的包或者类来配置 Spring Bean。

如：当前类路径下有 Mybatis 这个 JAR 包，MybatisAutoConfiguration 注解就能根据相关参数来配置 Mybatis 的各个 Spring Bean。

@EnableAutoConfiguration实现的关键在于引入了AutoConfigurationImportSelector，其核心逻辑为selectImports方法，逻辑大致如下：

* 从配置文件META-INF/spring.factories加载所有可能用到的自动配置类；

* 去重，并将exclude和excludeName属性携带的类排除；

* 过滤，将满足条件（@Conditional）的自动配置类返回；

#### 3、@Configuration

用于定义配置类，指出该类是 Bean 配置的信息源，相当于传统的xml配置文件，一般加在主类上。如果有些第三方库需要用到xml文件，建议仍然通过@Configuration类作为项目的配置主类——可以使用@ImportResource注解加载xml配置文件。

#### 4、@ComponentScan

组件扫描。让spring Boot扫描到Configuration类并把它加入到程序上下文。

@ComponentScan注解默认就会装配标识了@Controller，@Service，@Repository，@Component注解的类到spring容器中。

#### 5、@Repository

用于标注数据访问组件，即DAO组件。

使用@Repository注解可以确保DAO或者repositories提供异常转译，这个注解修饰的DAO或者repositories类会被ComponetScan发现并配置，同时也不需要为它们提供XML配置项。

#### 6、@Service

一般用于修饰service层的组件

#### 7、@RestController

用于标注控制层组件(如struts中的action)，表示这是个控制器bean,并且是将函数的返回值直 接填入HTTP响应体中,是REST风格的控制器；它是@Controller和@ResponseBody的合集。

#### 8、@ResponseBody

表示该方法的返回结果直接写入HTTP response body中

一般在异步获取数据时使用，在使用@RequestMapping后，返回值通常解析为跳转路径，加上@responsebody后返回结果不会被解析为跳转路径，而是直接写入HTTP response body中。比如异步获取json数据，加上@responsebody后，会直接返回json数据。

#### 9、@Component

泛指组件，当组件不好归类的时候，我们可以使用这个注解进行标注。

#### 10、@Bean

相当于XML中的`<bean></bean>`,放在方法的上面，而不是类，意思是产生一个bean,并交给spring管理。

#### 11、@AutoWired

byType方式。把配置好的Bean拿来用，完成属性、方法的组装，它可以对类成员变量、方法及构造函数进行标注，完成自动装配的工作。

当加上（required=false）时，就算找不到bean也不报错。

#### 12、@Qualifier

当有多个同一类型的Bean时，可以用@Qualifier("name")来指定。与@Autowired配合使用

#### 13、@Resource(name="name",type="type")

没有括号内内容的话，默认byName。与@Autowired干类似的事。

#### 14、@RequestMapping

RequestMapping是一个用来处理请求地址映射的注解；提供路由信息，负责URL到Controller中的具体函数的映射，可用于类或方法上。用于类上，表示类中的所有响应请求的方法都是以该地址作为父路径。

#### 15、@RequestParam

用在方法的参数前面。例：

`@RequestParam String a =request.getParameter("a")`

路径变量。参数与大括号里的名字一样要相同。例：

#### 16、@PathVariable

```java
RequestMapping("user/get/mac/{macAddress}")

public String getByMacAddress(@PathVariable String macAddress){

　　//do something;

}
```

Spring Profiles提供了一种隔离应用程序配置的方式，并让这些配置只能在特定的环境下生效。

#### 17、@Profiles

任何@Component或@Configuration都能被@Profile标记，从而限制加载它的时机。

```java
@Configuration

@Profile("prod")

public class ProductionConfiguration {

    // ...

}
```
Spring Boot可使用注解的方式将自定义的properties文件映射到实体bean中，比如config.properties文件。

#### 18、@ConfigurationProperties

```java
@Data

@ConfigurationProperties("rocketmq.consumer")

public class RocketMQConsumerProperties extends RocketMQProperties {

    private boolean enabled = true;

    private String consumerGroup;

    private MessageModel messageModel = MessageModel.CLUSTERING;

    private ConsumeFromWhere consumeFromWhere = ConsumeFromWhere.CONSUME_FROM_LAST_OFFSET;

    private int consumeThreadMin = 20;

    private int consumeThreadMax = 64;

    private int consumeConcurrentlyMaxSpan = 2000;

    private int pullThresholdForQueue = 1000;

    private int pullInterval = 0;

    private int consumeMessageBatchMaxSize = 1;

    private int pullBatchSize = 32;

}
```