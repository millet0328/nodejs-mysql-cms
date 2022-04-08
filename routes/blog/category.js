const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @api {get} /category/list 获取所有分类
 * @apiName CategoryList
 * @apiPermission 后台系统、前台
 * @apiGroup Category
 *
 * @apiSampleRequest /category/list
 */
router.get('/list', async (req, res) => {
    const sql = 'SELECT c1.*,c2.`name` AS parent_name FROM `category` c1 LEFT JOIN category c2 ON c1.parent_id = c2.id';
    let [results] = await pool.query(sql);
    res.json({
        status: true,
        data: results
    });
});

/**
 * @api {get} /category/sub 获取子级分类
 * @apiName CategorySub
 * @apiPermission 后台系统、前台
 * @apiGroup Category
 *
 * @apiQuery { Number } id 父级id。一级分类的父类id=0;
 *
 * @apiSampleRequest /category/sub
 */
router.get("/sub", async (req, res) => {
    let { id } = req.query;
    let sql = 'SELECT * FROM category WHERE parent_id = ?';
    let [results] = await pool.query(sql, [id]);
    res.json({
        status: true,
        data: results
    });
});

module.exports = router;
