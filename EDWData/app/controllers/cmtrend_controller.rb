class CmtrendController < ApplicationController
def index
       bfxinfo=CmbfxRequestTable.find_by_sql("select \"Modified_l\"  from  cmbfx_request_tables order by \"Modified_l\"")
       
       everymonthdate=Dailyrolluptime.find_by_sql("
	     select * from (
         select \"Year\",\"Month\",max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ) aaa
         where aaa.\"everymaxmonth\" >\'#{bfxinfo[0]["Modified_l"]}\'")  
  
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
	    
	
        bfxclosetinfo=Array.new(20,0)
		  j=0	
	      i=0
		 while i< monthinfo.length-1 do		    
               bfxinfo=CmbfxRequestTable.find_by_sql("select count(*) as \"countModified\"  from  cmbfx_request_tables where  \"Modified_l\">\'#{monthinfo[i]}\'
 			   and \"Modified_l\"<=\'#{monthinfo[i+1]}\' ")
			   bfxclosetinfo[j]=bfxinfo[0]["countModified"]
			   
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
          bfxtrend={}
		  bfxtrend[:categories]=monthdata
		  
		  
		  rfxclose={}
		  rfxclose[:title]="RFC Number"	  		  
		  rfxclose[:data]=[[
                    0,
                    69
                ],
                [
                    1,
                    60
                ]]
		  bfxtrend[:RFC]=[]
		  bfxtrend[:RFC].push(rfxclose)
		  
		  bfxclose={}
		  bfxclose[:title]="BFX Number"	  		  
		  bfxclose[:data]=[]
		  bfxtrend[:BFX]=[]
		  bfxtrend[:BFX].push(bfxclose)
		  
		  
		  mtpclose={}
		  mtpclose[:title]="MTP Review Meeting"	  		  
		  mtpclose[:data]=[[
                    0,
                    2
                ],
                [
                    1,
                    0
                ],
                [
                    2,
                    2
                ],
                [
                    3,
                    3
                ],
                [
                    3,
                    2
                ],
                [
                    4,
                    3
                ]]
		  bfxtrend[:MTP]=[]
		  bfxtrend[:MTP].push(mtpclose)
		  
		  
		  i=0
          j=j-1
          while i<=j do
             bfxclose[:data].push([i,bfxclosetinfo[i+5]])
             i+=1
          end
		  
		 
		 render json:bfxtrend.to_json
   end
end
