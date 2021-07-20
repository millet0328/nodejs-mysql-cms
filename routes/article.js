var express = require('express');
var router = express.Router();
// 数据库
var db = require('../config/mysql');

/**
 * @api {post} /article/release 添加新的文章
 * @apiName ReleaseArticle
 * @apiGroup Article
 *
 * @apiParam { Number } cate_1st 一级分类id.
 * @apiParam { Number } cate_2nd 二级分类id.
 * @apiParam { String } title 文章标题.
 * @apiParam { String } description 文章摘要.
 * @apiParam { String } main_photo 文章主图.
 * @apiParam { String } content 文章内容.
 *
 * @apiSampleRequest /article/release
 */

router.post("/release/", async (req, res) => {
    let { cate_1st, cate_2nd, title, description, content, main_photo } = req.body;
    var sql = 'INSERT INTO article (cate_1st ,cate_2nd , title , description , content , create_date , main_photo ) VALUES (?, ? , ? , ?, ?, CURRENT_TIMESTAMP() , ?)';
    let { insertId, affectedRows } = await db.query(sql, [cate_1st, cate_2nd, title, description, content, main_photo]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "添加失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "添加成功"
    });
});

/**
 * @api {post} /article/remove 删除指定id的文章
 * @apiName RemoveArticle
 * @apiGroup Article
 *
 * @apiParam { Number } id 文章id
 *
 * @apiSampleRequest /article/remove
 */

router.post('/remove', async (req, res) => {
    let { id } = req.body;
    var sql = 'DELETE FROM article WHERE id = ?';
    let results = await db.query(sql, [id]);
    res.json({
        status: true,
        msg: "删除成功"
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
router.get('/detail', async (req, res) => {
    let { id } = req.query;
    var sql = 'SELECT * FROM article WHERE id = ?';
    let results = await db.query(sql, [id]);
    res.json({
        status: true,
        msg: "获取成功",
        data: results[0]
    });
});

/**
 * @api {post} /article/edit 编辑指定id文章
 * @apiName EditArticle
 * @apiGroup Article
 *
 * @apiParam { Number } id 文章id.
 * @apiParam { Number } cate_1st 一级分类id.
 * @apiParam { Number } cate_2nd 二级分类id.
 * @apiParam { String } title 文章标题.
 * @apiParam { String } description 文章摘要.
 * @apiParam { String } content 文章内容.
 * @apiParam { String } main_photo 文章主图.
 *
 * @apiSampleRequest /article/edit
 */
router.post('/edit', async (req, res) => {
    let { id, cate_1st, cate_2nd, title, description, content, main_photo } = req.body;
    var sql = 'UPDATE article SET cate_1st = ? , cate_2nd = ? , title = ? , description = ? , content = ? , main_photo = ? WHERE id = ?';
    let { affectedRows } = await db.query(sql, [cate_1st, cate_2nd, title, description, content, main_photo, id]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "修改失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "修改成功！"
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
 * @apiSuccess {Object[]} data 文章数组.
 * @apiSuccess {Number} total 文章总数.
 *
 * @apiSampleRequest /article/list
 */
router.get("/list", async (req, res) => {
    let { pagesize, pageindex } = req.query;
    pagesize = parseInt(pagesize);
    var offset = pagesize * (pageindex - 1);
    var sql = 'SELECT a.id, cate_1st, cate_2nd, title, description, main_photo, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c1.`name` AS cate_1st_name, c2.`name` AS cate_2nd_name FROM `article` a JOIN category c1 ON a.cate_1st = c1.id JOIN category c2 ON a.cate_2nd = c2.id ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ?;SELECT FOUND_ROWS() as total';
    let results = await db.query(sql, [pagesize, offset]);
    res.json({
        status: true,
        msg: "获取成功",
        ...results[1][0],
        data: results[0],
    });
});

/**
 * @api {get} /article/category 获取某分类下的文章列表
 * @apiDescription 注意：默认按照日期降序排序
 * @apiName ArticleCategory
 * @apiGroup Article
 *
 * @apiParam { Number } id 一级分类id.
 * @apiParam { Number } pagesize 每一页文章数量.
 * @apiParam { Number } pageindex 第几页.
 *
 * @apiSampleRequest /article/category
 */

router.get("/category", async (req, res) => {
    let { pagesize, pageindex, id } = req.query;
    pagesize = parseInt(pagesize);
    let offset = pagesize * (pageindex - 1);
    var sql = 'SELECT a.id, cate_1st, cate_2nd, title, description, main_photo, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c1.`name` AS cate_1st_name, c2.`name` AS cate_2nd_name FROM `article` a JOIN category c1 ON a.cate_1st = c1.id JOIN category c2 ON a.cate_2nd = c2.id WHERE a.cate_1st = ? ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ? ; SELECT FOUND_ROWS() as total';
    let results = await db.query(sql, [id, pagesize, offset]);
    res.json({
        status: true,
        msg: "获取成功",
        ...results[1][0],
        data: results[0]
    });
});


module.exports = router;
