var express = require('express');
var router = express.Router();
// 数据库
var db = require('../../config/mysql');

/**
 * @api {post} /user/remove 删除账户
 * @apiName UserRemove
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiBody { Number } id 用户id.
 *
 * @apiSampleRequest /user/remove
 */

router.post('/remove', async (req, res) => {
    let { id } = req.body;
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
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiSampleRequest /user/list
 */
router.get('/list', async (req, res) => {
    const sql = 'SELECT id,username,nickname,sex,tel FROM user';
    let results = await db.query(sql);
    res.json({
        status: true,
        data: results
    });
});

module.exports = router;
