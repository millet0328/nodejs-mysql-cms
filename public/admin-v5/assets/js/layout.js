$(document).ready(function () {
    // 加载header
    $('header').load('./layout/header.html');
    // 加载侧边栏
    $('#left-menu').load('./layout/left-menu.html', function () {
        // 加载成功之后执行，根据缓存展开某一层菜单
        var activeIndex = localStorage.activeIndex;
        $('.accordion .card .collapse').removeClass('show');
        $('.accordion .card').eq(activeIndex).find('.collapse').addClass('show');
    });
    // 每次点击侧边栏，缓存其点击的哪一层菜单
    $('#left-menu').on('click', '.accordion .card', function () {
        var activeIndex = $(this).index();
        localStorage.activeIndex = activeIndex;
    });
    // 退出登录
    $('header').on('click', '#logout', function () {
        // 清空sessionStorage
        sessionStorage.clear();
        // 重定向
        location.replace('./login.html');
    });
});