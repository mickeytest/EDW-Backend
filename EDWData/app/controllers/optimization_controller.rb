class OptimizationController < ApplicationController
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
	    
	
        beforedurationinfo=Array.new(20,0)
        afterdurationinfo=Array.new(20,0)
		  j=0	
	      i=6
		 while i< monthinfo.length-1 do
		   tttstart=(DateTime.parse((monthinfo[i]).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00") 
		   tttend=  (DateTime.parse((monthinfo[i+1]).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00") 
               optimizationinfo=HpsmYotta.find_by_sql("SELECT  \"Complete_Date_l\",\"MIDs\"
               FROM edw_ops_call_trackers  where \"Classification\"='Optimization' and \"Status\"='Completed' and \"Complete_Date_l\">=\'#{tttstart}\' 
			   and \"Complete_Date_l\"<=\'#{tttend}\'")
		       			   
			   optimizationinfo.each do |r|			      
			   midstarttime= (DateTime.parse((r["Complete_Date_l"]).strftime("%Y/%m/%d")+ ' 00:00:00') +30)
			   midendtime= (DateTime.parse((r["Complete_Date_l"]).strftime("%Y/%m/%d")+ ' 00:00:00') -30)
				if(midstarttime>monthinfo[i+1])
				   midstarttime=monthinfo[i+1]
				end
			if(r["MIDs"]!=nil)
                before30duration=HpsmYotta.find_by_sql("SELECT avg(\"DURATION\") FROM rollupstatuses  where \"Start_TS_l\">=\'#{midendtime}\' 
				and  \"MID\"=\'#{r["MIDs"][0,5]}\' and \"End_TS_l\"<=\'#{r["Complete_Date_l"]}\'  ")				
			  
			    after30duration=HpsmYotta.find_by_sql("SELECT avg(\"DURATION\") FROM rollupstatuses  where \"Start_TS_l\">=\'#{r["Complete_Date_l"]}\' 
			      and  \"MID\"=\'#{r["MIDs"][0,5]}\' and \"End_TS_l\"<=\'#{midstarttime}\'")				
               if(before30duration[0]["avg"]!=nil)
			      beforedurationinfo[j]+=before30duration[0]["avg"]
			   end
			   if(after30duration[0]["avg"]!=nil)
			      afterdurationinfo[j]+=after30duration[0]["avg"]
               end
              end			   
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
		   i=7
           while i< slength
               monthdata[j]=(DateTime.parse(everymonthdate[i]["Year"].to_s + '-' + everymonthdate[i]["Month"].to_s + '-01')).strftime("%b,%Y")
               i+=1
               j+=1
           end
          optimizationtrend={}
		  optimizationtrend[:categories]=monthdata
		  
		  optimization={}
		  optimization[:title]="Optimization Total"	  		  
		  optimization[:data]=[]
		  optimizationtrend[:OptimizationTrend]=[]
		  optimizationtrend[:OptimizationTrend].push(optimization)		  

		  i=0
          j=j-1
           while i<=j do
             optimization[:data].push([i,(beforedurationinfo[i]==0 ? 0:(((beforedurationinfo[i]-afterdurationinfo[i])/beforedurationinfo[i])*100).round(0))])
             i+=1
            end
		  
		 
		 render json:optimizationtrend.to_json
	end
end
