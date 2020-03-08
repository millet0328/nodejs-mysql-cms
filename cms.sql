/*
 Navicat Premium Data Transfer

 Source Server         : app
 Source Server Type    : MySQL
 Source Server Version : 50553
 Source Host           : localhost:3306
 Source Schema         : cms

 Target Server Type    : MySQL
 Target Server Version : 50553
 File Encoding         : 65001

 Date: 09/03/2020 01:17:32
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '密码',
  `fullname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `sex` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '男' COMMENT '性别',
  `tel` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '手机号码',
  `email` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '../images/avatar/default.jpg' COMMENT '头像',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 4 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '管理员' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '123', '赵薇', '女', '15863008280', 'nn880328@126.com', '../images/avatar/default.jpg');
INSERT INTO `admin` VALUES (2, 'tom', '123456', '黄小米', '女', '13475829262', 'nn880328@126.com', '../images/avatar/default.jpg');
INSERT INTO `admin` VALUES (3, 'moz', '123', '罗志祥', '男', '15863008280', 'nn880328@126.com', '../images/avatar/default.jpg');

-- ----------------------------
-- Table structure for admin_role
-- ----------------------------
DROP TABLE IF EXISTS `admin_role`;
CREATE TABLE `admin_role`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `admin_id` int(11) NULL DEFAULT NULL COMMENT '用户id',
  `role_id` int(11) NULL DEFAULT NULL COMMENT '角色id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Fixed;

-- ----------------------------
-- Records of admin_role
-- ----------------------------
INSERT INTO `admin_role` VALUES (2, 2, 2);
INSERT INTO `admin_role` VALUES (1, 1, 1);
INSERT INTO `admin_role` VALUES (4, 6, 3);

-- ----------------------------
-- Table structure for article
-- ----------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cate_1st` int(11) NOT NULL COMMENT '一级分类id',
  `cate_2nd` int(11) NOT NULL COMMENT '二级分类id',
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '标题',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '摘要',
  `content` varchar(8000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '正文',
  `create_date` timestamp NULL DEFAULT NULL COMMENT '发表日期',
  `update_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  `main_photo` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '主图',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 3 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of article
-- ----------------------------
INSERT INTO `article` VALUES (1, 2, 11, '百度向今日头条索赔9000万，称其不正当竞争窃取搜索结果', '今日头条(北京字节跳动科技有限公司)因大量窃取百度“TOP1” 搜索产品结果，被百度以不正当竞争为由起诉到北京市海淀区人民法院，要求字节跳动立即停止侵权，赔偿相关经济损失及合理支出共计人民币9000万元，并连续30天在其App及网站首页道歉。', '<p>科技先生4月26日讯，今日头条(北京字节跳动科技有限公司)因大量窃取百度“TOP1” 搜索产品结果，被百度以不正当竞争为由起诉到北京市海淀区人民法院，要求字节跳动立即停止侵权，赔偿相关经济损失及合理支出共计人民币9000万元，并连续30天在其App及网站首页道歉。</p><p>除民事起诉外，百度也同时向法院提交了行为禁止保全申请书。</p><div><br></div><p>百度方面向法院出示的一些证据中显示：在今日头条搜索 “螃蟹和西红柿吃会中毒吗”，首个搜索结果中的图片上打着百度LOGO水印;而搜索“1立方厘米水等于多少升”，首条搜索结果中，嵌入了“抄自百度”的字眼。百度方面表示，这些是百度为防止TOP1搜索结果被抄袭预先打下的“防伪标记”。</p><p>百度方面表示，“TOP1”产品，是百度 2017 年初推出的“搜索结果首条直接满足”搜索产品的简称。不同于传统搜索用URL(链接地址)满足用户搜索需求，TOP1产品创造性地在搜索结果首位，将用户所寻找的答案或者查找的资源直接展示给用户，提升用户获取信息的效率。</p><div><br></div><p>TOP1 产品属于百度在AI领域的前瞻性探索，需要极高的技术运用，也需要强大的生态运营能力，百度为此投入了大量人力物力。</p><p>而在今日头条“头条搜索”服务的搜索结果中，存在大量盗用百度“TOP1产品”搜索结果的内容，盗用内容既包括百度公司运用算法和历史数据挖掘出的匹配用户需求的TOP1搜索结果，也包括百度花费大量成本与生态合作伙伴一起运营的TOP1搜索结果。</p><p>百度认为，这种行为是对自己技术及劳动成果的公然窃取，已经构成侵权。</p>', '2019-04-26 14:55:21', '2020-03-08 22:40:39', '/images/details/355a67c0-67f0-11e9-b7fb-3d2cafb359a4.jpeg');
INSERT INTO `article` VALUES (2, 2, 11, '亚马逊2019第一季度财报：净利润同比增长118% AWS业务增速迅猛', '根据这份财报显示，亚马逊销售额增速不错。第一季度总净销售额为597亿美元，高于市场预期596.53亿美元，对比去年同期为510.42亿美元同比增长17%。', '<p>美股研究社最新消息 亚马逊在周四盘后发布2019财年第一季度的财报。</p><p>根据这份财报显示，亚马逊销售额增速不错。第一季度总净销售额为597亿美元，高于市场预期596.53亿美元，对比去年同期为510.42亿美元同比增长17%。</p><p>本季度亚马逊各条业务增长都不错，其中北美地区净销售额为358.12亿美元，去年同期为307.25亿美元；线上商店销售额为294.98亿美元，去年同期为269.39亿美元；国际净销售额为161.92亿美元，去年同期为148.75亿美元。</p><div><br></div><p>净利润方面，亚马逊第一季度净利润为35.61亿美元，高于市场预期23.81亿美元，达到去年同期16.29亿美元的2倍以上，同比增长118%。</p><p>其中，季度广告服务以及其他销售额为27.16亿美元，去年同期为20.31亿美元；季度AWS运营利润增速迅猛达到22.23亿美元，去年同期为14亿美元，同比增长近59%。</p><p>第一季度EPS 7.09美元，市场预期4.67美元。</p><p>目前，亚马逊预计第二季度总销售额为595-635亿美元，预计第二季度运营利润为26-36亿美元。受财报利好消息影响，目前亚马逊盘后涨幅已经超过1%.</p>', '2019-04-26 14:56:54', '2020-03-08 22:40:44', '/images/details/6f70b4a0-67f0-11e9-b7fb-3d2cafb359a4.jpeg');

-- ----------------------------
-- Table structure for article_tag
-- ----------------------------
DROP TABLE IF EXISTS `article_tag`;
CREATE TABLE `article_tag`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `article_id` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '博客ID',
  `tag_id` int(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT '标签ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '博客to标签中间表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of article_tag
-- ----------------------------

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '分类id',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '分类名称',
  `parent_id` int(11) NOT NULL COMMENT '父级id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of category
-- ----------------------------
INSERT INTO `category` VALUES (1, '科技', 0);
INSERT INTO `category` VALUES (2, '娱乐', 0);
INSERT INTO `category` VALUES (3, '摄影', 2);
INSERT INTO `category` VALUES (4, '电影', 2);
INSERT INTO `category` VALUES (5, '人工智能', 1);
INSERT INTO `category` VALUES (6, '黑客技术', 1);
INSERT INTO `category` VALUES (7, '编程', 0);
INSERT INTO `category` VALUES (8, '前端', 7);
INSERT INTO `category` VALUES (9, 'JAVA', 7);
INSERT INTO `category` VALUES (10, 'PHP', 7);
INSERT INTO `category` VALUES (11, 'IT新闻', 2);
INSERT INTO `category` VALUES (12, '设计', 0);
INSERT INTO `category` VALUES (13, 'UI设计', 12);
INSERT INTO `category` VALUES (14, '平面设计', 12);

-- ----------------------------
-- Table structure for menu
-- ----------------------------
DROP TABLE IF EXISTS `menu`;
CREATE TABLE `menu`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '菜单id',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `pId` int(11) NULL DEFAULT NULL COMMENT '父级id',
  `path` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '链接url',
  `menu_order` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '显示顺序',
  `icon_id` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '图标id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 16 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of menu
-- ----------------------------
INSERT INTO `menu` VALUES (1, '全部菜单', 0, '', '0', NULL);
INSERT INTO `menu` VALUES (2, '信息面板', 1, '', '2000', NULL);
INSERT INTO `menu` VALUES (3, '文章管理', 1, '', '3000', NULL);
INSERT INTO `menu` VALUES (4, '分类管理', 1, '/category/list', '4000', NULL);
INSERT INTO `menu` VALUES (5, '用户管理', 1, '', '5000', NULL);
INSERT INTO `menu` VALUES (6, '管理员管理', 1, '', '6000', NULL);
INSERT INTO `menu` VALUES (8, '账户设置', 1, '/admin/info', '8000', NULL);
INSERT INTO `menu` VALUES (7, '权限管理', 1, '', '7000', NULL);
INSERT INTO `menu` VALUES (9, '发布文章', 3, '/article/release', '3001', NULL);
INSERT INTO `menu` VALUES (10, '文章列表', 3, '/article/list', '3002', NULL);
INSERT INTO `menu` VALUES (11, '分类列表', 4, '/category/list', '4001', NULL);
INSERT INTO `menu` VALUES (12, '用户列表', 5, '/user/list', '5001', NULL);
INSERT INTO `menu` VALUES (13, '管理员列表', 6, '/admin/list', '6001', NULL);
INSERT INTO `menu` VALUES (14, '权限角色', 7, '/auth/role', '7001', NULL);

-- ----------------------------
-- Table structure for role
-- ----------------------------
DROP TABLE IF EXISTS `role`;
CREATE TABLE `role`  (
  `id` int(11) NOT NULL AUTO_INCREMENT COMMENT '角色id',
  `role_name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '角色名称',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of role
-- ----------------------------
INSERT INTO `role` VALUES (1, '超级管理员');
INSERT INTO `role` VALUES (2, '管理员');
INSERT INTO `role` VALUES (3, '编辑');
INSERT INTO `role` VALUES (4, '设计');

-- ----------------------------
-- Table structure for role_menu
-- ----------------------------
DROP TABLE IF EXISTS `role_menu`;
CREATE TABLE `role_menu`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `role_id` int(11) NULL DEFAULT NULL COMMENT '角色id',
  `menu_id` int(11) NULL DEFAULT NULL COMMENT '权限id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 23 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Fixed;

-- ----------------------------
-- Records of role_menu
-- ----------------------------
INSERT INTO `role_menu` VALUES (1, 1, 2);
INSERT INTO `role_menu` VALUES (2, 1, 3);
INSERT INTO `role_menu` VALUES (3, 1, 4);
INSERT INTO `role_menu` VALUES (4, 1, 5);
INSERT INTO `role_menu` VALUES (5, 1, 6);
INSERT INTO `role_menu` VALUES (6, 1, 7);
INSERT INTO `role_menu` VALUES (7, 1, 8);
INSERT INTO `role_menu` VALUES (8, 1, 9);
INSERT INTO `role_menu` VALUES (9, 1, 10);
INSERT INTO `role_menu` VALUES (10, 1, 11);
INSERT INTO `role_menu` VALUES (11, 1, 12);
INSERT INTO `role_menu` VALUES (12, 1, 13);
INSERT INTO `role_menu` VALUES (13, 1, 14);
INSERT INTO `role_menu` VALUES (14, 2, 2);
INSERT INTO `role_menu` VALUES (15, 2, 3);
INSERT INTO `role_menu` VALUES (16, 2, 4);
INSERT INTO `role_menu` VALUES (17, 2, 5);
INSERT INTO `role_menu` VALUES (18, 2, 8);
INSERT INTO `role_menu` VALUES (19, 2, 9);
INSERT INTO `role_menu` VALUES (20, 2, 10);
INSERT INTO `role_menu` VALUES (21, 2, 11);
INSERT INTO `role_menu` VALUES (22, 2, 12);

-- ----------------------------
-- Table structure for tag
-- ----------------------------
DROP TABLE IF EXISTS `tag`;
CREATE TABLE `tag`  (
  `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '账户' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tag
-- ----------------------------
INSERT INTO `tag` VALUES (1, 'Web前端');
INSERT INTO `tag` VALUES (2, '后台编程');
INSERT INTO `tag` VALUES (3, '数据库');
INSERT INTO `tag` VALUES (4, 'Javascript');
INSERT INTO `tag` VALUES (5, 'CSS3');
INSERT INTO `tag` VALUES (6, '网页设计');
INSERT INTO `tag` VALUES (7, 'UI设计');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(80) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '密码',
  `nickname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '姓名',
  `sex` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '男' COMMENT '性别',
  `tel` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '手机号码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'moz', '1', '张艺兴', '男', '15863008280');

SET FOREIGN_KEY_CHECKS = 1;
