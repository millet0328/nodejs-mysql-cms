const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');
// Token 生成器
const token_manager = require("../../plugins/jwt");
// uuid
const uuid = require('../../plugins/uuid')

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @apiDefine AdminSuccessResponse
 * @apiSuccess { Boolean } status 请求状态.
 * @apiSuccess { String } msg 请求结果信息.
 * @apiSuccess { Object } data 请求数据信息.
 * @apiSuccess { String } data.access_token 成功之后返回的access_token，每次请求携带。
 * @apiSuccess { String } data.refresh_token access_token超时之后，使用refresh_token换取新的access_token。
 * @apiSuccess { String } data.user_id 用户id.
 * @apiSuccess { String } data.role_id 用户角色id.
 *
 * @apiSuccessExample { json } 200返回的JSON:
 *  HTTP / 1.1 200 OK
 *  {
 *      "status": true,
 *      "msg": "成功",
 *      "data":{
 *          "user_id":5,
 *          "role_id":3,
 *          "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwidXNlcm5hbWUiOiIxIiwiaWF0IjoxNTU3MzM1Mzk3LCJleHAiOjE1NTczNDI1OTd9.vnauDCSHdDXaZyvTjNOz0ezpiO-UACbG-oHg_v76URE",
 *          "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsInJvbGUiOjEsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNjY0ODE4OTYyLCJleHAiOjE2NjQ4MjA3NjJ9.Kzy_CRR7cIX1PRK2caVrMqexmZ7vAKadccN3pswOqB8"
 *      }
 *  }
 */

/**
 * @api {post} /admin/register 注册管理员账户
 * @apiDescription 新账户默认状态--审核中，审核通过之后才可以登录；
 * @apiName AdminRegister
 * @apiGroup Admin
 * @apiPermission 后台系统
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } password 密码.
 * @apiBody { String } fullname 姓名.
 * @apiBody { String } tel 手机号码.
 *
 * @apiSampleRequest /admin/register
 */

router.post('/register', async (req, res) => {
    let { username, password, fullname, tel } = req.body;
    // 默认头像
    let defaultAvatar = `${process.env.server}/images/avatar/default.jpg`;
    // 获取一个连接
    const connection = await pool.getConnection();
    // 查询账户是否重名
    let select_sql = 'SELECT user_id FROM `sys_user` WHERE username = ?';
    let [results] = await connection.query(select_sql, [username]);
    // 查询账户是否存在，重名，禁止注册
    if (results.length) {
        res.json({
            msg: "账户已存在，请修改用户名！",
            status: false,
        });
        return;
    }

    try {
        // 开启事务
        await connection.beginTransaction();
        // 创建新账户
        let insert_admin_sql = 'INSERT INTO `sys_user` (username, password, fullname, tel, avatar, create_date) VALUES (?,?,?,?,?,?,?,CURRENT_TIMESTAMP())';
        let [{ insertId: user_id, affectedRows: admin_affected_rows }] = await connection.query(insert_admin_sql, [username, password, fullname, tel, defaultAvatar]);
        if (admin_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "账户admin创建失败！" });
            return;
        }
        // 给新账户分配角色，默认角色为3
        let insert_role_sql = 'INSERT INTO `sys_user_role` (user_id,role_id) VALUES (?,3)';
        let [{ affectedRows: role_affected_rows }] = await pool.query(insert_role_sql, [user_id]);
        if (role_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "默认角色user_role设置失败！" });
            return;
        }
        // 一切顺利，提交事务
        await connection.commit();
        // 注册成功
        res.json({
            status: true,
            msg: "注册成功，请等待管理员审核通过！",
            data: { user_id, role_id: 3 }
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
 * @api {post} /admin/login 登录管理员账户
 * @apiDescription 账户默认状态--审核中，审核通过之后才可以登录；登录成功，返回access_token、refresh_token，有效期30分钟，请在头部headers中设置Authorization: `Bearer ${access_token}`，所有请求都必须携带access_token；access_token超时之后，使用refresh_token换取新的access_token。
 * @apiName AdminLogin
 * @apiPermission 后台系统
 * @apiGroup Admin
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } password 密码.
 *
 * @apiUse AdminSuccessResponse
 *
 * @apiSampleRequest /admin/login
 */

router.post('/login', async (req, res) => {
    let { username, password } = req.body;

    let sql = 'SELECT u.*, ur.role_id FROM `sys_user` u LEFT JOIN `sys_user_role` ur ON u.user_id = ur.user_id LEFT JOIN `sys_role` r ON r.role_id = ur.role_id  WHERE username = ? AND password = ?';
    let [results] = await pool.query(sql, [username, password]);
    // 检查账户、密码
    if (results.length === 0) {
        res.json({
            msg: "账号或密码错误！",
            status: false,
        });
        return;
    }
    let { user_id, role_id, usable } = results[0];
    // 检查账户状态--审核中，审核通过之后才可以登录
    if (usable === -1) {
        res.json({
            msg: "账号审核中，审核通过之后才可以登录！",
            status: false,
        });
        return;
    }
    // 检查账户状态--禁用，需要联系管理员解禁
    if (usable === -2) {
        res.json({
            msg: "账号已禁用，请联系管理员！",
            status: false,
        });
        return;
    }
    // 生成payload
    let payload = { user_id, role_id };
    // 生成access_token
    let access_token = token_manager.create_access_token({ ...payload, type: 'access' });
    // 生成refresh_token
    let jwtid = uuid();
    let refresh_token = token_manager.create_refresh_token({ type: 'refresh' }, { jwtid });
    // 存储新的refresh_token
    let update_token_sql = 'UPDATE `sys_user` SET refresh_token = ?, jwt_id = ? WHERE user_id = ?';
    let [{ affectedRows }] = await pool.query(update_token_sql, [refresh_token, jwtid, user_id]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "refresh_token存储失败！"
        });
        return;
    }
    // 登录成功
    res.json({
        status: true,
        msg: "登录成功！",
        data: { access_token, refresh_token, user_id, role_id }
    });
});
/**
 * @api {get} /admin/info 获取管理员个人资料
 * @apiName AdminInfo
 * @apiPermission 后台系统
 * @apiGroup Admin
 *
 * @apiUse Authorization
 *
 * @apiQuery { Number } user_id 管理员id.
 *
 * @apiSampleRequest /admin/info
 */
router.get('/info', async (req, res) => {
    let { user_id } = req.query;
    const sql = 'SELECT u.user_id, u.username, u.fullname, u.sex, u.email, u.avatar, u.tel, ur.role_id FROM `sys_user` u LEFT JOIN `sys_user_role` ur ON u.user_id = ur.user_id WHERE u.user_id = ?';
    let [results] = await pool.query(sql, [user_id]);
    res.json({
        status: true,
        data: results[0]
    });
});

/**
 * @api {post} /admin/check/username 检测用户名是否可用
 * @apiName AdminCheckUsername
 * @apiGroup Admin
 * @apiPermission 后台系统
 *
 * @apiBody { String } username 用户名.
 *
 * @apiSampleRequest /admin/check/username
 */
router.post('/check/username', async (req, res) => {
    let { username } = req.body;
    // 查询账户是否重名
    let select_sql = 'SELECT user_id FROM `sys_user` WHERE username = ?';
    let [results] = await pool.query(select_sql, [username]);
    // 查询账户是否存在
    if (results.length) {
        res.json({
            status: false,
            msg: "用户名已存在，请重新命名！",
        });
        return;
    }
    res.json({
        status: true,
        msg: "恭喜，用户名可用！",
    });
});

/**
 * @api {post} /admin/info 编辑管理员个人资料
 * @apiDescription 只有超级管理员才有权限修改用户角色，普通管理员无权限更改角色。
 * @apiName AdminUpdate
 * @apiGroup Admin
 * @apiPermission 超级管理员--后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } user_id 管理员id.
 * @apiBody { String } username 用户名.
 * @apiBody { String } fullname 姓名.
 * @apiBody { String } role_id 角色id.
 * @apiBody { String="男","女" } sex 性别.
 * @apiBody { String } tel 手机号码.
 * @apiBody { String } email 邮箱地址.
 * @apiBody { String } avatar 头像地址.
 *
 * @apiSampleRequest /admin/info
 */

router.post('/info', async (req, res) => {
    let { user_id, username, fullname, role_id, sex, tel, email, avatar } = req.body;
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 更新管理员信息
        let update_admin_sql = 'UPDATE `sys_user` SET username = ?,fullname = ?,sex = ?,tel = ?,email = ?, avatar = ? WHERE user_id = ?;';
        let [{ affectedRows: admin_affected_rows }] = await connection.query(update_admin_sql, [username, fullname, sex, tel, email, avatar, user_id]);
        if (admin_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "账户admin修改失败！" });
            return;
        }
        // 更新角色
        let update_role_sql = 'UPDATE `sys_user_role` SET role_id = ? WHERE user_id = ?';
        let [{ affectedRows: role_affected_rows }] = await connection.query(update_role_sql, [role_id, user_id]);
        if (role_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "角色role修改失败！" });
            return;
        }
        // 一切顺利，提交事务
        await connection.commit();
        res.json({
            status: true,
            msg: "修改成功!"
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
 * @api {post} /admin/account 修改本账户信息
 * @apiDescription 管理员自行修改本账户信息，但是无权限分配角色。
 * @apiName UpdateAccount
 * @apiGroup Admin
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } fullname 姓名.
 * @apiBody { String="男","女" } sex 性别.
 * @apiBody { String } tel 手机号码.
 * @apiBody { String } email 邮箱地址.
 * @apiBody { String } avatar 头像地址.
 *
 * @apiSampleRequest /admin/account
 */
router.post("/account/", async (req, res) => {
    let { user_id } = req.auth;
    let { fullname, sex, avatar, tel, email } = req.body;
    let sql = 'UPDATE `sys_user` SET fullname = ?,sex = ?,avatar = ?,tel = ?,email = ? WHERE user_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [fullname, sex, avatar, tel, email, user_id]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "修改失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "修改成功！"
    });
});

/**
 * @api {post} /admin/remove 删除账户
 * @apiName AdminRemove
 * @apiGroup Admin
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } user_id 管理员id.
 *
 * @apiSampleRequest /admin/remove
 */
router.post('/remove', async (req, res) => {
    let { user_id } = req.body;
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 删除账户
        let delete_admin_sql = 'DELETE FROM `sys_user` WHERE user_id = ? AND editable = 1 ';
        let [{ affectedRows: admin_affected_rows }] = await connection.query(delete_admin_sql, [user_id]);
        if (admin_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "删除失败，账户禁止删除！" });
            return;
        }
        // 删除角色
        let delete_role_sql = 'DELETE FROM `sys_user_role` WHERE user_id = ?';
        await connection.query(delete_role_sql, [user_id]);
        // 一切顺利，提交事务
        await connection.commit();
        res.json({
            status: true,
            msg: "删除成功"
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
 * @api {get} /admin/list 获取管理员列表
 * @apiName AdminList
 * @apiPermission 后台系统
 * @apiGroup Admin
 *
 * @apiUse Authorization
 *
 * @apiQuery { Number } [pagesize=10] 每一页数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 *
 * @apiSuccess { Boolean } status 请求状态。
 * @apiSuccess { String } msg 请求结果信息。
 * @apiSuccess { Object[] } data 请求数据信息。
 * @apiSuccess { Number } data.user_id 管理员id。
 * @apiSuccess { String } data.username 用户名。
 * @apiSuccess { String } data.fullname 姓名。
 * @apiSuccess { String } data.sex 性别。
 * @apiSuccess { String } data.tel 手机号码。
 * @apiSuccess { String } data.email 邮箱。
 * @apiSuccess { String } data.avatar 头像。
 * @apiSuccess { String } data.role_id 角色id。
 * @apiSuccess { String } data.role_name 角色名称。
 * @apiSuccess { String } data.usable 可用状态，正常：1，审核中：-1，禁用：-2。
 *
 * @apiSuccessExample { json } 200返回的JSON:
 *  HTTP / 1.1 200 OK
 * {
 *   "status": true,
 *   "msg": "获取成功",
 *   "data": [
 *       {
 *           "user_id": 1,
 *           "username": "admin",
 *           "fullname": "黄小米",
 *           "sex": "女",
 *           "email": "nn880328@126.com",
 *           "avatar": "http://localhost:3001/images/avatar/default.jpg",
 *           "tel": "15863008280",
 *           "role_name": "超级管理员",
 *           "role_id": 1,
 *           "usable": 1
 *       },
 *       {
 *           "user_id": 2,
 *           "username": "moz",
 *           "fullname": "孙红雷",
 *           "sex": "女",
 *           "email": "715623617@qq.com",
 *           "avatar": "http://localhost:3001/images/avatar/default.jpg",
 *           "tel": "13475829262",
 *           "role_name": "管理员",
 *           "role_id": 2,
 *           "usable": 1
 *       }
 *   ],
 *   "total": 4
 * }
 *
 * @apiSampleRequest /admin/list
 */

router.get('/list', async (req, res) => {
    let { pagesize = '10', pageindex = '1' } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    const offset = pagesize * (pageindex - 1);
    // 查询列表
    let select_sql = 'SELECT u.user_id,u.username,u.fullname,u.sex,u.email,u.avatar,u.tel,r.role_name,r.role_id,u.usable,u.editable FROM `sys_user` u LEFT JOIN `sys_user_role` ur ON u.user_id = ur.user_id LEFT JOIN `sys_role` r ON r.role_id = ur.role_id LIMIT ? OFFSET ?';
    let [admins] = await pool.query(select_sql, [pagesize, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(*) as total FROM `sys_user`';
    let [total] = await pool.query(total_sql, []);
    res.json({
        status: true,
        msg: "获取成功",
        data: admins,
        ...total[0],
    });
});

/**
 * @api {post} /admin/usable 修改管理员的账户状态
 * @apiName UsableAdmin
 * @apiPermission 后台系统
 * @apiGroup Admin
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } user_id 管理员id.
 * @apiBody { Number=1,-1,-2 } usable 账户状态，正常：1，审核中：-1，禁用：-2。
 *
 * @apiSampleRequest /admin/usable
 */
router.post('/usable', async (req, res) => {
    let { user_id, usable } = req.body;
    const sql = 'UPDATE `sys_user` SET usable = ? WHERE user_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [usable, user_id]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "修改失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "修改成功！"
    });
});

module.exports = router;
