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
			select "Year","Month", min("MECStartDate_l"),max("MECEndDate_l")  from mec_calendars where "Year"=$1 and "Month"=$2 group by "Year","Month"  
		    */
	});
    var sqlParams = [parseInt(req.query["date"].substr(0,4)),parseInt(req.query["date"].substr(5,6))];	
    var rst ={};
    var resultHandler = function (result) {
	    if(result.rows.length<1)
		{
		  res.json(rst);
		}
		else
		{
    	//var rst = result.rows;
    	var weeks = [];
		var JAD=[];
		var EMR=[];
		var ZEO=[];
		var cweek=[];
		var selectStringc = multiline.stripIndent(function () { 
	        /*
			select workday_nm  from mec_calendars where "Year"=$1 and "Month"=$2 and "Environment"='EMR' and workday_nm is not null order by "MECStartDate_l" 
		    */
	     });
		 var sqlParamsc = [parseInt(req.query["date"].substr(0,4)),parseInt(req.query["date"].substr(5,6))];	
		 var resultHandlerc = function (resultc) {
		     var workinfo="";
		     for(var i=0;i<resultc.rows.length;i++)
			 {
			    workinfo+=resultc.rows[i].workday_nm.replace(/(\s*$)/g, "")+",";
			 }
                          
			 var eworkd=[];
             while  (workinfo.indexOf(",")!=-1) {
			        eworkd.push(workinfo.substring(0,workinfo.indexOf(","))); 
 					workinfo=workinfo.substring(workinfo.indexOf(",")+1);
			 }
				 
		     var days0=(result.rows[0].max.getTime()-result.rows[0].min.getTime())/24/3600/1000;
			 j=0
		     for(var i = 0; i<=days0; i++) //
             { 		   
		       if(((new Date((result.rows[0].min/1000+86400*i)*1000)).getDay()!=6) &&((new Date((result.rows[0].min/1000+86400*i)*1000)).getDay()!=0))
		       { 	
      
                  if((((new Date(dateFormat(new Date((result.rows[0].min/1000+86400*i)*1000),'yyyy-mm-dd hh:mm:ss'))).getDay())!=6)&&(((new Date(dateFormat(new Date((result.rows[0].min/1000+86400*i)*1000),'yyyy-mm-dd hh:mm:ss'))).getDay())!=0))
                  { 
                    cweek.push(new Date(dateFormat(new Date((result.rows[0].min/1000+86400*i)*1000),'yyyy-mm-dd hh:mm:ss')));
				    var  edate={};	
					if(j<eworkd.length)
					{
                     edate["t"]=eworkd[j]+" "+dateFormat(new Date((result.rows[0].min/1000+86400*i)*1000),'yyyy-mm-dd');		
                    }
                    else
                    {
					 edate["t"]=dateFormat(new Date((result.rows[0].min/1000+86400*i)*1000),'yyyy-mm-dd');	
					}					
		            weeks.push(edate);
					j++;
			       }
		       }
             }   
		      var selectStringb = multiline.stripIndent(function () { 
            /*
             select * from dailyrolluptimes where "Server"!='BER' and "RollupDate_l">=$1 and "RollupDate_l"<=$2  order by "End_TS"
            */
            });
		var sqlParamstwo = [result.rows[0].min,result.rows[0].max];
		
		var j=0;
		var a=0;
		var b=0;
		var lastenvironment;
	    var resultHandlertwo = function (result1)
            {
			   for(var i = 0; i<result1.rows.length; i++) 
               {
			    if(i==result1.rows.length-1)
				{
				  lastenvironment=result1.rows[i].Server;
				}
			    if((result1.rows[i].RollupDate_l.getDay()!=6)&&(result1.rows[i].RollupDate_l.getDay()!=0)) 
                {				
			     if((result1.rows[i].Server=='ZEO')&&(j<cweek.length))
				 {
				    if(new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 00:00:00')).getTime()==new Date(dateFormat(cweek[j],'yyyy-mm-dd 00:00:00')).getTime())
					{  
                       	 var  detailinfo={};
						if(result1.rows[i].ElapseTime!=null)
                        {								
						 if(result1.rows[i].ElapseTime.toString().length>1)
						 { 
						    detailinfo["t"]=result1.rows[i].ElapseTime.toString().substring(0,result1.rows[i].ElapseTime.toString().indexOf("."))+"h"+parseInt(result1.rows[i].ElapseTime.toString()[result1.rows[i].ElapseTime.toString().indexOf(".")+1]/10*60)+"m";
						 }
						 else
						 {
						    detailinfo["t"]=result1.rows[i].ElapseTime.toString()[0]+"h"+"0"+"m";
						 }
						}
						else
						{						   
						   var myDate = new Date();
						   hour=parseInt((myDate.getTime()-result1.rows[i].Start_TS.getTime())/1000/3600)-8;
						   minute=parseInt((myDate.getTime()-result1.rows[i].Start_TS.getTime())/1000/60)-(hour+8)*60;
						   console.log("zeo log");
						   console.log(minute);
						   if(hour==0)
						   {
						    detailinfo["t"]=minute+"m";
						   }
						   else
						   {
						    detailinfo["t"]=hour+"h"+minute+"m";
						   }
						}
						
					   if(result1.rows[i].End_TS_l!=null)
                       {		
						if((new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))) >result1.rows[i].End_TS_l)
						{
						   detailinfo["o"]=true;
						}
						else
						{
						   detailinfo["o"]=false;
						}
					   }
                       else
                       {   
					       var myDate = new Date();
						   if(myDate<(new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))))
						   {
						     detailinfo["o"]=true;
						   }
						   else
						   {
						     detailinfo["o"]=false;
						   }					       
					   }					   
						 
						 if(result1.rows[i].Start_TS_l.getTime() >(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())
						 {
						   if(((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/60)>3)
						   {
						    hour=parseInt((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/3600);
							minute=parseInt((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/60)-hour*60;
							if(hour==0)
						    {
						      detailinfo["d"]=minute+"m";
						    }
						    else
						    {
						     detailinfo["d"]=hour+"h"+minute+"m";
						    }
						   }
                           else
                           {
						    detailinfo["d"]="";
						   }						   
						  }
						 else
						 {
						   detailinfo["d"]="";
						 }
					     ZEO.push(detailinfo);
					}
					else
					{  
					   var  detailinfo={};
					   detailinfo["t"]="";
					   detailinfo["o"]="";
					   detailinfo["d"]="";
					   ZEO.push(detailinfo);
					}
					j+=1;
				 }
				 if((result1.rows[i].Server=='EMR')&&(a<cweek.length))
				 {   
				    if(new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 00:00:00')).getTime()==new Date(dateFormat(cweek[a],'yyyy-mm-dd 00:00:00')).getTime())
					{
					   var  detailinfo={};
					   if(result1.rows[i].ElapseTime!=null)
					   {
						 if(result1.rows[i].ElapseTime.toString().length>1)
						 { 
						    detailinfo["t"]=result1.rows[i].ElapseTime.toString().substring(0,result1.rows[i].ElapseTime.toString().indexOf("."))+"h"+parseInt(result1.rows[i].ElapseTime.toString()[result1.rows[i].ElapseTime.toString().indexOf(".")+1]/10*60)+"m";
						 }
						 else
						 {
						    detailinfo["t"]=result1.rows[i].ElapseTime.toString()[0]+"h"+"0"+"m";
						 }
						}
						else
						{
						   var myDate = new Date();
						   hour=parseInt((myDate.getTime()-result1.rows[i].Start_TS.getTime())/1000/3600)-8;
						   minute=parseInt((myDate.getTime()-result1.rows[i].Start_TS.getTime())/1000/60)-(hour+8)*60;
						   if(hour==0)
						   {
						    detailinfo["t"]=minute+"m";
						   }
						   else
						   {
						   detailinfo["t"]=hour+"h"+minute+"m";
						   }
						}
						 
						 if(result1.rows[i].End_TS_l!=null)
                       {		
						if((new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))) >result1.rows[i].End_TS_l)
						{
						   detailinfo["o"]=true;
						}
						else
						{
						   detailinfo["o"]=false;
						}
					   }
                       else
                       {   
					       var myDate = new Date();
						   if(myDate<(new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))))
						   {
						     detailinfo["o"]=true;
						   }
						   else
						   {
						     detailinfo["o"]=false;
						   }					       
					   }
						 
						 if(result1.rows[i].Start_TS_l.getTime() >(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())
						 {
						   if(((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/60/60)>3)
						   {
							 hour=parseInt((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/3600);
							 minute=parseInt((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/60)-hour*60;
							 if(hour==0)
						     {
						      detailinfo["d"]=minute+"m";
						     }
						     else
						     {
						      detailinfo["d"]=hour+"h"+minute+"m";
						     }
						   }
						   else
						   {
						    detailinfo["d"]="";
						   }
						  }
						 else
						 {
						   detailinfo["d"]="";
						 }
					     EMR.push(detailinfo);
					}
					else
					{    
					     var  detailinfo={};
					     detailinfo["t"]="";
					     detailinfo["o"]="";
					     detailinfo["d"]="";
					     EMR.push(detailinfo);
					}
					a+=1;
				 }
				 if((result1.rows[i].Server=='JAD')&&(b<cweek.length))
				 {
				    if(new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 00:00:00')).getTime()==new Date(dateFormat(cweek[b],'yyyy-mm-dd 00:00:00')).getTime())
					{
					    var  detailinfo={};
				        if(result1.rows[i].ElapseTime!=null)
					    {
						 if(result1.rows[i].ElapseTime.toString().length>1)
						 { 
						    detailinfo["t"]=result1.rows[i].ElapseTime.toString().substring(0,result1.rows[i].ElapseTime.toString().indexOf("."))+"h"+parseInt(result1.rows[i].ElapseTime.toString()[result1.rows[i].ElapseTime.toString().indexOf(".")+1]/10*60)+"m";
						 }
						 else
						 {
						    detailinfo["t"]=result1.rows[i].ElapseTime.toString()[0]+"h"+"0"+"m";
						 }
						}
						else
						{
						   var myDate = new Date();
						   hour=parseInt((myDate.getTime()-result1.rows[i].Start_TS.getTime())/1000/3600)-8;
						   minute=parseInt((myDate.getTime()-result1.rows[i].Start_TS.getTime())/1000/60)-(hour+8)*60;
						   if(hour==0)
						   {
						    detailinfo["t"]=minute+"m";
						   }
						   else
						   {
						   detailinfo["t"]=hour+"h"+minute+"m";
						   }
						}
						 
						 if(result1.rows[i].End_TS_l!=null)
                       {		
						if((new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))) >result1.rows[i].End_TS_l)
						{
						   detailinfo["o"]=true;
						}
						else
						{
						   detailinfo["o"]=false;
						}
					   }
                       else
                       {   
					       var myDate = new Date();
						   if(myDate<(new Date(dateFormat(result1.rows[i].RollupDate_l,'yyyy-mm-dd 13:00:00'))))
						   {
						     detailinfo["o"]=true;
						   }
						   else
						   {
						     detailinfo["o"]=false;
						   }					       
					   }
						 
						 if(result1.rows[i].Start_TS_l.getTime() >(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())
						 {
						   if(((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/60/60)>3)
						   {
							 hour=parseInt((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/3600);
							 minute=parseInt((result1.rows[i].Start_TS_l.getTime()-(new Date(dateFormat(result1.rows[i].Start_TS_l,'yyyy-mm-dd 03:00:00'))).getTime())/1000/60)-hour*60;
							 if(hour==0)
						     {
						      detailinfo["d"]=minute+"m";
						     }
						     else
						     {
						      detailinfo["d"]=hour+"h"+minute+"m";
						     }
						   }
						   else
						   {
						    detailinfo["d"]="";
						   }
						}
						 else
						 {						   
						   detailinfo["d"]="";
						 }
					     JAD.push(detailinfo);
					}
					else
					{   
					     var  detailinfo={};
					     detailinfo["t"]="";
					     detailinfo["o"]="";
					     detailinfo["d"]="";
					     JAD.push(detailinfo);
					}
					b+=1
				 }
				}  
			   }

			   for(j=ZEO.length;j<cweek.length;j++)
			   {
			     var  detailinfo={};
				 detailinfo["t"]="";
			     detailinfo["o"]="";
			     detailinfo["d"]="";
			     ZEO.push(detailinfo);
			   }
			   
			   for(j=EMR.length;j<cweek.length;j++)
			   {
			     var  detailinfo={};
				 detailinfo["t"]="";
			     detailinfo["o"]="";
			     detailinfo["d"]="";
			     EMR.push(detailinfo);
			   }
			   
			   for(j=JAD.length;j<cweek.length;j++)
			   {
			     var  detailinfo={};
				 detailinfo["t"]="";
			     detailinfo["o"]="";
			     detailinfo["d"]="";
			     JAD.push(detailinfo);
			   }
			   
			   
			   rst["weeks"]=weeks;
			   rst["ZEO"]=ZEO;
			   rst["EMR"]=EMR;
			   rst["JAD"]=JAD;
               if(result1.rows.length==0)
			   {			     
				 for(i=0;i<cweek.length;i++)
				 {
				   var  detailinfo={};
				   detailinfo["t"]="";
				   detailinfo["o"]="";
				   detailinfo["d"]="";
				   ZEO.push(detailinfo);
				   EMR.push(detailinfo);
				   JAD.push(detailinfo);
				 }
				 rst["LASTENV"]="JAD";
				 rst["LASTDAY"]=0;
			   }
			   else
			   {
			     rst["LASTENV"]=lastenvironment;
                 for(var i=0;i<cweek.length;i++)
				 { 
				   if(new Date(dateFormat(result1.rows[result1.rows.length-1].RollupDate_l,'yyyy-mm-dd 00:00:00')).getTime()==new Date(dateFormat(cweek[i],'yyyy-mm-dd 00:00:00')).getTime())
				   {
				    rst["LASTDAY"]=i;
				   }
				 }
			   }			  
			   res.json(rst);
			}		
				
		templateHandler(selectStringb, sqlParamstwo, resultHandlertwo, res);
		 }
		 templateHandler(selectStringc, sqlParamsc, resultHandlerc, res);		 		
 		} 
     	 
    }
    templateHandler(selectString, sqlParams, resultHandler, res);	
	
	}catch(err)
	     {
			console.log(err);
            res.send(500,null);
         } 		   
});


router.post('/', function (req, res) {
   try{

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

  	}catch(err){
			console.log(err);
            res.send(500,null);
           } 
});
module.exports = router;
