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
           SELECT load_status,src_sys_nm,server,sum(file_count) as count  FROM mcdfc where upd_ts>=$1 and upd_ts<=$2  group by load_status,src_sys_nm,server order by  load_status,src_sys_nm,server
		   */
	});
	if(req.query["iscritical"]==1)
	{
	 selectString="SELECT load_status,src_sys_nm,server,sum(file_count) as count  FROM mcdfc where ";
	 selectString+=" critical_flag=1"  + " and ";
	 selectString+=" upd_ts>=  '" + dateFormat(req.query["date"],'yyyy-mm-dd 00:00:00') + "' and " + " upd_ts<= '" + dateFormat(req.query["date"],'yyyy-mm-dd 23:59:59');
	 selectString+="' group by load_status,src_sys_nm,server order by  load_status,src_sys_nm,server";	
	}
	else
	{
	  selectString="SELECT load_status,src_sys_nm,server,sum(file_count) as count  FROM mcdfc where "
	  selectString+=" upd_ts>=  '" + dateFormat(req.query["date"],'yyyy-mm-dd 00:00:00') + "' and " + " upd_ts<= '" + dateFormat(req.query["date"],'yyyy-mm-dd 23:59:59')
	  selectString+="' group by load_status,src_sys_nm,server order by  load_status,src_sys_nm,server"	
	}
	
	console.log(selectString);
    var sqlParams = [];	
    var rst ={};
    var resultHandler = function (result) {
	      var datainfo=[];
		  var ainfo={};
	      ainfo["name"]="File arrived late and not loaded";
	      ainfo["y"]=0;
	      ainfo["drilldown"]="A";
	      var binfo={};
	      binfo["name"]="File arrived on time but not loaded";
	      binfo["y"]=0;
	      binfo["drilldown"]="B";
		  var cinfo={};
	      cinfo["name"]="File did not arrive";
	      cinfo["y"]=0;
	      cinfo["drilldown"]="C";
		  var dinfo={};
	      dinfo["name"]="File included in rollup";
	      dinfo["y"]=0;
	      dinfo["drilldown"]="D";
		  var adata=[];
		  var bdata=[];
		  var cdata=[];
		  var ddata=[];
          for(var i=0;i<result.rows.length;i++)
		  {
		       if(req.query["env"]=="ALL")
               {
			     if(req.query["source"]=="ALL")
				 {
			     if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File arrived late and not loaded")
				 {
				   ainfo["y"]=parseInt(ainfo["y"])+parseInt(result.rows[i].count);	
				   var temparr=[];	
                   temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                   temparr.push(parseInt(result.rows[i].count));
				   var ifexsit=false;
				   for(var j=0;j<adata.length;j++)
				   {
				     if(adata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					 {
					   adata[j][1]+=parseInt(result.rows[i].count);
					   ifexsit=true;
					 }
				   }
				   if(ifexsit==false)
				   {
                     adata.push(temparr);
                   }					 
				 }
				 else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File arrived on time but not loaded (backlog)")
				 {
				    binfo["y"]=parseInt(binfo["y"])+parseInt(result.rows[i].count);
					var temparr=[];	
                    temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                    temparr.push(parseInt(result.rows[i].count));
                    var ifexsit=false;
				    for(var j=0;j<bdata.length;j++)
				    {
				     if(bdata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					 {
					   bdata[j][1]+=parseInt(result.rows[i].count);
					   ifexsit=true;
					 }
				    }
				    if(ifexsit==false)
				    {
                     bdata.push(temparr);
                    }
				 }
				 else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File did not arrive")
				 {
				    cinfo["y"]=parseInt(cinfo["y"])+parseInt(result.rows[i].count);	
					var temparr=[];	
                    temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                    temparr.push(parseInt(result.rows[i].count));
                    var ifexsit=false;
				    for(var j=0;j<cdata.length;j++)
				    {
				     if(cdata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					 {
					   cdata[j][1]+=parseInt(result.rows[i].count);
					   ifexsit=true;
					 }
				    }
				    if(ifexsit==false)
				    {
                     cdata.push(temparr);
                    }
				 }
				 else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File included in rollup")
				 {
				    dinfo["y"]=parseInt(dinfo["y"])+parseInt(result.rows[i].count);	
					var temparr=[];	
                    temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                    temparr.push(parseInt(result.rows[i].count));
                     var ifexsit=false;
				    for(var j=0;j<ddata.length;j++)
				    {
				     if(ddata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					 {
					   ddata[j][1]+=parseInt(result.rows[i].count);
					   ifexsit=true;
					 }
				    }
				    if(ifexsit==false)
				    {
                     ddata.push(temparr);
                    }
				  }
				  }
				  else if(req.query["source"]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
				  {
				    if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File arrived late and not loaded")
				    {
				     ainfo["y"]=parseInt(ainfo["y"])+parseInt(result.rows[i].count);	
				     var temparr=[];	
                     temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                     temparr.push(parseInt(result.rows[i].count));
				     var ifexsit=false;
				     for(var j=0;j<adata.length;j++)
				     {
				        if(adata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      adata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        adata.push(temparr);
                     }					 
				    }
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File arrived on time but not loaded (backlog)")
				    {
				      binfo["y"]=parseInt(binfo["y"])+parseInt(result.rows[i].count);
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<bdata.length;j++)
				      {
				       if(bdata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					   {
					     bdata[j][1]+=parseInt(result.rows[i].count);
					     ifexsit=true;
					   }
				      }
				      if(ifexsit==false)
				      {
                        bdata.push(temparr);
                      }
				    }
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File did not arrive")
				    {
				       cinfo["y"]=parseInt(cinfo["y"])+parseInt(result.rows[i].count);	
					   var temparr=[];	
                       temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                       temparr.push(parseInt(result.rows[i].count));
                       var ifexsit=false;
				       for(var j=0;j<cdata.length;j++)
				       {
				          if(cdata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					      {
					        cdata[j][1]+=parseInt(result.rows[i].count);
					        ifexsit=true;
					      }
				        }
				       if(ifexsit==false)
				       {
                           cdata.push(temparr);
                       }
				    }
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File included in rollup")
				    {
				        dinfo["y"]=parseInt(dinfo["y"])+parseInt(result.rows[i].count);							
					    var temparr=[];	
                        temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                        temparr.push(parseInt(result.rows[i].count));
                        var ifexsit=false;
				        for(var j=0;j<ddata.length;j++)
				        {
				           if(ddata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					       {
							 console.log(ddata[j][1]);
					         ddata[j][1]+=parseInt(result.rows[i].count);							 
					         ifexsit=true;
					       }
				        }
				        if(ifexsit==false)
				        {
                          ddata.push(temparr);
                        }
				      }
				  }				 
			   }			   
		       else
			   { 
			      if(result.rows[i].server.replace(/(\s*$)/g, "")==req.query["env"])
				  {  
				     if(req.query["source"]=="ALL")
				    {
				    if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File arrived late and not loaded")
				    {
                      ainfo["y"]=parseInt(ainfo["y"])+parseInt(result.rows[i].count);	
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<adata.length;j++)
				      {
				        if(adata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      adata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        adata.push(temparr);
                     }	
				    }                                                           
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File arrived on time but not loaded (backlog)")
				    {
					 
				      binfo["y"]=parseInt(binfo["y"])+parseInt(result.rows[i].count);
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<bdata.length;j++)
				      {
				        if(bdata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      bdata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        bdata.push(temparr);
                     }	
				    }
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File did not arrive") 
				    {
					  cinfo["y"]=parseInt(cinfo["y"])+parseInt(result.rows[i].count);	
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<cdata.length;j++)
				      {
				        if(cdata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      cdata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        cdata.push(temparr);
                     }	
				    }
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File included in rollup")
				    {
				      dinfo["y"]=parseInt(dinfo["y"])+parseInt(result.rows[i].count);	
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<ddata.length;j++)
				      {
				        if(ddata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      ddata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        ddata.push(temparr);
                     }	
				    }    
				  }
				  }
				  else if(req.query["source"]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
				  {
				    if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File arrived late and not loaded")
				    {
                      ainfo["y"]=parseInt(ainfo["y"])+parseInt(result.rows[i].count);	
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<adata.length;j++)
				      {
				        if(adata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      adata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        adata.push(temparr);
                     }	
				    }                                                           
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File arrived on time but not loaded (backlog)")
				    {
					 
				      binfo["y"]=parseInt(binfo["y"])+parseInt(result.rows[i].count);
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<bdata.length;j++)
				      {
				        if(bdata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      bdata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        bdata.push(temparr);
                     }	
				    }
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File did not arrive") 
				    {
					  cinfo["y"]=parseInt(cinfo["y"])+parseInt(result.rows[i].count);	
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<cdata.length;j++)
				      {
				        if(cdata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      cdata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        cdata.push(temparr);
                     }		  
				    }
				    else if(result.rows[i].load_status.replace(/(\s*$)/g, "")=="File included in rollup")
				    {
				      dinfo["y"]=parseInt(dinfo["y"])+parseInt(result.rows[i].count);	
					  var temparr=[];	
                      temparr.push(result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""));				   
                      temparr.push(parseInt(result.rows[i].count));
                      var ifexsit=false;
				      for(var j=0;j<ddata.length;j++)
				      {
				        if(ddata[j][0]==result.rows[i].src_sys_nm.replace(/(\s*$)/g, ""))
					    {
					      ddata[j][1]+=parseInt(result.rows[i].count);
					      ifexsit=true;
					    }
				     }
				     if(ifexsit==false)
				     {
                        ddata.push(temparr);
                     }		
				    }    
				  }
			   }		  
		  }
		  var drilldowna={};
		  var drilldownb={};
		  var drilldownc={};
		  var drilldownd={};
		  drilldowna["id"]="A";
		  drilldowna["data"]=adata;
		  drilldownb["id"]="B";
		  drilldownb["data"]=bdata;
		  drilldownc["id"]="C";
		  drilldownc["data"]=cdata;
		  drilldownd["id"]="D";
		  drilldownd["data"]=ddata;
		  datainfo.push(ainfo);
		  datainfo.push(binfo);
		  datainfo.push(cinfo);
		  datainfo.push(dinfo);
		  
		  rst["data"]=datainfo;
		  rst["drilldown"]=[];
		  rst["drilldown"].push(drilldowna);
		  rst["drilldown"].push(drilldownb);
		  rst["drilldown"].push(drilldownc);
		  rst["drilldown"].push(drilldownd);
    	  res.json(rst);
    }
    templateHandler(selectString, null, resultHandler, res);
	}catch(err){
	    console.log(err);
        res.send(500,null);
    } 
});


router.post('/', function (req, res) {

	var templateHandler = res.app.get('getDataTemplate2');

    var deleteString = multiline.stripIndent(function () { 
              /*
             delete from  rollupmecsummaries where rollupdate_l = $1 and environment = $2
 	         */
    });
    
     var params = [req.body.DATE,req.body.ENV]
    
     var resultHandler = function (result) { 

     }
     templateHandler(deleteString, params, resultHandler, res);
   

     var insertString = multiline.stripIndent(function () { 
             /*
			     INSERT INTO rollupmecsummaries(
			             category, rollupdate_l, item, environment,itemid)
			     VALUES ($1, $2, $3, $4, $5);
			*/
     });
    


     for(var i = 0 ;i < req.body.JADCOMMENT.length ; i++){

     	var params = ['JAD', req.body.DATE, req.body.JADCOMMENT[i].name,req.body.ENV, i]

     	templateHandler(insertString, params, resultHandler, res);
     }

      for(var i = 0 ;i < req.body.ZEOCOMMENT.length ; i++){

     	var params = ['ZEO', req.body.DATE, req.body.ZEOCOMMENT[i].name,req.body.ENV, i]

     	templateHandler(insertString, params, resultHandler, res);
     }

       for(var i = 0 ;i < req.body.EMRCOMMENT.length ; i++){

     	var params = ['EMR', req.body.DATE, req.body.EMRCOMMENT[i].name,req.body.ENV, i]

     	templateHandler(insertString, params, resultHandler, res);
     }

       for(var i = 0 ;i < req.body.YOTTACOMMENT.length ; i++){

     	var params = ['YOTTA', req.body.DATE, req.body.YOTTACOMMENT[i].name,req.body.ENV, i]

     	templateHandler(insertString, params, resultHandler, res);
     }

       for(var i = 0 ;i < req.body.OTHERCOMMENT.length ; i++){

     	var params = ['OTHER', req.body.DATE, req.body.OTHERCOMMENT[i].name,req.body.ENV, i]

     	templateHandler(insertString, params, resultHandler, res);
     }
      

    res.send(req.body);


});
module.exports = router;
