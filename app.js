const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
// 处理 async error
require('express-async-errors');
// JSON WEB TOKEN 管理器
const token_manager = require('./plugins/jwt');
// CORS
let cors = require('cors');

const index = require('./routes/index');
//后台
const admin = require('./routes/admin/admin');
const admin_user = require('./routes/admin/user');
const admin_tag = require('./routes/admin/tag');
const admin_article = require('./routes/admin/article');
const admin_category = require('./routes/admin/category');
const admin_upload = require('./routes/admin/upload');
const admin_notice = require('./routes/admin/notice');
const admin_comment = require('./routes/admin/comment');
const admin_slide = require('./routes/admin/slide');
const admin_link = require('./routes/admin/link');
const admin_token = require('./routes/admin/token');
//前台
const blog_account = require('./routes/blog/account');
const blog_article = require('./routes/blog/article');
const blog_category = require('./routes/blog/category');
const blog_notice = require('./routes/blog/notice');
const blog_upload = require('./routes/blog/upload');
const blog_comment = require('./routes/blog/comment');
const blog_slide = require('./routes/blog/slide');
const blog_link = require('./routes/blog/link');
const blog_token = require('./routes/blog/token');
// 系统
const system_icon = require('./routes/system/icon');
const system_menu = require('./routes/system/menu');
const system_operation = require('./routes/system/operation');
const system_role = require('./routes/system/role');
const system_route = require('./routes/system/route');

const app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'pug');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

// 设置跨域资源分享CORS
// app.use(cors({ credentials: true, origin: /^((https|http|ftp|rtsp|mms)?:\/\/)[^\s]+/ }));

// 校验白名单
let white_path = [
    '/',
    '/favicon.ico',
    /\/images\/*/,
    /^\/admin\/(login|register|check\/username)$/,
    /^\/account\/(login|register)$/,
    /^\/article\/(list|detail)$/,
    /^\/category\/(list|sub)$/,
    /^\/notice\/(list|detail)$/,
    /^\/token\/refresh\/(system|blog)$/,
    '/comment/list',
    '/slide/list',
    '/link/list',
];
// token守卫，每一个路由都验证token合法性，白名单地址无需校验。
app.use(token_manager.guard(white_path));

app.use('/', index);
//后台
app.use('/admin', admin);
app.use('/user', admin_user);
app.use('/tag', admin_tag);
app.use('/category', admin_category);
app.use('/article', admin_article);
app.use('/upload', admin_upload);
app.use('/notice', admin_notice);
app.use('/comment', admin_comment);
app.use('/slide', admin_slide);
app.use('/link', admin_link);
app.use('/token', admin_token);
//前台
app.use('/article', blog_article);
app.use('/category', blog_category);
app.use('/upload', blog_upload);
app.use('/notice', blog_notice);
app.use('/comment', blog_comment);
app.use('/account', blog_account);
app.use('/slide', blog_slide);
app.use('/link', blog_link);
app.use('/token', blog_token);
//系统
app.use('/icon', system_icon);
app.use('/menu', system_menu);
app.use('/operation', system_operation);
app.use('/role', system_role);
app.use('/route', system_route);

// catch 404 and forward to error handler
app.use(function (req, res, next) {
    next(createError(404));
});

// 处理401错误
app.use(function (err, req, res, next) {
    if (err.name === 'UnauthorizedError') {
        res.status(401).json({
            ...err,
            status: false,
        });
    } else {
        next(err);
    }
});

// error handler
app.use(function (err, req, res, next) {
    // set locals, only providing error in development
    res.locals.message = err.message;
    res.locals.error = req.app.get('env') === 'development' ? err : {};

    // render the error page
    res.status(err.status || 500);
    res.render('error');
});

module.exports = app;
