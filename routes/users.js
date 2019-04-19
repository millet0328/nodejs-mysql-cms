var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;

// 注册
router.post('/register', function (req, res) {
  var sql = 'INSERT INTO users (username,`password`,fullname,tel) VALUES (?,?,?,?)'
  pool.query(sql, [req.body.username, req.body.password, req.body.fullname, req.body.tel], function (error, results, fields) {
    // 注册成功
    res.json({
      status: true,
      msg: "注册成功！"
    });
  });

});
// 登录
router.post('/login', function (req, res) {
  var sql = 'SELECT * FROM users WHERE username = ? AND `password` = ? ';
  pool.query(sql, [req.body.username, req.body.password], function (error, results) {
    if (results.length > 0) {
      res.json({
        status: true,
        msg: "登录成功！",
        uid: results[0].user_id
      });
    } else {
      res.json({
        status: false,
        msg: "账号或密码错误！"
      });
    }
  });

});

// 获取用户资料 id=?
router.get('/info', function (req, res, next) {
  var sql = 'SELECT username,fullname,tel FROM users WHERE user_id = ? ';
  pool.query(sql, [req.query.id], function (error, results) {
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
// 编辑资料
// id,username,password,fullname,tel
router.post('/edit', function (req, res, next) {
 
});
// 删除账户

// 获取用户列表，不要显示密码


module.exports = router;