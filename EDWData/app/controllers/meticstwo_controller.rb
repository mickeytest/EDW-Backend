class MeticstwoController < ApplicationController
   def index
	      currentdate = params[:month];
		  jaddatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate_l\") as \"MECStartDate_l\" ,max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Environment\"='JAD' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
          emrdatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate_l\") as \"MECStartDate_l\" ,max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Environment\"='EMR' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
		  zeodatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate_l\") as \"MECStartDate_l\" ,max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Environment\"='ZEO' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")

 if(currentdate!=nil)
		  #datestart=DateTime.parse(currentdate+ '-01').strftime("%Y-%m-%d %H:%M:%S")
		  #dateend=(DateTime.parse((DateTime.parse(currentdate+ '-01')).strftime("%Y-%m") + '-1 00:00:00') >>1).strftime("%Y-%m-%d %H:%M:%S");		             
		  datestartyear=(DateTime.parse(currentdate+ '-01').strftime("%Y")).to_i
	      datestartmonth=(DateTime.parse(currentdate+ '-01').strftime("%m")).to_i 
	       
		   if(datestartmonth!=1)
               mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"= \'#{datestartmonth}\' group by \"Environment\"")
	           mecendinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\'-1 group by \"Environment\"")
           else
	           mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\")  as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\' group by \"Environment\"")
	           mecendinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear-1}\'  and \"Month\"=12 group by \"Environment\"")
	       end   	           
			   datejadstart=mecendinfo[0]["endtime"]
			   dateemrstart=mecendinfo[1]["endtime"]
			   datezeostart=mecendinfo[2]["endtime"]
			   			   
	           datejadend=mecstartinfo[0]["starttime"]
	           dateemrend=mecstartinfo[1]["starttime"]
	           datezeoend=mecstartinfo[2]["starttime"]
                datestart=mecendinfo[2]["endtime"]
				dateend=mecstartinfo[2]["starttime"]
=begin				
			if(datestartmonth==jaddatascope[0]["Month"].to_i)
			   if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((jaddatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               datejadend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
			   dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
               end	
            end
    
	        if(datestartmonth==emrdatascope[0]["Month"].to_i)
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((emrdatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               dateemrend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
               dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))				   
               end	
			end
			if(datestartmonth==zeodatascope[0]["Month"].to_i)
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((zeodatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               datezeoend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
			   dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
               end	
             end
=end              			   
=begin	 
  	  else
          datestart=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 90).strftime("%Y-%m-%d %H:%M:%S")
		  dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
=end		  
       end
		   prorollupmatic=Hash.new	


#mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Year\"=\'#{zeodatascope[1]["Year"]}\'  and \"Month\"=\'#{zeodatascope[1]["Month"]}\'")


if(currentdate==nil)
       first=true
    i=0
   while i<jaddatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((jaddatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   jadmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{jaddatascope[i]["Year"]}\'  and \"Month\"=\'#{jaddatascope[i]["Month"]}\' and \"Environment\"='JAD'")
		   first=false
		 end
		 i+=1
   end
   
   first=true
   i=0
   while i<emrdatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((emrdatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   emrmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{emrdatascope[i]["Year"]}\'  and \"Month\"=\'#{emrdatascope[i]["Month"]}\' and \"Environment\"='EMR'")
		   first=false
		 end
		 i+=1
   end
   
     first=true
    i=0
   while i<zeodatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((zeodatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   zeomecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{zeodatascope[i]["Year"]}\'  and \"Month\"=\'#{zeodatascope[i]["Month"]}\' and \"Environment\"='ZEO'")
		   first=false
		 end
		 i+=1
   end
	datejadstart=jadmecstartinfo[0]["currentstarttime"]
	dateemrstart=emrmecstartinfo[0]["currentstarttime"]
	datezeostart=zeomecstartinfo[0]["currentstarttime"]
	datestart=zeomecstartinfo[0]["currentstarttime"]
    dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
	datejadend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	dateemrend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	datezeoend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
end 

if((params[:from] !=nil) && (params[:to]!=nil))
 datejadstart=DateTime.parse(params[:from])
 dateemrstart=DateTime.parse(params[:from])
# datezeostart=DateTime.parse(params[:from])
 datejadend=DateTime.parse(params[:to])
 dateemrend=DateTime.parse(params[:to])
 datezeoend=DateTime.parse(params[:to])
 datestart=DateTime.parse(params[:from])
 dateend==DateTime.parse(params[:to])
  datezeostart=(DateTime.parse((params[:from]))-1).strftime("%Y-%m-%d")
end

mectitleinfo=nil
nonmectitleinfo=nil
if( DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) < DateTime.parse((zeodatascope[0]["MECStartDate_l"]).strftime("%Y-%m-%d %H:%M:%S")) )
     prorollupmatic["mindate"]="2015-08"
	 prorollupmatic["maxdate"]=zeodatascope[1]["Year"].to_s + "-" + zeodatascope[1]["Month"].to_s
	 mectitleinfo=""
elsif(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >DateTime.parse((zeodatascope[0]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S")))
     prorollupmatic["mindate"]="2015-08"
	 prorollupmatic["maxdate"]=zeodatascope[0]["Year"].to_s + "-" + zeodatascope[0]["Month"].to_s
	 mectitleinfo=""
else
     prorollupmatic["mindate"]="2015-08"
	 prorollupmatic["maxdate"]=zeodatascope[0]["Year"].to_s + "-" + zeodatascope[0]["Month"].to_s
	 if(currentdate!=nil)
	     if(DateTime.parse(currentdate+ '-01').strftime("%Y-%m-%d")==DateTime.parse(zeodatascope[0]["Year"].to_s+ "-" + zeodatascope[0]["Month"].to_s + "-01").strftime("%Y-%m-%d"))
         mectitleinfo= DateTime.parse(zeodatascope[0]["Year"].to_s+ "-" + zeodatascope[0]["Month"].to_s + "-01").strftime("%b") + " MEC is on going"
         else
         mectitleinfo=""
         end
	 else
	     mectitleinfo=""
	 end
end
		 
		 privious90time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 90).strftime("%Y-%m-%d %H:%M:%S")
		 mecZEOinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{datezeostart}\' and \"MECStartDate_l\"<=\'#{datezeoend}\' and \"Environment\"='ZEO'")
	     mecEMRinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{dateemrstart}\'  and \"MECStartDate_l\"<=\'#{dateemrend}\' and \"Environment\"='EMR'")
		 mecJADinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{datejadstart}\' and \"MECStartDate_l\"<=\'#{datejadend}\' and \"Environment\"='JAD'")
		 devoncallzeoinfo=Oncallissuetracker.find_by_sql("select \"Date_l\" ,\"TimetoFix\",\"Environment\",\"TimetoEngage\" from oncallissuetrackers where \"Date_l\">\'#{datezeostart}\' and \"Date_l\"<=\'#{datezeoend}\' and \"Environment\"='ZEO'")
		 devoncallemrinfo=Oncallissuetracker.find_by_sql("select \"Date_l\" ,\"TimetoFix\",\"Environment\",\"TimetoEngage\" from oncallissuetrackers where \"Date_l\">\'#{dateemrstart}\' and \"Date_l\"<=\'#{dateemrend}\' and \"Environment\"='EMR'")
		 devoncalljadinfo=Oncallissuetracker.find_by_sql("select \"Date_l\" ,\"TimetoFix\",\"Environment\",\"TimetoEngage\" from oncallissuetrackers where \"Date_l\">\'#{datejadstart}\' and \"Date_l\"<=\'#{datejadend}\' and \"Environment\"='JAD'")
		 
		 
		 tttstart=  (DateTime.parse((datestart).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00")
		 tttend=  (DateTime.parse((dateend).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00") 
		 yottainfo=HpsmYotta.find_by_sql("select count(distinct  \"Incident_ID\"),\"Status\" from hpsm_yotta where \"Open_Time_l\">=\'#{tttstart}\' and \"Open_Time_l\"<=\'#{tttend}\' group by \"Status\"")
		 uaminfo=HpsmUam.find_by_sql("select count(distinct  \"Incident_ID\"),\"Status\" from hpsm_uams where \"Open_Time_l\">=\'#{tttstart}\' and \"Open_Time_l\"<=\'#{tttend}\' group by \"Status\"")
		 dqinfo=HpsmDq.find_by_sql("select count(*),\"Status\" from hpsm_dqs where \"Open_Time_l\">=\'#{tttstart}\' and \"Open_Time_l\"<=\'#{tttend}\' group by \"Status\"")
		 seaquestsinfo=HpsmDq.find_by_sql("select count(distinct  \"Incident_ID\"),\"Status\" from hpsm_seaquests where \"Open_Time_l\">=\'#{tttstart}\' and \"Open_Time_l\"<=\'#{tttend}\' group by \"Status\"")
		 bfxinfo=CmbfxRequestTable.find_by_sql("select count(*) as \"countModified\"  from  cmbfx_request_tables where  \"Modified_l\">\'#{datestart}\'
 			   and \"Modified_l\"<=\'#{dateend}\'")
	     dqticketbyall=HpsmYotta.find_by_sql("select count(*) as \"countttstartf\"  from  hpsm_dqs where  \"Close_Time_l\">=\'#{tttstart}}\' and \"Close_Time_l\"<=\'#{tttend}\' 
			      and \"Assignee\" in('patrick.sigourney@hpe.com', 
                 'dana.orr@hpe.com', 
                 'grace.chao@hpe.com', 
                 'annmarie.mcginley@hpe.com')")   
	     dqticketbyssit=HpsmYotta.find_by_sql("select count(*) as \"countttstartf\"  from  hpsm_dqs where  \"Close_Time_l\">=\'#{tttstart}}\' and \"Close_Time_l\"<=\'#{tttend}\' 
			      and \"Assignee\" in ('dai-jun.lv@hpe.com','xiao-yang.liu@hpe.com','mooi@hpe.com' ,'xiao.zhang@hpe.com','yi-wen.chen@hpe.com',
				  'sergio.castellanos@hpe.com', 
                  'pedro-enrique.castillo.rangel@hpe.com',
                  'nayeli.mena@hpe.com',
                  'gibascencio@hpe.com' 
				  )")
				  
				  
	     yottaclose  =HpsmYotta.find_by_sql("select count(distinct  \"Incident_ID\") as \"countttstartf\"  from  hpsm_yotta where \"Close_Time_l\">=\'#{tttstart}\' and \"Close_Time_l\"<=\'#{tttend}\'")
	     seaquestclose=HpsmDq.find_by_sql("select count(distinct  \"Incident_ID\") as \"countttstartf\"  from  hpsm_seaquests where \"Close_Time_l\">=\'#{tttstart}\' and \"Close_Time_l\"<=\'#{tttend}\'")
	     dqclose=HpsmDq.find_by_sql("select count(*)  as \"countttstartf\"  from hpsm_dqs where \"Close_Time_l\">=\'#{tttstart}\' and \"Close_Time_l\"<=\'#{tttend}\'")
      
 	    opsinfo=EdwOpsCallTracker.find_by_sql("select * from(
(select distinct \"Classification\" from edw_ops_call_trackers) a  
left join (select  \"Classification\" as \"class\", count(*) as \"number\" from edw_ops_call_trackers where \"Complete_Date\">=\'#{tttstart}\'  and  \"Complete_Date\"<=\'#{tttend}\' group by \"Classification\" ) b  on a.\"Classification\"=b.\"class\") bbb
where \"number\" is not null")
		 
		 statusinfo= EdwOpsCallTracker.find_by_sql("SELECT \"Status\" ,\"MIDs\",count(*)
  FROM edw_ops_call_trackers where (\"Assigned_To\" like 'Chen, Gang%' or \"Assigned_To\"  is null)  and (\"Complete_Date_l\">=\'#{tttstart}\' and \"Complete_Date_l\"<=\'#{tttend}\'  or  \"Complete_Date_l\" is null )
  group by \"Status\",\"MIDs\"")
  
				typeinfo= EdwOpsCallTracker.find_by_sql("SELECT \"Change_Type\" ,\"MIDs\",count(*)
  FROM edw_ops_call_trackers where (\"Assigned_To\" like 'Chen, Gang%' or \"Assigned_To\"  is null)  and (\"Complete_Date_l\">=\'#{tttstart}\' and \"Complete_Date_l\"<=\'#{tttend}\'  or  \"Complete_Date_l\" is null )
  group by \"Change_Type\",\"MIDs\"")
         
		 pdminfo= EdwOpsCallTracker.find_by_sql("  select count(distinct \"PdmNo\")  from pdm_requests
         where \"Schema\" is not null and \"UpdateDate\" >=\'#{tttstart}\' and \"UpdateDate\" <=\'#{tttend}\' ")
		 
	     onboardinfo=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"requestId\") FROM edw_regression_test_request where \"requestDate\" >=\'#{tttstart}\'and  \"requestDate\" <=\'#{tttend}\' and \"approvalStatus\"='Yes'")
	     onboardinfo1=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"filesName\") FROM edw_regression_test_request where \"requestDate\" >=\'#{tttstart}\'and  \"requestDate\" <=\'#{tttend}\'  and \"approvalStatus\"='Yes'")
         onboarddeepinfo=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"ID\")  FROM sp_edwonboardingdeepsprt where \"EndDate\" >=\'#{tttstart}\'and \"EndDate\"  <=\'#{tttend}\'")
		 yottacr=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"ID\")  FROM sp_yottacr where  \"Closed\">=\'#{tttstart}\' and \"Closed\"  <=\'#{tttend}\'")
		 shareplatformcr=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"ID\") FROM sp_uamchangerequests  where  \"Closed\">=\'#{tttstart}\' and \"Closed\"  <=\'#{tttend}\'")
		 boecr=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"ID\") FROM sp_boe  where  \"Closed\">=\'#{tttstart}\' and \"Closed\"  <=\'#{tttend}\'")
		 qlikviewcr=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"ID\") FROM sp_qlikviewrequest  where  \"Closed\">=\'#{tttstart}\' and \"Closed\"  <=\'#{tttend}\'")
		 
		 rmticketinfo=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"MID\") FROM rolluperrorinformations where \"Server\"='BER'  and \"RollupDate_l\">=\'#{tttstart}\' and \"RollupDate_l\"<\'#{tttend}\'");
         rmmtirequestinfo=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"ID\") FROM sp_mtirequest where \"ApprovalStatus\"='Approved' and ((\"MTIStatus\"='Completed') or (\"MTIStatus\"='Signed Off')) and   \"Created\">=\'#{tttstart}\' and  \"Created\"<=\'#{tttend}\'")
		 strclassification=[]
		 ttt=0
		 while ttt<opsinfo.length do
               classhash=Hash.new	
               classhash={:name=>opsinfo[ttt]["Classification"],:value=>opsinfo[ttt]["number"].to_s}			   
		       strclassification.push(classhash)
		       ttt+=1
		 end		 

		 
		 maticstwo={
                    "Yotta"=> {"Ticket"=> 0,"CloseTicket"=>0,"CR"=>0,"MTP"=>1,"Month"=>" 16 Feb"},
                    "Sequest"=> {"Ticket"=> 0,"CloseTicket"=> 0,"PDM"=> 12},
                    "UAM"=> {"Tickets"=> 0,"CancelTicketttstartF"=> 2,"NotReproduce"=> 2,"OOS"=> 2,"MisRouted"=> 2,"Resolved"=> 1,"CRs"=> 38,"NotShared"=> 6,"BOE"=> 2,"QV"=> 30},
                    "DQ"=> {"Tickets"=> 0,"CloseTicket"=> 0,"PendingTicket"=>0,"OpenTicket"=> 0,"TicketIMIT"=> 0,"TicketSSIT"=> 80,"ClosedPercentage"=> 100},
					"CM"=> {"TTFMTPReview"=> 0,"TTFBFX"=> 0,"AVGRFC"=> 0,"AVGBFX"=> 0},
                    "DevOncall"=> {"TTOMEC"=> 0,"TTFMEC"=> 0,"TTONonMEC"=> 0,"TTFError"=> 0,"Total"=> 0,"TotalMEC"=> 0,"TotalNonMEC"=> 0},
                    "RMT"=> {"Tickets"=> 0,"MTIRequest"=> 0,"MTDQR"=> 1,"TTO"=> 100,"TTF"=> 90},
                    "OnBoarding"=> {"FileLoadingRequest"=> 1,"FileLoad"=> 11,"FileLoadSharePoint"=> 4,"Within1hours"=> 100,"Within2days"=> 100},
					"Optimization"=>{"Tickets"=>0,"topthree"=>[]}
                   }
			maticstwo["OnBoarding"]["FileLoadingRequest"]=  onboardinfo[0]["count"] 
			maticstwo["OnBoarding"]["FileLoad"]=  onboardinfo1[0]["count"] 
			maticstwo["OnBoarding"]["FileLoadSharePoint"]=  onboarddeepinfo[0]["count"]
 			maticstwo["Yotta"]["CR"]=  yottacr[0]["count"]
            maticstwo["UAM"]["NotShared"]=  shareplatformcr[0]["count"]	
            maticstwo["UAM"]["BOE"]=  boecr[0]["count"]	
            maticstwo["UAM"]["QV"] =  qlikviewcr[0]["count"]	
            maticstwo["UAM"]["CRs"]=  qlikviewcr[0]["count"]+shareplatformcr[0]["count"]+ boecr[0]["count"]
            maticstwo["RMT"]["Tickets"]=rmticketinfo[0]["count"]		
            maticstwo["RMT"]["MTIRequest"]=rmmtirequestinfo[0]["count"]	
			maticstwo["Sequest"]["PDM"]=pdminfo[0]["count"]	
			if(currentdate!=nil)
			maticstwo["Yotta"]["Month"]= DateTime.parse(currentdate+ '-01').strftime("%Y %b")
			else
			maticstwo["Yotta"]["Month"]=(Time.new).strftime("%Y %b")
			end
			
		  tt=0	
          while tt<statusinfo.length do		 
                if((statusinfo[tt]["MIDs"].include? "N/A")||(statusinfo[tt]["MIDs"].include? "n/a")||(statusinfo[tt]["MIDs"].include? "/NA"))	
			       maticstwo["Optimization"]["Tickets"]+=statusinfo[tt]["count"]
				else
				   maticstwo["Optimization"]["Tickets"]+=statusinfo[tt]["MIDs"].split(',').length * statusinfo[tt]["count"]						 
                end			 
		     tt+=1
		 end
		

		    ticketbytype={"typebugfixing"=>0,"typeoptimization"=>0,"typetsa"=>0,"Enhancement"=>0,"dataextract"=>0}
		    tt=0
		 while tt<typeinfo.length do
		   if(typeinfo[tt]["Change_Type"] != nil)
		     if((typeinfo[tt]["Change_Type"].include? "Bug Fixing") ==true)  
			    if((typeinfo[tt]["MIDs"].include? "N/A")||(typeinfo[tt]["MIDs"].include? "n/a")||(typeinfo[tt]["MIDs"].include? "/NA"))	
			       ticketbytype["typebugfixing"]+=typeinfo[tt]["count"]
				else	   
				   ticketbytype["typebugfixing"]+=typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
				end
			end
             
			 if((typeinfo[tt]["Change_Type"].include? "Optimization") ==true)
                if((typeinfo[tt]["MIDs"].include? "N/A")||(typeinfo[tt]["MIDs"].include? "n/a")||(typeinfo[tt]["MIDs"].include? "/NA"))	
			       ticketbytype["typeoptimization"]+=typeinfo[tt]["count"]
				else
				   ticketbytype["typeoptimization"]+=typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
				end  
             end     		
			
             if((typeinfo[tt]["Change_Type"].include? "TSA" )==true)
                if((typeinfo[tt]["MIDs"].include? "N/A")||(typeinfo[tt]["MIDs"].include? "n/a")||(typeinfo[tt]["MIDs"].include? "/NA"))	
			       ticketbytype["typetsa"]+=typeinfo[tt]["count"]
				else
				   ticketbytype["typetsa"]+=typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
				end			 
             end

			 
			 if((typeinfo[tt]["Change_Type"].include? "Enhancement" )==true)			    
                if((typeinfo[tt]["MIDs"].include? "N/A")||(typeinfo[tt]["MIDs"].include? "n/a")||(typeinfo[tt]["MIDs"].include? "/NA"))	
			       ticketbytype["Enhancement"]+=typeinfo[tt]["count"]
				else
				   ticketbytype["Enhancement"]+=typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
				end			 
             end
			 
			 if((typeinfo[tt]["Change_Type"].include? "Data Extract" )==true)
			 p "dfadf"
                if((typeinfo[tt]["MIDs"].include? "N/A")||(typeinfo[tt]["MIDs"].include? "n/a")||(typeinfo[tt]["MIDs"].include? "/NA"))	
			       ticketbytype["dataextract"]+=typeinfo[tt]["count"]
				else
				   ticketbytype["dataextract"]+=typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
				end			 
             end
            end			 
		     tt+=1
		 end
topone={"name"=>"Bug Fixing","value"=>ticketbytype["typebugfixing"]}
toptwo={"name"=>"Data Extract","value"=>ticketbytype["dataextract"]}
topthree={"name"=>"TSA","value"=>ticketbytype["typetsa"]}

if(ticketbytype["typebugfixing"]>ticketbytype["dataextract"])
   	
	   	maticstwo["Optimization"]["topthree"].push(topone);
    maticstwo["Optimization"]["topthree"].push(toptwo);	
	
else
    maticstwo["Optimization"]["topthree"].push(toptwo);
    maticstwo["Optimization"]["topthree"].push(topone);	
end


    maticstwo["Optimization"]["topthree"].push(topthree);		



		
		
		
		 i=0
		 while i<typeinfo.length do
		      
		     i+=1
		 end
				   
				   
		 i=0
		 while i<yottainfo.length do
		       if(yottainfo[i]["Status"]=="Closed")
			   maticstwo["Yotta"]["CloseTicket"]=yottainfo[i]["count"]
			   end
			   maticstwo["Yotta"]["Ticket"]+=yottainfo[i]["count"]
			   i+=1
		 end
		 
		 i=0
		 while i<uaminfo.length do
			   maticstwo["UAM"]["Tickets"]+=uaminfo[i]["count"]
			   i+=1
		 end
		 
		 i=0
		 while i<seaquestsinfo.length do
			    if(seaquestsinfo[i]["Status"]=="Closed")
			   maticstwo["Sequest"]["CloseTicket"]=seaquestsinfo[i]["count"]
			   end
			   maticstwo["Sequest"]["Ticket"]+=seaquestsinfo[i]["count"]
			   i+=1
		 end
		 
		 i=0
		 while i<dqinfo.length do
			   if(dqinfo[i]["Status"]=="Closed")
			   maticstwo["DQ"]["CloseTicket"]=dqinfo[i]["count"]
			   elsif(dqinfo[i]["Status"]=="Pending Other")
			   maticstwo["DQ"]["PendingTicket"]=dqinfo[i]["count"]
			   elsif(dqinfo[i]["Status"]=="Open")
			   maticstwo["DQ"]["OpenTicket"]+=dqinfo[i]["count"]
			   elsif(dqinfo[i]["Status"]=="Work In Progress")
			   maticstwo["DQ"]["OpenTicket"]+=dqinfo[i]["count"]
			   end
			   maticstwo["DQ"]["Tickets"]+=dqinfo[i]["count"]			   
			   i+=1
		 end
		 maticstwo["DQ"]["TicketIMIT"]=dqticketbyall[0]["countttstartf"]
		 maticstwo["DQ"]["TicketSSIT"]=dqticketbyssit[0]["countttstartf"]
		 
		 maticstwo["Yotta"]["CloseTicket"]=yottaclose[0]["countttstartf"]
		 maticstwo["Sequest"]["CloseTicket"]=seaquestclose[0]["countttstartf"]
		 maticstwo["DQ"]["CloseTicket"]=dqclose[0]["countttstartf"]
		 nonmeccount=0
		 meccount=0
		 i=0
		 ifmecornot=FALSE
		 while i < devoncallzeoinfo.length do		  
              j=0
			  while (ifmecornot==false)&&(j < mecZEOinfo.length) do
			        if ((ifmecornot==false) && devoncallzeoinfo[i]["Date_l"]>=mecZEOinfo[j]["MECStartDate_l"]  &&  devoncallzeoinfo[i]["Date_l"]<=mecZEOinfo[j]["MECEndDate_l"])
                     ifmecornot=true					
			        calengatetime("mec",devoncallzeoinfo[i]["TimetoEngage"],maticstwo)
					meccount+=1
					if(devoncallzeoinfo[i]["TimetoFix"]<=60)
					      maticstwo["DevOncall"]["TTFMEC"] += 1 
					end
                    j=mecZEOinfo.length			
					end			        
					j+=1					
			  end  
			  if ifmecornot==false
			        calengatetime("nonmec",devoncallzeoinfo[i]["TimetoEngage"],maticstwo)
					 if(devoncallzeoinfo[i]["TimetoFix"]<=120)
                        maticstwo["DevOncall"]["TTFError"] += 1 
			         end
                    nonmeccount+=1					
			  end
			  ifmecornot=false

			 i+=1
			end
		i=0
		 ifmecornot=FALSE
		 while i < devoncallemrinfo.length do
			  j=0
			  while (ifmecornot==false)&&(j < mecEMRinfo.length) do
			        if ((ifmecornot==false) && devoncallemrinfo[i]["Date_l"]>=mecEMRinfo[j]["MECStartDate_l"]  &&  devoncallemrinfo[i]["Date_l"]<=mecEMRinfo[j]["MECEndDate_l"])
					    ifmecornot=true
			           calengatetime("mec",devoncallemrinfo[i]["TimetoEngage"],maticstwo) 
					   meccount+=1
					   if(devoncallemrinfo[i]["TimetoFix"]<=60)
					      maticstwo["DevOncall"]["TTFMEC"] += 1 
					   end
                       j=mecEMRinfo.length						   
					end
					j+=1
			  end
			  if ifmecornot==false
			           calengatetime("nonmec",devoncallemrinfo[i]["TimetoEngage"],maticstwo)
					   if(devoncallemrinfo[i]["TimetoFix"]<=120)
                          maticstwo["DevOncall"]["TTFError"] += 1 
			           end
					   nonmeccount+=1
			  end
			  ifmecornot=false

			 i+=1
			end
			
		 i=0
		 ifmecornot=FALSE
		 while i < devoncalljadinfo.length do
			  j=0
			  while (ifmecornot==false)&&(j < mecJADinfo.length) do
			        if ((ifmecornot==false) && devoncalljadinfo[i]["Date_l"]>=mecJADinfo[j]["MECStartDate_l"]  &&  devoncalljadinfo[i]["Date_l"]<=mecJADinfo[j]["MECEndDate_l"])
					ifmecornot=true
					calengatetime("mec",devoncalljadinfo[i]["TimetoEngage"],maticstwo)
					meccount+=1
                    if(devoncalljadinfo[i]["TimetoFix"]<=60)
					      maticstwo["DevOncall"]["TTFMEC"] += 1 
					end			
					j=mecJADinfo.length
					end
					j+=1
			  end
			  if ifmecornot==false
			        calengatetime("nonmec",devoncalljadinfo[i]["TimetoEngage"],maticstwo) 
					if(devoncalljadinfo[i]["TimetoFix"]<=120)
                         maticstwo["DevOncall"]["TTFError"] += 1 
			        end
                    nonmeccount+=1					
			  end
			  ifmecornot=false

		    i+=1
		   end
		   p maticstwo["DevOncall"]["TTOMEC"]
		   p maticstwo["DevOncall"]["TTFMEC"]
		   p maticstwo["DevOncall"]["TTONonMEC"]
		   p maticstwo["DevOncall"]["TTFError"]
		   p devoncalljadinfo.length+devoncallzeoinfo.length+devoncallemrinfo.length
		   p 	meccount
           p    nonmeccount		   
		   if(meccount!=0)
		   maticstwo["DevOncall"]["TTOMEC"]=((maticstwo["DevOncall"]["TTOMEC"]/(meccount).to_f)*100).round(0)
		   maticstwo["DevOncall"]["TTFMEC"]=((maticstwo["DevOncall"]["TTFMEC"]/(meccount).to_f)*100).round(0)
		   end	   
		   if(nonmeccount!=0)
		   maticstwo["DevOncall"]["TTONonMEC"]=((maticstwo["DevOncall"]["TTONonMEC"]/(nonmeccount).to_f)*100).round(0)
		   maticstwo["DevOncall"]["TTFError"]=((maticstwo["DevOncall"]["TTFError"]/(nonmeccount).to_f)*100).round(0)
		   end
		 
		   
		   maticstwo["DevOncall"]["Total"]=devoncalljadinfo.length+devoncallzeoinfo.length+devoncallemrinfo.length
		   
	
		   
		   maticstwo["DevOncall"]["TotalMEC"]=meccount
		   maticstwo["DevOncall"]["TotalNonMEC"]=nonmeccount
		   maticstwo["CM"]["AVGBFX"]=bfxinfo[0]["countModified"]
		   
          if(currentdate=='2015-11')
		  # maticstwo["RMT"]["Tickets"]=58
		  #maticstwo["RMT"]["MTIRequest"]=84
		   maticstwo["RMT"]["MTDQR"]=1
		   maticstwo["RMT"]["TTO"]=100
		   maticstwo["RMT"]["TTF"]=95
#		   maticstwo["OnBoarding"]["FileLoadingRequest"]=5
#		   maticstwo["OnBoarding"]["FileLoad"]=29
#		   maticstwo["OnBoarding"]["FileLoadSharePoint"]=5
		   maticstwo["OnBoarding"]["Within1hours"]=100
		   maticstwo["OnBoarding"]["Within2days"]=100		  
		   end
		   
		   
		   if(currentdate=='2016-01')
		  # maticstwo["RMT"]["Tickets"]=6
		   #maticstwo["RMT"]["MTIRequest"]=41
		   maticstwo["RMT"]["MTDQR"]=1
		   maticstwo["RMT"]["TTO"]=100
		   maticstwo["RMT"]["TTF"]=90
          #maticstwo["OnBoarding"]["FileLoadingRequest"]=6
          #maticstwo["OnBoarding"]["FileLoad"]=255
          #maticstwo["OnBoarding"]["FileLoadSharePoint"]=7
		   maticstwo["OnBoarding"]["Within1hours"]=100
		   maticstwo["OnBoarding"]["Within2days"]=100
           maticstwo["CM"]["TTFMTPReview"]=2
		  #maticstwo["Sequest"]["PDM"]=19
		   maticstwo["UAM"]["CRs"]=52
		   maticstwo["UAM"]["NotShared"]=17
		   maticstwo["UAM"]["BOE"]=3
		   maticstwo["UAM"]["QV"]=32
		   end
		   
		     if(currentdate=='2016-02')
			  maticstwo["CM"]["TTFMTPReview"]=3
			  #maticstwo["Sequest"]["PDM"]=8
			 end
			 if(currentdate=='2016-03')
			  maticstwo["CM"]["TTFMTPReview"]=2
			  #maticstwo["Sequest"]["PDM"]=34
			  maticstwo["Yotta"]["MTP"]=0		  
			 end
			 if(currentdate=='2016-04')
			  maticstwo["CM"]["TTFMTPReview"]=3
			  #maticstwo["Sequest"]["PDM"]=34
			  maticstwo["Yotta"]["MTP"]=0		  
			 end
		  render json: maticstwo.to_json
	  end
	  
	   def  calengatetime(mecornot,duration,maticstwo)
	       if mecornot=="mec"
		      case                    
			  when duration<=3                        then maticstwo["DevOncall"]["TTOMEC"] += 1
              end			  
		   else
		      case 
			  when duration<=10                          then maticstwo["DevOncall"]["TTONonMEC"] += 1
		      end
		   end
	  end
end
