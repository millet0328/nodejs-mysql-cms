const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {post} /route 添加路由
 * @apiName RouteInsert
 * @apiGroup Route
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody {String} route_title 路由标题文字。
 * @apiBody {String} route_name 路由名称。
 * @apiBody {String} route_path 路由地址。
 * @apiBody {String} route_full_path 路由完整地址。同时作为 permission_code 存储
 * @apiBody {String} component_name 路由组件名称。
 * @apiBody {String} component_path 路由组件路径。
 * @apiBody {Number} parent_id 父级路由权限的 permission_id，如果一级路由则 parent_id = 0。
 * @apiBody {String} [route_alias] 路由别名。
 * @apiBody {String=0,1} require_auth 是否需要登录认证，需要：1，不需要：0。
 * @apiBody {String} permission_remark 备注。
 *
 * @apiSampleRequest /route
 */

router.post("/", async (req, res) => {
    let { route_title, route_name, route_path, route_full_path, component_name, component_path, parent_id, route_alias, require_auth, permission_remark } = req.body;
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 创建 route 新路由
        let insert_route_sql = 'INSERT INTO `sys_route` (route_title, route_name, route_path, route_full_path, component_name, component_path, route_alias, require_auth) VALUES (?,?,?,?,?,?,?,?)';
        let [{ insertId: route_id, affectedRows: route_affected_rows }] = await connection.query(insert_route_sql, [route_title, route_name, route_path, route_full_path, component_name, component_path, route_alias, require_auth]);
        if (route_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "路由 route 创建失败！" });
            return;
        }
        // 创建 permission 新路由权限
        let insert_permission_sql = 'INSERT INTO `sys_permission` (parent_id, resource_id, resource_type_id, permission_code, permission_remark) VALUES (?,?,?,?,?)';
        let [{ insertId: permission_id, affectedRows: permission_affected_rows }] = await connection.query(insert_permission_sql, [parent_id, route_id, 1, route_full_path, permission_remark]);
        if (permission_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "权限 permission 创建失败！" });
            return;
        }
        // 创建 role_permission 关联，超级管理员默认拥有此权限。
        let insert_role_permission_sql = 'INSERT INTO `sys_role_permission` (role_id, permission_id) VALUES (?,?)';
        let [{ affectedRows: role_permission_affected_rows }] = await connection.query(insert_role_permission_sql, [1, permission_id]);
        if (role_permission_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "role_permission 关联，创建失败！" });
            return;
        }
        // 一切顺利，提交事务
        await connection.commit();
        // 创建成功
        res.json({
            status: true,
            msg: "创建成功!",
            data: { route_id, permission_id }
        });
    } catch (error) {
        await connection.rollback();
        res.status(500).json({
            status: false,
            msg: error.message,
            error,
        });
    }
});

/**
 * @api {put} /route/:route_id 更新路由
 * @apiName RouteUpdate
 * @apiGroup Route
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam {Number} route_id 路由id.
 * @apiBody {String} route_title 路由标题文字。
 * @apiBody {String} route_name 路由名称。
 * @apiBody {String} route_path 路由地址。
 * @apiBody {String} route_full_path 路由完整地址。同时作为 permission_code 存储
 * @apiBody {String} component_name 路由组件名称。
 * @apiBody {String} component_path 路由组件路径。
 * @apiBody {Number} parent_id 父级路由权限的 permission_id，如果一级路由则 parent_id = 0。
 * @apiBody {String} [route_alias] 路由别名。
 * @apiBody {String=0,1} require_auth 是否需要认证登录状态，需要认证：1，对外公开：0。
 * @apiBody {String} permission_remark 备注。
 *
 * @apiExample {js} 参数示例:
 * /route/3
 *
 * @apiSampleRequest /route/
 */
router.put("/:route_id", async (req, res) => {
    let { route_id } = req.params;
    let { route_title, route_name, route_path, route_full_path, component_name, component_path, parent_id, route_alias, require_auth, permission_remark } = req.body;
    // 获取一个连接
    const connection = await pool.getConnection();
    try {
        // 开启事务
        await connection.beginTransaction();
        // 更新 route 路由
        let update_route_sql = 'UPDATE `sys_route` SET route_title = ?, route_name = ?, route_path = ?, route_full_path = ?, component_name = ?, component_path = ?, route_alias = ?, require_auth = ? WHERE route_id = ?';
        let [{ affectedRows: route_affected_rows }] = await pool.query(update_route_sql, [route_title, route_name, route_path, route_full_path, component_name, component_path, route_alias, require_auth, route_id]);
        if (route_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "更新 route 失败！" });
            return;
        }
        // 更新 permission 权限
        let update_permission_sql = 'UPDATE `sys_permission` SET parent_id = ?, permission_code = ?, permission_remark = ? WHERE resource_id = ? AND resource_type_id = 1';
        let [{ affectedRows: permission_affected_rows }] = await pool.query(update_permission_sql, [parent_id, route_full_path, permission_remark, route_id]);
        if (permission_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "更新 permission 失败！" });
            return;
        }
        // 一切顺利，提交事务
        await connection.commit();
        // 更新成功
        res.json({
            status: true,
            msg: "更新路由成功!"
        });
    } catch (error) {
        await connection.rollback();
        res.status(500).json({
            status: false,
            msg: error.message,
            error,
        });
    }
});

/**
 * @api {delete} /route/:route_id 删除路由
 * @apiName RouteDelete
 * @apiGroup Route
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam {Number} route_id 路由id。
 * @apiQuery {Number} permission_id 权限id。
 *
 * @apiExample {js} 参数示例:
 * /route/3
 *
 * @apiSampleRequest /route
 */

router.delete("/:route_id", async (req, res) => {
    let { route_id } = req.params;
    let { permission_id } = req.query;
    let select_sql = 'SELECT * FROM `sys_permission` WHERE parent_id = ?';
    // 查询是否有子级路由
    let [results] = await pool.query(select_sql, [permission_id]);
    if (results.length > 0) {
        res.json({
            status: false,
            msg: "拥有子级路由，不允许删除！"
        });
        return;
    }
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 删除 route 路由
        let delete_route_sql = 'DELETE FROM `sys_route` WHERE route_id = ?';
        let [{ affectedRows: route_affected_rows }] = await connection.query(delete_route_sql, [route_id]);
        if (route_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "路由route删除失败！" });
            return;
        }
        // 删除 permission 路由权限
        let delete_permission_sql = 'DELETE FROM `sys_permission` WHERE permission_id = ?';
        let [{ affectedRows: permission_affected_rows }] = await connection.query(delete_permission_sql, [permission_id]);
        if (permission_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "路由权限 permission 删除失败！" });
            return;
        }
        // 删除 role_permission 关联，超级管理员默认拥有此权限。
        let delete_role_permission_sql = 'DELETE FROM `sys_role_permission` WHERE permission_id = ?';
        let [{ affectedRows: role_permission_affected_rows }] = await connection.query(delete_role_permission_sql, [permission_id]);
        if (role_permission_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "role_permission 关联，删除失败！" });
            return;
        }
        // 一切顺利，提交事务
        await connection.commit();
        // 创建成功
        res.json({
            status: true,
            msg: "删除成功!",
        });
    } catch (error) {
        await connection.rollback();
        res.status(500).json({
            status: false,
            msg: error.message,
            error,
        });
    }
});

/**
 * @api {get} /route/sub 获取子级路由
 * @apiName RouteSub
 * @apiGroup Route
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiQuery { Number } parent_id 父级路由权限的 permission_id。 注：获取一级路由 parent_id = 0;
 *
 * @apiSampleRequest /route/sub
 */
router.get("/sub", async (req, res) => {
    let { parent_id } = req.query;
    // TODO 精简字段
    let sql = 'SELECT route_id, route_name, route_path, route_alias, route_title, route_full_path, component_name, component_path, parent_id, permission_id, permission_remark, permission_code, require_auth FROM `role_route_view` WHERE parent_id = ? AND role_id = 1';
    let [results] = await pool.query(sql, [parent_id]);
    res.json({
        status: true,
        msg: "获取成功!",
        data: results
    });
});

/**
 * @api {get} /route/all 获取所有路由权限
 * @apiName AllRoute
 * @apiGroup Route
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiQuery { String="flat","tree" } [type="flat"] 返回数据格式。flat--扁平数组；tree--树形结构
 *
 * @apiSampleRequest /route/all
 */
router.get('/all', async (req, res) => {
    let { type = 'flat' } = req.query;
    // 查询路由
    let select_route_sql = 'SELECT route_id, route_name, route_path, route_alias, route_title, route_full_path, component_name, component_path, parent_id, permission_id, permission_remark, permission_code, require_auth FROM `role_route_view` WHERE role_id = 1';
    let [routes] = await pool.query(select_route_sql, []);
    // 扁平数组
    if (type === 'flat') {
        res.json({
            status: true,
            msg: "获取成功!",
            data: routes
        });
        return;
    }
    // 树形结构
    if (type === 'tree') {
        // 筛选出一级路由
        let route_1st = routes.filter((item) => item.parent_id === 0);
        // 转换为树形结构--递归函数
        const parseToTree = function (list) {
            return list.map((parent) => {
                let children = routes.filter((child) => child.parent_id === parent.permission_id);
                if (children.length) {
                    return { ...parent, children: parseToTree(children) }
                } else {
                    return { ...parent }
                }
            });
        }
        // 生成树形路由
        let tree_route = parseToTree(route_1st);
        // 查询成功
        res.json({
            status: true,
            msg: "获取成功!",
            data: tree_route
        });
    }
});

module.exports = router;