const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {get} /comment/recent 获取最新的评论列表
 * @apiDescription 注意：默认按照日期降序排序
 * @apiName RecentComment
 * @apiPermission 后台系统
 * @apiGroup Comment
 *
 * @apiUse Authorization
 *
 * @apiQuery { Number } [pagesize=10] 每一页评论数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 *
 * @apiSampleRequest /comment/recent
 */

router.get("/recent", async (req, res) => {
    let { pagesize = 10, pageindex = 1 } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    let offset = pagesize * (pageindex - 1);
    // 查询列表
    let sql = 'SELECT c.*, DATE_FORMAT(c.create_date,"%Y-%m-%d %T") AS create_time, DATE_FORMAT(c.reply_date,"%Y-%m-%d %T") AS reply_time, u.nickname AS user_nickname,a.title AS article_title FROM `cms_comment` c LEFT JOIN `cms_user` u ON c.user_id = u.user_id JOIN `cms_article` a ON c.article_id = a.article_id ORDER BY c.create_date DESC LIMIT ? OFFSET ?';
    let [comments] = await pool.query(sql, [pagesize, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(*) as total FROM `cms_comment`';
    let [total] = await pool.query(total_sql, []);
    res.json({
        status: true,
        msg: "获取成功",
        data: comments,
        ...total[0],
    });
});

/**
 * @api {post} /comment/reply 回复评论
 * @apiDescription 注意：只有管理员才可以回复评论。
 * @apiName ReplyComment
 * @apiPermission 后台系统
 * @apiGroup Comment
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } comment_id 评论id.
 * @apiBody { String } reply 回复内容.
 *
 * @apiSampleRequest /comment/reply
 */

router.post("/reply/", async (req, res) => {
    let { comment_id, reply } = req.body;
    const sql = 'UPDATE `cms_comment` SET reply = ?, is_reply = 1, reply_date = CURRENT_TIMESTAMP() WHERE comment_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [reply, comment_id]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "回复失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "回复成功",
    });
});

/**
 * @api {post} /comment/visible 隐藏/显示评论
 * @apiDescription 注意：只有管理员才可以隐藏/显示评论，隐藏的评论前台无法显示。
 * @apiName SwitchComment
 * @apiPermission 后台系统
 * @apiGroup Comment
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } comment_id 评论id.
 * @apiBody { Number=1,-1 } visible 评论状态。1-显示，-1-隐藏。
 *
 * @apiSampleRequest /comment/visible
 */

router.post('/visible', async (req, res) => {
    let { comment_id, visible } = req.body;
    const sql = 'UPDATE `cms_comment` SET is_visible = ? WHERE comment_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [visible, comment_id]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "修改失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "修改成功！"
    });
});

module.exports = router;