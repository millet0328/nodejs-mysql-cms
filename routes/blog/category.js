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
 * @apiQuery { String="flat","tree" } [type="flat"] 返回数据格式。flat--扁平数组；tree--树形结构
 *
 * @apiSampleRequest /category/list
 */
router.get('/list', async (req, res) => {
    let { type = 'flat' } = req.query;
    // 查询分类
    const sql = 'SELECT c1.*,c2.`name` AS parent_name FROM `category` c1 LEFT JOIN category c2 ON c1.parent_id = c2.id';
    let [results] = await pool.query(sql, []);
    // 扁平数组
    if (type === 'flat') {
        res.json({
            status: true,
            msg: "获取成功!",
            data: results
        });
        return;
    }
    // 树形结构
    if (type === 'tree') {
        // 筛选出一级菜单
        let cate_1st = results.filter((item) => item.parent_id === 0);
        // 转换为树形结构--递归函数
        const parseToTree = function (list) {
            return list.map((parent) => {
                let children = results.filter((child) => child.parent_id === parent.id);
                if (children.length) {
                    return { ...parent, children: parseToTree(children) }
                } else {
                    return { ...parent }
                }
            });
        }
        // 生成树形菜单
        let tree_cate = parseToTree(cate_1st);
        // 返回数据
        res.json({
            status: true,
            msg: "获取成功!",
            data: tree_cate
        });
    }
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
