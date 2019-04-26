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
    var sql = 'SELECT c1.*,c2.`name` AS parent_name FROM `category` c1 left JOIN category c2 ON c1.parent_id = c2.category_id';
    pool.query(sql, function (error, results) {
        res.json({
            status: true,
            data: results
        });
    })
});
// 获取一级分类
router.get("/category/first", function (req, res) {
    var sql = 'SELECT * FROM category WHERE parent_id = 0';
    pool.query(sql, function (error, results) {
        res.json({
            status: true,
            data: results
        });
    });
});

// 添加新的文章
router.post("/article/add/", function (req, res) {
    var sql = 'INSERT INTO article (category_id , title , description , content , create_date , main_photo ) VALUES (?, ? , ? , ? , CURRENT_TIMESTAMP() , ?)';
    pool.query(sql, [req.body.category_id, req.body.title, req.body.description, req.body.content, req.body.main_photo], function (error, results) {
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
        if (error) {
            console.log(error);
            return false;
        }
        if (!results.affectedRows) {
            res.json({
                status: false,
                msg: results
            });
            return false;
        }
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
// 获取所有文章列表,默认按照日期降序排序，分页 pagesize(一页数量) pageindex(第几页)
/**
 * 1   LIMIT 10    OFFSET 0
 * 2   LIMIT 10    OFFSET 10
 * 3   LIMIT 10    OFFSET 20
 * 4   LIMIT 10    OFFSET 30
 * ....
 * n   LIMIT 10    OFFSET 10*(n-1)
 */
router.get("/article/all", function (req, res) {
    var pagesize = parseInt(req.query.pagesize);
    var pageindex = req.query.pageindex;
    var offset = pagesize * (pageindex - 1);
    var sql = 'SELECT a.*, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c.`name` AS category_name FROM `article` a LEFT JOIN category c ON a.category_id = c.category_id ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ?';
    pool.query(sql, [pagesize, offset], function (error, results) {
        res.json({
            status: true,
            msg: "获取成功",
            data: results
        });
    });
});
// 获取指定分类下的文章列表,默认按照日期降序排序，分页 pagesize(一页数量) pageindex(第几页)
router.get("/article/byCategory", function (req, res) {
    var pagesize = parseInt(req.query.pagesize);
    var pageindex = req.query.pageindex;
    var offset = pagesize * (pageindex - 1);
    var sql = 'SELECT a.*, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c.`name` AS category_name FROM `article` a LEFT JOIN category c ON a.category_id = c.category_id ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ? WHERE category_id = ?';
    pool.query(sql, [pagesize, offset, req.query.id], function (error, results) {
        res.json({
            status: true,
            msg: "获取成功",
            data: results
        });
    });
});



module.exports = router;