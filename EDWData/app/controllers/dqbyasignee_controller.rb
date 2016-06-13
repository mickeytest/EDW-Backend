class DqbyasigneeController < ApplicationController
     def index
	     	      currentdate = params[:month];
		  jaddatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='JAD' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
          emrdatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='EMR' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
		  zeodatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='ZEO' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")

 if(currentdate!=nil)
		  #datestart=DateTime.parse(currentdate+ '-01').strftime("%Y-%m-%d %H:%M:%S")
		  #dateend=(DateTime.parse((DateTime.parse(currentdate+ '-01')).strftime("%Y-%m") + '-1 00:00:00') >>1).strftime("%Y-%m-%d %H:%M:%S");		             
		  datestartyear=(DateTime.parse(currentdate+ '-01').strftime("%Y")).to_i
	      datestartmonth=(DateTime.parse(currentdate+ '-01').strftime("%m")).to_i 
	       
		   if(datestartmonth!=1)
               mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"= \'#{datestartmonth}\' group by \"Environment\"")
	           mecendinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\'-1 group by \"Environment\"")
           else
	           mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\")  as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\' group by \"Environment\"")
	           mecendinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear-1}\'  and \"Month\"=12 group by \"Environment\"")
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
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((jaddatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               datejadend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
			   dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
               end	
               
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((emrdatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               dateemrend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
               dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))				   
               end	
			   
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((zeodatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               datezeoend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
			   dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
               end	
=end              			   
=begin	 
  	  else
          datestart=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 90).strftime("%Y-%m-%d %H:%M:%S")
		  dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
=end		  
       end
		   prorollupmatic=Hash.new	


#mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Year\"=\'#{zeodatascope[1]["Year"]}\'  and \"Month\"=\'#{zeodatascope[1]["Month"]}\'")


if(currentdate==nil)
     first=true
    i=0
   while i<jaddatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((jaddatascope[i]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   jadmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{jaddatascope[i]["Year"]}\'  and \"Month\"=\'#{jaddatascope[i]["Month"]}\'  and \"Environment\"='JAD'")
		   first=false
		 end
		 i+=1
   end
   
   first=true
   i=0
   while i<emrdatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((emrdatascope[i]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   emrmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{emrdatascope[i]["Year"]}\'  and \"Month\"=\'#{emrdatascope[i]["Month"]}\'  and \"Environment\"='EMR'")
		   first=false
		 end
		 i+=1
   end
   
     first=true
    i=0
   while i<zeodatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((zeodatascope[i]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   zeomecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{zeodatascope[i]["Year"]}\'  and \"Month\"=\'#{zeodatascope[i]["Month"]}\'  and \"Environment\"='ZEO'")
		   first=false
		 end
		 i+=1
   end

	datejadstart=(jadmecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d %H:%M:%S")
	dateemrstart=(emrmecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d %H:%M:%S")
	datezeostart=zeomecstartinfo[0]["currentstarttime"]
	datestart=(zeomecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d %H:%M:%S")
    dateend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	datejadend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	dateemrend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	datezeoend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
end 

if((params[:from] !=nil) && (params[:to]!=nil))
 datejadstart=params[:from]
 dateemrstart=params[:from]
 datezeostart=(DateTime.parse((params[:from]))-1)
 #datezeostart=params[:from]
 datejadend=params[:to]
 dateemrend=params[:to]
 datezeoend=params[:to]
 datestart=params[:from]
 dateend==params[:to]
end

mectitleinfo=nil
nonmectitleinfo=nil
if( DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) < DateTime.parse((zeodatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S")) )
     prorollupmatic["mindate"]="2015-08"
	 prorollupmatic["maxdate"]=zeodatascope[1]["Year"].to_s + "-" + zeodatascope[1]["Month"].to_s
	 mectitleinfo=""
elsif(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S")))
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
if(params[:to] !=nil)
tttend=  (DateTime.parse(params[:to]+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00")
elsif(currentdate!=nil)
tttend=  (DateTime.parse((datezeoend).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00")
else
tttend= DateTime.parse(datezeoend).strftime("%Y-%m-%d 24:00:00")
end
  
 tttstart=(DateTime.parse((datezeostart).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00") 

 dqticketapj=HpsmYotta.find_by_sql("select \"Assignee\",count(*) as \"countttf\"  from  hpsm_dqs where  \"Close_Time_l\">\'#{tttstart}}\' and \"Close_Time_l\"<=\'#{tttend}\' 
			      and \"Assignee\"  in ( 'xiao-yang.liu@hpe.com',
 'dai-jun.lv@hpe.com',
 'mooi@hpe.com',
 'xiao.zhang@hpe.com',
 'yi-wen.chen@hpe.com' ) group by \"Assignee\"")
 
 
 
  dqticketams=HpsmYotta.find_by_sql("select \"Assignee\",count(*) as \"countttf\"  from  hpsm_dqs where  \"Close_Time_l\">\'#{tttstart}}\' and \"Close_Time_l\"<=\'#{tttend}\' 
			      and \"Assignee\" not  in ('patrick.sigourney@hpe.com', 
                 'dana.orr@hpe.com', 
                 'grace.chao@hpe.com', 
                 'annmarie.mcginley@hpe.com',
				 'xiao-yang.liu@hpe.com',
                 'dai-jun.lv@hpe.com',
                 'mooi@hpe.com',
                 'xiao.zhang@hpe.com',
                 'yi-wen.chen@hpe.com') group by \"Assignee\"")
  dqassign={}
  	dqassign[:dqbyassignee]={} 
	dqassign[:dqbyassignee][:data]=[]

	dqassign[:dqbyassignee][:drilldown]=[]
	
    dqamshash={}
	dqamshash["id"]="AMS"
	dqamshash["data"]=[]
	
	dqapjhash={}
	dqapjhash["id"]="APJ"
	dqapjhash["data"]=[]
 
    apjinfo=Array.new
	apjcount=0
	amscount=0
    i=0
	while i<dqticketapj.length do
	      apjcount+=dqticketapj[i]["countttf"]
		  dqapjhash["data"].push([dqticketapj[i]["Assignee"],dqticketapj[i]["countttf"]])		
	i+=1
	end
	
	
	i=0
	while i<dqticketams.length do
	      amscount+=dqticketams[i]["countttf"]
		  dqamshash["data"].push([dqticketams[i]["Assignee"],dqticketams[i]["countttf"]])
	i+=1
	end
 

    dqassign[:dqbyassignee][:data]=[
	{:name=>"AMS",:y=>amscount,:drilldown=>"AMS"},
	{:name=>"APJ",:y=>apjcount,:drilldown=>"APJ"},	
	]
	
	dqassign[:dqbyassignee][:drilldown].push(dqamshash,dqapjhash)
	render json:dqassign.to_json
	 end
end
