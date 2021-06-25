---
title: SpringBoot + MyBatis-Plus + Swagger快速创建后台项目
author: Marlowe
tags:
  - SpringBoot
  - MyBatis-Plus
  - Swagger
categories: 个人项目
abbrlink: 14903
date: 2021-06-08 20:07:21
---

本文主要用于记录综合课程设计Ⅲ中的学习的后台相关插件使用...
<!--more-->

### 项目简介


### 快速开始

#### 1、GitHub创建项目

[我的GitHub地址](https://github.com/XMMarlowe)

1. 新建一个代码仓库，用于管理项目代码
![20210608201141](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608201141.png)

![20210608201420](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608201420.png)

#### 2、使用idea将代码下载到本地并新建Springboot模块

![20210608201506](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608201506.png)

![20210608201853](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608201853.png)

1. 新建SpringBoot项目模块

![20210608202216](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608202216.png)


![20210608202407](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608202407.png)

2. 勾选相关依赖

![20210608202454](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608202454.png)

3. 项目创建成功

![20210608203427](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608203427.png)


#### 3、创建数据库

1. 在navcat中新建数据库

![20210608205809](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608205809.png)


新建`employee表`

![20210608210231](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608210231.png)



#### 4、开始编写代码

##### 1. 将`application.properties` 文件删除并新建`application.yml`、`application-dev.yml`、`application-prod.yml`。

##### 2. 分别编写对应的配置文件

application.yml

```yml
server:
  port: 8080
  servlet:
    context-path: /
spring:
  profiles:
    active: prod
  datasource:
    druid:
      url: jdbc:mysql://localhost:3306/weixin?useUnicode=true&characterEncoding=UTF-8&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=GMT%2b8
      username: root
      password: root
      initial-size: 1
      min-idle: 1
      max-active: 20
      test-on-borrow: true
      driver-class-name: com.mysql.cj.jdbc.Driver
```

application-dev.yml

```yml
server:
  port: 8081
  servlet:
    context-path: /
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/weixin?useUnicode=true&characterEncoding=UTF-8&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=GMT%2b8
    username: root
    password: root
    driver-class-name: com.mysql.cj.jdbc.Driver


mybatis-plus:
  # xml地址
  mapper-locations: classpath:mapper/*Mapper.xml
  # 实体扫描，多个package用逗号或者分号分隔
  type-aliases-package: com.marlowe.music.entity   #自己的实体类地址
  configuration:
    # 这个配置会将执行的sql打印出来，在开发或测试的时候可以用
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

application-prod.yml

```yml
server:
  port: 8081
  servlet:
    context-path: /
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/weixin?useUnicode=true&characterEncoding=UTF-8&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=GMT%2b8
    username: root
    password: root
    driver-class-name: com.mysql.cj.jdbc.Driver


mybatis-plus:
  # xml地址
  mapper-locations: classpath:mapper/*Mapper.xml
  # 实体扫描，多个package用逗号或者分号分隔
  type-aliases-package: com.marlowe.music.entity   #自己的实体类地址
  configuration:
    # 这个配置会将执行的sql打印出来，在开发或测试的时候可以用
    log-impl: org.apache.ibatis.logging.stdout.StdOutImpl
```

##### 3. 引入相关依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>

<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>

<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-test</artifactId>
    <scope>test</scope>
</dependency>

<!--MySQL-->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.25</version>
</dependency>

<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>druid</artifactId>
    <version>1.2.6</version>
</dependency>

<!--fastjson-->
<dependency>
    <groupId>com.alibaba</groupId>
    <artifactId>fastjson</artifactId>
    <version>1.2.62</version>
</dependency>

<!--swagger在线文档-->
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
<dependency>
    <groupId>com.hankcs</groupId>
    <artifactId>hanlp</artifactId>
    <version>portable-1.1.5</version>
</dependency>

<!--hutool-->
<dependency>
    <groupId>cn.hutool</groupId>
    <artifactId>hutool-all</artifactId>
    <version>5.1.0</version>
</dependency>
<!--mybatis-plus-->
<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-boot-starter</artifactId>
    <version>3.0.5</version>
</dependency>

<dependency>
    <groupId>com.baomidou</groupId>
    <artifactId>mybatis-plus-generator</artifactId>
    <version>3.4.1</version>
</dependency>


<!--MyBatis 分页插件: MyBatis PageHelper-->
<!-- https://mvnrepository.com/artifact/com.github.pagehelper/pagehelper -->
<dependency>
    <groupId>com.github.pagehelper</groupId>
    <artifactId>pagehelper-spring-boot-starter</artifactId>
    <version>1.3.0</version>
</dependency>

<!-- velocity 模板引擎, Mybatis Plus 代码生成器需要 -->
<dependency>
    <groupId>org.apache.velocity</groupId>
    <artifactId>velocity-engine-core</artifactId>
    <version>2.3</version>
</dependency>

<dependency>
    <groupId>org.freemarker</groupId>
    <artifactId>freemarker</artifactId>
    <version>2.3.31</version>
</dependency>
```

##### 4. 创建公共包

新建commons包，用于统一结果处理，统一异常处理，以及代码生成器配置

1. 统一结果处理

编写错误代码类

`ErrorCode.java`

```java
public enum ErrorCode {

    /**
     * 请求成功
     */
    SUCCESS("200", "请求成功"),
    /**
     * 请求失败
     */
    ERROR("500", "请求失败");
    
    private String code;
    private String message;

    public String getCode() {
        return this.code;
    }

    public String getMessage() {
        return this.message;
    }

    ErrorCode(String _code, String _message) {
        this.code = _code;
        this.message = _message;
    }
}
```

编写统一结果接口

`IResult.java`

```java
public interface IResult<T> {

    /**
     * 获得信息
     *
     * @return
     */
    String getMsg();

    /**
     * 获得状态码
     *
     * @return
     */
    String getCode();

    /**
     * 获得数据
     *
     * @return
     */
    T getData();
}
```

编写统一结果实现类

`Result.java`

```java
@Data
@AllArgsConstructor
@NoArgsConstructor
public class Result<T> implements Serializable, IResult<T> {

    /**
     * 200:成功   其他：失败
     */
    private String code;
    private String msg;
    private T data;

    public static Result ok() {
        return new Result(ErrorCode.SUCCESS.getCode(), ErrorCode.SUCCESS.getMessage(), null);
    }

    public static Result ok(String msg) {
        return new Result(ErrorCode.SUCCESS.getCode(), msg, null);
    }

    public static Result ok(String msg, Object data) {
        return new Result(ErrorCode.SUCCESS.getCode(), msg, data);
    }

    public static Result ok(Object data) {
        return new Result(ErrorCode.SUCCESS.getCode(), ErrorCode.SUCCESS.getMessage(), data);
    }


    public static Result error() {
        return new Result(ErrorCode.ERROR.getCode(), ErrorCode.ERROR.getMessage(), null);
    }

    public static Result error(ErrorCode errorCode) {
        return new Result(errorCode.getCode(), errorCode.getMessage(), null);
    }

    public static Result error(String code, String msg) {
        return new Result(code, msg, null);
    }


    public static Result error(String code, String msg, Object data) {
        return new Result(code, ErrorCode.ERROR.getMessage(), data);
    }

    public static Result error(ErrorCode errorCode, String msg) {
        return new Result(ErrorCode.ERROR.getCode(), msg, null);
    }

    /**
     * 获得信息
     *
     * @return
     */
    @Override
    public String getMsg() {
        return this.msg;
    }

    /**
     * 获得状态码
     *
     * @return
     */
    @Override
    public String getCode() {
        return this.code;
    }

    /**
     * 获得数据
     *
     * @return
     */
    @Override
    public T getData() {
        return this.data;
    }

    @Override
    public String toString() {
        return "Result{" +
                "code='" + code + '\'' +
                ", msg='" + msg + '\'' +
                ", data=" + data +
                '}';
    }
}
```

2. 编写代码自动生成类，并修改配置

`CodeGenerator.java`

```java
public class CodeGenerator {
    /**
     * <p>
     * 读取控制台内容
     * </p>
     */
    public static String scanner(String tip) {
        Scanner scanner = new Scanner(System.in);
        StringBuilder help = new StringBuilder();
        help.append("请输入" + tip + "：");
        System.out.println(help.toString());
        if (scanner.hasNext()) {
            String ipt = scanner.next();
            if (StringUtils.isNotEmpty(ipt)) {
                return ipt;
            }
        }
        throw new MybatisPlusException("请输入正确的" + tip + "！");
    }

    public static void main(String[] args) {
        // 代码生成器
        AutoGenerator mpg = new AutoGenerator();

        // 全局配置
        GlobalConfig gc = new GlobalConfig();
        String projectPath = System.getProperty("user.dir");
        gc.setOutputDir(projectPath + "/src/main/java"); //生成文件输出目录
        gc.setAuthor("marlowe");
        gc.setOpen(false);
        // gc.setSwagger2(true); 实体属性 Swagger2 注解
        mpg.setGlobalConfig(gc);

        // 数据源配置
        DataSourceConfig dsc = new DataSourceConfig();
        dsc.setUrl("jdbc:mysql://localhost:3306/music?useUnicode=true&useSSL=false&characterEncoding=utf8&serverTimezone=UTC");
        dsc.setDriverName("com.mysql.cj.jdbc.Driver");
        dsc.setUsername("root");
        dsc.setPassword("root");
        mpg.setDataSource(dsc);

        // 包配置
        PackageConfig pc = new PackageConfig();
//        pc.setModuleName(scanner("模块名"));
        pc.setParent("com.marlowe.music");
        pc.setController("controller");
        pc.setEntity("entity");
        pc.setService("service");
        pc.setMapper("mapper");
        mpg.setPackageInfo(pc);
        // 自定义配置
        InjectionConfig cfg = new InjectionConfig() {
            @Override
            public void initMap() {
                // to do nothing
            }
        };
        //如果模板引擎是 freemarker
        String templatePath = "/templates/mapper.xml.ftl";
        // 自定义输出配置
        List<FileOutConfig> focList = new ArrayList<>();
        // 自定义配置会被优先输出
//        focList.add(new FileOutConfig(templatePath) {
//            @Override
//            public String outputFile(TableInfo tableInfo) {
//                // 自定义输出文件名 ， 如果你 Entity 设置了前后缀、此处注意 xml 的名称会跟着发生变化！！
//                return projectPath + "/src/main/resources/mapper/" + pc.getModuleName()
//                        + "/" + tableInfo.getEntityName() + "Mapper" + StringPool.DOT_XML;
//            }
//        });
        cfg.setFileOutConfigList(focList);
        mpg.setCfg(cfg); //这个必须要,需要提供一个默认的

        // 策略配置
        StrategyConfig strategy = new StrategyConfig();
        strategy.setNaming(NamingStrategy.underline_to_camel);//表名生成策略
        strategy.setColumnNaming(NamingStrategy.underline_to_camel);//实体字段生成策略
        strategy.setInclude(scanner("表名").split(",")); //需要生成的表
        //strategy.setSuperEntityClass("com.baomidou.ant.common.BaseEntity");
        strategy.setEntityLombokModel(true);//使用lombook
        strategy.setRestControllerStyle(true);
        // 公共父类
        //strategy.setSuperControllerClass("com.baomidou.ant.common.BaseController");
        // 写于父类中的公共字段
//        strategy.setSuperEntityColumns("id");
//        strategy.setInclude(scanner("表名，多个英文逗号分割").split(","));
//        strategy.setControllerMappingHyphenStyle(true);
//        strategy.setTablePrefix(pc.getModuleName() + "_");
        mpg.setStrategy(strategy);
        mpg.setTemplateEngine(new FreemarkerTemplateEngine());
        mpg.execute();
    }
}
```

##### 5. 创建配置类包

1. 编写Swagger配置类

`SwaggerConfig.java`

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
                .apiInfo(apiInfo())
                .groupName("Marlowe")
                // enable是否启动Swagger，如果为false，则swagger不能在浏览器中访问
                .select()
                .apis(RequestHandlerSelectors.basePackage("com.marlowe.music.controller"))
                .build();
    }

    public ApiInfo apiInfo() {

        // 作者信息
        Contact contact = new Contact("Marlowe", "https://xmmarlowe.github.io", "marlowe246@qq.com");

        return new ApiInfo("SpringBoot-VUE-Music API Documentation",
                "Api Documentation",
                "v1.0", "urn:tos",
                contact, "Apache 2.0",
                "http://www.apache.org/licenses/LICENSE-2.0", new ArrayList());
    }
}
```

2. 编写Pagehelper配置类

`PageHelperConfig.java`

```java
@Configuration
public class PageHelperConfig {

    @Bean
    public PageHelper pageHelper() {
        PageHelper pageHelper = new PageHelper();
        Properties properties = new Properties();
        //把这个设置为true，会带RowBounds第一个参数offset当成PageNum使用
        properties.setProperty("offsetAsPageNum", "true");
        //设置为true时，使用RowBounds分页会进行count查询
        properties.setProperty("rowBoundsWithCount", "true");
        properties.setProperty("reasonable", "true");
        pageHelper.setProperties(properties);
        return pageHelper;
    }
}
```

##### 6. 运行CodeGenerator

得到相关代码

![20210608221549](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608221549.png)

1. 编写service接口

`IEmployeeService.java`

```java
public interface IEmployeeService extends IService<Employee> {

    /**
     * 添加员工
     * @param employee
     * @return
     */
    boolean addEmployee(Employee employee);

    /**
     * 通过id删除员工
     * @param id
     * @return
     */
    boolean delete(int id);

    /**
     * 通过员工姓名分页查询员工
     * @param name
     * @param pageNo
     * @param pageSize
     * @return
     */
    PageInfo<Employee> findByName(String name,int pageNo,int pageSize);

}
```

2. 编写service实现类

`EmployeeServiceImpl.java`

```java
@Service
public class EmployeeServiceImpl extends ServiceImpl<EmployeeMapper, Employee> implements IEmployeeService {

    @Autowired
    private EmployeeMapper employeeMapper;


    /**
     * 添加员工
     *
     * @param employee
     * @return
     */
    @Override
    public boolean addEmployee(Employee employee) {
        return employeeMapper.insert(employee) > 0;
    }

    /**
     * 通过id删除员工
     *
     * @param id
     * @return
     */
    @Override
    public boolean delete(int id) {
        return employeeMapper.deleteById(id) > 0;
    }

    /**
     * 通过员工姓名分页查询员工
     *
     * @param name
     * @param pageNo
     * @param pageSize
     * @return
     */
    @Override
    public PageInfo<Employee> findByName(String name, int pageNo, int pageSize) {
        // 设置分页查询参数
        PageHelper.startPage(pageNo, pageSize);
        QueryWrapper<Employee> queryWrapper = new QueryWrapper<>();
        queryWrapper.like("name", name);
        List<Employee> employees = employeeMapper.selectList(queryWrapper);
        PageInfo<Employee> pageInfo = new PageInfo(employees);
        return pageInfo;
    }
}
```

3. 编写controller

`EmployeeController.java`

```java
@RestController
@Api(tags = "员工管理控制器")
@RequestMapping("/employee")
public class EmployeeController {

    @Autowired
    private EmployeeServiceImpl employeeService;

    @ApiOperation(value = "添加员工")
    @PostMapping("add")
    public String addEmployee(@RequestBody Employee employee) {
        boolean b = employeeService.addEmployee(employee);
        if (b) {
            return "添加成功";
        } else {
            return "添加失败";
        }

    }

    /**
     * 根据id删除员工
     *
     * @param id
     * @return
     */
    @ApiOperation(value = "根据id删除员工")
    @PostMapping("delete/{id}")
    public Result deleteEmployee(@PathVariable int id) {
        boolean delete = employeeService.delete(id);
        if (delete) {
            return Result.ok("删除成功");
        } else {
            return Result.ok("删除失败");
        }
    }

    /**
     * 通过姓名分页查找员工
     *
     * @param name
     * @return
     */
    @ApiOperation(value = "通过姓名分页查找员工")
    @PostMapping("find/{name}/{pageNo}/{pageSize}")
    public Result<List<Employee>> findEmployee(@PathVariable String name, @PathVariable int pageNo, @PathVariable int pageSize) {
        PageInfo<Employee> pageInfo = employeeService.findByName(name, pageNo, pageSize);
        List<Employee> employees = pageInfo.getList();
        return Result.ok(employees);
    }

}
```

4. 在启动类加@MapperScan("mapper的包名")

```java
@MapperScan("com.marlowe.whell.mapper")
```

5. 启动代码

6. 访问swagger在线文档

[swagger在线文档](http://localhost:8088/swagger-ui.html#)

![20210608225149](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210608225149.png)

分别测试所有接口即可。

### 参考资料

[Marlowe's的个人博客](https://xmmarlowe.github.io/)

[项目地址](..)