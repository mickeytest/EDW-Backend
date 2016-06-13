class DailyrolluptimeController < ApplicationController
  def index
      #\'#{currectTime}\' ")
	  #currectTime=(Time.new).strftime("%Y-%m-%d")+ ' 00:00:00'
	  #currectTime=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-2).strftime("%Y-%m-%d %H:%M:%S")
	  maxrolluptime=Dailyrolluptime.find_by_sql("select max(\"RollupDate\") as \"maxrollupdate\", max(\"RollupDate_l\") as \"maxrollupdate_l\" from dailyrolluptimes where   \"Server\" !='BER'")
      
	  regioninfo=Dailyrolluptime.find_by_sql("SELECT \"region_name\", \"instance\", split_part(\"time_zone\", ' ', 1) as \"time\"
        FROM regions")
rollupjs=Hash.new
      i=0
	  while i<regioninfo.length do
	        if(regioninfo[i]["instance"]=='ZEO')
			rollupjs["ZEODST"]=regioninfo[i]["time"].to_i
			elsif(regioninfo[i]["instance"]=='EMR')
			rollupjs["EMRDST"]=regioninfo[i]["time"].to_i
			elsif(regioninfo[i]["instance"]=='JAD')
			rollupjs["JADDST"]=regioninfo[i]["time"].to_i
	        end
	     i+=1
	  end
	  
	  priviousday= (DateTime.parse((maxrolluptime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 00:00:00') -1)
	  priviousday_l= (DateTime.parse((maxrolluptime[0]["maxrollupdate_l"]).strftime("%Y/%m/%d")+ ' 00:00:00') -1)
	  
	  rollupdetailtoday=Array.new
	  rollupdetailprivious=Array.new
	  rollupdetailtoday=rollupinformation(maxrolluptime[0]["maxrollupdate"],maxrolluptime[0]["maxrollupdate_l"],rollupjs) 
	  rollupjs["date"]=DateTime.parse((maxrolluptime[0]["maxrollupdate"]).strftime("%Y/%m/%d")).strftime("%Y/%m/%d")

	  
	  
      rollupdetailprivious=rollupinformation(priviousday,priviousday_l,rollupjs)	  
	  i=0
	  while i<9 do 
	  rollupdetailtoday[9+i]=rollupdetailprivious[i]
	  i+=1
	  end	  	  
      rollupjs["info"]=rollupdetailtoday
	  
	  msabreachinfo=MsaslaBreachTracker.find_by_sql("SELECT  \"Rollup_Date\", \"Start_Time\", \"End_Time\", \"Environment\", \"Start_On_Time\", 
       \"SLA_Met\", \"Delay_Reason\", \"SLA_Miss_Reason\", \"Comment\"
       FROM msasla_breach_trackers where \"Rollup_Date\">=\'#{priviousday}\' order by \"Rollup_Date\" desc;")
	  
	  i=0
	  rollupjs["SLABreach"]=[]
	  while i<msabreachinfo.length do
	      rollupjs["SLABreach"].push([:Date=>msabreachinfo[i]["Rollup_Date"].strftime("%Y-%m-%d"),
		  :Environment=>msabreachinfo[i]["Environment"],
		  :StartOnTime=>msabreachinfo[i]["Start_On_Time"],
		  :DelayReason=>msabreachinfo[i]["Delay_Reason"],
		  :SLAMeet=>msabreachinfo[i]["SLA_Met"],
		  :SLAMissReason=>msabreachinfo[i]["SLA_Miss_Reason"],
		  :Comments=>msabreachinfo[i]["Comment"]
		  ]
		  ) 
		  i+=1
	  end
  
	  render json: rollupjs.to_json
  end
     
	def  rollupcolourcal(rolluptimestartact,server,rolluptimeendact,rolluptime,currenttime) 
	      rolluptimestart =Hash.new
		  rolluptimestart["JAD"]=DateTime.parse((currenttime).strftime("%Y/%m/%d")+ ' 19:00:00').strftime("%Y/%m/%d %H:%M:%S")
		  rolluptimestart["ZEO"]=DateTime.parse((currenttime).strftime("%Y/%m/%d")+ ' 02:00:00').strftime("%Y/%m/%d %H:%M:%S")
		  rolluptimestart["EMR"]=DateTime.parse((currenttime).strftime("%Y/%m/%d")+ ' 08:00:00').strftime("%Y/%m/%d %H:%M:%S")
		  timediff=((DateTime.parse(rolluptimestartact)-DateTime.parse(rolluptimestart[server]))*24.0*60).to_int
		  
		  if rolluptimeendact !=  nil
		     timediff2=((DateTime.parse(rolluptimeendact)-DateTime.parse(rolluptimestart[server]))*24.0*60).to_int	#DateTime.parse(rolluptimestartact))*24*60).to_int
          else  
		     timediff2=(((DateTime.parse((Time.new).strftime("%Y/%m/%d %H:%M:%S"))-7/24.0)-DateTime.parse(rolluptimestart[server]))*24.0*60).to_int
		  end
         rolluptime[server]=rolluptimestartact		  
    #      if(server=='EMR')		     
		  #    p rolluptimestart["EMR"]
			 # p DateTime.parse(rolluptimeendact).strftime("%Y/%m/%d %H:%M:%S")
			 # p DateTime.parse(rolluptimestartact).strftime("%Y/%m/%d %H:%M:%S")
			 # p timediff2
			 # p timediff
		  # end
         if (timediff2 >600)
		     return "#FF0033"
		 elsif(timediff2 >570)
		     return "#F28F2C"
		 elsif(timediff >180)
		     return "#FFFF00"
		 else
		     return "#81D5A9"
		 end
		 
	 end

	 
	 def  offcyclecolourcal(offcyclestarttime,server,offcycleendtime,rolluptime) 
	      rolluptimestart =Hash.new	
		  timediff=((DateTime.parse(rolluptime[server])-DateTime.parse(offcyclestarttime))*24.0*60).to_int
          timediff2=((DateTime.parse(rolluptime[server])-DateTime.parse(offcycleendtime))*24.0*60).to_int		   
		  return case 
		     when timediff2<0          then :"#C65355"
		     when timediff !=180       then :"#FFFF7A"
		     when timediff ==180       then :"#81D5D4"
		  end  
	 end
	 

	 def rollupinformation(rollup_date,rollup_date_l,rollupjs)		 
	  rollupinfo=  Dailyrolluptime.find_by_sql("select * from dailyrolluptimes where \"RollupDate\"=\'#{rollup_date}\' and \"Server\" !='BER' ")
      offcycleinfo=Dailyrollupoffcycle.find_by_sql("select * from dailyrollupoffcycles where \"RollupDate\"=\'#{rollup_date }\' and \"Server\" in 
  (
  select \"Server\" from dailyrolluptimes where \"RollupDate\"=\'#{rollup_date}\' and \"Server\" !='BER' 
  )
  ")
	  rollupstatus=Hash.new
	  rollupdata=Hash.new
      rollupstatus={"ZEO"=>{"IVC"=> "OffIVC ",    "FIN"=>"OffFIN ",   "rollup"=>"Rollup "}, 
                    "EMR"=>{"IVC"=>"OffIVC ",     "FIN"=>"OffFIN ",   "rollup"=>"Rollup "}, 
                    "JAD"=>{"IVC"=>"OffIVC ",  "FIN"=>"OffFIN ","rollup"=>"Rollup "}}
	  rollupdata  ={"ZEO"=>{"IVC"=>0,   "FIN"=>1 ,"rollup"=>2}, 
                    "EMR"=>{"IVC"=>3,   "FIN"=>4 ,"rollup"=>5},
                    "JAD"=>{"IVC"=>6,   "FIN"=>7 ,"rollup"=>8}}				
	  rollupdetail=Array.new
      rolluptime  =Hash.new  
	  rollupcolour =Hash.new
	  
	  rollupdetail=[	                     
					{"name"=> "OffIVC not started","color"=> "#C9C9C9","x"=>0,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["ZEODST"]+3)/24.0).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["ZEODST"]+3-10)/24.0).strftime("%Y/%m/%d %H:%M:%S"),DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 00:00:00').strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')).strftime("%Y/%m/%d %H:%M:%S")]},
                    {"name"=> "OffFIN not started","color"=> "#C9C9C9","x"=>0,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["ZEODST"]+3)/24.0).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["ZEODST"]+3-10)/24.0).strftime("%Y/%m/%d %H:%M:%S"),DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 00:00:00').strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')).strftime("%Y/%m/%d %H:%M:%S")]},
                    {"name"=> "Not Started","color"=> "#ABABAB","x"=>0,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-rollupjs["ZEODST"]/24.0).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["ZEODST"]-10)/24.0).strftime("%Y/%m/%d %H:%M:%S"),DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00').strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')+10/24.0).strftime("%Y/%m/%d %H:%M:%S")]},					
					{"name"=> "OffIVC not started","color"=> "#C9C9C9","x"=>1,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["EMRDST"]+3)/24.0).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["EMRDST"]+3-10)/24.0).strftime("%Y/%m/%d %H:%M:%S"),DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 00:00:00').strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')).strftime("%Y/%m/%d %H:%M:%S")]},
                    {"name"=> "OffFIN not started","color"=> "#C9C9C9","x"=>1,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["EMRDST"]+3)/24.0).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["EMRDST"]+3-10)/24.0).strftime("%Y/%m/%d %H:%M:%S"),DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 00:00:00').strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')).strftime("%Y/%m/%d %H:%M:%S")]},
                    {"name"=> "Not Started","color"=> "#ABABAB","x"=>1,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-rollupjs["EMRDST"]/24.0).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["EMRDST"]-10)/24.0).strftime("%Y/%m/%d %H:%M:%S"),DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00').strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')+10/24.0).strftime("%Y/%m/%d %H:%M:%S")]},					 
					{"name"=> "OffIVC not started","color"=> "#C9C9C9","x"=>2,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["JADDST"]+3)/24.0+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["JADDST"]+3-10)/24.0+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 00:00:00')+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')+1).strftime("%Y/%m/%d %H:%M:%S")]},
                    {"name"=> "OffFIN not started","color"=> "#C9C9C9","x"=>2,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["JADDST"]+3)/24.0+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["JADDST"]+3-10)/24.0+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 00:00:00')+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')+1).strftime("%Y/%m/%d %H:%M:%S")]},
                    {"name"=> "Not Started","color"=> "#ABABAB","x"=>2,"data"=> [(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-rollupjs["JADDST"]/24.0+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')-(rollupjs["JADDST"]-10)/24.0+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')+1).strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((rollup_date).strftime("%Y/%m/%d")+ ' 03:00:00')+10/24.0+1).strftime("%Y/%m/%d %H:%M:%S")]}                   				
					]	  

	  i=0
	  while i < rollupinfo.length do
	    p rollupinfo[i].attributes["Server"]
			if rollupinfo[i].attributes["End_TS"]== nil && rollupinfo[i].attributes["Start_TS"]!= nil && rollupinfo[i].attributes["Estimated_End_TS"] == nil
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["name"]="Running"
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["data"]=[rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse(rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"))+8.5/24.0).strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse(rollupinfo[i].attributes["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S"))+8.5/24.0).strftime("%Y/%m/%d %H:%M:%S")]		
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["color"]=rollupcolourcal(rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Server"],nil,rolluptime,rollup_date)						
			elsif  rollupinfo[i].attributes["End_TS"]== nil && rollupinfo[i].attributes["Start_TS"]!= nil && rollupinfo[i].attributes["Estimated_End_TS"] != nil
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["name"]="Running"
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["data"]=[rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Estimated_End_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["estimated_end_l"].strftime("%Y/%m/%d %H:%M:%S")]		
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["color"]=rollupcolourcal(rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Server"],nil,rolluptime,rollup_date)						
			else
			rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["name"]="Completed"     			
			rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["data"]=[rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["End_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["End_TS_l"].strftime("%Y/%m/%d %H:%M:%S")]								
			rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["color"]=rollupcolourcal(rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Server"],rollupinfo[i].attributes["End_TS"].strftime("%Y/%m/%d %H:%M:%S"),rolluptime,rollup_date)						
			end
			rollupcolour[rollupinfo[i].attributes["Server"]]=rollupinfo[i].attributes["RollupDate"]			
			i+=1
	  end
	  i=0
	  while i < offcycleinfo.length do
            if  (offcycleinfo[i].attributes["End_TS"])== nil && (offcycleinfo[i].attributes["Start_TS"])!= nil
                rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["name"]=rollupstatus[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]+"Running"
				rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["data"]=[offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse(offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"))+3/24.0).strftime("%Y-%m-%d %H:%M:%S"),offcycleinfo[i].attributes["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse(offcycleinfo[i].attributes["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S"))+3/24.0).strftime("%Y-%m-%d %H:%M:%S")]								
			    rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["color"]=offcyclecolourcal(offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),offcycleinfo[i].attributes["Server"],nil,rolluptime)	
			else
			rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["name"]=rollupstatus[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]+"Completed"		
			rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["data"]=[offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),offcycleinfo[i].attributes["End_TS"].strftime("%Y/%m/%d %H:%M:%S"),offcycleinfo[i].attributes["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S"),offcycleinfo[i].attributes["End_TS_l"].strftime("%Y/%m/%d %H:%M:%S")]											
			rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["color"]=offcyclecolourcal(offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),offcycleinfo[i].attributes["Server"],offcycleinfo[i].attributes["End_TS"].strftime("%Y/%m/%d %H:%M:%S"),rolluptime)	
			end
			
			i+=1
	  end	  
      return rollupdetail	 
	 end

end