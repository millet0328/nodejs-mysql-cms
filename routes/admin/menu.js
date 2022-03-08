const express = require('express');
const router = express.Router();
// 数据库
let db = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 登录或者注册之后返回的token，请设置在request header中.
 */

/**
 * @api {get} /menu/tree 根据角色id获取侧边栏树形菜单
 * @apiName TreeMenu
 * @apiGroup admin-Menu
 * @apiPermission 后台系统
 * 
 * @apiUse Authorization
 * 
 * @apiQuery {Number} id 角色id.
 *
 * @apiSampleRequest /menu/tree
 */
router.get('/tree', async (req, res) => {
	let { id } = req.query;
	let sql = `SELECT m.* FROM MENU m JOIN role_menu rm ON rm.menu_id = m.id WHERE rm.role_id = ? ORDER BY menu_order;`;
	let results = await db.query(sql, [id]);
	//成功
	res.json({
		status: true,
		msg: "success!",
		data: results
	});

});
module.exports = router;
