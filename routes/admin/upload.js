const express = require('express');
const router = express.Router();
// 文件模块
const fs = require('fs');
const path = require('path');
//文件传输
const multer = require('multer');
const upload = multer();
//图片处理
const sharp = require('sharp');
//uuid
const uuidv1 = require('uuid/v1');

/**
 * @apiDefine Authorization
 * @apiHeader {String} Authorization 登录或者注册之后返回的token，请在头部headers中设置Authorization: `Bearer ${token}`.
 */

/**
 * @api {post} /upload/editor/ 富文本编辑器图片上传
 * @apiDescription 上传图片会自动检测图片质量，压缩图片，体积<2M，不限制尺寸，存储至details文件夹
 * @apiName UploadEditor
 * @apiPermission 后台系统
 * @apiGroup Upload
 * 
 * @apiUse Authorization
 * 
 * @apiBody {File} file File文件对象;
 * 
 * @apiSampleRequest /upload/editor/
 * 
 * @apiSuccess {String[]} data 返回图片地址.
 */
router.post("/editor", upload.single('file'), async function (req, res) {
	//文件类型
	let { mimetype, size } = req.file;
	//判断是否为图片
	let reg = /^image\/\w+$/;
	let flag = reg.test(mimetype);
	if (!flag) {
		res.json({
			errno: 1,
			msg: "格式错误，请选择一张图片!"
		});
		return;
	}
	//判断图片体积是否小于2M
	if (size >= 2 * 1024 * 1024) {
		res.json({
			errno: 1,
			msg: "图片体积太大，请压缩图片!"
		});
		return;
	}
	//扩展名
	let { format } = await sharp(req.file.buffer).metadata();
	// 生成文件名
	let filename = uuidv1();
	//储存文件夹
	let fileFolder = `/images/details/`;
	//处理图片
	try {
		await sharp(req.file.buffer).toFile("public" + fileFolder + filename + '.' + format);
		//返回储存结果
		res.json({
			errno: 0,
			msg: "图片上传处理成功!",
			data: [process.env.server + fileFolder + filename + '.' + format],
		});
	} catch (error) {
		res.json({
			errno: 1,
			msg: error,
		});
	}
});

module.exports = router;
