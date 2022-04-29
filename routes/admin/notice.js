const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${token}`，登录/注册成功返回的token。
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
    const sql = 'INSERT INTO notice ( title , content , create_date , update_date , is_sticky ) VALUES (?, ? , CURRENT_TIMESTAMP() ,CURRENT_TIMESTAMP(), ?)';
    let [{ insertId, affectedRows }] = await pool.query(sql, [title, content, is_sticky]);
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
            id: insertId
        }
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
    let [{ affectedRows }] = await pool.query(sql, [id]);
    if (!affectedRows) {
        res.json({
            status: true,
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
    let [{ affectedRows }] = await pool.query(sql, [title, content, is_sticky, id]);
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
 * @api {post} /notice/stick 置顶/取消置顶公告
 * @apiDescription 注意：置顶公告排序，多个置顶按照更新时间降序排列
 * @apiName StickNotice
 * @apiPermission 后台系统
 * @apiGroup Notice
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 公告id.
 * @apiBody { Number=1,0 } is_sticky 是否置顶。1-置顶，0-正常。
 *
 * @apiSampleRequest /notice/stick
 */
router.post('/stick', async (req, res) => {
    let { id, is_sticky } = req.body;
    const sql = 'UPDATE notice SET is_sticky = ? WHERE id = ?';
    let [{ affectedRows }] = await pool.query(sql, [is_sticky, id]);
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