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
 * @apiQuery { Number } article_id 文章id
 *
 * @apiSampleRequest /article/detail
 */
router.get('/detail', async (req, res) => {
    let { article_id } = req.query;
    // 查询文章对应标签
    const tag_sql = 'SELECT t.* FROM `cms_article_tag` at JOIN `cms_tag` t ON at.tag_id = t.tag_id WHERE at.article_id = ?';
    let [tags] = await pool.query(tag_sql, [article_id]);
    // 查询文章详情
    const article_sql = 'SELECT a.*, DATE_FORMAT(a.create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(a.update_date,"%Y-%m-%d %T") AS update_time, c1.cate_name AS cate_1st_name, c2.cate_name AS cate_2nd_name FROM `cms_article` a JOIN `cms_category` c1 ON a.cate_1st = c1.cate_id JOIN `cms_category` c2 ON a.cate_2nd = c2.cate_id WHERE a.article_id = ?';
    let [articles] = await pool.query(article_sql, [article_id]);
    res.json({
        status: true,
        msg: "获取成功",
        data: { ...articles[0], tags }
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
 * @apiDescription 前台页面，保证status = 2，显示审核通过的文章。注意：默认按照日期降序排序
 * @apiName ArticleList
 * @apiPermission 后台系统、前台
 * @apiGroup Article
 *
 * @apiQuery { Number } [pagesize=10] 每一页文章数量。
 * @apiQuery { Number } [pageindex=1] 第几页。
 * @apiQuery { Number } [cate_id] 分类id。与cate_level同时传参
 * @apiQuery { Number = 1,2 } [cate_level] 分类层级。与cate_id同时传参
 * @apiQuery { String } [keyword] 搜索关键词。
 * @apiQuery { Number=1,2,-1 } [status] 审核状态，状态分为三种：1-审核中，2-通过，-1-未通过。
 *
 * @apiSuccess {Object[]} data 文章数组.
 * @apiSuccess {Number} total 文章总数.
 *
 * @apiSampleRequest /article/list
 */
router.get("/list", async (req, res) => {
    let { pagesize = 10, pageindex = 1, cate_id, cate_level, keyword, status } = req.query;
    // TODO 根据标签获取文章列表
    // 计算偏移量
    pagesize = parseInt(pagesize);
    const offset = pagesize * (pageindex - 1);
    let cate = [null, 'cate_1st', 'cate_2nd'];
    // 根据参数，拼接SQL
    let article_sql = 'SELECT a.article_id, cate_1st, cate_2nd, title, description, main_photo, DATE_FORMAT(a.create_date,"%Y-%m-%d %T") AS create_time, DATE_FORMAT(a.update_date,"%Y-%m-%d %T") AS update_time, c1.cate_name AS cate_1st_name, c2.cate_name AS cate_2nd_name FROM `cms_article` a JOIN `cms_category` c1 ON a.cate_1st = c1.cate_id JOIN `cms_category` c2 ON a.cate_2nd = c2.cate_id WHERE 1 = 1';

    let total_sql = 'SELECT COUNT(*) AS total FROM `cms_article` WHERE 1 = 1';

    let tag_sql = 'SELECT t.*, at.article_id FROM ( SELECT article_id FROM `cms_article` WHERE 1 = 1';

    if (cate_level) {
        let cate_name = cate[cate_level];
        article_sql += ` AND ${cate_name} = ${cate_id}`;
        total_sql += ` AND ${cate_name} = ${cate_id}`;
        tag_sql += ` AND ${cate_name} = ${cate_id}`;
    }
    if (keyword) {
        article_sql += ` AND title LIKE '%${keyword}%'`;
        total_sql += ` AND title LIKE '%${keyword}%'`;
        tag_sql += ` AND title LIKE '%${keyword}%'`;
    }
    if (status) {
        article_sql += ` AND audit_status = ${status}`;
        total_sql += ` AND audit_status = ${status}`;
        tag_sql += ` AND audit_status = ${status}`;
    }
    article_sql += ' ORDER BY a.create_date DESC, a.update_date DESC LIMIT ? OFFSET ?';
    tag_sql += ' ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ? ) AS a JOIN `cms_article_tag` at ON a.article_id = at.article_id JOIN `cms_tag` t ON at.tag_id = t.tag_id';
    // 查询文章
    let [articles] = await pool.query(article_sql, [pagesize, offset]);
    // 计算总数
    let [total] = await pool.query(total_sql, []);
    // 查询tag标签
    let [tags] = await pool.query(tag_sql, [pagesize, offset]);
    articles.forEach((article) => {
        article.tags = tags.filter((item) => item.article_id === article.article_id);
    });
    res.json({
        status: true,
        msg: "获取成功",
        data: articles,
        ...total[0],
    });
});

module.exports = router;
