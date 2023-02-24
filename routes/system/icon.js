const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {get} /icon/list 获取所有element图标
 * @apiDescription 获取系统中的element图标，具备分页功能。
 * @apiName AdminIcon
 * @apiGroup Icon
 * @apiPermission admin
 *
 * @apiUse Authorization
 *
 * @apiQuery {Number} [pageSize=20] 一个页有多少个图标;
 * @apiQuery {Number} [pageIndex=1] 第几页;
 *
 * @apiSuccess {Object[]} icons 图标数组.
 * @apiSuccess {Number} total 图标总数.
 *
 * @apiSampleRequest /icon/list
 */
router.get('/list', async (req, res) => {
    let { pageSize = 20, pageIndex = 1 } = req.query;
    let size = parseInt(pageSize);
    let offset = size * (pageIndex - 1);
    // 查询列表
    let select_sql = 'SELECT * FROM `sys_icon` LIMIT ? OFFSET ?';
    let [icons] = await pool.query(select_sql, [size, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(*) as total FROM `sys_icon`';
    let [total] = await pool.query(total_sql, []);
    // 获取成功
    res.json({
        status: true,
        msg: "获取成功！",
        data: icons,
        ...total[0],
    });
});

module.exports = router;
