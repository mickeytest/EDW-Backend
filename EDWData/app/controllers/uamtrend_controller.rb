class UamtrendController < ApplicationController

 def index
       yottainfo=HpsmYotta.find_by_sql("select \"Open_Time_l\" as \"TTF\"  from  hpsm_uams where \"Status\"='Closed'  order by \"Open_Time_l\"")
       
       everymonthdate=Dailyrolluptime.find_by_sql("
	     select * from (
  select \"Year\",\"Month\",max(\"MECEndDate_l\") as \"everymaxmonth\" from mec_calendars  where \"Environment\"='ZEO'  group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ) aaa
  where aaa.\"everymaxmonth\" >\'#{yottainfo[0]["TTF"]}\'") 
  
  

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
        	
        closeticketinfo=Array.new(20,0)
        crinfo=Array.new(20,0)
		  j=0	
	      i=0
		 while i< monthinfo.length-1 do
		       tttstart=  (DateTime.parse((monthinfo[i]).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00")
		       tttend=  (DateTime.parse((monthinfo[i+1]).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00") 
               yottainfo=HpsmYotta.find_by_sql("select count(distinct  \"Incident_ID\") as \"countttf\"  from  hpsm_uams where  \"Open_Time_l\">\'#{tttstart}}\'
 			   and \"Open_Time_l\"<=\'#{tttend}\' ")
			   closeticketinfo[j]=yottainfo[0]["countttf"]
			   shareplatformcr=HpsmYotta.find_by_sql("SELECT count(distinct \"ID\") FROM sp_uamchangerequests  where  \"Closed\">=\'#{tttstart}}\' and \"Closed\"  <=\'#{tttend}\'")
		       boecr=HpsmYotta.find_by_sql("SELECT count(distinct \"ID\") FROM sp_boe  where  \"Closed\">=\'#{tttstart}}\' and \"Closed\"  <=\'#{tttend}\'")
		       qlikviewcr=HpsmYotta.find_by_sql("SELECT count(distinct \"ID\") FROM sp_qlikviewrequest  where  \"Closed\">=\'#{tttstart}}\' and \"Closed\"  <=\'#{tttend}\'")
               crinfo[j]=qlikviewcr[0]["count"]+shareplatformcr[0]["count"]+ boecr[0]["count"]
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
          uamtrend={}
		  uamtrend[:categories]=monthdata
		  
		  tickeclost={}
		  tickeclost[:title]="Ticket"	  		  
		  tickeclost[:data]=[]
		  uamtrend[:TicketTrend]=[]
		  uamtrend[:TicketTrend].push(tickeclost)
		  
		  uamtrend[:TicketDrilldownCategories]=[]
		  uamtrend[:TicketDrilldownCategories].push("Cancelled",
          "Not able to reproduce",
          "Out of scope",
          "Misrouted",
          "Resolved")
		  
		  uamtrend[:TicketDrilldownData]=[]
		  uamtrend[:TicketDrilldownData].push(
		  [
            2,
            2,
            2,
            2,
            2
        ],
        [
            1,
            2,
            3,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ],
        [
            24,
            17,
            8,
            5,
            2
        ])
		
		  crclost={}
		  crclost[:title]="CR"	  		  
		  crclost[:data]=[]
		  uamtrend[:CRTrend]=[]
		  uamtrend[:CRTrend].push(crclost)
		
		  
		  i=0
          j=j-1
           while i<=j do
             tickeclost[:data].push([i,closeticketinfo[i+5]])
             crclost[:data].push([i,crinfo[i+5]])
             i+=1
            end
		  
		 
		 render json:uamtrend.to_json
   end
   
end
