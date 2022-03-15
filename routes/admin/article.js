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
    let { id, tags } = req.body;
    // 转化为数组
    try {
        var insert_tags = JSON.parse(tags);
    } catch (e) {
        res.json({
            status: false,
            msg: "tags参数错误！"
        });
        return;
    }
    //获取现有tags标签id
    const select_sql = 'SELECT tag_id FROM `article_tag` WHERE article_id = ?';
    let exist_tags = await db.query(select_sql, [id]);
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
    //根据rest_exist_tags删除数据，数组为空,不需要删除数据
    if (rest_exist_tags.length) {
        let remove_sql = `DELETE FROM article_tag WHERE article_id = ? AND tag_id IN (${rest_exist_tags.toString()});`
        let { affectedRows } = await db.query(remove_sql, [id]);
        if (affectedRows === 0) {
            res.json({
                status: false,
                msg: "删除原有tag失败！"
            });
            return;
        }
    }
    //根据rest_exist_tags插入数据，数组为空,不需要插入数据
    if (rest_insert_tags.length) {
        let insert_sql = `INSERT INTO article_tag (article_id, tag_id) VALUES ${rest_insert_tags.toString()}`;
        let { affectedRows } = await db.query(insert_sql);
        if (affectedRows === 0) {
            res.json({
                status: false,
                msg: "插入tag失败！"
            });
            return;
        }
    }

    res.json({
        status: true,
        msg: "添加成功"
    });
});

module.exports = router;
