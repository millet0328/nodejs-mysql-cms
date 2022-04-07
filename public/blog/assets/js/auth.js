// 判断登录状态，导航守卫
var uid = sessionStorage.uid;

if (!uid) {
    // 获取当前的URL地址
    var current = location.href;
    // 重定向
    location.replace(`./login.html?redirect=${current}`);
}