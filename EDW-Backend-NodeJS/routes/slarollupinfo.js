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
    
    var selectStringa = multiline.stripIndent(function () { 
            /*
            select * from dailyrolluptimes where "Server" = $1  and "RollupDate_l">'2015-06-06 00:00:00' order by "RollupDate_l" asc
            */
    });    
	if(req.query["Environment"]=='ALL')
	 {
	  selectStringa="select * from dailyrolluptimes where \"Server\" !='BER' and  \"RollupDate_l\">'2015-06-06 00:00:00'  order by  \"RollupDate_l\""
	 }
	else
	 {
	  var sqlParams = [req.query["Environment"]];
	 }
	 
    var rst= {}; 
	var result1;
    var resultHandler = function (result) {
	       var rst = {};
		   //res.json(result.rows);
       // rst= result.rows	
       	    console.log(selectStringa)
        	var selectStringb = multiline.stripIndent(function () { 
            /*
            select "Month","Year",min("MECStartDate_l"),max("MECEndDate_l")  from mec_calendars group by "Month","Year" order by "Year" asc,"Month" asc
            */
            });
           console.log(selectStringb)			
	       var resultHandlerb = function (resulta){
		   j=0
		   var categories = []
		   var MEC = [0]
		   var NonMEC = [0]
		   var T15Min = [0]
		   categories.push(dateFormat(resulta.rows[1].min, 'mmm,yyyy'))
           for(var i = 0; i<result.rows.length; i++) //
           {  	   
		      var delaytime=(result.rows[i].Start_TS_l-(new Date(dateFormat(result.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))))/1000 			  			  
		      if((result.rows[i].RollupDate_l > resulta.rows[j].max) 
			     &&(result.rows[i].RollupDate_l <= resulta.rows[j+1].max)) 
			  {  
			     if(((new Date(dateFormat(result.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))) >result.rows[i].End_TS_l)&&
					((new Date(dateFormat(result.rows[i].RollupDate_l,'yyyy-mm-dd 12:45:00'))) <result.rows[i].End_TS_l)
					)
				 {
				    T15Min[j]=+1
				 }						
			     if((result.rows[i].RollupDate_l > resulta.rows[j+1].min) 
			     && (result.rows[i].RollupDate_l <= resulta.rows[j+1].max)&&(result.rows[i].RollupDate_l.getDay()!=6)&&(result.rows[i].RollupDate_l.getDay()!=0) ) 
				 {    
				    console.log(delaytime)
                  	if(delaytime>=180)
					{
					  MEC[j]+=1
					}					
				 }
				 else
				 {
				    if(delaytime>=180)
					{
				      console.log(delaytime)
					  NonMEC[j]+=1
					}	
				 }
			  }
			  else
			  {
			    console.log("not into")
				j+=1				
				MEC[j]=0
				NonMEC[j]=0
				T15Min[j]=0
				categories.push(dateFormat(resulta.rows[j+1].min, 'mmm,yyyy'))
			  }
		   }
		     rst.lastmonthfinished=false
			rst.categories = categories;
			rst.MEC = MEC;
			rst.NonMEC = NonMEC;
			rst.T15Min = T15Min;
		    res.json(rst);		
	       }	 		
           templateHandler(selectStringb, null, resultHandlerb, res);	
    };	
    templateHandler(selectStringa, sqlParams, resultHandler, res);
		}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});

module.exports = router;