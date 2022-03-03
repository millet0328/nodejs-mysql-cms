var express = require('express');
var router = express.Router();
// 数据库
var db = require('../config/mysql');

/**
 * @api {post} /user/register 注册普通用户
 * @apiDescription 注册成功，后台采用 cookie-session 模式识别登录状态，response headers返回Set-Cookie，浏览器自动设置cookie。浏览器每次请求都会自动携带此cookie,但是AJAX请求需要额外设置 withCredentials = true;
 * @apiName UserRegister
 * @apiPermission 前台
 * @apiGroup User
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } password 密码.
 * @apiBody { String } nickname 昵称.
 * @apiBody { String } sex 性别.
 * @apiBody { String } tel 手机号码.
 *
 * @apiSampleRequest /user/register
 */
router.post('/register', async (req, res) => {
    let { username, password, nickname, sex, tel } = req.body;
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
    let { insertId, affectedRows } = await db.query(sql, [username, password, nickname, sex, tel]);
    if (affectedRows) {
        // 注册成功，设置session
        req.session.uid = insertId;
        res.json({
            msg: "注册成功！",
            status: true,
            data: { id: insertId, username, nickname, sex, tel }
        });
    }
});
/**
 * @api {post} /user/login 登录普通用户
 * @apiDescription 登录成功，后台采用 cookie-session 模式识别登录状态，response headers返回Set-Cookie，浏览器自动设置cookie。浏览器每次请求都会自动携带此cookie,但是AJAX请求需要额外设置 withCredentials = true;
 * @apiName UserLogin
 * @apiPermission 前台
 * @apiGroup User
 *
 * @apiBody { String } username 用户名.
 * @apiBody { String } password 密码.
 *
 * @apiSampleRequest /user/login
 */
router.post('/login', async (req, res) => {
    let { username, password } = req.body;
    let sql = 'SELECT * FROM user WHERE username = ? AND `password` = ?';
    let [user] = await db.query(sql, [username, password]);
    if (!user) {
        res.json({
            msg: "账号或密码错误！",
            status: false,
        });
        return;
    }
    // 登录成功，设置session
    req.session.uid = user.id;
    // 去除密码字段
    delete user.password;
    res.json({
        msg: "登陆成功！",
        status: true,
        data: user,
    });
});
/**
 * @api {get} /user/info 获取用户个人资料
 * @apiName UserInfo
 * @apiPermission 前台
 * @apiGroup User
 *
 * @apiQuery { Number } id 用户id.
 *
 * @apiSampleRequest /user/info
 */
router.get('/info', async (req, res) => {
    let { id } = req.query;
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
 * @api {post} /user/info 编辑个人资料
 * @apiName UserUpdate
 * @apiPermission 前台
 * @apiGroup User
 *
 * @apiBody { Number } id 用户id.
 * @apiBody { String } nickname 昵称.
 * @apiBody { String } sex 性别.
 * @apiBody { String } tel 手机号码.
 *
 * @apiSampleRequest /user/info
 */

router.post('/info', async (req, res) => {
    let { id, nickname, sex, tel } = req.body;
    let sql = 'UPDATE user SET nickname = ?,sex = ?,tel = ? WHERE id = ?';
    let { affectedRows } = await db.query(sql, [nickname, sex, tel, id]);
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
/**
 * @api {post} /user/remove 删除账户
 * @apiName UserRemove
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiBody { Number } id 用户id.
 *
 * @apiSampleRequest /user/remove
 */

router.post('/remove', async (req, res) => {
    let { id } = req.body;
    let sql = 'DELETE FROM user WHERE id = ?';
    let { affectedRows } = await db.query(sql, [id]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "fail！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "success!",
    });
})

/**
 * @api {get} /user/list 获取用户列表
 * @apiName UserList
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiSampleRequest /user/list
 */
router.get('/list', async (req, res) => {
    const sql = 'SELECT id,username,nickname,sex,tel FROM user';
    let results = await db.query(sql);
    res.json({
        status: true,
        data: results
    });
});

module.exports = router;
