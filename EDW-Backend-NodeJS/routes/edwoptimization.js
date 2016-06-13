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
            select * from fact_edw_optimization
            */
    });
    
    var sqlParams = [];
    
    var resultHandler = function (result) {
        var rst = {};
       

        var categories = []
        var classDrilldowncategories = []
        var CompletedByStatus = {}
        var InProgressByStatus = {}
        var OthersByStatus = {}
        var BugFixByType = {}
        var OptimizeByType = {}
        var TSAByType = {}
        var OthersByType = {}
        var classification = {}
        var classificationTotal = {}
        var permanent = {}
        var optimization = {}

        for(var i = 0; i< result.rows.length ; i++){
            var newFormat = dateFormat(result.rows[i].MECMonth, 'mmm,yyyy');
            categories.push(newFormat)

            if(result.rows[i].Category == 0){
                if(result.rows[i].Type == "Completed"){
                    CompletedByStatus[newFormat] = result.rows[i].Value
                }
                else if(result.rows[i].Type == "In Progress"){
                    InProgressByStatus[newFormat] = result.rows[i].Value
                }
                else if(result.rows[i].Type == "Others"){
                    OthersByStatus[newFormat] = result.rows[i].Value
                }
            }else if(result.rows[i].Category == 1){
                if(result.rows[i].Type == "Bug Fixing"){
                     BugFixByType[newFormat] = result.rows[i].Value
                }
                else if(result.rows[i].Type == "Optimization"){
                    OptimizeByType[newFormat] = result.rows[i].Value
                }
                else if(result.rows[i].Type == "TSA"){
                    TSAByType[newFormat] = result.rows[i].Value
                }
                else if(result.rows[i].Type == "Others"){
                    OthersByType[newFormat] = result.rows[i].Value
                }
            }else if(result.rows[i].Category == 2){
                classDrilldowncategories.push(result.rows[i].Type)

                if(classification[result.rows[i].Type] == null){
                    classification[result.rows[i].Type] = {}
                }
                classification[result.rows[i].Type][newFormat] = result.rows[i].Value

                if (classificationTotal[newFormat] == null){
                    classificationTotal[newFormat] = 0
                }
                classificationTotal[newFormat] += result.rows[i].Value
            }else if(result.rows[i].Category == 3){
                permanent[newFormat] = result.rows[i].Value
            }else if(result.rows[i].Category == 4){
                optimization[newFormat] = result.rows[i].Value
            }

        }
        categories = categories.unique()
        classDrilldowncategories = classDrilldowncategories.unique()

        rst.categories = categories;
        rst.StatusTrend = [
            utils.getItemdate(categories,"Completed",CompletedByStatus),
            utils.getItemdate(categories,"In Progress",InProgressByStatus),
            utils.getItemdate(categories,"Others",OthersByStatus)
            ];
        rst.ChangeTypeTrend = [
            utils.getItemdate(categories,"Bug Fixing",BugFixByType),
            utils.getItemdate(categories,"Optimization",OptimizeByType),
            utils.getItemdate(categories,"TSA",TSAByType),
            utils.getItemdate(categories,"Others",OthersByType)
            ];

        rst.classdilldowncategories = classDrilldowncategories
        rst.classtrend =  [utils.getItemdate(categories,"classify",classificationTotal)]
        rst.classdilldowndate = utils.getDrilldowndata(categories,classDrilldowncategories,classification)
        rst.PermanentTrend =  [utils.getItemdate(categories,"Pemanent Total",permanent)],
        rst.OptimizationTrend =  [utils.getItemdate(categories,"OptimizationTrend Total",optimization)],

        res.json(rst);
    };
    
    templateHandler(selectString, null, resultHandler, res);
		}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});

module.exports = router;