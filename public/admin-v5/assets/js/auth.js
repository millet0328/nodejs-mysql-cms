// 提取token
var token = sessionStorage.token;
// token不存在，未登录状态
if (!token) {
    layer.alert('Token无效，请重新登录！',
        { icon: 0, title: "错误：401", closeBtn: 0 },
        function (index) {
            // 强制跳转登录页面
            location.replace('./login.html');
        });
}
// token存在，设置全局 AJAX 默认headers中携带token
$.ajaxSetup({
    headers: {
        Authorization: `Bearer ${token}`
    },
    statusCode: {
        401: function () {
            layer.alert('Token已过期，请重新登录！',
                { icon: 0, title: "错误：401", closeBtn: 0 },
                function (index) {
                    // 强制跳转登录页面
                    location.replace('./login.html');
                });
        }
    }
});
