const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');
/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 需在请求headers中设置Authorization: `Bearer ${token}`，登录/注册成功返回的token。
 */

/**
 * @api {post} /article/release 添加新的文章
 * @apiName ReleaseArticle
 * @apiPermission 后台系统
 * @apiGroup Article
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } cate_1st 一级分类id.
 * @apiBody { Number } cate_2nd 二级分类id.
 * @apiBody { String } title 文章标题.
 * @apiBody { String } description 文章摘要.
 * @apiBody { String } main_photo 文章主图.
 * @apiBody { String } content 文章内容.
 *
 * @apiSampleRequest /article/release
 */

router.post("/release/", async (req, res) => {
    let { cate_1st, cate_2nd, title, description, content, main_photo } = req.body;
    const sql = 'INSERT INTO article (cate_1st ,cate_2nd , title , description , content , create_date , main_photo ) VALUES (?, ? , ? , ?, ?, CURRENT_TIMESTAMP() , ?)';
    let [{ insertId, affectedRows }] = await pool.query(sql, [cate_1st, cate_2nd, title, description, content, main_photo]);
    if (affectedRows === 0) {
        res.json({
            status: false,
            msg: "添加失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "添加成功",
        data: {
            id: insertId
        }
    });
});

/**
 * @api {post} /article/remove 删除指定id的文章
 * @apiName RemoveArticle
 * @apiPermission 后台系统
 * @apiGroup Article
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 文章id
 *
 * @apiSampleRequest /article/remove
 */

router.post('/remove', async (req, res) => {
    let { id } = req.body;
    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        // 删除文章
        let delete_article_sql = 'DELETE FROM article WHERE id = ?;';
        let [{ affectedRows: article_affected_rows }] = await connection.query(delete_article_sql, [id]);
        if (article_affected_rows === 0) {
            await connection.rollback();
            res.json({ status: false, msg: "文章article删除失败！" });
            return;
        }
        // 删除标签
        let delete_tag_sql = 'DELETE FROM article_tag WHERE article_id = ?;';
        await connection.query(delete_tag_sql, [id]);

        // 一切顺利，提交事务
        await connection.commit();
        res.json({
            status: true,
            msg: "删除成功"
        });
    } catch (error) {
        await connection.rollback();
        res.json({
            status: false,
            msg: error.message,
            error,
        });
    }
});

/**
 * @api {post} /article/edit 编辑指定id文章
 * @apiName EditArticle
 * @apiPermission 后台系统
 * @apiGroup Article
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 文章id.
 * @apiBody { Number } cate_1st 一级分类id.
 * @apiBody { Number } cate_2nd 二级分类id.
 * @apiBody { String } title 文章标题.
 * @apiBody { String } description 文章摘要.
 * @apiBody { String } content 文章内容.
 * @apiBody { String } main_photo 文章主图.
 *
 * @apiSampleRequest /article/edit
 */
router.post('/edit', async (req, res) => {
    let { id, cate_1st, cate_2nd, title, description, content, main_photo } = req.body;
    const sql = 'UPDATE article SET cate_1st = ? , cate_2nd = ? , title = ? , description = ? , content = ? , main_photo = ? WHERE id = ?';
    let [{ affectedRows }] = await pool.query(sql, [cate_1st, cate_2nd, title, description, content, main_photo, id]);
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
    });
});

/**
 * @api {post} /article/tag 给指定id文章标记标签
 * @apiName TagArticle
 * @apiPermission 后台系统
 * @apiGroup Article
 *
 * @apiUse Authorization
 *
 * @apiBody { Number } id 文章id.
 * @apiBody { Number[] } tags 标签的id数组,如[1,2,3].
 *
 * @apiSampleRequest /article/tag
 */

router.post("/tag/", async (req, res) => {
    let { id, tags: insert_tags } = req.body;
    //获取现有tags标签id
    const select_sql = 'SELECT tag_id FROM `article_tag` WHERE article_id = ?';
    let [exist_tags] = await pool.query(select_sql, [id]);
    exist_tags = exist_tags.map((item) => item.tag_id);
    //计算两个数组的差集
    let rest_exist_tags = exist_tags.filter((item) => {
        return !insert_tags.includes(item);
    });
    let rest_insert_tags = insert_tags.filter((item) => {
        return !exist_tags.includes(item);
    });
    //转化数组格式
    rest_insert_tags = rest_insert_tags.map((item) => `(${id},${item})`);

    // 获取一个连接
    const connection = await pool.getConnection();

    try {
        // 开启事务
        await connection.beginTransaction();
        //根据rest_exist_tags删除数据，数组为空,不需要删除数据
        if (rest_exist_tags.length) {
            let delete_sql = `DELETE FROM article_tag WHERE article_id = ? AND tag_id IN (${rest_exist_tags.toString()});`
            let [{ affectedRows }] = await connection.query(delete_sql, [id]);
            if (affectedRows === 0) {
                await connection.rollback();
                res.json({ status: false, msg: "删除原有tag失败！" });
                return;
            }
        }
        //根据rest_exist_tags插入数据，数组为空,不需要插入数据
        if (rest_insert_tags.length) {
            let insert_sql = `INSERT INTO article_tag (article_id, tag_id) VALUES ${rest_insert_tags.toString()}`;
            let [{ affectedRows }] = await connection.query(insert_sql);
            if (affectedRows === 0) {
                await connection.rollback();
                res.json({ status: false, msg: "插入tag失败！" });
                return;
            }
        }
        // 一切顺利，提交事务
        await connection.commit();
        // 添加成功
        res.json({
            status: true,
            msg: "添加成功"
        });
    } catch (error) {
        await connection.rollback();
        res.json({
            status: false,
            msg: error.message,
            error,
        });
    }
});

module.exports = router;
