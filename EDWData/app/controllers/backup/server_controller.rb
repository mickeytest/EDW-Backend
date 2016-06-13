class ServerController < ApplicationController
     def index
	 pf = params[:Environment]
	 privious30time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 30).strftime("%Y-%m-%d %H:%M:%S")
	 emrinfo=Oncallissuetracker.find_by_sql("select \"MasterID\",\"Date\",\"TimetoEngage\" ,\"Time_that_AO_emailed_oncall\" ,\"TimetoFix\" ,\"TimetoReExec\" ,\"TimeFailure\", \"TimeSucceeded\", \"ErrorDetails\",\"Action\" from oncallissuetrackers where \"Environment\"=\'#{pf}\' and \"Date\">\'#{privious30time}\'")
     #emrinfo = Oncallissuetracker.select('MasterID','Date','TimetoEngage','Time_that_AO_emailed_oncall','TimetoFix','TimetoReExec','TimeFailure','TimeSucceeded','ErrorDetails','Action').where(Environment: pf)
	 timeavg = Oncallissuetracker.find_by_sql("select avg(\"Time_that_AO_emailed_oncall\") as AO1ExceedAvg ,avg(\"TimetoReExec\") as AO2ExceedAvg  from oncallissuetrackers where \"Environment\"=\'#{pf}\' and \"Date\">\'#{privious30time}\'")
	 #timeavg = Oncallissuetracker.select(avg('Time_that_AO_emailed_oncall') as AO1ExceedAvg,avg'TimetoEngage') as OC1ExceedAvg,avg('TimetoReExec') as AO2ExceedAvg,avg('TimetoFix') as OC2ExceedAvg).where(Environment: pf)   ,avg(\"TimetoFix\") as OC2ExceedAvg 
	 i=0
	 serverjs =Hash.new
	 temphash =Hash.new
	 serverinfo =Array.new
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
end
