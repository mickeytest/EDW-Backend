class MecAvailableController < ApplicationController
def index

prorollupmatic=Hash.new	
           if(params[:Type]=="RollupMetrics")
		   prorollupmatic["mindate"]="2015/08/01"
		   elsif(params[:Type]=="RollupBaseline")
		   prorollupmatic["mindate"]="2015/08/01"
		   elsif(params[:Type]=="RollupSLA")
		   prorollupmatic["mindate"]="2015/08/01"
		   elsif(params[:Type]=="DataQuality")
		   prorollupmatic["mindate"]="2015/08/01"
		   elsif(params[:Type]=="DevOpsReport")
		   prorollupmatic["mindate"]="2015/08/01"
		   elsif(params[:Type]=="MECSummary")
		   prorollupmatic["mindate"]="2015/08/01"
		   end
		  jaddatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='JAD' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
          emrdatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='EMR' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
		  zeodatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='ZEO' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
		   
		   

mectitleinfo=nil
nonmectitleinfo=nil

runningornot=false
if( DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) < DateTime.parse((zeodatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S")) )
    # prorollupmatic["mindate"]="2015/08/01"
	 prorollupmatic["maxdate"]=zeodatascope[1]["Year"].to_s + "/" + zeodatascope[1]["Month"].to_s + "/" + "01"
	 mectitleinfo=""
elsif(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S")))
    # prorollupmatic["mindate"]="2015/08/01"
	 prorollupmatic["maxdate"]=zeodatascope[0]["Year"].to_s + "/" + zeodatascope[0]["Month"].to_s+ "/" + "01"
	 mectitleinfo=""
else
    # prorollupmatic["mindate"]="2015/08/01"
	 prorollupmatic["maxdate"]=zeodatascope[0]["Year"].to_s + "/" + zeodatascope[0]["Month"].to_s+ "/" + "01"
=begin
	 if(currentdate!=nil)
	     if(DateTime.parse(currentdate+ '-01').strftime("%Y-%m-%d")==DateTime.parse(zeodatascope[0]["Year"].to_s+ "-" + zeodatascope[0]["Month"].to_s + "-01").strftime("%Y-%m-%d"))
         mectitleinfo= DateTime.parse(zeodatascope[0]["Year"].to_s+ "-" + zeodatascope[0]["Month"].to_s + "-01").strftime("%b") + " MEC is on going"
         else
         mectitleinfo=""
         end
	 else
	    mectitleinfo=""
	 end
=end
	 runningornot=true
end

    first=true
    i=0
   while i<jaddatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((zeodatascope[i]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{zeodatascope[i]["Year"]}\'  and \"Month\"=\'#{zeodatascope[i]["Month"]}\' and \"Environment\"='ZEO'")
		   first=false
		 end
		 i+=1
   end


prorollupmatic["currentStartDate"]=(DateTime.parse((mecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d")#(mecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d")	 
prorollupmatic["currentEndDate"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d")	 


render json: prorollupmatic.to_json

end
end
