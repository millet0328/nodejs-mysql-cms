const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');
// JSON Web Token
const jwt = require("jsonwebtoken");

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${token}`，登录/注册成功返回的token。
 */

/**
 * @api {post} /account/register 注册普通用户
 * @apiName AccountRegister
 * @apiPermission 前台
 * @apiGroup Account
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } password 密码.
 * @apiBody { String } nickname 昵称.
 * @apiBody { String="男","女" } sex 性别.
 * @apiBody { String } tel 手机号码.
 *
 * @apiSampleRequest /account/register
 */
router.post('/register', async (req, res) => {
    let { username, password, nickname, sex, tel } = req.body;
    // 查询账户是否重名
    const select_sql = 'SELECT * FROM user WHERE username = ?';
    let [results] = await pool.query(select_sql, [username]);
    // 重名
    if (results.length > 0) {
        res.json({
            msg: "账户已存在",
            status: false,
        });
        return;
    }
    // 无重名
    const insert_sql = 'INSERT INTO user (username,password,nickname,sex,tel) VALUES (?,?,?,?,?)';
    let [{ insertId, affectedRows }] = await pool.query(insert_sql, [username, password, nickname, sex, tel]);
    if (affectedRows === 0) {
        res.json({
            msg: "注册失败！",
            status: false,
        });
        return;
    }
    // 生成token
    let payload = { id: insertId, username };
    let token = jwt.sign(payload, 'secret', { expiresIn: '4h' });
    // 注册成功
    res.json({
        msg: "注册成功！",
        status: true,
        data: { token, id: insertId, username, nickname, sex, tel }
    });
});
/**
 * @api {post} /account/login 登录普通用户
 * @apiName AccountLogin
 * @apiPermission 前台
 * @apiGroup Account
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } password 密码.
 *
 * @apiSampleRequest /account/login
 */
router.post('/login', async (req, res) => {
    let { username, password } = req.body;
    let sql = 'SELECT id,username,nickname,sex,tel,usable FROM user WHERE username = ? AND `password` = ?';
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
    let { id, usable } = results[0];
    if (usable === 0) {
        res.json({
            msg: "账号已被禁用，请联系站长！",
            status: false,
        });
        return;
    }
    // 生成token
    let payload = { id, username };
    let token = jwt.sign(payload, 'secret', { expiresIn: '4h' });
    // 登录成功
    res.json({
        status: true,
        msg: "登录成功！",
        data: { token, ...results[0] }
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
    let { id } = req.user;
    let sql = 'SELECT username,nickname,sex,tel FROM user WHERE id = ? ';
    let [results] = await pool.query(sql, [id]);
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
 * @apiBody { String } nickname 昵称.
 * @apiBody { String="男","女" } sex 性别.
 * @apiBody { String } tel 手机号码.
 *
 * @apiSampleRequest /account/info
 */

router.post('/info', async (req, res) => {
    let { id } = req.user;
    let { nickname, sex, tel } = req.body;
    let sql = 'UPDATE user SET nickname = ?,sex = ?,tel = ? WHERE id = ?';
    let [{ affectedRows }] = await pool.query(sql, [nickname, sex, tel, id]);
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