const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {get} /operation/list 获取操作按钮列表
 * @apiName OperationList
 * @apiGroup Operation
 * @apiPermission 后台系统
 *
 * @apiQuery { Number } [pagesize=10] 每一页数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 *
 * @apiUse Authorization
 *
 * @apiSampleRequest /operation/list
 */

router.get('/list', async (req, res) => {
    let { pagesize = 10, pageindex = 1 } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    let offset = pagesize * (pageindex - 1);
    // 查询操作
    let select_sql = 'SELECT * FROM `sys_operation` LIMIT ? OFFSET ?';
    let [operations] = await pool.query(select_sql, [pagesize, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(*) as total FROM `sys_operation`';
    let [total] = await pool.query(total_sql, []);
    // 获取成功
    res.json({
        status: true,
        msg: "获取成功！",
        data: operations,
        ...total[0],
    });
});

/**
 * @api {post} /operation 添加新的操作按钮
 * @apiName InsertOperation
 * @apiGroup Operation
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody {String} operation_name 操作名称。
 * @apiBody {String} operation_code 操作代码。
 * @apiBody {String} operation_description 操作描述。
 *
 * @apiSampleRequest /operation
 */

router.post("/", async (req, res) => {
    let { operation_name, operation_code, operation_description } = req.body;
    // 创建新 operation
    let insert_operation_sql = 'INSERT INTO `sys_operation` (operation_name, operation_code, operation_description) VALUES (?,?,?)';
    let [{ insertId: operation_id, affectedRows: operation_affected_rows }] = await pool.query(insert_operation_sql, [operation_name, operation_code, operation_description]);
    if (operation_affected_rows === 0) {
        res.json({ status: false, msg: "添加 operation 失败！" });
        return;
    }
    // 创建成功
    res.json({
        status: true,
        msg: "创建成功!",
        data: { operation_id }
    });
});

/**
 * @api {delete} /operation/:operation_id 删除操作按钮
 * @apiName DeleteOperation
 * @apiGroup Operation
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam { Number } operation_id 操作id.
 *
 * @apiExample {js} 参数示例:
 * /operation/3
 *
 * @apiSampleRequest /operation
 */

router.delete('/:operation_id', async (req, res) => {
    let { operation_id } = req.params;
    let delete_operation_sql = 'DELETE FROM `sys_operation` WHERE operation_id = ?';
    let [{ affectedRows }] = await pool.query(delete_operation_sql, [operation_id]);
    // 删除失败
    if (affectedRows === 0) {
        res.json({ status: false, msg: "删除 operation 失败！" });
        return;
    }
    // 删除成功
    res.json({
        status: true,
        msg: "删除成功!",
    });
})

/**
 * @api {put} /operation/:operation_id 更新操作
 * @apiName UpdateOperation
 * @apiGroup Operation
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam { Number } operation_id 操作id.
 * @apiBody {String} operation_name 操作名称。
 * @apiBody {String} operation_code 操作代码。
 * @apiBody {String} operation_description 操作描述。
 *
 * @apiExample {js} 参数示例:
 * /operation/3
 *
 * @apiParamExample {json} body参数:
 * {
 *   "operation_name": '编辑',
 *   "operation_code": 'edit',
 *   "operation_description": '编辑操作',
 * }
 * @apiSampleRequest /operation
 */

router.put('/:operation_id', async (req, res) => {
    let { operation_id } = req.params;
    let { operation_name, operation_code, operation_description } = req.body;
    let sql = 'UPDATE `sys_operation` SET operation_name = ?, operation_code = ?, operation_description = ? WHERE operation_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [operation_name, operation_code, operation_description, operation_id]);
    if (affectedRows === 0) {
        res.json({ status: false, msg: "修改 operation 失败！" });
        return;
    }
    res.json({
        status: true,
        msg: "修改成功!",
    });
});

module.exports = router;