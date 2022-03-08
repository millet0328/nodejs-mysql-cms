var express = require('express');
var router = express.Router();
// 数据库
var db = require('../../config/mysql');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 登录或者注册之后返回的token，请设置在request header中.
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
    var sql = 'INSERT INTO article (cate_1st ,cate_2nd , title , description , content , create_date , main_photo ) VALUES (?, ? , ? , ?, ?, CURRENT_TIMESTAMP() , ?)';
    let { insertId, affectedRows } = await db.query(sql, [cate_1st, cate_2nd, title, description, content, main_photo]);
    if (!affectedRows) {
        res.json({
            status: false,
            msg: "添加失败！"
        });
        return;
    }
    res.json({
        status: true,
        msg: "添加成功"
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
    var sql = 'DELETE FROM article WHERE id = ?';
    let { affectedRows } = await db.query(sql, [id]);
    if (affectedRows) {
        res.json({
            status: true,
            msg: "删除成功"
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
    var sql = 'UPDATE article SET cate_1st = ? , cate_2nd = ? , title = ? , description = ? , content = ? , main_photo = ? WHERE id = ?';
    let { affectedRows } = await db.query(sql, [cate_1st, cate_2nd, title, description, content, main_photo, id]);
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



module.exports = router;
