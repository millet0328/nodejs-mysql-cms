/*
 Navicat Premium Data Transfer

 Source Server         : app
 Source Server Type    : MySQL
 Source Server Version : 80019
 Source Host           : localhost:3306
 Source Schema         : cms

 Target Server Type    : MySQL
 Target Server Version : 80019
 File Encoding         : 65001

 Date: 13/04/2020 21:52:01
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for admin
-- ----------------------------
DROP TABLE IF EXISTS `admin`;
CREATE TABLE `admin`  (
  `id` int(0) UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '密码',
  `fullname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `sex` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '男' COMMENT '性别',
  `tel` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '手机号码',
  `email` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '../images/avatar/default.jpg' COMMENT '头像',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 5 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '管理员' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of admin
-- ----------------------------
INSERT INTO `admin` VALUES (1, 'admin', '123', '赵薇', '女', '15863008280', 'nn880328@126.com', '../images/avatar/default.jpg');
INSERT INTO `admin` VALUES (2, 'tom', '123456', '黄小米', '女', '13475829262', 'nn880328@126.com', '../images/avatar/default.jpg');
INSERT INTO `admin` VALUES (3, 'moz', '123', '罗志祥', '男', '15863008280', 'nn880328@126.com', '../images/avatar/default.jpg');
INSERT INTO `admin` VALUES (4, 'silky', '123', '鹿晗', '男', '15863008280', 'nn880328@126.com', '../images/avatar/default.jpg');

-- ----------------------------
-- Table structure for admin_role
-- ----------------------------
DROP TABLE IF EXISTS `admin_role`;
CREATE TABLE `admin_role`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `admin_id` int(0) NULL DEFAULT NULL COMMENT '用户id',
  `role_id` int(0) NULL DEFAULT NULL COMMENT '角色id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = MyISAM AUTO_INCREMENT = 6 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Fixed;

-- ----------------------------
-- Records of admin_role
-- ----------------------------
INSERT INTO `admin_role` VALUES (2, 2, 2);
INSERT INTO `admin_role` VALUES (1, 1, 1);
INSERT INTO `admin_role` VALUES (4, 6, 3);
INSERT INTO `admin_role` VALUES (5, 4, 3);

-- ----------------------------
-- Table structure for article
-- ----------------------------
DROP TABLE IF EXISTS `article`;
CREATE TABLE `article`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `cate_1st` int(0) NOT NULL COMMENT '一级分类id',
  `cate_2nd` int(0) NOT NULL COMMENT '二级分类id',
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '标题',
  `description` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '摘要',
  `content` varchar(8000) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '正文',
  `create_date` timestamp(0) NULL DEFAULT NULL COMMENT '发表日期',
  `update_date` timestamp(0) NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP(0) COMMENT '更新日期',
  `main_photo` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '主图',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of article
-- ----------------------------
INSERT INTO `article` VALUES (1, 2, 11, '百度向今日头条索赔9000万，称其不正当竞争窃取搜索结果', '今日头条(北京字节跳动科技有限公司)因大量窃取百度“TOP1” 搜索产品结果，被百度以不正当竞争为由起诉到北京市海淀区人民法院，要求字节跳动立即停止侵权，赔偿相关经济损失及合理支出共计人民币9000万元，并连续30天在其App及网站首页道歉。', '<p>科技先生4月26日讯，今日头条(北京字节跳动科技有限公司)因大量窃取百度“TOP1” 搜索产品结果，被百度以不正当竞争为由起诉到北京市海淀区人民法院，要求字节跳动立即停止侵权，赔偿相关经济损失及合理支出共计人民币9000万元，并连续30天在其App及网站首页道歉。</p><p>除民事起诉外，百度也同时向法院提交了行为禁止保全申请书。</p><div><br></div><p>百度方面向法院出示的一些证据中显示：在今日头条搜索 “螃蟹和西红柿吃会中毒吗”，首个搜索结果中的图片上打着百度LOGO水印;而搜索“1立方厘米水等于多少升”，首条搜索结果中，嵌入了“抄自百度”的字眼。百度方面表示，这些是百度为防止TOP1搜索结果被抄袭预先打下的“防伪标记”。</p><p>百度方面表示，“TOP1”产品，是百度 2017 年初推出的“搜索结果首条直接满足”搜索产品的简称。不同于传统搜索用URL(链接地址)满足用户搜索需求，TOP1产品创造性地在搜索结果首位，将用户所寻找的答案或者查找的资源直接展示给用户，提升用户获取信息的效率。</p><div><br></div><p>TOP1 产品属于百度在AI领域的前瞻性探索，需要极高的技术运用，也需要强大的生态运营能力，百度为此投入了大量人力物力。</p><p>而在今日头条“头条搜索”服务的搜索结果中，存在大量盗用百度“TOP1产品”搜索结果的内容，盗用内容既包括百度公司运用算法和历史数据挖掘出的匹配用户需求的TOP1搜索结果，也包括百度花费大量成本与生态合作伙伴一起运营的TOP1搜索结果。</p><p>百度认为，这种行为是对自己技术及劳动成果的公然窃取，已经构成侵权。</p>', '2019-04-26 14:55:21', '2020-04-13 21:46:10', 'http://localhost:3001/images/common/355a67c0-67f0-11e9-b7fb-3d2cafb359a4.jpeg');
INSERT INTO `article` VALUES (2, 2, 11, '亚马逊2019第一季度财报：净利润同比增长118% AWS业务增速迅猛', '根据这份财报显示，亚马逊销售额增速不错。第一季度总净销售额为597亿美元，高于市场预期596.53亿美元，对比去年同期为510.42亿美元同比增长17%。', '<p>美股研究社最新消息 亚马逊在周四盘后发布2019财年第一季度的财报。</p><p>根据这份财报显示，亚马逊销售额增速不错。第一季度总净销售额为597亿美元，高于市场预期596.53亿美元，对比去年同期为510.42亿美元同比增长17%。</p><p>本季度亚马逊各条业务增长都不错，其中北美地区净销售额为358.12亿美元，去年同期为307.25亿美元；线上商店销售额为294.98亿美元，去年同期为269.39亿美元；国际净销售额为161.92亿美元，去年同期为148.75亿美元。</p><div><br></div><p>净利润方面，亚马逊第一季度净利润为35.61亿美元，高于市场预期23.81亿美元，达到去年同期16.29亿美元的2倍以上，同比增长118%。</p><p>其中，季度广告服务以及其他销售额为27.16亿美元，去年同期为20.31亿美元；季度AWS运营利润增速迅猛达到22.23亿美元，去年同期为14亿美元，同比增长近59%。</p><p>第一季度EPS 7.09美元，市场预期4.67美元。</p><p>目前，亚马逊预计第二季度总销售额为595-635亿美元，预计第二季度运营利润为26-36亿美元。受财报利好消息影响，目前亚马逊盘后涨幅已经超过1%.</p>', '2019-04-26 14:56:54', '2020-04-13 21:46:20', 'http://localhost:3001/images/common/6f70b4a0-67f0-11e9-b7fb-3d2cafb359a4.jpeg');
INSERT INTO `article` VALUES (3, 2, 11, '疫情以来，中关村创业大街吸引35家创业企业注册', '2月10日复工截至3月17日，中关村创业大街集群注册平台累计收到注册申请41家，有35个项目通过评审。相比去年月均18个项目通过评审，数量更多，而且，通过对项目内容、核心团队履历、所属行业分析，质量也高于以往。', '<p>2月10日复工截至3月17日，中关村创业大街集群注册平台累计收到注册申请41家，有35个项目通过评审。相比去年月均18个项目通过评审，数量更多，而且，通过对项目内容、核心团队履历、所属行业分析，质量也高于以往。</p><p style=\"text-align: center;\"><img src=\"https://inews.gtimg.com/newsapp_bt/0/11464404908/1000\" style=\"max-width:100%;\"><br></p><div></div><p>“我们通常通过三个维度来评价一个创业项目的质量：所属行业领域、创始团队履历、核心技术及商业模式。”3月17日上午，中关村创业大街总经理聂丽霞向记者介绍。</p><p>疫情以来，中关村创业大街集群注册平台有35个项目通过评审，有24个技术已经成熟，产品已经开发完成，有部分项目还开展了市场合作。其余9家产品或技术还在研发阶段。相比以往，技术或产品成熟的申请项目数量倍增。</p><p>从项目创始人履历来看，35个项目的主要创始人当中，有57.1%是硕士及以上学历，还有一位是博士后创业；有40%有百度、IBM、中海油、微软、华为等大企业工作经历。平均年龄37.4岁。</p><p>从创业项目所属行业来看，主要集中在大数据、工业互联网、区块链技术、人工智能、软件信息化服务、新能源等新兴科技领域。涉及传统行业的，大多也是把新技术应用在细分领域里深耕。比如，有一个创业项目专门是做企业微信应用升级和周边应用程序开发的，市场前景非常广阔。</p><p>据介绍，去年5月13日，中关村创业大街集群注册平台正式授牌，开始为创业者免费提供企业注册服务，只需要一个注册地址、不需要实际在此办公，集群注册政策非常适合初创企业。创业大街还为集群注册企业提供政策咨询、产业对接和投融资等加速服务，满足初创企业的发展需求。</p><p>2019年，平台累计接受申请270个，注册成功137个。平均月成功注册约18家。</p><p>新冠肺炎疫情期间，创业者的热情为什么没受影响，反倒格外高涨呢？</p><p>“疫情期间，宅在家里不能外出，让我们更能潜下心来了好好思考自己的创业项目，修炼内功。而且，这期间，政府的支持政策更多、更到位，对创业者来说，创业成本更低。”北京彩云长天科技有限公司创始人何杰说。</p><p>何杰2019年6月从原公司辞职，创业伙伴7月也离开了原公司，他们的项目专注于AI数据处理。2月15日前后，何杰在家登录中关村创业大街“创业会客厅”线上平台，按要求填写提交了相关材料，申请加入集群注册平台。3月6日，他们就拿到了营业执照，迈出了公司化运营的第一步。</p>', '2020-03-18 09:19:55', '2020-04-13 21:49:02', 'http://localhost:3001/images/common/6d6da420-68b6-11ea-94f5-2514290e3ea7.jpeg');
INSERT INTO `article` VALUES (8, 2, 4, '《寄生虫》背后的韩国寄生史', '看完《寄生虫》，和朋友们聊了聊，大家一致认同这部电影隐喻气息浓烈，达成共识后就丢下了它，没想到这几天翻了翻影评，发现很多人都认为这是在讲述阶级的隐喻，又和朋友们聊了聊，才发现我们一开始就有一点不同的看法。', '<p>开篇我先<strong>吐槽</strong>一下微信开发者的文档，<strong>千年不更新</strong>。</p><p><em>写文时间：2020年3月14日</em>，先敲个时间，别那边偷偷改了有人吐槽我。</p><p>文档中写的<strong>拒绝</strong>和<strong>允许</strong>都会触发回调，然后我测试<strong>拒绝的时候就不会触发回调</strong>。</p><h2 id=\"item-1\">微信授权逻辑</h2><p><img referrerpolicy=\"no-referrer\" src=\"https://segmentfault.com/img/bVbExhl\" alt=\"image.png\" title=\"image.png\"></p><ol><li>进入页面，获取授权状态，（getUserid）一般是看cookie里面有用户信息吗。</li><li>有用户信息，pass。</li><li><p>无用户信息。这里只是打个标记，并不在一进入页面就强制授权。而是在用户操作的时候提示用户授权，因为这样体验比较好。<br>体验上是可以告诉用户你浏览我们是不需要你的信息的，而你在我们平台互动是需要注册登录的。</p><ol><li>用户拒绝授权，这里页面是无感知的，所以不做任何处理。但是页面可以知道用户是非首次互动，这时候可以先弹出一个框告知用户，用户需要允许授权。</li><li>用户允许授权，这个时候会触发刷新页面。这里建议页面给自己加个标记，就是用户触发授权的事件，刷新之后重新调用一下。</li></ol></li></ol><h3 id=\"item-1-1\">需求一:&nbsp;<strong>拒绝授权的时候弹窗</strong></h3><p><em>嘿嘿你猜我在做的是什么</em>。</p><p>我看之前代码是有拒绝回调逻辑的，而且我也在文档中确认过了。<br>但是我在测试的时候发现，拒绝不会触发回调，成功的时候逻辑是对的。</p><p>那么在这个场景下，我们怎么显示呢？</p><ol><li>我们做一个小页面藏在授权弹框后面，因为拒绝的时候页面无变化，用户就可以看到后面的小页面。</li><li>基于方案1我们发现，网慢的情况下，同意授权的用户也会看到弹窗，这对于我们要求体验的前端er来说是不好的。我们这里可以尝试<strong>给一个稍微大一点的setTimeout显示小页面</strong>。</li><li>基于方案2，因为微信授权弹窗不会阻塞主进程，所以我们并不能稳定控制小页面的显示与隐藏。极端情况下用户的体验仍是不好的。那么我们应该怎么办呢？<strong>捶产品，砍需求</strong>，哈哈当然是不做这个弹框，把这部分的功能<strong>换另一种交互方式咯</strong>。</li></ol><h3 id=\"item-1-2\">需求二: 非微信绑定的域名做微信授权</h3><p>因为现在微信管得太严了，怕被微信拉黑，所以考虑使用其他域名做分享外链。</p><p>但是我们又希望可以<strong>在微信授权登录一下</strong>，这样这个需求就来了。</p><p>微信中绑定的安全域名和回调域名为&nbsp;<code>a.com</code>，<br>我们分享到微信打开的域名为&nbsp;<code>b.com</code>。</p><h4>方案一：跨域方案</h4><p>首先我们要明确几个要点。</p><ol><li><strong>我方服务端判断登录是判断&nbsp;<code>cookie</code>&nbsp;</strong>。</li><li>对于前端来讲&nbsp;<code>a.com</code>&nbsp;和&nbsp;<code>b.com</code>&nbsp;是<strong>跨域</strong>的。</li><li><code>a.com</code>&nbsp;是无法把&nbsp;<code>cookie</code>&nbsp;写到&nbsp;<code>b.com</code>&nbsp;下的。</li><li>同样&nbsp;<code>b.com</code>&nbsp;也无法读取&nbsp;<code>a.com</code>&nbsp;的&nbsp;<code>cookie</code>。</li></ol><p>好了基于上面的要点。我们开始实现功能。</p><ol><li><code>a.com/wxauth</code>&nbsp;会触发微信授权，我们默认用户同意授权</li><li>微信会将页面重定向到 callback 页面。（这里是在公众号配置好的）</li><li>callback 页面写&nbsp;<code>cookie</code>。这个时候我们就能拿到用户登录信息。</li><li>但是基于上面我们跨域的cookie是无法共享的。那么我们可以开<code>CORS</code>来使用，<code>a.com</code>&nbsp;的接口允许&nbsp;<code>b.com</code>的页面发出请求。</li><li>但是跨域的情况下默认是不携带&nbsp;<code>cookie</code>&nbsp;的。这个时候我们可以配置&nbsp;<code>withCredentials</code>&nbsp;来达到携带cookie的目的。</li></ol><p>基于上面的跨域方案，我们&nbsp;<code>b.com</code>&nbsp;下面没有任何&nbsp;<code>cookie</code>，只有页面。<br>我们所有的请求和&nbsp;<code>cookie</code>&nbsp;都放在&nbsp;<code>a.com</code>。</p><h4>方案二：共享，我觉得叫授权验证也可以</h4><p>上个方案是所有请求都走&nbsp;<code>a.com</code>。</p><p>这个方案是所有请求都走当前域名。我网上看了几个别人做好的，也都是这种方案。</p><p>这种方案其实可以把&nbsp;<code>a.com</code>&nbsp;理解成第三方平台。</p><p><img referrerpolicy=\"no-referrer\" src=\"https://segmentfault.com/img/bVbExwp\" alt=\"image.png\" title=\"image.png\"></p>', '2020-03-18 09:44:26', '2020-03-18 22:35:12', 'http://localhost:3001/images/common/9bde6050-6925-11ea-a704-ab781b5ae732.jpeg');
INSERT INTO `article` VALUES (10, 2, 4, '《只有芸知道》：哭湿纸巾的爱情 原来没那么简单', '新西兰Clyde小镇见证了隋东风和罗芸最重要的十五年。', '<p>开篇我先<strong>吐槽</strong>一下微信开发者的文档，<strong>千年不更新</strong>。</p><p><em>写文时间：2020年3月14日</em>，先敲个时间，别那边偷偷改了有人吐槽我。</p><p>文档中写的<strong>拒绝</strong>和<strong>允许</strong>都会触发回调，然后我测试<strong>拒绝的时候就不会触发回调</strong>。</p><h2 id=\"item-1\">微信授权逻辑</h2><p><img referrerpolicy=\"no-referrer\" src=\"https://segmentfault.com/img/bVbExhl\" alt=\"image.png\" title=\"image.png\"></p><ol><li>进入页面，获取授权状态，（getUserid）一般是看cookie里面有用户信息吗。</li><li>有用户信息，pass。</li><li><p>无用户信息。这里只是打个标记，并不在一进入页面就强制授权。而是在用户操作的时候提示用户授权，因为这样体验比较好。<br>体验上是可以告诉用户你浏览我们是不需要你的信息的，而你在我们平台互动是需要注册登录的。</p><ol><li>用户拒绝授权，这里页面是无感知的，所以不做任何处理。但是页面可以知道用户是非首次互动，这时候可以先弹出一个框告知用户，用户需要允许授权。</li><li>用户允许授权，这个时候会触发刷新页面。这里建议页面给自己加个标记，就是用户触发授权的事件，刷新之后重新调用一下。</li></ol></li></ol><h3 id=\"item-1-1\">需求一:&nbsp;<strong>拒绝授权的时候弹窗</strong></h3><p><em>嘿嘿你猜我在做的是什么</em>。</p><p>我看之前代码是有拒绝回调逻辑的，而且我也在文档中确认过了。<br>但是我在测试的时候发现，拒绝不会触发回调，成功的时候逻辑是对的。</p><p>那么在这个场景下，我们怎么显示呢？</p><ol><li>我们做一个小页面藏在授权弹框后面，因为拒绝的时候页面无变化，用户就可以看到后面的小页面。</li><li>基于方案1我们发现，网慢的情况下，同意授权的用户也会看到弹窗，这对于我们要求体验的前端er来说是不好的。我们这里可以尝试<strong>给一个稍微大一点的setTimeout显示小页面</strong>。</li><li>基于方案2，因为微信授权弹窗不会阻塞主进程，所以我们并不能稳定控制小页面的显示与隐藏。极端情况下用户的体验仍是不好的。那么我们应该怎么办呢？<strong>捶产品，砍需求</strong>，哈哈当然是不做这个弹框，把这部分的功能<strong>换另一种交互方式咯</strong>。</li></ol><h3 id=\"item-1-2\">需求二: 非微信绑定的域名做微信授权</h3><p>因为现在微信管得太严了，怕被微信拉黑，所以考虑使用其他域名做分享外链。</p><p>但是我们又希望可以<strong>在微信授权登录一下</strong>，这样这个需求就来了。</p><p>微信中绑定的安全域名和回调域名为&nbsp;<code>a.com</code>，<br>我们分享到微信打开的域名为&nbsp;<code>b.com</code>。</p><h4>方案一：跨域方案</h4><p>首先我们要明确几个要点。</p><ol><li><strong>我方服务端判断登录是判断&nbsp;<code>cookie</code>&nbsp;</strong>。</li><li>对于前端来讲&nbsp;<code>a.com</code>&nbsp;和&nbsp;<code>b.com</code>&nbsp;是<strong>跨域</strong>的。</li><li><code>a.com</code>&nbsp;是无法把&nbsp;<code>cookie</code>&nbsp;写到&nbsp;<code>b.com</code>&nbsp;下的。</li><li>同样&nbsp;<code>b.com</code>&nbsp;也无法读取&nbsp;<code>a.com</code>&nbsp;的&nbsp;<code>cookie</code>。</li></ol><p>好了基于上面的要点。我们开始实现功能。</p><ol><li><code>a.com/wxauth</code>&nbsp;会触发微信授权，我们默认用户同意授权</li><li>微信会将页面重定向到 callback 页面。（这里是在公众号配置好的）</li><li>callback 页面写&nbsp;<code>cookie</code>。这个时候我们就能拿到用户登录信息。</li><li>但是基于上面我们跨域的cookie是无法共享的。那么我们可以开<code>CORS</code>来使用，<code>a.com</code>&nbsp;的接口允许&nbsp;<code>b.com</code>的页面发出请求。</li><li>但是跨域的情况下默认是不携带&nbsp;<code>cookie</code>&nbsp;的。这个时候我们可以配置&nbsp;<code>withCredentials</code>&nbsp;来达到携带cookie的目的。</li></ol><p>基于上面的跨域方案，我们&nbsp;<code>b.com</code>&nbsp;下面没有任何&nbsp;<code>cookie</code>，只有页面。<br>我们所有的请求和&nbsp;<code>cookie</code>&nbsp;都放在&nbsp;<code>a.com</code>。</p><h4>方案二：共享，我觉得叫授权验证也可以</h4><p>上个方案是所有请求都走&nbsp;<code>a.com</code>。</p><p>这个方案是所有请求都走当前域名。我网上看了几个别人做好的，也都是这种方案。</p><p>这种方案其实可以把&nbsp;<code>a.com</code>&nbsp;理解成第三方平台。</p><p><img referrerpolicy=\"no-referrer\" src=\"https://segmentfault.com/img/bVbExwp\" alt=\"image.png\" title=\"image.png\"></p>', '2020-03-18 09:54:23', '2020-03-18 22:28:52', 'http://localhost:3001/images/common/c9273330-6924-11ea-a704-ab781b5ae732.jpeg');
INSERT INTO `article` VALUES (12, 1, 5, '超大的字号、艳俗的色彩，他的设计风格怎么这么秀', '头顶板寸，脑后长辫，他身着大开三扣的花衬衫，脖子上的刺青会随着走路的摆动而忽隐忽现，我不说他是设计师的话，大家肯定会误以为是那条道上混的兄弟。这位张扬又粗犷的男子以他独特的「台味美学」混迹设计圈，他就是廖小子（本名廖俊裕），下面我们就一起来认识认识这个，痞气十足的设计师吧。', '<p>	 	 	 	 	 	 	    	  	 	 	 <!--[if lte IE 9]>\r\n	\r\n	<![endif]-->	 <!--[if lt IE 9]>\r\n  \r\n    window.onload=function(){\r\n    location.href=\"https://www.uisdc.com/ie8/?re=https%3A%2F%2Fwww.uisdc.com%2Fliaojunyu\";\r\n    }\r\n  </script>\r\n	<![endif]-->			 \r\n\r\n\r\n<script>\r\n		var _hmt = _hmt || [];\r\n		(function() {\r\n			var hm = document.createElement(\"script\");\r\n			hm.src = \"//hm.baidu.com/hm.js?7aeefdb15fe9aede961eee611c7e48a5\";\r\n			var s = document.getElementsByTagName(\"script\")[0];\r\n			s.parentNode.insertBefore(hm, s);\r\n		})();\r\n	</script>\r\n	 \r\n<script>\r\n		window.ga_tid = \"UA-154264393-2\";\r\n		window.ga_api = \"https://uiiiuiiicom.disquscdn.workers.dev/\";\r\n	</script>\r\n	 \r\n\r\n	 </p><div><div><div><div><p>头顶板寸，脑后长辫，他身着大开三扣的花衬衫，脖子上的刺青会随着走路的摆动而忽隐忽现，我不说他是设计师的话，大家肯定会误以为是那条道上混的兄弟。这位张扬又粗犷的男子以他独特的「台味美学」混迹设计圈，他就是廖小子（本名廖俊裕），下面我们就一起来认识认识这个，痞气十足的设计师吧。</p><p><img width=\"400\" height=\"577\" alt=\"\" src=\"https://image.uisdc.com/wp-content/uploads/2020/03/uisdc-yx-20200316-47.jpeg\"></p><h4><span id=\"menu_0\">设计师简介</span></h4><p>在台湾嘉义长大的廖俊裕，他的父亲是当地建筑工地的一个小型工程承包商，所以家中常有工人走动，那时廖俊裕的父亲对他说，要称这些人为「师傅」。打小起养成对手艺人的敬意，这让廖俊裕对劳动阶级多了一份深厚情感，这份难以割舍的感情，也成为他从台湾草根文化汲取创作养份的源头。</p><p><img width=\"600\" height=\"337\" alt=\"\" src=\"https://image.uisdc.com/wp-content/uploads/2020/03/uisdc-yx-20200316-2.jpeg\"></p><p>廖俊裕深受父亲的影响。现在袒露胸膛只扣一半花衬衫的打扮，也是耳濡目染了父亲的习惯。</p><p><img width=\"246\" height=\"303\" alt=\"\" src=\"https://image.uisdc.com/wp-content/uploads/2020/03/uisdc-yx-20200316-1.jpeg\"></p><p>从小他喜欢看功夫电影「好小子」，因此父亲开始叫他「小子」。就这样叫着叫着「廖俊裕」变成了「廖小子」。</p><p><img width=\"600\" height=\"242\" alt=\"\" src=\"https://image.uisdc.com/wp-content/uploads/2020/03/uisdc-yx-20200316-48.jpg\"></p><p>高三时的一个领悟，使得廖小子背弃了父亲对他成为一名律师的期望。这可不得了，因为他们家族里有从事法律的亲戚，廖小子成绩也不错，做父亲的当然希望儿子能跟着去走法律的康庄大道。</p><p>然而廖小子执意要选美术系，因为这件事父子俩吵得非常凶，还在家里大打出手。两人拿着大型立式电扇互砸，最后「黑带三段」的儿子打赢了老子。无奈劝说没有，渐渐的廖小子的父亲就默许了这件事情。</p><p><img width=\"600\" height=\"450\" alt=\"\" src=\"https://image.uisdc.com/wp-content/uploads/2020/03/uisdc-yx-20200316-3.jpeg\"></p><p>有一次，廖小子的父亲喝醉了说：自己曾经也热爱绘画，但是没能坚持自己的理想，被你的祖父给劝退了，如果你真要转念美术系的话就要学好，要有决心在这条路上闯出一片天，也圆父亲的一个梦。自此廖小子就开始了他的设计之路。</p><p><img width=\"700\" height=\"466\" alt=\"\" src=\"https://image.uisdc.com/wp-content/uploads/2020/03/uisdc-yx-20200316-4.jpeg\"></p><p>高中毕业后，廖小子顺利的考上了高雄师范大学美术系，但因家庭条件不好，连买画材的钱都没有，为了自力更生廖小子大学时就开始接活。跟大部分新手设计师一样，一开始接的都是些街头小广告，DM 单之类的设计项目。那时的廖小子也喜欢日系、大气简单的设计，但是能发出这种委托的客户，想要什么东西大家心里都有数。</p><p>完成项目后，客户一直要求改稿，希望字可以再放得大一些、颜色要鲜艳的、图要修得很沙龙、再整个玫瑰顺带一个外框与阴影。</p></div></div></div></div>', '2020-03-18 22:49:38', '2020-03-21 13:41:23', 'http://localhost:3001/images/common/78adf990-6927-11ea-a704-ab781b5ae732.jpeg');

-- ----------------------------
-- Table structure for article_tag
-- ----------------------------
DROP TABLE IF EXISTS `article_tag`;
CREATE TABLE `article_tag`  (
  `id` int(0) UNSIGNED NOT NULL AUTO_INCREMENT,
  `article_id` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '博客ID',
  `tag_id` int(0) UNSIGNED NOT NULL DEFAULT 0 COMMENT '标签ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 8 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '博客to标签中间表' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of article_tag
-- ----------------------------
INSERT INTO `article_tag` VALUES (7, 1, 2);
INSERT INTO `article_tag` VALUES (8, 1, 3);
INSERT INTO `article_tag` VALUES (9, 3, 6);

-- ----------------------------
-- Table structure for category
-- ----------------------------
DROP TABLE IF EXISTS `category`;
CREATE TABLE `category`  (
  `id` int(0) NOT NULL AUTO_INCREMENT COMMENT '分类id',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '分类名称',
  `parent_id` int(0) NOT NULL COMMENT '父级id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 16 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

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

-- ----------------------------
-- Table structure for menu
-- ----------------------------
DROP TABLE IF EXISTS `menu`;
CREATE TABLE `menu`  (
  `id` int(0) NOT NULL AUTO_INCREMENT COMMENT '菜单id',
  `name` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '菜单名称',
  `pId` int(0) NULL DEFAULT NULL COMMENT '父级id',
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
  `id` int(0) NOT NULL AUTO_INCREMENT COMMENT '角色id',
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
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `role_id` int(0) NULL DEFAULT NULL COMMENT '角色id',
  `menu_id` int(0) NULL DEFAULT NULL COMMENT '权限id',
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
  `id` int(0) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(10) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8 COLLATE = utf8_general_ci COMMENT = '账户' ROW_FORMAT = Compact;

-- ----------------------------
-- Records of tag
-- ----------------------------
INSERT INTO `tag` VALUES (1, 'Web前端');
INSERT INTO `tag` VALUES (2, '后台编程');
INSERT INTO `tag` VALUES (3, '数据库');
INSERT INTO `tag` VALUES (4, 'Javascript');
INSERT INTO `tag` VALUES (5, 'CSS3');
INSERT INTO `tag` VALUES (6, '网页设计');

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` int(0) NOT NULL AUTO_INCREMENT,
  `username` varchar(80) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(30) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '密码',
  `nickname` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '姓名',
  `sex` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL DEFAULT '男' COMMENT '性别',
  `tel` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '手机号码',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8 COLLATE = utf8_general_ci ROW_FORMAT = Compact;

-- ----------------------------
-- Records of user
-- ----------------------------
INSERT INTO `user` VALUES (1, 'moz', '1', '张艺兴', '男', '15863008280');

SET FOREIGN_KEY_CHECKS = 1;
