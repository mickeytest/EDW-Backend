class RollupbyearlyportfolioController < ApplicationController
     def index
	      pf= params[:Environment] 
   
   scamet=Array.new(20,0)
   scamis=Array.new(20,0)
   expmet=Array.new(20,0)
   expmis=Array.new(20,0)
   rodmet=Array.new(20,0)
   rodmis=Array.new(20,0)
   rolluptimes=Array.new(20,0)
   rollupcount=Array.new(20,0)

          everymonthdate=MecCalendar.find_by_sql("select \"Year\",\"Month\",max(\"MECEndDate_l\") as \"everymaxmonth\" from mec_calendars where  \"Environment\"='ZEO' group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ") 

   dstinfor   =Dst.find_by_sql("select * from dsts where \"DST_TYPE\"='CET' order by \"Environment\" asc ")
   i=0

 	
   
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
     
   a=0
   j=0
   i=6

   while i< monthinfo.length-1 do
	 domaininfo= Dailyrolluptime.find_by_sql("select * from( 
(select \"EVENT_ID\" from mid_rollup_domains where \"Rollup_Domain\" in( 'SCA-STOP','EXPNFIN-STOP','RODATTNMT-STOP'))  a left join 
(select  \"EVENT_ID\",\"End_TS_l\",\"SERVER\",\"End_TS_l\"  from rollupstatuses where \"End_TS_l\">\'#{monthinfo[i]}}\' and \"End_TS_l\"<\'#{monthinfo[i+1]}\' and \"SERVER\"!='BER') b  on a.\"EVENT_ID\"=b.\"EVENT_ID\" ) dd  where dd.\"SERVER\" is not null") 
   
     domaininfo.each do |r|
	     if((pf=='ALL' || pf=='ZEO') &&  r["SERVER"]=='ZEO')
		     if(r["End_TS_l"].strftime("%H").to_i >9)
			     if(r["EVENT_ID"] == "12611.DP.999.1")
				    scamis[j]+=1
				 elsif(r["EVENT_ID"] == "16973.DP.999.1")
				    expmis[j]+=1
				 elsif(r["EVENT_ID"] == "22231.DP.999.1")
				    rodmis[j]+=1
				 end
			 else
			     if(r["EVENT_ID"] == "12611.DP.999.1")
				    scamet[j]+=1
				 elsif(r["EVENT_ID"] == "16973.DP.999.1")
				    expmet[j]+=1
				 elsif(r["EVENT_ID"] == "22231.DP.999.1")
				    rodmet[j]+=1
				 end
			 end
		 elsif((pf=='ALL' || pf=='EMR') &&  r["SERVER"]=='EMR')
		     if(r["End_TS_l"].strftime("%H").to_i >9)
			     if(r["EVENT_ID"] == "12611.DP.999.1")
				    scamis[j]+=1
				 elsif(r["EVENT_ID"] == "16973.DP.999.1")
				    expmis[j]+=1
				 elsif(r["EVENT_ID"] == "22231.DP.999.1")
				    rodmis[j]+=1
				 end
			 else
			     if(r["EVENT_ID"] == "12611.DP.999.1")
				    scamet[j]+=1
				 elsif(r["EVENT_ID"] == "16973.DP.999.1")
				    expmet[j]+=1
				 elsif(r["EVENT_ID"] == "22231.DP.999.1")
				    rodmet[j]+=1
				 end
			 end	 
		 elsif((pf=='ALL' || pf=='JAD') && r["SERVER"]=='JAD')
		     if(r["End_TS_l"].strftime("%H").to_i >9)
			     if(r["EVENT_ID"] == "12611.DP.999.1")
				    scamis[j]+=1
				 elsif(r["EVENT_ID"] == "16973.DP.999.1")
				    expmis[j]+=1
				 elsif(r["EVENT_ID"] == "22231.DP.999.1")
				    rodmis[j]+=1
				 end
			 else
			     if(r["EVENT_ID"] == "12611.DP.999.1")
				    scamet[j]+=1
				 elsif(r["EVENT_ID"] == "16973.DP.999.1")
				    expmet[j]+=1
				 elsif(r["EVENT_ID"] == "22231.DP.999.1")
				    rodmet[j]+=1
				 end
			 end			
		 end  	
		 end
		 j+=1
		 i+=1
end   
   portfolio=Hash.new
 if(Time.new <everymonthdate[everymonthdate.length-1]["everymaxmonth"])
		         slength= everymonthdate.length
				 portfolio[:lastmonthfinished]=false
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
  
 portfolio[:categories]=monthdata
 portfolio[:SCA]=[]
 portfolio[:EXPNFIN]=[]
 portfolio[:RODATTNMT]=[]

 i=0
 j=j-1
 while i<=j do
 portfolio[:SCA].push(((scamet[i]+ scamis[i])==0) ?0: (((scamet[i] / (scamet[i]+ scamis[i]).to_f))*100).round(0))
 portfolio[:EXPNFIN].push(((expmet[i]+ expmis[i])==0) ?0: (((expmet[i] / (expmet[i]+ expmis[i]).to_f))*100).round(0))
 portfolio[:RODATTNMT].push(((rodmet[i]+ rodmis[i])==0) ?0: (((rodmet[i] / (rodmet[i]+ rodmis[i]).to_f))*100).round(0))
 i+=1
 end
  
render json:portfolio.to_json   
end
end
