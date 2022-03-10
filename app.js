const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const logger = require('morgan');
// JSON WEB TOKEN
const expressJwt = require('express-jwt');
// CORS
let cors = require('cors');
// SESSION
const session = require('express-session');

var index = require('./routes/index');
//后台
var admin = require('./routes/admin/admin');
var adminUser = require('./routes/admin/user');
var adminRole = require('./routes/admin/role');
var adminMenu = require('./routes/admin/menu');
var adminTag = require('./routes/admin/tag');
var adminArticle = require('./routes/admin/article');
var adminCategory = require('./routes/admin/category');
var adminUpload = require('./routes/admin/upload');
var adminNotice = require('./routes/admin/notice');
var adminComment = require('./routes/admin/comment');
var adminSlide = require('./routes/admin/slide');
//前台
var blogAccount = require('./routes/blog/account');
var blogArticle = require('./routes/blog/article');
var blogCategory = require('./routes/blog/category');
var blogNotice = require('./routes/blog/notice');
var blogUpload = require('./routes/blog/upload');
var blogComment = require('./routes/blog/comment');
var blogSlide = require('./routes/blog/slide');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

// session支持
/*
* name: 设置cookie中，保存session的字段名称，默认为connect.sid
* store: session的存储方式，默认为存放在内存中，我们可以自定义redis等
* genid: 生成一个新的session_id时，默认为使用uid2这个npm包
* rolling: 每个请求都重新设置一个cookie，默认为false
* resave: 即使session没有被修改，也保存session值，默认为true
* saveUninitialized：强制未初始化的session保存到数据库
* secret: 通过设置的secret字符串，来计算hash值并放在cookie中，使产生的signedCookie防篡改
* cookie : 设置存放sessionid的cookie的相关选项 { secure: true } https协议下才可以访问cookie
* */
app.use(session({ name: 'session_id', secret: 'keyboard cat', resave: false, saveUninitialized: false }));
// 设置跨域资源分享CORS
// app.use(cors({ credentials: true, origin: /^((https|http|ftp|rtsp|mms)?:\/\/)[^\s]+/ }));

//使用中间件验证token合法性
//除了这些地址，其他的URL都需要验证
// app.use(expressJwt({ secret: 'secret' }).unless({
//     path: ['/', '/admin/register', '/admin/login', '/article/list', '/article/detail', '/article/category', '/category/list', '/category/sub', '/upload/common/', '/upload/remove']
// }));

app.use('/', index);
//后台
app.use('/admin', admin);
app.use('/user', adminUser);
app.use('/tag', adminTag);
app.use('/role', adminRole);
app.use('/menu', adminMenu);
app.use('/category', adminCategory);
app.use('/article', adminArticle);
app.use('/upload', adminUpload);
app.use('/notice', adminNotice);
app.use('/comment', adminComment);
app.use('/slide', adminSlide);
//前台
app.use('/article', blogArticle);
app.use('/category', blogCategory);
app.use('/upload', blogUpload);
app.use('/notice', blogNotice);
app.use('/comment', blogComment);
app.use('/account', blogAccount);
app.use('/slide', blogSlide);
// 处理401错误
app.use(function (err, req, res, next) {
    if (err.name === 'UnauthorizedError') {
        res.status(401).json({
            status: false,
            ...err,
        });
    }
});

// catch 404 and forward to error handler
app.use(function (req, res, next) {
    next(createError(404));
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
