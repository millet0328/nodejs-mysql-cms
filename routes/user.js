var express = require('express');
var router = express.Router();
// 数据库
var db = require('../config/mysql');

/**
 * @api {post} /user/register 注册普通用户
 * @apiName UserRegister
 * @apiGroup User
 *
 * @apiParam { String } username 用户名.
 * @apiParam { String } password 密码.
 * @apiParam { String } nickname 昵称.
 * @apiParam { String } sex 性别.
 * @apiParam { String } tel 手机号码.
 * 
 * @apiSampleRequest /user/register
 */
router.post('/register', async (req, res) => {
	let { username, password, nickname, sex, tel } = req.body;
	// 查询账户是否重名
	var sql = 'SELECT * FROM user WHERE username = ?';
	let results = await db.query(sql, [username]);
	// 重名
	if (results.length) {
		res.json({
			msg: "账户已存在",
			status: false,
		});
		return;
	}
	// 无重名
	var sql = 'INSERT INTO user (username,password,nickname,sex,tel) VALUES (?,?,?,?,?)';
	let { insertId, affectedRows } = await db.query(sql, [username, password, nickname, sex, tel]);
	if (affectedRows) {
		res.json({
			msg: "注册成功！",
			status: true,
			id: insertId
		});
	}
});
/**
 * @api {post} /user/login 登录普通用户
 * @apiName UserLogin
 * @apiGroup User
 *
 * @apiParam { String } username 用户名.
 * @apiParam { String } password 密码.
 *
 * @apiSampleRequest /user/login
 */
router.post('/login', async (req, res) => {
	let { username, password } = req.body;
	let sql = 'SELECT * FROM user WHERE username = ? AND `password` = ?';
	let results = await db.query(sql, [username, password]);
	if (results.length == 0) {
		res.json({
			msg: "账号或密码错误！",
			status: false,
		});
		return;
	}
	res.json({
		msg: "登陆成功！",
		status: true,
	});
});
/**
 * @api {get} /user/ 获取用户个人资料
 * @apiName UserInfo
 * @apiGroup User
 *
 * @apiParam { Number } id 用户id.
 * 
 * @apiSampleRequest /user/
 */
router.get('/', async (req, res) => {
	let { id } = req.query;
	var sql = 'SELECT username,nickname,sex,tel FROM user WHERE id = ? ';
	let results = await db.query(sql, [id]);
	if (results.length == 0) {
		res.json({
			status: false,
			msg: "查无此人！"
		});
		return;
	}
	res.json({
		status: true,
		data: results[0]
	});
});

/**
 * @api {put} /user/:id 编辑个人资料
 * @apiName UserUpdate
 * @apiGroup User
 *
 * @apiParam { Number } id 用户id.
 * @apiParam { String } username 用户名.
 * @apiParam { String } nickname 昵称.
 * @apiParam { String } sex 性别.
 * @apiParam { String } tel 手机号码.
 *
 * @apiExample {js} 参数示例:
 * /user/3
 * 
 * @apiParamExample {json} body参数:
 *     {
 *       "username": '黄小米',
 *       "nickname":"hxm",
 *       "sex":"女",
 *       "tel":"15863008280"
 *     }
 * 
 * @apiSampleRequest /user
 */

router.put('/:id', async (req, res) => {
	let { id } = req.params;
	let { username, nickname, sex, tel } = req.body;
	let sql = 'UPDATE user SET username = ?,nickname = ?,sex = ?,tel = ? WHERE id = ?';
	let { affectedRows } = await db.query(sql, [username, nickname, sex, tel, id]);
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
 * @api {delete} /user/:id 删除账户
 * @apiName UserDelete
 * @apiGroup User
 *
 * @apiParam { Number } id 用户id.
 * 
 * @apiExample {js} 参数示例:
 * /user/3
 * 
 * @apiSampleRequest /user
 */

router.delete('/:id', async (req, res) => {
	let { id } = req.params;
	let sql = 'DELETE FROM user WHERE id = ?';
	let { affectedRows } = await db.query(sql, [id]);
	if (!affectedRows) {
		res.json({
			status: false,
			msg: "fail！"
		});
		return;
	}
	res.json({
		status: true,
		msg: "success!",
	});
})

/**
 * @api {get} /user/list 获取用户列表
 * @apiName UserList
 * @apiGroup User
 *
 * @apiSampleRequest /user/list
 */

router.get('/list', async (req, res) => {
	var sql = 'SELECT id,username,nickname,sex,tel FROM user';
	let results = await db.query(sql);
	res.json({
		status: true,
		data: results
	});
});

module.exports = router;
