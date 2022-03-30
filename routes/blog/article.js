const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @api {get} /article/detail 获取指定id的文章详情
 * @apiName ArticleDetail
 * @apiPermission 后台系统、前台
 * @apiGroup Article
 *
 * @apiQuery { Number } id 文章id
 *
 * @apiSampleRequest /article/detail
 */
router.get('/detail', async (req, res) => {
    let { id } = req.query;
    // 查询文章对应标签
    const tag_sql = 'SELECT t.* FROM article_tag at JOIN tag t ON at.tag_id = t.id WHERE at.article_id = ?';
    let [tags] = await pool.query(tag_sql, [id]);
    // 查询文章详情
    const article_sql = 'SELECT a.*, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c1.`name` AS cate_1st_name, c2.`name` AS cate_2nd_name FROM `article` a JOIN category c1 ON a.cate_1st = c1.id JOIN category c2 ON a.cate_2nd = c2.id WHERE a.id = ?';
    let [results, fields] = await pool.query(article_sql, [id]);
    results[0].tags = tags;
    res.json({
        status: true,
        msg: "获取成功",
        data: results[0]
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
 * @api {get} /article/list 获取文章列表
 * @apiDescription 注意：默认按照日期降序排序
 * @apiName ArticleList
 * @apiPermission 后台系统、前台
 * @apiGroup Article
 *
 * @apiQuery { Number } [pagesize=10] 每一页文章数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 * @apiQuery { Number } [cate_id] 分类id。与cate_level同时传参
 * @apiQuery { Number = 1,2 } [cate_level] 分类层级。与cate_id同时传参
 * @apiQuery { String } [keyword] 搜索关键词;
 *
 * @apiSuccess {Object[]} data 文章数组.
 * @apiSuccess {Number} total 文章总数.
 *
 * @apiSampleRequest /article/list
 */
router.get("/list", async (req, res) => {
    let { pagesize = 10, pageindex = 1, cate_id, cate_level, keyword } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    const offset = pagesize * (pageindex - 1);
    // 根据参数，拼接SQL
    let article_sql = 'SELECT SQL_CALC_FOUND_ROWS a.id, cate_1st, cate_2nd, title, description, main_photo, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c1.`name` AS cate_1st_name, c2.`name` AS cate_2nd_name FROM `article` a JOIN category c1 ON a.cate_1st = c1.id JOIN category c2 ON a.cate_2nd = c2.id WHERE 1 = 1';
    let cate = [null, 'cate_1st', 'cate_2nd'];
    if (cate_level) {
        let cate_name = cate[cate_level];
        article_sql += ` AND ${cate_name} = ${cate_id}`;
    }
    if (keyword) {
        article_sql += ` AND a.title LIKE '%${keyword}%'`;
    }
    article_sql += ' ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ? ;SELECT FOUND_ROWS() as total;'
    // 查询文章
    let [results, fields] = await pool.query(article_sql, [pagesize, offset]);
    // 循环查询tag标签
    for (const item of results[0]) {
        let tag_sql = 'SELECT t.* FROM article_tag at JOIN tag t ON at.tag_id = t.id WHERE article_id = ?';
        let [tags] = await pool.query(tag_sql, [item.id]);
        item.tags = tags;
    }

    res.json({
        status: true,
        msg: "获取成功",
        ...results[1][0],
        data: results[0],
    });
});

module.exports = router;
