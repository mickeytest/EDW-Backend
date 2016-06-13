class OnboardtrendController < ApplicationController
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
	    
	
        fileloadarrayinfo=Array.new(20,0)
        filenameinfo=Array.new(20,0)
        deepinfo=Array.new(20,0)
		  j=0	
	      i=0
		 while i< monthinfo.length-1 do	
               tttstart=  (DateTime.parse((monthinfo[i]).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00")
		       tttend=  (DateTime.parse((monthinfo[i+1]).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00") 		 
			   onboardinfo=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"requestId\") as \"countttf\"  FROM edw_regression_test_request where \"requestDate\" >=\'#{tttstart}\'and  \"requestDate\" <=\'#{tttend}\' and \"approvalStatus\"='Yes'")
	           onboardinfo1=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"filesName\") as \"countttf\"  FROM edw_regression_test_request where \"requestDate\" >=\'#{tttstart}\'and  \"requestDate\" <=\'#{tttend}\'  and \"approvalStatus\"='Yes'")
               onboarddeepinfo=EdwOpsCallTracker.find_by_sql("SELECT count(distinct \"ID\") as \"countttf\"   FROM sp_edwonboardingdeepsprt where \"EndDate\" >=\'#{tttstart}\'and \"EndDate\"  <=\'#{tttend}\'")
			     fileloadarrayinfo[j]=onboardinfo[0]["countttf"]
			     filenameinfo[j]=onboardinfo1[0]["countttf"]
			     deepinfo[j]=onboarddeepinfo[0]["countttf"]			   
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
          onboardtrend={}
		  onboardtrend[:categories]=monthdata
		  
		  
		  
		  fileloadinfo={}
		  fileloadinfo[:title]="File Loading Request"	  		  
		  fileloadinfo[:data]=[]
		  onboardtrend[:FileRequest]=[]
		  onboardtrend[:FileRequest].push(fileloadinfo)
		  
		  
		  fileprocessinfo={}
		  fileprocessinfo[:title]="File Processed"	  		  
		  fileprocessinfo[:data]=[]
		  onboardtrend[:FileProcessed]=[]
		  onboardtrend[:FileProcessed].push(fileprocessinfo)
          
		  
		  deepsupportinfo={}
		  deepsupportinfo[:title]="Deep Support"	  		  
		  deepsupportinfo[:data]=[]
		  onboardtrend[:DeepSupport]=[]
		  onboardtrend[:DeepSupport].push(deepsupportinfo)
		  
		  
		  
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
		  onboardtrend[:TTO]=[]
		  onboardtrend[:TTO].push(ttoinfo)
		  
		  
		  ttfinfo={}
		  ttfinfo[:title]="TTF"	  		  
		  ttfinfo[:data]=[[
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
		  onboardtrend[:TTF]=[]
		  onboardtrend[:TTF].push(ttfinfo)
		  
		  i=0
          j=j-1
           while i<=j do
             fileloadinfo[:data].push([i,fileloadarrayinfo[i+5]])
             fileprocessinfo[:data].push([i,filenameinfo[i+5]])
             deepsupportinfo[:data].push([i,deepinfo[i+5]])
             i+=1
            end
		 
		 render json:onboardtrend.to_json
	  end
end
