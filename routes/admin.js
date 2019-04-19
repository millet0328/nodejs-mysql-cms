var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;

// 添加分类 parent_id , name
// 约定：一级分类 parent_id：0
router.post("/category/add", function (req, res) {
    var sql = 'INSERT INTO category (`name`,parent_id) VALUES (?,?);'
    pool.query(sql, [req.body.name, req.body.parent_id], function (error, results) {
        res.json({
            status: true,
            msg: "添加成功！"
        });
    });
});
// 删除分类
router.post("/category/delete", function (req, res) {

});
// 获取分类

// 编辑分类

module.exports = router;