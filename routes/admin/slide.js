const express = require('express');
const router = express.Router();
// 数据库
let db = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 登录或者注册之后返回的token，请设置在request header中.
 */

/**
 * @api {post} /slide/add 添加新的幻灯片
 * @apiName AddSlide
 * @apiPermission 后台系统
 * @apiGroup Slide
 *
 * @apiUse Authorization
 *
 * @apiBody { String } title 幻灯片标题文字.
 * @apiBody { String } picture 图片地址.
 * @apiBody { String } url 跳转的url地址.
 * @apiBody { String='_blank','_self' } target='_blank' 跳转方式，在新窗口中打开链接：_blank，在本窗口打开链接：_self。
 * @apiBody { Number } order 排序数字，数字越小越靠前.
 *
 * @apiSampleRequest /slide/add
 */

router.post("/add/", async (req, res) => {
    let { title, picture, url, target = '_blank', order } = req.body;
    const sql = 'INSERT INTO slide ( title, picture, url, target, order ) VALUES (?, ?, ?, ?, ?)';
    let { insertId, affectedRows } = await db.query(sql, [title, picture, url, target, order]);
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
 * @api {post} /slide/remove 删除指定id的幻灯片
 * @apiName RemoveSlide
 * @apiPermission 后台系统
 * @apiGroup Slide
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 幻灯片id
 *
 * @apiSampleRequest /slide/remove
 */

router.post('/remove', async (req, res) => {
    let { id } = req.body;
    const sql = 'DELETE FROM slide WHERE id = ?';
    let { affectedRows } = await db.query(sql, [id]);
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
 * @api {post} /slide/edit 编辑指定id幻灯片
 * @apiName EditSlide
 * @apiPermission 后台系统
 * @apiGroup Slide
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 幻灯片id.
 * @apiBody { String } title 幻灯片标题文字.
 * @apiBody { String } picture 图片地址.
 * @apiBody { String } url 跳转的url地址.
 * @apiBody { String='_blank','_self' } target='_blank' 跳转方式，在新窗口中打开链接：_blank，在本窗口打开链接：_self。
 * @apiBody { Number } order 排序数字，数字越小越靠前.
 *
 * @apiSampleRequest /slide/edit
 */
router.post('/edit', async (req, res) => {
    let { id, title, picture, url, target = '_blank', order } = req.body;
    const sql = 'UPDATE slide SET title = ?, picture = ?, url = ?, target = ?, order = ? WHERE id = ?';
    let { affectedRows } = await db.query(sql, [title, picture, url, target, order, id]);
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
 * @api {post} /slide/switch 启用/禁用幻灯片
 * @apiName SwitchSlide
 * @apiPermission 后台系统
 * @apiGroup Slide
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 幻灯片id.
 * @apiBody { Number=1,0 } available 是否启用。1-启用，0-禁用。
 *
 * @apiSampleRequest /slide/switch
 */
router.post('/switch', async (req, res) => {
    let { id, available } = req.body;
    const sql = 'UPDATE slide SET available = ? WHERE id = ?';
    let { affectedRows } = await db.query(sql, [available, id]);
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