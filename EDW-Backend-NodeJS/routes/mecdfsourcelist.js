var express = require('express');
var router = express.Router();
var http = require('http');
var pg = require('pg');
var multiline = require('multiline');
var dateFormat = require('dateformat');


router.get('/', function (req, res) {
  try{
	var templateHandler = res.app.get('getDataTemplate2');   
	var selectString = multiline.stripIndent(function () { 
	       /*
           SELECT distinct src_sys_nm  FROM mcdfc order by src_sys_nm
		   */
	});	
    var sqlParams = [];	
    var rst ={};
    var resultHandler = function (result) {
	      var list=[];
		  list.push("ALL");
		  for(var i=0;i<result.rows.length;i++)
		  {
		   list.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));
		  }
		  rst["list"]=list;
    	  res.json(rst);
    }
    templateHandler(selectString, null, resultHandler, res);
		}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});


module.exports = router;
