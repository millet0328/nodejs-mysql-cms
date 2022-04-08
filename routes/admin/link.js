const express = require('express');
const router = express.Router();
// 数据库
let pool = require('../../config/mysql');

//TODO 友情链接增删改查