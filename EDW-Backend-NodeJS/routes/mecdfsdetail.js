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
           SELECT *  FROM mcdfc where upd_ts>=$1 and upd_ts<=$2 
		   */
	});
	
    if(req.query["iscritical"]==1)
	{
	 selectString="SELECT *  FROM mcdfc where ";
	 selectString+=" critical_flag=1"  + " and ";
	 selectString+=" upd_ts>=  '" + dateFormat(req.query["date"],'yyyy-mm-dd 00:00:00') + "' and " + " upd_ts<= '" + dateFormat(req.query["date"],'yyyy-mm-dd 23:59:59')+"'";
	}
	else
	{
	  selectString="SELECT *  FROM mcdfc where ";
	  selectString+=" upd_ts>=  '" + dateFormat(req.query["date"],'yyyy-mm-dd 00:00:00') + "' and " + " upd_ts<= '" + dateFormat(req.query["date"],'yyyy-mm-dd 23:59:59')+"'";
	}

	console.log(selectString);
    var sqlParams = [];	
    var rst ={};
    var resultHandler = function (result) {
	      
	      var detailinfo=[];
		  var typeinfo="";
		  if(req.query["type"]=="A")
		  {
		    typeinfo="File arrived late and not loaded"; 
		  }
		  else if(req.query["type"]=="B")
		  {
		    typeinfo="File arrived on time but not loaded (backlog)";
		  }
		  else if(req.query["type"]=="C")
		  {
		    typeinfo="File did not arrive";
		  }
		  else if(req.query["type"]=="D")
		  {
		    typeinfo="File included in rollup";
		  }
		  
		  
	      for(var i=0;i<result.rows.length;i++)
		  {
		    if(req.query["env"]=="ALL")
			{
			  if(req.query["source"]=="ALL")
			  {
			    if(result.rows[i].load_status.replace(/(\s*$)/g, "")==typeinfo)
				{
			    var tempdetail={};
				tempdetail["SERVER"]=result.rows[i].server.replace(/(\s*$)/g, "");
				tempdetail["SOURCECODE"]=result.rows[i].src_code;
				tempdetail["SOURCENAME"]=result.rows[i].src_sys_nm.replace(/(\s*$)/g, "");
				tempdetail["EPRID"]=result.rows[i].epr_id.replace(/(\s*$)/g, "");
				tempdetail["PORTFOLIO"]=result.rows[i].portfolio.replace(/(\s*$)/g, "");
				tempdetail["DATASUBJECT"]=result.rows[i].data_subject.replace(/(\s*$)/g, "");
				tempdetail["FILETS"]=dateFormat(result.rows[i].file_ts,'yyyymmdd.hhmmss');  
				tempdetail["VALUE"]=result.rows[i].file_count;
				detailinfo.push(tempdetail);
				}
			  }
			  else if(req.query["source"]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
			  {
			    if(result.rows[i].load_status.replace(/(\s*$)/g, "")==typeinfo)
				{
				var tempdetail={};
				tempdetail["SERVER"]=result.rows[i].server.replace(/(\s*$)/g, "");
				tempdetail["SOURCECODE"]=result.rows[i].src_code;
				tempdetail["SOURCENAME"]=result.rows[i].src_sys_nm.replace(/(\s*$)/g, "");
				tempdetail["EPRID"]=result.rows[i].epr_id.replace(/(\s*$)/g, "");
				tempdetail["PORTFOLIO"]=result.rows[i].portfolio.replace(/(\s*$)/g, "");
				tempdetail["DATASUBJECT"]=result.rows[i].data_subject.replace(/(\s*$)/g, "");
				tempdetail["FILETS"]=dateFormat(result.rows[i].file_ts,'yyyymmdd.hhmmss');
				tempdetail["VALUE"]=result.rows[i].file_count;
				detailinfo.push(tempdetail);
				}
			  }
			}
			else if(req.query["env"]==result.rows[i].server.replace(/(\s*$)/g, ""))
			{
			  if(req.query["source"]=="ALL")
			  {
			    if(result.rows[i].load_status.replace(/(\s*$)/g, "")==typeinfo)
				{
			    var tempdetail={};
				tempdetail["SERVER"]=result.rows[i].server.replace(/(\s*$)/g, "");
				tempdetail["SOURCECODE"]=result.rows[i].src_code;
				tempdetail["SOURCENAME"]=result.rows[i].src_sys_nm.replace(/(\s*$)/g, "");
				tempdetail["EPRID"]=result.rows[i].epr_id.replace(/(\s*$)/g, "");
				tempdetail["PORTFOLIO"]=result.rows[i].portfolio.replace(/(\s*$)/g, "");
				tempdetail["DATASUBJECT"]=result.rows[i].data_subject.replace(/(\s*$)/g, "");
				tempdetail["FILETS"]=dateFormat(result.rows[i].file_ts,'yyyymmdd.hhmmss');
				tempdetail["VALUE"]=result.rows[i].file_count;
				detailinfo.push(tempdetail);
				}
			  }
			  else if(req.query["source"]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
			  {
			    if(result.rows[i].load_status.replace(/(\s*$)/g, "")==typeinfo)
				{
			    var tempdetail={};
				tempdetail["SERVER"]=result.rows[i].server.replace(/(\s*$)/g, "");
				tempdetail["SOURCECODE"]=result.rows[i].src_code;
				tempdetail["SOURCENAME"]=result.rows[i].src_sys_nm.replace(/(\s*$)/g, "");
				tempdetail["EPRID"]=result.rows[i].epr_id.replace(/(\s*$)/g, "");
				tempdetail["PORTFOLIO"]=result.rows[i].portfolio.replace(/(\s*$)/g, "");
				tempdetail["DATASUBJECT"]=result.rows[i].data_subject.replace(/(\s*$)/g, "");
				tempdetail["FILETS"]=dateFormat(result.rows[i].file_ts,'yyyymmdd.hhmmss');
				tempdetail["VALUE"]=result.rows[i].file_count;
				detailinfo.push(tempdetail);
				}
			  }		
			}
		  }
		 
    	  res.json(detailinfo);
    }
    templateHandler(selectString, null, resultHandler, res);
		}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});

module.exports = router;
