const express = require('express');
const router = express.Router();
// 数据库
let db = require('../config/mysql');

/**
 * @api {get} /menu/tree 根据角色id获取侧边栏树形菜单
 * @apiName TreeMenu
 * @apiGroup admin-Menu
 * @apiPermission admin
 *
 * @apiParam {Number} id 角色id.
 *
 * @apiSampleRequest /menu/tree
 */
router.get('/tree', async (req, res) => {
	let { id } = req.query;
	let sql =
		`SELECT m.* FROM MENU m JOIN role_menu rm ON rm.menu_id = m.id WHERE rm.role_id = ? ORDER BY menu_order;`;
	let results = await db.query(sql, [id]);
	//筛选出一级菜单
	let menu_1st = results.filter((item) => item.pId === 1 ? item : null);
	//递归循环数据
	parseToTree(menu_1st);
	//递归函数
	function parseToTree(array) {
		array.forEach(function(parent) {
			parent.children = [];
			results.forEach(function(child) {
				if (child.pId === parent.id) {
					parent.children.push(child);
				}
			});
			parseToTree(parent.children);
		});
	}
	//成功
	res.json({
		status: true,
		msg: "success!",
		data: menu_1st
	});

});
module.exports = router;
