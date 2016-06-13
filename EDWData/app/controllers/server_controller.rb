class ServerController < ApplicationController
	def index 
	
	   
		view = params[:View];
		pf = params[:Environment];
		serverjs =Hash.new
		temphash =Hash.new
		
		
		privious90time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 90).strftime("%Y-%m-%d %H:%M:%S")
 		  mecZEOinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">=\'#{privious90time}\' and \"Environment\"='ZEO'")
	      mecEMRinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">=\'#{privious90time}\' and \"Environment\"='EMR'")
		  mecJADinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">=\'#{privious90time}\' and \"Environment\"='EMR'")
		  ticketinfo=Oncallissuetracker.find_by_sql("select \"Date\" ,\"TimetoFix\",\"Environment\"from oncallissuetrackers where \"Date\">=\'#{privious90time}\'")
		  needhelpinfo=Oncallissuetracker.find_by_sql("select count(\"EscalatetoDevteam\") as \"needsmehelp\",\"EscalatetoDevteam\" from oncallissuetrackers where \"Date\">=\'#{privious90time}\' group by \"EscalatetoDevteam\" order by \"EscalatetoDevteam\"")
		  i=0
		  ticketarraytemp=Array.new
		  sumofticket=0
		  while i <7  do
		     weekend=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).wday-49+i*7+1).strftime("%Y-%m-%d %H:%M:%S")
		     weekendbegin=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).wday-49+(i+1)*7).strftime("%Y-%m-%d %H:%M:%S")
		     ticket12weekinfo=Oncallissuetracker.find_by_sql("select  count(*) as \"countticket\" from oncallissuetrackers where \"Date\">=\'#{weekend}\' and \"Date\"<=\'#{weekendbegin}\'")
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

		  ticketduration=Hash.new
		  needsmehelp=Hash.new

  
		  ticketduration["name"]="Ticket Life Duration"
		  ticketduration["MEC"]=mecduration	
          ticketduration["NonMEC"]=nonmecduration
		  needsmehelp["name"]="Need SME Help"
		  if(needhelpinfo.length==1)
		  needsmehelp["NO"]=needhelpinfo[0]["needsmehelp"]
		  else
		  needsmehelp["YES"]=needhelpinfo[1]["needsmehelp"]
		  needsmehelp["NO"]=needhelpinfo[0]["needsmehelp"]
		  end	  

          serverjs["ticketDuration"]=ticketduration
          serverjs["ticket"]=tickethash		  
          serverjs["help"]=needsmehelp	
	  
		  i=0
		  ifmecornot=false
		 
		   i=0
		   while i < ticketinfo.length do		   
		    if(ticketinfo[i]["Environment"]=="ZEO")
              j=0
			  while j < mecZEOinfo.length do
			        if (ifmecornot==false && ticketinfo[i]["Date"]>=mecZEOinfo[j]["MECStartDate"]  &&  ticketinfo[i]["Date"]<=mecZEOinfo[j]["MECEndDate"])
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
			        if (ifmecornot==false && ticketinfo[i]["Date"]>=mecEMRinfo[j]["MECStartDate"]  &&  ticketinfo[i]["Date"]<=mecEMRinfo[j]["MECEndDate"])
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
			        if (ifmecornot==false && ticketinfo[i]["Date"]>=mecJADinfo[j]["MECStartDate"]  &&  ticketinfo[i]["Date"]<=mecJADinfo[j]["MECEndDate"])
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
		
		
		serverinfo =Array.new
		if view == "Day" then
			privious30time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 30).strftime("%Y-%m-%d %H:%M:%S")
			emrinfo=Oncallissuetracker.find_by_sql("select \"MasterID\",\"Date\",\"TimetoEngage\" ,\"Time_that_AO_emailed_oncall\" ,\"TimetoFix\" ,\"TimetoReExec\" ,\"TimeFailure\", \"TimeSucceeded\", \"ErrorDetails\",\"Action\" from oncallissuetrackers where \"Environment\"=\'#{pf}\' and \"Date\">\'#{privious30time}\'")
		    #emrinfo = Oncallissuetracker.select('MasterID','Date','TimetoEngage','Time_that_AO_emailed_oncall','TimetoFix','TimetoReExec','TimeFailure','TimeSucceeded','ErrorDetails','Action').where(Environment: pf)
			timeavg = Oncallissuetracker.find_by_sql("select avg(\"Time_that_AO_emailed_oncall\") as AO1ExceedAvg ,avg(\"TimetoReExec\") as AO2ExceedAvg  from oncallissuetrackers where \"Environment\"=\'#{pf}\' and \"Date\">\'#{privious30time}\'")
			#timeavg = Oncallissuetracker.select(avg('Time_that_AO_emailed_oncall') as AO1ExceedAvg,avg'TimetoEngage') as OC1ExceedAvg,avg('TimetoReExec') as AO2ExceedAvg,avg('TimetoFix') as OC2ExceedAvg).where(Environment: pf)   ,avg(\"TimetoFix\") as OC2ExceedAvg 
			i=0

			while i < emrinfo.length do
				detailinfo =Hash.new
				detailinfo["name"]=emrinfo[i]["MasterID"].to_s
				detailinfo["x"]=emrinfo[i]["Date"].strftime("%Y-%m-%d")
				detailinfo["start_time"]=emrinfo[i]["TimeFailure"].strftime("%Y-%m-%d %H:%M:%S")
				detailinfo["end_time"]=emrinfo[i]["TimeSucceeded"].strftime("%Y-%m-%d %H:%M:%S")
				detailinfo["AO1"]=emrinfo[i]["Time_that_AO_emailed_oncall"]
				detailinfo["OC1"]=emrinfo[i]["TimetoEngage"]
				detailinfo["AO2"]=emrinfo[i]["TimetoReExec"]
				detailinfo["OC2"]=emrinfo[i]["TimetoFix"]
				detailinfo["AO1ExceedAvg"]=aocomparewithave(emrinfo[i]["Time_that_AO_emailed_oncall"],timeavg[0]["ao1exceedavg"])
				detailinfo["OC1ExceedAvg"]=occomparewithave(emrinfo[i]["TimetoEngage"],3)
				detailinfo["AO2ExceedAvg"]=aocomparewithave(emrinfo[i]["TimetoReExec"],timeavg[0]["ao2exceedavg"])
				detailinfo["OC2ExceedAvg"]=occomparewithave(emrinfo[i]["TimetoFix"],30)
				detailinfo["error_detail"]=emrinfo[i]["ErrorDetails"]
				detailinfo["action"]=emrinfo[i]["Action"]
				serverinfo[i]=detailinfo
				i+=1
			end
			temphash["data"]=serverinfo	 
			serverjs["series"]=temphash	 
			render json: serverjs.to_json
		elsif view == "Year" then
			currentYearFirstDay = DateTime.parse((Time.new).strftime("%Y") + '-1-1 00:00:00').strftime("%Y-%m-%d %H:%M:%S");
			emrinfo=Oncallissuetracker.find_by_sql("select * from (select EXTRACT(YEAR FROM \"Date\") as onlyYear, min(\"Date\") as test ,sum(\"TimetoEngage\") as engage ,sum(\"Time_that_AO_emailed_oncall\") as ao, sum(\"TimetoFix\") as fix, sum(\"TimetoReExec\") as exec from oncallissuetrackers where \"Environment\"=\'#{pf}\' and \"Date\">\'#{currentYearFirstDay}\' group by EXTRACT(YEAR FROM \"Date\")) a order by onlyYear" );
			i=0;
			while i < emrinfo.length do
				detailinfo =Hash.new
				# p "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
				# p emrinfo
				# p emrinfo[i]["onlyYear"]
				# p emrinfo[i]["test"]
				# p emrinfo[i]["test"].strftime("%Y")
				# p emrinfo[i]["rrr"]
				# p emrinfo[i]["onlyYear"]
				# p emrinfo[i][3]
				# p emrinfo[i][4]
				# p "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
				detailinfo["x"]=emrinfo[i]["test"].strftime("%Y")
				detailinfo["AO1"]=emrinfo[i]["ao"]
				detailinfo["OC1"]=emrinfo[i]["engage"]
				detailinfo["AO2"]=emrinfo[i]["exec"]
				detailinfo["OC2"]=emrinfo[i]["fix"]
				serverinfo[i]=detailinfo
				i+=1
			end
			temphash["data"]=serverinfo	 
			serverjs["series"]=temphash	 
			render json: serverjs.to_json
		elsif view == "Month" then
			last6mStart = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 00:00:00') << 6).strftime("%Y-%m-%d %H:%M:%S");
			last6mEnd = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 23:59:59') - 1).strftime("%Y-%m-%d %H:%M:%S");
			puts last6mStart
			puts last6mEnd
			emrinfo=Oncallissuetracker.find_by_sql("select * from (select EXTRACT(YEAR FROM \"Date\") * 100 + EXTRACT(MONTH FROM \"Date\") as month, min(\"Date\") as test ,sum(\"TimetoEngage\") as engage ,sum(\"Time_that_AO_emailed_oncall\") as ao, sum(\"TimetoFix\") as fix, sum(\"TimetoReExec\") as exec from oncallissuetrackers where \"Environment\"=\'#{pf}\' and \"Date\" between \'#{last6mStart}\' and \'#{last6mEnd}\' group by EXTRACT(YEAR FROM \"Date\") * 100 + EXTRACT(MONTH FROM \"Date\")) a order by test" );
			i=0;
			while i < emrinfo.length do
				detailinfo =Hash.new
				# p "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
				# p emrinfo
				# p emrinfo[i]["month"]
				# p emrinfo[i]["test"]
				# p emrinfo[i]["test"].strftime("%Y-%m")
				# p emrinfo[i]["rrr"]
				# p emrinfo[i]["onlyYear"]
				# p emrinfo[i][3]
				# p emrinfo[i][4]
				# p "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
				detailinfo["x"]=emrinfo[i]["test"].strftime("%h, %Y")
				detailinfo["AO1"]=emrinfo[i]["ao"]
				detailinfo["OC1"]=emrinfo[i]["engage"]
				detailinfo["AO2"]=emrinfo[i]["exec"]
				detailinfo["OC2"]=emrinfo[i]["fix"]
				serverinfo[i]=detailinfo
				i+=1
			end
			temphash["data"]=serverinfo	 
			serverjs["series"]=temphash	 
			render json: serverjs.to_json
		elsif view == "Week" then
			last12wStart = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).strftime("%u").to_i - 12*7 + 1).strftime("%Y-%m-%d %H:%M:%S");
			last12wEnd = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 23:59:59') - (Time.new).strftime("%u").to_i).strftime("%Y-%m-%d %H:%M:%S");
			emrinfo=Oncallissuetracker.find_by_sql(" select min(\"Date\") as test, sum(ao1) as ao1, sum(ao2) as ao2, sum(oc1) as oc1, sum(oc2) as oc2 from (select \"Date\", trunc(extract( day from (\"Date\" - \'#{last12wStart}\')) /7) as week, \"TimetoEngage\" as oc1, \"Time_that_AO_emailed_oncall\" as ao1, \"TimetoFix\" as oc2, \"TimetoReExec\" as ao2 from oncallissuetrackers where \"Environment\"=\'#{pf}\' and \"Date\" between \'#{last12wStart}\' and \'#{last12wEnd}\') a  group by week order by week " );
			i=0;
			while i < emrinfo.length do
				detailinfo =Hash.new
				p "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
				p emrinfo[i]["week"]
				p emrinfo[i]["test"]
				p emrinfo[i]["test"].strftime("%u").to_i
				p DateTime.parse(emrinfo[i]["test"].strftime("%Y-%m-%d")+ ' 00:00:00') - emrinfo[i]["test"].strftime("%u").to_i
				p "zzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz";
				weekMonday = DateTime.parse(emrinfo[i]["test"].strftime("%Y-%m-%d")+ ' 00:00:00') - emrinfo[i]["test"].strftime("%u").to_i + 1
				weekSunday = weekMonday + 6;
				displayMonday = weekMonday.strftime("%h, %d")
				displaySunday = weekSunday.strftime("%h, %d")
				detailinfo["x"]="#{displayMonday}~#{displaySunday}"
				detailinfo["AO1"]=emrinfo[i]["ao1"]
				detailinfo["OC1"]=emrinfo[i]["oc1"]
				detailinfo["AO2"]=emrinfo[i]["ao2"]
				detailinfo["OC2"]=emrinfo[i]["oc2"]
				serverinfo[i]=detailinfo
				i+=1
			end
			temphash["data"]=serverinfo	 
			serverjs["series"]=temphash	 
			render json: serverjs.to_json
		end
	end

	def aocomparewithave(needcomparetime,avgtime)
	return    case 
		       when  needcomparetime>avgtime    then true
		       when  needcomparetime<avgtime    then false
		       end    
	end

	def occomparewithave(needcomparetime,basictime)
	return    case 
		       when  needcomparetime>basictime    then true
		       when  needcomparetime<basictime    then false
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
