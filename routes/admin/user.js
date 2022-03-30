const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 登录或者注册之后返回的token，请在头部headers中设置Authorization: `Bearer ${token}`.
 */

/**
 * @api {post} /user/remove 删除账户
 * @apiName UserRemove
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 用户id.
 *
 * @apiSampleRequest /user/remove
 */

router.post('/remove', async (req, res) => {
    let { id } = req.body;
    let sql = 'DELETE FROM user WHERE id = ?';
    let [{ affectedRows }] = await pool.query(sql, [id]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "删除失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "删除成功!",
    });
})

/**
 * @api {get} /user/list 获取用户列表
 * @apiName UserList
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiUse Authorization
 *
 * @apiQuery { Number } [pagesize=10] 每一页用户数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 *
 * @apiSampleRequest /user/list
 */
router.get('/list', async (req, res) => {
    let { pagesize = 10, pageindex = 1 } = req.query;
    pagesize = parseInt(pagesize);
    let offset = pagesize * (pageindex - 1);
    const sql = 'SELECT id,username,nickname,sex,tel,status FROM user LIMIT ? OFFSET ?; SELECT COUNT(*) as total FROM `user`;';
    let [results] = await pool.query(sql, [pagesize, offset]);
    res.json({
        status: true,
        ...results[1][0],
        data: results[0],
    });
});

/**
 * @api {post} /user/disable 启用/禁用账户
 * @apiName UserDisable
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 用户id.
 * @apiBody { Number=1,0 } status 状态，1-启用，0-禁用.
 *
 * @apiSampleRequest /user/disable
 */

router.post('/disable', async (req, res) => {
    let { id, status } = req.body;
    let sql = 'UPDATE user SET status = ? WHERE id = ?';
    let [{ affectedRows }] = await pool.query(sql, [id, status]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "修改失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "修改成功!",
    });
})

module.exports = router;
