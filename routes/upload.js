var express = require('express');
var router = express.Router();
// 文件模块
const fs = require('fs');
const path = require('path');
//文件传输
var multer = require('multer');
var upload = multer();
//图片处理
const sharp = require('sharp');
//uuid
var uuidv1 = require('uuid/v1');

/**
 * @api {post} /upload/editor/ 富文本编辑器图片上传API
 * @apiDescription 上传图片会自动检测图片质量，压缩图片，体积<2M，不限制尺寸，存储至details文件夹
 * @apiName uploadEditor
 * @apiGroup Upload Image
 * 
 * @apiParam {File} file File文件对象;
 * 
 * @apiSampleRequest /upload/editor/
 * 
 * @apiSuccess {String[]} data 返回图片地址.
 */
router.post("/editor", upload.single('file'), async function (req, res) {
	//文件类型
	let { mimetype, size } = req.file;
	//判断是否为图片
	var reg = /^image\/\w+$/;
	var flag = reg.test(mimetype);
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
	var { format } = await sharp(req.file.buffer).metadata();
	// 生成文件名
	var filename = uuidv1();
	//储存文件夹
	var fileFolder = `/images/details/`;
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

/**
 * @api {post} /upload/common/ 通用图片上传API
 * @apiDescription 上传图片会自动检测图片质量，压缩图片，体积<2M，不限制尺寸，avatar存储至avatar文件夹,common存储至common文件夹
 * @apiName uploadCommon
 * @apiGroup Upload Image
 * 
 * @apiParam {File} file File文件对象;
 * @apiParam {String="common","avatar"} type 上传类型：avatar--头像上传；common--通用上传；
 * 
 * @apiSampleRequest /upload/common/
 * 
 * @apiSuccess {String} data 返回图片地址.
 */
router.post("/common", upload.single('file'), async function (req, res) {
	//上传类型
	let { type } = req.body;
	//文件类型
	let { mimetype, size } = req.file;
	//判断是否为图片
	var reg = /^image\/\w+$/;
	var flag = reg.test(mimetype);
	if (!flag) {
		res.json({
			status: false,
			msg: "格式错误，请选择一张图片!"
		});
		return;
	}
	//判断图片体积是否小于2M
	if (size >= 2 * 1024 * 1024) {
		res.json({
			status: false,
			msg: "图片体积太大，请压缩图片!"
		});
		return;
	}
	//扩展名
	var { format } = await sharp(req.file.buffer).metadata();
	// 生成文件名
	var filename = uuidv1();
	//储存文件夹
	var fileFolder = `/images/${type}/`;
	//处理图片
	try {
		await sharp(req.file.buffer).toFile("public" + fileFolder + filename + '.' + format);
		//返回储存结果
		res.json({
			status: true,
			msg: "图片上传处理成功!",
			data: process.env.server + fileFolder + filename + '.' + format
		});
	} catch (error) {
		res.json({
			status: false,
			msg: error,
		});
	}
});

/**
 * @api {post} /upload/delete 删除图片API
 * @apiDescription 如果上传错误的图片，通过此API删除错误的图片
 * @apiName uploadDelete
 * @apiGroup Upload Image
 *
 * @apiParam {String} src 图片文件路径,注：src='./images/goods/file.jpg'，必须严格按照规范路径，'./images'不可省略;
 *
 * @apiSampleRequest /upload/delete
 */

router.post('/delete', function (req, res) {
	let realPath = path.resolve(__dirname, '../public/', req.body.src);
	fs.unlink(realPath, function (err) {
		if (err) throw err;
		res.json({
			status: true,
			msg: "success!"
		});
	})

});

module.exports = router;
