const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @api {get} /link/list 获取所有友情链接列表
 * @apiName LinkList
 * @apiPermission 后台系统、前台
 * @apiGroup Link
 *
 * @apiQuery { Number } [pagesize=10] 每一页数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 * @apiQuery { Number=1,-1 } [usable] 是否启用。1-启用，-1-禁用。
 *
 * @apiSuccess {Object[]} data 友情链接数组.
 *
 * @apiSampleRequest /link/list
 */

router.get("/list", async (req, res) => {
    let { pagesize = 10, pageindex = 1, usable } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    const offset = pagesize * (pageindex - 1);
    // 获取友情链接
    let select_sql = 'SELECT *, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time FROM `cms_link` WHERE 1 = 1';
    if (usable) {
        select_sql += ` AND usable = ${usable}`
    }
    select_sql += ' ORDER BY `link_order` ASC LIMIT ? OFFSET ?';
    let [links] = await pool.query(select_sql, [pagesize, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(link_id) as total FROM `cms_link` WHERE 1 = 1';
    if (usable) {
        total_sql += ` AND usable = ${usable}`
    }
    let [total] = await pool.query(total_sql, []);
    res.json({
        status: true,
        msg: "获取成功",
        data: links,
        ...total[0],
    });
});


module.exports = router;