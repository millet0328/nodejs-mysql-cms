const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${access_token}`，登录成功返回的access_token。
 */

/**
 * @api {get} /tag/list 获取标签列表
 * @apiName TagList
 * @apiGroup Tag
 * @apiPermission 后台系统
 *
 * @apiQuery { Number } [pagesize=10] 每一页数量.
 * @apiQuery { Number } [pageindex=1] 第几页.
 *
 * @apiUse Authorization
 *
 * @apiSampleRequest /tag/list
 */
router.get('/list', async (req, res) => {
    let { pagesize = 10, pageindex = 1 } = req.query;
    // 计算偏移量
    pagesize = parseInt(pagesize);
    let offset = pagesize * (pageindex - 1);
    // 查询列表
    const select_sql = 'SELECT * FROM `cms_tag` LIMIT ? OFFSET ?';
    let [tags] = await pool.query(select_sql, [pagesize, offset]);
    // 计算总数
    let total_sql = 'SELECT COUNT(*) as total FROM `cms_tag`';
    let [total] = await pool.query(total_sql, []);
    res.json({
        status: true,
        data: tags,
        ...total[0],
    });
});

/**
 * @api {post} /tag/ 创建新的标签
 * @apiName AddTag
 * @apiGroup Tag
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiBody { String } tag_name 标签名.
 *
 * @apiSampleRequest /tag/
 */
router.post('/', async (req, res) => {
    let { tag_name } = req.body;
    const sql = 'INSERT INTO `cms_tag` (tag_name, create_date) VALUES (?, CURRENT_TIMESTAMP())';
    let [{ insertId: tag_id, affectedRows }] = await pool.query(sql, [tag_name]);
    if (affectedRows) {
        res.json({
            msg: "创建成功！",
            status: true,
            data: { tag_id }
        });
    }
});

/**
 * @api {put} /tag/:tag_id 编辑标签
 * @apiName EditTag
 * @apiGroup Tag
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam { Number } tag_id 标签id.
 * @apiBody { String } tag_name 标签名称.
 *
 * @apiExample {js} 参数示例:
 * /tag/3
 *
 * @apiParamExample {json} body参数:
 * {
 *    "tag_name": 'typescript',
 * }
 *
 * @apiSampleRequest /tag/
 */
router.put('/:tag_id', async (req, res) => {
    let { tag_id } = req.params;
    let { tag_name } = req.body;
    let sql = 'UPDATE `cms_tag` SET tag_name = ? WHERE tag_id = ?';
    let [{ affectedRows }] = await pool.query(sql, [tag_name, tag_id]);
    if (affectedRows === 0) {
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
 * @api {delete} /tag/:tag_id 删除标签
 * @apiDescription 删除标签，如果有文章关联此标签，将同时删除此关联关系；
 * @apiName RemoveTag
 * @apiGroup Tag
 * @apiPermission 后台系统
 *
 * @apiUse Authorization
 *
 * @apiParam { Number } tag_id 标签id.
 *
 * @apiExample {js} 参数示例:
 * /tag/3
 *
 * @apiSampleRequest /tag/
 */
router.delete('/:tag_id', async (req, res) => {
    let { tag_id } = req.params;
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 删除标签
        let delete_tag_sql = 'DELETE FROM `cms_tag` WHERE tag_id = ?';
        let [{ affectedRows: tag_affected_rows }] = await connection.query(delete_tag_sql, [tag_id]);
        if (tag_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "标签tag删除失败！" });
            return;
        }
        // 如果没有文章关联，仅删除标签即可;如果有文章关联标签，删除标签_文章关联
        let delete_connect_sql = 'DELETE FROM `cms_article_tag` WHERE tag_id = ?';
        await connection.query(delete_connect_sql, [tag_id]);
        // 一切顺利，提交事务
        await connection.commit();
        res.json({
            status: true,
            msg: "删除成功"
        });
    } catch (error) {
        await connection.rollback();
        res.status(500).json({
            status: false,
            msg: error.message,
            error,
        });
    }
});

module.exports = router;
