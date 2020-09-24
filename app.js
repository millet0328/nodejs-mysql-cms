var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
const expressJwt = require('express-jwt');
var cors = require('cors');

var indexRouter = require('./routes/index');

var userRouter = require('./routes/user');
var categoryRouter = require('./routes/category');
var articleRouter = require('./routes/article');
var tagRouter = require('./routes/tag');
var uploadRouter = require('./routes/upload');
var adminRouter = require('./routes/admin');
var roleRouter = require('./routes/role');
var menuRouter = require('./routes/menu');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'jade');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

//使用中间件验证token合法性
//除了这些地址，其他的URL都需要验证
app.use(expressJwt({ secret: 'secret' }).unless({
	path: ['/', '/admin/register', '/admin/login']
}));
// 设置跨域资源分享CORS
app.use(cors());

app.use('/', indexRouter);
app.use('/user', userRouter);
app.use('/category', categoryRouter);
app.use('/article', articleRouter);
app.use('/tag', tagRouter);
app.use('/upload', uploadRouter);
app.use('/admin', adminRouter);
app.use('/role', roleRouter);
app.use('/menu', menuRouter);

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
