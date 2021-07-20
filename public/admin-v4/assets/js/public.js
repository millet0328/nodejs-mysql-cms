//获取地址栏的url参数
function GetRequest() {
	var url = location.search; //获取url中"?"符后的字串
	var theRequest = new Object();
	if (url.indexOf("?") != -1) {
		var str = url.substr(1);
		strs = str.split("&");
		for (var i = 0; i < strs.length; i++) {
			theRequest[strs[i].split("=")[0]] = (strs[i].split("=")[1]);
		}
	}
	return theRequest;
}


var token = sessionStorage.token;
// 不存在token，强制跳转登录
if (!token) {
	location.replace('./login.html');
}
// 全局设置ajax
$.ajaxSetup({
	headers: {
		Authorization: `Bearer ${token}`
	},
	error: function(XMLHttpRequest, textStatus, errorThrown) {
		var status = XMLHttpRequest.status;
		switch (status) {
			case 401:
				layer.msg('token失效，请重新登录！');
				location.replace('./login.html');
				break;
			default:
				break;
		}
	}
});
