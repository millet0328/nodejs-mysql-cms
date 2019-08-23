var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;

// 添加分类 parent_id , name
// 约定：一级分类 parent_id：0
router.post("/add", function (req, res) {
    var sql = 'INSERT INTO category (`name`,parent_id) VALUES (?,?);'
    pool.query(sql, [req.body.name, req.body.parent_id], function (error, results) {
        res.json({
            status: true,
            msg: "添加成功！"
        });
    });
});
// 删除指定id分类,同时删除其子分类
router.post("/delete", function (req, res) {
    var sql = 'DELETE FROM category  WHERE category_id = ? OR parent_id = ? '
    pool.query(sql, [req.body.category_id, req.body.category_id], function (error, results, fielde) {
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

});
// 获取指定id的分类详情
router.get("/detail", function (req, res) {
    var sql = 'SELECT * FROM category WHERE category_id = ?';
    pool.query(sql, [req.query.id], function (error, results) {
        if (results.length == 0) {
            res.json({
                status: false,
                msg: "获取失败！"
            });
            return;
        }
        res.json({
            status: true,
            data: results[0]
        });
    });
});
//编辑指定id分类
router.post('/edit', function (req, res, next) {
    var sql = 'UPDATE category SET name = ?,parent_id = ? WHERE category_id=?';
    pool.query(sql, [req.body.name, req.body.parent_id, req.body.id], function (error, results) {
        res.json({
            status: true,
            msg: "修改成功"
        });
    })

});
// 获取所有分类
router.get('/list', function (req, res, next) {
    var sql = 'SELECT c1.*,c2.`name` AS parent_name FROM `category` c1 left JOIN category c2 ON c1.parent_id = c2.category_id';
    pool.query(sql, function (error, results) {
        res.json({
            status: true,
            data: results
        });
    })
});
// 获取一级分类
router.get("/first", function (req, res) {
    var sql = 'SELECT * FROM category WHERE parent_id = 0';
    pool.query(sql, function (error, results) {
        res.json({
            status: true,
            data: results
        });
    });
});

module.exports = router;