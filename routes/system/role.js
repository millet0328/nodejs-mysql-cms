const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {get} /role/list 获取角色列表
 * @apiName RoleList
 * @apiGroup Role
 * @apiPermission 后台系统
 *
 * @apiQuery { Number } [pagesize=10] 每一页数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 *
 * @apiUse Authorization
 *
 * @apiSampleRequest /role/list
 */

router.get('/list', async (req, res) => {
    let { pagesize = 10, pageindex = 1 } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    let offset = pagesize * (pageindex - 1);
    // 查询角色
    let select_sql = 'SELECT * FROM `sys_role` LIMIT ? OFFSET ?';
    let [roles] = await pool.query(select_sql, [pagesize, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(*) as total FROM `sys_role`';
    let [total] = await pool.query(total_sql, []);
    // 获取成功
    res.json({
        status: true,
        msg: "获取成功！",
        data: roles,
        ...total[0],
    });
});

/**
 * @api {post} /role 添加角色
 * @apiName InsertRole
 * @apiGroup Role
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody {String} role_name 角色名称。
 * @apiBody {String} role_code 角色代码。
 * @apiBody {String} role_description 角色描述。
 *
 * @apiSampleRequest /role
 */

router.post('/', async (req, res) => {
    let { role_name, role_code, role_description } = req.body;
    let sql = 'INSERT INTO `sys_role` (role_name, role_code, role_description) VALUES (?,?,?)';
    let [{ insertId: role_id }] = await pool.query(sql, [role_name, role_code, role_description]);
    res.json({
        status: true,
        msg: "添加成功!",
        data: { role_id }
    });
});

/**
 * @api {delete} /role/:role_id 删除角色
 * @apiName DeleteRole
 * @apiGroup Role
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam {String} role_id 角色id.
 *
 * @apiExample {js} 参数示例:
 * /role/3
 *
 * @apiSampleRequest /role
 */

router.delete('/:role_id', async (req, res) => {
    let { role_id } = req.params;
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 删除角色
        let delete_role_sql = 'DELETE FROM `sys_role` WHERE role_id = ?';
        let [{ affectedRows: role_affected_rows }] = await connection.query(delete_role_sql, [role_id]);
        if (role_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "删除role失败！" });
            return;
        }

        // 删除 sys_user_role 关联数据
        let delete_admin_sql = 'DELETE FROM `sys_user_role` WHERE role_id = ?'
        await connection.query(delete_admin_sql, [role_id]);

        // 删除 role_permission 关联数据
        let delete_permission_sql = 'DELETE FROM `sys_role_permission` WHERE role_id = ?'
        await connection.query(delete_permission_sql, [role_id]);

        // 一切顺利，提交事务
        await connection.commit();
        // 设置成功
        res.json({
            status: true,
            msg: "删除成功！"
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
 * @api {put} /role/:role_id 更新角色
 * @apiName UpdateRole
 * @apiGroup Role
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam {String} role_id 角色id.
 * @apiBody {String} role_name 角色名称。
 * @apiBody {String} role_code 角色代码。
 * @apiBody {String} role_description 角色描述。
 *
 * @apiExample {js} 参数示例:
 * /role/3
 *
 * @apiParamExample {json} body参数:
 * {
 *   "name": '库管',
 * }
 * @apiSampleRequest /role
 */

router.put('/:role_id', async (req, res) => {
    let { role_id } = req.params;
    let { role_name, role_code, role_description } = req.body;
    let sql = 'UPDATE `sys_role` SET role_name = ?, role_code = ?, role_description = ? WHERE role_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [role_name, role_code, role_description, role_id]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "修改失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "修改成功!",
    });
});

/**
 * @api {get} /role/route/ 根据角色id，获取路由权限
 * @apiName RoleRoute
 * @apiGroup Role
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiQuery {Number} role_id 角色id.
 * @apiQuery { String="flat","tree" } [type="flat"] 返回数据格式。flat--扁平数组；tree--树形结构
 *
 * @apiSampleRequest /role/route/
 */
router.get('/route/', async (req, res) => {
    let { role_id, type = 'flat' } = req.query;
    // 查询菜单
    let select_route_sql = 'SELECT * FROM `role_route_view` WHERE role_id = ?';
    let [routes] = await pool.query(select_route_sql, [role_id]);
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
        // 筛选出一级菜单
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
        // 生成树形菜单
        let tree_route = parseToTree(route_1st);
        // 查询成功
        res.json({
            status: true,
            msg: "获取成功!",
            data: tree_route
        });
    }
});

/**
 * @api {get} /role/menu/ 根据角色id，获取菜单权限
 * @apiName RoleMenu
 * @apiGroup Role
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiQuery {Number} role_id 角色id.
 * @apiQuery { String="flat","tree" } [type="flat"] 返回数据格式。flat--扁平数组；tree--树形结构
 *
 * @apiSampleRequest /role/menu/
 */
router.get('/menu/', async (req, res) => {
    let { role_id, type = 'flat' } = req.query;
    // 查询 menu 菜单
    let select_menu_sql = 'SELECT * FROM `role_menu_view` WHERE role_id = ? ORDER BY menu_order';
    let [menus] = await pool.query(select_menu_sql, [role_id]);
    // 查询 operation 操作按钮
    let select_operation_sql = 'SELECT * FROM `role_operation_view` WHERE role_id = ?';
    let [operations] = await pool.query(select_operation_sql, [role_id]);
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
 * @api {post} /role/route 配置角色--路由权限
 * @apiName SetRoleRoute
 * @apiGroup Role
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody {Number} role_id 角色id.
 * @apiBody {Number[]} permissions 由 permission_id 组成的数组，例如：[1,3,6,9,7,15].
 *
 * @apiSampleRequest /role/route
 */

router.post('/route', async (req, res) => {
    let { role_id, permissions: insert_permissions } = req.body;
    // 获取已存在的权限id
    const select_permission_sql = 'SELECT p.* FROM `sys_role_permission` rp JOIN `sys_permission` p ON rp.permission_id = p.permission_id WHERE rp.role_id = ? AND p.resource_type_id = 1';
    let [exist_permissions] = await pool.query(select_permission_sql, [role_id]);
    exist_permissions = exist_permissions.map((item) => item.permission_id);
    // exist_permissions 数组中有这些id，而 insert_permissions 数组中没有这些id，筛选出来这部分id，将会删除它们
    let rest_exist_permissions = exist_permissions.filter((item) => {
        return !insert_permissions.includes(item);
    });
    // insert_permissions 数组中有这些id，而 exist_permissions 数组中没有这些id，筛选出来这部分id，将会添加它们
    let rest_insert_permissions = insert_permissions.filter((item) => {
        return !exist_permissions.includes(item);
    });
    // 转化数组格式
    rest_insert_permissions = rest_insert_permissions.map((item) => `(${role_id},${item})`);

    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 根据 rest_exist_menus 删除数据，数组为空,不需要删除数据
        if (rest_exist_permissions.length) {
            let delete_permission_sql = `DELETE FROM sys_role_permission WHERE role_id = ? AND permission_id IN (${rest_exist_permissions.toString()})`;
            let [{ affectedRows: permission_affected_rows }] = await connection.query(delete_permission_sql, [role_id]);
            if (permission_affected_rows === 0) {
                await connection.rollback();
                res.json({ status: false, msg: "删除原有 permission 失败！" });
                return;
            }
        }
        // 根据 rest_insert_menus 插入数据，数组为空,不需要插入数据
        if (rest_insert_permissions.length) {
            let insert_permission_sql = `INSERT INTO sys_role_permission (role_id, permission_id) VALUES ${rest_insert_permissions.toString()}`;
            let [{ affectedRows: permission_affected_rows }] = await connection.query(insert_permission_sql, []);
            if (permission_affected_rows === 0) {
                await connection.rollback();
                res.json({ status: false, msg: "插入新的 permission 失败！" });
                return;
            }
        }
        // 一切顺利，提交事务
        await connection.commit();
        // 设置成功
        res.json({
            status: true,
            msg: "设置成功"
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
 * @api {post} /role/menu 配置角色--菜单权限，操作权限
 * @apiName SetRoleMenu
 * @apiGroup Role
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody {Number} role_id 角色id.
 * @apiBody {Number[]} permissions 由 permission_id 组成的数组，例如：[1,3,6,9,7,15].
 *
 * @apiSampleRequest /role/menu
 */

router.post('/menu', async (req, res) => {
    let { role_id, permissions: insert_permissions } = req.body;
    // 获取已存在的权限id
    const select_permission_sql = 'SELECT p.* FROM `sys_role_permission` rp JOIN `sys_permission` p ON rp.permission_id = p.permission_id WHERE rp.role_id = ? AND p.resource_type_id = 2 OR p.resource_type_id = 3';
    let [exist_permissions] = await pool.query(select_permission_sql, [role_id]);
    exist_permissions = exist_permissions.map((item) => item.permission_id);
    // exist_permissions 数组中有这些id，而 insert_permissions 数组中没有这些id，筛选出来这部分id，将会删除它们
    let rest_exist_permissions = exist_permissions.filter((item) => {
        return !insert_permissions.includes(item);
    });
    // insert_permissions 数组中有这些id，而 exist_permissions 数组中没有这些id，筛选出来这部分id，将会添加它们
    let rest_insert_permissions = insert_permissions.filter((item) => {
        return !exist_permissions.includes(item);
    });
    // 转化数组格式
    rest_insert_permissions = rest_insert_permissions.map((item) => `(${role_id},${item})`);

    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 根据 rest_exist_menus 删除数据，数组为空,不需要删除数据
        if (rest_exist_permissions.length) {
            let delete_permission_sql = `DELETE FROM sys_role_permission WHERE role_id = ? AND permission_id IN (${rest_exist_permissions.toString()})`;
            let [{ affectedRows: permission_affected_rows }] = await connection.query(delete_permission_sql, [role_id]);
            if (permission_affected_rows === 0) {
                await connection.rollback();
                res.json({ status: false, msg: "删除原有 permission 失败！" });
                return;
            }
        }
        // 根据 rest_insert_menus 插入数据，数组为空,不需要插入数据
        if (rest_insert_permissions.length) {
            let insert_permission_sql = `INSERT INTO sys_role_permission (role_id, permission_id) VALUES ${rest_insert_permissions.toString()}`;
            let [{ affectedRows: permission_affected_rows }] = await connection.query(insert_permission_sql, []);
            if (permission_affected_rows === 0) {
                await connection.rollback();
                res.json({ status: false, msg: "插入新的 permission 失败！" });
                return;
            }
        }
        // 一切顺利，提交事务
        await connection.commit();
        // 设置成功
        res.json({
            status: true,
            msg: "设置成功"
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
