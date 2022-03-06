var express = require('express');
var router = express.Router();
// 数据库
var db = require('../config/mysql');

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
    let {username, password, nickname, sex, tel} = req.body;
    // 查询账户是否重名
    var sql = 'SELECT * FROM user WHERE username = ?';
    let results = await db.query(sql, [username]);
    // 重名
    if (results.length) {
        res.json({
            msg: "账户已存在",
            status: false,
        });
        return;
    }
    // 无重名
    var sql = 'INSERT INTO user (username,password,nickname,sex,tel) VALUES (?,?,?,?,?)';
    let {insertId, affectedRows} = await db.query(sql, [username, password, nickname, sex, tel]);
    if (affectedRows) {
        res.json({
            msg: "注册成功！",
            status: true,
            data: {id: insertId, username, nickname, sex, tel}
        });
    }
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
    let {username, password} = req.body;
    let sql = 'SELECT * FROM user WHERE username = ? AND `password` = ?';
    let [user] = await db.query(sql, [username, password]);
    if (!user) {
        res.json({
            msg: "账号或密码错误！",
            status: false,
        });
        return;
    }
    // 去除密码字段
    delete user.password;
    res.json({
        msg: "登陆成功！",
        status: true,
        data: user,
    });
});
/**
 * @api {get} /account/info 获取用户个人资料
 * @apiName AccountInfo
 * @apiPermission 前台
 * @apiGroup Account
 *
 * @apiQuery { Number } id 用户id.
 *
 * @apiSampleRequest /account/info
 */
router.get('/info', async (req, res) => {
    let {id} = req.query;
    var sql = 'SELECT username,nickname,sex,tel FROM user WHERE id = ? ';
    let [user] = await db.query(sql, [id]);
    if (!user) {
        res.json({
            status: false,
            msg: "查无此人！"
        });
        return;
    }
    res.json({
        status: true,
        data: user
    });
});

/**
 * @api {post} /account/info 编辑个人资料
 * @apiName AccountUpdate
 * @apiPermission 前台
 * @apiGroup Account
 *
 * @apiBody { Number } id 用户id.
 * @apiBody { String } nickname 昵称.
 * @apiBody { String="男","女" } sex 性别.
 * @apiBody { String } tel 手机号码.
 *
 * @apiSampleRequest /account/info
 */

router.post('/info', async (req, res) => {
    let {id, nickname, sex, tel} = req.body;
    let sql = 'UPDATE user SET nickname = ?,sex = ?,tel = ? WHERE id = ?';
    let {affectedRows} = await db.query(sql, [nickname, sex, tel, id]);
    if (!affectedRows) {
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