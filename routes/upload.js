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
 * @api {post} /upload/editor/ 富文本编辑器图片上传
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
 * @api {post} /upload/common/ 通用图片上传
 * @apiDescription 上传图片会自动检测图片质量，压缩图片，体积<2M，头像上传，图片必须是正方形，通用上传不限制尺寸，avatar存储至avatar文件夹,common存储至common文件夹
 * @apiName uploadCommon
 * @apiGroup Upload Image
 * 
 * @apiParam {File} file File文件对象;
 * @apiParam {String="common","avatar"} type 上传类型：avatar--头像上传；common--通用上传；
 * 
 * @apiSampleRequest /upload/common/
 * 
 * @apiSuccess {String} src 返回图片地址.
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
		res.status(400).json({
			status: false,
			msg: "格式错误，请选择一张图片!"
		});
		return;
	}
	//判断图片体积是否小于2M
	if (size >= 2 * 1024 * 1024) {
		res.status(400).json({
			status: false,
			msg: "图片体积太大，请压缩图片!"
		});
		return;
	}
	// 获取图片信息
	var { width, height, format } = await sharp(req.file.buffer).metadata();
	// 判读图片尺寸
	if (type == "avatar" && width != height) {
		res.status(400).json({
			status: false,
			msg: "图片必须为正方形，请重新上传!"
		});
		return;
	}
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
			src: process.env.server + fileFolder + filename + '.' + format
		});
	} catch (error) {
		res.json({
			status: false,
			msg: error,
		});
	}
});

/**
 * @api {post} /upload/remove 删除图片
 * @apiDescription 如果上传错误的图片，通过此API删除错误的图片
 * @apiName uploadDelete
 * @apiGroup Upload Image
 * @apiPermission user admin
 * 
 * @apiParam {String} src 图片文件路径,注意图片路径必须是绝对路径，例：http://localhost:3003/images/path/to/photo.jpg
 *
 * @apiSampleRequest /upload/remove
 */

router.post('/remove', function (req, res) {
	let { src } = req.body;
	src = src.replace(/.+\/images/, "./images");
	let realPath = path.resolve(__dirname, '../public/', src);
	fs.unlink(realPath, function (err) {
		if (err) throw err;
		res.json({
			status: true,
			msg: "success!"
		});
	})
});

module.exports = router;
