const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {post} /menu 添加子级菜单
 * @apiName MenuInsert
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody {String} menu_name 菜单名称.
 * @apiBody {Number} [route_id=null] 关联路由id，无关联路由则为null.
 * @apiBody {String} menu_order 菜单显示顺序，按照数字从小到大排序，如2001，3002。
 * @apiBody {Number} parent_id 父级菜单权限的 permission_id，一级菜单的 parent_id = 0。
 * @apiBody {String} permission_code 权限代码，例如：link:edit。
 * @apiBody {String} permission_remark 权限备注。
 *
 * @apiSampleRequest /menu
 */
router.post("/", async (req, res) => {
    let { menu_name, route_id = null, menu_order, parent_id, permission_code, permission_remark } = req.body;
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 创建新菜单 menu
        let insert_menu_sql = 'INSERT INTO `sys_menu` (menu_name, route_id, menu_order) VALUES (?,?,?)';
        let [{ insertId: menu_id, affectedRows: menu_affected_rows }] = await connection.query(insert_menu_sql, [menu_name, route_id, menu_order]);
        if (menu_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "菜单 menu 创建失败！" });
            return;
        }
        // 创建新菜单权限 permission
        let insert_permission_sql = 'INSERT INTO `sys_permission` (parent_id, resource_id, resource_type_id, permission_code, permission_remark) VALUES (?,?,?,?,?)';
        let [{ insertId: permission_id, affectedRows: permission_affected_rows }] = await connection.query(insert_permission_sql, [parent_id, menu_id, 2, permission_code, permission_remark]);
        if (permission_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "菜单权限 permission 创建失败！" });
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
            data: { menu_id, permission_id }
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
 * @api {delete} /menu/:menu_id 删除指定id的菜单
 * @apiName MenuDelete
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam {Number} menu_id 菜单id.
 * @apiQuery {Number} permission_id 权限id。
 *
 * @apiExample {js} 参数示例:
 * /menu/3
 *
 * @apiSampleRequest /menu
 */
router.delete("/:menu_id", async (req, res) => {
    let { menu_id } = req.params;
    let { permission_id } = req.query;
    // 查询是否有子级菜单
    let select_sql = 'SELECT * FROM `sys_permission` WHERE parent_id = ?';
    let [results] = await pool.query(select_sql, [permission_id]);
    if (results.length > 0) {
        res.json({
            status: false,
            msg: "拥有子级元素，不允许删除！"
        });
        return;
    }
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 删除 menu 菜单
        let delete_menu_sql = 'DELETE FROM `sys_menu` WHERE menu_id = ?';
        let [{ affectedRows: menu_affected_rows }] = await connection.query(delete_menu_sql, [menu_id]);
        if (menu_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "菜单 menu 删除失败！" });
            return;
        }
        // 删除 permission 菜单权限
        let delete_permission_sql = 'DELETE FROM `sys_permission` WHERE permission_id = ?';
        let [{ affectedRows: permission_affected_rows }] = await connection.query(delete_permission_sql, [permission_id]);
        if (permission_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "菜单权限 permission 删除失败！" });
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
 * @api {put} /menu/:menu_id 更新指定id的菜单
 * @apiName MenuUpdate
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam {Number} menu_id 菜单id.
 * @apiBody {String} menu_name 菜单名称.
 * @apiBody {Number} [route_id] 关联路由id.
 * @apiBody {String} menu_order 菜单显示顺序，按照数字从小到大排序，如2001，3002。
 * @apiBody {Number} parent_id 父级菜单权限的 permission_id，一级菜单的 parent_id = 0。
 * @apiBody {Number} permission_id 权限id。
 * @apiBody {String} permission_code 权限代码，例如：link:edit。
 * @apiBody {String} permission_remark 权限备注。
 *
 * @apiExample {js} 参数示例:
 * /menu/3
 *
 * @apiSampleRequest /menu/
 */
router.put("/:menu_id", async (req, res) => {
    let { menu_id } = req.params;
    let { menu_name, route_id, menu_order, parent_id, permission_id, permission_code, permission_remark } = req.body;
    // 获取一个连接
    const connection = await pool.getConnection();
    try {
        // 开启事务
        await connection.beginTransaction();
        // 更新 menu 路由
        let update_menu_sql = 'UPDATE `sys_menu` SET menu_name = ?, route_id = ?, menu_order = ? WHERE menu_id = ?';
        let [{ affectedRows: menu_affected_rows }] = await pool.query(update_menu_sql, [menu_name, route_id, menu_order, menu_id]);
        if (menu_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "更新 menu 失败！" });
            return;
        }
        // 更新 permission 权限
        let update_permission_sql = 'UPDATE `sys_permission` SET parent_id = ?, permission_code = ?, permission_remark = ? WHERE permission_id = ? AND resource_type_id = 2';
        let [{ affectedRows: permission_affected_rows }] = await pool.query(update_permission_sql, [parent_id, permission_code, permission_remark, permission_id]);
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
            msg: "更新菜单成功!"
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
 * @api {put} /menu/icon/:menu_id 设置指定id的菜单图标
 * @apiName MenuUpdateIcon
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam { Number } menu_id 菜单id.
 * @apiBody { String } icon_id element图标id.
 *
 * @apiExample {js} 参数示例:
 * /menu/icon/3
 *
 * @apiSampleRequest /menu/icon
 */
router.put("/icon/:menu_id", async (req, res) => {
    let { menu_id } = req.params;
    let { icon_id } = req.body;
    let sql = 'UPDATE `sys_menu` SET icon_id = ? WHERE menu_id = ? ';
    let [{ affectedRows }] = await pool.query(sql, [icon_id, menu_id]);
    if (affectedRows === 0) {
        res.json({ status: false, msg: "设置图标失败！" });
        return;
    }
    // 设置成功
    res.json({
        status: true,
        msg: "设置图标成功!"
    });
});
/**
 * @api {get} /menu/sub 获取子级菜单
 * @apiName MenuSub
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiQuery { Number } parent_id 父级菜单权限的 permission_id。 注： 获取一级菜单 parent_id = 0;
 *
 * @apiSampleRequest /menu/sub
 */
router.get("/sub", async (req, res) => {
    let { parent_id } = req.query;
    let sql = 'SELECT * FROM `role_menu_view` WHERE parent_id = ? AND role_id = 1 ORDER BY menu_order';
    let [results] = await pool.query(sql, [parent_id]);
    res.json({
        status: true,
        msg: "获取成功!",
        data: results
    });
});

/**
 * @api {get} /menu/all 获取所有菜单 + 操作按钮
 * @apiDescription 包含菜单权限、操作按钮权限，根据 resource_type_id 区分类型。
 * @apiName AllMenu
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiQuery { String="flat","tree" } [type="flat"] 返回数据格式。flat--扁平数组；tree--树形结构
 *
 * @apiSampleRequest /menu/all
 */

router.get('/all', async (req, res) => {
    let { type = "flat" } = req.query;
    // 查询 menu 菜单
    let select_menu_sql = 'SELECT * FROM `role_menu_view` WHERE role_id = 1 ORDER BY menu_order';
    let [menus] = await pool.query(select_menu_sql, []);
    // 查询 operation 操作按钮
    let select_operation_sql = 'SELECT * FROM `role_operation_view` WHERE role_id = 1';
    let [operations] = await pool.query(select_operation_sql, []);
    // 将两部分合并成一个数组
    let all_menu = [...menus, ...operations];
    // 扁平数组
    if (type === 'flat') {
        res.json({
            status: true,
            msg: "获取成功!",
            data: all_menu
        });
        return;
    }
    // 树形结构
    if (type === 'tree') {
        // 筛选出一级菜单
        let menu_1st = all_menu.filter((item) => item.parent_id === 0);
        // 转换为树形结构--递归函数
        const parseToTree = function (list) {
            return list.map((parent) => {
                let children = all_menu.filter((child) => child.parent_id === parent.permission_id);
                if (children.length) {
                    return { ...parent, children: parseToTree(children) }
                } else {
                    return { ...parent }
                }
            });
        }
        // 生成树形菜单
        let tree_menu = parseToTree(menu_1st);
        // 查询成功
        res.json({
            status: true,
            msg: "获取成功!",
            data: tree_menu
        });
    }
});

/**
 * @api {post} /menu/operation 菜单页面--添加新的操作按钮
 * @apiName MenuInsertOperation
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody {String} operation_id 操作id。
 * @apiBody {String} parent_id 父级菜单权限的 permission_id，一级菜单的 parent_id = 0。
 * @apiBody {String} permission_code 权限代码，例如：link:edit。
 * @apiBody {String} permission_remark 权限备注。
 *
 * @apiSampleRequest /menu/operation
 */

router.post("/operation", async (req, res) => {
    let { operation_id, parent_id, permission_code, permission_remark } = req.body;
    // 获取一个连接
    const connection = await pool.getConnection();
    try {
        // 开启事务
        await connection.beginTransaction();
        // 创建新操作权限 permission
        let insert_permission_sql = 'INSERT INTO `sys_permission` (parent_id, resource_id, resource_type_id, permission_code, permission_remark) VALUES (?,?,?,?,?)';
        let [{ insertId: permission_id, affectedRows: permission_affected_rows }] = await pool.query(insert_permission_sql, [parent_id, operation_id, 3, permission_code, permission_remark]);
        if (permission_affected_rows === 0) {
            res.json({ status: false, msg: "操作权限 permission 创建失败！" });
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
            data: { permission_id }
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
 * @api {put} /menu/operation/:permission_id 菜单页面--编辑操作按钮
 * @apiName MenuEditOperation
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam { Number } permission_id 权限id。
 * @apiBody { Number } operation_id 操作id。
 * @apiBody { String } permission_code 权限代码，例如：link:edit。
 * @apiBody { String } permission_remark 权限备注。
 *
 * @apiExample {js} 参数示例:
 * /menu/operation/3
 *
 * @apiSampleRequest /menu/operation/
 */

router.put("/operation/:permission_id", async (req, res) => {
    let { permission_id } = req.params;
    let { operation_id, permission_code, permission_remark } = req.body;

    let sql = 'UPDATE `sys_permission` SET resource_id = ?, permission_code = ?, permission_remark = ? WHERE permission_id = ? ';
    let [{ affectedRows }] = await pool.query(sql, [operation_id, permission_code, permission_remark, permission_id]);
    if (affectedRows === 0) {
        res.json({ status: false, msg: "修改失败！" });
        return;
    }
    // 设置成功
    res.json({
        status: true,
        msg: "修改操作按钮成功!"
    });
});

/**
 * @api {delete} /menu/operation/:permission_id 菜单页面--删除指定id的操作按钮
 * @apiName MenuDeleteOperation
 * @apiGroup Menu
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam {Number} permission_id 菜单id.
 *
 * @apiExample {js} 参数示例:
 * /menu/operation/3
 *
 * @apiSampleRequest /menu/operation/
 */

router.delete("/operation/:permission_id", async (req, res) => {
    let { permission_id } = req.params;
    // 查询是否有子级
    let select_sql = 'SELECT * FROM `sys_permission` WHERE parent_id = ?';
    let [results] = await pool.query(select_sql, [permission_id]);
    if (results.length > 0) {
        res.json({
            status: false,
            msg: "拥有子级元素，不允许删除！"
        });
        return;
    }
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 删除 permission 操作权限
        let delete_permission_sql = 'DELETE FROM `sys_permission` WHERE permission_id = ?';
        let [{ affectedRows: permission_affected_rows }] = await connection.query(delete_permission_sql, [permission_id]);
        if (permission_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "操作权限 permission 删除失败！" });
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

module.exports = router;
