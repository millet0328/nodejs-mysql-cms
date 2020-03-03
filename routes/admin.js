var express = require('express');
var router = express.Router();
// 数据库
let db = require('../config/mysql');
let { pool } = db;
// JSON Web Token
const jwt = require("jsonwebtoken");
/**
 * @apiDefine SuccessResponse
 * @apiSuccess { Boolean } status 请求状态.
 * @apiSuccess { String } msg 请求结果信息.
 * @apiSuccess { Object } data 请求数据信息.
 * @apiSuccess { String } data.token 注册成功之后返回的token.
 * @apiSuccess { String } data.id 用户uid.
 * @apiSuccess { String } data.role 用户角色id.
 *
 * @apiSuccessExample { json } 200返回的JSON:
 *  HTTP / 1.1 200 OK
 *  {
 *      "status": true,
 *      "msg": "成功",
 *      "data":{
 *          "id":5,
 *          "role":3,
 *          "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NSwidXNlcm5hbWUiOiIxIiwiaWF0IjoxNTU3MzM1Mzk3LCJleHAiOjE1NTczNDI1OTd9.vnauDCSHdDXaZyvTjNOz0ezpiO-UACbG-oHg_v76URE"
 *      }
 *  }
 */
/**
 * @api {post} /admin/register 注册管理员账户
 * @apiDescription 注册成功， 返回token, 请在头部headers中设置Authorization: `Bearer ${token}`,所有请求都必须携带token;
 * @apiName AdminRegister
 * @apiGroup Admin
 *
 * @apiParam { String } username 用户名.
 * @apiParam { String } password 密码.
 * @apiParam { String } fullname 姓名.
 * @apiParam { String } sex 性别.
 * @apiParam { String } tel 手机号码.
 * @apiParam { String } [email] 邮箱地址.
 * 
 * @apiUse SuccessResponse
 * 
 * @apiSampleRequest /admin/register
 */
router.post('/register', async (req, res) => {
	let { username, password, fullname, sex, tel, email } = req.body;
	// 查询账户是否重名
	let sql = 'SELECT * FROM admin WHERE username = ?';
	let results = await db.query(sql, [username]);
	// 查询账户是否存在
	if (results.length) {
		res.json({
			msg: "账户已存在",
			status: false,
		});
		return;
	}
	pool.getConnection(function(err, connection) {
		if (err) throw err; // not connected!
		connection.beginTransaction(function(err) {
			if (err) throw err;
			let sql = `INSERT INTO admin (username,password,fullname,sex,tel,email) VALUES (?,?,?,?,?,?)`;
			connection.query(sql, [username, password, fullname, sex, tel, email], function(error, results, fields) {
				let { insertId, affectedRows } = results;
				if (error || affectedRows <= 0) {
					return connection.rollback(function() {
						throw error || `${affectedRows} rows changed!`;
					});
				}
				let sql = `INSERT INTO admin_role (admin_id,role_id) VALUES (?,3)`;
				connection.query(sql, [insertId], function(error, results, fields) {
					if (error) {
						return connection.rollback(function() {
							throw error;
						});
					}
					connection.commit(function(err) {
						if (err) {
							return connection.rollback(function() {
								throw err;
							});
						}
					});
					let payload = {
						id: insertId,
						username,
						role: 3,
					};
					// 生成token
					let token = jwt.sign(payload, 'secret', { expiresIn: '4h' });
					// 存储成功
					res.json({
						status: true,
						msg: "注册成功！",
						data: {
							token,
							id: insertId,
							role: 3
						}
					});
				});

			});
		});
	});

});

/**
 * @api {post} /admin/login 登录管理员账户
 * @apiDescription 登录成功， 返回token,有效期4小时，请在头部headers中设置Authorization: `Bearer ${token}`, 所有请求都必须携带token;
 * @apiName AdminLogin
 * @apiGroup Admin
 *
 * @apiParam { String } username 用户名.
 * @apiParam { String } password 密码.
 * 
 * @apiUse SuccessResponse
 * 
 * @apiSampleRequest /admin/login
 */

router.post('/login', async (req, res) => {
	let { username, password } = req.body;
	let sql =
		`SELECT a.*,r.id AS role FROM ADMIN a LEFT JOIN admin_role ar ON a.id = ar.admin_id LEFT JOIN role r ON r.id = ar.role_id  WHERE username = ? AND password = ?`;
	let results = await db.query(sql, [username, password]);
	if (results.length == 0) {
		res.json({
			msg: "账号或密码错误！",
			status: false,
		});
		return;
	}
	let { id, role } = results[0];
	// 登录成功
	let payload = {
		id,
		username,
		role,
	};
	// 生成token
	let token = jwt.sign(payload, 'secret', { expiresIn: '4h' });
	res.json({
		status: true,
		msg: "登录成功！",
		data: {
			token,
			id,
			role,
		}
	});


});
/**
 * @api {get} /admin/info 获取管理员个人资料
 * @apiName AdminInfo
 * @apiGroup Admin
 *
 * @apiParam { Number } id 管理员id.
 *
 * @apiSampleRequest /admin/info
 */
router.get('/info', async (req, res) => {
	let { id } = req.query;
	var sql =
		'SELECT a.id,a.username,a.fullname,a.sex,a.email,a.avatar,a.tel,r.role_name,r.id AS role FROM ADMIN AS a LEFT JOIN admin_role AS ar ON a.id = ar.admin_id LEFT JOIN role AS r ON r.id = ar.role_id WHERE a.id = ?';
	let results = await db.query(sql, [id]);
	res.json({
		status: true,
		data: results[0]
	});
});

/**
 * @api {post} /admin/info 编辑管理员个人资料
 * @apiName AdminUpdate
 * @apiGroup Admin
 *
 * @apiParam { Number } id 管理员id.
 * @apiParam { String } username 用户名.
 * @apiParam { String } fullname 姓名.
 * @apiParam { String } sex 性别.
 * @apiParam { String } tel 手机号码.
 * @apiParam { String } email 邮箱地址.
 * @apiParam { String } avatar 头像地址.
 *
 * @apiSampleRequest /admin/info
 */

router.post('/info', async (req, res) => {
	let { id, username, fullname, sex, tel, email, avatar } = req.body;
	let sql = 'UPDATE admin SET username = ?,fullname = ?,sex = ?,tel = ?,email = ?, avatar = ? WHERE id = ?';
	let { affectedRows } = await db.query(sql, [username, fullname, sex, tel, email, avatar, id]);
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

/**
 * @api {post} /admin/delete 删除账户
 * @apiName AdminDelete
 * @apiGroup Admin
 *
 * @apiParam { Number } id 管理员id.
 *
 * @apiSampleRequest /admin/delete
 */
router.post('/delete', async (req, res) => {
	let { id } = req.body;
	let sql = 'DELETE FROM admin WHERE id = ?';
	let { affectedRows } = await db.query(sql, [id]);
	if (!affectedRows) {
		res.json({
			status: false,
			msg: "删除失败！"
		});
		return;
	}
	res.json({
		status: true,
		msg: "删除成功"
	});
});

/**
 * @api {get} /admin/list 获取管理员列表
 * @apiName AdminList
 * @apiGroup Admin
 *
 * @apiSampleRequest /admin/list
 */

router.get('/list', async (req, res) => {
	var sql = 'SELECT id, username, fullname, sex, tel, email, avatar FROM admin';
	let results = await db.query(sql);
	res.json({
		status: true,
		data: results
	});
});

module.exports = router;
