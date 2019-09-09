var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;

/**
 * @api {post} /admin/register 注册管理员账户
 * @apiName AdminRegister
 * @apiGroup Admin
 *
 * @apiParam { String } username 用户名.
 * @apiParam { String } password 密码.
 * @apiParam { String } nickname 昵称.
 * @apiParam { String } sex 性别.
 * @apiParam { String } tel 手机号码.
 * @apiParam { String } [email] 邮箱地址.
 * @apiParam { String } [avatar] 头像地址.
 *
 * @apiSampleRequest /admin/register
 */
router.post('/register', function (req, res) {
    let { username, password, nickname, sex, tel, email, avatar } = req.body;
    // 查询账户是否重名
    let sql = 'SELECT * FROM admin WHERE username = ?';
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
        let sql = 'INSERT INTO admin (username,password,nickname,sex,tel,email,avatar) VALUES (?,?,?,?,?,?,?)';
        pool.query(sql, [username, password, nickname, sex, tel, email, avatar], function (error, results) {
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
 * @api {post} /admin/login 登录管理员账户
 * @apiName AdminLogin
 * @apiGroup Admin
 *
 * @apiParam { String } username 用户名.
 * @apiParam { String } password 密码.
 *
 * @apiSampleRequest /admin/login
 */

router.post('/login', function (req, res) {
    let { username, password } = req.body;
    let sql = 'SELECT * FROM `admin` WHERE username = ? AND password = ?';
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
 * @api {get} /admin/info 获取管理员个人资料
 * @apiName AdminInfo
 * @apiGroup Admin
 *
 * @apiParam { Number } id 管理员id.
 *
 * @apiSampleRequest /admin/info
 */
router.get('/info', function (req, res, next) {
    let { id } = req.query;
    var sql = 'SELECT username, nickname, sex, tel, email, avatar FROM admin WHERE id = ? ';
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
 * @api {post} /admin/info 编辑管理员个人资料
 * @apiName AdminUpdate
 * @apiGroup Admin
 *
 * @apiParam { Number } id 管理员id.
 * @apiParam { String } username 用户名.
 * @apiParam { String } nickname 昵称.
 * @apiParam { String } sex 性别.
 * @apiParam { String } tel 手机号码.
 * @apiParam { String } email 邮箱地址.
 * @apiParam { String } avatar 头像地址.
 *
 * @apiSampleRequest /admin/info
 */

router.post('/info', function (req, res) {
    let { id, username, nickname, sex, tel, email, avatar } = req.body;
    let sql = 'UPDATE admin SET username = ?,nickname = ?,sex = ?,tel = ?,email = ?, avatar = ? WHERE id = ?';
    pool.query(sql, [username, nickname, sex, tel, email, avatar, id], function (error, results) {
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
 * @api {post} /admin/delete 删除账户
 * @apiName AdminDelete
 * @apiGroup Admin
 *
 * @apiParam { Number } id 管理员id.
 *
 * @apiSampleRequest /admin/delete
 */
router.post('/delete', function (req, res) {
    let { id } = req.body;
    let sql = 'DELETE FROM admin WHERE id = ?';
    pool.query(sql, [id], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            msg: "删除成功"
        });
    })
});

/**
 * @api {get} /admin/list 获取管理员列表
 * @apiName AdminList
 * @apiGroup Admin
 *
 * @apiSampleRequest /admin/list
 */

router.get('/list', function (req, res) {
    var sql = 'SELECT id, username, nickname, sex, tel, email, avatar FROM admin';
    pool.query(sql, [], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            data: results
        });
    })
});

module.exports = router;