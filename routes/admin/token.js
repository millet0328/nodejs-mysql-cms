const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

// Token 生成器
const token_manager = require("../../plugins/jwt");

/**
 * @apiDefine Refresh_Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${refresh_token}`，登录成功时返回的 refresh_token。
 */

/**
 * 路由"/token/refresh/system"----单独校验
 * 校验refresh token是否有效，无效则抛出Error/UnauthorizedError
 */

router.use('/refresh/system', token_manager.guard([], async (req, token) => {
    let { type, jti } = token.payload;
    // 检测是否refresh_token
    if (type !== 'refresh') {
        throw Error('请在header中添加refresh_token!');
    }
    // 检测refresh_token是否失效
    let select_sql = 'SELECT u.user_id, u.refresh_token, ur.role_id FROM `sys_user` u JOIN `sys_user_role` ur ON u.user_id = ur.user_id WHERE jwt_id = ?';
    let [results] = await pool.query(select_sql, [jti]);
    // 查询结果为空 / refresh_token为空，皆为失效
    let isRevoked = results.length === 0 || !results[0].refresh_token;
    // refresh_token有效，在其payload中添加user_id、role_id等数据
    if (isRevoked === false) {
        token.payload = { ...token.payload, ...results[0] }
    }
    return isRevoked;
}));

/**
 * 校验失败，抛出Error/UnauthorizedError，统一在此处理
 * 返回403状态码,返回错误信息
 */
router.use('/refresh/system', (err, req, res, next) => {
    if (err.name === 'UnauthorizedError') {
        res.status(403).json({
            ...err,
            status: false,
        });
    } else {
        next(err);
    }
});

/**
 * @api {post} /token/refresh/system 刷新access_token--后台系统
 * @apiDescription refresh_token有效期大约30天，利用refresh_token重新换取一个有效期30分钟的access_token，如果refresh_token到期，返回403，强制用户重新登录。
 * @apiName RefreshSystemToken
 * @apiPermission 后台系统
 * @apiGroup JSON Web Token
 *
 * @apiUse Refresh_Authorization
 *
 * @apiSampleRequest /token/refresh/system
 */

router.post('/refresh/system', async (req, res) => {
    let { user_id, role_id } = req.auth;
    // 生成payload
    let payload = { user_id, role_id };
    // 重新生成 access_token
    let access_token = token_manager.create_access_token({ ...payload, type: 'access' });
    // 登录成功
    res.json({
        status: true,
        msg: "刷新成功！",
        data: { access_token }
    });
});

module.exports = router;