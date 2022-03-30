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
 *
 * @apiSuccess {Object[]} data 幻灯片数组.
 *
 * @apiSampleRequest /slide/list
 */
router.get("/list", async (req, res) => {
    let { pagesize = 10, pageindex = 1 } = req.query;
    pagesize = parseInt(pagesize);
    const offset = pagesize * (pageindex - 1);
    const sql = 'SELECT * FROM slide WHERE available = 1 ORDER BY `order` DESC LIMIT ? OFFSET ?;SELECT COUNT(*) as total FROM `slide`';
    let [results] = await pool.query(sql, [pagesize, offset]);
    res.json({
        status: true,
        msg: "获取成功",
        ...results[1][0],
        data: results[0],
    });
});

module.exports = router;