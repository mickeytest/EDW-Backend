var express = require('express');
var router = express.Router();
var http = require('http');
var pg = require('pg');
var multiline = require('multiline');
var dateFormat = require('dateformat');

/* GET users listing. */
router.post('/user', function (req, res) {
   
	var templateHandler = res.app.get('getDataTemplate2');
    var selectString = multiline.stripIndent(function () { 
              /*
            INSERT INTO dailycriticalpaths(
            "DCPID", "RollupDate", "Server", "CriticalPath")
   			 VALUES ( 1, '2016-04-01', 'EMR', 'b');
 				*/
    });
    
   var resultHandler = function (result) {

   }
    templateHandler(selectString, null, resultHandler, res);
   

	console.log(req.body);
    res.send(req.body);
});

module.exports = router;