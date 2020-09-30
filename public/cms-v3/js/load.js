// 加载header，侧边栏
$(document).ready(function () {
	$('header').load('./header.html');
	$('.left-side').load('./aside.html', function () {
		// 获取侧边栏开启状态
		var index = localStorage.openIndex;
		$('#accordion .panel-collapse').removeClass('in');
		$('#accordion .panel').eq(index).find('.panel-collapse').addClass('in');
	});
	// 点击侧边栏存储开启状态
	$('body').on('click', '.left-side .panel', function () {
		var i = $(this).index();
		localStorage.openIndex = i;
	})

});

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
