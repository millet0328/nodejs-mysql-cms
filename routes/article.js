var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;
// 添加新的文章
router.post("/add/", function(req, res) {
    var sql = 'INSERT INTO article (category_id , title , description , content , create_date , main_photo ) VALUES (?, ? , ? , ? , CURRENT_TIMESTAMP() , ?)';
    pool.query(sql, [req.body.category_id, req.body.title, req.body.description, req.body.content, req.body.main_photo], function(error, results) {
        res.json({
            status: true,
            msg: "添加成功"
        });
    });
});
// 删除指定id的文章
router.post('/delete', function name(req, res) {
    var sql = 'DELETE FROM article WHERE article_id = ?';
    pool.query(sql, [req.body.id], function(error, results) {
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
router.get('/detail', function(req, res) {
    var sql = 'SELECT * FROM article WHERE article_id = ?';
    pool.query(sql, [req.query.id], function(error, results) {
        res.json({
            status: true,
            msg: "获取成功",
            data: results[0]
        });
    });
});
// 编辑指定id文章
router.post('/edit', function(req, res) {
    var sql = 'UPDATE article SET category_id = ? , title = ? , description = ? , content = ? , main_photo = ? WHERE article_id = ?';
    pool.query(sql, [req.body.category_id, req.body.title, req.body.description, req.body.content, req.body.main_photo, req.body.id], function(error, results) {
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
router.get("/all", function(req, res) {
    var pagesize = parseInt(req.query.pagesize);
    var pageindex = req.query.pageindex;
    var offset = pagesize * (pageindex - 1);
    var sql = 'SELECT a.*, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c.`name` AS category_name FROM `article` a LEFT JOIN category c ON a.category_id = c.category_id ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ?';
    pool.query(sql, [pagesize, offset], function(error, results) {
        res.json({
            status: true,
            msg: "获取成功",
            data: results
        });
    });
});
// 获取指定分类下的文章列表,默认按照日期降序排序，分页 pagesize(一页数量) pageindex(第几页)
router.get("/category", function(req, res) {
    let { pagesize, pageindex, id } = req.query;
    pagesize = parseInt(pagesize);
    let offset = pagesize * (pageindex - 1);
    var sql = 'SELECT a.*, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c.`name` AS category_name FROM `article` a LEFT JOIN category c ON a.category_id = c.category_id ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ? WHERE category_id = ?';
    pool.query(sql, [pagesize, offset, id], function(error, results) {
        res.json({
            status: true,
            msg: "获取成功",
            data: results
        });
    });
});



module.exports = router;