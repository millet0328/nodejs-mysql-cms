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
// 删除指定id分类,同时删除其子分类
router.post("/category/delete", function (req, res) {
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
router.get("/category/detail", function (req, res) {
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
router.post('/category/edit', function (req, res, next) {
    var sql = 'UPDATE category SET name = ?,parent_id = ? WHERE category_id=?';
    pool.query(sql, [req.body.name, req.body.parent_id, req.body.id], function (error, results) {
        res.json({
            status: true,
            msg: "修改成功"
        });
    })

});
// 获取所有分类
router.get('/category/list', function (req, res, next) {
    var sql = 'SELECT category_id,name,parent_id FROM category';
    pool.query(sql, function (error, results) {
        res.json({
            status: true,
            data: results
        });
    })
});

// 添加新的文章
router.post("/article/add/", function (req, res) {
    var sql = 'INSERT INTO article (category_id , title , description , content , create_date , main_photo ) VALUES (?, ? , ? , ? , CURRENT_TIMESTAMP() , ?)';
    pool.query(sql, [req.body.category_id, req.body.title, req.body.description, req.body.content , req.body.main_photo], function (error, results) {
        console.log(error);
        res.json({
            status: true,
            msg: "添加成功"
        });
    });
});
// 删除指定id的文章
router.post('/article/delete', function name(req, res) {
    var sql = 'DELETE FROM article WHERE article_id = ?';
    pool.query(sql, [req.body.id], function (error, results) {
        res.json({
            status: true,
            msg: "删除成功"
        });
    });
});
// 获取指定id的文章详情
router.get('/article/detail', function (req, res) {
    var sql = 'SELECT * FROM article WHERE article_id = ?';
    pool.query(sql, [req.query.id], function (error, results) {
        res.json({
            status: true,
            msg: "获取成功",
            data: results[0]
        });
    });
});
// 编辑指定id文章
router.post('/article/edit', function (req, res) {
    var sql = 'UPDATE article SET category_id = ? , title = ? , description = ? , content = ? , main_photo = ? WHERE article_id = ?';
    pool.query(sql, [req.body.category_id, req.body.title, req.body.description, req.body.content, req.body.main_photo, req.body.id], function (error, results) {
        res.json({
            status: true,
            msg: "编辑成功",
        });
    });
});
// 获取文章列表
router.get("/article/list", function (req, res) {
    var sql = 'SELECT * FROM article WHERE category_id = ?';
    pool.query(sql, [req.query.id], function (error, results) {
        res.json({
            status: true,
            msg: "获取成功",
            data: results
        });
    });
});


module.exports = router;