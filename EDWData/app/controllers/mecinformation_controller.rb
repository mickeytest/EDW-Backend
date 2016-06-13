class MecinformationController < ApplicationController
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
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((jaddatascope[0]["MECStartDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
               datejadend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
			   dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
               end	
               
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((emrdatascope[0]["MECStartDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
               dateemrend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
               dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))				   
               end	
			   
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((zeodatascope[0]["MECStartDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
               datezeoend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
			   dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
               end	
               			   
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
		   jadmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{jaddatascope[i]["Year"]}\'  and \"Month\"=\'#{jaddatascope[i]["Month"]}\'  and \"Environment\"='JAD'")
		   first=false
		 end
		 i+=1
   end
   
   first=true
   i=0
   while i<emrdatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((emrdatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   emrmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{emrdatascope[i]["Year"]}\'  and \"Month\"=\'#{emrdatascope[i]["Month"]}\'  and \"Environment\"='EMR'")
		   first=false
		 end
		 i+=1
   end
   
     first=true
    i=0
   while i<zeodatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((zeodatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   zeomecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{zeodatascope[i]["Year"]}\'  and \"Month\"=\'#{zeodatascope[i]["Month"]}\'  and \"Environment\"='ZEO'")
		   first=false
		 end
		 i+=1
   end

	datejadstart=(jadmecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d %H:%M:%S")
	dateemrstart=(emrmecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d %H:%M:%S")
	datezeostart=(zeomecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d %H:%M:%S")
	datestart=(zeomecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d %H:%M:%S")
    dateend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	datejadend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	dateemrend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	datezeoend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
end 

if((params[:from] !=nil) && (params[:to]!=nil))
 datejadstart=params[:from]
 dateemrstart=params[:from]
 #datezeostart=params[:from]
 datejadend=params[:to]
 dateemrend=params[:to]
 datezeoend=params[:to]
 datestart=params[:from]
 dateend==params[:to]
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
		
		  rollupjadinfo=Dailyrolluptime.find_by_sql("select \"ElapseTime\",\"RollupDate_l\",\"Start_TS_l\",\"End_TS_l\",\"Server\" from  dailyrolluptimes where \"RollupDate_l\">\'#{datejadstart}\' and \"RollupDate_l\"<=\'#{datejadend}\' and \"Server\"='JAD' and \"ElapseTime\" is not null ")	      
		  rollupzeoinfo=Dailyrolluptime.find_by_sql("select \"ElapseTime\",\"RollupDate_l\",\"Start_TS_l\",\"End_TS_l\",\"Server\" from  dailyrolluptimes where \"RollupDate_l\">\'#{datezeostart}\' and \"RollupDate_l\"<=\'#{datezeoend}\' and \"Server\"='ZEO' and \"ElapseTime\" is not null ")	      
		  rollupemrinfo=Dailyrolluptime.find_by_sql("select \"ElapseTime\",\"RollupDate_l\",\"Start_TS_l\",\"End_TS_l\",\"Server\" from  dailyrolluptimes where \"RollupDate_l\">\'#{dateemrstart}\' and \"RollupDate_l\"<=\'#{dateemrend}\' and \"Server\"='EMR' and \"ElapseTime\" is not null ")	      
		  mecZEOinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{datezeostart}\' and \"MECStartDate_l\"<=\'#{datezeoend}\' and \"Environment\"='ZEO'")
	      mecEMRinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{dateemrstart}\'  and \"MECStartDate_l\"<=\'#{dateemrend}\' and \"Environment\"='EMR'")
		  mecJADinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{datejadstart}\' and \"MECStartDate_l\"<=\'#{datejadend}\' and \"Environment\"='JAD'")
		  ticketinfo=Oncallissuetracker.find_by_sql("select \"Date_l\" ,\"TimetoFix\",\"Environment\"from oncallissuetrackers where \"Date_l\">=\'#{datestart}\' and \"Date\"<\'#{dateend}\'")
		  needhelpinfo=Oncallissuetracker.find_by_sql("select count(\"EscalatetoDevteam\") as \"needsmehelp\",\"EscalatetoDevteam\" from oncallissuetrackers where \"Date\">=\'#{datestart}\' and \"Date\"<\'#{dateend}\' group by \"EscalatetoDevteam\" order by \"EscalatetoDevteam\"")
		  i=0
		  ticketarraytemp=Array.new
		  sumofticket=0
		  while i <7  do
		     weekend=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).wday-49+i*7+1).strftime("%Y-%m-%d %H:%M:%S")
		     weekendbegin=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).wday-49+(i+1)*7).strftime("%Y-%m-%d %H:%M:%S")
		     ticket12weekinfo=Oncallissuetracker.find_by_sql("select  count(*) as \"countticket\" from oncallissuetrackers where \"Date_l\">=\'#{weekend}\' and \"Date_l\"<=\'#{weekendbegin}\'")
		     weekticket=Hash.new
		     weekticket["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).wday-49+i*7+1).strftime("%b-%d")+'~'+(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).wday-49+(i+1)*7).strftime("%b-%d")
             weekticket["y"]=ticket12weekinfo[0]["countticket"]
             ticketarraytemp[i]=weekticket
             sumofticket+=ticket12weekinfo[0]["countticket"]		 
             i+=1			 
		  end
		  tickethash=Hash.new
		  tickethash["name"]="Ticket Total"
		  tickethash["total"]=sumofticket
		  tickethash["avg"]=sumofticket/7
		  tickethash["data"]=ticketarraytemp
		  mecarray=Array.[](0,0,0)
		  nonmecarray=Array.[](0,0,0)
		  mecdelaytime=Array.[](0,0,0)
		  nonmecdelaytime=Array.[](0,0,0)
		  mecduration=Array.[](0,0)
		  nonmecduration=Array.[](0,0)
		  rollupmetric=Hash.new
		  rollupdelay=Hash.new
		  ticketduration=Hash.new
		  needsmehelp=Hash.new
		  rollupmetric["name"]="rollup run time"
		  rollupmetric["mectitleinfo"]=mectitleinfo
		  rollupmetric["nonmectitleinfo"]=""
		  mectotal=0
          nonmectotal=0
		  rollupmetric["MEC"]=mecarray
         	  
          rollupmetric["NonMEC"]=nonmecarray
		
          rollupdelay["name"]="Rollup Delay Time"
		
		  rollupdelay["mectitleinfo"]=mectitleinfo
		  rollupdelay["nonmectitleinfo"]=""
		  
          rollupdelay["MEC"]=mecdelaytime	  
          rollupdelay["NonMEC"]=nonmecdelaytime
		  
		  ticketduration["name"]="Ticket Life Duration"
		  
		  ticketduration["mectitleinfo"]=mectitleinfo
		  ticketduration["nonmectitleinfo"]=""
		  
		  ticketduration["MEC"]=mecduration	
		
          ticketduration["NonMEC"]=nonmecduration
		  
		  needsmehelp["name"]="Need SME Help"
		  if(needhelpinfo.length==1)
		  needsmehelp["YES"]=0
		  needsmehelp["NO"]=needhelpinfo[0]["needsmehelp"]
		  elsif(needhelpinfo.length==0)
		  needsmehelp["YES"]=0  
		  needsmehelp["NO"]=0	  
		  else
		  needsmehelp["YES"]=needhelpinfo[0]["needsmehelp"]		  
		  needsmehelp["NO"]=needhelpinfo[0]["needsmehelp"]
		  end
     	  
          prorollupmatic["rollupRun"]=rollupmetric
          prorollupmatic["rollupDelay"]=rollupdelay	
          prorollupmatic["ticketDuration"]=ticketduration
          prorollupmatic["ticket"]=tickethash		  
          prorollupmatic["help"]=needsmehelp	
		  
        if(params[:env]=='ZEO' || params[:env]=='ALL')		
		  i=0
		  ifmecornot=false		  
		  while i < rollupzeoinfo.length do
		      p rollupzeoinfo[i]["RollupDate_l"].strftime("%Y-%m-%d %H:%M:%S")
              j=0
			  while j < mecZEOinfo.length do
			        if (ifmecornot==false && rollupzeoinfo[i]["RollupDate_l"]>=mecZEOinfo[j]["MECStartDate_l"]  &&  rollupzeoinfo[i]["RollupDate_l"]<=mecZEOinfo[j]["MECEndDate_l"])
					    p 'xxxx'
						ifmecornot=true	
					    calruntime("mec",rollupzeoinfo[i]["ElapseTime"],rollupmetric)	                              						                       					
                        calrollupdelaytime("mec",rollupzeoinfo[i]["Start_TS_l"]-DateTime.parse(rollupzeoinfo[i]["Start_TS_l"].strftime("%Y-%m-%d 03:00:00")) ,rollupdelay)						
			            j=mecZEOinfo.length
						mectotal+=1
					end			        
					j+=1					
			  end  
			  if ifmecornot==false	 
			     calruntime("nonmec",rollupzeoinfo[i]["ElapseTime"],rollupmetric)					
				 calrollupdelaytime("nonmec",rollupzeoinfo[i]["Start_TS_l"]-DateTime.parse(rollupzeoinfo[i]["Start_TS_l"].strftime("%Y-%m-%d 03:00:00")) ,rollupdelay)
			     nonmectotal+=1
			  end
			  ifmecornot=false	
			  i+=1
		   end
		 end 
		 
		if(params[:env]=='EMR' || params[:env]=='ALL')
		   i=0
		   ifmecornot=false		
		   while i < rollupemrinfo.length do
			  j=0
			  while j < mecEMRinfo.length do
			        if (ifmecornot==false && rollupemrinfo[i]["RollupDate_l"]>=mecEMRinfo[j]["MECStartDate_l"]  &&  rollupemrinfo[i]["RollupDate_l"]<=mecEMRinfo[j]["MECEndDate_l"])
					    ifmecornot=true	
					    calruntime("mec",rollupemrinfo[i]["ElapseTime"],rollupmetric)
						calrollupdelaytime("mec",rollupemrinfo[i]["Start_TS_l"]-DateTime.parse(rollupemrinfo[i]["Start_TS_l"].strftime("%Y-%m-%d 03:00:00"))  ,rollupdelay)
			            j=mecEMRinfo.length
						mectotal+=1
					end
					j+=1
			  end
			  if ifmecornot==false 
			     calruntime("nonmec",rollupemrinfo[i]["ElapseTime"],rollupmetric)
				 calrollupdelaytime("nonmec",rollupemrinfo[i]["Start_TS_l"]-DateTime.parse(rollupemrinfo[i]["Start_TS_l"].strftime("%Y-%m-%d 03:00:00"))   ,rollupdelay)
			     nonmectotal+=1
			  end
			  ifmecornot=false	
			    i+=1
           end
		 end 
		   
		 if(params[:env]=='JAD' || params[:env]=='ALL')		
       	   i=0
		   ifmecornot=false		
		   while i < rollupjadinfo.length do   
			  j=0
			  while j < mecJADinfo.length do
			        if (ifmecornot==false && rollupjadinfo[i]["RollupDate_l"]>=mecJADinfo[j]["MECStartDate_l"]  &&  rollupjadinfo[i]["RollupDate_l"]<=mecJADinfo[j]["MECEndDate_l"])
					    ifmecornot=true
					    calruntime("mec",rollupjadinfo[i]["ElapseTime"],rollupmetric)
						calrollupdelaytime("mec",rollupjadinfo[i]["Start_TS_l"]-DateTime.parse(rollupjadinfo[i]["Start_TS_l"].strftime("%Y-%m-%d 03:00:00")),rollupdelay)
						j=mecJADinfo.length
						mectotal+=1
					end
					j+=1
			  end
			  if ifmecornot==false 
			     calruntime("nonmec",rollupjadinfo[i]["ElapseTime"],rollupmetric)
				 calrollupdelaytime("nonmec",rollupjadinfo[i]["Start_TS_l"]-DateTime.parse(rollupjadinfo[i]["Start_TS_l"].strftime("%Y-%m-%d 03:00:00")),rollupdelay)			     
			     nonmectotal+=1
			  end
			  ifmecornot=false	
		    i+=1
		   end
         end
		   rollupdelay["mectotal"]=mectotal
		  rollupdelay["nonmectotal"]=nonmectotal
		   
		   i=0
		   while i < ticketinfo.length do		   
		    if(ticketinfo[i]["Environment"]=="ZEO")
              j=0
			  while j < mecZEOinfo.length do
			        if (ifmecornot==false && ticketinfo[i]["Date_l"]>=mecZEOinfo[j]["MECStartDate_l"]  &&  ticketinfo[i]["Date_l"]<=mecZEOinfo[j]["MECEndDate_l"])
                    ifmecornot=true					
			        calticketduration("mec",ticketinfo[i]["TimetoFix"],ticketduration)
                    j=mecZEOinfo.length					
					end			        
					j+=1					
			  end  
			  if ifmecornot==false 
			        calticketduration("nonmec",ticketinfo[i]["TimetoFix"],ticketduration) 
			  end
			  ifmecornot=false
			end
			if(ticketinfo[i]["Environment"]=="EMR")
			  j=0
			  while j < mecEMRinfo.length do
			        if (ifmecornot==false && ticketinfo[i]["Date_l"]>=mecEMRinfo[j]["MECStartDate_l"]  &&  ticketinfo[i]["Date_l"]<=mecEMRinfo[j]["MECEndDate_l"])
					   ifmecornot=true	
			           calticketduration("mec",ticketinfo[i]["TimetoFix"],ticketduration) 
                       j=mecEMRinfo.length					   
					end
					j+=1
			  end
			  if ifmecornot==false 
			        calticketduration("nonmec",ticketinfo[i]["TimetoFix"],ticketduration)
			  end
			  ifmecornot=false
			end
		    if(ticketinfo[i]["Environment"]=="JAD")
			  j=0
			  while j < mecJADinfo.length do
			        if (ifmecornot==false && ticketinfo[i]["Date_l"]>=mecJADinfo[j]["MECStartDate_l"]  &&  ticketinfo[i]["Date_l"]<=mecJADinfo[j]["MECEndDate_l"])
					ifmecornot=true	
					calticketduration("mec",ticketinfo[i]["TimetoFix"],ticketduration)  
					j=mecJADinfo.length
					end
					j+=1
			  end
			  if ifmecornot==false  
			        calticketduration("nonmec",ticketinfo[i]["TimetoFix"],ticketduration)  
			  end
			  ifmecornot=false
			  end
		    i+=1
		   end
		  render json: prorollupmatic.to_json
	  end
	  def  calruntime(mecornot,elapesetime,rollupmetric)
	       if mecornot=="mec"
		      case 
		      when elapesetime<=8.5                     then rollupmetric["MEC"][0] += 1
			  when elapesetime>8.5 &&  elapesetime<=10  then rollupmetric["MEC"][1] += 1
			  when elapesetime>10                       then rollupmetric["MEC"][2] += 1		  
		      end
		   else
		      case
		      when elapesetime<=8.5                     then rollupmetric["NonMEC"][0] += 1
			  when elapesetime>8.5 &&  elapesetime<=10  then rollupmetric["NonMEC"][1] += 1
			  when elapesetime>10                       then rollupmetric["NonMEC"][2] += 1
		      end
			end
	  end 
	  def  calrollupdelaytime(mecornot,delaytime,rollupdelay)
	       if mecornot=="mec"
		      case 
		      when delaytime>=180  &&  delaytime<=1200    then rollupdelay["MEC"][0] += 1
			  when delaytime>1200 &&  delaytime<=2340     then rollupdelay["MEC"][1] += 1
			  when delaytime>=2400                        then rollupdelay["MEC"][2] += 1		  
		      end
		   else
		      case 
		      when delaytime>=180  &&  delaytime<=1200      then rollupdelay["NonMEC"][0] += 1
			  when delaytime>1200 &&  delaytime<=2340       then rollupdelay["NonMEC"][1] += 1
			  when delaytime>=2400                          then rollupdelay["NonMEC"][2] += 1	  
		      end
		   end
	  end
	  def  calticketduration(mecornot,duration,ticketduration)
	       if mecornot=="mec"
		      case 
		      when duration>=30                         then ticketduration["MEC"][1] += 1
			  when duration<30                          then ticketduration["MEC"][0] += 1	 
              end			  
		   else
		      case 
		      when duration>=30                         then ticketduration["NonMEC"][1] += 1
			  when duration<30                          then ticketduration["NonMEC"][0] += 1 
		      end
		   end
	  end
end

