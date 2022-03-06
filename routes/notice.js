var express = require('express');
var router = express.Router();
// 数据库
var db = require('../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 登录或者注册之后返回的token，请设置在request header中.
 */

/**
 * @api {post} /notice/release 添加新的公告
 * @apiName NoticeRelease
 * @apiPermission 后台系统
 * @apiGroup Notice
 *
 * @apiUse Authorization
 *
 * @apiBody { String } title 公告标题.
 * @apiBody { String } content 公告内容.
 * @apiBody { Number=1,0 } is_sticky=0 是否置顶。1-置顶，0-正常。
 *
 * @apiSampleRequest /notice/release
 */

router.post("/release/", async (req, res) => {
    let { title, content, is_sticky = 0 } = req.body;
    console.log(req.body)
    const sql = 'INSERT INTO notice ( title , content , create_date , update_date , is_sticky ) VALUES (?, ? , CURRENT_TIMESTAMP() ,CURRENT_TIMESTAMP(), ?)';
    let { insertId, affectedRows } = await db.query(sql, [title, content, is_sticky]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "添加失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "添加成功"
    });
});

/**
 * @api {post} /notice/remove 删除指定id的公告
 * @apiName RemoveNotice
 * @apiPermission 后台系统
 * @apiGroup Notice
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 公告id
 *
 * @apiSampleRequest /notice/remove
 */

router.post('/remove', async (req, res) => {
    let { id } = req.body;
    const sql = 'DELETE FROM notice WHERE id = ?';
    let { affectedRows } = await db.query(sql, [id]);
    if (affectedRows) {
        res.json({
            status: true,
            msg: "删除成功"
        });
    }
});

/**
 * @api {get} /notice/detail 获取指定id的公告详情
 * @apiName NoticeDetail
 * @apiPermission 后台系统、前台
 * @apiGroup Notice
 *
 * @apiQuery { Number } id 公告id
 *
 * @apiSampleRequest /notice/detail
 */
router.get('/detail', async (req, res) => {
    let { id } = req.query;
    const sql = 'SELECT * FROM notice WHERE id = ?';
    let results = await db.query(sql, [id]);
    res.json({
        status: true,
        msg: "获取成功",
        data: results[0]
    });
});

/**
 * @api {post} /notice/edit 编辑指定id公告
 * @apiName EditNotice
 * @apiPermission 后台系统
 * @apiGroup Notice
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 公告id.
 * @apiBody { String } title 公告标题.
 * @apiBody { String } content 公告内容.
 * @apiBody { Number=1,0 } is_sticky=0 是否置顶。1-置顶，0-正常。
 *
 * @apiSampleRequest /notice/edit
 */
router.post('/edit', async (req, res) => {
    let { id, title, content, is_sticky } = req.body;
    const sql = 'UPDATE notice SET  title = ? , content = ? , is_sticky = ? WHERE id = ?';
    let { affectedRows } = await db.query(sql, [title, content, is_sticky, id]);
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
 * 1   LIMIT 10    OFFSET 0
 * 2   LIMIT 10    OFFSET 10
 * 3   LIMIT 10    OFFSET 20
 * 4   LIMIT 10    OFFSET 30
 * ....
 * n   LIMIT 10    OFFSET 10*(n-1)
 */
/**
 * @api {get} /notice/list 获取所有公告列表
 * @apiDescription 注意：置顶公告排序靠前，正常公告默认按照日期降序排序
 * @apiName NoticeList
 * @apiPermission 后台系统、前台
 * @apiGroup Notice
 *
 * @apiQuery { Number } pagesize 每一页公告数量.
 * @apiQuery { Number } pageindex 第几页.
 *
 * @apiSuccess {Object[]} data 公告数组.
 *
 * @apiSampleRequest /notice/list
 */
router.get("/list", async (req, res) => {
    let { pagesize, pageindex } = req.query;
    pagesize = parseInt(pagesize);
    const offset = pagesize * (pageindex - 1);
    const sql = '(SELECT * FROM notice WHERE is_sticky = 1 ORDER BY update_date DESC LIMIT 9999999) UNION ALL SELECT * FROM (SELECT * FROM notice WHERE is_sticky = 0 ORDER BY create_date DESC LIMIT 9999999) AS temp LIMIT ? OFFSET ?';
    let results = await db.query(sql, [pagesize, offset, pagesize, offset]);
    res.json({
        status: true,
        msg: "获取成功",
        data: results,
    });
});

/**
 * @api {post} /notice/stick 置顶/取消置顶公告
 * @apiDescription 注意：置顶公告排序，多个置顶按照更新时间降序排列
 * @apiName StickNotice
 * @apiPermission 后台系统
 * @apiGroup Notice
 *
 * @apiBody { Number } id 公告id.
 * @apiBody { Number=1,0 } is_sticky 是否置顶。1-置顶，0-正常。
 *
 * @apiSampleRequest /notice/stick
 */
router.post('/stick', async (req, res) => {
    let { id, is_sticky } = req.body;
    const sql = 'UPDATE notice SET is_sticky = ? WHERE id = ?';
    let { affectedRows } = await db.query(sql, [is_sticky, id]);
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

module.exports = router;