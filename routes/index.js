const express = require('express');
const router = express.Router();

/* GET home page. */
router.get('/', function (req, res) {
    res.redirect('/api/');
});
// admin后台转向
router.get('/admin/', function (req, res) {
    res.redirect('/admin/login.html');
});

module.exports = router;
