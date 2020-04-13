var express = require('express');
var router = express.Router();
// 数据库
var db = require('../config/mysql');

/**
 * @api {post} /article/add 添加新的文章
 * @apiName AddArticle
 * @apiGroup Article
 *
 * @apiParam { Number } cate_1st 一级分类id.
 * @apiParam { Number } cate_2nd 二级分类id.
 * @apiParam { String } title 文章标题.
 * @apiParam { String } description 文章摘要.
 * @apiParam { String } main_photo 文章主图.
 * @apiParam { String } content 文章内容.
 * @apiParam { Number[] } tags 标签的id数组,如[1,2,3].
 *
 * @apiSampleRequest /article/add
 */

router.post("/add/", async (req, res) => {
	let { cate_1st, cate_2nd, title, description, content, main_photo, tags } = req.body;
	tags = JSON.parse(tags);
	var articleSQL =
		'INSERT INTO article (cate_1st ,cate_2nd , title , description , content , create_date , main_photo ) VALUES (?, ? , ? , ?, ?, CURRENT_TIMESTAMP() , ?)';
	let { insertId } = await db.query(articleSQL, [cate_1st, cate_2nd, title, description, content, main_photo]);
	// 依次插入文章_标签中间表
	let arr = [];
	tags.forEach(async (item) => {
		arr.push(`(${insertId},${item})`);
	});
	let tagSQL = `INSERT INTO article_tag (article_id, tag_id) VALUES ${arr.toString()}`;
	let result = await db.query(tagSQL);
	res.json({
		status: true,
		msg: "添加成功"
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

router.post('/delete', async (req, res) => {
	let { id } = req.body;
	var sql = 'DELETE FROM article WHERE id = ?;DELETE FROM article_tag WHERE article_id = ?';
	let results = await db.query(sql, [id, id]);
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
	// 查询文章对应标签
	var tagSQL = 'SELECT t.* FROM article_tag at JOIN tag t ON at.tag_id = t.id WHERE at.article_id = ?';
	let tags = await db.query(tagSQL, [id]);
	// 查询文章详情
	var articleSQL = 'SELECT a.*,DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c1.name AS cate_1st_name,c2.name AS cate_2nd_name FROM article a JOIN category c1 ON a.cate_1st = c1.id JOIN category c2 ON a.cate_2nd = c2.id WHERE a.id = ?';
	let detail = await db.query(articleSQL, [id]);
	detail[0].tags = tags;
	res.json({
		status: true,
		msg: "获取成功",
		data: detail[0]
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
 * @apiParam { Number[] } tags 标签的id数组,如[1,2,3].
 *
 * @apiSampleRequest /article/edit
 */
router.post('/edit', async (req, res) => {
	let { id, cate_1st, cate_2nd, title, description, content, main_photo, tags } = req.body;
	tags = JSON.parse(tags);
	var updateSQL =
		'UPDATE article SET cate_1st = ? , cate_2nd = ? , title = ? , description = ? , content = ? , main_photo = ? WHERE id = ?';
	let { affectedRows } = await db.query(updateSQL, [cate_1st, cate_2nd, title, description, content, main_photo, id]);
	if (!affectedRows) {
		res.json({
			status: false,
			msg: "修改失败！"
		});
		return;
	}
	// 考虑到标签的复杂性，先删除原有标签关系，再插入新的标签关系
	let arr = [];
	tags.forEach(async (item) => {
		arr.push(`(${id},${item})`);
	});
	let tagSQL = `DELETE FROM article_tag WHERE article_id = ?;INSERT INTO article_tag (article_id, tag_id) VALUES ${arr.toString()}`;
	let result = await db.query(tagSQL, id);
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
	var sql =
		'SELECT a.id, cate_1st, cate_2nd, title, description, main_photo, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c1.`name` AS cate_1st_name, c2.`name` AS cate_2nd_name FROM `article` a JOIN category c1 ON a.cate_1st = c1.id JOIN category c2 ON a.cate_2nd = c2.id ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ?;SELECT FOUND_ROWS() as total';
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
	var sql =
		'SELECT a.id, cate_1st, cate_2nd, title, description, main_photo, DATE_FORMAT(create_date,"%Y-%m-%d %T") AS create_time , DATE_FORMAT(update_date,"%Y-%m-%d %T") AS update_time, c1.`name` AS cate_1st_name, c2.`name` AS cate_2nd_name FROM `article` a JOIN category c1 ON a.cate_1st = c1.id JOIN category c2 ON a.cate_2nd = c2.id WHERE a.cate_1st = ? ORDER BY create_date DESC, update_date DESC LIMIT ? OFFSET ? ; SELECT FOUND_ROWS() as total';
	let results = await db.query(sql, [id, pagesize, offset]);
	res.json({
		status: true,
		msg: "获取成功",
		...results[1][0],
		data: results[0]
	});
});


module.exports = router;
