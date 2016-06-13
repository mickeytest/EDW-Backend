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
         SELECT distinct upd_ts  FROM mcdfc where
		 */
	});	
	

	if((req.query["env"]!="ALL")&&(req.query["source"]=="ALL"))
	{
	      selectString="SELECT distinct to_char(upd_ts,'yyyy-mm-dd')  as upd_ts FROM mcdfc where"
	      if(req.query["iscritical"]==1)
	      {
	       selectString+=" critical_flag=1"  + " and ";
	      }
		  selectString+=  "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+"'";		  
	      selectString+= " and "+ "  server ='" + req.query["env"]+"'"+" order by upd_ts";   
		  console.log(selectString);
	}
	else if((req.query["env"]=="ALL")&&(req.query["source"]=="ALL"))
	{
	     selectString="SELECT  distinct  to_char(upd_ts,'yyyy-mm-dd')  as upd_ts FROM mcdfc where"
	     if(req.query["iscritical"]==1)
	     {
	       selectString+=" critical_flag=1"  + "  and  ";
	     }
		 selectString+=  "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "'" +" order by upd_ts";
	     console.log(selectString);
	}
	else if((req.query["env"]=="ALL")&&(req.query["source"]!="ALL"))
	{
	     selectString="SELECT distinct to_char(upd_ts,'yyyy-mm-dd')  as upd_ts FROM mcdfc where"
	     if(req.query["iscritical"]==1)
	     {
	       selectString+=" critical_flag=1"  + " and ";
	     }
		 selectString+=  "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "'";
	     selectString+= " and "+ "  src_sys_nm ='" + req.query["source"]+"'" +" order by upd_ts";    
	}
    else if((req.query["env"]!="ALL")||(req.query["source"]!="ALL"))
	{
	     selectString="SELECT distinct to_char(upd_ts,'yyyy-mm-dd')  as upd_ts FROM mcdfc where"
	     if(req.query["iscritical"]==1)
	     {
	       selectString+=" critical_flag=1"  + " and ";
	     }
		 selectString+=  "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "'";
	     selectString+= " and "+ "  src_sys_nm ='" + req.query["source"]+"'" + " and "+ "  server ='" + req.query["env"]+"'" + " order by upd_ts";    	
	}
	   var rst =[];
	   var resultHandler = function (result) {
	      var datetime=[];		  
	      var adate=[];
	      var bdate=[];
	      var cdate=[];
	      var ddate=[];
          for(var i=0;i<result.rows.length;i++)
		  {
		     var tempa={};
			 tempa["x"]=dateFormat(result.rows[i].upd_ts,'yyyy/mm/dd');
			 tempa["y"]=0;
			 var tempb={};
			 tempb["x"]=dateFormat(result.rows[i].upd_ts,'yyyy/mm/dd');
			 tempb["y"]=0;
			 var tempc={};
			 tempc["x"]=dateFormat(result.rows[i].upd_ts,'yyyy/mm/dd');
			 tempc["y"]=0;
			 var tempd={};
			 tempd["x"]=dateFormat(result.rows[i].upd_ts,'yyyy/mm/dd');
			 tempd["y"]=0;
		     adate.push(tempa);
		     bdate.push(tempb);
		     cdate.push(tempc);
		     ddate.push(tempd);
			 datetime.push(dateFormat(result.rows[i].upd_ts,'yyyy/mm/dd'));
		  }
		   var selectStringb = multiline.stripIndent(function () { 
		      /*
               SELECT upd_ts,rtrim(load_status) as loadstatus  FROM  mcdfc where
		      */
		   })
		    if((req.query["env"]!="ALL")&&(req.query["source"]=="ALL"))
	        {
	         selectStringb="SELECT upd_ts,rtrim(load_status) as loadstatus,sum(file_count) as count  FROM  mcdfc where "
	         if(req.query["iscritical"]==1)
	         {
	           selectStringb+=" critical_flag=1"  + " and ";
	         }
			 selectStringb+=  "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "' and ";
	         selectStringb+= "server ='" + req.query["env"]+ "'  group by 1,2 order by  1,2";   
	         console.log(selectStringb);	
			}
	        else if((req.query["env"]=="ALL")&&(req.query["source"]=="ALL"))
	        {
	        selectStringb="SELECT upd_ts,rtrim(load_status) as loadstatus,sum(file_count) as count  FROM  mcdfc where "
	        if(req.query["iscritical"]==1)
	         {
	           selectStringb+=" critical_flag=1"  + " and ";
	         }
		    selectStringb+=  "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59');
	        selectStringb+= "' group by 1,2 order by  1,2";
            console.log(selectStringb);			
	        }
	        else if((req.query["env"]=="ALL")&&(req.query["source"]!="ALL"))
	        {
	        selectStringb="SELECT upd_ts,rtrim(load_status) as loadstatus,sum(file_count) as count  FROM  mcdfc where "
	        if(req.query["iscritical"]==1)
	         {
	           selectStringb+=" critical_flag=1"  + " and ";
	         }
			selectStringb+=  "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "' and ";
	        selectStringb+= "src_sys_nm  ='" + req.query["source"]+ "'   group by 1,2 order by  1,2";   
	        console.log(selectStringb);	
		   }
	       else if((req.query["env"]!="ALL")&&(req.query["source"]!="ALL"))
	       {
	       selectStringb="SELECT upd_ts,rtrim(load_status) as loadstatus,sum(file_count) as count  FROM  mcdfc where "
	       if(req.query["iscritical"]==1)
	         {
	           selectStringb+=" critical_flag=1"  + " and ";
	         }
		   selectStringb+=  "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "' and ";
	       selectStringb+= "src_sys_nm  ='" + req.query["source"]+ "' and " +   "server ='" + req.query["env"]+ "'   group by 1,2 order by  1,2";   
	       console.log(selectStringb);	
		   }
		   var j=0;
		   var s=0;
	       var resultHandlerb = function (result1) {
		     console.log(datetime);
		     for(var i=0;i<result1.rows.length;i++)
			 {			   
			   if(dateFormat(result1.rows[i].upd_ts,'yyyy/mm/dd')==datetime[j+1])
			   { 
			    console.log("first");
			    s+=1
				if(result1.rows[i].loadstatus.replace(/(\s*$)/g, "")=="File arrived late and not loaded")
				{  
				  adate[s]["y"]=parseInt(result1.rows[i].count);			  
				}
				else if(result1.rows[i].loadstatus.replace(/(\s*$)/g, "")=="File arrived on time but not loaded (backlog)")
				{ 
				  bdate[s]["y"]=parseInt(result1.rows[i].count);
				}
				else if(result1.rows[i].loadstatus.replace(/(\s*$)/g, "")=="File did not arrive")
				{
				  cdate[s]["y"]=parseInt(result1.rows[i].count);
				}
				else if(result1.rows[i].loadstatus.replace(/(\s*$)/g, "")=="File included in rollup")
				{
				  ddate[s]["y"]=parseInt(result1.rows[i].count);
				}			
				j+=1
			  }
			  else
			  {  

			    if(result1.rows[i].loadstatus.replace(/(\s*$)/g, "")=="File arrived late and not loaded")
				{  			
				  adate[s]["y"]=parseInt(result1.rows[i].count);	  
				}
				else if(result1.rows[i].loadstatus.replace(/(\s*$)/g, "")=="File arrived on time but not loaded (backlog)")
				{ 
				  bdate[s]["y"]=parseInt(result1.rows[i].count);
				}
				else if(result1.rows[i].loadstatus.replace(/(\s*$)/g, "")=="File did not arrive")
				{
				  cdate[s]["y"]=parseInt(result1.rows[i].count);
				}
				else if(result1.rows[i].loadstatus.replace(/(\s*$)/g, "")=="File included in rollup")
				{			
				  ddate[s]["y"]=parseInt(result1.rows[i].count);
				}
			  }				
			 }
			 var ahash={};
		     var bhash={};
		     var chash={};
		     var dhash={};
			 ahash["name"]="File arrived late and not loaded";
		     ahash["dataset"]=adate;
			 bhash["name"]="File arrived on time but not loaded";
			 bhash["dataset"]=bdate;
			 chash["name"]="File did not arrive";
			 chash["dataset"]=cdate;
			 dhash["name"]="File included in rollup";
			 dhash["dataset"]=ddate;
			 rst.push(ahash);
			 rst.push(bhash);
			 rst.push(chash);
			 rst.push(dhash);
	 
		     res.json(rst);
		   }
		
	    templateHandler(selectStringb, null, resultHandlerb, res);
	 
	 }
    templateHandler(selectString, null, resultHandler, res);
		}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});

module.exports = router;
