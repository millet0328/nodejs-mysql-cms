const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');
// Token 生成器
const token_manager = require("../../plugins/jwt");
const uuid = require('../../plugins/uuid')

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @apiDefine UserSuccessResponse
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
 *          ...
 *          "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwidXNlcm5hbWUiOiIxIiwiaWF0IjoxNTU3MzM1Mzk3LCJleHAiOjE1NTczNDI1OTd9.vnauDCSHdDXaZyvTjNOz0ezpiO-UACbG-oHg_v76URE",
 *          "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwidXNlcm5hbWUiOiJhZG1pbiIsInJvbGUiOjEsInR5cGUiOiJyZWZyZXNoIiwiaWF0IjoxNjY0ODE4OTYyLCJleHAiOjE2NjQ4MjA3NjJ9.Kzy_CRR7cIX1PRK2caVrMqexmZ7vAKadccN3pswOqB8"
 *      }
 *  }
 */

/**
 * @api {post} /account/register 注册普通用户
 * @apiDescription 注册成功，返回access_token、refresh_token，有效期30分钟，请在头部headers中设置Authorization: `Bearer ${access_token}`，所有请求都必须携带access_token；access_token超时之后，使用refresh_token换取新的access_token。
 * @apiName AccountRegister
 * @apiPermission 前台
 * @apiGroup Account
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } password 密码.
 * @apiBody { String } tel 手机号码.
 *
 * @apiUse UserSuccessResponse
 *
 * @apiSampleRequest /account/register
 */
router.post('/register', async (req, res) => {
    let { username, password, tel } = req.body;
    // 默认头像
    let defaultAvatar = `${process.env.server}/images/avatar/default.jpg`;
    // 获取一个连接
    const connection = await pool.getConnection();
    // 查询账户是否重名
    const select_sql = 'SELECT user_id FROM `cms_user` WHERE username = ?';
    let [results] = await pool.query(select_sql, [username]);
    // 查询账户是否存在，重名，禁止注册
    if (results.length > 0) {
        res.json({
            msg: "账户已存在，请修改用户名！",
            status: false,
        });
        return;
    }
    try {
        // 开启事务
        await connection.beginTransaction();
        // 创建新的用户
        const insert_sql = 'INSERT INTO `cms_user` (username, password, nickname, tel, avatar, create_date) VALUES (?,?,?,?,?,CURRENT_TIMESTAMP())';
        let [{ insertId: user_id, affectedRows: user_affected_rows }] = await pool.query(insert_sql, [username, password, username, tel, defaultAvatar]);
        if (user_affected_rows === 0) {
            res.json({
                msg: "账户user创建失败！",
                status: false,
            });
            return;
        }
        // 生成payload
        let payload = { user_id };
        // 生成access_token
        let access_token = token_manager.create_access_token({ ...payload, type: 'access' });
        // 生成refresh_token
        let jwtid = uuid();
        let refresh_token = token_manager.create_refresh_token({ type: 'refresh' }, { jwtid });
        // 存储新的refresh_token
        let update_token_sql = 'UPDATE `cms_user` SET refresh_token = ?, jwt_id = ? WHERE user_id = ?';
        let [{ affectedRows: refresh_token_rows }] = await connection.query(update_token_sql, [refresh_token, jwtid, user_id]);
        if (refresh_token_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "refresh_token存储失败！" });
            return;
        }
        // 一切顺利，提交事务
        await connection.commit();
        // 注册成功
        res.json({
            msg: "注册成功！",
            status: true,
            data: { access_token, refresh_token, user_id, username, tel }
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
 * @api {post} /account/login 登录普通用户
 * @apiDescription 登录成功，返回access_token、refresh_token，有效期30分钟，请在头部headers中设置Authorization: `Bearer ${access_token}`，所有请求都必须携带access_token；access_token超时之后，使用refresh_token换取新的access_token。
 * @apiName AccountLogin
 * @apiPermission 前台
 * @apiGroup Account
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } password 密码.
 *
 * @apiUse UserSuccessResponse
 *
 * @apiSampleRequest /account/login
 */
router.post('/login', async (req, res) => {
    let { username, password } = req.body;
    let sql = 'SELECT user_id,username,nickname,sex,tel,email,avatar,usable FROM `cms_user` WHERE username = ? AND `password` = ?';
    let [results] = await pool.query(sql, [username, password]);
    // 判断账号密码
    if (results.length === 0) {
        res.json({
            msg: "账号或密码错误！",
            status: false,
        });
        return;
    }
    // 判断账户是否禁用
    let { user_id, usable } = results[0];
    if (usable === -1) {
        res.json({
            msg: "账号已被禁用，请联系站长！",
            status: false,
        });
        return;
    }
    // 生成payload
    let payload = { user_id };
    // 生成access_token
    let access_token = token_manager.create_access_token({ ...payload, type: 'access' });
    // 生成refresh_token
    let jwtid = uuid();
    let refresh_token = token_manager.create_refresh_token({ type: 'refresh' }, { jwtid });
    // 存储新的refresh_token
    let update_token_sql = 'UPDATE `cms_user` SET refresh_token = ?, jwt_id = ? WHERE user_id = ?';
    let [{ affectedRows: refresh_token_rows }] = await pool.query(update_token_sql, [refresh_token, jwtid, user_id]);
    if (refresh_token_rows === 0) {
        res.json({ status: false, msg: "refresh_token存储失败！" });
        return;
    }
    // 登录成功
    res.json({
        status: true,
        msg: "登录成功！",
        data: { access_token, refresh_token, ...results[0] }
    });
});
/**
 * @api {get} /account/info 获取用户个人资料
 * @apiName AccountInfo
 * @apiPermission 前台
 * @apiGroup Account
 *
 * @apiUse Authorization
 *
 * @apiSampleRequest /account/info
 */
router.get('/info', async (req, res) => {
    let { user_id } = req.auth;
    let sql = 'SELECT user_id,username,nickname,sex,tel,email,avatar,usable FROM `cms_user` WHERE user_id = ? ';
    let [results] = await pool.query(sql, [user_id]);
    if (!results.length) {
        res.json({
            status: false,
            msg: "查无此人！"
        });
        return;
    }
    res.json({
        status: true,
        data: results[0]
    });
});

/**
 * @api {post} /account/info 编辑个人资料
 * @apiName AccountUpdate
 * @apiPermission 前台
 * @apiGroup Account
 *
 * @apiUse Authorization
 *
 * @apiBody { String } nickname 昵称。
 * @apiBody { String="男","女" } sex 性别。
 * @apiBody { String } tel 手机号码。
 * @apiBody { String } email 邮箱地址。
 * @apiBody { String } avatar 头像地址。
 *
 * @apiSampleRequest /account/info
 */

router.post('/info', async (req, res) => {
    let { user_id } = req.auth;
    let { nickname, sex, tel, email, avatar } = req.body;
    let sql = 'UPDATE `cms_user` SET nickname = ?, sex = ?, tel = ?, email = ?, avatar = ? WHERE user_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [nickname, sex, tel, email, avatar, user_id]);
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
    })
});

module.exports = router;