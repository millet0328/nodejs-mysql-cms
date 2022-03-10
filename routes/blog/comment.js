var express = require('express');
var router = express.Router();
// 数据库
var db = require('../../config/mysql');

/**
 * @api {post} /comment/release 发表新的评论
 * @apiName CommentRelease
 * @apiPermission 前台
 * @apiGroup Comment
 *
 * @apiBody { Number } user_id 账户id.
 * @apiBody { Number } article_id 文章id.
 * @apiBody { String } content 评论内容.
 *
 * @apiSampleRequest /comment/release
 */

router.post("/release/", async (req, res) => {
    let { user_id, article_id, content } = req.body;
    const sql = 'INSERT INTO comment ( user_id , article_id , content , create_date ) VALUES (?, ? , ? ,CURRENT_TIMESTAMP() )';
    let { insertId, affectedRows } = await db.query(sql, [user_id, article_id, content]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "添加失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "添加成功",
        data: {
            id: insertId,
        }
    });
});

/**
 * @api {post} /comment/remove 删除指定id的评论
 * @apiDescription 注意：本账户只能删除自己账户的评论，无权限删除其他账户评论。
 * @apiName RemoveComment
 * @apiPermission 前台
 * @apiGroup Comment
 *
 * @apiBody { Number } id 评论id
 * @apiBody { Number } user_id 账户id
 *
 * @apiSampleRequest /comment/remove
 */

router.post('/remove', async (req, res) => {
    let { id, user_id } = req.body;
    var sql = 'SELECT * FROM comment WHERE id = ? AND user_id = ?';
    let results = await db.query(sql, [id, user_id]);
    if (!results.length) {
        res.json({
            status: false,
            msg: "删除失败，只能删除自己的评论！"
        });
        return;
    }
    var sql = 'DELETE FROM comment WHERE id = ? AND user_id = ?';
    let { affectedRows } = await db.query(sql, [id, user_id]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "删除失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "删除成功"
    });
});

/**
 * @api {get} /comment/detail 获取指定id的评论详情
 * @apiName CommentDetail
 * @apiPermission 后台系统、前台
 * @apiGroup Comment
 *
 * @apiQuery { Number } id 评论id
 *
 * @apiSampleRequest /comment/detail
 */
router.get('/detail', async (req, res) => {
    let { id } = req.query;
    const sql = 'SELECT * FROM comment WHERE id = ?';
    let results = await db.query(sql, [id]);
    res.json({
        status: true,
        msg: "获取成功",
        data: results[0]
    });
});

/**
 * @api {post} /comment/edit 编辑指定id评论
 * @apiDescription 注意：本账户只能编辑自己账户的评论，无权限编辑其他账户评论。
 * @apiName EditComment
 * @apiPermission 前台
 * @apiGroup Comment
 *
 * @apiBody { Number } id 评论id.
 * @apiBody { Number } user_id 账户id
 * @apiBody { String } content 评论内容.
 *
 * @apiSampleRequest /comment/edit
 */

router.post('/edit', async (req, res) => {
    let { id, user_id, content } = req.body;
    var sql = 'SELECT * FROM comment WHERE id = ? AND user_id = ?';
    let results = await db.query(sql, [id, user_id]);
    if (!results.length) {
        res.json({
            status: false,
            msg: "修改失败，只能修改自己的评论！"
        });
        return;
    }
    var sql = 'UPDATE comment SET content = ? WHERE id = ? AND user_id = ?';
    let { affectedRows } = await db.query(sql, [content, id, user_id]);
    if (!affectedRows) {
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

/**
 * @api {get} /comment/list 获取一篇文章下面的评论列表
 * @apiName CommentList
 * @apiPermission 前台
 * @apiGroup Comment
 *
 * @apiQuery { Number } id 文章id
 * @apiQuery { Number } pagesize=10 每一页评论数量.
 * @apiQuery { Number } pageindex=1 第几页.
 *
 * @apiSampleRequest /comment/list
 */

router.get("/list", async (req, res) => {
    let { id, pagesize = 10, pageindex = 1 } = req.query;
    pagesize = parseInt(pagesize);
    var offset = pagesize * (pageindex - 1);
    var sql = 'SELECT c.*, DATE_FORMAT(c.create_date,"%Y-%m-%d %T") AS create_time, u.nickname AS user_nickname,a.title AS article_title FROM comment c JOIN user u ON c.user_id = u.id JOIN article a ON c.article_id = a.id WHERE c.article_id = ? ORDER BY c.create_date DESC LIMIT ? OFFSET ?;SELECT FOUND_ROWS() as total';
    let results = await db.query(sql, [id, pagesize, offset]);
    res.json({
        status: true,
        msg: "获取成功",
        ...results[1][0],
        data: results[0],
    });
});

module.exports = router;