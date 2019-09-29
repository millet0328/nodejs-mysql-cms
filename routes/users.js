var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;

/**
 * @api {post} /user/register 注册普通用户
 * @apiName UserRegister
 * @apiGroup User
 *
 * @apiParam { String } username 用户名.
 * @apiParam { String } password 密码.
 * @apiParam { String } nickname 昵称.
 * @apiParam { String } sex 性别.
 * @apiParam { String } tel 手机号码.
 *
 * @apiSampleRequest /user/register
 */
router.post('/register', function (req, res) {
    let { username, password, nickname, sex, tel } = req.body;
    // 查询账户是否重名
    let sql = 'SELECT * FROM users WHERE username = ?';
    pool.query(sql, [username], function (error, results) {
        if (error) throw error;
        // 有重名
        if (results.length) {
            res.json({
                msg: "账户已存在",
                status: false,
            });
            return;
        }
        // 不存在重名
        var sql = 'INSERT INTO users (username,password,nickname,sex,tel) VALUES (?,?,?,?,?)';
        pool.query(sql, [username, password, nickname, sex, tel], function (error, results) {
            if (error) throw error;
            if (results.affectedRows == 1) {
                res.json({
                    msg: "注册成功！",
                    status: true,
                    id: results.insertId
                });
            }
        });
    });

});
/**
 * @api {post} /user/login 登录普通用户
 * @apiName UserLogin
 * @apiGroup User
 *
 * @apiParam { String } username 用户名.
 * @apiParam { String } password 密码.
 *
 * @apiSampleRequest /user/login
 */
router.post('/login', function (req, res) {
    let { username, password } = req.body;
    let sql = 'SELECT * FROM users WHERE username = ? AND `password` = ?';
    pool.query(sql, [username, password], function (error, results) {
        if (error) throw error;
        if (results.length == 0) {
            res.json({
                msg: "账号或密码错误！",
                status: false,
            });
            return;
        }
        res.json({
            msg: "登陆成功！",
            status: true,
        });
    });

});
/**
 * @api {get} /user/info 获取用户个人资料
 * @apiName UserInfo
 * @apiGroup User
 *
 * @apiParam { Number } id 用户id.
 *
 * @apiSampleRequest /user/info
 */
router.get('/info', function (req, res) {
    let { id } = req.query;
    var sql = 'SELECT username,nickname,sex,tel FROM users WHERE id = ? ';
    pool.query(sql, [id], function (error, results) {
        if (error) throw error;
        if (results.length == 0) {
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
    })
});

/**
 * @api {post} /user/info 编辑个人资料
 * @apiName UserUpdate
 * @apiGroup User
 *
 * @apiParam { Number } id 用户id.
 * @apiParam { String } username 用户名.
 * @apiParam { String } nickname 昵称.
 * @apiParam { String } sex 性别.
 * @apiParam { String } tel 手机号码.
 *
 * @apiSampleRequest /user/info
 */

router.post('/info', function (req, res) {
    let { id, username, nickname, sex, tel } = req.body;
    let sql = 'UPDATE users SET username = ?,nickname = ?,sex = ?,tel = ? WHERE id = ?';
    pool.query(sql, [username, nickname, sex, tel, id], function (error, results) {
        if (error) throw error;
        if (!results.affectedRows) {
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
});
/**
 * @api {post} /user/delete 删除账户
 * @apiName UserDelete
 * @apiGroup User
 *
 * @apiParam { Number } id 用户id.
 *
 * @apiSampleRequest /user/delete
 */

router.post('/delete', function (req, res) {
    let { id } = req.body;
    let sql = 'DELETE FROM users WHERE id = ?';
    pool.query(sql, [id], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            msg: "删除成功"
        });
    })
})

/**
 * @api {get} /user/list 获取用户列表
 * @apiName UserList
 * @apiGroup User
 *
 * @apiSampleRequest /user/list
 */

router.get('/list', function (req, res) {
    var sql = 'SELECT id,username,nickname,sex,tel FROM users';
    pool.query(sql, [], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            data: results
        });
    })
});


module.exports = router;