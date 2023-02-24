const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {post} /user/remove 删除账户
 * @apiName UserRemove
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } user_id 用户id.
 *
 * @apiSampleRequest /user/remove
 */

router.post('/remove', async (req, res) => {
    let { user_id } = req.body;
    let sql = 'DELETE FROM `cms_user` WHERE user_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [user_id]);
    if (affectedRows === 0) {
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
    // 查询列表
    const select_sql = 'SELECT user_id,username,nickname,sex,tel,email,avatar,usable FROM `cms_user` LIMIT ? OFFSET ?';
    let [users] = await pool.query(select_sql, [pagesize, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(*) as total FROM `cms_user`';
    let [total] = await pool.query(total_sql, []);
    res.json({
        status: true,
        data: users,
        ...total[0],
    });
});

/**
 * @api {post} /user/usable 启用/禁用账户
 * @apiName UserUsable
 * @apiPermission 后台系统
 * @apiGroup User
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } user_id 用户id.
 * @apiBody { Number=1,-1 } usable 状态，1-启用，-1-禁用.
 *
 * @apiSampleRequest /user/usable
 */

router.post('/usable', async (req, res) => {
    let { user_id, usable } = req.body;
    let sql = 'UPDATE `cms_user` SET usable = ? WHERE user_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [usable, user_id]);
    if (affectedRows === 0) {
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
