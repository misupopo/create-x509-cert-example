var express = require('express');
var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  // res.render('index', { title: 'Express' });
  res.json({ status: 'ok', clientCertSha1: req.get('X-Client-Cert-Sha1') });
});

module.exports = router;
