class PermanentController < ApplicationController
    def index
	    yottainfo=HpsmYotta.find_by_sql("select  \"Open_Time_l\" as \"TTF\"  from  hpsm_yotta where \"Status\"='Closed'  order by \"Open_Time_l\"")
       
       everymonthdate=Dailyrolluptime.find_by_sql("
	     select * from (
  select \"Year\",\"Month\",max(\"MECEndDate_l\") as \"everymaxmonth\"  from mec_calendars where \"Environment\"='ZEO' group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ) aaa
  where aaa.\"everymaxmonth\" >\'#{yottainfo[0]["TTF"]}\' ") 
  
  
  
	if(everymonthdate[0]["Month"]!=1)
    firstmonth=Dailyrolluptime.find_by_sql("
  select max(\"MECEndDate_l\") as \"everymaxmonth\" from mec_calendars where \"Year\"=\'#{everymonthdate[0]["Year"]}\'
  and \"Month\"=\'#{everymonthdate[0]["Month"]-1}\'")
     else
   firstmonth=Dailyrolluptime.find_by_sql("
         select max(\"MECEndDate_l\") as \"everymaxmonth\" from mec_calendars where \"Year\"=\'#{everymonthdate[0]["Year"]-1}\'
          and \"Month\"=12")
     end	 
		
		monthinfo=Array.new
		i=1
		j=0
		if(firstmonth[0]["everymaxmonth"]==nil)
		i=0
		j=0
		else
		monthinfo[0]=firstmonth[0]["everymaxmonth"]		
		end
	
	    while j<everymonthdate.length do		     
              monthinfo[i]=everymonthdate[j]["everymaxmonth"]	
			  i+=1
			  j+=1
        end
	    
	
        peinfo=Array.new(20,0)
		  j=0	
	      i=0
		 while i< monthinfo.length-1 do
		   tttstart=(DateTime.parse((monthinfo[i]).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00") 
		   tttend=  (DateTime.parse((monthinfo[i+1]).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00")
               midinfo=HpsmYotta.find_by_sql("SELECT  \"Complete_Date_l\",\"MIDs\"
               FROM edw_ops_call_trackers  where \"Classification\"='ETL Script Issue'  and \"Complete_Date_l\">=\'#{tttstart}\' 
			   and \"Complete_Date_l\"<=\'#{tttend}\'")
			   ddd=0
			   while ddd<midinfo.length do
			   if(midinfo[ddd]["MIDs"] != nil)
			       permanentinfo=HpsmYotta.find_by_sql("SELECT \"Time_that_AO_emailed_oncall\", \"TimetoReExec\", \"TimetoEngage\", \"TimetoFix\", 
              \"Time_that_AO_called_oncall\"              
              FROM oncallissuetrackers  where \"Date_l\">=\'#{tttstart}\' and \"Date_l\"<=\'#{tttend}\' and  \"MasterID\"=#{midinfo[ddd]["MIDs"][0,5].to_i}")
			   end
               if(permanentinfo!=nil)
			   permanentinfo.each do |r|
			   peinfo[j]+=(r["Time_that_AO_emailed_oncall"]+r["TimetoReExec"]+r["TimetoEngage"]+r["TimetoFix"])*2
			   end
			   end
			   ddd+=1
			   end
			   i+=1
			   j+=1
		  end

		 if(Time.new <everymonthdate[everymonthdate.length-1]["everymaxmonth"])
		         slength= everymonthdate.length-1
		 else
		         slength= everymonthdate.length
		 end

           monthdata=Array.new
		   if(firstmonth[0]["everymaxmonth"]==nil)
           i=1
		   else
		   i=0
		   end
           j=0
		   i=6
           while i< slength
               monthdata[j]=(DateTime.parse(everymonthdate[i]["Year"].to_s + '-' + everymonthdate[i]["Month"].to_s + '-01')).strftime("%b,%Y")
               i+=1
               j+=1
           end
          permanenttrend={}
		  permanenttrend[:categories]=monthdata
		  
		  permanent={}
		  permanent[:title]="Pemanent Total"	  		  
		  permanent[:data]=[]
		  permanenttrend[:PermanentTrend]=[]
		  permanenttrend[:PermanentTrend].push(permanent)
		  

		  i=0
          j=j-1
           while i<=j do
             permanent[:data].push([i,(peinfo[i+5]/60).round(0)])
             i+=1
            end
		  
		 
		 render json:permanenttrend.to_json
	end
end
