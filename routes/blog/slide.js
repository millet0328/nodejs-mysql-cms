const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @api {get} /slide/list 获取所有幻灯片列表
 * @apiName SlideList
 * @apiPermission 后台系统、前台
 * @apiGroup Slide
 *
 * @apiQuery { Number } [pagesize=10] 每一页幻灯片数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 * @apiQuery { Number=1,-1 } [available] 是否启用。1-启用，-1-禁用。
 *
 * @apiSuccess {Object[]} data 幻灯片数组.
 *
 * @apiSampleRequest /slide/list
 */
router.get("/list", async (req, res) => {
    let { pagesize = 10, pageindex = 1, available } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    const offset = pagesize * (pageindex - 1);
    // 根据参数，拼接SQL
    let select_sql = 'SELECT *, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time FROM slide WHERE 1 = 1';
    if (available) {
        select_sql += ` AND available = ${available}`
    }
    select_sql += ' ORDER BY `slide_order` ASC LIMIT ? OFFSET ?;SELECT COUNT(*) as total FROM `slide`'
    // 判断启用/禁用状态
    let [results] = await pool.query(select_sql, [pagesize, offset]);
    res.json({
        status: true,
        msg: "获取成功",
        ...results[1][0],
        data: results[0],
    });
});

module.exports = router;