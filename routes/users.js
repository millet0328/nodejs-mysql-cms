var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;

// 注册
router.post('/register', function (req, res) {
  var sql = 'INSERT INTO users (username,`password`,fullname,tel) VALUES (?,?,?,?)'
  pool.query(sql, [req.body.username, req.body.password, req.body.fullname, req.body.tel], function (error, results, fields) {
    if (error) {
      console.log(error);
      return;
    }
    if (results.affectedRows <= 0) {
      // 注册失败
      res.json({
        status: false,
        msg: results
      });
      return;
    }
    // 注册成功
    res.json({
      status: true,
      msg: "注册成功！",
      uid: results.insertId
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
router.post('/edit', function (req, res, next) {
  var sql = 'UPDATE users SET username = ?,fullname = ?,tel = ? WHERE user_id = ?';
  pool.query(sql, [req.body.username, req.body.fullname, req.body.tel, req.body.id], function (error, results) {
    res.json({
      status: true,
      msg: "修改成功"
    });
  })
});
// 删除账户
router.post('/delete', function (req, res, next) {
  var sql = 'DELETE FROM users WHERE user_id = ?'
  pool.query(sql, [req.body.id], function (error, results, fielde) {
    // 如果删除成功
    if (results.affectedRows > 0) {
      res.json({
        status: true,
        msg: "删除成功"
      });
      return
    } else {
      res.json({
        status: false,
        msg: "删除失败"
      });
    }

  })
})

// 获取用户列表，不能显示密码
router.get('/list', function (req, res, next) {
  var sql = 'SELECT user_id,username,fullname,tel FROM users';
  pool.query(sql, function (error, results) {
    res.json({
      status: true,
      data: results
    });
  })
});


module.exports = router;