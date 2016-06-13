class MecinformationController < ApplicationController
      def index
	      privious90time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 90).strftime("%Y-%m-%d %H:%M:%S")
          rollupinfo=Dailyrolluptime.find_by_sql("select \"ElapseTime\",\"RollupDate\",\"Start_TS\",\"End_TS\",\"Server\" from  dailyrolluptimes where \"RollupDate\">\'#{privious90time}\' and \"ElapseTime\" is not null ")	      
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
		  rollupmetric=Hash.new
		  rollupdelay=Hash.new
		  ticketduration=Hash.new
		  needsmehelp=Hash.new
		  rollupmetric["name"]="rollup run time"
		  rollupmetric["MEC"]=mecarray	
          rollupmetric["NonMEC"]=nonmecarray
          rollupdelay["name"]="Rollup Delay Time"
		  rollupdelay["MEC"]=mecdelaytime	
          rollupdelay["NonMEC"]=nonmecdelaytime
		  ticketduration["name"]="Ticket Life Duration"
		  ticketduration["MEC"]=mecduration	
          ticketduration["NonMEC"]=nonmecduration
		  needsmehelp["name"]="Need SME Help"
		  needsmehelp["YES"]=needhelpinfo[1]["needsmehelp"]
		  needsmehelp["NO"]=needhelpinfo[0]["needsmehelp"]
          prorollupmatic=Hash.new		  
          prorollupmatic["rollupRun"]=rollupmetric
          prorollupmatic["rollupDelay"]=rollupdelay	
          prorollupmatic["ticketDuration"]=ticketduration
          prorollupmatic["ticket"]=tickethash		  
          prorollupmatic["help"]=needsmehelp	  
		  i=0
		  ifmecornot=false
		  while i < rollupinfo.length do
		    if(rollupinfo[i]["Server"]=="ZEO")
              j=0
			  while j < mecZEOinfo.length do
			        if (ifmecornot==false && rollupinfo[i]["RollupDate"]>=mecJADinfo[j]["MECStartDate"]  &&  rollupinfo[i]["RollupDate"]<=mecJADinfo[j]["MECEndDate"])
					    ifmecornot=true	
					    calruntime("mec",rollupinfo[i]["ElapseTime"],rollupmetric)	                              						                       					
                        calrollupdelaytime("mec",rollupinfo[i]["Start_TS"]-Time.utc(rollupinfo[i]["Start_TS"].year, rollupinfo[i]["Start_TS"].month, rollupinfo[i]["Start_TS"].day,01,00,00) ,rollupdelay)						
			            j=mecZEOinfo.length
					end			        
					j+=1					
			  end  
			  if ifmecornot==false	
			     calruntime("nonmec",rollupinfo[i]["ElapseTime"],rollupmetric)					
				 calrollupdelaytime("nonmec",rollupinfo[i]["Start_TS"]-Time.utc(rollupinfo[i]["Start_TS"].year, rollupinfo[i]["Start_TS"].month, rollupinfo[i]["Start_TS"].day,01,00,00) ,rollupdelay)
			  end
			  ifmecornot=false	
			end
			if(rollupinfo[i]["Server"]=="EMR")
			  j=0
			  while j < mecEMRinfo.length do
			        if (ifmecornot==false && rollupinfo[i]["RollupDate"]>=mecJADinfo[j]["MECStartDate"]  &&  rollupinfo[i]["RollupDate"]<=mecJADinfo[j]["MECEndDate"])
					    ifmecornot=true	
					    calruntime("mec",rollupinfo[i]["ElapseTime"],rollupmetric)
						calrollupdelaytime("mec",rollupinfo[i]["Start_TS"]-Time.utc(rollupinfo[i]["Start_TS"].year, rollupinfo[i]["Start_TS"].month, rollupinfo[i]["Start_TS"].day,8,00,00) ,rollupdelay)
			            j=mecEMRinfo.length
					end
					j+=1
			  end
			  if ifmecornot==false
			     calruntime("nonmec",rollupinfo[i]["ElapseTime"],rollupmetric)
				 calrollupdelaytime("nonmec",rollupinfo[i]["Start_TS"]-Time.utc(rollupinfo[i]["Start_TS"].year, rollupinfo[i]["Start_TS"].month, rollupinfo[i]["Start_TS"].day,8,00,00) ,rollupdelay)
			  end
			  ifmecornot=false	
			end			
		    if(rollupinfo[i]["Server"]=="JAD")
			  j=0
			  while j < mecJADinfo.length do
			        if (ifmecornot==false && rollupinfo[i]["RollupDate"]>=mecJADinfo[j]["MECStartDate"]  &&  rollupinfo[i]["RollupDate"]<=mecJADinfo[j]["MECEndDate"])
					    ifmecornot=true
					    calruntime("mec",rollupinfo[i]["ElapseTime"],rollupmetric)
						calrollupdelaytime("mec",rollupinfo[i]["Start_TS"]-Time.utc(rollupinfo[i]["Start_TS"].year, rollupinfo[i]["Start_TS"].month, rollupinfo[i]["Start_TS"].day,19,00,00) ,rollupdelay)
						j=mecJADinfo.length
					end
					j+=1
			  end
			  if ifmecornot==false
			     calruntime("nonmec",rollupinfo[i]["ElapseTime"],rollupmetric)
				 calrollupdelaytime("nonmec",rollupinfo[i]["Start_TS"]-Time.utc(rollupinfo[i]["Start_TS"].year, rollupinfo[i]["Start_TS"].month, rollupinfo[i]["Start_TS"].day,19,00,00) ,rollupdelay)			     
			  end
			  ifmecornot=false	
			  end
		    i+=1
		   end
		   i=0
		   while i < ticketinfo.length do		   
		    if(ticketinfo[i]["Environment"]=="ZEO")
              j=0
			  while j < mecZEOinfo.length do
			        if (ifmecornot==false && ticketinfo[i]["Date"]>=mecJADinfo[j]["MECStartDate"]  &&  ticketinfo[i]["Date"]<=mecJADinfo[j]["MECEndDate"])
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
			        if (ifmecornot==false && ticketinfo[i]["Date"]>=mecJADinfo[j]["MECStartDate"]  &&  ticketinfo[i]["Date"]<=mecJADinfo[j]["MECEndDate"])
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
		      when delaytime<=1200                      then rollupdelay["MEC"][0] += 1
			  when delaytime>1200 &&  delaytime<2400    then rollupdelay["MEC"][1] += 1
			  when delaytime>=2400                      then rollupdelay["MEC"][2] += 1		  
		      end
		   else
		      case 
		      when delaytime<=1200                      then rollupdelay["NonMEC"][0] += 1
			  when delaytime>1200 &&  delaytime<2400    then rollupdelay["NonMEC"][1] += 1
			  when  delaytime>=2400                     then rollupdelay["NonMEC"][2] += 1	  
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

