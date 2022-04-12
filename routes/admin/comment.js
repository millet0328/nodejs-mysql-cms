const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 登录或者注册之后返回的token，请在头部headers中设置Authorization: `Bearer ${token}`.
 */

/**
 * @api {post} /comment/reply 回复评论
 * @apiDescription 注意：只有管理员才可以回复评论。
 * @apiName ReplyComment
 * @apiPermission 后台系统
 * @apiGroup Comment
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 评论id.
 * @apiBody { String } reply 回复内容.
 *
 * @apiSampleRequest /comment/reply
 */

router.post("/reply/", async (req, res) => {
    let { id, reply } = req.body;
    const sql = 'UPDATE comment SET reply = ?,is_reply = 1,reply_date = CURRENT_TIMESTAMP() WHERE id = ?';
    let [{ affectedRows }] = await pool.query(sql, [reply, id]);
    if (!affectedRows) {
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

    let sql = 'SELECT c.*, DATE_FORMAT(c.create_date,"%Y-%m-%d %T") AS create_time, DATE_FORMAT(c.reply_date,"%Y-%m-%d %T") AS reply_time, u.nickname AS user_nickname,a.title AS article_title FROM comment c LEFT JOIN user u ON c.user_id = u.id JOIN article a ON c.article_id = a.id ORDER BY c.create_date DESC LIMIT ? OFFSET ?; SELECT COUNT(*) as total FROM `comment`;';
    let [results] = await pool.query(sql, [pagesize, offset]);
    res.json({
        status: true,
        msg: "获取成功",
        ...results[1][0],
        data: results[0],
    });
});

module.exports = router;