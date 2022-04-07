// 加载页头
$('header').load('./layout/header.html', function () {
    // 获取一级分类
    $.getJSON('/category/sub', { id: 0 }, function (res) {
        if (res.status) {
            var html = '';
            res.data.forEach(function (item) {
                html += `
					<li class="nav-item">
                    	<a class="nav-link" href="./article-list.html?id=${item.id}">${item.name}</a>
                	</li>`
            });
            $('.navbar-nav.left').html(html);
        }
    });
});
// 加载页尾
$('footer').load('./layout/footer.html');