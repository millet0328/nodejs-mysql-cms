var express = require('express');
var router = express.Router();
// 数据库
var pool = require('../config/mysql').pool;

/**
 * @api {post} /category/add 添加分类
 * @apiDescription 注意：目前最多支持二级分类
 * @apiName AddCategory
 * @apiGroup Category
 *
 * @apiParam { String } name 分类名称.
 * @apiParam { Number } parent_id 父级分类id.一级分类的parent_id=0
 *
 * @apiSampleRequest /category/add
 */

router.post("/add", function(req, res) {
	let { name, parent_id } = req.body;
	var sql = 'INSERT INTO category (`name`,parent_id) VALUES (?,?);'
	pool.query(sql, [name, parent_id], function(error, results) {
		if (error) throw error;
		res.json({
			status: true,
			msg: "添加成功！",
			data: {
				id: results.insertId
			}
		});
	});
});
/**
 * @api {post} /category/delete 删除指定id分类
 * @apiDescription 注意：删除指定id分类,如果其拥有子级分类不允许删除，必须清空子分类才可删除。
 * @apiName DeleteCategory
 * @apiGroup Category
 *
 * @apiParam { Number } id 分类id
 *
 * @apiSampleRequest /category/delete
 */

router.post("/delete", function(req, res) {
	let { id } = req.body;
	var sql = 'DELETE FROM category  WHERE category_id = ?'
	pool.query(sql, [id, id], function(error, results) {
		if (error) throw error;
		res.json({
			status: true,
			msg: "删除成功"
		});
	});

});
/**
 * @api {get} /category/detail 获取指定id的分类详情
 * @apiName CategoryDetail
 * @apiGroup Category
 *
 * @apiParam { Number } id 分类id
 *
 * @apiSampleRequest /category/detail
 */
router.get("/detail", function(req, res) {
	let { id } = req.query;
	var sql = 'SELECT * FROM category WHERE category_id = ?';
	pool.query(sql, [id], function(error, results) {
		if (error) throw error;
		res.json({
			status: true,
			data: results[0]
		});
	});
});
//
/**
 * @api {post} /category/edit 编辑指定id分类
 * @apiName EditCategory
 * @apiGroup Category
 *
 * @apiParam { Number } id 分类id
 * @apiParam { String } name 分类名称.
 * @apiParam { Number } parent_id 父级分类id.一级分类的parent_id=0
 *
 * @apiSampleRequest /category/edit
 */
router.post('/edit', function(req, res) {
	var sql = 'UPDATE category SET name = ?,parent_id = ? WHERE category_id = ?';
	let { id, name, parent_id } = req.body;
	pool.query(sql, [name, parent_id, id], function(error, results) {
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
	})

});
/**
 * @api {get} /category/list 获取所有分类
 * @apiName CategoryList
 * @apiGroup Category
 *
 * @apiSampleRequest /category/list
 */
router.get('/list', function(req, res) {
	var sql =
		'SELECT c1.*,c2.`name` AS parent_name FROM `category` c1 left JOIN category c2 ON c1.parent_id = c2.category_id';
	pool.query(sql, function(error, results) {
		if (error) throw error;
		res.json({
			status: true,
			data: results
		});
	})
});
/**
 * @api {get} /category/sub 获取子级分类
 * @apiName CategorySub
 * @apiGroup Category
 * 
 * @apiParam { Number } id 父级id。一级分类的父类id=0;
 * 
 * @apiSampleRequest /category/sub
 */
router.get("/sub", function(req, res) {
	let { id } = req.query;
	var sql = 'SELECT * FROM category WHERE parent_id = ?';
	pool.query(sql, [id], function(error, results) {
		if (error) throw error;
		res.json({
			status: true,
			data: results
		});
	});
});

module.exports = router;
