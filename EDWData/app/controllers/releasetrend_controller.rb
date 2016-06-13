class ReleasetrendController < ApplicationController
 def index
	  yottainfo=HpsmYotta.find_by_sql("select \"Open_Time_l\" as \"TTF\"  from  hpsm_yotta where \"Status\"='Closed'  order by \"Open_Time_l\"")
       
       everymonthdate=Dailyrolluptime.find_by_sql("
	     select * from (
  select \"Year\",\"Month\",max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ) aaa
  where aaa.\"everymaxmonth\" >\'#{yottainfo[0]["TTF"]}\'") 
  
  
  
	if(everymonthdate[0]["Month"]!=1)
    firstmonth=Dailyrolluptime.find_by_sql("
  select max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars where \"Year\"=\'#{everymonthdate[0]["Year"]}\'
  and \"Month\"=\'#{everymonthdate[0]["Month"]-1}\'")
     else
   firstmonth=Dailyrolluptime.find_by_sql("
         select max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars where \"Year\"=\'#{everymonthdate[0]["Year"]-1}\'
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
	    
	
        rmticketinfo1=Array.new(20,0)
        mtirinfo=Array.new(20,0)
		  j=0	
	      i=0
		 while i< monthinfo.length-1 do
               tttstart=  (DateTime.parse((monthinfo[i]).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00")
		       tttend=  (DateTime.parse((monthinfo[i+1]).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00") 		 
			   rmticketinfo=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"MID\")  as \"countttf\" FROM rolluperrorinformations where \"Server\"='BER'  and \"RollupDate_l\">=\'#{tttstart}\' and \"RollupDate_l\"<\'#{tttend}\'");
               rmmtirequestinfo=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"ID\")  as \"countttf\" FROM sp_mtirequest where \"ApprovalStatus\"='Approved' and ((\"MTIStatus\"='Completed') or (\"MTIStatus\"='Signed Off')) and   \"Created\">=\'#{tttstart}\' and  \"Created\"<=\'#{tttend}\'")
               rmticketinfo1[j]=rmticketinfo[0]["countttf"]
			   mtirinfo[j]=rmmtirequestinfo[0]["countttf"]
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
          releasetrend={}
		  releasetrend[:categories]=monthdata
		  
		  
		  
		  ticketinfo={}
		  ticketinfo[:title]="Ticket"	  		  
		  ticketinfo[:data]=[]
		  releasetrend[:Ticket]=[]
		  releasetrend[:Ticket].push(ticketinfo)
		  
		  
		  mtirequestinfo={}
		  mtirequestinfo[:title]="MIT Request"	  		  
		  mtirequestinfo[:data]=[]
		  releasetrend[:MITRequest]=[]
		  releasetrend[:MITRequest].push(mtirequestinfo)
          
		  		  
		  
		  ttoinfo={}
		  ttoinfo[:title]="TTO"	  		  
		  ttoinfo[:data]=[[
                    0,
                    100
                ],
                [
                    1,
                    100
                ],
                [
                    2,
                    100
                ],
                [
                    3,
                    100
                ],
                [
                    4,
                    100
                ]]
		  releasetrend[:TTO]=[]
		  releasetrend[:TTO].push(ttoinfo)
		  
		  
		  ttfinfo={}
		  ttfinfo[:title]="TTF"	  		  
		  ttfinfo[:data]=[[
                    0,
                    95
                ],
                [
                    1,
                    90
                ],
                [
                    2,
                    90
                ],
                [
                    3,
                    90
                ],
                [
                    4,
                    90
                ]]
		  releasetrend[:TTF]=[]
		  releasetrend[:TTF].push(ttfinfo)
		  
		  		  i=0
          j=j-1
           while i<=j do
             ticketinfo[:data].push([i,rmticketinfo1[i+5]])
             mtirequestinfo[:data].push([i,mtirinfo[i+5]])
             i+=1
            end
		 
		 render json:releasetrend.to_json
	  end
end
