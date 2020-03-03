const express = require('express');
const router = express.Router();
// 数据库
let db = require('../config/mysql');
/**
 * @api {get} /tag/list 获取标签列表
 * @apiName TagList
 * @apiGroup Tag
 * @apiPermission user
 *
 * @apiSampleRequest /tag/list
 */
router.get('/list', async (req, res) => {
	var sql = 'SELECT * FROM tag';
	let results = await db.query(sql);
	res.json({
		status: true,
		data: results
	});
});

/**
 * @api {post} /tag/add 创建新的标签
 * @apiName AddTag
 * @apiGroup Tag
 * @apiPermission user
 * 
 * @apiParam { String } name 标签名.
 *
 * @apiSampleRequest /tag/add
 */
router.post('/add', async (req, res) => {
	let { name } = req.body;
	var sql = 'INSERT INTO tag (name) values (?)';
	let { insertId, affectedRows } = await db.query(sql, [name]);
	if (affectedRows) {
		res.json({
			msg: "创建成功！",
			status: true,
			id: insertId
		});
	}
});

/**
 * @api {post} /tag/edit 编辑标签名称
 * @apiName EditTag
 * @apiGroup Tag
 * @apiPermission user
 * 
 * @apiParam { Number } id 标签id.
 * @apiParam { String } name 标签名称.
 *
 * @apiSampleRequest /tag/edit
 */
router.post('/edit', async (req, res) => {
	let { id, name } = req.body;
	let sql = 'UPDATE tag SET name = ? WHERE id = ?';
	let { affectedRows } = await db.query(sql, [name, id]);
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
	})
});

/**
 * @api {post} /tag/delete 删除标签
 * @apiDescription 有文章与标签关联，不允许删除标签；将关联文章删除，标签没有关联，可以删除标签；
 * @apiName DeleteTag
 * @apiGroup Tag
 * @apiPermission user
 * 
 * @apiParam { Number } id 标签id.
 *
 * @apiSampleRequest /tag/delete
 */
router.post('/delete', async (req, res) => {
	let { id } = req.body;
	// 判断是否有标签关联文章
	let check_sql = 'SELECT * FROM article_tag WHERE tag_id = ?';
	let results = await db.query(check_sql, [id]);
	if (results.length) {
		res.json({
			status: false,
			msg: "删除失败，有文章关联标签！"
		});
		return;
	}
	// 删除操作
	let delete_sql = 'DELETE FROM tag WHERE id = ?';
	let { affectedRows } = await db.query(delete_sql, [id]);
	if (!affectedRows) {
		res.json({
			status: false,
			msg: "删除失败！"
		});
		return;
	}
	res.json({
		status: true,
		msg: "删除成功！"
	})
});
module.exports = router;
