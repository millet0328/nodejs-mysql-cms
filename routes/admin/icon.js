const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${token}`，登录/注册成功返回的token。
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
    let sql = `SELECT * FROM ICON LIMIT ? OFFSET ?;SELECT COUNT(*) as total FROM ICON;`;
    let [results] = await pool.query(sql, [size, offset]);
    // 获取成功
    res.json({
        status: true,
        msg: "获取成功！",
        data: results[0],
        ...results[1][0],
    });
});

module.exports = router;
