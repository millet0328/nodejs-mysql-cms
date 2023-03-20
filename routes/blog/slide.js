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
 * @apiQuery { Number=1,-1 } [usable] 是否启用。1-启用，-1-禁用。
 *
 * @apiSuccess {Object[]} data 幻灯片数组.
 *
 * @apiSampleRequest /slide/list
 */
router.get("/list", async (req, res) => {
    let { pagesize = 10, pageindex = 1, usable } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    const offset = pagesize * (pageindex - 1);
    // 根据参数，拼接SQL
    let select_sql = 'SELECT *, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time, DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time FROM `cms_slide` WHERE 1 = 1';
    if (usable) {
        select_sql += ` AND usable = ${usable}`
    }
    select_sql += ' ORDER BY `slide_order` ASC LIMIT ? OFFSET ?;'
    // 判断启用/禁用状态
    let [slides] = await pool.query(select_sql, [pagesize, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(*) as total FROM `cms_slide` WHERE 1 = 1';
    if (usable) {
        total_sql += ` AND usable = ${usable}`
    }
    let [total] = await pool.query(total_sql, []);

    res.json({
        status: true,
        msg: "获取成功",
        data: slides,
        ...total[0],
    });
});

module.exports = router;