---
title: RBAC权限详解
author: Marlowe
tags: RBAC
categories: 个人项目
abbrlink: 53215
date: 2021-06-23 20:10:49
---

<!--more-->

### 1、什么是系统权限

* 定义：对某个功能进行操作时，需要先获得相关的‘允许’，才可以操作，否则操作会被拒绝。这里的允许即为权限

* 系统权限是一个复杂过程：
  * 一个功能有多种权限操作，比如新增权限、修改权限、查看权限、删除权限等
  * 一个系统存在多种权限，比如功能权限、菜单权限、数据权限等
  * 一个管理员能拥有多种权限和多种操作

### 2、什么是RBAC

RBAC模型（Role-Based Access Control：基于角色的访问控制）模型是20世纪90年代研究出来的一种新模型，但其实在20世纪70年代的多用户计算时期，这种思想就已经被提出来，直到20世纪90年代中后期，RBAC才在研究团体中得到一些重视，并先后提出了许多类型的RBAC模型。其中以美国George Mason大学信息安全技术实验室（LIST）提出的RBAC96模型最具有代表，并得到了普遍的公认。

RBAC认为权限授权的过程可以抽象地概括为：Who是否可以对What进行How的访问操作，并对这个逻辑表达式进行判断是否为True的求解过程，也即是将权限问题转换为What、How的问题，Who、What、How构成了访问权限三元组，具体的理论可以参考RBAC96的论文，这里我们就不做详细的展开介绍，大家有个印象即可。

### 3、RBAC的组成部分

- User（用户）：每个用户都有唯一的UID识别，并被授予不同的角色
- Role（角色）：不同角色具有不同的权限
- Permission（权限）：访问权限
- 用户-角色映射：用户和角色之间的映射关系
- 角色-权限映射：角色和权限之间的映射

![20210623201537](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210623201537.png)

### 4、RBAC96模型

* RBAC96是一个家族模型，包括了rbac0、rbac1、rbac2、rbac3模型，其中rbac3最为复杂。

![20210623201611](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210623201611.png)

### 5、RBAC0模型

- 每个角色至少具备一个权限，每个用户至少扮演一个角色；
- 用户可以在会话中更改激活角色

![20210623201653](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210623201653.png)

### 6、RBAC1模型

- RBAC1模型是在RBAC0模型的基础上增加了角色可以存在继承关系
- 继承关系实现分类
  - 多继承：可以存在多个父角色
  - 单继承：只能有一个父角色

![20210623201732](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210623201732.png)

### 7、RBAC2模型

- RBAC2模型是在RBAC0模型的基础上增加了角色访问控制
- 角色访问控制规则：
  - 角色互斥：同一用户只能分配到一组互斥角色集合中的一个角色；例子：在审计活动中，一个角色不能同时被指派给会计角色和审计员角色。
  - 基数约束：一个角色被分配的数量是有限制的；比如一个功能高层领导人只有一个，因此角色需要限制为1个
  - 先决条件：指获得某个角色之前需要先获得其它角色
    - 方式一：先决角色只有一种（必要）
    - 方式二：先决角色有多种（必要）
    - 方式二：先决角色有多种（选其一）
  - 运行时互斥：例如一个用户具备两个角色，但在运行时不能同时激活两种角色


### 8、RABC3模型

* RABC3=RABC1+RABC2

![20210623201831](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210623201831.png)

### 9、RBAC3+Resources模型

- 该模型是工作中对RBAC3模型的一种扩展模型，权限是用于对资源的控制；
- 一个权限可以控制多种资源，比如一个新增用户权限包括对用户列表页面、新增按钮两种资源的访问
- 常见的Resources包括：
  - 菜单
  - 页面操作按钮
  - 文件
  - 数据：数据范围
  - 系统：oa系统、财务系统
  - 终端：电脑、手机

![20210623201857](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210623201857.png)

### 10、RBAC3+Resources+Group模型

- RBAC3+Resources的基础上增加了分组信息，用户分类管理便于操作。
- 分组实现分类：
  - 允许授权的分组【实现】
  - 非授权的分组

![20210623201928](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210623201928.png)

### 11、如何设计RBAC3+Resources+Group模型的数据库

![20210623202004](http://marlowe.oss-cn-beijing.aliyuncs.com/img/20210623202004.png)

### 12、sql附件

```sql
/*
 Navicat Premium Data Transfer

 Source Server         : localhost
 Source Server Type    : MySQL
 Source Server Version : 80016
 Source Host           : localhost:3306
 Source Schema         : rbac

 Target Server Type    : MySQL
 Target Server Version : 80016
 File Encoding         : 65001

 Date: 23/06/2021 20:20:53
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for button
-- ----------------------------
DROP TABLE IF EXISTS `button`;
CREATE TABLE `button`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '按钮名称',
  `page_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '页面id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '页面操作按钮信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for menu
-- ----------------------------
DROP TABLE IF EXISTS `menu`;
CREATE TABLE `menu`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '请求路径',
  `link_type` tinyint(1) UNSIGNED NULL DEFAULT NULL COMMENT '0本网页打开1新网页打开',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  `parent_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '父菜单',
  `page_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '页面id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '菜单信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for page
-- ----------------------------
DROP TABLE IF EXISTS `page`;
CREATE TABLE `page`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '页面信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for permission
-- ----------------------------
DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '权限名称',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '权限代码',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for permission_buttion
-- ----------------------------
DROP TABLE IF EXISTS `permission_buttion`;
CREATE TABLE `permission_buttion`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `permission_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '权限id',
  `buttion_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '按钮id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for permission_group
-- ----------------------------
DROP TABLE IF EXISTS `permission_group`;
CREATE TABLE `permission_group`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分组名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分组描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '权限组信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for permission_menu
-- ----------------------------
DROP TABLE IF EXISTS `permission_menu`;
CREATE TABLE `permission_menu`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `permission_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '权限id',
  `menu_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '菜单id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '权限菜单信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色名称，比如管理员',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '角色代码，比如admin',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `max_count` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '该角色最多使用的人数',
  `use_count` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '已使用的人数',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_exclusion_group
-- ----------------------------
DROP TABLE IF EXISTS `role_exclusion_group`;
CREATE TABLE `role_exclusion_group`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分组名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述互斥的规则',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '互斥角色分组表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_exclusion_group_item
-- ----------------------------
DROP TABLE IF EXISTS `role_exclusion_group_item`;
CREATE TABLE `role_exclusion_group_item`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '互斥分组id',
  `role_id` int(11) NULL DEFAULT NULL COMMENT '角色ID',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_extend
-- ----------------------------
DROP TABLE IF EXISTS `role_extend`;
CREATE TABLE `role_extend`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NULL DEFAULT NULL COMMENT '角色Id',
  `parent_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '父角色Id',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色父类继承关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_include_group
-- ----------------------------
DROP TABLE IF EXISTS `role_include_group`;
CREATE TABLE `role_include_group`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '角色Id（该组是该角色的先决条件）',
  `name` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分组名称',
  `type` tinyint(1) UNSIGNED NULL DEFAULT NULL COMMENT '先决项之间的逻辑关系0and ，1or',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色先决条件信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_include_group_item
-- ----------------------------
DROP TABLE IF EXISTS `role_include_group_item`;
CREATE TABLE `role_include_group_item`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '互斥分组id',
  `role_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '角色ID',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '先决条件项信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_merge_group
-- ----------------------------
DROP TABLE IF EXISTS `role_merge_group`;
CREATE TABLE `role_merge_group`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '合并后的权限名称',
  `code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '合并后的权限代码',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_merge_group_item
-- ----------------------------
DROP TABLE IF EXISTS `role_merge_group_item`;
CREATE TABLE `role_merge_group_item`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '角色ID',
  `group_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '合并分组id',
  `created_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色合并项信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for role_permission
-- ----------------------------
DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '角色id',
  `permission_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '权限id',
  `created_time` datetime(0) NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色权限关系信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for roloe_group
-- ----------------------------
DROP TABLE IF EXISTS `roloe_group`;
CREATE TABLE `roloe_group`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分组名称',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分组描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '角色组信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '登录名',
  `password` varchar(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '登录密码',
  `name` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '真实姓名',
  `sex` tinyint(1) UNSIGNED NULL DEFAULT NULL COMMENT '0未知 1男 2女',
  `old` int(2) UNSIGNED NULL DEFAULT NULL COMMENT '年龄',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  `last_login_time` datetime(0) NULL DEFAULT NULL COMMENT '最后一次登录时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_group
-- ----------------------------
DROP TABLE IF EXISTS `user_group`;
CREATE TABLE `user_group`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分组名称',
  `parent_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '父ID',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL COMMENT '分组描述',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '部门信息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_role
-- ----------------------------
DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '用户id',
  `role_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '角色id',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户角色关系表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for user_role_group
-- ----------------------------
DROP TABLE IF EXISTS `user_role_group`;
CREATE TABLE `user_role_group`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '用户id',
  `role_group_id` int(10) UNSIGNED NULL DEFAULT NULL COMMENT '角色id',
  `created_time` datetime(0) NULL DEFAULT NULL COMMENT '创建时间',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '用户角色组关系表' ROW_FORMAT = Dynamic;

SET FOREIGN_KEY_CHECKS = 1;
```


