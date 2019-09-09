var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;

/**
 * @api {post} /article/add 添加新的文章
 * @apiName AddArticle
 * @apiGroup Article
 *
 * @apiParam { Number } category_id 分类id.
 * @apiParam { String } title 文章标题.
 * @apiParam { String } description 文章摘要.
 * @apiParam { String } content 文章内容.
 * @apiParam { String } main_photo 文章主图.
 *
 * @apiSampleRequest /article/add
 */

router.post("/add/", function (req, res) {
    let { category_id, title, description, content, main_photo } = req.body;
    var sql = 'INSERT INTO article (category_id , title , description , content , create_date , main_photo ) VALUES (?, ? , ? , ? , CURRENT_TIMESTAMP() , ?)';
    pool.query(sql, [category_id, title, description, content, main_photo], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            msg: "添加成功"
        });
    });
});

/**
 * @api {post} /article/delete 删除指定id的文章
 * @apiName DeleteArticle
 * @apiGroup Article
 *
 * @apiParam { Number } id 文章id
 *
 * @apiSampleRequest /article/delete
 */

router.post('/delete', function name(req, res) {
    let { id } = req.body;
    var sql = 'DELETE FROM article WHERE article_id = ?';
    pool.query(sql, [id], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            msg: "删除成功"
        });
    });
});

/**
 * @api {get} /article/detail 获取指定id的文章详情
 * @apiName ArticleDetail
 * @apiGroup Article
 *
 * @apiParam { Number } id 文章id
 *
 * @apiSampleRequest /article/detail
 */
router.get('/detail', function (req, res) {
    let { id } = req.query;
    var sql = 'SELECT * FROM article WHERE article_id = ?';
    pool.query(sql, [id], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            msg: "获取成功",
            data: results[0]
        });
    });
});

/**
 * @api {post} /article/edit 编辑指定id文章
 * @apiName EditArticle
 * @apiGroup Article
 *
 * @apiParam { Number } id 文章id.
 * @apiParam { Number } category_id 分类id.
 * @apiParam { String } title 文章标题.
 * @apiParam { String } description 文章摘要.
 * @apiParam { String } content 文章内容.
 * @apiParam { String } main_photo 文章主图.
 *
 * @apiSampleRequest /article/edit
 */
router.post('/edit', function (req, res) {
    let { id, category_id, title, description, content, main_photo } = req.body;
    var sql = 'UPDATE article SET category_id = ? , title = ? , description = ? , content = ? , main_photo = ? WHERE article_id = ?';
    pool.query(sql, [category_id, title, description, content, main_photo, id], function (error, results) {
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
// 获取所有文章列表,默认按照日期降序排序，分页 pagesize(一页数量) pageindex(第几页)
/**
 * 1   LIMIT 10    OFFSET 0
 * 2   LIMIT 10    OFFSET 10
 * 3   LIMIT 10    OFFSET 20
 * 4   LIMIT 10    OFFSET 30
 * ....
 * n   LIMIT 10    OFFSET 10*(n-1)
 */
/**
 * @api {get} /article/list 获取所有文章列表
 * @apiDescription 注意：默认按照日期降序排序
 * @apiName ArticleList
 * @apiGroup Article
 *
 * @apiParam { Number } pagesize 每一页文章数量.
 * @apiParam { Number } pageindex 第几页.
 *
 * @apiSampleRequest /article/list
 */
router.get("/list", function (req, res) {
    let { pagesize, pageindex } = req.query;
    pagesize = parseInt(pagesize);
    var offset = pagesize * (pageindex - 1);
    var sql = 'SELECT a.*, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c.`name` AS category_name FROM `article` a LEFT JOIN category c ON a.category_id = c.category_id ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ?';
    pool.query(sql, [pagesize, offset], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            msg: "获取成功",
            data: results
        });
    });
});

/**
 * @api {get} /article/category 获取某分类下的文章列表
 * @apiDescription 注意：默认按照日期降序排序
 * @apiName ArticleCategory
 * @apiGroup Article
 *
 * @apiParam { Number } id 分类id.
 * @apiParam { Number } pagesize 每一页文章数量.
 * @apiParam { Number } pageindex 第几页.
 *
 * @apiSampleRequest /article/list
 */

router.get("/category", function (req, res) {
    let { pagesize, pageindex, id } = req.query;
    pagesize = parseInt(pagesize);
    let offset = pagesize * (pageindex - 1);
    var sql = 'SELECT a.*, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c.`name` AS category_name FROM `article` a LEFT JOIN category c ON a.category_id = c.category_id ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ? WHERE category_id = ?';
    pool.query(sql, [pagesize, offset, id], function (error, results) {
        if (error) throw error;
        res.json({
            status: true,
            msg: "获取成功",
            data: results
        });
    });
});



module.exports = router;