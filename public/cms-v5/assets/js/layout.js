$(document).ready(function () {
    // 加载header
    $('header').load('./layout/header.html')
    // 加载侧边栏
    $('#left-menu').load('./layout/left-menu.html', function () {
        // 获取侧边栏开启状态
        var index = localStorage.openIndex;
        $('#accordion .card .collapse').removeClass('show');
        $('#accordion .card').eq(index).find('.collapse').addClass('show');
    });
    // 点击侧边栏存储开启状态
    $('#left-menu').on('click', '.accordion .card', function () {
        var i = $(this).index();
        localStorage.openIndex = i;
    })
});