const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${token}`，登录/注册成功返回的token。
 */

/**
 * @api {post} /link/ 添加友情链接
 * @apiName InsertLink
 * @apiPermission 后台系统
 * @apiGroup Link
 *
 * @apiUse Authorization
 *
 * @apiBody { String } title 链接标题.
 * @apiBody { String } url 链接的url地址.
 * @apiBody { Number } link_order 排序数字，数字越小越靠前.
 *
 * @apiSampleRequest /link/
 */

router.post("/", async (req, res) => {
    let { title, url, link_order } = req.body;
    const sql = 'INSERT INTO link ( title, url, link_order, create_date ) VALUES (?, ?, ?, CURRENT_TIMESTAMP() )';
    let [{ insertId, affectedRows }] = await pool.query(sql, [title, url, link_order]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "添加失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "添加成功",
        data: { id: insertId }
    });
});

/**
 * @api {delete} /link/:id 删除指定id的友情链接
 * @apiName RemoveLink
 * @apiPermission 后台系统
 * @apiGroup Link
 *
 * @apiUse Authorization
 *
 * @apiParam { Number } id 友情链接id
 *
 * @apiSampleRequest /link/
 */

router.delete('/:id', async (req, res) => {
    let { id } = req.params;
    // 删除标签
    let delete_sql = 'DELETE FROM link WHERE id = ?';
    let [{ affectedRows }] = await pool.query(delete_sql, [id]);
    if (affectedRows === 0) {
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
 * @api {put} /link/:id 编辑友情链接
 * @apiName UpdateLink
 * @apiPermission 后台系统
 * @apiGroup Link
 *
 * @apiUse Authorization
 *
 * @apiParam { Number } id 友情链接id
 * @apiBody { String } title 链接标题.
 * @apiBody { String } url 链接的url地址.
 * @apiBody { Number } link_order 排序数字，数字越小越靠前.
 *
 * @apiExample {js} 参数示例:
 * /link/3
 *
 * @apiSampleRequest /link/
 */

router.put('/:id', async (req, res) => {
    let { id } = req.params;
    let { title, url, link_order } = req.body;
    let sql = `UPDATE link SET title = ?, url = ?, link_order = ? WHERE id = ?`;
    let [{ affectedRows }] = await pool.query(sql, [title, url, link_order, id]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "修改失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "修改成功!",
    });
});

module.exports = router;