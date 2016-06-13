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
			select * from dailyrolluptimes where "RollupDate_l"=$1
		    */
	});
    var sqlParams = [req.query["date"]];	
    var rst ={};
    var resultHandler = function (result) {
    	//var rst = result.rows;
		   var zeo_meet="";
		    var jad_meet="";
		    var emr_meet="";
			var zeo_time="Not Started";
			var jad_time="Not Started";
			var emr_time="Not Started";
         for(var i=0;i<result.rows.length;i++)
         {  
			
		    if(result.rows[i].Server=="ZEO")
			{
			 
			  if(result.rows[i].End_TS_l!=null)
			  {
			    zeo_time="Completed "+"@"+dateFormat(result.rows[i].End_TS_l,'yyyy-mm-dd hh:mm:ss')+" local";
				console.log(dateFormat(result.rows[i].End_TS_l,'yyyy-mm-dd hh:mm:ss'));
				if((new Date(dateFormat(result.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))) >result.rows[i].End_TS_l)
				{
				  zeo_meet=true;
				}
				else
				{
				  zeo_meet=false;
				}
			  }
			  else
			  {
			    zeo_time="Still Running";
			    var myDate = new Date();
				if(myDate<(new Date(dateFormat(result.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))))
				{
					zeo_meet=true;
				}
				else
				{
					zeo_meet=false;
				}
			  }
			}
			if(result.rows[i].Server=="EMR")
			{
		
			  if(result.rows[i].End_TS_l!=null)
			  {
			    emr_time="Completed "+"@"+dateFormat(result.rows[i].End_TS_l,'yyyy-mm-dd hh:mm:ss')+" local";
				console.log(dateFormat(result.rows[i].End_TS_l,'yyyy-mm-dd hh:mm:ss'));
				if((new Date(dateFormat(result.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))) >result.rows[i].End_TS_l)
				{
				  emr_meet=true;
				}
				else
				{
				  emr_meet=false;
				}
			  }
			  else
			  {
			    emr_time="Still Running";
			    var myDate = new Date();
				if(myDate<(new Date(dateFormat(result.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))))
				{
					zeo_meet=true;
				}
				else
				{
					zeo_meet=false;
				}
			  }
			}
			if(result.rows[i].Server=="JAD")
			{			
			  if(result.rows[i].End_TS_l!="")
			  {
			    jad_time="Completed "+"@"+dateFormat(result.rows[i].End_TS_l,'yyyy-mm-dd hh:mm:ss')+" local";
				console.log(dateFormat(result.rows[i].End_TS_l,'yyyy-mm-dd hh:mm:ss'));
				if((new Date(dateFormat(result.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))) >result.rows[i].End_TS_l)
				{
				  jad_meet=true;
				}
				else
				{
				  jad_meet=false;
				}
			  }
			  else
			  {
			    jad_time="Still Running";
			    var myDate = new Date();
				if(myDate<(new Date(dateFormat(result.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))))
				{
					zeo_meet=true;
				}
				else
				{
					zeo_meet=false;
				}
			  }
			}
		 }
         		 
         rst["JADTIME"]=jad_time;		 
         rst["EMRTIME"]=emr_time;
         rst["ZEOTIME"]=zeo_time;		  
		 rst["JADMEET"]=jad_meet;
		 rst["EMRMEET"]=emr_meet;
		 rst["ZEOMEET"]=zeo_meet;
		 var selectStringb = multiline.stripIndent(function () { 
            /*
             select * from rollupmecsummaries where "rollupdate_l"=$1 and "environment"=$2 order by "category" ,"itemid"
            */
            });
		var sqlParamstwo = [req.query["date"],req.query["env"]];
            	
	    var resultHandlertwo = function (result1)
            {    
			   var zeocomment=[];
               var jadcomment=[];
               var emrcomment=[];
               var yottacomment=[];
               var othercomment=[];	
       		   for(var i=0;i<result1.rows.length;i++)
			   {
			     if(result1.rows[i].category=="ZEO")
				 {
				   var detailinfo={};
				   detailinfo["c"]=result1.rows[i].item;
				   zeocomment.push(detailinfo);
				 }
				 if(result1.rows[i].category=="EMR")
				 {
				   var detailinfo={};
				   detailinfo["c"]=result1.rows[i].item;
				   emrcomment.push(detailinfo);
				 }
				 if(result1.rows[i].category=="JAD")
				 {
				    var detailinfo={};
				    detailinfo["c"]=result1.rows[i].item;
				    jadcomment.push(detailinfo);
				 }
				 if(result1.rows[i].category=="YOTTA")
				 { 
				    var detailinfo={};
				    detailinfo["c"]=result1.rows[i].item;
				    yottacomment.push(detailinfo);
				 }
				 if(result1.rows[i].category=="OTHER")
				 {
				    var detailinfo={};
				    detailinfo["c"]=result1.rows[i].item;
				    othercomment.push(detailinfo);
				 }
			   }
			   if(zeocomment.length==0)
			   {
			     var detailinfo={};
				 detailinfo["c"]="N/A";
				 zeocomment.push(detailinfo);
			   }
			   if(jadcomment.length==0)
			   {
			     var detailinfo={};
				 detailinfo["c"]="N/A";
				 jadcomment.push(detailinfo);
			   }
			   if(emrcomment.length==0)
			   {
			     var detailinfo={};
				 detailinfo["c"]="N/A";
				 emrcomment.push(detailinfo);
			   }
			   if(yottacomment.length==0)
			   { 
			     var detailinfo={};
				 detailinfo["c"]="N/A";
				 yottacomment.push(detailinfo);
			   }
			   if(othercomment.length==0)
			   {
			      var detailinfo={};
				 detailinfo["c"]="N/A";
				 othercomment.push(detailinfo);
			   }
				rst["ZEOCOMMENT"]=zeocomment; 
				rst["JADCOMMENT"]=jadcomment; 
				rst["EMRCOMMENT"]=emrcomment; 
				rst["YOTTACOMMENT"]=yottacomment; 
				rst["OTHERCOMMENT"]=othercomment; 
			   res.json(rst);
			}		
				
		templateHandler(selectStringb, sqlParamstwo, resultHandlertwo, res);	
 		 
     	 
    }
    templateHandler(selectString, sqlParams, resultHandler, res);
		}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});

module.exports = router;
