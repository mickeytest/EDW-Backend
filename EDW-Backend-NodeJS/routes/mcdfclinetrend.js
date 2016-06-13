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
         select distinct rtrim(src_sys_nm) as sys_name from mcdfc where 
		 */
	});	
	var sqlParams = [dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00'),dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')];
	if((req.query["env"]=="ALL") && (req.query["type"]=="ABC"))
	{
	  selectString="select distinct rtrim(src_sys_nm) as sys_name from mcdfc where";
	  selectString+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "' and ";
	  if(req.query["iscritical"]==1)
	  {
	    selectString+=" critical_flag=1"  + " and ";
	  }
	  selectString+= "  load_status not like 'File included in rollup%'   order by sys_name";
	}
	else
	{
     if((req.query["env"]=="ALL") && (req.query["type"]!="ABC")) 
	 {
	   var loadstatus="";
	   for(var i=0;i<req.query["type"].length;i++)
	   {	     
		 if(req.query["type"][i]=="A")
		 {
		     loadstatus+=" load_status  like 'File arrived late and not loaded%'  or ";
		 }
		 else if(req.query["type"][i]=="B")
		 {
		     loadstatus+=" load_status  like 'File arrived on time but not loaded%'  or ";
		 }
		 else if(req.query["type"][i]=="C")
		 {
		     loadstatus+=" load_status  like 'File did not arrive%'     or ";
	     }     	 
	  }
	  loadstatus=loadstatus.substr(0,loadstatus.length-4);
	  selectString+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 
	  if(req.query["iscritical"]==1)
	  {
	    selectString+=" critical_flag=1"  + " and ";
	  }
      selectString += " server != 'BER'   " + " and ("
	  selectString += loadstatus +") order by sys_name";
      console.log(selectString);
	  }
	  else if((req.query["env"]!="ALL") && (req.query["type"]=="ABC"))
	  {
		 selectString+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 
	     if(req.query["iscritical"]==1)
	     {
	      selectString+=" critical_flag=1"  + " and ";
	     }
		 selectString+= "server = '" +req.query["env"]+ "' and ";
		 selectString+="load_status not like 'File included in rollup%' "+" order by sys_name";
		 console.log(selectString);
	  }
	  else if((req.query["env"]!="ALL") && (req.query["type"]!="ABC"))
	  {
	    var loadstatus="";
	   for(var i=0;i<req.query["type"].length;i++)
	   {	     
		 if(req.query["type"][i]=="A")
		 {
		     loadstatus+=" load_status like 'File arrived late and not loaded%'   or ";
		 }
		 else if(req.query["type"][i]=="B")
		 {
		     loadstatus+=" load_status  like 'File arrived on time but not loaded%'    or ";
		 }
		 else if(req.query["type"][i]=="C")
		 {
		     loadstatus+=" load_status  like 'File did not arrive%'     or ";
	     }		 
	     
	    }
	   loadstatus=loadstatus.substr(0,loadstatus.length-4);
	  selectString+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 	
	  if(req.query["iscritical"]==1)
	  {
	    selectString+=" critical_flag=1"  + " and ";
	  }
	  selectString += " server ='" + req.query["env"]  + "' and ("
	  selectString += loadstatus +") order by sys_name";
      //console.log(selectString); 
	  }
	}
    
	
	
    var rst ={};
    var resultHandler = function (result) {
	      var datetime=[];		  
		  var selectStringc = multiline.stripIndent(function () { 
	       /*
           select distinct to_char(upd_ts,'yyyy-mm-dd') as upd_ts  from mcdfc where
		   */
	      });	
	if((req.query["env"]=="ALL") && (req.query["type"]=="ABC"))
	{
	  selectStringc="select distinct to_char(upd_ts,'yyyy-mm-dd')  as upd_ts from mcdfc where";
	  if(req.query["iscritical"]==1)
	  {
	    selectStringc+=" critical_flag=1"  + " and ";
	  }
	  selectStringc+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "' and ";
	  selectStringc+= "  load_status not like 'File included in rollup%'   order by upd_ts";
	}
	else
	{
     if((req.query["env"]=="ALL") && (req.query["type"]!="ABC")) 
	 {
	   var loadstatus="";
	   for(var i=0;i<req.query["type"].length;i++)
	   {	     
		 if(req.query["type"][i]=="A")
		 {
		     loadstatus+=" load_status  like 'File arrived late and not loaded%'  or ";
		 }
		 else if(req.query["type"][i]=="B")
		 {
		     loadstatus+=" load_status  like 'File arrived on time but not loaded%'   or ";
		 }
		 else if(req.query["type"][i]=="C")
		 {
		     loadstatus+=" load_status  like 'File did not arrive%'     or ";
	     }     
		 
	  }
	  loadstatus=loadstatus.substr(0,loadstatus.length-4);
	  selectStringc+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 
	  if(req.query["iscritical"]==1)
	  {
	    selectStringc+=" critical_flag=1"  + " and ";
	  }
	  selectStringc += " server != 'BER'   " + " and ("
	  selectStringc += loadstatus +") order by upd_ts";
      console.log(selectStringc);
	  }
	  else if((req.query["env"]!="ALL") && (req.query["type"]=="ABC"))
	  {
		 selectStringc+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 
	     if(req.query["iscritical"]==1)
	     {
	       selectStringc+=" critical_flag=1"  + " and ";
	     }
		 selectStringc+= "server = '" +req.query["env"]+ "' and ";
		 selectStringc+="load_status not like 'File included in rollup%' "+" order by upd_ts";
		 console.log(selectStringc);
	  }
	  else if((req.query["env"]!="ALL") && (req.query["type"]!="ABC"))
	  {
	    var loadstatus="";
	   for(var i=0;i<req.query["type"].length;i++)
	   {	     
		 if(req.query["type"][i]=="A")
		 {
		     loadstatus+=" load_status like 'File arrived late and not loaded%' or  ";
		 }
		 else if(req.query["type"][i]=="B")
		 {
		     loadstatus+=" load_status  like 'File arrived on time but not loaded%'  or  ";
		 }
		 else if(req.query["type"][i]=="C")
		 {
		     loadstatus+=" load_status  like 'File did not arrive%'     or ";
	     }		 
	     
	    }
	   loadstatus=loadstatus.substr(0,loadstatus.length-4);
	  selectStringc+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 	
	  if(req.query["iscritical"]==1)
	  {
	    selectStringc+=" critical_flag=1"  + " and ";
	  }
	  selectStringc += " server ='" + req.query["env"]  + "' and ("
	  selectStringc += loadstatus +") order by upd_ts";
      console.log(selectStringc); 
	  }
	}
		  
	  
		  
         var sqlParamsc = [dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00'),dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')];			  
		  var resultHandlerc = function (result3) {
		      for(var i=0;i<result3.rows.length;i++)
			  {
			    datetime.push(dateFormat(result3.rows[i].upd_ts,'yyyy/mm/dd'));
			  }
		  
		  var sysname=[];
		  var dateinfo=[];
          for(var i=0;i<result.rows.length;i++)
		  {
		     sysname.push(result.rows[i].sys_name);
			 var detailinfo={};
			 detailinfo["name"]=result.rows[i].sys_name;
			 detailinfo["dataset"]=[];
			 dateinfo.push(detailinfo);
		  }		 
          var selectStringb = multiline.stripIndent(function () { 
	       /*
           select to_char(upd_ts,'yyyy-mm-dd') as upd_ts,src_sys_nm, sum(file_count) as count from mcdfc  where 
		   */
		  });
		  
		  
	if((req.query["env"]=="ALL") && (req.query["type"]=="ABC"))
	{  
	  selectStringb="select to_char(upd_ts,'yyyy-mm-dd') as upd_ts,src_sys_nm,sum(file_count) as count from mcdfc where";
	  if(req.query["iscritical"]==1)
	  {
	    selectStringb+=" critical_flag=1"  + " and ";
	  }
	  selectStringb+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='" + dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59')+ "' and ";
	  selectStringb+= "  load_status not like 'File included in rollup%' " + "  group by 1,2 order by upd_ts,src_sys_nm";
	  console.log(selectStringb);
	}
	else
	{
     if((req.query["env"]=="ALL") && (req.query["type"]!="ABC")) 
	 {
	   var loadstatus="";
	   for(var i=0;i<req.query["type"].length;i++)
	   {	     
		 if(req.query["type"][i]=="A")
		 {
		     loadstatus+=" load_status  like 'File arrived late and not loaded%' or ";
		 }
		 else if(req.query["type"][i]=="B")
		 {
		     loadstatus+=" load_status  like 'File arrived on time but not loaded%'  or ";
		 }
		 else if(req.query["type"][i]=="C")
		 {
		     loadstatus+=" load_status  like 'File did not arrive%'     or ";
	     }
	     
	  }
	  loadstatus=loadstatus.substr(0,loadstatus.length-4);
	  selectStringb+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 
	  if(req.query["iscritical"]==1)
	  {
	    selectStringb+=" critical_flag=1"  + " and ";
	  }
	  selectStringb += " server != 'BER'   " + " and ("
	  selectStringb += loadstatus  + ")  group by 1,2 order by upd_ts,src_sys_nm";;
      console.log(selectStringb);
	  }
	  else if((req.query["env"]!="ALL") && (req.query["type"]=="ABC"))
	  {
	     console.log("222");
		 selectStringb+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 
	     if(req.query["iscritical"]==1)
	     {
	       selectStringb+=" critical_flag=1"  + " and ";
	     }
		 selectStringb+= "server = '" +req.query["env"]+ "' and ";
		 selectStringb+= "load_status not like 'File included in rollup%' "+ "  group by 1,2 order by upd_ts,src_sys_nm";
		 console.log(selectStringb);
	  }
	  else if((req.query["env"]!="ALL") && (req.query["type"]!="ABC"))
	  {
	    var loadstatus="";
	   for(var i=0;i<req.query["type"].length;i++)
	   {	     
		 if(req.query["type"][i]=="A")
		 {
		     loadstatus+=" load_status like 'File arrived late and not loaded%' or ";
		 }
		 else if(req.query["type"][i]=="B")
		 {
		     loadstatus+=" load_status  like 'File arrived on time but not loaded%'  or ";
		 }
		 else if(req.query["type"][i]=="C")
		 {
		     loadstatus+=" load_status  like 'File did not arrive%'    or ";
	     }		 
	   
	    }
	 loadstatus=loadstatus.substr(0,loadstatus.length-4);
	  selectStringb+= "  upd_ts>='" + dateFormat(req.query["from"],'yyyy-mm-dd 00:00:00') +"' and  "+ "upd_ts<='"+dateFormat(req.query["to"],'yyyy-mm-dd 23:59:59') + "' and "; 	
	  if(req.query["iscritical"]==1)
	  {
	    selectStringb+=" critical_flag=1"  + " and ";
	  }
	  selectStringb += " server ='" + req.query["env"]  + "' and ("
	  selectStringb += loadstatus + ")  group by 1,2 order by upd_ts,src_sys_nm";
      console.log(selectStringb); 
	  }
	}
		 
      
		  console.log(datetime);
		  
		
		   var sqlParamsb = [];
		   var resultHandlerb = function (result1) {
		   //console.log("result1 come in");
			var j=0;
			var s=0;
			for(var i=0;i<result1.rows.length;i++)
            {	 
			  if(dateFormat(result1.rows[i].upd_ts,'yyyy/mm/dd')==datetime[j+1])
			  { 
				if(s< sysname.length){				
					for(var ii=s;ii<sysname.length ;ii++){
					    console.log(ii)
						dateinfo[ii]["dataset"].push(0);
					}			
				}		 
			 
			    s=0;
				if(result1.rows[i].src_sys_nm.replace(/(\s*$)/g, "")==sysname[s])
				{
				console.log("up found");
				console.log(sysname[s]);
				
				  dateinfo[s]["dataset"].push(parseInt(result1.rows[i].count));
				  console.log(dateinfo[s]["dataset"])
				  s+=1
				}
				else
				{	
				console.log("up not found");
				console.log(s);
				  dateinfo[s]["dataset"].push(0);
				  console.log(dateinfo[s]["dataset"])
				  s+=1;
				  i=i-1;
				}
								
				j+=1
			  }
			  else
			  {
			    if(result1.rows[i].src_sys_nm.replace(/(\s*$)/g, "")==sysname[s])
				{  
				//console.log("found");
				//console.log(sysname[s]);
				  dateinfo[s]["dataset"].push(parseInt(result1.rows[i].count));	
				   console.log(dateinfo[s]["dataset"])
                  s+=1;				  
				}
				else
				{ 
				 //console.log("not found");
				//console.log(sysname[s]);
				  dateinfo[s]["dataset"].push(0);
                  s+=1;	
                  i=i-1;				  
				}	
			  }
			}

			if(s< sysname.length){						
					for(var ii=s;ii<sysname.length ;ii++){
					   //console.log(ii)
						dateinfo[ii]["dataset"].push(0);
					}			
				}	
				
			 rst["datetime"]=datetime;
		     rst["data"]=dateinfo;
			 res.json(rst);	
  	     
		   }
		  	 
		  templateHandler(selectStringb, null, resultHandlerb, res);
		  }
		  templateHandler(selectStringc, null, resultHandlerc, res);     
    }
	
    templateHandler(selectString, null, resultHandler, res);
	}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});

module.exports = router;
