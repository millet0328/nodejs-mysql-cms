const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {post} /category/add 添加分类
 * @apiDescription 注意：目前最多支持二级分类
 * @apiName AddCategory
 * @apiPermission 后台系统
 * @apiGroup Category
 *
 * @apiUse Authorization
 *
 * @apiBody { String } cate_name 分类名称。
 * @apiBody { Number } parent_id 父级分类id。如果一级分类则 parent_id = 0
 *
 * @apiSampleRequest /category/add
 */

router.post("/add", async (req, res) => {
    let { cate_name, parent_id } = req.body;
    const sql = 'INSERT INTO `cms_category` (cate_name, parent_id, create_date) VALUES (?, ?, CURRENT_TIMESTAMP() );'
    let [{ insertId: cate_id }] = await pool.query(sql, [cate_name, parent_id]);
    res.json({
        status: true,
        msg: "添加成功！",
        data: { cate_id }
    });
});
/**
 * @api {post} /category/remove 删除指定id分类
 * @apiDescription 注意：删除指定id分类,如果其拥有子级分类不允许删除，必须清空子分类才可删除。
 * @apiName RemoveCategory
 * @apiPermission 后台系统
 * @apiGroup Category
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } cate_id 分类id
 *
 * @apiSampleRequest /category/remove
 */

router.post("/remove", async (req, res) => {
    let { cate_id } = req.body;
    let select_sql = 'SELECT * FROM `cms_category` WHERE parent_id = ?';
    let [results] = await pool.query(select_sql, [cate_id]);
    if (results.length) {
        res.json({
            status: false,
            msg: "拥有子级分类，不允许删除！"
        });
        return;
    }
    let delete_sql = 'DELETE FROM `cms_category` WHERE cate_id = ?'
    let [{ affectedRows }] = await pool.query(delete_sql, [cate_id]);
    if (affectedRows) {
        res.json({
            status: true,
            msg: "删除成功"
        });
    }
});
/**
 * @api {get} /category/detail 获取指定id的分类详情
 * @apiName CategoryDetail
 * @apiPermission 后台系统
 * @apiGroup Category
 *
 * @apiUse Authorization
 *
 * @apiQuery { Number } cate_id 分类id
 *
 * @apiSampleRequest /category/detail
 */
router.get("/detail", async (req, res) => {
    let { cate_id } = req.query;
    const sql = 'SELECT * FROM `cms_category` WHERE cate_id = ?';
    let [results] = await pool.query(sql, [cate_id]);
    res.json({
        status: true,
        data: results[0]
    });
});
//
/**
 * @api {post} /category/edit 编辑指定id分类
 * @apiName EditCategory
 * @apiPermission 后台系统
 * @apiGroup Category
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } cate_id 分类id
 * @apiBody { String } cate_name 分类名称.
 * @apiBody { Number } parent_id 父级分类id。如果一级分类则 parent_id = 0
 *
 * @apiSampleRequest /category/edit
 */
router.post('/edit', async (req, res) => {
    const sql = 'UPDATE `cms_category` SET cate_name = ?, parent_id = ? WHERE cate_id = ?';
    let { cate_id, cate_name, parent_id } = req.body;
    let [{ affectedRows }] = await pool.query(sql, [cate_name, parent_id, cate_id]);
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
