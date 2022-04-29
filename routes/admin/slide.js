const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');
// 文件模块
const path = require('path')
const fs = require('fs/promises');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${token}`，登录/注册成功返回的token。
 */

/**
 * @api {post} /slide/add 添加新的幻灯片
 * @apiName AddSlide
 * @apiPermission 后台系统
 * @apiGroup Slide
 *
 * @apiUse Authorization
 *
 * @apiBody { String } [title] 幻灯片标题文字.
 * @apiBody { String } picture 图片地址.
 * @apiBody { String } url 跳转的url地址.
 * @apiBody { String='_blank','_self' } target='_blank' 跳转方式，在新窗口中打开链接：_blank，在本窗口打开链接：_self。
 * @apiBody { Number } slide_order 排序数字，数字越小越靠前.
 *
 * @apiSampleRequest /slide/add
 */

router.post("/add/", async (req, res) => {
    let { title, picture, url, target = '_blank', slide_order } = req.body;
    const sql = 'INSERT INTO slide ( title, picture, url, target, slide_order, create_date ) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP() )';
    let [{ insertId, affectedRows }] = await pool.query(sql, [title, picture, url, target, slide_order]);
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
    // 查询幻灯片的图片地址
    const select_sql = 'SELECT * FROM slide WHERE id = ?';
    let [results] = await pool.query(select_sql, [id]);
    let { picture } = results[0];
    // 计算真实地址
    let src = picture.replace(/.+\/images/, "./images");
    let realPath = path.resolve(__dirname, '../../public/', src);
    try {
        // 物理删除幻灯片
        await fs.unlink(realPath);
        // 删除slide表数据
        const delete_sql = 'DELETE FROM slide WHERE id = ?';
        let [{ affectedRows }] = await pool.query(delete_sql, [id]);
        if (affectedRows === 0) {
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
    } catch (error) {
        res.json({
            status: false,
            msg: "幻灯片删除失败!",
            error: error.message,
        });
    }
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
 * @apiBody { Number } slide_order 排序数字，数字越小越靠前.
 *
 * @apiSampleRequest /slide/edit
 */
router.post('/edit', async (req, res) => {
    let { id, title, picture, url, target = '_blank', slide_order } = req.body;
    const sql = 'UPDATE slide SET title = ?, picture = ?, url = ?, target = ?, slide_order = ? WHERE id = ?';
    let [{ affectedRows }] = await pool.query(sql, [title, picture, url, target, slide_order, id]);
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
 * @api {post} /slide/usable 启用/禁用幻灯片
 * @apiName UsableSlide
 * @apiPermission 后台系统
 * @apiGroup Slide
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 幻灯片id.
 * @apiBody { Number=1,-1 } usable 是否启用。1-启用，-1-禁用。
 *
 * @apiSampleRequest /slide/usable
 */
router.post('/usable', async (req, res) => {
    let { id, usable } = req.body;
    const sql = 'UPDATE slide SET usable = ? WHERE id = ?';
    let [{ affectedRows }] = await pool.query(sql, [usable, id]);
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