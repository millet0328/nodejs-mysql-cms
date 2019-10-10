var mysql = require('mysql');
var pool = mysql.createPool({
	host: 'localhost',
	user: 'root',
	password: 'root',
	database: 'cms',
	// debug: true,
});
//常规SQL
let query = (sql, arr = []) => {
	return new Promise((resolve, reject) => {
		//建立链接
		pool.getConnection((err, connection) => {
			// 处理链接错误
			if (err) throw err;

			connection.query(sql, arr, (error, results, fields) => {
				//将链接返回到连接池中，准备由其他链接重复使用
				connection.release();
				// 处理链接错误
				if (error) throw error;
				//执行回调函数，将数据返回
				resolve(results);
			});
		});
	});
};

module.exports = {
	pool,
	query
}
