// 加载header，侧边栏
$(document).ready(function() {
	$('header').load('./header.html');
	$('.left-side').load('./aside.html', function() {
		// 获取侧边栏开启状态
		var index = localStorage.openIndex;
		$('#accordion .panel-collapse').removeClass('in');
		$('#accordion .panel').eq(index).find('.panel-collapse').addClass('in');
	});
	// 点击侧边栏存储开启状态
	$('body').on('click', '.panel', function() {
		var i = $(this).index();
		localStorage.openIndex = i;
	})

});
