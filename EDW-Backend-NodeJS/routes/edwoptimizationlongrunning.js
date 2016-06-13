var express = require('express');
var router = express.Router();
var http = require('http');
var pg = require('pg');
var multiline = require('multiline');
var dateFormat = require('dateformat');

var utils = require('../public/javascripts/utils.js');

router.get('/', function (req, res) {
   try{
    var templateHandler = res.app.get('getDataTemplate2');
    
    var selectString = multiline.stripIndent(function () { 
            /*
            select * from fact_edw_optimization_long_running_mec
            */
    });
    
    var sqlParams = [];
    
    var resultHandler = function (result) {
        var rst = {};
       

        var categories = []
        var longrunning = {}
        var longrunningTotal = {}
        var longrunningcategories = []


        for(var i = 0; i< result.rows.length ; i++){
            var newFormat = dateFormat(result.rows[i].MECMonth, 'mmm,yyyy');
            categories.push(newFormat)
            longrunningcategories.push(result.rows[i].Server)


            if(longrunning[result.rows[i].Server] == null){
                longrunning[result.rows[i].Server] = {}
            }
            longrunning[result.rows[i].Server][newFormat] = result.rows[i].Value

            if (longrunningTotal[newFormat] == null){
                longrunningTotal[newFormat] = 0
            }
            longrunningTotal[newFormat] += result.rows[i].Value
            
        }

        categories = categories.unique()
        longrunningcategories = longrunningcategories.unique()

        rst.categories = categories;
        rst.longrunning =[utils.getItemdate(categories,"Long Running Jobs",longrunningTotal)]
        
        rst.longrunningdrilldown = utils.getDrilldowndata(categories,longrunningcategories,longrunning)

        rst.longrunningcategories = longrunningcategories
        res.json(rst);
    };
    
    templateHandler(selectString, null, resultHandler, res);
		}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});

module.exports = router;