class DailyrolluptimeController < ApplicationController
  def index
     #\'#{currectTime}\' ")
	  #currectTime=(Time.new).strftime("%Y-%m-%d")+ ' 00:00:00'
	  #currectTime=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-2).strftime("%Y-%m-%d %H:%M:%S")
	  maxrolluotime=Dailyrolluptime.find_by_sql("select max(\"RollupDate\") as \"maxrollupdate\" from dailyrolluptimes where   \"Server\" !='BER'")
      rollupinfo=  Dailyrolluptime.find_by_sql("select * from dailyrolluptimes where \"RollupDate\"=\'#{maxrolluotime[0]["maxrollupdate"]}\' and \"Server\" !='BER'")
      offcycleinfo=Dailyrollupoffcycle.find_by_sql("select * from dailyrollupoffcycles where \"RollupDate\"=\'#{maxrolluotime[0]["maxrollupdate"]}\' and \"Server\" !='BER'")
	  rollupjs=Hash.new
	  rollupstatus=Hash.new
	  rollupdata=Hash.new
	  rollupjs["date"]=DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")).strftime("%Y/%m/%d")
      rollupstatus={"ZEO"=>{"IVC"=> "OffIVC ",    "FIN"=>"OffFIN ",   "rollup"=>"Rollup "}, 
                    "EMR"=>{"IVC"=>"OffIVC ",     "FIN"=>"OffFIN ",   "rollup"=>"Rollup "}, 
                    "JAD"=>{"IVC"=>"OffIVC ",  "FIN"=>"OffFIN ","rollup"=>"Rollup "}}
	  rollupdata  ={"ZEO"=>{"IVC"=>0,   "FIN"=>1 ,"rollup"=>2}, 
                    "EMR"=>{"IVC"=>3,   "FIN"=>4 ,"rollup"=>5},
                    "JAD"=>{"IVC"=>6,   "FIN"=>7 ,"rollup"=>8}}				
	  rollupdetail=Array.new
      rolluptime  =Hash.new  
	  rollupcolour =Hash.new
	  rollupdetail=[{"name"=> "OffIVC not started!","color"=> "#C9C9C9","x"=>0,"data"=> [(DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 01:00:00') - 3/24.0).strftime("%Y/%m/%d %H:%M:%S"),(Time.new).strftime("%Y/%m/%d")+ ' 01:00:00']}, 
                    {"name"=> "OffFIN not started!","color"=> "#C9C9C9","x"=>0,"data"=> [(DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 01:00:00') - 3/24.0).strftime("%Y/%m/%d %H:%M:%S"),(Time.new).strftime("%Y/%m/%d")+ ' 01:00:00']},
                    {"name"=> "Rollup not started!","color"=> "#ABABAB","x"=>0,"data"=> [DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 01:00:00').strftime("%Y/%m/%d %H:%M:%S"),(maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 09:30:00']},
                    {"name"=> "OffIVC not started!","color"=> "#C9C9C9","x"=>1,"data"=> [DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 05:00:00').strftime("%Y/%m/%d %H:%M:%S"),(maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 08:00:00']},
                    {"name"=> "OffFIN not started!","color"=> "#C9C9C9","x"=>1,"data"=> [DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 05:00:00').strftime("%Y/%m/%d %H:%M:%S"),(maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 08:00:00']},
                    {"name"=> "Rollup not started!","color"=> "#ABABAB","x"=>1,"data"=> [DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 08:00:00').strftime("%Y/%m/%d %H:%M:%S"),(maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 16:30:00']},
                    {"name"=> "OffIVC not started!","color"=> "#C9C9C9","x"=>2,"data"=> [DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 16:00:00').strftime("%Y/%m/%d %H:%M:%S"),(maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 19:00:00']},
                    {"name"=> "OffFIN not started!","color"=> "#C9C9C9","x"=>2,"data"=> [DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 16:00:00').strftime("%Y/%m/%d %H:%M:%S"),(maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 19:00:00']},
                    {"name"=> "Rollup not started!","color"=> "#ABABAB","x"=>2,"data"=> [DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 19:00:00').strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse((maxrolluotime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 19:00:00') + 8.5/24.0).strftime("%Y/%m/%d %H:%M:%S")]}]	  
	  i=0
	  while i < rollupinfo.length do
	  puts rollupinfo[i].attributes["Server"]
	  puts rollupinfo[i].attributes["Start_TS"]
	  puts rollupinfo[i].attributes["RollupDate"]
			if rollupinfo[i].attributes["End_TS"]== nil && rollupinfo[i].attributes["Start_TS"]!= nil && rollupinfo[i].attributes["Estimated_End_TS"] == nil
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["name"]="Rollup is running"
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["data"]=[rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse(rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"))+8.5/24.0).strftime("%Y/%m/%d %H:%M:%S")]		
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["color"]=rollupcolourcal(rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Server"],nil,rolluptime,maxrolluotime[0]["maxrollupdate"])						
			elsif  rollupinfo[i].attributes["End_TS"]== nil && rollupinfo[i].attributes["Start_TS"]!= nil && rollupinfo[i].attributes["Estimated_End_TS"] != nil
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["name"]="Rollup is running"
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["data"]=[rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Estimated_End_TS"].strftime("%Y/%m/%d %H:%M:%S")]		
			   rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["color"]=rollupcolourcal(rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Server"],nil,rolluptime,maxrolluotime[0]["maxrollupdate"])						
			else
			rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["name"]="Rollup finished!"     			
			rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["data"]=[rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["End_TS"].strftime("%Y/%m/%d %H:%M:%S")]								
			rollupdetail[rollupdata[rollupinfo[i].attributes["Server"]]["rollup"]]["color"]=rollupcolourcal(rollupinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),rollupinfo[i].attributes["Server"],rollupinfo[i].attributes["End_TS"].strftime("%Y/%m/%d %H:%M:%S"),rolluptime,maxrolluotime[0]["maxrollupdate"])						
			end
			rollupcolour[rollupinfo[i].attributes["Server"]]=rollupinfo[i].attributes["RollupDate"]			
			i+=1
	  end
	  i=0
	  while i < offcycleinfo.length do
            if  (offcycleinfo[i].attributes["End_TS"])== nil && (offcycleinfo[i].attributes["Start_TS"])!= nil
                rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["name"]=rollupstatus[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]+"is running!"
				rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["data"]=[offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),(DateTime.parse(offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"))+3/24.0).strftime("%Y-%m-%d %H:%M:%S")]								
			    rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["color"]=offcyclecolourcal(offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),offcycleinfo[i].attributes["Server"],nil,rolluptime)	
			else
			rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["name"]=rollupstatus[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]+"is finished!"		
			rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["data"]=[offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),offcycleinfo[i].attributes["End_TS"].strftime("%Y/%m/%d %H:%M:%S")]											
			rollupdetail[rollupdata[offcycleinfo[i].attributes["Server"]][offcycleinfo[i].attributes["OffCycleType"]]]["color"]=offcyclecolourcal(offcycleinfo[i].attributes["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),offcycleinfo[i].attributes["Server"],offcycleinfo[i].attributes["End_TS"].strftime("%Y/%m/%d %H:%M:%S"),rolluptime)	
			end
			
			i+=1
	  end	  
      rollupjs["info"]=rollupdetail
	  render json: rollupjs.to_json
  end
     
	def  rollupcolourcal(rolluptimestartact,server,rolluptimeendact,rolluptime,currenttime) 
	      rolluptimestart =Hash.new
		  rolluptimestart["JAD"]=DateTime.parse((currenttime).strftime("%Y/%m/%d")+ ' 19:00:00').strftime("%Y/%m/%d %H:%M:%S")
		  rolluptimestart["ZEO"]=DateTime.parse((currenttime).strftime("%Y/%m/%d")+ ' 01:00:00').strftime("%Y/%m/%d %H:%M:%S")
		  rolluptimestart["EMR"]=DateTime.parse((currenttime).strftime("%Y/%m/%d")+ ' 08:00:00').strftime("%Y/%m/%d %H:%M:%S")
		  timediff=((DateTime.parse(rolluptimestartact)-DateTime.parse(rolluptimestart[server]))*24.0*60).to_int
		  if rolluptimeendact !=  nil
		     timediff2=((DateTime.parse(rolluptimeendact)-DateTime.parse(rolluptimestart[server]))*24.0*60).to_int	#DateTime.parse(rolluptimestartact))*24*60).to_int
          else 
		     timediff2=0
		  end
         rolluptime[server]=rolluptimestartact		  
		 return case 
		    when timediff2 >720 then :"#FF0033"
			when timediff2 >510 then :"#F28F2C"
			when timediff ==0   then :"#81D5A9"  
			when timediff != 0  then :"#FFFF00"		    
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
end