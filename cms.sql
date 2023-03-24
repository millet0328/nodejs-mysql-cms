/*
 Navicat Premium Data Transfer

 Source Server         : mysql
 Source Server Type    : MySQL
 Source Server Version : 80032 (8.0.32)
 Source Host           : localhost:3306
 Source Schema         : cms

 Target Server Type    : MySQL
 Target Server Version : 80032 (8.0.32)
 File Encoding         : 65001

 Date: 24/03/2023 15:05:23
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for cms_article
-- ----------------------------
DROP TABLE IF EXISTS `cms_article`;
CREATE TABLE `cms_article`  (
  `article_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `cate_1st` int NOT NULL COMMENT '一级分类id',
  `cate_2nd` int NOT NULL COMMENT '二级分类id',
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '标题',
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '摘要',
  `content` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '正文',
  `create_date` datetime NOT NULL COMMENT '发表日期',
  `update_date` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新日期',
  `main_photo` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '主图',
  `audit_status` tinyint NOT NULL DEFAULT 1 COMMENT '审核状态（1-审核中，2-通过，-1-未通过）',
  `audit_comments` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '审核意见',
  PRIMARY KEY (`article_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '文章表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_article
-- ----------------------------
INSERT INTO `cms_article` VALUES (1, 2, 11, '俄罗斯总统发言人：俄军遭受了重大损失', '据英国天空新闻网报道，俄罗斯总统普京的发言人佩斯科夫周四在接受这家英国媒体的采访时表示，俄罗斯军队遭到了“重大损失”。在回答天空新闻网直播关于俄军损失了多少士兵的问题时，佩斯科夫用英文回答说：“我们在士兵方面遭受了重大损失，这对我们来说是一个巨大的悲剧”。（原话为：\"We have significant losses of troops. It\'s a huge tragedy for us.\"）', '<p>开篇我先<strong>吐槽</strong>一下微信开发者的文档，<strong>千年不更新</strong>。</p><p><em>写文时间：2020年3月14日</em>，先敲个时间，别那边偷偷改了有人吐槽我。</p><p>文档中写的<strong>拒绝</strong>和<strong>允许</strong>都会触发回调，然后我测试<strong>拒绝的时候就不会触发回调</strong>。</p><h2>微信授权逻辑</h2><p><img src=\"https://segmentfault.com/img/bVbExhl\" alt=\"image.png\" data-href=\"\" style=\"\"/></p><ol><li>进入页面，获取授权状态，（getUserid）一般是看cookie里面有用户信息吗。</li><li>有用户信息，pass。</li><li>无用户信息。这里只是打个标记，并不在一进入页面就强制授权。而是在用户操作的时候提示用户授权，因为这样体验比较好。体验上是可以告诉用户你浏览我们是不需要你的信息的，而你在我们平台互动是需要注册登录的。用户拒绝授权，这里页面是无感知的，所以不做任何处理。但是页面可以知道用户是非首次互动，这时候可以先弹出一个框告知用户，用户需要允许授权。用户允许授权，这个时候会触发刷新页面。这里建议页面给自己加个标记，就是用户触发授权的事件，刷新之后重新调用一下。</li></ol><h3>需求一: <strong>拒绝授权的时候弹窗</strong></h3><p><em>嘿嘿你猜我在做的是什么</em>。</p><p>我看之前代码是有拒绝回调逻辑的，而且我也在文档中确认过了。<br>但是我在测试的时候发现，拒绝不会触发回调，成功的时候逻辑是对的。</p><p>那么在这个场景下，我们怎么显示呢？</p><ol><li>我们做一个小页面藏在授权弹框后面，因为拒绝的时候页面无变化，用户就可以看到后面的小页面。</li><li>基于方案1我们发现，网慢的情况下，同意授权的用户也会看到弹窗，这对于我们要求体验的前端er来说是不好的。我们这里可以尝试<strong>给一个稍微大一点的setTimeout显示小页面</strong>。</li><li>基于方案2，因为微信授权弹窗不会阻塞主进程，所以我们并不能稳定控制小页面的显示与隐藏。极端情况下用户的体验仍是不好的。那么我们应该怎么办呢？<strong>捶产品，砍需求</strong>，哈哈当然是不做这个弹框，把这部分的功能<strong>换另一种交互方式咯</strong>。</li></ol><h3>需求二: 非微信绑定的域名做微信授权</h3><p>因为现在微信管得太严了，怕被微信拉黑，所以考虑使用其他域名做分享外链。</p><p>但是我们又希望可以<strong>在微信授权登录一下</strong>，这样这个需求就来了。</p><p>微信中绑定的安全域名和回调域名为 <code>a.com</code>，<br>我们分享到微信打开的域名为 <code>b.com</code>。</p><h4>方案一：跨域方案</h4><p>首先我们要明确几个要点。</p><ol><li><code><strong>我方服务端判断登录是判断 cookie </strong></code>。</li><li>对于前端来讲 <code>a.com</code> 和 <code>b.com</code> 是<strong>跨域</strong>的。</li><li><code>a.com</code> 是无法把 <code>cookie</code> 写到 <code>b.com</code> 下的。</li><li>同样 <code>b.com</code> 也无法读取 <code>a.com</code> 的 <code>cookie</code>。</li></ol><p>好了基于上面的要点。我们开始实现功能。</p><ol><li><code>a.com/wxauth</code> 会触发微信授权，我们默认用户同意授权</li><li>微信会将页面重定向到 callback 页面。（这里是在公众号配置好的）</li><li>callback 页面写 <code>cookie</code>。这个时候我们就能拿到用户登录信息。</li><li>但是基于上面我们跨域的cookie是无法共享的。那么我们可以开<code>CORS</code>来使用，<code>a.com</code> 的接口允许 <code>b.com</code>的页面发出请求。</li><li>但是跨域的情况下默认是不携带 <code>cookie</code> 的。这个时候我们可以配置 <code>withCredentials</code> 来达到携带cookie的目的。</li></ol><p>基于上面的跨域方案，我们 <code>b.com</code> 下面没有任何 <code>cookie</code>，只有页面。<br>我们所有的请求和 <code>cookie</code> 都放在 <code>a.com</code>。</p><h4>方案二：共享，我觉得叫授权验证也可以</h4><p>上个方案是所有请求都走 <code>a.com</code>。</p><p>这个方案是所有请求都走当前域名。我网上看了几个别人做好的，也都是这种方案。</p><p>这种方案其实可以把 <code>a.com</code> 理解成第三方平台。</p><p><img src=\"https://segmentfault.com/img/bVbExwp\" alt=\"image.png\" data-href=\"\" style=\"\"/></p>', '2022-10-01 22:47:52', '2022-10-01 22:49:14', 'http://localhost:3001/images/common/78adf990-6927-11ea-a704-ab781b5ae732.jpeg', -1, NULL);
INSERT INTO `cms_article` VALUES (2, 2, 11, '亚马逊2019第一季度财报：净利润同比增长118% AWS业务增速迅猛', '根据这份财报显示，亚马逊销售额增速不错。第一季度总净销售额为597亿美元，高于市场预期596.53亿美元，对比去年同期为510.42亿美元同比增长17%。', '<p>美股研究社最新消息 亚马逊在周四盘后发布2019财年第一季度的财报。</p><p>根据这份财报显示，亚马逊销售额增速不错。第一季度总净销售额为597亿美元，高于市场预期596.53亿美元，对比去年同期为510.42亿美元同比增长17%。</p><p>本季度亚马逊各条业务增长都不错，其中北美地区净销售额为358.12亿美元，去年同期为307.25亿美元；线上商店销售额为294.98亿美元，去年同期为269.39亿美元；国际净销售额为161.92亿美元，去年同期为148.75亿美元。</p><p><br></p><p>净利润方面，亚马逊第一季度净利润为35.61亿美元，高于市场预期23.81亿美元，达到去年同期16.29亿美元的2倍以上，同比增长118%。</p><p>其中，季度广告服务以及其他销售额为27.16亿美元，去年同期为20.31亿美元；季度AWS运营利润增速迅猛达到22.23亿美元，去年同期为14亿美元，同比增长近59%。</p><p>第一季度EPS 7.09美元，市场预期4.67美元。</p><p>目前，亚马逊预计第二季度总销售额为595-635亿美元，预计第二季度运营利润为26-36亿美元。受财报利好消息影响，目前亚马逊盘后涨幅已经超过1%.</p>', '2022-10-01 22:47:53', '2023-02-23 01:53:49', 'http://localhost:3001/images/common/6f70b4a0-67f0-11e9-b7fb-3d2cafb359a4.jpeg', 1, NULL);
INSERT INTO `cms_article` VALUES (3, 2, 11, '疫情以来，中关村创业大街吸引35家创业企业注册', '2月10日复工截至3月17日，中关村创业大街集群注册平台累计收到注册申请41家，有35个项目通过评审。相比去年月均18个项目通过评审，数量更多，而且，通过对项目内容、核心团队履历、所属行业分析，质量也高于以往。', '<p>2月10日复工截至3月17日，中关村创业大街集群注册平台累计收到注册申请41家，有35个项目通过评审。相比去年月均18个项目通过评审，数量更多，而且，通过对项目内容、核心团队履历、所属行业分析，质量也高于以往。</p><p style=\"text-align: center;\"><img src=\"https://inews.gtimg.com/newsapp_bt/0/11464404908/1000\" style=\"max-width:100%;\"><br></p><div></div><p>“我们通常通过三个维度来评价一个创业项目的质量：所属行业领域、创始团队履历、核心技术及商业模式。”3月17日上午，中关村创业大街总经理聂丽霞向记者介绍。</p><p>疫情以来，中关村创业大街集群注册平台有35个项目通过评审，有24个技术已经成熟，产品已经开发完成，有部分项目还开展了市场合作。其余9家产品或技术还在研发阶段。相比以往，技术或产品成熟的申请项目数量倍增。</p><p>从项目创始人履历来看，35个项目的主要创始人当中，有57.1%是硕士及以上学历，还有一位是博士后创业；有40%有百度、IBM、中海油、微软、华为等大企业工作经历。平均年龄37.4岁。</p><p>从创业项目所属行业来看，主要集中在大数据、工业互联网、区块链技术、人工智能、软件信息化服务、新能源等新兴科技领域。涉及传统行业的，大多也是把新技术应用在细分领域里深耕。比如，有一个创业项目专门是做企业微信应用升级和周边应用程序开发的，市场前景非常广阔。</p><p>据介绍，去年5月13日，中关村创业大街集群注册平台正式授牌，开始为创业者免费提供企业注册服务，只需要一个注册地址、不需要实际在此办公，集群注册政策非常适合初创企业。创业大街还为集群注册企业提供政策咨询、产业对接和投融资等加速服务，满足初创企业的发展需求。</p><p>2019年，平台累计接受申请270个，注册成功137个。平均月成功注册约18家。</p><p>新冠肺炎疫情期间，创业者的热情为什么没受影响，反倒格外高涨呢？</p><p>“疫情期间，宅在家里不能外出，让我们更能潜下心来了好好思考自己的创业项目，修炼内功。而且，这期间，政府的支持政策更多、更到位，对创业者来说，创业成本更低。”北京彩云长天科技有限公司创始人何杰说。</p><p>何杰2019年6月从原公司辞职，创业伙伴7月也离开了原公司，他们的项目专注于AI数据处理。2月15日前后，何杰在家登录中关村创业大街“创业会客厅”线上平台，按要求填写提交了相关材料，申请加入集群注册平台。3月6日，他们就拿到了营业执照，迈出了公司化运营的第一步。</p>', '2022-10-01 22:47:53', '2022-10-01 22:48:58', 'http://localhost:3001/images/common/6d6da420-68b6-11ea-94f5-2514290e3ea7.jpeg', 2, NULL);
INSERT INTO `cms_article` VALUES (4, 2, 4, '《寄生虫》背后的韩国寄生史', '看完《寄生虫》，和朋友们聊了聊，大家一致认同这部电影隐喻气息浓烈，达成共识后就丢下了它，没想到这几天翻了翻影评，发现很多人都认为这是在讲述阶级的隐喻，又和朋友们聊了聊，才发现我们一开始就有一点不同的看法。', '<p>开篇我先<strong>吐槽</strong>一下微信开发者的文档，<strong>千年不更新</strong>。</p><p><em>写文时间：2020年3月14日</em>，先敲个时间，别那边偷偷改了有人吐槽我。</p><p>文档中写的<strong>拒绝</strong>和<strong>允许</strong>都会触发回调，然后我测试<strong>拒绝的时候就不会触发回调</strong>。</p><h2 id=\"item-1\">微信授权逻辑</h2><p><img referrerpolicy=\"no-referrer\" src=\"https://segmentfault.com/img/bVbExhl\" alt=\"image.png\" title=\"image.png\"></p><ol><li>进入页面，获取授权状态，（getUserid）一般是看cookie里面有用户信息吗。</li><li>有用户信息，pass。</li><li><p>无用户信息。这里只是打个标记，并不在一进入页面就强制授权。而是在用户操作的时候提示用户授权，因为这样体验比较好。<br>体验上是可以告诉用户你浏览我们是不需要你的信息的，而你在我们平台互动是需要注册登录的。</p><ol><li>用户拒绝授权，这里页面是无感知的，所以不做任何处理。但是页面可以知道用户是非首次互动，这时候可以先弹出一个框告知用户，用户需要允许授权。</li><li>用户允许授权，这个时候会触发刷新页面。这里建议页面给自己加个标记，就是用户触发授权的事件，刷新之后重新调用一下。</li></ol></li></ol><h3 id=\"item-1-1\">需求一:&nbsp;<strong>拒绝授权的时候弹窗</strong></h3><p><em>嘿嘿你猜我在做的是什么</em>。</p><p>我看之前代码是有拒绝回调逻辑的，而且我也在文档中确认过了。<br>但是我在测试的时候发现，拒绝不会触发回调，成功的时候逻辑是对的。</p><p>那么在这个场景下，我们怎么显示呢？</p><ol><li>我们做一个小页面藏在授权弹框后面，因为拒绝的时候页面无变化，用户就可以看到后面的小页面。</li><li>基于方案1我们发现，网慢的情况下，同意授权的用户也会看到弹窗，这对于我们要求体验的前端er来说是不好的。我们这里可以尝试<strong>给一个稍微大一点的setTimeout显示小页面</strong>。</li><li>基于方案2，因为微信授权弹窗不会阻塞主进程，所以我们并不能稳定控制小页面的显示与隐藏。极端情况下用户的体验仍是不好的。那么我们应该怎么办呢？<strong>捶产品，砍需求</strong>，哈哈当然是不做这个弹框，把这部分的功能<strong>换另一种交互方式咯</strong>。</li></ol><h3 id=\"item-1-2\">需求二: 非微信绑定的域名做微信授权</h3><p>因为现在微信管得太严了，怕被微信拉黑，所以考虑使用其他域名做分享外链。</p><p>但是我们又希望可以<strong>在微信授权登录一下</strong>，这样这个需求就来了。</p><p>微信中绑定的安全域名和回调域名为&nbsp;<code>a.com</code>，<br>我们分享到微信打开的域名为&nbsp;<code>b.com</code>。</p><h4>方案一：跨域方案</h4><p>首先我们要明确几个要点。</p><ol><li><strong>我方服务端判断登录是判断&nbsp;<code>cookie</code>&nbsp;</strong>。</li><li>对于前端来讲&nbsp;<code>a.com</code>&nbsp;和&nbsp;<code>b.com</code>&nbsp;是<strong>跨域</strong>的。</li><li><code>a.com</code>&nbsp;是无法把&nbsp;<code>cookie</code>&nbsp;写到&nbsp;<code>b.com</code>&nbsp;下的。</li><li>同样&nbsp;<code>b.com</code>&nbsp;也无法读取&nbsp;<code>a.com</code>&nbsp;的&nbsp;<code>cookie</code>。</li></ol><p>好了基于上面的要点。我们开始实现功能。</p><ol><li><code>a.com/wxauth</code>&nbsp;会触发微信授权，我们默认用户同意授权</li><li>微信会将页面重定向到 callback 页面。（这里是在公众号配置好的）</li><li>callback 页面写&nbsp;<code>cookie</code>。这个时候我们就能拿到用户登录信息。</li><li>但是基于上面我们跨域的cookie是无法共享的。那么我们可以开<code>CORS</code>来使用，<code>a.com</code>&nbsp;的接口允许&nbsp;<code>b.com</code>的页面发出请求。</li><li>但是跨域的情况下默认是不携带&nbsp;<code>cookie</code>&nbsp;的。这个时候我们可以配置&nbsp;<code>withCredentials</code>&nbsp;来达到携带cookie的目的。</li></ol><p>基于上面的跨域方案，我们&nbsp;<code>b.com</code>&nbsp;下面没有任何&nbsp;<code>cookie</code>，只有页面。<br>我们所有的请求和&nbsp;<code>cookie</code>&nbsp;都放在&nbsp;<code>a.com</code>。</p><h4>方案二：共享，我觉得叫授权验证也可以</h4><p>上个方案是所有请求都走&nbsp;<code>a.com</code>。</p><p>这个方案是所有请求都走当前域名。我网上看了几个别人做好的，也都是这种方案。</p><p>这种方案其实可以把&nbsp;<code>a.com</code>&nbsp;理解成第三方平台。</p><p><img referrerpolicy=\"no-referrer\" src=\"https://segmentfault.com/img/bVbExwp\" alt=\"image.png\" title=\"image.png\"></p>', '2022-10-01 22:47:54', '2022-10-01 22:47:54', 'http://localhost:3001/images/common/9bde6050-6925-11ea-a704-ab781b5ae732.jpeg', 1, NULL);
INSERT INTO `cms_article` VALUES (5, 2, 4, '《只有芸知道》：哭湿纸巾的爱情 原来没那么简单', '新西兰Clyde小镇见证了隋东风和罗芸最重要的十五年。', '<p>开篇我先<strong>吐槽</strong>一下微信开发者的文档，<strong>千年不更新</strong>。</p><p><em>写文时间：2020年3月14日</em>，先敲个时间，别那边偷偷改了有人吐槽我。</p><p>文档中写的<strong>拒绝</strong>和<strong>允许</strong>都会触发回调，然后我测试<strong>拒绝的时候就不会触发回调</strong>。</p><h2 id=\"item-1\">微信授权逻辑</h2><p><img referrerpolicy=\"no-referrer\" src=\"https://segmentfault.com/img/bVbExhl\" alt=\"image.png\" title=\"image.png\"></p><ol><li>进入页面，获取授权状态，（getUserid）一般是看cookie里面有用户信息吗。</li><li>有用户信息，pass。</li><li><p>无用户信息。这里只是打个标记，并不在一进入页面就强制授权。而是在用户操作的时候提示用户授权，因为这样体验比较好。<br>体验上是可以告诉用户你浏览我们是不需要你的信息的，而你在我们平台互动是需要注册登录的。</p><ol><li>用户拒绝授权，这里页面是无感知的，所以不做任何处理。但是页面可以知道用户是非首次互动，这时候可以先弹出一个框告知用户，用户需要允许授权。</li><li>用户允许授权，这个时候会触发刷新页面。这里建议页面给自己加个标记，就是用户触发授权的事件，刷新之后重新调用一下。</li></ol></li></ol><h3 id=\"item-1-1\">需求一:&nbsp;<strong>拒绝授权的时候弹窗</strong></h3><p><em>嘿嘿你猜我在做的是什么</em>。</p><p>我看之前代码是有拒绝回调逻辑的，而且我也在文档中确认过了。<br>但是我在测试的时候发现，拒绝不会触发回调，成功的时候逻辑是对的。</p><p>那么在这个场景下，我们怎么显示呢？</p><ol><li>我们做一个小页面藏在授权弹框后面，因为拒绝的时候页面无变化，用户就可以看到后面的小页面。</li><li>基于方案1我们发现，网慢的情况下，同意授权的用户也会看到弹窗，这对于我们要求体验的前端er来说是不好的。我们这里可以尝试<strong>给一个稍微大一点的setTimeout显示小页面</strong>。</li><li>基于方案2，因为微信授权弹窗不会阻塞主进程，所以我们并不能稳定控制小页面的显示与隐藏。极端情况下用户的体验仍是不好的。那么我们应该怎么办呢？<strong>捶产品，砍需求</strong>，哈哈当然是不做这个弹框，把这部分的功能<strong>换另一种交互方式咯</strong>。</li></ol><h3 id=\"item-1-2\">需求二: 非微信绑定的域名做微信授权</h3><p>因为现在微信管得太严了，怕被微信拉黑，所以考虑使用其他域名做分享外链。</p><p>但是我们又希望可以<strong>在微信授权登录一下</strong>，这样这个需求就来了。</p><p>微信中绑定的安全域名和回调域名为&nbsp;<code>a.com</code>，<br>我们分享到微信打开的域名为&nbsp;<code>b.com</code>。</p><h4>方案一：跨域方案</h4><p>首先我们要明确几个要点。</p><ol><li><strong>我方服务端判断登录是判断&nbsp;<code>cookie</code>&nbsp;</strong>。</li><li>对于前端来讲&nbsp;<code>a.com</code>&nbsp;和&nbsp;<code>b.com</code>&nbsp;是<strong>跨域</strong>的。</li><li><code>a.com</code>&nbsp;是无法把&nbsp;<code>cookie</code>&nbsp;写到&nbsp;<code>b.com</code>&nbsp;下的。</li><li>同样&nbsp;<code>b.com</code>&nbsp;也无法读取&nbsp;<code>a.com</code>&nbsp;的&nbsp;<code>cookie</code>。</li></ol><p>好了基于上面的要点。我们开始实现功能。</p><ol><li><code>a.com/wxauth</code>&nbsp;会触发微信授权，我们默认用户同意授权</li><li>微信会将页面重定向到 callback 页面。（这里是在公众号配置好的）</li><li>callback 页面写&nbsp;<code>cookie</code>。这个时候我们就能拿到用户登录信息。</li><li>但是基于上面我们跨域的cookie是无法共享的。那么我们可以开<code>CORS</code>来使用，<code>a.com</code>&nbsp;的接口允许&nbsp;<code>b.com</code>的页面发出请求。</li><li>但是跨域的情况下默认是不携带&nbsp;<code>cookie</code>&nbsp;的。这个时候我们可以配置&nbsp;<code>withCredentials</code>&nbsp;来达到携带cookie的目的。</li></ol><p>基于上面的跨域方案，我们&nbsp;<code>b.com</code>&nbsp;下面没有任何&nbsp;<code>cookie</code>，只有页面。<br>我们所有的请求和&nbsp;<code>cookie</code>&nbsp;都放在&nbsp;<code>a.com</code>。</p><h4>方案二：共享，我觉得叫授权验证也可以</h4><p>上个方案是所有请求都走&nbsp;<code>a.com</code>。</p><p>这个方案是所有请求都走当前域名。我网上看了几个别人做好的，也都是这种方案。</p><p>这种方案其实可以把&nbsp;<code>a.com</code>&nbsp;理解成第三方平台。</p><p><img referrerpolicy=\"no-referrer\" src=\"https://segmentfault.com/img/bVbExwp\" alt=\"image.png\" title=\"image.png\"></p>', '2022-10-01 22:47:55', '2022-10-01 22:47:55', 'http://localhost:3001/images/common/c9273330-6924-11ea-a704-ab781b5ae732.jpeg', 1, NULL);
INSERT INTO `cms_article` VALUES (6, 7, 8, '2023前端面试真题之JS篇', '在如今的互联网大环境下，每天都充斥着各种负能量。有可能，你上午还在工位摸鱼，下午HR已经给你单独开小灶，很煞有介事的通知你，提前毕业了。在这个浮躁的互联网环境下，总有一种我们永远不知道明天和意外哪个先到的感觉。', '<p><br></p><p><br></p><blockquote>世界上只有一种真正的英雄主义，那就是看清生活的真相之后，依然热爱生活。 -- 罗曼罗兰</blockquote><p>大家好，我是<strong>柒八九</strong>。</p><p>在如今的互联网大环境下，每天都充斥着各种<strong>负能量</strong>。有可能，你上午还在工位<strong>摸鱼</strong>，下午<code>HR</code>已经给你<strong>单独开小灶</strong>，很煞有介事的通知你，<strong>提前毕业</strong>了。在这个浮躁的互联网环境下，总有一种<strong>我们永远不知道明天和意外哪个先到</strong>的感觉。</p><blockquote>《古兰经》中有一句很契合的话，山不过来，我就过去。</blockquote><p>既然，外部环境我们无法去改变，那就从我们内部改变。所以，我又重新总结了一套，<code>2023</code>年最新的面试集锦，以便大家一起度过寒冬，拥抱更好的未来。</p><blockquote>note: 其中有些知识点，在前面的文章中，有过涉猎，为了行文的方便和资料的完整性，我就又拿来主义了，免去大家去翻找。但是，前面的文章有更深的解读，如果想更深的学习，可以移步到对应文章中。 如果在行文中，有技术披露和考虑不周的地方，不吝赐教。</blockquote><h3>你能所学到的知识点</h3><blockquote>JS执行流程 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ 基本数据类型 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ ES6的新特性有哪些 推荐阅读指数⭐️⭐️⭐️ 箭头函数和普通函数的区别 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ Promise VS async/await 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ ES6迭代器 推荐阅读指数⭐️⭐️⭐️ 设计模式的分类 推荐阅读指数⭐️⭐️⭐️⭐️ WebGL和canvas的关系 推荐阅读指数⭐️⭐️ CommonJS和ES6 Module的区别 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ 声明变量的方式 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ Object/Map/WeakMap的区别 推荐阅读指数⭐️⭐️⭐️⭐️ JS 深浅复制 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ 闭包 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ Event Loop 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ 垃圾回收机制 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ 内存问题 推荐阅读指数⭐️⭐️⭐️ 作用域的产生 推荐阅读指数⭐️⭐️⭐️⭐️ this指向 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ 图片懒加载 推荐阅读指数⭐️⭐️⭐️⭐️⭐️ PromiseQueue 推荐阅读指数⭐️⭐️⭐️⭐️ 数组常用方法 推荐阅读指数⭐️⭐️⭐️⭐️</blockquote><p>好了，天不早了，干点正事哇。<br><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/c19267c0fa5042aab7f5b678dd7a6a10~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"\" data-href=\"\" style=\"\"/></p><h1>JS执行流程</h1><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/38f8e16b3a2a4b7fb8d19e079d0d1b4c~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"\" data-href=\"\" style=\"\"/></p>', '2022-10-01 22:48:01', '2023-02-23 13:15:26', 'http://localhost:3001/images/common/39e4d9ae-2374-4685-82d9-7778efbb3cee.png', 1, NULL);
INSERT INTO `cms_article` VALUES (7, 7, 8, '2023前端面试系列-- Vue 篇', '为了准备2023年春招，最近开始复习八股文。本文是我的前端面试系列的Vue篇，其他章节内容可点击链接查看：', '<h2>Vue 常见面试题总结</h2><h3>MVVM模型？</h3><p>MVVM，是<code>Model-View-ViewModel</code>的简写，其本质是<code>MVC</code>模型的升级版。其中 <code>Model</code> 代表数据模型，<code>View</code> 代表看到的页面，<code>ViewModel</code>是<code>View</code>和<code>Model</code>之间的桥梁，数据会绑定到<code>ViewModel</code>层并自动将数据渲染到页面中，视图变化的时候会通知<code>ViewModel</code>层更新数据。以前是通过操作<code>DOM</code>来更新视图，现在是<code>数据驱动视图</code>。</p><h3>Vue的生命周期</h3><p>Vue 的生命周期可以分为8个阶段：创建前后、挂载前后、更新前后、销毁前后，以及一些特殊场景的生命周期。Vue 3 中还新增了是3个用于调试和服务端渲染的场景。</p><table style=\"width: auto;\"><tbody><tr><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">Vue 2中的生命周期钩子</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">Vue 3选项式API的生命周期选项</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">Vue 3 组合API中生命周期钩子</th><th colSpan=\"1\" rowSpan=\"1\" width=\"auto\">描述</th></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>beforeCreate</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>beforeCreate</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>setup()</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">创建前，此时<code>data</code>和 <code>methods</code>的数据都还没有初始化</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>created</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>created</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>setup()</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">创建后，<code>data</code>中有值，尚未挂载，可以进行一些<code>Ajax</code>请求</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>beforeMount</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>beforeMount</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onBeforeMount</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">挂载前，会找到虚拟<code>DOM</code>，编译成<code>Render</code></td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>mounted</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>mounted</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onMounted</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">挂载后，<code>DOM</code>已创建，可用于获取访问数据和<code>DOM</code>元素</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>beforeUpdate</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>beforeUpdate</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onBeforeUpdate</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">更新前，可用于获取更新前各种状态</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>updated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>updated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onUpdated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">更新后，所有状态已是最新</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>beforeDestroy</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>beforeUnmount</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onBeforeUnmount</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">销毁前，可用于一些定时器或订阅的取消</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>destroyed</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>unmounted</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onUnmounted</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">销毁后，可用于一些定时器或订阅的取消</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>activated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>activated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onActivated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>keep-alive</code>缓存的组件激活时</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>deactivated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>deactivated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onDeactivated</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>keep-alive</code>缓存的组件停用时</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>errorCaptured</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>errorCaptured</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onErrorCaptured</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">捕获一个来自子孙组件的错误时调用</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">—</td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>renderTracked</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onRenderTracked</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">调试钩子，响应式依赖被收集时调用</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">—</td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>renderTriggered</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onRenderTriggered</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">调试钩子，响应式依赖被触发时调用</td></tr><tr><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">—</td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>serverPrefetch</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\"><code>onServerPrefetch</code></td><td colSpan=\"1\" rowSpan=\"1\" width=\"auto\">组件实例在服务器上被渲染前调用</td></tr></tbody></table><p><strong>关于Vue 3中的生命周期建议阅读官方文档!!!!</strong><br></p><p><a href=\"https://link.juejin.cn?target=https%3A%2F%2Fcn.vuejs.org%2Fapi%2Fcomposition-api-lifecycle.html\" target=\"_blank\">组合式 API：生命周期钩子--官方文档</a><br><a href=\"https://link.juejin.cn?target=https%3A%2F%2Fcn.vuejs.org%2Fapi%2Foptions-lifecycle.html\" target=\"_blank\">选项式 API：生命周期选项--官方文档</a></p><p><strong>父子组件的生命周期：</strong><br></p><ul><li><code>加载渲染阶段</code>：父 beforeCreate -&gt; 父 created -&gt; 父 beforeMount -&gt; 子 beforeCreate -&gt; 子 created -&gt; 子 beforeMount -&gt; 子 mounted -&gt; 父 mounted</li><li><code>更新阶段</code>：父 beforeUpdate -&gt; 子 beforeUpdate -&gt; 子 updated -&gt; 父 updated</li><li><code>销毁阶段</code>：父 beforeDestroy -&gt; 子 beforeDestroy -&gt; 子 destroyed -&gt; 父 destroyed</li></ul><h3>Vue.$nextTick</h3><p><strong>在下次 DOM 更新循环结束之后执行延迟回调。在修改数据之后立即使用这个方法，获取更新后的 DOM。</strong></p><p><code>nextTick</code> 是 Vue 提供的一个全局 API，由于 Vue 的异步更新策略，导致我们对数据修改后不会直接体现在 DOM 上，此时如果想要立即获取更新后的 DOM 状态，就需要借助该方法。</p><p>Vue 在更新 DOM 时是异步执行的。当数据发生变化，Vue 将开启一个异步更新队列，并缓冲在同一事件循环中发生的所有数据变更。如果同一个 <code>watcher</code> 被多次触发，只会被推入队列一次。这种在缓冲时去除重复数据对于避免不必要的计算和 DOM 操作是非常重要的。<code>nextTick</code>方法会在队列中加入一个回调函数，确保该函数在前面的 DOM 操作完成后才调用。</p><p>使用场景：</p><ol><li>如果想要在修改数据后立刻得到更新后的<code>DOM</code>结构，可以使用<code>Vue.nextTick()</code></li><li>在<code>created</code>生命周期中进行<code>DOM</code>操作</li></ol><h3>Vue 实例挂载过程中发生了什么？</h3><p>挂载过程指的是 <code>app.mount()</code>过程，这是一个初始化过程，整体上做了两件事情：<code>初始化</code>和<code>建立更新机制</code>。</p><p>初始化会创建组件实例、初始化组件状态、创建各种响应式数据。</p><p>建立更新机制这一步会立即执行一次组件的更新函数，这会首次执行组件渲染函数并执行<code>patch</code>将<code>vnode</code> 转换为 <code>dom</code>； 同时首次执行渲染函数会创建它内部响应式数据和组件更新函数之间的依赖关系，这使得以后数据发生变化时会执行对应的更新函数。</p><h3>Vue 的模版编译原理</h3><p>Vue 中有个独特的编译器模块，称为<code>compiler</code>，它的主要作用是将用户编写的<code>template</code>编译为js中可执行的<code>render</code>函数。<br><br>在Vue 中，编译器会先对<code>template</code>进行解析，这一步称为<code>parse</code>，结束之后得到一个JS对象，称之为<code>抽象语法树AST</code>；然后是对<code>AST</code>进行深加工的转换过程，这一步称为<code>transform</code>，最后将前面得到的<code>AST</code>生成JS代码，也就是<code>render</code>函数。</p><h3>Vue 的响应式原理</h3><ol><li>Vue 2 中的数据响应式会根据数据类型做不同的处理。如果是对象，则通过<code>Object.defineProperty(obj,key,descriptor)</code>拦截对象属性访问，当数据被访问或改变时，感知并作出反应；如果是数组，则通过覆盖数组原型的方法，扩展它的7个变更方法（push、pop、shift、unshift、splice、sort、reverse），使这些方法可以额外的做更新通知，从而做出响应。<br><br>缺点：<br></li><li>Vue 3 中利用<code>ES6</code>的<code>Proxy</code>机制代理需要响应化的数据。可以同时支持对象和数组，动态属性增、删都可以拦截，新增数据结构均支持，对象嵌套属性运行时递归，用到时才代理，也不需要维护特别多的依赖关系，性能取得很大进步。</li></ol><h3>虚拟DOM</h3><ol><li>概念： 虚拟DOM，顾名思义就是虚拟的DOM对象，它本身就是一个JS对象，只不过是通过不同的属性去描述一个视图结构。</li><li>虚拟DOM的好处： (1) 性能提升 直接操作DOM是有限制的，一个真实元素上有很多属性，如果直接对其进行操作，同时会对很多额外的属性内容进行了操作，这是没有必要的。如果将这些操作转移到JS对象上，就会简单很多。另外，操作DOM的代价是比较昂贵的，频繁的操作DOM容易引起页面的重绘和回流。如果通过抽象VNode进行中间处理，可以有效减少直接操作DOM次数，从而减少页面的重绘和回流。 (2) 方便跨平台实现 同一VNode节点可以渲染成不同平台上对应的内容，比如：渲染在浏览器是DOM元素节点，渲染在Native（iOS、Android）变为对应的控件。Vue 3 中允许开发者基于VNode实现自定义渲染器（renderer），以便于针对不同平台进行渲染。</li><li>结构： 没有统一的标准，一般包括tag、props、children三项。 tag：必选。就是标签，也可以是组件，或者函数。 props：非必选。就是这个标签上的属性和方法。 children：非必选。就是这个标签的内容或者子节点。如果是文本节点就是字符串；如果有子节点就是数组。换句话说，如果判断children是字符串的话，就表示一定是文本节点，这个节点肯定没有子元素。</li></ol><h3>diff 算法</h3><ol><li>概念：<br><code>diff</code>算法是一种对比算法，通过对比旧的虚拟DOM和新的虚拟DOM，得出是哪个虚拟节点发生了改变，找出这个虚拟节点并只更新这个虚拟节点所对应的真实节点，而不用更新其他未发生改变的节点，实现精准地更新真实DOM，进而提高效率。<br></li><li>对比方式：<br><code>diff</code>算法的整体策略是：<code>深度优先，同层比较</code>。比较只会在同层级进行, 不会跨层级比较；比较的过程中，循环从两边向中间收拢。</li></ol><ul><li>首先判断两个节点的<code>tag</code>是否相同，不同则删除该节点重新创建节点进行替换。</li><li><code>tag</code>相同时，先替换属性，然后对比子元素，分为以下几种情况：<br></li></ul><h3>Vue中key的作用？</h3><p><code>key</code>的作用主要是<code>为了更加高效的更新虚拟 DOM</code>。</p><p>Vue 判断两个节点是否相同时，主要是判断两者的<code>key</code>和<code>元素类型tag</code>。因此，如果不设置<code>key</code><br>，它的值就是 undefined，则可能永远认为这是两个相同的节点，只能去做更新操作，将造成大量的 DOM 更新操作。</p><h3>为什么组件中的 data 是一个函数？</h3><p>在 new Vue() 中，可以是函数也可以是对象，因为根实例只有一个，不会产生数据污染。</p><p>在组件中，data 必须为函数，目的是为了防止多个组件实例对象之间共用一个 data，产生数据污染；而采用函数的形式，initData 时会将其作为工厂函数都会返回全新的 data 对象。</p><h3>Vue 中组件间的通信方式？</h3><ol><li>父子组件通信： 父向子传递数据是通过props，子向父是通过$emit触发事件；通过父链/子链也可以通信（$parent/$children）；ref也可以访问组件实例；provide/inject；$attrs/$listeners。</li><li>兄弟组件通信： 全局事件总线EventBus、Vuex。</li><li>跨层级组件通信： 全局事件总线EventBus、Vuex、provide/inject。</li></ol><h3>v-show 和 v-if 的区别？</h3><ol><li>控制手段不同。<code>v-show</code>是通过给元素添加 css 属性<code>display: none</code>，但元素仍然存在；而<code>v-if</code>控制元素显示或隐藏是将元素整个添加或删除。</li><li>编译过程不同。<code>v-if</code>切换有一个局部编译/卸载的过程，切换过程中合适的销毁和重建内部的事件监听和子组件；<code>v-show</code>只是简单的基于 css 切换。</li><li>编译条件不同。<code>v-if</code>是真正的条件渲染，它会确保在切换过程中条件块内的事件监听器和子组件适当地被销毁和重建，渲染条件为假时，并不做操作，直到为真才渲染。</li><li>触发生命周期不同。<code>v-show</code>由 false 变为 true 的时候不会触发组件的生命周期；<code>v-if</code>由 false 变为 true 的时候，触发组件的<code>beforeCreate</code>、<code>created</code>、<code>beforeMount</code>、<code>mounted</code>钩子，由 true 变为 false 的时候触发组件的<code>beforeDestory</code>、<code>destoryed</code>钩子。</li><li>性能消耗不同。<code>v-if</code>有更高的切换消耗；<code>v-show</code>有更高的初始渲染消耗。</li></ol><p>使用场景：<br><br>如果需要非常频繁地切换，则使用<code>v-show</code>较好，如：手风琴菜单，tab 页签等；<br>如果在运行时条件很少改变，则使用<code>v-if</code>较好，如：用户登录之后，根据权限不同来显示不同的内容。</p><h3>computed 和 watch 的区别？</h3><ul><li><code>computed</code>计算属性，依赖其它属性计算值，内部任一依赖项的变化都会重新执行该函数，计算属性有缓存，多次重复使用计算属性时会从缓存中获取返回值，计算属性必须要有<code>return</code>关键词。</li><li><code>watch</code>侦听到某一数据的变化从而触发函数。当数据为对象类型时，对象中的属性值变化时需要使用深度侦听<code>deep</code>属性，也可在页面第一次加载时使用立即侦听<code>immdiate</code>属性。</li></ul><p>运用场景：<br><br>计算属性一般用在模板渲染中，某个值是依赖其它响应对象甚至是计算属性而来；而侦听属性适用于观测某个值的变化去完成一段复杂的业务逻辑。</p><h3>v-if 和 v-for 为什么不建议放在一起使用？</h3><p>Vue 2 中，<code>v-for</code>的优先级比<code>v-if</code>高，这意味着<code>v-if</code>将分别重复运行于每一个<code>v-for</code>循环中。如果要遍历的数组很大，而真正要展示的数据很少时，将造成很大的性能浪费。</p><p>Vue 3 中，则完全相反，<code>v-if</code>的优先级高于<code>v-for</code>，所以<code>v-if</code>执行时，它调用的变量还不存在，会导致异常。</p><p>通常有两种情况导致要这样做：</p><ul><li>为了过滤列表中的项目，比如：<code>v-for = \"user in users\" v-if = \"user.active\"</code>。这种情况，可以定义一个计算属性，让其返回过滤后的列表即可。</li><li>为了避免渲染本该被隐藏的列表，比如<code>v-for = \"user in users\" v-if = \"showUsersFlag\"</code>。这种情况，可以将<code>v-if</code>移至容器元素上或在外面包一层<code>template</code>即可。</li></ul><h3>Vue 2中的set方法？</h3><p><a href=\"https://link.juejin.cn?target=https%3A%2F%2Fv2.cn.vuejs.org%2Fv2%2Fapi%2F%23Vue-set\" target=\"_blank\"><code>set</code>是Vue 2中的一个全局API</a>。可手动添加响应式数据，解决数据变化视图未更新问题。当在项目中直接设置数组的某一项的值，或者直接设置对象的某个属性值，会发现页面并没有更新。这是因为<code>Object.defineProperty()</code>的限制，监听不到数据变化，可通过<code>this.$set(数组或对象，数组下标或对象的属性名，更新后的值)</code>解决。</p>', '2022-10-01 22:48:01', '2023-02-23 13:19:37', 'http://localhost:3001/images/common/21186986-267e-466d-89f0-679f892229c0.png', 1, NULL);
INSERT INTO `cms_article` VALUES (8, 1, 5, 'ChatGPT保姆级教程，一分钟学会使用ChatGPT！', '最近ChatGPT大火！微软退出首款ChatGPT搜索引擎，阿里等国内巨头也纷纷爆出自家产品，一夜之间，全球最大的科技公司仿佛都回到了自己年轻时的样子！', '<p><br><img src=\"https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0453f8de6e4c4da1903dfa65587de65c~tplv-k3u1fbpfcp-zoom-crop-mark:3024:3024:3024:1702.awebp?\" alt=\"ChatGPT保姆级教程，一分钟学会使用ChatGPT！\" data-href=\"\" style=\"width: 755.925px;\"/></p><p><br></p><p>最近ChatGPT大火！微软退出首款ChatGPT搜索引擎，阿里等国内巨头也纷纷爆出自家产品，一夜之间，全球最大的科技公司仿佛都回到了自己年轻时的样子！</p><p>然而，ChatGPT这么火，这么好玩的东西，国人都被卡在注册上了？！</p><p>今天老鱼给大家汇总了国内能使用ChatGPT的方法，解锁更多ChatGPT玩法！</p><p><strong>如果你在使用过程中遇到问题，或者需要账号欢迎咨询</strong></p><p>完整文档打开姿势：<a href=\"https://link.juejin.cn/?target=https%3A%2F%2Fwww.yuque.com%2Fyueryi%2Fga3tog%2Fgdfl9iy2alpeg999\" target=\"_blank\"> ChatGPT怎么玩</a>) <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dd9174cab84c4197aedc9783d338ad82~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/></p><h3>一.准备工作</h3><p>和注册美区 Apple ID 一样的流程：</p><ol><li>挂个代理，伪装在日本、新加坡或者美国，建议新加坡；亲测香港是100%不可行的</li><li>准备一个国外手机号，GoogleVoice 虚拟号会被识别，亲测不行，使用<strong>接码平台</strong></li><li>Chrome 浏览器。</li></ol><h3>二. 注册接码平台</h3><p>打开网站：<a href=\"https://link.juejin.cn/?target=https%3A%2F%2Fsms-activate.org%2F\" target=\"_blank\">sms-activate.org/</a> 使用邮箱注册 注意：邮件里链接点击后可能回404，多试几次就好了。 <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f67c2540ee5b4954bdae5604ad3ca587~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/> 然后，选择充值 1 美元，支持使用支付宝。 <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3e4712bcdfe249ed9a7399f58126e948~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/> 充值完毕，在左侧搜索 OpenAI，从销量看印尼最高，亲测也可用。(印度也可以) 选择后系统会分配一个手机号，留着备用。 <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7389b23f7a33454fa291d77fd2076beb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/></p><p><strong>如果你在使用过程中遇到问题，或者需要账号欢迎咨询</strong></p><h3>三. 注册 OpenAI</h3><p>打开链接 <a href=\"https://link.juejin.cn/?target=https%3A%2F%2Fbeta.openai.com%2Fsignup\" target=\"_blank\">beta.openai.com/signup</a> 选择使用 Google 登录即可（建议） <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/498d197a95234690b69d8367995d6adb~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/></p><p>在这里输入第二步中分配给你的手机号，然后点击【Send code via SMS】按钮。 <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/579172b46c044f5da01eff657bcf6959~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/></p><p>回到刚刚的接码平台，就能看到收到的验证码了。 <strong>PS：注意购买后的短信有效期是20分钟，需要快速操作哦~</strong> <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fab7b222bf524f959b4084654917f9e6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/></p><p>我们把验证码拷贝出来输入到OpenAI的注册界面即可 <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/fd58ec99e684492fb2640ef76e556c70~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/></p><h3>四. 体验ChatGPT</h3><p>重新登录：<a href=\"https://link.juejin.cn/?target=http%3A%2F%2Fchat.openai.com%2Fauth%2Flogin\" target=\"_blank\">chat.openai.com/auth/login</a></p><p>然后访问：<a href=\"https://link.juejin.cn/?target=http%3A%2F%2Fchat.openai.com%2Fchat\" target=\"_blank\">chat.openai.com/chat</a></p><p>这时你就可以开始尽情和机器人聊天了 <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/b1d4e3feb1434934bb0459ce8230e21b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/> <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/de3949e6072b44ef931efca247d0409b~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"在这里插入图片描述\" data-href=\"\" style=\"\"/></p><p><br></p><p><br></p>', '2022-10-01 22:48:01', '2023-02-23 13:22:05', 'http://localhost:3001/images/common/434a3f72-79ec-45cc-bfce-0cef01a1ffd4.jpeg', 1, NULL);
INSERT INTO `cms_article` VALUES (9, 1, 5, 'ChatGPT可以写vue、react、js 惊艳到我', '我认为ChatGPT未来也许可以取代那些 重复 可以模板 固定公式 运作的工作 但是很难取代 定制化 人性化的工作', '<p><br></p><p><br></p><h1>前言</h1><p>chatGPT是什么？可以用来做什么？</p><p>ChatGPT 是一种由 OpenAI 训练的大型语言模型。它可以通过学习大量文本数据，来掌握语言结构和语义，生成高质量的人类可读文本。</p><p>以下是 ChatGPT 可以用来完成的一些任务：</p><ol><li>自动回复：ChatGPT 可以作为一个聊天机器人，回答用户的问题。它可以生成合适的答案，以提供快速、准确的帮助。</li><li>文本生成：ChatGPT 可以生成各种类型的文本，例如：小说、新闻报道、诗歌等。它可以根据提示词、上下文等生成相关的文本。</li><li>文本摘要：ChatGPT 可以生成长文本的摘要，帮助读者快速了解文本的主要内容。</li><li>语言翻译：ChatGPT 可以实现不同语言间的翻译，帮助不同语言的用户相互交流。</li><li>文本分类：ChatGPT 可以识别文本所属的类别，例如：技术、娱乐、新闻等。</li></ol><p>这些任务仅是 ChatGPT 的一部分应用，它还有更多的应用场景，例如：问答系统、文本审核等。总的来说，ChatGPT 是一种强大的语言模型，可以用于完成大量的自然语言处理任务。</p><p>这是来自chatGPT的自我介绍 从上 能看出它的功能主要是对文字语言的处理 （自动回复 文本生产 语言翻译 都是已经应用成熟的商业技术 虽然这些功能提高人类工作效率 也减少了工作岗位 但是并没有产生过大影响 就跟工业自动化一样 一些简单重复的工作被机器取代）</p><h1>一、ChatGPT可以写代码吗</h1><p>chatGPT可以写简单逻辑的代码 就跟低代码一样（已经是成熟项目） 实际上对程序员岗位的影响很小 因为定制化 懂需求才是主流</p><h2>写一段html代码</h2><p><img src=\"https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1d933ea1788d41f9864ac0537f35b560~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"20230208_150800.gif\" data-href=\"\" style=\"\"/></p><h2>加大难度 添加js逻辑 和用vue改写 （录制时间有限vue没录完）</h2><p><img src=\"https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bb3e92558d274e73ad3c49e4935039f8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"20230208_151114.gif\" data-href=\"\" style=\"\"/></p><p>可以看出确实会用vue写代码（有点超乎我的想象）</p><h2>加大难度 用vue 写一个包含A,B,C的下拉组件</h2><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/dcc17adda332427bb23dfd536bd09258~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"20230208_151946.gif\" data-href=\"\" style=\"\"/></p><p>这是最终成果（有点经验到我了）</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5edff7e0d452493babbda90e2539ed65~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"image.png\" data-href=\"\" style=\"\"/></p><p>我感觉非常适合小白学习 &nbsp;（为啥我那时候没出现）</p><h2>继续美化样式 添加蓝色背景</h2><p><img src=\"https://p6-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5c2ef8124aa84926b2402b46bc641335~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"20230208_152952.gif\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/00f4d27d94de4e4ebaf8b15f7c20c1ee~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"image.png\" data-href=\"\" style=\"\"/></p><h2>用react 写一个表格 包含 姓名 年龄 性别 爱好 身高</h2><p><img src=\"https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/ce0dc361ad6545998d67451f76dc709d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"20230208_153746.gif\" data-href=\"\" style=\"\"/></p><p>嗯 这个写的虽然没问题但是他没有引入react环境无法运行起来 不过写的react没问题</p><h1>二、总结</h1><p>我觉得用来给初级者学习解答真的很不错 未来能不能取代底层程序我也不知道 （ps chatGPT给的是不能）</p><p>chatGPT 还有plus版本（收费 可能还要更高级的功能） 难怪微软要投资100亿美元</p><p>不过网上说资本家到处说他可以写文章 写论文 写研究 我觉得夸大其词 （写稍微复杂点的文章就质量很差 过于死板 没有情感 而且经常中断）</p><p><img src=\"https://p9-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f887080385e4496ab8a74ec285bca9d0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"20230208_160548.gif\" data-href=\"\" style=\"\"/><br></p><p>作者：垃圾程序员<br>链接：https://juejin.cn/post/7197675335802388539<br>来源：稀土掘金<br>著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。</p>', '2022-10-01 22:48:01', '2023-02-23 13:25:33', 'http://localhost:3001/images/common/25935869-8af0-434c-89d6-b5c7c9e9c643.jpeg', 1, NULL);
INSERT INTO `cms_article` VALUES (10, 1, 5, 'AI绘画火了！一文看懂背后技术原理', '近些年AI蓬勃发展，在各行各业都有着不同方式的应用。而AI创作艺术和生产内容无疑是今年以来最热门的话题，AI创作到底发生过什么，原理又是如何，是噱头还是会有对我们有用的潜在应用场景呢？我们旨在深入浅出的尝试回答这些问题。', '<p><br></p><h1>AI创作怎么火了？</h1><p>今年开始，文本描述自动生成图片（Text-to-Image）的AI绘画黑科技一下子变火了。很多人对AI绘画产生巨大兴趣是从一副AI作品的新闻开始的。这幅由MidJourney生成的数字油画参加了Colorado博览会的艺术比赛，并且获得了第一名。这个事件可以想象的引起了巨大的争论。（难道300刀的奖金撬起了3千亿的市场？）</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/968cdd7ae43d401eac5f3071bde15886~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>Jason Allen’s A.I.-generated work, “Théâtre D’opéra Spatial,” took first place in the digital category at the Colorado State Fair.Credit…via Jason Allen</p><p>Disco Diffusion是今年2月爆火的AI图像生成程序，可以根据描述的场景关键词渲染对应的图片。今年4月，大名鼎鼎的OpenAI也发布了新模型DALL-E 2，命名来源于著名画家Dali和机器人总动员Wall-E，同样支持Text-to-Image。在年初的时候，Disco Diffusion可以生成一些有氛围感的图片，但还无法生成精致的人脸，但很快到了DALL-E 2后就可以非常清晰的画出人脸了。而现在到了Stable Diffusion在创作的精致程度和作画速度上更上了一个新的台阶。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f91199a522f54bda802acbd4616e6508~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>Disco Diffusion: Mechanical arm with a paint brush and a canvas by Li Shuxing and Tyler Edlin</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/feac21e53c6a4cb79a3bd2749391b9a3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>DALL-E2: 将Johannes Vermeer 的名画“戴珍珠耳环的女孩”转换生成不同的面孔</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/603fa87cc2284e3ca4333804b7116690~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>Stable Diffusion: a beautiful painting of a building in a serene landscape</p><p>2022年8月，被视为当下最强的AI创作工具Stable Diffusion正式开放，这无疑进一步给AI创作带来了最近的火热。通过网站注册就可以使用，提供了方便简洁的UI，也大大降低了这类工具的使用门槛，而且效率高，图像质量好。而如果不想花钱的话，Stable Diffusion还正式开源了代码、模型和weights，在huggingface上都可以直接clone和下载，部署到GPU上就可以随便用了。huggingface上同时也已经有了diffusers库，可以成为调包侠直接使用，colab上也都有现成的notebook example了。也因此热度，推出Stable Diffusion的AI公司StabilityAI完成了1亿美元的种子轮融资，公司估值达到了10亿美元。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f243bc94bfab44db9cde7aa863c1a2c8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>Stable Diffusion开源后的搜索热度已经保持两个月了</p><p>和机器学习刚开始火的时候一样，AI生成技术也并不是凭空出现的。只是近一两年以来，作品的质量和计算速度日益快速提升，让我们忽略了AI绘画同样悠久的历史。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/063ec81466414bc4b6aabb6c8244e8e2~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/>历史发展</p><p>AI绘画在计算机出现后不久就已经开始有了最初的探索。在70年的时候艺术家Harold Cohen就已经创造了程序“AARON”进行绘画，而不同于现在的黑科技，当时AARON是真的去操作机械臂来画画。Harold对AARON的改进持续了很久，80年代的时候，ARRON可以尝试画三维物体，并且很快就可以画彩图了。但AARON没有开源，所以它学习的是Harold本人的抽象色彩绘画风格。2006年，出现了The Painting Fool，有点类似AARON，通过观察照片提取颜色信息，使用现实中的材料进行创作，所以同样电脑程序通过学习信息就行物理绘画的方式。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/f4bb5782a2354d3e828f820b6d9170fc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>现在我们说的更多的“AI创作”的概念，更多的指的是基于Deep Learning模型进行自动作图的程序，这种绘画方式得益于近些年计算机软硬件的高速发展。2012年两位大神Andrew Ng和Jeff Dean进行了一次实验，使用1.6万个CPU和Youtube上一千万个猫脸图片用了3天训练了当时最大的深度学习网络，生成了一个猫脸。在现在看来这个结果不值一提，但对当时的CV领域来说，是具有突破性的意义的尝试，并且正式开启了AI创作的全新方向。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4ea935679447439fa45291408bc2c5be~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>2006年，李飞飞教授发现了很多研究工作在AI算法方面忽略了“数据”的重要性，于是带头开始构建大型图像数据集 - ImageNet，也因此图像识别大赛由此拉开帷幕，三年后李飞飞团队发表了ImageNet的论文从而真正发布了ImageNet数据集，给AI创作提供了强大的数据库。同样2006年，Geoffrey Hilton团队实现了GPU优化深度神经网络的方法，从而“深度学习”这个新名词的概念被提出，各种Neural Networks的技术手段开始不断出现，深度学习的发展也加速了AI在两个赛道Discriminative model和Generative model的发展。2012年的AlexNet，2014年的VGGNet，2015年的ResNet，2016年的DenseNet都是前者的经典模型。</p><p>而对于Generative model，2014年大神Ian Goodfellow提出了GAN，两个神经网络互相学习和训练，被认为是CV领域的重大突破，通过两个神经网络的相互博弈，使得生成的数据分布更接近真实数据分布。从此2014年的GAN、VAE以及2016年的PixelRNN/CNN成为了三类主流的Generative models。2017-2018年深度学习框架也建设成熟，PyTorch和Tensorflow成为首选框架，提供了很多图像处理的大量预训练模型，大大降低了技术门槛。2018年，Nvidia发布了Video-to-Video synthesis，它可以通过发生器、鉴别器网络等模块，合成高分辨率照片一样真实的视频，实现了把AI推向新的创造场景。GAN的大规模使用，也出现了很多基于GAN的模型迭代和优化，2019年BigGAN的出现让GAN的世界更强大，由它训练生成的图像已经无法分辨真假了，被认为是当时最强的图像生成器。</p><p>但是GAN依然存在一些缺陷，比如一些研究中都有提到模型的稳定性和收敛较差，尤其是面对更加复杂和多样的数据。更为重要的是，让生成的数据分布接近真实数据分布，也就是接近现有的内容的样子同样会形成一个问题，就是生成的内容是非常接近现有内容，接近也就是没法突破带来艺术上的“创新”。</p><p>而2020年开始在图片生成领域研究更多的Diffusion model克服了这些问题。Diffusion model的核心原理就是给图片去噪的过程中理解有意义的图像是如何生成的，同时又大大简化了模型训练过程数据处理的难度和稳定性问题。所以Diffusion模型生成的图片相比GAN模型京都更高，且随着样本数量和训练时长的累积，Diffusion model展现了对艺术表达风格更好的模拟能力。2021年的对比研究表明，在同样的ImageNet的数据库训练后的图片生成质量，使用Diffusion model得到的FID评估结果要优于当时最好的Generative models BigGAN-deep等等。</p><p>正如开头提到，今年的AI热点属于文本创作内容，而其实一直到2021年初，OpenAI发布的DALL-E其AI绘画水平也就一般，但这里开始拥有的一个重要能力就可以按照文本描述进行创作。然后今年2022年，在三座大山Stable Diffusion、DALL-E 2、MidJourney生成的各种画作中，已经引起了各种人群包括开发者、艺术家、美术工作者等等的兴趣尝试和争论。Stable Diffusion的开源和简单的过滤器功能无疑将Text-to-Imagede的热点和争议推向了高潮。</p><p>而很快大厂们不再只局限于图片，同时又推出了Text-to-Video的产品。Meta在刚过去的九月底宣布了新的AI产品Make-A-Video，使用者可以同样使用文本的方式生产简洁和高质量的短视频，他们的说明是系统模型可以从文本-图片配对数据中学习这个世界的样子并从视频片段中推理没有文本情况下的世界变化。从实现场景来看也有多种使用方式，比如文本描述不同类型的场景动作、使用单张或一对图片生成变化视频、在原始视频中加入额外的元素和变化，Meta也表明了他们之后会发布demo工具。很快在十月初，Google也发布了他们新的AI产品Imagen Video，同样是使用文本生产视频的工具。Imagen Video还在研发阶段，但Google的学术论文表明了这个工具可以通过文本描述生产24 fps的分辨率在1280x768的视频，同时可以有风格化能力和物体3D旋转能力。文章还表明Imagen Video在文本内容的视频呈现上也会相对于优于DALL-E和Stable Diffusion。又没过几天，Google和Phenaki宣布了另一个文本生产视频工具Phenaki，甚至可以生产2分钟以上较长的视频。Google同时也说明了“问题数据”对于AI模型的影响和潜在的风险，公司一直致力于严谨过滤暴力和色情内容以及文化偏差等问题，因此短期内并不会开源Imagen Video模型，但我们相信不久的将来，不管通过工具或者源代码的方式，这些cutting-edge的视频生产模型也会和图片生产模型一样很快和AI创作者们相见。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/81f9bef9869444e590282a739594c253~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>既然有了Text-to-Image和Text-to-Video，那Text-to-Speech肯定也要蹭一下热度。10月中旬postcast.ai发布了一段音频是跟用AI生成的跟Steve Jobs的对话火了（新闻），从语音语调上听起来真的和Steve本人没有差别，完全不像是机器人的声音。而技术提供方play.ht在他们的网站上也上线了新的这个非常有吸引力的功能Voice Cloning，上面提供各种名人的AI合成声音。他们并没有提供更多的技术信息，但看起来他们使用了2020年上线并在2021年底开放的GPT3模型，同时从效果上看起来已经非常接近复制真人的声音了。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eb41ff84f9aa479787054df89f1a689f~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/64fabd1c14e84041956517446ebbf3d6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><h3>技术解读</h3><p>看到历史和一些生动的例子，是不是觉得AI生成各种内容已经就在眼前了？我们可以随便写几句话就能生成精美的图片、视频、声音满足各种需求了？但是实际操作上依然会有很多的限制。下面我们就来适当剖析一下最近较热的文本生成图片和视频技术原理，到底实现了什么功能以及相关的局限性在哪里，后面我们再针对实际游戏内容做一些demo，更贴合应用场景的了解这些局限性。</p><h3>（一）Text-to-Image技术</h3><p>不同的AI图片生成器技术结构上会有差别，本文在最后也附上了一些重要模型的参考文献。我们在这里主要针对最近热门的Stable Diffusion和DALL-E 2做一些解读和讨论。这类的AI生成模型的核心技术能力就是，把人类创作的内容，用某一个高维的数学向量进行表示。如果这种内容到向量的“翻译”足够合理且能代表内容的特征，那么人类所有的创作内容都可以转化为这个空间里的向量。当把这个世界上所有的内容都转化为向量，而在这个空间中还无法表示出来的向量就是还没有创造出来的内容。而我们已经知道了这些已知内容的向量，那我们就可以通过反向转化，用AI“创造”出还没有被创造的内容。</p><ul><li>Stable Diffusion</li></ul><p>Stable Diffusion的整体上来说主要是三个部分，language model、diffusion model和decoder。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bff766b991c549848724676ecdbfbc0e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>Language model主要将输入的文本提示转化为可以输入到diffusion model使用的表示形式，通常使用embedding加上一些random noise输入到下一层。</p><p>diffusion model主要是一个时间条件U-Net，它将一些高斯噪声和文本表示作为模型输入，将对应的图像添加一点高斯噪声，从而得到一个稍微有噪点的图像，然后在时间线上重复这个过程，对于稍微有噪点的图像，继续添加高斯噪声，以获得更有噪点的图像，重复多次到几百次后就可以获得完全嘈杂的图像。这么做的过程中，知道每个步骤的图像版本。然后训练的NN就可以将噪声较大的示例作为输入，具有预测图像去噪版本的能力。</p><p>在训练过程中，还有一个encoder，是decoder的对应部分，encoder的目标是将输入图像转化为具有高语义意义的缩减采样表示，但消除与手头图像不太相关的高频视觉噪声。这里的做法是将encoder与diffusion的训练分开。这样，可以训练encoder获得最佳图像表示，然后在下游训练几个扩散模型，这样就可以在像素空间的训练上比原始图像计算少64倍，因为训练模型的训练和推理是计算最贵的部分。</p><p>decoder的主要作用就是对应encoder的部分，获得扩散模型的输出并将其放大到完整图像。比如扩散模型在64x64 px上训练，解码器将其提高到512x512 px。</p><ul><li>DALL-E 2</li></ul><p>DALL-E 2其实是三个子模块拼接而成的，具体来说：</p><ul><li>一个基于CLIP模型的编码模块，目标是训练好的文本和图像encoder，从而可以把文本和图像都被编码为相应的特征空间。</li><li>一个先验（prior）模块，目标是实现文本编码到图像编码的转换。</li><li>一个decoder模块，该模块通过解码图像编码生成目标图像。</li></ul><p>在本篇文章开始前，希望你可以了解go的一些基本的内存知识，不需要太深入，简单总结了如下几点：</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc7674c658e64922b7ee378cc0fde257~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>从上面的模型拆解中可以看出，DALL-E 2和Stable Diffusion的text encoder都是基于openAI提出的CLIP，图像的生成都是基于diffusion model。其中，CLIP是学习任意给定的图像和标题（caption）之间的相关程度。其原理是计算图像和标题各自embedding之后的高维数学向量的余弦相似度（cosine similarity）。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/9de216caadb7423cbeb1d8d83866ef8e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><h3>（二）Text-to-Video技术</h3><p>文本生成视频大概从2017年就开始有一些研究了，但一直都有很多限制。而从今年10月初Meta宣布了他们的产品Make-A-Video以及Google宣布了Imagen Video。这两款都是创新了Text-to-Video的技术场景。而这两款最新产品都是从他们的Text-to-Image产品衍生而言的，所以技术实现方式也是基于Text-to-Image的技术演变而成。</p><p>本质上来说我们可以认为静态图片就是只有一帧的视频。生成视频需要考虑图片中的元素在时间线上的变化，所以比生成照片会难很多，除了根据文本信息生成合理和正确的图片像素外，还必须推理图片像素对应的信息如何随时间变化。这里我们主要根据Make-A-Video的研究论文做一下拆解。</p><ul><li>Meta’s Make-A-Video</li></ul><p>Make-A-Video正是建立在text-to-Image技术最新进展的基础上，使用的是一种通过时空分解的diffusion model将基于Text-to-Image的模型扩展到Text-to-Video的方法。原理很直接：</p><ul><li>从文本-图像数据里学习描述的世界长什么样（文本生成图像）</li><li>从无文本的视频数据中学习世界的变化（图像在时间轴上的变化）</li></ul><p>训练数据是23亿文本-图像数据（Schuhmann et al），以及千万级别的视频数据（WebVid-10M and HD-VILA-100M）。</p><p>整体上来说Make-A-Video也是有三个重要组成部分，所有的组成部分都是分开训练：</p><ul><li>基于文本图像pair训练的基本的Text-to-Image的模型，总共会用到三个网络：</li><li>Prior网络：从文本信息生成Image特征向量，也是唯一接收文本信息的网络。</li><li>Decoder网络：从图像特征网络生成低分辨率64x64的图片。</li><li>两个空间的高分辨率网络：生成256x256和768x768的图片。</li><li>时空卷积层和注意层，将基于第一部分的网络扩展到时间维度</li><li>在模型初始化阶段扩展包含了时间维度，而扩展后包括了新的注意层，可以从视频数据中学习信息的时间变化</li><li>temporal layer是通过未标注的视频数据进行fine-tune，一般从视频中抽取16帧。所以加上时间维度的decoder可以生成16帧的图片</li><li>以及用于高帧速率生成的插帧网络</li></ul><p>空间的超分辨率模型以及插帧模型，提高的高帧速率和分辨率，让视觉质量看起来更好。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3788b63f77cf4445b5871095f7a1a7e8~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>整体评估上都要优于今年早些时期的研究：</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/1c78d623325446fe98ce0a65ff19ae91~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>优势：</p><ul><li>这里的好处很明显就是不再需要使用大量的文本视频pair数据来训练模型。</li><li>因此也大大加速了模型训练时间。</li><li>继承了现在最好的文本生成图像模型的优质结果。</li></ul><p>*前两点都是之前text-to-video生成模型发展的瓶颈。</p><p>限制：</p><ul><li>这个方法无法学习只能从视频中得到的关系文本和现象的关系，比如一个人是从左往右挥手还是从右往左挥手的的视频细节。</li><li>目前限于简单的动作和变化，包括多个场景和事件的较长视频，或者更多的视频中展现的故事细节很难实现。</li><li>一样是使用大量公开数据的大规模模型，一样有用于生产有害内容的风险。</li><li>Google’s Imagen Video</li></ul><p>是由7个串联的子模型构成，模型包含多达116亿个参数，其中T5是一个language model用来理解文本语义，Base是负责生产视频中的关键帧，SSR模型提升视频的像素，TSR负责填充关键帧之间辅助帧。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5152a8f673e24fb3b0f009a1ebd69f6e~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/2cfbe6d6924d41529de44ef0a4efa953~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><h1>能够实现的技术应用场景</h1><p>通过底层技术尤其在CV、NLP相关的各类模型在不同内容和多模态场景中的尝试和迭代，对于AI创作和内容生产同样无外乎在不同类型内容（文本、音频、图像、视频）生产和内容跨类型的生产场景。下图很好地总结了这些实际中可以使用的技术场景。</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/70337d0ba6e74c36adcb31fbb45fc542~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/004eff14c0c04eb8ac7efa84b151804d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><h1>针对游戏内容的Demo</h1><p>这些技术实现是否同样能给我们提供游戏相关的应用场景呢？我们在这里针对相对较为成熟的图像相关的生成场景做了几个demo尝试。整体上来说在我们游戏中台相关的业务场景中是有一些应用点的。下面看一下这几个demo的样子。</p><h2>（一）文本生成图像</h2><p>针对庄周这个英雄的样子我们使用工具和代码都尝试了一下如何能够生产不同风格的庄周</p><p>游戏中的样子：</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/4e86178293934db3a28e6d830f634cd0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>经过我们以下描述后的样子，同时也可以加上卡通、二次元、素描等等风格的描述，我们得到各种不同风格类型的样子：</p><p>Ultra detailed illustration of a butterfly anime boy covered in liquid chrome, with green short hair, beautiful and clear facial features, lost in a dreamy fairy landscape, crystal butterflies around, vivid colors, 8k, anime vibes, octane render, uplifting, magical composition, trending on artstation</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8f078bc1427841f4a5337b7043388423~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>我们在各种尝试的过程中很明显的感知和发现一些限制：</p><ul><li>文本描述生成的结果会有一些随机性，生成的图片大概率是很难完全按照“需求”生成，更多带来的是“惊喜”，这种惊喜在一定的层面上代表的也是一种艺术风格。所以在实际的使用中并不是很适用于按照严格要求生产图片的任务，而更多的适用于有一定的描述，能够给艺术创意带来一些灵感的迸发和参考。</li><li>文本的准确描述对于生成的图片样子是极其重要的，技术本身对文本描述和措辞有较高要求，需对脑海中的核心创意细节有较为准确的描述。</li><li>生产Domain-specific例如腾讯游戏高度一致的内容元素需对预训练大模型进行再训练。</li></ul><p>而文本生成视频的场景相对很新，Google/Meta也是这两三周才官宣对应的视频生成器，且还没有开放使用和开源，但我们预估以目前的热度和迭代速度，在未来的3-6个月内我们可以对相关能力有更清晰的探索和尝试。</p><h2>（二）图像融合和变换</h2><p>图像本身的融合变换在早几年的时候就已经有了一些研究和探索，且有了相对较为成熟的生成的样子，这里我们使用和平精英的素材尝试做一种变换风格的样子。</p><p>和平精英素材原图和星空：</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/0fc487ae3216474aa233c5848155c8e7~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>更加深度的将星空的颜色和变化融合到原始图片中：</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/152ec393c0dd49bc8f2ce5deaef102ea~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>相对较浅度的将星空的颜色像素融合到原始图片中：</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/8749e0a8d46f4c48b3ce5062229c65dc~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>另外一种很有意思的方式是，我们可以变换人物风格，比如王者英雄不知火舞和亚瑟在我们印象的样子，我们可以把他们Q化成数码宝贝的样子：</p><p>不知火舞</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/e0b92fafced5458a97724da651a67aa0~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/376120db0953451f8cf084a9a92dc119~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cc7bd38cadb445f39ea7f52e668b1f48~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>亚瑟</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/5caffbb50f8642d994f3c9f889309c10~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/09eeb35eb08841a29fa61f9d7c60ff80~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/86b8e54298e94d478489b07692e4aaf6~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p>试想一下，这些不同的技术实现甚至都可以串联在一起，比如我们可以先用文本描述生成图片，再对图片进行风格变换等等，那这里可以操作的事情就越来越多了，这里就不一一展开了。</p><p>而再进一步思考（发自懒人的思考），我们是不是都不用去思考文本怎么写？有没有帮忙生成文本或者我们可以搜索之前生成过的文本？答案是有，比如Phraser就提供了这样的方式，甚至可以通过图片搜索相关的文本：</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/7877c9a54c1b43f5ae7dd4e3353f7e76~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/30ab49d50eda4bc09341d822009dd723~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"图片\" data-href=\"\" style=\"\"/></p><h1>AI创作的意义及风险</h1><p>（一）意义</p><p>正如开头提到，今年的AI热点属于AI创作，从2月的Disco Diffusion，到4月的DALL-E 2和MidJourney内测，到5/6月的Google模型Imagen和Parti，再到7月底的Stable Diffusion。越来越多的人开始尝试AI创作图像、声音、视频、3D内容等等，这让我们看到了AI在艺术领域越来越多的可能性。</p><p>十多年前当世界都开始为AI和机器学习欢呼的时候，我们看到了很多AI可以做的事情，而“创作力”和“想象力”也是一直以来AI最无法啃动的硬骨头，也是人类世界在AI和机器取代面前最后的倔强，然而现在看起来也是可以被技术拆解的。</p><p>从Alpha GO身上，我们就看到了AI在智慧和谋略上就已经突破了人类极限，而AI创作又进一步在创造力和想象力逐渐取代人类。在未来，一个各方面成熟的AI完全取代人类看起来已经是越来越现实的问题。如果AI未来可以完成计算机领域上下游所有的事情包括自己写代码，那么人类需要思考的问题就是如何和一个超越自己所有方面的人共存于世了。</p><h1>（二）风险</h1><p>AI创作的大火在很长时间以后回头看一定有Stable Diffusion的开源的一席之地，同样这也会带来一些争议和风险。Stability AI的开源是简单粗暴的，他们几乎不对生成内容做任何审核或者过滤，他们只包含了一些关键词过滤，但技术上可以轻松绕过，Reddit上就有教程如何5秒内移除Stable Diffusion的安全过滤。因此用户可以轻松指控Stable Diffusion生成暴力或不良图片，描绘公众人物和名人，也可以高度仿制艺术品或者有版权保护的图像，aka deepfakes。</p><p>由此我们也可以设想这项技术可能被用于各类恶意和影响巨大的用途，我们还很难判断在更久的未来，这项技术的开源是会给我们更大的技术革新还是各种问题。目前最大的乱子可能就是Stable Diffusion让生成暴力和色情图像变得更容易，且内容中往往包含真人特征。虽然开源说明禁止人们使用该模型实施各类犯罪行为，但只要把Stable Diffusion下载到自己的电脑上，使用者可以完全不守约束。虽然很多论坛例如Reddit有不少约束政策且会封禁相关内容，但仍有用户不断生成各种名人明星的荒诞图像，AI生成内容的伦理问题再次会出现在风口浪尖。</p><p>在AI创作内容的这些模型中，训练数据中一类很明显的视觉素材就是受版权保护的作品。这在艺术家眼里，模仿艺术风格和美学的行为是不道德行为，且可能违反版权。Stable Diffusion也是其中重要一员，它的训练集LAION-5B包含50多亿张图像与匹配的文本标注，其中就包含了大量受版权保护的内容，这些内容其实归众多独立艺术家和专业摄影师所有。这些版权争议，也给这些AI创作工具带来了盗窃艺术家创作成果的骂名，也让很多有抱负有想法的艺术家越来越难以生存。<br></p><p>作者：腾讯云开发者<br>链接：https://juejin.cn/post/7161340423611351077<br>来源：稀土掘金<br>著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。</p><h3></h3>', '2022-10-01 22:48:01', '2023-02-23 13:26:54', 'http://localhost:3001/images/common/04d22b04-230c-4737-87b9-130b94ba2cea.jpeg', 1, NULL);
INSERT INTO `cms_article` VALUES (11, 7, 9, 'SpringBoot-实现RAS+AES自动接口解密', '目前常用的加密方式就对称性加密和非对称性加密，加密解密的操作的肯定是大家知道的，最重要的使用什么加密解密方式，制定什么样的加密策略；考虑到我技术水平和接口的速度，采用的是RAS非对称加密和AES对称加密一起用！！！！', '<p><br><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/bf08a0c1bae94717a269bc6ec99ac685~tplv-k3u1fbpfcp-zoom-crop-mark:3024:3024:3024:1702.awebp?\" alt=\"SpringBoot-实现RAS+AES自动接口解密\" data-href=\"\" style=\"width: 755.925px;\"/></p><p><br></p><p>我正在参加「掘金·启航计划」</p><h2>一、讲个事故</h2><p>接口安全老生常谈了</p><p>过年之前做了过一款飞机大战的H5小游戏，里面无限模式-需要保存用户的积分，因为使用的Body传参，参数是可见的，为了接口安全我，我和前端约定了传递参数是：<strong>用户无限模式的积分+“我们约定的一个数字”+用户id的和</strong>，在用<span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>Base64</code></span>加密，请求到服务器我再解密，出用户无限模式的积分；如下：</p><pre><code class=\"language-hljs language-json copyable\">{\n    \"integral\": \"MTExMTM0NzY5NQ==\",\n}\n复制代码</code></pre><p>可是过年的时候，运营突然找我说无限模式积分排行榜分数不对： <img src=\"https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/d6674de9f0b748cab6ee4a48d833c55d~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"image-20230223230748206.png\" data-href=\"\" style=\"\"/> <img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/eed12500abb94772b03d6672baa472d3~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"image-20230223230631313.png\" data-href=\"\" style=\"\"/> 这就很诡异了，第二名才一万多分，第一名就40多万分！！！！</p><p>一开始我以为是我解密有问题，反复看了好几变，可就两三行代码不可能有问题的！！！</p><p>没办法我去翻了好久的日志，才发现这个用户把我接口参数给改了。。。。</p><p>他把<span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>Base64</code></span>接口参数改了 <img src=\"https://p1-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3c98adcbb20547b889e56f001d8a4c00~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp?\" alt=\"image-20230223231806161.png\" data-href=\"\" style=\"\"/> 事已至此，我也不能怪用户，谁让我把人家想得太简单，接口安全也没到位</p><p>所以年后上班第一件是就是把接口加密的工作搞起来</p><p>目前常用的加密方式就对称性加密和非对称性加密，加密解密的操作的肯定是大家知道的，最重要的使用什么加密解密方式，制定什么样的加密策略；考虑到我技术水平和接口的速度，采用的是RAS非对称加密和AES对称加密一起用！！！！</p><h2>二、RSA和AES基础知识</h2><h3>1、非对称加密和对称加密</h3><p><strong>非对称加密</strong></p><p>非对称加密算法是一种密钥的保密方法。 非对称加密算法需要两个密钥：公开密钥（publickey:简称公钥）和私有密钥（privatekey:简称私钥）。 公钥与私钥是一对，如果用公钥对数据进行加密，只有用对应的私钥才能解密。 因为加密和解密使用的是两个不同的密钥，所以这种算法叫作非对称加密算法。</p><p><strong>对称加密</strong></p><p>加密秘钥和解密秘钥是一样，当你的密钥被别人知道后，就没有秘密可言了</p><p><strong>AES 是对称加密算法</strong>，优点：加密速度快；缺点：如果秘钥丢失，就容易解密密文，安全性相对比较差</p><p><strong>RSA 是非对称加密算法</strong> ， 优点：安全 ；缺点：加密速度慢</p><h3>2、RSA基础知识</h3><p><span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>RSA</code></span>——非对称加密，会产生公钥和私钥，公钥在客户端，私钥在服务端。公钥用于加密，私钥用于解密。</p><p>大概的流程：</p><blockquote>客户端向服务器发送消息： 客户端用公钥加密信息，发送给服务端，服务端再用私钥机密服务器向客户端发送消息：服务端用私钥加密信息，发送给客户端，客户端再用公钥机密</blockquote><p>当然中间要保障密钥的安全，还有很多为了保障数据安全的操作，比如数字签名，证书签名等等，在这我们就先不说了；</p><p><strong>RSA加密解密算法支持三种填充模式</strong>，</p><p>分别是<span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>ENCRYPTION_OAEP</code></span>、<span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>ENCRYPTION_PKCS1</code></span>、<span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>ENCRYPTION_NONE</code></span>，RSA填充是为了和公钥等长。</p><ul><li><strong>ENCRYPTION_OAEP</strong>：<strong>最优非对称加密填充</strong>，是RSA加密和RSA解密最新最安全的推荐填充模式。</li><li><strong>ENCRYPTION_PKCS1</strong>：<strong>随机填充数据模式</strong>，每次加密的结果都不一样，是RSA加密和RSA解密使用最为广泛的填充模式。</li><li><strong>ENCRYPTION_NONE</strong>：<strong>不填充模式</strong>，是RSA加密和RSA解密使用较少的填充模式。</li></ul><p><strong>RSA 常用的加密填充模式</strong></p><ul><li>RSA/None/PKCS1Padding</li><li>RSA/ECB/PKCS1Padding</li></ul><p>知识点：</p><ul><li>Java 默认的 RSA 实现是 <span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>RSA/None/PKCS1Padding</code></span></li><li>在创建RSA秘钥对时，长度最好选择 2048的整数倍，长度为1024在已经不很安全了</li><li>一般由服务器创建秘钥对，私钥保存在服务器，公钥下发至客户端</li><li>DER是RSA密钥的二进制格式，PEM是DER转码为Base64的字符格式，由于DER是二进制格式，不便于阅读和理解。一般而言，密钥都是通过PEM的格式进行存储的</li></ul><pre><code class=\"language-hljs language-scss copyable\">    /**\n     * 生成密钥对\n     * @param keyLength  密钥长度\n     * @return KeyPair\n     */\n    public static KeyPair getKeyPair(int keyLength) {\n        try {\n            KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance(\"RSA\");   //默认:RSA/None/PKCS1Padding\n            keyPairGenerator.initialize(keyLength);\n            return keyPairGenerator.generateKeyPair();\n        } catch (NoSuchAlgorithmException e) {\n            throw new RuntimeException(\"生成密钥对时遇到异常\" +  e.getMessage());\n        }\n    }\n​\n    /**\n     * 获取公钥\n     */\n    public static byte[] getPublicKey(KeyPair keyPair) {\n        RSAPublicKey rsaPublicKey = (RSAPublicKey) keyPair.getPublic();\n        return rsaPublicKey.getEncoded();\n    }\n​\n    /**\n     * 获取私钥\n     */\n    public static byte[] getPrivateKey(KeyPair keyPair) {\n        RSAPrivateKey rsaPrivateKey = (RSAPrivateKey) keyPair.getPrivate();\n        return rsaPrivateKey.getEncoded();\n    }\n复制代码</code></pre><h3>3、AES基础知识</h3><p><strong>AES 简介</strong> AES加密解密算法是一种可逆的对称加密算法，这类算法在加密和AES解密时使用相同的密钥，或是使用两个可以简单地相互推算的密钥，一般用于服务端对服务端之间对数据进行加密解密。它是一种为了替代原先DES、3DES而建立的高级加密标准（Advanced Encryption Standard）。作为可逆且对称的块加密，AES加密算法的速度比公钥加密等加密算法快很多，在很多场合都需要AES对称加密，但是要求加密端和解密端双方都使用相同的密钥是AES算法的主要缺点之一。</p><p><strong>AES加密解密</strong></p><p>AES加密需要：明文 + 密钥+ 偏移量（IV）+密码模式(算法/模式/填充) AES解密需要：密文 + 密钥+ 偏移量（IV）+密码模式(算法/模式/填充)</p><p>AES的算法模式一般为 <span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>AES/CBC/PKCS5Padding</code></span> 或 <span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>AES/CBC/PKCS7Padding</code></span></p><p><strong>AES常见的工作模式</strong>：</p><ul><li>电码本模式(ECB)</li><li>密码分组链接模式(CBC)</li><li>计算器模式(CTR)</li><li>密码反馈模式(CFB)</li><li>输出反馈模式(OFB)</li></ul><p><span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>除了ECB无须设置初始化向量IV而不安全之外，其它AES工作模式都必须设置向量IV，其中GCM工作模式较为特殊。</code></span></p><p><strong>AES填充模式</strong></p><p>块密码只能对确定长度的数据块进行处理，而消息的长度通常是可变的，因此需要选择填充模式。</p><ul><li><span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>填充区别</code></span>：在ECB、CBC工作模式下最后一块要在加密前进行填充，其它不用选择填充模式；</li><li><span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>填充模式</code></span>：AES支持的填充模式为PKCS7和NONE不填充。其中PKCS7标准是主流加密算法都遵循的数据填充算法。AES标准规定的区块长度为固定值128Bit，对应的字节长度为16位，这明显和PKCS5标准规定使用的固定值8位不符，虽然有些框架特殊处理后可以通用PKCS5，但是从长远和兼容性考虑，推荐PKCS7。</li></ul><p><strong>AES密钥KEY和初始化向量IV</strong></p><p>初始化向量IV可以有效提升安全性，但是在实际的使用场景中，它不能像密钥KEY那样直接保存在配置文件或固定写死在代码中，一般正确的处理方式为：在加密端将IV设置为一个16位的随机值，然后和加密文本一起返给解密端即可。</p><ul><li><span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>密钥KEY</code></span>：AES标准规定区块长度只有一个值，固定为128Bit，对应的字节为16位。AES算法规定密钥长度只有三个值，128Bit、192Bit、256Bit，对应的字节为16位、24位和32位，其中密钥KEY不能公开传输，用于加密解密数据；</li><li><span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>初始化向量IV</code></span>：该字段可以公开，用于将加密随机化。同样的明文被多次加密也会产生不同的密文，避免了较慢的重新产生密钥的过程，初始化向量与密钥相比有不同的安全性需求，因此IV通常无须保密。然而在大多数情况中，不应当在使用同一密钥的情况下两次使用同一个IV，一般推荐初始化向量IV为16位的随机值。</li></ul><h2>三、加密策略</h2><p>RAS、AES加密解密的操作都是一样，如果有效的结合到一起才能达到更好的加密效果很重要；</p><p>上面说到：</p><p><strong>AES 是对称加密算法</strong>，优点：加密速度快；缺点：如果秘钥丢失，就容易解密密文，安全性相对比较差</p><p><strong>RSA 是非对称加密算法</strong> ， 优点：安全 ；缺点：加密速度慢</p><h3>1、<strong>主要思路：</strong></h3><p>那么我们就结合2个加密算法的优点来操作：</p><p>1、因为接口传递的参数有多有少，当接口传递的参数过多时，使用RSA加密会导致加密速度慢，所以我们使用AES加密加密接口参数</p><p>2、因为AES的密钥key和偏移量VI都是固定的所以可以使用RSA加密</p><p>3、客户端将AES加密后的密文和RSA加密后的密文，传递给服务器即可。</p><h3>2、<strong>涉及工具类：</strong></h3><p>util包下：</p><ol><li>ActivityRSAUtil</li><li>AES256Util</li><li>RequestDecryptionUtil</li></ol><h3>3、加密策略</h3><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/3d86e041d0204c049f04d11c54cb9253~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"img\" data-href=\"\" style=\"\"/></p><h3>4、交互方式</h3><h5><strong>前端：</strong></h5><p>1、客户端随机生成2个16为的AES密钥和AES偏移量</p><p>2、使用AES加密算法加密真实传递参数，得到参数密文“asy”</p><p>3、将AES密钥、AES偏移量和当前时间戳，格式如下：</p><ul><li>key：密钥</li><li>keyVI：偏移量</li><li>time：请求时间，用户判断是否重复请求</li></ul><pre><code class=\"language-hljs language-json copyable\">{\n  \"key\":\"0t7FtCDKofbEVpSZS\",\n  \"keyVI\":\"0t7WESMofbEVpSZS\",\n  \"time\":211213232323323\n}\n//转成JSON字符串\n复制代码</code></pre><p>4、AES信息密钥信息，再使用RSA公钥加密，得到AES密钥的密文“sym”</p><p>5、将“sym”和“asy”作为body参数，调用接口</p><p><img src=\"https://p3-juejin.byteimg.com/tos-cn-i-k3u1fbpfcp/cecd80cc0ced4f248b4e73812ec0cf33~tplv-k3u1fbpfcp-zoom-in-crop-mark:4536:0:0:0.awebp\" alt=\"img\" data-href=\"\" style=\"\"/></p><h5><strong>后端：</strong></h5><p>1、在接口接收参数中，多增加2个字段接收加密后的“sym”和“asy” （名字可以自己定，能接收到就行）</p><p>2、使用RequestDecryptionUtil.getRequestDecryption（）方法解密，返回解密后的真实传递参数</p><h2>四、服务器自动解密</h2><p>因为不是每个接口都需求加密解密，我们可以自定义一个注解，将需要解密的接口上加一个这个注解，</p><h4>1、<strong>自定义解密注解</strong>：<span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>@RequestRSA</code></span></h4><pre><code class=\"language-hljs language-java copyable\">import java.lang.annotation.Documented;\nimport java.lang.annotation.ElementType;\nimport java.lang.annotation.Retention;\nimport java.lang.annotation.RetentionPolicy;\nimport java.lang.annotation.Target;\n​\n​\n@Target({ElementType.TYPE, ElementType.METHOD})\n@Retention(RetentionPolicy.RUNTIME)\n@Documented\npublic @interface RequestRSA {\n}\n复制代码</code></pre><h4>2、<strong>创建一个aop切片</strong></h4><ul><li>1、AOP判断controller接收到请求是否带有<span style=\"color: rgb(255, 80, 44); background-color: rgb(255, 245, 245);\"><code>@RequestRSA</code></span>注解</li><li>2、如果带有注解，通过ProceedingJoinPoint类getArgs()方法获取请求的body参数，</li><li>3、将body参数，传为JSONObject类，获取到\"asy\"和\"sym\"属性，再调用RequestDecryptionUtil解密获取接口传递的真实参数</li><li>4、获取接口入参的类</li><li>5、将获取解密后的真实参数，封装到接口入参的类中</li></ul><pre><code class=\"language-hljs language-ini copyable\">import com.alibaba.fastjson.JSONObject;\nimport app.activity.common.interceptor.RequestRSA;\nimport app.activity.util.RequestDecryptionUtil;\nimport lombok.extern.slf4j.Slf4j;\nimport org.aspectj.lang.ProceedingJoinPoint;\nimport org.aspectj.lang.annotation.Around;\nimport org.aspectj.lang.annotation.Aspect;\nimport org.aspectj.lang.annotation.Pointcut;\nimport org.aspectj.lang.reflect.MethodSignature;\nimport org.springframework.core.annotation.Order;\nimport org.springframework.stereotype.Component;\nimport org.springframework.web.bind.annotation.RequestBody;\n​\nimport java.lang.reflect.Method;\nimport java.lang.reflect.Parameter;\nimport java.util.ArrayList;\nimport java.util.List;\nimport java.util.Objects;\n​\n/**\n * @module\n * @author: qingxu.liu\n * @date: 2023-02-08 16:41\n * @copyright  请求验证RSA & AES  统一验证切面\n **/\n@Aspect\n@Component\n@Order(2)\n@Slf4j\npublic class RequestRSAAspect {\n​\n    /**\n     * 1&gt; 获取请求参数\n     * 2&gt; 获取被请求接口的入参类型\n     * 3&gt; 判断是否为get请求 是则跳过AES解密判断\n     * 4&gt; 请求参数解密-&gt;封装到接口的入参\n     */\n​\n    @Pointcut(\"execution(public * app.activity.controller.*.*(..))\")\n    public void requestRAS() {\n    }\n​\n    @Around(\"requestRAS()\")\n    public Object doAround(ProceedingJoinPoint joinPoint) throws Throwable {\n        //=======AOP解密切面通知=======\n        MethodSignature methodSignature = (MethodSignature) joinPoint.getSignature();\n        Method methods = methodSignature.getMethod();\n        RequestRSA annotation = methods.getAnnotation(RequestRSA.class);\n        if (Objects.nonNull(annotation)){\n            //获取请求的body参数\n            Object data = getParameter(methods, joinPoint.getArgs());\n            String body = JSONObject.toJSONString(data);\n            //获取asy和sym的值\n            JSONObject jsonObject = JSONObject.parseObject(body);\n            String asy = jsonObject.get(\"asy\").toString();\n            String sym = jsonObject.get(\"sym\").toString();\n            //调用RequestDecryptionUtil方法解密，获取解密后的真实参数\n            JSONObject decryption = RequestDecryptionUtil.getRequestDecryption(sym, asy);\n            //获取接口入参的类\n            String typeName = joinPoint.getArgs()[0].getClass().getTypeName();\n            System.out.println(\"参数值类型：\"+ typeName);\n            Class&lt;?&gt; aClass = joinPoint.getArgs()[0].getClass();\n            //将获取解密后的真实参数，封装到接口入参的类中\n            Object o = JSONObject.parseObject(decryption.toJSONString(), aClass);\n            Object[] as = {o};\n            return joinPoint.proceed(as);\n        }\n        return joinPoint.proceed();\n    }\n​\n    /**\n     * 根据方法和传入的参数获取请求参数 获取的是接口的入参\n     */\n    private Object getParameter(Method method, Object[] args) {\n        List&lt;Object&gt; argList = new ArrayList&lt;&gt;();\n        Parameter[] parameters = method.getParameters();\n        for (int i = 0; i &lt; parameters.length; i++) {\n            //将RequestBody注解修饰的参数作为请求参数\n            RequestBody requestBody = parameters[i].getAnnotation(RequestBody.class);\n            if (requestBody != null) {\n                argList.add(args[i]);\n            }\n        }\n        if (argList.size() == 0) {\n            return null;\n        } else if (argList.size() == 1) {\n            return argList.get(0);\n        } else {\n            return argList;\n        }\n    }\n}\n复制代码</code></pre><h4>3、<strong>RequestDecryptionUtil 解密类</strong></h4><p>1、使用privateKey私钥对”sym“解密获取到客户端加密的AES密钥，偏移量、时间等信息</p><pre><code class=\"language-hljs language-json copyable\">{\n  \"key\":\"0t7FtSMofbEVpSZS\",\n  \"keyVI\":\"0t7FtSMofbEVpSZS\",\n  \"time\":211213232323323\n}\n复制代码</code></pre><p>2、获取当前时间戳，与time比较是否超过一分钟（6000毫秒），超过就抛出“Request timed out, please try again”异常</p><p>3、没有超时，将获取的到AES密钥和偏移量，再对“asy”解密获取接口传递的真实参数</p><pre><code class=\"language-hljs language-typescript copyable\">import com.alibaba.fastjson.JSONObject;\nimport app.activity.common.rsa.RSADecodeData;\nimport app.common.exception.ServiceException;\n​\nimport java.security.interfaces.RSAPrivateKey;\nimport java.util.Objects;\n​\n/**\n * @module\n * @author: qingxu.liu\n * @date: 2023-02-09 17:43\n * @copyright\n **/\npublic class RequestDecryptionUtil {\n​\n    private final static String publicKey = \"RSA生成的公钥\";\n    private final static String privateKey = \"RSA生成的私钥\";\n    private final static Integer timeout = 60000;\n​\n    /**\n     *\n     * @param sym RSA 密文\n     * @param asy AES 密文\n     * @param clazz 接口入参类\n     * @return Object\n     */\n    public static &lt;T&gt; Object getRequestDecryption(String sym, String asy, Class&lt;T&gt; clazz){\n        //验证密钥\n        try {\n            //解密RSA\n            RSAPrivateKey rsaPrivateKey = ActivityRSAUtil.getRSAPrivateKeyByString(privateKey);\n            String RSAJson = ActivityRSAUtil.privateDecrypt(sym, rsaPrivateKey);\n            RSADecodeData rsaDecodeData = JSONObject.parseObject(RSAJson, RSADecodeData.class);\n            boolean isTimeout = Objects.nonNull(rsaDecodeData)  && Objects.nonNull(rsaDecodeData.getTime()) && System.currentTimeMillis() -  rsaDecodeData.getTime() &lt; timeout;\n            if (!isTimeout){\n                throw new ServiceException(\"Request timed out, please try again.\"); //请求超时\n            }\n            //解密AES\n            String AESJson = AES256Util.decode(rsaDecodeData.getKey(),asy,rsaDecodeData.getKeyVI());\n            System.out.println(\"AESJson: \"+AESJson);\n            return JSONObject.parseObject(AESJson,clazz);\n        } catch (Exception e) {\n            throw new RuntimeException(\"RSA decryption Exception:  \" +e.getMessage());\n        }\n    }\n​\n    public static JSONObject getRequestDecryption(String sym, String asy){\n        //验证密钥\n        try {\n            //解密RSA\n            RSAPrivateKey rsaPrivateKey = ActivityRSAUtil.getRSAPrivateKeyByString(privateKey);\n            String RSAJson = ActivityRSAUtil.privateDecrypt(sym, rsaPrivateKey);\n            RSADecodeData rsaDecodeData = JSONObject.parseObject(RSAJson, RSADecodeData.class);\n            boolean isTimeout = Objects.nonNull(rsaDecodeData)  && Objects.nonNull(rsaDecodeData.getTime()) && System.currentTimeMillis() -  rsaDecodeData.getTime() &lt; timeout;\n            if (!isTimeout){\n                throw new ServiceException(\"Request timed out, please try again.\"); //请求超时\n            }\n            //解密AES\n            String AESJson = AES256Util.decode(rsaDecodeData.getKey(),asy,rsaDecodeData.getKeyVI());\n            System.out.println(\"AESJson: \"+AESJson);\n            return JSONObject.parseObject(AESJson);\n        } catch (Exception e) {\n            throw new RuntimeException(\"RSA decryption Exception:  \" +e.getMessage());\n        }\n    }\n}\n复制代码</code></pre><h4>4、ActivityRSAUtil 工具类</h4><pre><code class=\"language-java\">import org.apache.commons.io.IOUtils;\nimport javax.crypto.Cipher;\nimport java.io.ByteArrayOutputStream;\nimport java.security.*;\nimport java.security.interfaces.RSAPrivateKey;\nimport java.security.interfaces.RSAPublicKey;\nimport java.security.spec.PKCS8EncodedKeySpec;\nimport java.security.spec.X509EncodedKeySpec;\nimport java.util.Base64;\n​\n/**\n * @module\n * @author: qingxu.liu\n * @date: 2023-02-07 16:54\n * @copyright\n **/\npublic class ActivityRSAUtil {\n​\n    /**\n     * 字符集\n     */\n    public static String CHARSET = \"UTF-8\";\n​\n    /**\n     * 生成密钥对\n     * @param keyLength  密钥长度\n     * @return KeyPair\n     */\n    public static KeyPair getKeyPair(int keyLength) {\n        try {\n            KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance(\"RSA\");   //默认:RSA/None/PKCS1Padding\n            keyPairGenerator.initialize(keyLength);\n            return keyPairGenerator.generateKeyPair();\n        } catch (NoSuchAlgorithmException e) {\n            throw new RuntimeException(\"生成密钥对时遇到异常\" +  e.getMessage());\n        }\n    }\n​\n    /**\n     * 获取公钥\n     */\n    public static byte[] getPublicKey(KeyPair keyPair) {\n        RSAPublicKey rsaPublicKey = (RSAPublicKey) keyPair.getPublic();\n        return rsaPublicKey.getEncoded();\n    }\n​\n    /**\n     * 获取私钥\n     */\n    public static byte[] getPrivateKey(KeyPair keyPair) {\n        RSAPrivateKey rsaPrivateKey = (RSAPrivateKey) keyPair.getPrivate();\n        return rsaPrivateKey.getEncoded();\n    }\n​\n    /**\n     * 公钥字符串转PublicKey实例\n     * @param publicKey 公钥字符串\n     * @return          PublicKey\n     * @throws Exception e\n     */\n    public static PublicKey getPublicKey(String publicKey) throws Exception {\n        byte[] publicKeyBytes = Base64.getDecoder().decode(publicKey.getBytes());\n        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(publicKeyBytes);\n        KeyFactory keyFactory = KeyFactory.getInstance(\"RSA\");\n        return keyFactory.generatePublic(keySpec);\n    }\n​\n    /**\n     * 私钥字符串转PrivateKey实例\n     * @param privateKey  私钥字符串\n     * @return PrivateKey\n     * @throws Exception e\n     */\n    public static PrivateKey getPrivateKey(String privateKey) throws Exception {\n        byte[] privateKeyBytes = Base64.getDecoder().decode(privateKey.getBytes());\n        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(privateKeyBytes);\n        KeyFactory keyFactory = KeyFactory.getInstance(\"RSA\");\n        return keyFactory.generatePrivate(keySpec);\n    }\n​\n    /**\n     * 获取公钥字符串\n     * @param keyPair KeyPair\n     * @return  公钥字符串\n     */\n    public static String getPublicKeyString(KeyPair keyPair){\n        RSAPublicKey publicKey = (RSAPublicKey) keyPair.getPublic();  // 得到公钥\n        return new String(org.apache.commons.codec.binary.Base64.encodeBase64(publicKey.getEncoded()));\n    }\n​\n    /**\n     * 获取私钥字符串\n     * @param keyPair  KeyPair\n     * @return 私钥字符串\n     */\n    public static String getPrivateKeyString(KeyPair keyPair){\n        RSAPrivateKey privateKey = (RSAPrivateKey) keyPair.getPrivate();   // 得到私钥\n        return new String(org.apache.commons.codec.binary.Base64.encodeBase64((privateKey.getEncoded())));\n    }\n​\n​\n    /**\n     * 公钥加密\n     * @param data        明文\n     * @param publicKey   公钥\n     * @return            密文\n     */\n    public static String publicEncrypt(String data, RSAPublicKey publicKey) {\n        try {\n            Cipher cipher = Cipher.getInstance(\"RSA\");\n            cipher.init(Cipher.ENCRYPT_MODE, publicKey);\n            byte[] bytes = rsaSplitCodec(cipher, Cipher.ENCRYPT_MODE, data.getBytes(CHARSET), publicKey.getModulus().bitLength());\n            return new String(org.apache.commons.codec.binary.Base64.encodeBase64(bytes));\n        } catch (Exception e) {\n            throw new RuntimeException(\"加密字符串[\" + data + \"]时遇到异常\"+  e.getMessage());\n        }\n    }\n​\n    /**\n     * 私钥解密\n     * @param data        密文\n     * @param privateKey  私钥\n     * @return            明文\n     */\n    public static String privateDecrypt(String data, RSAPrivateKey privateKey) {\n        try {\n            Cipher cipher = Cipher.getInstance(\"RSA\");\n            cipher.init(Cipher.DECRYPT_MODE, privateKey);\n            return new String(rsaSplitCodec(cipher, Cipher.DECRYPT_MODE, Base64.getDecoder().decode(data), privateKey.getModulus().bitLength()), CHARSET);\n        } catch (Exception e) {\n            throw new RuntimeException(\"privateKey解密字符串[\" + data + \"]时遇到异常\"+  e.getMessage());\n        }\n    }\n​\n​\n    /**\n     * 私钥加密\n     * @param content 明文\n     * @param privateKey 私钥\n     * @return 密文\n     */\n    public static String encryptByPrivateKey(String content, RSAPrivateKey privateKey){\n​\n        try {\n            Cipher cipher = Cipher.getInstance(\"RSA\");\n            cipher.init(Cipher.ENCRYPT_MODE, privateKey);\n            byte[] bytes = rsaSplitCodec(cipher, Cipher.ENCRYPT_MODE,content.getBytes(CHARSET), privateKey.getModulus().bitLength());\n            return new String(org.apache.commons.codec.binary.Base64.encodeBase64(bytes));\n        } catch (Exception e) {\n            throw new RuntimeException(\"privateKey加密字符串[\" + content + \"]时遇到异常\" +  e.getMessage());\n        }\n    }\n​\n    /**\n     * 公钥解密\n     * @param content  密文\n     * @param publicKey 私钥\n     * @return  明文\n     */\n    public static String decryByPublicKey(String content, RSAPublicKey publicKey){\n        try {\n            Cipher cipher = Cipher.getInstance(\"RSA\");\n            cipher.init(Cipher.DECRYPT_MODE, publicKey);\n            return new String(rsaSplitCodec(cipher, Cipher.DECRYPT_MODE, Base64.getDecoder().decode(content), publicKey.getModulus().bitLength()), CHARSET);\n        } catch (Exception e) {\n            throw new RuntimeException(\"publicKey解密字符串[\" + content + \"]时遇到异常\" +e.getMessage());\n        }\n    }\n​\n    public static RSAPublicKey getRSAPublicKeyByString(String publicKey){\n        try {\n            X509EncodedKeySpec keySpec = new X509EncodedKeySpec(Base64.getDecoder().decode(publicKey));\n            KeyFactory keyFactory = KeyFactory.getInstance(\"RSA\");\n            return (RSAPublicKey)keyFactory.generatePublic(keySpec);\n        } catch (Exception e) {\n            throw new RuntimeException(\"String转PublicKey出错\" + e.getMessage());\n        }\n    }\n​\n​\n    public static RSAPrivateKey getRSAPrivateKeyByString(String privateKey){\n        try {\n            PKCS8EncodedKeySpec pkcs8EncodedKeySpec = new PKCS8EncodedKeySpec(Base64.getDecoder().decode(privateKey));\n            KeyFactory keyFactory = KeyFactory.getInstance(\"RSA\");\n            return (RSAPrivateKey)keyFactory.generatePrivate(pkcs8EncodedKeySpec);\n        } catch (Exception e) {\n            throw new RuntimeException(\"String转PrivateKey出错\" + e.getMessage());\n        }\n    }\n​\n​\n    //rsa切割解码  , ENCRYPT_MODE,加密数据   ,DECRYPT_MODE,解密数据\n    private static byte[] rsaSplitCodec(Cipher cipher, int opmode, byte[] datas, int keySize) {\n        int maxBlock = 0;  //最大块\n        if (opmode == Cipher.DECRYPT_MODE) {\n            maxBlock = keySize / 8;\n        } else {\n            maxBlock = keySize / 8 - 11;\n        }\n        ByteArrayOutputStream out = new ByteArrayOutputStream();\n        int offSet = 0;\n        byte[] buff;\n        int i = 0;\n        try {\n            while (datas.length &gt; offSet) {\n                if (datas.length - offSet &gt; maxBlock) {\n                    //可以调用以下的doFinal（）方法完成加密或解密数据：\n                    buff = cipher.doFinal(datas, offSet, maxBlock);\n                } else {\n                    buff = cipher.doFinal(datas, offSet, datas.length - offSet);\n                }\n                out.write(buff, 0, buff.length);\n                i++;\n                offSet = i * maxBlock;\n            }\n        } catch (Exception e) {\n            throw new RuntimeException(\"加解密阀值为[\" + maxBlock + \"]的数据时发生异常: \" + e.getMessage());\n        }\n        byte[] resultDatas = out.toByteArray();\n        IOUtils.closeQuietly(out);\n        return resultDatas;\n    }\n}</code></pre><h4>5、AES256Util 工具类</h4><pre><code class=\"language-java\">import org.bouncycastle.jce.provider.BouncyCastleProvider;\nimport javax.crypto.Cipher;\nimport javax.crypto.spec.SecretKeySpec;\nimport java.nio.charset.StandardCharsets;\nimport java.security.Security;\nimport java.util.Base64;\n​\n/**\n * @module\n * @author: qingxu.liu\n * @date: 2023-02-07 16:14\n * @copyright\n **/\n​\npublic class AES256Util {\n​\n    private static final String AES = \"AES\";\n    /**\n     * 初始向量IV, 初始向量IV的长度规定为128位16个字节, 初始向量的来源为随机生成.\n     */\n    /**\n     * 加密解密算法/加密模式/填充方式\n     */\n    private static final String CIPHER_ALGORITHM = \"AES/CBC/PKCS7Padding\";\n​\n    private static final Base64.Encoder base64Encoder = java.util.Base64.getEncoder();\n    private static final Base64.Decoder base64Decoder = java.util.Base64.getDecoder();\n​\n    //通过在运行环境中设置以下属性启用AES-256支持\n    static {\n        Security.setProperty(\"crypto.policy\", \"unlimited\");\n    }\n    /*\n     * 解决java不支持AES/CBC/PKCS7Padding模式解密\n     */\n    static {\n        Security.addProvider(new BouncyCastleProvider());\n    }\n    /**\n     * AES加密\n     */\n    public static String encode(String key, String content,String keyVI) {\n        try {\n            javax.crypto.SecretKey secretKey = new javax.crypto.spec.SecretKeySpec(key.getBytes(), AES);\n            javax.crypto.Cipher cipher = javax.crypto.Cipher.getInstance(CIPHER_ALGORITHM);\n            cipher.init(javax.crypto.Cipher.ENCRYPT_MODE, secretKey, new javax.crypto.spec.IvParameterSpec(keyVI.getBytes()));\n            // 获取加密内容的字节数组(这里要设置为utf-8)不然内容中如果有中文和英文混合中文就会解密为乱码\n            byte[] byteEncode = content.getBytes(java.nio.charset.StandardCharsets.UTF_8);\n            // 根据密码器的初始化方式加密\n            byte[] byteAES = cipher.doFinal(byteEncode);\n            // 将加密后的数据转换为字符串\n            return base64Encoder.encodeToString(byteAES);\n        } catch (Exception e) {\n            e.printStackTrace();\n        }\n        return null;\n    }\n​\n    /**\n     * AES解密\n     */\n    public static String decode(String key, String content,String keyVI) {\n        try {\n            javax.crypto.SecretKey secretKey = new javax.crypto.spec.SecretKeySpec(key.getBytes(), AES);\n            javax.crypto.Cipher cipher = javax.crypto.Cipher.getInstance(CIPHER_ALGORITHM);\n            cipher.init(javax.crypto.Cipher.DECRYPT_MODE, secretKey, new javax.crypto.spec.IvParameterSpec(keyVI.getBytes()));\n            // 将加密并编码后的内容解码成字节数组\n            byte[] byteContent = base64Decoder.decode(content);\n            // 解密\n            byte[] byteDecode = cipher.doFinal(byteContent);\n            return new String(byteDecode, java.nio.charset.StandardCharsets.UTF_8);\n        } catch (Exception e) {\n            e.printStackTrace();\n        }\n        return null;\n    }\n​\n    /**\n     * AES加密ECB模式PKCS7Padding填充方式\n     * @param str 字符串\n     * @param key 密钥\n     * @return 加密字符串\n     * @throws Exception 异常信息\n     */\n    public static String aes256ECBPkcs7PaddingEncrypt(String str, String key) throws Exception {\n        Cipher cipher = Cipher.getInstance(\"AES/ECB/PKCS7Padding\");\n        byte[] keyBytes = key.getBytes(StandardCharsets.UTF_8);\n        cipher.init(Cipher.ENCRYPT_MODE, new SecretKeySpec(keyBytes, AES));\n        byte[] doFinal = cipher.doFinal(str.getBytes(StandardCharsets.UTF_8));\n        return new String(Base64.getEncoder().encode(doFinal));\n    }\n​\n    /**\n     * AES解密ECB模式PKCS7Padding填充方式\n     * @param str 字符串\n     * @param key 密钥\n     * @return 解密字符串\n     * @throws Exception 异常信息\n     */\n    public static String aes256ECBPkcs7PaddingDecrypt(String str, String key) throws Exception {\n        Cipher cipher = Cipher.getInstance(\"AES/ECB/PKCS7Padding\");\n        byte[] keyBytes = key.getBytes(StandardCharsets.UTF_8);\n        cipher.init(Cipher.DECRYPT_MODE, new SecretKeySpec(keyBytes, AES));\n        byte[] doFinal = cipher.doFinal(Base64.getDecoder().decode(str));\n        return new String(doFinal);\n    }\n}\n复制代码</code></pre><p>亲测100%可用~~~</p><p><br></p>', '2023-02-27 01:04:16', '2023-02-27 01:04:16', 'http://localhost:3001/images/common/8e823cca-303a-4024-915e-f4249224a63e.jpeg', 1, NULL);

-- ----------------------------
-- Table structure for cms_article_tag
-- ----------------------------
DROP TABLE IF EXISTS `cms_article_tag`;
CREATE TABLE `cms_article_tag`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `article_id` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '博客ID',
  `tag_id` int UNSIGNED NOT NULL DEFAULT 0 COMMENT '标签ID',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '博客-标签中间表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_article_tag
-- ----------------------------
INSERT INTO `cms_article_tag` VALUES (1, 1, 1);
INSERT INTO `cms_article_tag` VALUES (2, 6, 4);
INSERT INTO `cms_article_tag` VALUES (3, 6, 5);
INSERT INTO `cms_article_tag` VALUES (4, 5, 6);
INSERT INTO `cms_article_tag` VALUES (5, 5, 1);
INSERT INTO `cms_article_tag` VALUES (6, 5, 2);
INSERT INTO `cms_article_tag` VALUES (7, 4, 4);
INSERT INTO `cms_article_tag` VALUES (8, 3, 5);
INSERT INTO `cms_article_tag` VALUES (9, 3, 4);
INSERT INTO `cms_article_tag` VALUES (10, 2, 5);
INSERT INTO `cms_article_tag` VALUES (11, 2, 6);

-- ----------------------------
-- Table structure for cms_category
-- ----------------------------
DROP TABLE IF EXISTS `cms_category`;
CREATE TABLE `cms_category`  (
  `cate_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '分类id',
  `cate_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '分类名称',
  `parent_id` int NOT NULL COMMENT '父级id',
  `create_date` datetime NOT NULL COMMENT '创建时间',
  `update_date` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`cate_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 12 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '分类表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_category
-- ----------------------------
INSERT INTO `cms_category` VALUES (1, '科技', 0, '2022-10-11 10:53:20', '2022-10-11 10:53:22');
INSERT INTO `cms_category` VALUES (2, '娱乐', 0, '2022-10-11 10:53:23', '2022-10-11 10:53:25');
INSERT INTO `cms_category` VALUES (3, '摄影', 2, '2022-10-11 10:53:26', '2022-10-11 10:53:28');
INSERT INTO `cms_category` VALUES (4, '电影', 2, '2022-10-11 10:53:29', '2022-10-11 10:53:31');
INSERT INTO `cms_category` VALUES (5, '人工智能', 1, '2022-10-11 10:53:32', '2022-10-11 10:53:34');
INSERT INTO `cms_category` VALUES (6, '黑客技术', 1, '2022-10-11 10:53:34', '2022-10-11 10:53:36');
INSERT INTO `cms_category` VALUES (7, '编程', 0, '2022-10-11 10:53:37', '2022-10-11 10:53:39');
INSERT INTO `cms_category` VALUES (8, '前端', 7, '2022-10-11 10:53:40', '2022-10-11 10:53:41');
INSERT INTO `cms_category` VALUES (9, 'JAVA', 7, '2022-10-11 10:53:42', '2022-10-11 10:53:44');
INSERT INTO `cms_category` VALUES (10, 'PHP', 7, '2022-10-11 10:53:45', '2022-10-11 10:53:46');
INSERT INTO `cms_category` VALUES (11, 'IT新闻', 2, '2022-10-11 10:53:47', '2022-10-11 10:53:50');

-- ----------------------------
-- Table structure for cms_comment
-- ----------------------------
DROP TABLE IF EXISTS `cms_comment`;
CREATE TABLE `cms_comment`  (
  `comment_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL COMMENT '用户id',
  `article_id` int NOT NULL COMMENT '文章id',
  `content` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '评论内容',
  `reply` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '回复内容',
  `is_visible` tinyint NOT NULL DEFAULT 1 COMMENT '是否显示，（-1-否, 1-是）',
  `is_reply` tinyint NOT NULL DEFAULT 0 COMMENT '是否回复，（0否, 1是）',
  `is_read` tinyint NOT NULL DEFAULT 0 COMMENT '是否已读，（0否, 1是）',
  `reply_date` datetime NULL DEFAULT NULL COMMENT '回复时间',
  `create_date` datetime NOT NULL COMMENT '创建时间',
  `update_date` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`comment_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '评论表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_comment
-- ----------------------------
INSERT INTO `cms_comment` VALUES (1, 1, 1, '宝贝宝贝', '反对战争', 1, 1, 0, '2023-02-27 01:27:25', '2022-03-09 00:07:22', '2023-02-27 01:27:25');
INSERT INTO `cms_comment` VALUES (2, 1, 1, '呜呜呜呜', '喜剧演员', -1, 1, 0, '2023-02-27 01:27:04', '2022-03-17 23:38:41', '2023-02-27 01:27:04');
INSERT INTO `cms_comment` VALUES (3, 1, 2, '破哦哦哦哦哦哦哦哦哦', NULL, 1, 0, 0, NULL, '2022-03-17 23:40:14', '2023-02-27 01:25:59');

-- ----------------------------
-- Table structure for cms_link
-- ----------------------------
DROP TABLE IF EXISTS `cms_link`;
CREATE TABLE `cms_link`  (
  `link_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标题',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跳转的url',
  `link_order` int NULL DEFAULT NULL COMMENT '排序',
  `usable` tinyint NULL DEFAULT 1 COMMENT '状态,1-正常，-1-禁用',
  `create_date` datetime NOT NULL COMMENT '创建日期',
  `update_date` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改日期',
  PRIMARY KEY (`link_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '友情链接表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_link
-- ----------------------------
INSERT INTO `cms_link` VALUES (1, '苦瓜甘甜', 'https://www.kuguagantian.com/', 1, 1, '2022-05-04 23:26:02', '2022-05-04 23:30:51');
INSERT INTO `cms_link` VALUES (2, '优设网', 'https://www.uisdc.com/', 2, 1, '2022-05-04 23:31:34', '2022-10-23 09:31:23');
INSERT INTO `cms_link` VALUES (3, '站酷', 'https://www.zcool.com.cn/', 3, -1, '2022-05-04 23:32:58', '2022-09-26 17:06:21');

-- ----------------------------
-- Table structure for cms_notice
-- ----------------------------
DROP TABLE IF EXISTS `cms_notice`;
CREATE TABLE `cms_notice`  (
  `notice_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公告标题',
  `content` varchar(8000) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '公告内容',
  `create_date` datetime NOT NULL COMMENT '创建时间',
  `update_date` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '编辑时间',
  `is_sticky` tinyint NOT NULL DEFAULT 0 COMMENT '是否置顶，1-置顶，0-正常',
  PRIMARY KEY (`notice_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '公告表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_notice
-- ----------------------------
INSERT INTO `cms_notice` VALUES (1, '桃花诗', '<p style=\"text-align:center;\">《桃花诗》</p><p style=\"text-align:center;\">&nbsp;明.唐寅</p><p style=\"text-align:center;\">桃花坞里桃花庵，桃花庵下桃花仙。</p><p style=\"text-align:center;\">桃花仙人种桃树，又折花枝当酒钱。</p><p style=\"text-align:center;\">酒醒只在花前坐，酒醉还须花下眠。</p><p style=\"text-align:center;\">花前花后日复日，酒醉酒醒年复年。</p><p style=\"text-align:center;\">不愿鞠躬车马前，但愿老死花酒间。</p><p style=\"text-align:center;\">&nbsp;车尘马足贵者趣，酒盏花枝贫者缘。</p><p style=\"text-align:center;\">若将富贵比贫贱，一在平地一在天。</p><p style=\"text-align:center;\">若将贫贱比车马，他得驱驰我得闲。</p><p style=\"text-align:center;\">世人笑我忒疯癫，我笑世人看不穿。</p><p style=\"text-align:center;\">记得五陵豪杰墓，无酒无花锄作田。</p>', '2022-03-06 16:37:01', '2022-10-23 09:19:45', 1);
INSERT INTO `cms_notice` VALUES (2, '登鹳雀楼', '<p>白日依山尽，黄河入海流。<br>欲穷千里目，更上一层楼。</p>', '2022-03-06 16:38:59', '2022-10-23 09:19:43', 0);
INSERT INTO `cms_notice` VALUES (3, '江雪', '<p style=\"text-align: center;\">千山鸟飞绝，万径人踪灭。<br></p><p style=\"text-align: center;\">孤舟蓑笠翁，独钓寒江雪。</p>', '2022-03-06 16:39:48', '2023-03-02 00:24:36', 0);
INSERT INTO `cms_notice` VALUES (4, '大淘宝技术2022技术年货来了！《2022技术人的百宝黑皮书》电子书公开下载', '<p style=\"text-align: start;\">新年好！岁末年初，温故而知新。<br>过去一年，我们尝试在分享的过程中，对自己做过的工作进行系统性的总结和提炼，升华自己对技术深度的理解；更希望能够与同行交流互动，共同关注业务的差异性、技术思考的不同路径、技术的困难挑战以及对未来的思考，彼此成就，共同成长。<br>基于此，我们将一整年的精华内容梳理合并，重磅推出大淘宝技术年货《2022技术人的百宝黑皮书》。<br>在2022年的技术年货中，你将看到以下内容——<br>一、大淘宝各技术栈工程师重新定义和解决问题，分享消费点滴改变背后的技术深意<br>二、大淘宝技术工程师们的成长经验沉淀，从幼稚到成熟，就是从不负责任到承担责任的过程<br>三、50 余位工程师推荐学习的GitHub项目，入门级经典库or框架，勤学勤练共同成长<br>四、2022大淘宝技术顶会 paper 全文，窥见相关领域下一步最新方向</p><p style=\"text-align: start;\">电子书目录内容展示（部分）</p><p style=\"text-align: start;\">第一部分 年度精选技术栈内容<br>终端技术篇<br>● 技术经典总结：<br>○ 内存优化: 纹理压缩技术<br>○ 移动域全链路可观测架构和关键技术<br>○ 性能优化之接口优化<br>○ APM 页面加载耗时校准<br>○ 19条跨端cpp开发有效经验总结<br>○ 下一代响应式Web设计：组件驱动式Web设计<br>○ Flutter 新一代图形渲染器 Impeller<br>○ HTTPS的原理浅析与本地开发实践<br>○ 无代码生产新模式探索<br>○ HTTP3 RFC标准正式发布，QUIC会成为传输技术的新一代颠覆者吗？<br>● 相关业务实践：<br>○ 淘宝购物车5年客户端技术升级与沉淀<br>○ 淘宝长辈模式客户端技术实践万字总结<br>○ 打造淘宝极简包的轻量化框架<br>○ 我在淘宝做弹窗，2022 年初的回顾与展望<br>● 年度经典专题：<br>○ 跨全端SDK技术演进<br>○ 跨桌面端Web容器演进<br>○ 跨桌面端之组件化实践</p><p style=\"text-align: start;\">服务端技术篇<br>● 技术经典总结：<br>○ 合理使用线程池以及线程变量<br>○ mysql锁机制的再研究<br>○ 数据库存储选型经验总结<br>○ 开发规约的意义与细则<br>○ 如何避免写重复代码：善用抽象和组合<br>○ MapStruct，降低无用代码的神器<br>○ 一个搞定责任链的注解<br>○ stream的实用方法和注意事项<br>○ 响应式编程的复杂度和简化<br>○ 一种可灰度的接口迁移方案<br>● 相关业务实践：<br>○ 谈一谈凑单页的那些优雅系统设计<br>○ 大淘宝用户平台技术团队单元测试建设<br>○ 淘宝扫一扫架构升级 - 设计模式的应用</p><p style=\"text-align: start;\">另还有【3DXR技术篇】【数据算法篇】【音视频与图像技术篇】【技术质量篇】等篇章内容待你下载全本内容解锁。</p><p style=\"text-align: start;\"><img src=\"https://segmentfault.com/img/bVc5LCW\" alt=\"\" data-href=\"\" style=\"\"></p><p style=\"text-align: start;\">——如何下载——<br>点击【报名参加】进入《2022技术人的百宝黑皮书》下载页面，即可获得电子书全本内容</p>', '2023-03-02 00:23:56', '2023-03-02 00:23:56', 1);

-- ----------------------------
-- Table structure for cms_slide
-- ----------------------------
DROP TABLE IF EXISTS `cms_slide`;
CREATE TABLE `cms_slide`  (
  `slide_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '标题',
  `picture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '图片地址',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '跳转的url',
  `target` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT '_blank' COMMENT '跳转方式，_blank，_self',
  `slide_order` int NULL DEFAULT NULL COMMENT '排序',
  `usable` tinyint NULL DEFAULT 1 COMMENT '状态,1-正常，-1-禁用',
  `create_date` datetime NOT NULL COMMENT '创建日期',
  `update_date` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改日期',
  PRIMARY KEY (`slide_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 4 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '轮播图表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_slide
-- ----------------------------
INSERT INTO `cms_slide` VALUES (1, '1', 'http://localhost:3001/images/common/4cb37c20-b42a-11ec-9686-9534ec65c3ac.jpeg', 'http://www.test.com/', '_blank', 1, 1, '2022-04-04 23:36:36', '2022-04-07 01:59:22');
INSERT INTO `cms_slide` VALUES (2, '测试标题', 'http://localhost:3001/images/common/2647d170-b435-11ec-a1e0-9ff51000691e.jpeg', 'http://www.123.com', '_blank', 2, -1, '2022-04-05 00:35:14', '2023-03-02 00:52:52');
INSERT INTO `cms_slide` VALUES (3, 'test', 'http://localhost:3001/images/common/14858e90-b43b-11ec-8b84-0b17af77884d.jpeg', 'http://www.vote.com', '_self', 3, 1, '2022-04-05 01:18:03', '2022-10-23 09:30:23');

-- ----------------------------
-- Table structure for cms_tag
-- ----------------------------
DROP TABLE IF EXISTS `cms_tag`;
CREATE TABLE `cms_tag`  (
  `tag_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `tag_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `create_date` datetime NOT NULL COMMENT '创建日期',
  `update_date` datetime NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '修改日期',
  PRIMARY KEY (`tag_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 7 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '标签表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_tag
-- ----------------------------
INSERT INTO `cms_tag` VALUES (1, 'Web前端', '2023-02-27 10:17:49', '2023-02-27 10:17:51');
INSERT INTO `cms_tag` VALUES (2, '后台编程', '2023-02-27 10:17:52', '2023-02-27 10:17:54');
INSERT INTO `cms_tag` VALUES (3, '数据库', '2023-02-27 10:17:55', '2023-02-27 10:17:56');
INSERT INTO `cms_tag` VALUES (4, 'Javascript', '2023-02-27 10:17:57', '2023-02-27 10:17:59');
INSERT INTO `cms_tag` VALUES (5, 'CSS3', '2023-02-27 10:18:00', '2023-02-27 10:18:02');
INSERT INTO `cms_tag` VALUES (6, 'UI设计', '2023-02-27 10:18:02', '2023-02-27 10:18:45');

-- ----------------------------
-- Table structure for cms_user
-- ----------------------------
DROP TABLE IF EXISTS `cms_user`;
CREATE TABLE `cms_user`  (
  `user_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '密码',
  `nickname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `sex` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '男' COMMENT '性别',
  `tel` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '手机号码',
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '头像',
  `usable` tinyint NOT NULL DEFAULT 1 COMMENT '状态，1-正常，-1-禁用',
  `jwt_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'jwt_id',
  `refresh_token` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '刷新token',
  `create_date` datetime NOT NULL COMMENT '创建时间',
  `login_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '博客用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of cms_user
-- ----------------------------
INSERT INTO `cms_user` VALUES (1, 'papi', '123', 'papi酱', '女', '13475829262', 'nn880328@126.com', 'http://localhost:3001/images/avatar/default.jpg', 1, 'c0d09f86-bced-4495-ae22-8163ea17639a', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTY3NzcyMzU1MywiZXhwIjoxNjgwMzE1NTUzLCJqdGkiOiJjMGQwOWY4Ni1iY2VkLTQ0OTUtYWUyMi04MTYzZWExNzYzOWEifQ.AvJBLo5HDN-7H06K4SOb8VILKGSWivU5tXxK2I9xrcQ', '2016-06-25 23:15:13', '2023-03-02 10:19:13');
INSERT INTO `cms_user` VALUES (2, 'moz', '123', '夏目友人帐', '女', '13475829262', 'nn880328@126.com', 'http://localhost:3001/images/avatar/default.jpg', 1, '676c3639-dfe9-4859-bf2d-bd1fe14d8557', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTY3NzcyNDIzMiwiZXhwIjoxNjgwMzE2MjMyLCJqdGkiOiI2NzZjMzYzOS1kZmU5LTQ4NTktYmYyZC1iZDFmZTE0ZDg1NTcifQ.U47dH7tYN6-NdIUOyTQsthGcuLBX7boYxy3dI2m0jFk', '2019-11-08 23:15:38', '2023-03-02 10:30:32');
INSERT INTO `cms_user` VALUES (3, 'sky', '123', '乌鸦校尉', '男', '15863008280', 'nn880328@126.com', 'http://localhost:3001/images/avatar/default.jpg', -1, NULL, NULL, '2020-06-22 12:58:58', '2022-10-11 16:20:03');
INSERT INTO `cms_user` VALUES (4, 'orz', '123', '咸鱼', '男', '13475829262', 'nn880328@126.com', 'http://localhost:3001/images/avatar/default.jpg', 0, 'be808ed3-88e1-439f-ae47-576767fb9335', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTY3NzcyNDI1MSwiZXhwIjoxNjgwMzE2MjUxLCJqdGkiOiJiZTgwOGVkMy04OGUxLTQzOWYtYWU0Ny01NzY3NjdmYjkzMzUifQ.xsAgSnCtT21jmXBc_hZMxXR3kBqKX19kLUMZmk3eCjA', '2022-07-07 23:16:39', '2023-03-02 10:30:52');
INSERT INTO `cms_user` VALUES (5, 'test', '123', 'test', '男', '13475829262', NULL, 'http://localhost:3001/images/avatar/default.jpg', 1, '12b8299b-c82e-4c35-a7cf-bb189291c0f4', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTY3NzcyNDIyMCwiZXhwIjoxNjgwMzE2MjIwLCJqdGkiOiIxMmI4Mjk5Yi1jODJlLTRjMzUtYTdjZi1iYjE4OTI5MWMwZjQifQ.gqoPln8v4Fsz1vw-pryHgpz3sMzkjKILoxLZZ-4d5-Q', '2022-10-11 16:16:57', '2023-03-02 10:30:20');

-- ----------------------------
-- Table structure for sys_element
-- ----------------------------
DROP TABLE IF EXISTS `sys_element`;
CREATE TABLE `sys_element`  (
  `element_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `element_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '页面元素编码',
  PRIMARY KEY (`element_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '页面元素表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_element
-- ----------------------------

-- ----------------------------
-- Table structure for sys_icon
-- ----------------------------
DROP TABLE IF EXISTS `sys_icon`;
CREATE TABLE `sys_icon`  (
  `icon_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `icon_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '图标名称',
  PRIMARY KEY (`icon_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 281 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '系统图标' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_icon
-- ----------------------------
INSERT INTO `sys_icon` VALUES (1, 'platform-eleme');
INSERT INTO `sys_icon` VALUES (2, 'eleme');
INSERT INTO `sys_icon` VALUES (3, 'delete-solid');
INSERT INTO `sys_icon` VALUES (4, 'delete');
INSERT INTO `sys_icon` VALUES (5, 's-tools');
INSERT INTO `sys_icon` VALUES (6, 'setting');
INSERT INTO `sys_icon` VALUES (7, 'user-solid');
INSERT INTO `sys_icon` VALUES (8, 'user');
INSERT INTO `sys_icon` VALUES (9, 'phone');
INSERT INTO `sys_icon` VALUES (10, 'phone-outline');
INSERT INTO `sys_icon` VALUES (11, 'more');
INSERT INTO `sys_icon` VALUES (12, 'more-outline');
INSERT INTO `sys_icon` VALUES (13, 'star-on');
INSERT INTO `sys_icon` VALUES (14, 'star-off');
INSERT INTO `sys_icon` VALUES (15, 's-goods');
INSERT INTO `sys_icon` VALUES (16, 'goods');
INSERT INTO `sys_icon` VALUES (17, 'warning');
INSERT INTO `sys_icon` VALUES (18, 'warning-outline');
INSERT INTO `sys_icon` VALUES (19, 'question');
INSERT INTO `sys_icon` VALUES (20, 'info');
INSERT INTO `sys_icon` VALUES (21, 'remove');
INSERT INTO `sys_icon` VALUES (22, 'circle-plus');
INSERT INTO `sys_icon` VALUES (23, 'success');
INSERT INTO `sys_icon` VALUES (24, 'error');
INSERT INTO `sys_icon` VALUES (25, 'zoom-in');
INSERT INTO `sys_icon` VALUES (26, 'zoom-out');
INSERT INTO `sys_icon` VALUES (27, 'remove-outline');
INSERT INTO `sys_icon` VALUES (28, 'circle-plus-outline');
INSERT INTO `sys_icon` VALUES (29, 'circle-check');
INSERT INTO `sys_icon` VALUES (30, 'circle-close');
INSERT INTO `sys_icon` VALUES (31, 's-help');
INSERT INTO `sys_icon` VALUES (32, 'help');
INSERT INTO `sys_icon` VALUES (33, 'minus');
INSERT INTO `sys_icon` VALUES (34, 'plus');
INSERT INTO `sys_icon` VALUES (35, 'check');
INSERT INTO `sys_icon` VALUES (36, 'close');
INSERT INTO `sys_icon` VALUES (37, 'picture');
INSERT INTO `sys_icon` VALUES (38, 'picture-outline');
INSERT INTO `sys_icon` VALUES (39, 'picture-outline-round');
INSERT INTO `sys_icon` VALUES (40, 'upload');
INSERT INTO `sys_icon` VALUES (41, 'upload2');
INSERT INTO `sys_icon` VALUES (42, 'download');
INSERT INTO `sys_icon` VALUES (43, 'camera-solid');
INSERT INTO `sys_icon` VALUES (44, 'camera');
INSERT INTO `sys_icon` VALUES (45, 'video-camera-solid');
INSERT INTO `sys_icon` VALUES (46, 'video-camera');
INSERT INTO `sys_icon` VALUES (47, 'message-solid');
INSERT INTO `sys_icon` VALUES (48, 'bell');
INSERT INTO `sys_icon` VALUES (49, 's-cooperation');
INSERT INTO `sys_icon` VALUES (50, 's-order');
INSERT INTO `sys_icon` VALUES (51, 's-platform');
INSERT INTO `sys_icon` VALUES (52, 's-fold');
INSERT INTO `sys_icon` VALUES (53, 's-unfold');
INSERT INTO `sys_icon` VALUES (54, 's-operation');
INSERT INTO `sys_icon` VALUES (55, 's-promotion');
INSERT INTO `sys_icon` VALUES (56, 's-home');
INSERT INTO `sys_icon` VALUES (57, 's-release');
INSERT INTO `sys_icon` VALUES (58, 's-ticket');
INSERT INTO `sys_icon` VALUES (59, 's-management');
INSERT INTO `sys_icon` VALUES (60, 's-open');
INSERT INTO `sys_icon` VALUES (61, 's-shop');
INSERT INTO `sys_icon` VALUES (62, 's-marketing');
INSERT INTO `sys_icon` VALUES (63, 's-flag');
INSERT INTO `sys_icon` VALUES (64, 's-comment');
INSERT INTO `sys_icon` VALUES (65, 's-finance');
INSERT INTO `sys_icon` VALUES (66, 's-claim');
INSERT INTO `sys_icon` VALUES (67, 's-custom');
INSERT INTO `sys_icon` VALUES (68, 's-opportunity');
INSERT INTO `sys_icon` VALUES (69, 's-data');
INSERT INTO `sys_icon` VALUES (70, 's-check');
INSERT INTO `sys_icon` VALUES (71, 's-grid');
INSERT INTO `sys_icon` VALUES (72, 'menu');
INSERT INTO `sys_icon` VALUES (73, 'share');
INSERT INTO `sys_icon` VALUES (74, 'd-caret');
INSERT INTO `sys_icon` VALUES (75, 'caret-left');
INSERT INTO `sys_icon` VALUES (76, 'caret-right');
INSERT INTO `sys_icon` VALUES (77, 'caret-bottom');
INSERT INTO `sys_icon` VALUES (78, 'caret-top');
INSERT INTO `sys_icon` VALUES (79, 'bottom-left');
INSERT INTO `sys_icon` VALUES (80, 'bottom-right');
INSERT INTO `sys_icon` VALUES (81, 'back');
INSERT INTO `sys_icon` VALUES (82, 'right');
INSERT INTO `sys_icon` VALUES (83, 'bottom');
INSERT INTO `sys_icon` VALUES (84, 'top');
INSERT INTO `sys_icon` VALUES (85, 'top-left');
INSERT INTO `sys_icon` VALUES (86, 'top-right');
INSERT INTO `sys_icon` VALUES (87, 'arrow-left');
INSERT INTO `sys_icon` VALUES (88, 'arrow-right');
INSERT INTO `sys_icon` VALUES (89, 'arrow-down');
INSERT INTO `sys_icon` VALUES (90, 'arrow-up');
INSERT INTO `sys_icon` VALUES (91, 'd-arrow-left');
INSERT INTO `sys_icon` VALUES (92, 'd-arrow-right');
INSERT INTO `sys_icon` VALUES (93, 'video-pause');
INSERT INTO `sys_icon` VALUES (94, 'video-play');
INSERT INTO `sys_icon` VALUES (95, 'refresh');
INSERT INTO `sys_icon` VALUES (96, 'refresh-right');
INSERT INTO `sys_icon` VALUES (97, 'refresh-left');
INSERT INTO `sys_icon` VALUES (98, 'finished');
INSERT INTO `sys_icon` VALUES (99, 'sort');
INSERT INTO `sys_icon` VALUES (100, 'sort-up');
INSERT INTO `sys_icon` VALUES (101, 'sort-down');
INSERT INTO `sys_icon` VALUES (102, 'rank');
INSERT INTO `sys_icon` VALUES (103, 'loading');
INSERT INTO `sys_icon` VALUES (104, 'view');
INSERT INTO `sys_icon` VALUES (105, 'c-scale-to-original');
INSERT INTO `sys_icon` VALUES (106, 'date');
INSERT INTO `sys_icon` VALUES (107, 'edit');
INSERT INTO `sys_icon` VALUES (108, 'edit-outline');
INSERT INTO `sys_icon` VALUES (109, 'folder');
INSERT INTO `sys_icon` VALUES (110, 'folder-opened');
INSERT INTO `sys_icon` VALUES (111, 'folder-add');
INSERT INTO `sys_icon` VALUES (112, 'folder-remove');
INSERT INTO `sys_icon` VALUES (113, 'folder-delete');
INSERT INTO `sys_icon` VALUES (114, 'folder-checked');
INSERT INTO `sys_icon` VALUES (115, 'tickets');
INSERT INTO `sys_icon` VALUES (116, 'document-remove');
INSERT INTO `sys_icon` VALUES (117, 'document-delete');
INSERT INTO `sys_icon` VALUES (118, 'document-copy');
INSERT INTO `sys_icon` VALUES (119, 'document-checked');
INSERT INTO `sys_icon` VALUES (120, 'document');
INSERT INTO `sys_icon` VALUES (121, 'document-add');
INSERT INTO `sys_icon` VALUES (122, 'printer');
INSERT INTO `sys_icon` VALUES (123, 'paperclip');
INSERT INTO `sys_icon` VALUES (124, 'takeaway-box');
INSERT INTO `sys_icon` VALUES (125, 'search');
INSERT INTO `sys_icon` VALUES (126, 'monitor');
INSERT INTO `sys_icon` VALUES (127, 'attract');
INSERT INTO `sys_icon` VALUES (128, 'mobile');
INSERT INTO `sys_icon` VALUES (129, 'scissors');
INSERT INTO `sys_icon` VALUES (130, 'umbrella');
INSERT INTO `sys_icon` VALUES (131, 'headset');
INSERT INTO `sys_icon` VALUES (132, 'brush');
INSERT INTO `sys_icon` VALUES (133, 'mouse');
INSERT INTO `sys_icon` VALUES (134, 'coordinate');
INSERT INTO `sys_icon` VALUES (135, 'magic-stick');
INSERT INTO `sys_icon` VALUES (136, 'reading');
INSERT INTO `sys_icon` VALUES (137, 'data-line');
INSERT INTO `sys_icon` VALUES (138, 'data-board');
INSERT INTO `sys_icon` VALUES (139, 'pie-chart');
INSERT INTO `sys_icon` VALUES (140, 'data-analysis');
INSERT INTO `sys_icon` VALUES (141, 'collection-tag');
INSERT INTO `sys_icon` VALUES (142, 'film');
INSERT INTO `sys_icon` VALUES (143, 'suitcase');
INSERT INTO `sys_icon` VALUES (144, 'suitcase-1');
INSERT INTO `sys_icon` VALUES (145, 'receiving');
INSERT INTO `sys_icon` VALUES (146, 'collection');
INSERT INTO `sys_icon` VALUES (147, 'files');
INSERT INTO `sys_icon` VALUES (148, 'notebook-1');
INSERT INTO `sys_icon` VALUES (149, 'notebook-2');
INSERT INTO `sys_icon` VALUES (150, 'toilet-paper');
INSERT INTO `sys_icon` VALUES (151, 'office-building');
INSERT INTO `sys_icon` VALUES (152, 'school');
INSERT INTO `sys_icon` VALUES (153, 'table-lamp');
INSERT INTO `sys_icon` VALUES (154, 'house');
INSERT INTO `sys_icon` VALUES (155, 'no-smoking');
INSERT INTO `sys_icon` VALUES (156, 'smoking');
INSERT INTO `sys_icon` VALUES (157, 'shopping-cart-full');
INSERT INTO `sys_icon` VALUES (158, 'shopping-cart-1');
INSERT INTO `sys_icon` VALUES (159, 'shopping-cart-2');
INSERT INTO `sys_icon` VALUES (160, 'shopping-bag-1');
INSERT INTO `sys_icon` VALUES (161, 'shopping-bag-2');
INSERT INTO `sys_icon` VALUES (162, 'sold-out');
INSERT INTO `sys_icon` VALUES (163, 'sell');
INSERT INTO `sys_icon` VALUES (164, 'present');
INSERT INTO `sys_icon` VALUES (165, 'box');
INSERT INTO `sys_icon` VALUES (166, 'bank-card');
INSERT INTO `sys_icon` VALUES (167, 'money');
INSERT INTO `sys_icon` VALUES (168, 'coin');
INSERT INTO `sys_icon` VALUES (169, 'wallet');
INSERT INTO `sys_icon` VALUES (170, 'discount');
INSERT INTO `sys_icon` VALUES (171, 'price-tag');
INSERT INTO `sys_icon` VALUES (172, 'news');
INSERT INTO `sys_icon` VALUES (173, 'guide');
INSERT INTO `sys_icon` VALUES (174, 'male');
INSERT INTO `sys_icon` VALUES (175, 'female');
INSERT INTO `sys_icon` VALUES (176, 'thumb');
INSERT INTO `sys_icon` VALUES (177, 'cpu');
INSERT INTO `sys_icon` VALUES (178, 'link');
INSERT INTO `sys_icon` VALUES (179, 'connection');
INSERT INTO `sys_icon` VALUES (180, 'open');
INSERT INTO `sys_icon` VALUES (181, 'turn-off');
INSERT INTO `sys_icon` VALUES (182, 'set-up');
INSERT INTO `sys_icon` VALUES (183, 'chat-round');
INSERT INTO `sys_icon` VALUES (184, 'chat-line-round');
INSERT INTO `sys_icon` VALUES (185, 'chat-square');
INSERT INTO `sys_icon` VALUES (186, 'chat-dot-round');
INSERT INTO `sys_icon` VALUES (187, 'chat-dot-square');
INSERT INTO `sys_icon` VALUES (188, 'chat-line-square');
INSERT INTO `sys_icon` VALUES (189, 'message');
INSERT INTO `sys_icon` VALUES (190, 'postcard');
INSERT INTO `sys_icon` VALUES (191, 'position');
INSERT INTO `sys_icon` VALUES (192, 'turn-off-microphone');
INSERT INTO `sys_icon` VALUES (193, 'microphone');
INSERT INTO `sys_icon` VALUES (194, 'close-notification');
INSERT INTO `sys_icon` VALUES (195, 'bangzhu');
INSERT INTO `sys_icon` VALUES (196, 'time');
INSERT INTO `sys_icon` VALUES (197, 'odometer');
INSERT INTO `sys_icon` VALUES (198, 'crop');
INSERT INTO `sys_icon` VALUES (199, 'aim');
INSERT INTO `sys_icon` VALUES (200, 'switch-button');
INSERT INTO `sys_icon` VALUES (201, 'full-screen');
INSERT INTO `sys_icon` VALUES (202, 'copy-document');
INSERT INTO `sys_icon` VALUES (203, 'mic');
INSERT INTO `sys_icon` VALUES (204, 'stopwatch');
INSERT INTO `sys_icon` VALUES (205, 'medal-1');
INSERT INTO `sys_icon` VALUES (206, 'medal');
INSERT INTO `sys_icon` VALUES (207, 'trophy');
INSERT INTO `sys_icon` VALUES (208, 'trophy-1');
INSERT INTO `sys_icon` VALUES (209, 'first-aid-kit');
INSERT INTO `sys_icon` VALUES (210, 'discover');
INSERT INTO `sys_icon` VALUES (211, 'place');
INSERT INTO `sys_icon` VALUES (212, 'location');
INSERT INTO `sys_icon` VALUES (213, 'location-outline');
INSERT INTO `sys_icon` VALUES (214, 'location-information');
INSERT INTO `sys_icon` VALUES (215, 'add-location');
INSERT INTO `sys_icon` VALUES (216, 'delete-location');
INSERT INTO `sys_icon` VALUES (217, 'map-location');
INSERT INTO `sys_icon` VALUES (218, 'alarm-clock');
INSERT INTO `sys_icon` VALUES (219, 'timer');
INSERT INTO `sys_icon` VALUES (220, 'watch-1');
INSERT INTO `sys_icon` VALUES (221, 'watch');
INSERT INTO `sys_icon` VALUES (222, 'lock');
INSERT INTO `sys_icon` VALUES (223, 'unlock');
INSERT INTO `sys_icon` VALUES (224, 'key');
INSERT INTO `sys_icon` VALUES (225, 'service');
INSERT INTO `sys_icon` VALUES (226, 'mobile-phone');
INSERT INTO `sys_icon` VALUES (227, 'bicycle');
INSERT INTO `sys_icon` VALUES (228, 'truck');
INSERT INTO `sys_icon` VALUES (229, 'ship');
INSERT INTO `sys_icon` VALUES (230, 'basketball');
INSERT INTO `sys_icon` VALUES (231, 'football');
INSERT INTO `sys_icon` VALUES (232, 'soccer');
INSERT INTO `sys_icon` VALUES (233, 'baseball');
INSERT INTO `sys_icon` VALUES (234, 'wind-power');
INSERT INTO `sys_icon` VALUES (235, 'light-rain');
INSERT INTO `sys_icon` VALUES (236, 'lightning');
INSERT INTO `sys_icon` VALUES (237, 'heavy-rain');
INSERT INTO `sys_icon` VALUES (238, 'sunrise');
INSERT INTO `sys_icon` VALUES (239, 'sunrise-1');
INSERT INTO `sys_icon` VALUES (240, 'sunset');
INSERT INTO `sys_icon` VALUES (241, 'sunny');
INSERT INTO `sys_icon` VALUES (242, 'cloudy');
INSERT INTO `sys_icon` VALUES (243, 'partly-cloudy');
INSERT INTO `sys_icon` VALUES (244, 'cloudy-and-sunny');
INSERT INTO `sys_icon` VALUES (245, 'moon');
INSERT INTO `sys_icon` VALUES (246, 'moon-night');
INSERT INTO `sys_icon` VALUES (247, 'dish');
INSERT INTO `sys_icon` VALUES (248, 'dish-1');
INSERT INTO `sys_icon` VALUES (249, 'food');
INSERT INTO `sys_icon` VALUES (250, 'chicken');
INSERT INTO `sys_icon` VALUES (251, 'fork-spoon');
INSERT INTO `sys_icon` VALUES (252, 'knife-fork');
INSERT INTO `sys_icon` VALUES (253, 'burger');
INSERT INTO `sys_icon` VALUES (254, 'tableware');
INSERT INTO `sys_icon` VALUES (255, 'sugar');
INSERT INTO `sys_icon` VALUES (256, 'dessert');
INSERT INTO `sys_icon` VALUES (257, 'ice-cream');
INSERT INTO `sys_icon` VALUES (258, 'hot-water');
INSERT INTO `sys_icon` VALUES (259, 'water-cup');
INSERT INTO `sys_icon` VALUES (260, 'coffee-cup');
INSERT INTO `sys_icon` VALUES (261, 'cold-drink');
INSERT INTO `sys_icon` VALUES (262, 'goblet');
INSERT INTO `sys_icon` VALUES (263, 'goblet-full');
INSERT INTO `sys_icon` VALUES (264, 'goblet-square');
INSERT INTO `sys_icon` VALUES (265, 'goblet-square-full');
INSERT INTO `sys_icon` VALUES (266, 'refrigerator');
INSERT INTO `sys_icon` VALUES (267, 'grape');
INSERT INTO `sys_icon` VALUES (268, 'watermelon');
INSERT INTO `sys_icon` VALUES (269, 'cherry');
INSERT INTO `sys_icon` VALUES (270, 'apple');
INSERT INTO `sys_icon` VALUES (271, 'pear');
INSERT INTO `sys_icon` VALUES (272, 'orange');
INSERT INTO `sys_icon` VALUES (273, 'coffee');
INSERT INTO `sys_icon` VALUES (274, 'ice-tea');
INSERT INTO `sys_icon` VALUES (275, 'ice-drink');
INSERT INTO `sys_icon` VALUES (276, 'milk-tea');
INSERT INTO `sys_icon` VALUES (277, 'potato-strips');
INSERT INTO `sys_icon` VALUES (278, 'lollipop');
INSERT INTO `sys_icon` VALUES (279, 'ice-cream-square');
INSERT INTO `sys_icon` VALUES (280, 'ice-cream-round');

-- ----------------------------
-- Table structure for sys_menu
-- ----------------------------
DROP TABLE IF EXISTS `sys_menu`;
CREATE TABLE `sys_menu`  (
  `menu_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '菜单id',
  `menu_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '菜单名称',
  `route_id` int UNSIGNED NULL DEFAULT NULL COMMENT '路由id',
  `menu_order` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '显示顺序',
  `icon_id` int NULL DEFAULT NULL COMMENT '图标id',
  PRIMARY KEY (`menu_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '菜单表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_menu
-- ----------------------------
INSERT INTO `sys_menu` VALUES (1, '信息面板', NULL, '2000', 139);
INSERT INTO `sys_menu` VALUES (2, '文章管理', NULL, '3000', 172);
INSERT INTO `sys_menu` VALUES (3, '发布文章', 2, '3001', 121);
INSERT INTO `sys_menu` VALUES (4, '文章列表', 3, '3002', 149);
INSERT INTO `sys_menu` VALUES (5, '标签管理', 6, '3003', 171);
INSERT INTO `sys_menu` VALUES (6, '评论管理', 8, '3004', 188);
INSERT INTO `sys_menu` VALUES (7, '分类管理', 10, '4000', 140);
INSERT INTO `sys_menu` VALUES (8, '公告管理', NULL, '5000', 138);
INSERT INTO `sys_menu` VALUES (9, '发布公告', 13, '5001', 106);
INSERT INTO `sys_menu` VALUES (10, '公告列表', 12, '5002', 140);
INSERT INTO `sys_menu` VALUES (11, '用户管理', NULL, '6000', 151);
INSERT INTO `sys_menu` VALUES (12, '用户列表', 16, '6001', 8);
INSERT INTO `sys_menu` VALUES (13, '推广管理', NULL, '7000', 182);
INSERT INTO `sys_menu` VALUES (14, '轮播图管理', 18, '7001', 38);
INSERT INTO `sys_menu` VALUES (15, '友情链接', 20, '7002', 178);
INSERT INTO `sys_menu` VALUES (16, '账户设置', NULL, '8000', 190);
INSERT INTO `sys_menu` VALUES (17, '个人信息', 22, '8001', 190);
INSERT INTO `sys_menu` VALUES (18, '系统管理', NULL, '9000', 6);
INSERT INTO `sys_menu` VALUES (19, '管理员', 26, '9001', 206);
INSERT INTO `sys_menu` VALUES (20, '角色管理', 28, '9002', 180);
INSERT INTO `sys_menu` VALUES (21, '路由管理', 29, '9003', 182);
INSERT INTO `sys_menu` VALUES (22, '菜单管理', 30, '9004', 180);
INSERT INTO `sys_menu` VALUES (23, '操作按钮', 31, '9005', 180);

-- ----------------------------
-- Table structure for sys_module
-- ----------------------------
DROP TABLE IF EXISTS `sys_module`;
CREATE TABLE `sys_module`  (
  `module_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `module_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '模块名称',
  `module_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '模块代码',
  `module_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '模块描述',
  PRIMARY KEY (`module_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '模块表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_module
-- ----------------------------

-- ----------------------------
-- Table structure for sys_operation
-- ----------------------------
DROP TABLE IF EXISTS `sys_operation`;
CREATE TABLE `sys_operation`  (
  `operation_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `operation_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作名称',
  `operation_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作编码',
  `operation_description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作描述',
  PRIMARY KEY (`operation_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 13 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_operation
-- ----------------------------
INSERT INTO `sys_operation` VALUES (1, '创建', 'create', '创建操作');
INSERT INTO `sys_operation` VALUES (2, '编辑', 'edit', '编辑操作');
INSERT INTO `sys_operation` VALUES (3, '删除', 'remove', '删除操作');
INSERT INTO `sys_operation` VALUES (4, '浏览', 'view', '浏览权限');
INSERT INTO `sys_operation` VALUES (5, '搜索', 'search', '搜索操作');
INSERT INTO `sys_operation` VALUES (6, '审核', 'audit', '审核操作');
INSERT INTO `sys_operation` VALUES (7, '设置', 'setting', '设置操作');
INSERT INTO `sys_operation` VALUES (8, '回复', 'reply', '回复操作');
INSERT INTO `sys_operation` VALUES (9, '切换', 'switch', '切换操作');
INSERT INTO `sys_operation` VALUES (10, '标记', 'tag', '标记文章');
INSERT INTO `sys_operation` VALUES (11, '导入', 'import', '导入操作');
INSERT INTO `sys_operation` VALUES (12, '导出', 'export', '导出操作');

-- ----------------------------
-- Table structure for sys_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_permission`;
CREATE TABLE `sys_permission`  (
  `permission_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `parent_id` int NOT NULL COMMENT '父级权限ID',
  `resource_id` int NULL DEFAULT NULL,
  `resource_type_id` int NOT NULL COMMENT '资源类型ID',
  `permission_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限代码',
  `permission_remark` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '权限备注',
  PRIMARY KEY (`permission_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 88 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_permission
-- ----------------------------
INSERT INTO `sys_permission` VALUES (1, 0, 1, 1, 'article', '文章');
INSERT INTO `sys_permission` VALUES (2, 1, 2, 1, 'article:release', '发布文章');
INSERT INTO `sys_permission` VALUES (3, 1, 3, 1, 'article:list', '文章列表');
INSERT INTO `sys_permission` VALUES (4, 1, 4, 1, 'article:edit', '编辑文章');
INSERT INTO `sys_permission` VALUES (5, 0, 5, 1, NULL, '标签');
INSERT INTO `sys_permission` VALUES (6, 5, 6, 1, '/tag/list', '标签列表');
INSERT INTO `sys_permission` VALUES (7, 0, 7, 1, NULL, '评论');
INSERT INTO `sys_permission` VALUES (8, 7, 8, 1, '/comment/list', '评论列表');
INSERT INTO `sys_permission` VALUES (9, 0, 9, 1, NULL, '分类');
INSERT INTO `sys_permission` VALUES (10, 9, 10, 1, '/category/list', '文章分类');
INSERT INTO `sys_permission` VALUES (11, 0, 11, 1, NULL, '公告');
INSERT INTO `sys_permission` VALUES (12, 11, 12, 1, '/notice/list', '公告列表');
INSERT INTO `sys_permission` VALUES (13, 11, 13, 1, '/notice/release', '发布公告');
INSERT INTO `sys_permission` VALUES (14, 11, 14, 1, '/notice/edit/:id', '编辑公告');
INSERT INTO `sys_permission` VALUES (15, 0, 15, 1, NULL, '用户');
INSERT INTO `sys_permission` VALUES (16, 15, 16, 1, '/user/list', '用户列表');
INSERT INTO `sys_permission` VALUES (17, 0, 17, 1, NULL, '轮播图');
INSERT INTO `sys_permission` VALUES (18, 17, 18, 1, '/slide/list', '轮播图列表');
INSERT INTO `sys_permission` VALUES (19, 0, 19, 1, NULL, '友情链接');
INSERT INTO `sys_permission` VALUES (20, 19, 20, 1, '/link/list', '链接列表');
INSERT INTO `sys_permission` VALUES (21, 0, 21, 1, NULL, '账户');
INSERT INTO `sys_permission` VALUES (22, 21, 22, 1, '/account/info', '账户信息');
INSERT INTO `sys_permission` VALUES (23, 21, 23, 1, '/account/edit', '账户编辑');
INSERT INTO `sys_permission` VALUES (24, 21, 24, 1, '/account/board', '信息面板');
INSERT INTO `sys_permission` VALUES (25, 0, 25, 1, NULL, '系统');
INSERT INTO `sys_permission` VALUES (26, 25, 26, 1, '/admin/list', '管理员列表');
INSERT INTO `sys_permission` VALUES (27, 25, 27, 1, '/admin/edit/:id', '管理员编辑');
INSERT INTO `sys_permission` VALUES (28, 25, 28, 1, '/auth/role', '角色管理');
INSERT INTO `sys_permission` VALUES (29, 25, 29, 1, NULL, '路由管理');
INSERT INTO `sys_permission` VALUES (30, 25, 30, 1, '/auth/menu', '菜单管理');
INSERT INTO `sys_permission` VALUES (31, 25, 31, 1, NULL, '操作按钮');
INSERT INTO `sys_permission` VALUES (32, 0, 1, 2, 'account:board', '信息面板');
INSERT INTO `sys_permission` VALUES (33, 0, 2, 2, 'article', '文章管理');
INSERT INTO `sys_permission` VALUES (34, 33, 3, 2, 'article:release', '发布文章');
INSERT INTO `sys_permission` VALUES (35, 33, 4, 2, 'article:list', '文章列表');
INSERT INTO `sys_permission` VALUES (36, 33, 5, 2, 'article:tag', '标签管理');
INSERT INTO `sys_permission` VALUES (37, 33, 6, 2, 'article:comment', '评论管理');
INSERT INTO `sys_permission` VALUES (38, 0, 7, 2, 'category:list', '分类管理');
INSERT INTO `sys_permission` VALUES (39, 0, 8, 2, 'notice', '公告管理');
INSERT INTO `sys_permission` VALUES (40, 39, 9, 2, 'notice:release', '发布公告');
INSERT INTO `sys_permission` VALUES (41, 39, 10, 2, 'notice:list', '公告列表');
INSERT INTO `sys_permission` VALUES (42, 0, 11, 2, 'user', '用户管理');
INSERT INTO `sys_permission` VALUES (43, 42, 12, 2, 'user:list', '用户列表');
INSERT INTO `sys_permission` VALUES (44, 0, 13, 2, 'promotion', '推广管理');
INSERT INTO `sys_permission` VALUES (45, 44, 14, 2, 'promotion:slide', '轮播图管理');
INSERT INTO `sys_permission` VALUES (46, 44, 15, 2, 'promotion:link', '友情链接');
INSERT INTO `sys_permission` VALUES (47, 0, 16, 2, 'account:info', '账户设置');
INSERT INTO `sys_permission` VALUES (48, 47, 17, 2, NULL, '个人信息');
INSERT INTO `sys_permission` VALUES (49, 0, 18, 2, 'system', '系统管理');
INSERT INTO `sys_permission` VALUES (50, 49, 19, 2, 'system:admin', '管理员');
INSERT INTO `sys_permission` VALUES (51, 49, 20, 2, 'system:role', '角色管理');
INSERT INTO `sys_permission` VALUES (52, 49, 21, 2, NULL, '路由管理');
INSERT INTO `sys_permission` VALUES (53, 49, 22, 2, 'system:menu', '菜单管理');
INSERT INTO `sys_permission` VALUES (54, 49, 23, 2, NULL, '操作按钮');
INSERT INTO `sys_permission` VALUES (55, 35, 2, 3, 'article:list:edit', '编辑文章');
INSERT INTO `sys_permission` VALUES (56, 35, 6, 3, 'article:list:audit', '审核文章');
INSERT INTO `sys_permission` VALUES (57, 35, 10, 3, 'article:list:tag', '标记文章');
INSERT INTO `sys_permission` VALUES (58, 35, 3, 3, 'article:list:remove', '删除文章');
INSERT INTO `sys_permission` VALUES (59, 36, 1, 3, 'article:tag:create', '创建标签');
INSERT INTO `sys_permission` VALUES (60, 36, 2, 3, 'article:tag:edit', '编辑标签');
INSERT INTO `sys_permission` VALUES (61, 36, 3, 3, 'article:tag:remove', '删除标签');
INSERT INTO `sys_permission` VALUES (62, 37, 8, 3, 'comment:reply', '回复评论');
INSERT INTO `sys_permission` VALUES (63, 37, 9, 3, 'comment:switch', '隐藏/显示评论');
INSERT INTO `sys_permission` VALUES (64, 38, 2, 3, 'category:edit', '编辑分类');
INSERT INTO `sys_permission` VALUES (65, 38, 1, 3, 'category:create', '创建子分类');
INSERT INTO `sys_permission` VALUES (66, 38, 3, 3, 'category:remove', '删除分类');
INSERT INTO `sys_permission` VALUES (67, 41, 2, 3, 'notice:edit', '编辑公告');
INSERT INTO `sys_permission` VALUES (68, 41, 9, 3, 'notice:switch', '置顶/取消公告');
INSERT INTO `sys_permission` VALUES (69, 41, 3, 3, 'notice:remove', '删除公告');
INSERT INTO `sys_permission` VALUES (70, 43, 9, 3, 'user:switch', '禁用/启用用户');
INSERT INTO `sys_permission` VALUES (71, 43, 3, 3, 'user:remove', '删除用户');
INSERT INTO `sys_permission` VALUES (72, 45, 1, 3, 'slide:create', '添加轮播图');
INSERT INTO `sys_permission` VALUES (73, 45, 2, 3, 'slide:edit', '编辑轮播图');
INSERT INTO `sys_permission` VALUES (74, 45, 9, 3, 'slide:switch', '禁用/启用轮播图');
INSERT INTO `sys_permission` VALUES (75, 45, 3, 3, 'slide:remove', '删除轮播图');
INSERT INTO `sys_permission` VALUES (76, 46, 1, 3, 'link:create', '添加友情链接');
INSERT INTO `sys_permission` VALUES (77, 46, 2, 3, 'link:edit', '编辑友情链接');
INSERT INTO `sys_permission` VALUES (78, 46, 9, 3, 'link:switch', '禁用/启用友情链接');
INSERT INTO `sys_permission` VALUES (79, 46, 3, 3, 'link:remove', '删除友情链接');
INSERT INTO `sys_permission` VALUES (80, 50, 2, 3, 'admin:edit', '编辑管理员');
INSERT INTO `sys_permission` VALUES (81, 50, 6, 3, 'admin:audit', '审核管理员');
INSERT INTO `sys_permission` VALUES (82, 50, 9, 3, 'admin:switch', '禁用/启用管理员');
INSERT INTO `sys_permission` VALUES (83, 50, 3, 3, 'admin:remove', '删除管理员');
INSERT INTO `sys_permission` VALUES (84, 51, 1, 3, 'role:create', '创建角色');
INSERT INTO `sys_permission` VALUES (85, 51, 2, 3, 'role:edit', '编辑角色');
INSERT INTO `sys_permission` VALUES (86, 51, 3, 3, 'role:remove', '删除角色');
INSERT INTO `sys_permission` VALUES (87, 51, 7, 3, 'auth:setting', '分配权限');

-- ----------------------------
-- Table structure for sys_resource_type
-- ----------------------------
DROP TABLE IF EXISTS `sys_resource_type`;
CREATE TABLE `sys_resource_type`  (
  `resource_type_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `resource_type_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '类型名称',
  `resource_type_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '类型代码',
  PRIMARY KEY (`resource_type_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 6 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '权限表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_resource_type
-- ----------------------------
INSERT INTO `sys_resource_type` VALUES (1, '路由', 'ROUTE');
INSERT INTO `sys_resource_type` VALUES (2, '菜单', 'MENU');
INSERT INTO `sys_resource_type` VALUES (3, '操作', 'OPERATION');
INSERT INTO `sys_resource_type` VALUES (4, '元素', 'ELEMENT');
INSERT INTO `sys_resource_type` VALUES (5, '数据', 'DATA');

-- ----------------------------
-- Table structure for sys_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_role`;
CREATE TABLE `sys_role`  (
  `role_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '角色id',
  `role_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '角色名称',
  `role_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '角色代码',
  `role_description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '角色描述',
  `editable` tinyint NULL DEFAULT 1 COMMENT '可编辑状态，1-编辑，0-锁定',
  PRIMARY KEY (`role_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '角色表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role
-- ----------------------------
INSERT INTO `sys_role` VALUES (1, '超级管理员', 'SUPER_ADMINISTRATOR', '最高级权限，拥有所有权限', 0);
INSERT INTO `sys_role` VALUES (2, '管理员', 'ADMINISTRATOR', '拥有系统普通权限，可以分配角色', 0);
INSERT INTO `sys_role` VALUES (3, '编辑', 'EDITOR', '具有文章、推广、评论、公告等权限', 0);
INSERT INTO `sys_role` VALUES (4, '设计', 'DESIGNER', '具有文章、轮播图等权限', 1);

-- ----------------------------
-- Table structure for sys_role_permission
-- ----------------------------
DROP TABLE IF EXISTS `sys_role_permission`;
CREATE TABLE `sys_role_permission`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `role_id` int NOT NULL COMMENT '	角色id',
  `permission_id` int NOT NULL COMMENT '权限id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 93 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '角色-权限中间表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_role_permission
-- ----------------------------
INSERT INTO `sys_role_permission` VALUES (1, 1, 1);
INSERT INTO `sys_role_permission` VALUES (2, 1, 2);
INSERT INTO `sys_role_permission` VALUES (3, 1, 3);
INSERT INTO `sys_role_permission` VALUES (4, 1, 4);
INSERT INTO `sys_role_permission` VALUES (5, 1, 5);
INSERT INTO `sys_role_permission` VALUES (6, 1, 6);
INSERT INTO `sys_role_permission` VALUES (7, 1, 7);
INSERT INTO `sys_role_permission` VALUES (8, 1, 8);
INSERT INTO `sys_role_permission` VALUES (9, 1, 9);
INSERT INTO `sys_role_permission` VALUES (10, 1, 10);
INSERT INTO `sys_role_permission` VALUES (11, 1, 11);
INSERT INTO `sys_role_permission` VALUES (12, 1, 12);
INSERT INTO `sys_role_permission` VALUES (13, 1, 13);
INSERT INTO `sys_role_permission` VALUES (14, 1, 14);
INSERT INTO `sys_role_permission` VALUES (15, 1, 15);
INSERT INTO `sys_role_permission` VALUES (16, 1, 16);
INSERT INTO `sys_role_permission` VALUES (17, 1, 17);
INSERT INTO `sys_role_permission` VALUES (18, 1, 18);
INSERT INTO `sys_role_permission` VALUES (19, 1, 19);
INSERT INTO `sys_role_permission` VALUES (20, 1, 20);
INSERT INTO `sys_role_permission` VALUES (21, 1, 21);
INSERT INTO `sys_role_permission` VALUES (22, 1, 22);
INSERT INTO `sys_role_permission` VALUES (23, 1, 23);
INSERT INTO `sys_role_permission` VALUES (24, 1, 24);
INSERT INTO `sys_role_permission` VALUES (25, 1, 25);
INSERT INTO `sys_role_permission` VALUES (26, 1, 26);
INSERT INTO `sys_role_permission` VALUES (27, 1, 27);
INSERT INTO `sys_role_permission` VALUES (28, 1, 28);
INSERT INTO `sys_role_permission` VALUES (29, 1, 29);
INSERT INTO `sys_role_permission` VALUES (30, 1, 30);
INSERT INTO `sys_role_permission` VALUES (31, 1, 31);
INSERT INTO `sys_role_permission` VALUES (32, 1, 32);
INSERT INTO `sys_role_permission` VALUES (33, 1, 33);
INSERT INTO `sys_role_permission` VALUES (34, 1, 34);
INSERT INTO `sys_role_permission` VALUES (35, 1, 35);
INSERT INTO `sys_role_permission` VALUES (36, 1, 36);
INSERT INTO `sys_role_permission` VALUES (37, 1, 37);
INSERT INTO `sys_role_permission` VALUES (38, 1, 38);
INSERT INTO `sys_role_permission` VALUES (39, 1, 39);
INSERT INTO `sys_role_permission` VALUES (40, 1, 40);
INSERT INTO `sys_role_permission` VALUES (41, 1, 41);
INSERT INTO `sys_role_permission` VALUES (42, 1, 42);
INSERT INTO `sys_role_permission` VALUES (43, 1, 43);
INSERT INTO `sys_role_permission` VALUES (44, 1, 44);
INSERT INTO `sys_role_permission` VALUES (45, 1, 45);
INSERT INTO `sys_role_permission` VALUES (46, 1, 46);
INSERT INTO `sys_role_permission` VALUES (47, 1, 47);
INSERT INTO `sys_role_permission` VALUES (48, 1, 48);
INSERT INTO `sys_role_permission` VALUES (49, 1, 49);
INSERT INTO `sys_role_permission` VALUES (50, 1, 50);
INSERT INTO `sys_role_permission` VALUES (51, 1, 51);
INSERT INTO `sys_role_permission` VALUES (52, 1, 52);
INSERT INTO `sys_role_permission` VALUES (53, 1, 53);
INSERT INTO `sys_role_permission` VALUES (54, 1, 54);
INSERT INTO `sys_role_permission` VALUES (55, 1, 55);
INSERT INTO `sys_role_permission` VALUES (56, 1, 56);
INSERT INTO `sys_role_permission` VALUES (57, 1, 57);
INSERT INTO `sys_role_permission` VALUES (58, 1, 58);
INSERT INTO `sys_role_permission` VALUES (59, 1, 59);
INSERT INTO `sys_role_permission` VALUES (60, 1, 60);
INSERT INTO `sys_role_permission` VALUES (61, 1, 61);
INSERT INTO `sys_role_permission` VALUES (62, 1, 62);
INSERT INTO `sys_role_permission` VALUES (63, 1, 63);
INSERT INTO `sys_role_permission` VALUES (64, 1, 64);
INSERT INTO `sys_role_permission` VALUES (65, 1, 65);
INSERT INTO `sys_role_permission` VALUES (66, 1, 66);
INSERT INTO `sys_role_permission` VALUES (67, 1, 67);
INSERT INTO `sys_role_permission` VALUES (68, 1, 68);
INSERT INTO `sys_role_permission` VALUES (69, 1, 69);
INSERT INTO `sys_role_permission` VALUES (70, 1, 70);
INSERT INTO `sys_role_permission` VALUES (71, 1, 71);
INSERT INTO `sys_role_permission` VALUES (72, 1, 72);
INSERT INTO `sys_role_permission` VALUES (73, 1, 73);
INSERT INTO `sys_role_permission` VALUES (74, 1, 74);
INSERT INTO `sys_role_permission` VALUES (75, 1, 75);
INSERT INTO `sys_role_permission` VALUES (76, 1, 76);
INSERT INTO `sys_role_permission` VALUES (77, 1, 77);
INSERT INTO `sys_role_permission` VALUES (78, 1, 78);
INSERT INTO `sys_role_permission` VALUES (79, 1, 79);
INSERT INTO `sys_role_permission` VALUES (80, 1, 80);
INSERT INTO `sys_role_permission` VALUES (81, 1, 81);
INSERT INTO `sys_role_permission` VALUES (82, 1, 82);
INSERT INTO `sys_role_permission` VALUES (83, 1, 83);
INSERT INTO `sys_role_permission` VALUES (84, 1, 84);
INSERT INTO `sys_role_permission` VALUES (85, 1, 85);
INSERT INTO `sys_role_permission` VALUES (86, 1, 86);
INSERT INTO `sys_role_permission` VALUES (87, 1, 87);
INSERT INTO `sys_role_permission` VALUES (88, 2, 1);
INSERT INTO `sys_role_permission` VALUES (89, 2, 2);
INSERT INTO `sys_role_permission` VALUES (90, 2, 3);
INSERT INTO `sys_role_permission` VALUES (91, 2, 4);
INSERT INTO `sys_role_permission` VALUES (92, 2, 5);

-- ----------------------------
-- Table structure for sys_route
-- ----------------------------
DROP TABLE IF EXISTS `sys_route`;
CREATE TABLE `sys_route`  (
  `route_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `route_title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由标题',
  `route_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '路由英文名称',
  `route_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '路由路径',
  `route_full_path` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由完整路径',
  `component_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '组件名称',
  `component_path` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '组件路径',
  `route_alias` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '路由别名',
  `require_auth` tinyint NULL DEFAULT NULL COMMENT '是否需要登录认证，需要：1，不需要：0',
  PRIMARY KEY (`route_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 32 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '路由配置表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_route
-- ----------------------------
INSERT INTO `sys_route` VALUES (1, NULL, 'Article', '/article', '/article', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (2, NULL, 'ArticleRelease', 'release', '/article/release', 'Release', '@/views/Article/Release.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (3, NULL, 'ArticleList', 'list', '/article/list', 'List', '@/views/Article/List.vue', '\'\'', 1);
INSERT INTO `sys_route` VALUES (4, NULL, 'ArticleEdit', 'edit/:id', '/article/edit', 'Edit', '@/views/Article/Edit.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (5, NULL, 'Tag', '/tag', '/tag', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (6, NULL, 'TagList', 'list', '/tag/list', 'List', '@/views/Tag/List.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (7, NULL, 'Comment', '/comment', '/comment', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (8, NULL, 'CommentList', 'list', '/comment/list', 'List', '@/views/Comment/List.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (9, NULL, 'Category', '/category', '/category', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (10, NULL, 'CategoryList', 'list', '/category/list', 'List', '@/views/Category/List.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (11, NULL, 'Notice', '/notice', '/notice', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (12, NULL, 'NoticeList', 'list', '/notice/list', 'List', '@/views/Notice/List.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (13, NULL, 'NoticeRelease', 'release', '/notice/release', 'Release', '@/views/Notice/Release.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (14, NULL, 'NoticeEdit', 'edit/:id', '/notice/edit', 'Edit', '@/views/Notice/Edit.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (15, NULL, 'User', '/user', '/user', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (16, NULL, 'UserList', 'list', '/user/list', 'List', '@/views/User/List.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (17, NULL, 'Slide', '/slide', '/slide', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (18, NULL, 'SlideList', 'list', '/slide/list', 'List', '@/views/Slide/List.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (19, NULL, 'Link', '/link', '/link', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (20, NULL, 'LinkList', 'list', '/link/list', 'List', '@/views/Link/List.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (21, NULL, 'Account', '/account', '/account', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (22, NULL, 'AccountInfo', 'info', '/account/info', 'Info', '@/views/Account/Info.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (23, NULL, 'AccountEdit', 'edit', '/account/edit', 'Edit', '@/views/Account/Edit.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (24, NULL, 'AccountBoard', 'board', '/account/board', 'Board', '@/views/Account/Board.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (25, NULL, 'System', '/system', '/system', 'Layout', '@/components/Layout.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (26, NULL, 'AdminList', 'admin/list', '/system/admin/list', 'List', '@/views/Admin/List.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (27, NULL, 'AdminEdit', 'admin/edit/:id', '/system/admin/edit', 'Edit', '@/views/Admin/Edit.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (28, NULL, 'AuthRole', 'role', '/system/role', 'Role', '@/views/Auth/Role.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (29, NULL, 'AuthRoute', 'route', '/system/route', 'Route', '@/views/Auth/Route.vue', NULL, NULL);
INSERT INTO `sys_route` VALUES (30, NULL, 'AuthMenu', 'menu', '/system/menu', 'Menu', '@/views/Auth/Menu.vue', NULL, 1);
INSERT INTO `sys_route` VALUES (31, NULL, 'AuthOperation', 'operation', '/system/operation', 'Operation', '@/views/Auth/Operation.vue', NULL, NULL);

-- ----------------------------
-- Table structure for sys_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user`;
CREATE TABLE `sys_user`  (
  `user_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '用户名',
  `password` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '密码',
  `nickname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '昵称',
  `fullname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '姓名',
  `sex` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '男' COMMENT '性别',
  `tel` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '手机号码',
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL COMMENT '邮箱',
  `avatar` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL COMMENT '头像',
  `usable` tinyint NOT NULL DEFAULT -1 COMMENT '状态，1-正常，-1-审核中，-2-禁用',
  `editable` tinyint NOT NULL DEFAULT 1 COMMENT '可编辑状态，1-编辑，0-锁定',
  `jwt_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'jwt_id',
  `refresh_token` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL COMMENT '刷新token',
  `create_date` datetime NOT NULL COMMENT '创建时间',
  `login_date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '登录时间',
  PRIMARY KEY (`user_id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci COMMENT = '用户表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user
-- ----------------------------
INSERT INTO `sys_user` VALUES (1, 'admin', '123', 'papi酱', '黄小米', '女', '15863008280', 'nn880328@126.com', 'http://localhost:3001/images/avatar/default.jpg', 1, 0, 'cb758dce-22de-495b-85ff-a660dde1aa42', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0eXBlIjoicmVmcmVzaCIsImlhdCI6MTY3OTY0MDI3NSwiZXhwIjoxNjgyMjMyMjc1LCJqdGkiOiJjYjc1OGRjZS0yMmRlLTQ5NWItODVmZi1hNjYwZGRlMWFhNDIifQ.8xe3IcPfA_cNkEa-IFmtZRj2FnfbLptqR3YKOjrS1ms', '2020-01-11 10:31:49', '2023-03-24 14:44:35');
INSERT INTO `sys_user` VALUES (2, 'moz', '123', '夏目友人帐', '孙红雷', '女', '13475829262', '715623617@qq.com', 'http://localhost:3001/images/avatar/default.jpg', 1, 1, NULL, NULL, '2022-10-11 10:31:59', '2022-10-20 12:12:53');
INSERT INTO `sys_user` VALUES (3, 'orz', '123', '乌鸦校尉', '鹿晗', '男', '13485956526', 'love@163.com', 'http://localhost:3001/images/avatar/default.jpg', -2, 1, NULL, NULL, '2022-10-11 10:32:02', '2022-10-20 12:12:54');
INSERT INTO `sys_user` VALUES (4, 'god', '123', '咸鱼', '黄渤', '男', '13475829262', 'godisgreed@126.com', 'http://localhost:3001/images/avatar/default.jpg', -1, 1, NULL, '', '2022-10-10 10:54:56', '2022-10-20 12:12:57');

-- ----------------------------
-- Table structure for sys_user_group
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_group`;
CREATE TABLE `sys_user_group`  (
  `group_id` int UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '	主键id',
  `group_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '用户组名称',
  `parent_id` int NOT NULL COMMENT '父级id',
  PRIMARY KEY (`group_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户组表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_group
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user_group_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_group_role`;
CREATE TABLE `sys_user_group_role`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL COMMENT '用户组id',
  `role_id` int NOT NULL COMMENT '角色id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户组-角色中间表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_group_role
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user_group_user
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_group_user`;
CREATE TABLE `sys_user_group_user`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `group_id` int NOT NULL COMMENT '用户组id',
  `user_id` int NOT NULL COMMENT '用户id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户组-用户中间表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_group_user
-- ----------------------------

-- ----------------------------
-- Table structure for sys_user_role
-- ----------------------------
DROP TABLE IF EXISTS `sys_user_role`;
CREATE TABLE `sys_user_role`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL COMMENT '用户id',
  `role_id` bigint NOT NULL COMMENT '角色id',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 5 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户-角色中间表' ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sys_user_role
-- ----------------------------
INSERT INTO `sys_user_role` VALUES (1, 1, 1);
INSERT INTO `sys_user_role` VALUES (2, 2, 2);
INSERT INTO `sys_user_role` VALUES (3, 3, 3);
INSERT INTO `sys_user_role` VALUES (4, 4, 4);

-- ----------------------------
-- View structure for role_menu_view
-- ----------------------------
DROP VIEW IF EXISTS `role_menu_view`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `role_menu_view` AS select `p`.`permission_id` AS `permission_id`,`p`.`parent_id` AS `parent_id`,`p`.`permission_code` AS `permission_code`,`p`.`permission_remark` AS `permission_remark`,`m`.`menu_id` AS `menu_id`,`m`.`menu_name` AS `menu_name`,`m`.`menu_order` AS `menu_order`,`m`.`icon_id` AS `icon_id`,`r`.`role_id` AS `role_id`,`r`.`role_name` AS `role_name`,`r`.`role_code` AS `role_code`,`r`.`role_description` AS `role_description`,`t`.`resource_type_name` AS `resource_type_name`,`t`.`resource_type_code` AS `resource_type_code`,`t`.`resource_type_id` AS `resource_type_id`,`rt`.`route_title` AS `route_title`,`rt`.`route_name` AS `route_name`,`rt`.`route_path` AS `route_path`,`rt`.`route_full_path` AS `route_full_path`,`rt`.`component_name` AS `component_name`,`rt`.`component_path` AS `component_path`,`rt`.`route_alias` AS `route_alias`,`rt`.`require_auth` AS `require_auth`,`rt`.`route_id` AS `route_id`,`sys_icon`.`icon_name` AS `icon_name` from ((((((`sys_permission` `p` join `sys_role_permission` `rp` on((`p`.`permission_id` = `rp`.`permission_id`))) join `sys_role` `r` on((`r`.`role_id` = `rp`.`role_id`))) join `sys_menu` `m` on((`p`.`resource_id` = `m`.`menu_id`))) join `sys_resource_type` `t` on((`p`.`resource_type_id` = `t`.`resource_type_id`))) left join `sys_route` `rt` on((`m`.`route_id` = `rt`.`route_id`))) join `sys_icon` on((`m`.`icon_id` = `sys_icon`.`icon_id`))) where (`p`.`resource_type_id` = 2);

-- ----------------------------
-- View structure for role_operation_view
-- ----------------------------
DROP VIEW IF EXISTS `role_operation_view`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `role_operation_view` AS select `p`.`permission_id` AS `permission_id`,`p`.`parent_id` AS `parent_id`,`p`.`permission_code` AS `permission_code`,`p`.`permission_remark` AS `permission_remark`,`r`.`role_id` AS `role_id`,`r`.`role_name` AS `role_name`,`r`.`role_code` AS `role_code`,`r`.`role_description` AS `role_description`,`o`.`operation_id` AS `operation_id`,`o`.`operation_name` AS `operation_name`,`o`.`operation_code` AS `operation_code`,`o`.`operation_description` AS `operation_description`,`sys_resource_type`.`resource_type_id` AS `resource_type_id`,`sys_resource_type`.`resource_type_code` AS `resource_type_code`,`sys_resource_type`.`resource_type_name` AS `resource_type_name` from ((((`sys_permission` `p` join `sys_role_permission` `rp` on((`p`.`permission_id` = `rp`.`permission_id`))) join `sys_role` `r` on((`rp`.`role_id` = `r`.`role_id`))) join `sys_operation` `o` on((`p`.`resource_id` = `o`.`operation_id`))) join `sys_resource_type` on((`p`.`resource_type_id` = `sys_resource_type`.`resource_type_id`))) where (`p`.`resource_type_id` = 3);

-- ----------------------------
-- View structure for role_route_view
-- ----------------------------
DROP VIEW IF EXISTS `role_route_view`;
CREATE ALGORITHM = UNDEFINED SQL SECURITY DEFINER VIEW `role_route_view` AS select `p`.`permission_id` AS `permission_id`,`p`.`parent_id` AS `parent_id`,`p`.`permission_code` AS `permission_code`,`p`.`permission_remark` AS `permission_remark`,`r`.`role_id` AS `role_id`,`r`.`role_name` AS `role_name`,`r`.`role_code` AS `role_code`,`r`.`role_description` AS `role_description`,`rt`.`route_id` AS `route_id`,`rt`.`route_title` AS `route_title`,`rt`.`route_name` AS `route_name`,`rt`.`route_path` AS `route_path`,`rt`.`route_full_path` AS `route_full_path`,`rt`.`component_name` AS `component_name`,`rt`.`component_path` AS `component_path`,`rt`.`require_auth` AS `require_auth`,`rt`.`route_alias` AS `route_alias`,`t`.`resource_type_id` AS `resource_type_id`,`t`.`resource_type_name` AS `resource_type_name`,`t`.`resource_type_code` AS `resource_type_code` from ((((`sys_role_permission` `rp` join `sys_permission` `p` on((`rp`.`permission_id` = `p`.`permission_id`))) join `sys_role` `r` on((`r`.`role_id` = `rp`.`role_id`))) join `sys_route` `rt` on((`p`.`resource_id` = `rt`.`route_id`))) join `sys_resource_type` `t` on((`p`.`resource_type_id` = `t`.`resource_type_id`))) where (`p`.`resource_type_id` = 1);

SET FOREIGN_KEY_CHECKS = 1;
