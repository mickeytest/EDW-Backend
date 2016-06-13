class SlabreachController < ApplicationController

def index
   pf= params[:Environment] 
   
   serverinfo=Array.new
   serverinfo[0]='ZEO'
   serverinfo[1]='EMR'
   serverinfo[2]='JAD'
   metsla=Array.new(20,0)
   missla=Array.new(20,0)
   mecmeet=Array.new(20,0)
   mecmiss=Array.new(20,0)
   nonmecmeet=Array.new(20,0)
   nonmecmiss=Array.new(20,0)
   rolluptimes=Array.new(20,0)
   rollupcount=Array.new(20,0)
   if(pf=='ALL')
       jjj=0
          while jjj<serverinfo.length do
          everymonthdate=MecCalendar.find_by_sql("select \"Year\",\"Month\",max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars where \"Environment\"=\'#{serverinfo[jjj]}\' and \"MECStartDate\"<now() group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ") 

   rollupinfor=Dailyrolluptime.find_by_sql("select \"Server\",\"RollupDate\",\"End_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"Server\"=\'#{serverinfo[jjj]}\' and \"RollupDate\">\'#{everymonthdate[0]["everymaxmonth"]}\' order by \"RollupDate\"") 
   dstinfor   =Dst.find_by_sql("select * from dsts where \"DST_TYPE\"='CET' order by \"Environment\" asc ")
   i=0

 	
   
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
     
   a=0
   j=0
   i=0
     
   while i< monthinfo.length-1 do
        dailyrollupinfo=Dailyrolluptime.find_by_sql("select *  from  dailyrolluptimes where \"Server\"=\'#{serverinfo[jjj]}\' and \"End_TS\" is not null and \"RollupDate\">\'#{monthinfo[i]}}\'
 			   and \"RollupDate\"<=\'#{monthinfo[i+1]}\' ")
	 mecZEOinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">\'#{monthinfo[i]}}\' and \"MECStartDate\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='ZEO'")
	 mecEMRinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">\'#{monthinfo[i]}}\'  and \"MECStartDate\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='EMR'")
     mecJADinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">\'#{monthinfo[i]}}\' and \"MECStartDate\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='JAD'")

		 a=0
         while a<dailyrollupinfo.length do	 
         if(dailyrollupinfo[a]["Server"]=='ZEO')
		        
		     # puts (DateTime.parse((dailyrollupinfo[a]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 10/24.0) 
				if( (DateTime.parse((dailyrollupinfo[a]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 10/24.0) <=dailyrollupinfo[a]["End_TS"])
				    missla[j]= missla[j]+1			
					tt=0
					ifmecornot=false
					while tt < mecZEOinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecZEOinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecZEOinfo[tt]["MECEndDate"])
						ifmecornot=true	
						mecmiss[j]=mecmiss[j]+1	
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecZEOinfo.length
					end			        
					tt+=1					
			        end
					if(ifmecornot==false)
					   nonmecmiss[j]=nonmecmiss[j]+1
                       rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]					   
					end

				else
				    metsla[j]= metsla[j]+1

				    tt=0
					ifmecornot=false
					while tt < mecZEOinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecZEOinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecZEOinfo[tt]["MECEndDate"])
						ifmecornot=true	
						mecmeet[j]=mecmeet[j]+1	
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecZEOinfo.length
					end			        
					tt+=1					
			        end				    
                    if(ifmecornot==false)
					   nonmecmeet[j]=nonmecmeet[j]+1
                       rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]					   
					end		
					
				end	
				
		 elsif(dailyrollupinfo[a]["Server"]=='EMR')
		 		if( (DateTime.parse((dailyrollupinfo[a]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 10/24.0) <=dailyrollupinfo[a]["End_TS"])
				    tt=0
					missla[j]= missla[j]+1
					ifmecornot=false
					while tt < mecEMRinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecEMRinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecEMRinfo[tt]["MECEndDate"])
                        ifmecornot=true	
						mecmiss[j]+=1
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecEMRinfo.length
					end			        
					tt+=1					
			        end					
					if(ifmecornot==false)
					   nonmecmiss[j]+=1	 
					   rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end
				else
				    tt=0
					ifmecornot=false
					while tt < mecEMRinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecEMRinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecEMRinfo[tt]["MECEndDate"])
                        ifmecornot=true	
						mecmeet[j]+=1					
			            tt=mecEMRinfo.length
						rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end			        
					tt+=1					
			        end
				    metsla[j]=metsla[j]+1
					if(ifmecornot==false)
					   nonmecmeet[j]+=1	 
					   rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end	
				end		
		 elsif(dailyrollupinfo[a]["Server"]=='JAD')
		        if( (DateTime.parse((dailyrollupinfo[a]["RollupDate"]).strftime("%Y/%m/%d")+ ' 19:00:00') + 10/24.0) <=dailyrollupinfo[a]["End_TS"])
				     tt=0
					 ifmecornot=false
					while tt < mecJADinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecJADinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecJADinfo[tt]["MECEndDate"])
                        ifmecornot=true	
						mecmiss[j]+=1					
			            tt=mecJADinfo.length
						rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end			        
					tt+=1					
			        end
					missla[j]= missla[j]+1	
                    if(ifmecornot==false)
					   nonmecmiss[j]+=1	
                       rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]					   
					end					 
				else
				    tt=0
					ifmecornot=false
					while tt < mecJADinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecJADinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecJADinfo[tt]["MECEndDate"])
                        ifmecornot=true	
						mecmeet[j]+=1					
			            tt=mecJADinfo.length
						rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end			        
					tt+=1					
			        end
				    metsla[j]= metsla[j]+1
					if(ifmecornot==false)
					   nonmecmeet[j]+=1	 
					   rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end	
				end		 
		 end
		 a+=1
		 end
	  i+=1
	  j+=1
   end

   slahash=Hash.new
 if(Time.new <everymonthdate[everymonthdate.length-1]["everymaxmonth"])
		         slength= everymonthdate.length
				 slahash[:lastmonthfinished]=true
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
           while i< slength
               monthdata[j]=(DateTime.parse(everymonthdate[i]["Year"].to_s + '-' + everymonthdate[i]["Month"].to_s + '-01')).strftime("%b,%Y")
               i+=1
               j+=1
           end
		  jjj+=1
          end
else
      everymonthdate=MecCalendar.find_by_sql("select \"Year\",\"Month\",max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars where \"Environment\"=\'#{pf}\' and \"MECStartDate\"<now() group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ") 

      rollupinfor=Dailyrolluptime.find_by_sql("select \"Server\",\"RollupDate\",\"End_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"Server\"=\'#{pf}\' and \"RollupDate\">\'#{everymonthdate[0]["everymaxmonth"]}\' order by \"RollupDate\"") 
      dstinfor   =Dst.find_by_sql("select * from dsts where \"DST_TYPE\"='CET' order by \"Environment\" asc ")
      i=0

 	
   
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
   

   
   a=0
   j=0
   i=0
   
   
   while i< monthinfo.length-1 do
        dailyrollupinfo=Dailyrolluptime.find_by_sql("select *  from  dailyrolluptimes where \"Server\"=\'#{pf}\' and \"End_TS\" is not null and \"RollupDate\">\'#{monthinfo[i]}}\'
 			   and \"RollupDate\"<=\'#{monthinfo[i+1]}\' ")
	 mecZEOinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">\'#{monthinfo[i]}}\' and \"MECStartDate\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='ZEO'")
	 mecEMRinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">\'#{monthinfo[i]}}\'  and \"MECStartDate\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='EMR'")
     mecJADinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">\'#{monthinfo[i]}}\' and \"MECStartDate\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='JAD'")

		 a=0
         while a<dailyrollupinfo.length do	 
         if(dailyrollupinfo[a]["Server"]=='ZEO')
		        
		      #puts (DateTime.parse((dailyrollupinfo[a]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 10/24.0) 
				if( (DateTime.parse((dailyrollupinfo[a]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 10/24.0) <=dailyrollupinfo[a]["End_TS"])
				    missla[j]= missla[j]+1					
					tt=0
					ifmecornot=false
					while tt < mecZEOinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecZEOinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecZEOinfo[tt]["MECEndDate"])
						ifmecornot=true	
						mecmiss[j]=mecmiss[j]+1
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecZEOinfo.length
					end			        
					tt+=1					
			        end
					if(ifmecornot==false)
					   nonmecmiss[j]=nonmecmiss[j]+1	
                       rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]					   
					end

				else
				    metsla[j]= metsla[j]+1
				    tt=0
					ifmecornot=false
					while tt < mecZEOinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecZEOinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecZEOinfo[tt]["MECEndDate"])
						ifmecornot=true	
						mecmeet[j]=mecmeet[j]+1
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecZEOinfo.length
					end			        
					tt+=1					
			        end				    
                    if(ifmecornot==false)
					   nonmecmeet[j]=nonmecmeet[j]+1
                       rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]					   
					end		
					
				end	
				
		 elsif(dailyrollupinfo[a]["Server"]=='EMR')
		        
		 		if( (DateTime.parse((dailyrollupinfo[a]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 10/24.0) <=dailyrollupinfo[a]["End_TS"])
				    tt=0
					ifmecornot=false
					while tt < mecEMRinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecEMRinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecEMRinfo[tt]["MECEndDate"])
                        ifmecornot=true	
						mecmiss[j]+=1	
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecEMRinfo.length
					end			        
					tt+=1					
			        end
					missla[j]= missla[j]+1
					if(ifmecornot==false)
					   nonmecmiss[j]+=1	 
					   rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end
				else
				    tt=0
					ifmecornot=false
					while tt < mecEMRinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecEMRinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecEMRinfo[tt]["MECEndDate"])
                        ifmecornot=true	
						mecmeet[j]+=1		
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecEMRinfo.length
					end			        
					tt+=1					
			        end
				    metsla[j]=metsla[j]+1
					if(ifmecornot==false)
					   nonmecmeet[j]+=1	 
					   rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end	
				end		
		 elsif(dailyrollupinfo[a]["Server"]=='JAD')
		        
		        if( (DateTime.parse((dailyrollupinfo[a]["RollupDate"]).strftime("%Y/%m/%d")+ ' 19:00:00') + 10/24.0) <=dailyrollupinfo[a]["End_TS"])
				     tt=0
					 ifmecornot=false
					while tt < mecJADinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecJADinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecJADinfo[tt]["MECEndDate"])
                        ifmecornot=true	
						mecmiss[j]+=1		
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecJADinfo.length
					end			        
					tt+=1					
			        end
					missla[j]= missla[j]+1	
                    if(ifmecornot==false)
					   nonmecmiss[j]+=1	 
					   rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end					 
				else
				    tt=0
					ifmecornot=false
					while tt < mecJADinfo.length do
			        if (ifmecornot==false && dailyrollupinfo[a]["RollupDate"]>=mecJADinfo[tt]["MECStartDate"]  &&  dailyrollupinfo[a]["RollupDate"]<=mecJADinfo[tt]["MECEndDate"])
                        ifmecornot=true	
						mecmeet[j]+=1	
                        rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]						
			            tt=mecJADinfo.length
					end			        
					tt+=1					
			        end
				    metsla[j]= metsla[j]+1
					if(ifmecornot==false)
					   nonmecmeet[j]+=1	 
					   rolluptimes[j]+=dailyrollupinfo[a]["ElapseTime"]
					end	
				end		 
		 end
		 a+=1
		 end
	  i+=1
	  j+=1
   end
       slahash=Hash.new

 
 if(Time.new <everymonthdate[everymonthdate.length-1]["everymaxmonth"])
		         slength= everymonthdate.length
				 slahash[:lastmonthfinished]=true
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
           while i< slength
               monthdata[j]=(DateTime.parse(everymonthdate[i]["Year"].to_s + '-' + everymonthdate[i]["Month"].to_s + '-01')).strftime("%b,%Y")
               i+=1
               j+=1
           end
   
   
   end

  
 slahash[:RollupTime]=[]
 slahash[:categories]=monthdata
 slahash[:MEC]=[]
 slahash[:NonMEC]=[]
 slahash[:Total]=[]

 i=0
 j=j-1
 while i<=j do
 slahash[:RollupTime].push(((missla[i]+metsla[i])==0) ?0: (((rolluptimes[i]/(missla[i]+metsla[i]).to_f))).round(1))
 slahash[:MEC].push(   ((mecmeet[i]+ mecmiss[i])==0) ?0: (((mecmeet[i] / (mecmeet[i]+ mecmiss[i]).to_f))*100).round(0))
 slahash[:NonMEC].push( ((nonmecmeet[i]+ nonmecmiss[i])==0) ?0  :(((nonmecmeet[i] / (nonmecmeet[i]+ nonmecmiss[i]).to_f))*100).round(0))
 slahash[:Total].push(((metsla[i]+ missla[i])==0) ?0 : (((metsla[i] / (metsla[i]+ missla[i]).to_f))*100).round(0))
 i+=1
 end
  
render json:slahash.to_json   
end

def index1
     if(params[:month]==nil && params[:from]==nil)

mecstarttime=nil
mecendtime=nil
mectitleinfo=nil
nonmectitleinfo=nil
prorollupmatic=Hash.new
   monthinfo=Array.new  
   metsla=Array.new(20,0)
   missla=Array.new(20,0)
   slahash=Hash.new
   slahash["sladetailed"]=[]
   monday=Array.new(6,0)
   tuesday=Array.new(6,0)
   wednesday=Array.new(6,0)
   thursday=Array.new(6,0)
   friday=Array.new(6,0)
   saturday=Array.new(6,0)
   sunday=Array.new(6,0)
   		  jaddatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='JAD' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
          emrdatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='EMR' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
		  zeodatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='ZEO' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
	
	   first=true
    i=0
   while i<jaddatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((jaddatascope[i]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   mecstartjadinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{jaddatascope[i]["Year"]}\'  and \"Month\"=\'#{jaddatascope[i]["Month"]}\'")
		   first=false
		 end
		 i+=1
   end
   
   first=true
   i=0
   while i<emrdatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((emrdatascope[i]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   mecstartemrinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{emrdatascope[i]["Year"]}\'  and \"Month\"=\'#{emrdatascope[i]["Month"]}\'")
		   first=false
		 end
		 i+=1
   end
   
     first=true
    i=0
   while i<zeodatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((zeodatascope[i]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   mecstartzeoinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{zeodatascope[i]["Year"]}\'  and \"Month\"=\'#{zeodatascope[i]["Month"]}\'")
		   first=false
		 end
		 i+=1
   end

	dateend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S") 
	
	rollupzeoinfor=Dailyrolluptime.find_by_sql("select * from(select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecstartzeoinfo[0]["currentstarttime"]}\' and \"RollupDate\"<=\'#{dateend}\' and \"Server\"='ZEO' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\" from msasla_breach_trackers)  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"") 
	rollupemrinfor=Dailyrolluptime.find_by_sql("select *  from(select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecstartemrinfo[0]["currentstarttime"]}\' and \"RollupDate\"<=\'#{dateend}\' and \"Server\"='EMR' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\"    from msasla_breach_trackers)  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"") 
	rollupjadinfor=Dailyrolluptime.find_by_sql("select *  from(select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecstartjadinfo[0]["currentstarttime"]}\' and \"RollupDate\"<=\'#{dateend}\' and \"Server\"='JAD' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\"  from msasla_breach_trackers)  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"") 
	
          slahash=Hash.new
          slahash["sladetailed"]=[]
		  slahash[:missSLA]={:data=>[],:drilldown=>[]}
		  weekinfo=["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
		  i=0
		  while i<weekinfo.length do
		      slahash[:missSLA][:data].push({:name=>weekinfo[i],:y=>0,:drilldown=>weekinfo[i]})
			  slahash[:missSLA][:drilldown].push({:id=>weekinfo[i],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
			  i+=1
		  end
		  
if(params[:env]=='ZEO' || params[:env]=='ALL')
   i=0
   while i<rollupzeoinfor.length do
      if( (DateTime.parse((rollupzeoinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 10/24.0) <=rollupzeoinfor[i]["End_TS"])
				     missla[0]= missla[0]+1
                     if(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    slahash[:missSLA][:data][6][:y]+=1
						slahash[:missSLA][:drilldown][6][:data][0][1]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    slahash[:missSLA][:data][0][:y]+=1
						slahash[:missSLA][:drilldown][0][:data][0][1]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][0][1]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][0][1]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][0][1]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    slahash[:missSLA][:data][4][:y]+=1
						slahash[:missSLA][:drilldown][4][:data][0][1]+=1
					 else
					    slahash[:missSLA][:data][5][:y]+=1
						slahash[:missSLA][:drilldown][5][:data][0][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupzeoinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupzeoinfor[i]["Server"]),
					 :Week=>rollupzeoinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupzeoinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupzeoinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Miss",
					 :SLAMissReason=>rollupzeoinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				    if(((DateTime.parse((rollupzeoinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 10/24.0) >rollupzeoinfor[i]["End_TS"])&&
					((DateTime.parse((rollupzeoinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 01:45:00') + 10/24.0) <rollupzeoinfor[i]["End_TS"])
					) 
				     metsla[0]= metsla[0]+1
					
					 if(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[3]+=1
					 else
					    saturday[3]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupzeoinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupzeoinfor[i]["Server"]),
					 :Week=>rollupzeoinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupzeoinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupzeoinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupzeoinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupzeoinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupzeoinfor[i]["Server"]),
					 :Week=>rollupzeoinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupzeoinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupzeoinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :T15Mins=>'0'
					 )				 
				  end	
                  end
				  i+=1
    end
end

if(params[:env]=='ZEO' || params[:env]=='EMR')   
    i=0
    while i<rollupemrinfor.length do
      if( (DateTime.parse((rollupemrinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 10/24.0) <=rollupemrinfor[i]["End_TS"])
				     missla[1]= missla[1]+1
					 if(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    slahash[:missSLA][:data][6][:y]+=1
						slahash[:missSLA][:drilldown][6][:data][2][1]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    slahash[:missSLA][:data][0][:y]+=1
						slahash[:missSLA][:drilldown][0][:data][2][1]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][2][1]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][2][1]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][2][1]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    slahash[:missSLA][:data][4][:y]+=1
						slahash[:missSLA][:drilldown][4][:data][2][1]+=1
					 else
					    slahash[:missSLA][:data][5][:y]+=1
						slahash[:missSLA][:drilldown][5][:data][2][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupemrinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupemrinfor[i]["Server"]),
					 :Week=>rollupemrinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupemrinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupemrinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Miss",
					 :SLAMissReason=>rollupemrinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				    if(((DateTime.parse((rollupemrinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 10/24.0) >rollupemrinfor[i]["End_TS"])&&
					((DateTime.parse((rollupemrinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 08:45:00') + 10/24.0) <rollupemrinfor[i]["End_TS"])
					) 
				     metsla[1]=metsla[1]+1
					 if(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[4]+=1
					 else
					    saturday[4]+=1
					 end
					slahash["sladetailed"].push(
					 :Date=>(rollupemrinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupemrinfor[i]["Server"]),
					 :Week=>rollupemrinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupemrinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupemrinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupemrinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupemrinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupemrinfor[i]["Server"]),
					 :Week=>rollupemrinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupemrinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupemrinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupemrinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'0'
					 )		 
				  end	
                  end
				  i+=1
   end
end

if(params[:env]=='ZEO' || params[:env]=='JAD')   
   i=0
   while i<rollupjadinfor.length do
      if((DateTime.parse((rollupjadinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 19:00:00') + 10/24.0) <=rollupjadinfor[i]["End_TS"])
				     missla[2]= missla[2]+1
					 if(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    slahash[:missSLA][:data][6][:y]+=1
						slahash[:missSLA][:drilldown][6][:data][1][1]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    slahash[:missSLA][:data][0][:y]+=1
						slahash[:missSLA][:drilldown][0][:data][1][1]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][1][1]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][1][1]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][1][1]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    slahash[:missSLA][:data][4][:y]+=1
						slahash[:missSLA][:drilldown][4][:data][1][1]+=1
					 else
					    slahash[:missSLA][:data][5][:y]+=1
						slahash[:missSLA][:drilldown][5][:data][1][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupjadinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupjadinfor[i]["Server"]),
					 :Week=>rollupjadinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupjadinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupjadinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Miss",
					 :SLAMissReason=>rollupjadinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				    if(((DateTime.parse((rollupjadinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 19:00:00') + 10/24.0) >rollupjadinfor[i]["End_TS"])&&
					((DateTime.parse((rollupjadinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 18:45:00') + 10/24.0) <rollupjadinfor[i]["End_TS"])
					) 
				    metsla[2]=metsla[2]+1
					 if(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[5]+=1
					 else
					    saturday[5]+=1
					 end
					slahash["sladetailed"].push(
					 :Date=>(rollupjadinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupjadinfor[i]["Server"]),
					 :Week=>rollupjadinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupjadinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupjadinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupjadinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupjadinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupjadinfor[i]["Server"]),
					 :Week=>rollupjadinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupjadinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupjadinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupjadinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'0'
					 )			 
				  end	
                  end
				  i+=1
   end
end

    rollupzeoslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\",\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecstartzeoinfo[0]["currentstarttime"]}\' and \"RollupDate\"<=\'#{dateend}\' and \"Server\"='ZEO' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\"  from msasla_breach_trackers  where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
         ) dd where dd.\"SLA_Met\" is not null group by  dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")		 
	
	rollupemrslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*) as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecstartemrinfo[0]["currentstarttime"]}\' and \"RollupDate\"<=\'#{dateend}\' and \"Server\"='EMR' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\"  ,\"SLA_Met\"  from msasla_breach_trackers  where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\" 
		   ) dd where dd.\"SLA_Met\" is not null group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")	
		   
	rollupjadslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecstartjadinfo[0]["currentstarttime"]}\' and \"RollupDate\"<=\'#{dateend}\' and \"Server\"='JAD' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")	

		  
	countslaraasonzeo=0
    countslaraasonemr=0
    countslaraasonjad=0
	slahash[:missSLAReason]={} 
	slahash[:missSLAReason][:data]=[]

	slahash[:missSLAReason][:drilldown]=[]
	slazeohash={}
	slazeohash["id"]="ZEO"
	slazeohash["data"]=[]
	slaemrhash={}
	slaemrhash["id"]="EMR"
	slaemrhash["data"]=[]
	slajadhash={}
	slajadhash["id"]="JAD"
	slajadhash["data"]=[]
	if(params[:env]=='ZEO')
	slahash[:missSLAReason][:drilldown].push(slazeohash)
	elsif(params[:env]=='EMR')
	slahash[:missSLAReason][:drilldown].push(slaemrhash)
	elsif(params[:env]=='JAD')
	slahash[:missSLAReason][:drilldown].push(slajadhash)
	elsif(params[:env]=='ALL')
	slahash[:missSLAReason][:drilldown].push(slazeohash,slaemrhash,slajadhash)
	end
	
	i=0
	while i<rollupzeoslareason.length do
	   slazeohash["data"].push([(rollupzeoslareason[i]["SLA_Miss_Reason"]==nil ? "Other":rollupzeoslareason[i]["SLA_Miss_Reason"]),rollupzeoslareason[i]["count"]])
	   countslaraasonzeo+=rollupzeoslareason[i]["count"]
	i+=1
	end
	
	i=0
	while i<rollupemrslareason.length do
	   slaemrhash["data"].push([(rollupemrslareason[i]["SLA_Miss_Reason"]==nil ? "Other":rollupemrslareason[i]["SLA_Miss_Reason"]),rollupemrslareason[i]["count"]])
	   countslaraasonemr+=rollupemrslareason[i]["count"]
	i+=1
	end
	
	
	i=0
	while i<rollupjadslareason.length do
	   slajadhash["data"].push([(rollupjadslareason[i]["SLA_Miss_Reason"]==nil ? "Other":rollupjadslareason[i]["SLA_Miss_Reason"]),rollupjadslareason[i]["count"]])
	   countslaraasonjad+=rollupjadslareason[i]["count"]
	i+=1
	end

	
if(params[:env]!='ALL')
    if(params[:env]=='ZEO')
	    crossing=3
		metcross=0
		reason=countslaraasonzeo
	elsif(params[:env]=='EMR')
	    crossing=4
		metcross=1
		reason=countslaraasonemr
	elsif(params[:env]=='JAD')
	    crossing=5
		metcross=2
		reason=countslaraasonjad
	end
	
    slahash[:missSLAReason][:data]=
	[
#	{:name=>"ZEO",:y=>countslaraasonzeo,:drilldown=>"ZEO"},
#	{:name=>"EMR",:y=>countslaraasonemr,:drilldown=>"EMR"},
	{:name=>params[:env],:y=>reason,:drilldown=>params[:env]}
	]
	 
    slahash[:metSLA]={}
    slahash[:metSLA][:data]=[
#	{:name=>"ZEO",:y=>metsla[0],:drilldown=>"ZEO"},
#	{:name=>"EMR",:y=>metsla[1],:drilldown=>"EMR"},
	{:name=>params[:env],:y=>metsla[metcross],:drilldown=>params[:env]},	
	]
   
	slahash[:metSLA][:drilldown]=[
       {
            :id=> params[:env],
            :data=> [["Monday", monday[crossing]],
                ["Tuesday",tuesday[crossing]],
                ["Wednesday",wednesday[crossing]],
                ["Thursday",thursday[crossing]],
                ["Friday",friday[crossing]],
                [ "Saturday", saturday[crossing]],
                ["Sunday",sunday[crossing]]]
        },	
		]
else
        slahash[:missSLAReason][:data]=
	[
	{:name=>"ZEO",:y=>countslaraasonzeo,:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>countslaraasonemr,:drilldown=>"EMR"},
	{:name=>"JAD",:y=>countslaraasonjad,:drilldown=>"JAD"}
	]
	 
    slahash[:metSLA]={}
    slahash[:metSLA][:data]=[
	{:name=>"ZEO",:y=>metsla[0],:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>metsla[1],:drilldown=>"EMR"},
	{:name=>"JAD",:y=>metsla[2],:drilldown=>"JAD"},	
	]
    	slahash[:metSLA][:drilldown]=[
       {
            :id=> "ZEO",
            :data=> [["Monday", monday[3]],
                ["Tuesday",tuesday[3]], 
                ["Wednesday",wednesday[3]],
                ["Thursday",thursday[3]],
                ["Friday",friday[3]],
                [ "Saturday", saturday[3]],
                ["Sunday",sunday[3]]]
        },
       {
            :id=> "EMR",
            :data=> [["Monday",monday[4]],
                ["Tuesday",tuesday[4]],
                ["Wednesday",wednesday[4]],
                ["Thursday",thursday[4]],
                ["Friday",friday[4]],
                [ "Saturday", saturday[4]],
                ["Sunday",sunday[4]]]
        },
        {
            :id=> "JAD",
            :data=> [["Monday",monday[5]],
                ["Tuesday",tuesday[5]],
                ["Wednesday",wednesday[5]],
                ["Thursday",thursday[5]],
                ["Friday",friday[5]],
                [ "Saturday", saturday[5]],
                ["Sunday",sunday[5]]]
        }
    ]
end	
=begin
if(params[:env]!='ALL')	
    if(params[:env]=='ZEO')
	    crossing=0
		miscross=0
	elsif(params[:env]=='EMR')
	    crossing=1
		miscross=1
	elsif(params[:env]=='JAD')
	    crossing=2
		miscross=2
	end
	
	slahash[:missSLA]={}
	 slahash[:missSLA][:data]=[
#	{:name=>"ZEO",:y=>missla[0],:drilldown=>"ZEO"},
#	{:name=>"EMR",:y=>missla[1],:drilldown=>"EMR"},
    {:name=>params[:env],:y=>missla[miscross],:drilldown=>params[:env]},	
	]
    
	slahash[:missSLA][:drilldown]=[ {
            :id=> params[:env],
            :data=> [["Monday",monday[crossing]],
                ["Tuesday",tuesday[crossing]],
                ["Wednesday",wednesday[crossing]],
                ["Thursday",thursday[crossing]],
                ["Friday",friday[crossing]],
                [ "Saturday", saturday[crossing]],
                ["Sunday",sunday[crossing]]]
        },]
else
    slahash[:missSLA]={}
	 slahash[:missSLA][:data]=[
	{:name=>"ZEO",:y=>missla[0],:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>missla[1],:drilldown=>"EMR"},
    {:name=>"JAD",:y=>missla[2],:drilldown=>"JAD"},	
	]
	
	slahash[:missSLA][:drilldown]=[ {
            :id=> "ZEO",
            :data=> [["Monday",monday[0]],
                ["Tuesday",tuesday[0]],
                ["Wednesday",wednesday[0]],
                ["Thursday",thursday[0]],
                ["Friday",friday[0]],
                [ "Saturday", saturday[0]],
                ["Sunday",sunday[0]]]
        },
        {
            :id=> "EMR",
            :data=> [["Monday", monday[1]],
                ["Tuesday",tuesday[1]],
                ["Wednesday",wednesday[1]],
                ["Thursday",thursday[1]],
                ["Friday",friday[1]],
                [ "Saturday", saturday[1]],
                ["Sunday",sunday[1]]]
        },
        {
            :id=> "JAD",
            :data=> [["Monday",sunday[2]],
                ["Tuesday",tuesday[2]],
                ["Wednesday",wednesday[2]],
                ["Thursday",thursday[2]],
                ["Friday",friday[2]],
                [ "Saturday", saturday[2]],
                ["Sunday",sunday[2]]]
        }
		]
end      
=end   
	render json:slahash.to_json
    
	 elsif(params[:month]!=nil)
	       currentdate = params[:month];
	       monthinfo=Array.new
           metsla=Array.new(20,0)
           missla=Array.new(20,0)  
           monday=Array.new(6,0)
           tuesday=Array.new(6,0)
           wednesday=Array.new(6,0)
           thursday=Array.new(6,0)
           friday=Array.new(6,0)
           saturday=Array.new(6,0)
           sunday=Array.new(6,0)
	       datestartyear=(DateTime.parse(currentdate+ '-01').strftime("%Y")).to_i
	       datestartmonth=(DateTime.parse(currentdate+ '-01').strftime("%m")).to_i 
           if(datestartmonth!=1)
               mecstartzeoinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"= \'#{datestartmonth}\' and \"Environment\"='ZEO' ")
	           mecendzeoinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\'-1 and \"Environment\"='ZEO'")
			   
			   mecstartemrinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"= \'#{datestartmonth}\' and \"Environment\"='EMR'")
	           mecendemrinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\'-1 and \"Environment\"='EMR'")

			   mecstartjadinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"= \'#{datestartmonth}\' and \"Environment\"='JAD'")
	           mecendjadinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\'-1 and \"Environment\"='JAD'")
           else
	           mecstartzeoinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\")  as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\' and \"Environment\"='ZEO'")
	           mecendzeoinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear-1}\'  and \"Month\"=12 and \"Environment\"='ZEO'")
			   
			   mecstartemrinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\")  as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\' and \"Environment\"='EMR'")
	           mecendemrinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear-1}\'  and \"Month\"=12 and \"Environment\"='EMR'")
			   
			   mecstartjadinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\")  as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\' and \"Environment\"='JAD'")
	           mecendjadinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear-1}\'  and \"Month\"=12 and \"Environment\"='JAD'")
	       end  
		  zeodatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate\") as \"MECStartDate\" ,max(\"MECEndDate\") as \"MECEndDate\" from mec_calendars where \"Environment\"='ZEO' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
=begin	   
            if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((zeodatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) && 
			(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               mecstartzeoinfo[0]["starttime"]=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
               mecstartjadinfo[0]["starttime"]=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
               mecstartemrinfo[0]["starttime"]=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
            end		   		    
=end

    p mecendjadinfo[0]["endtime"]
			
	       rollupzeoinfor=Dailyrolluptime.find_by_sql("select * from(select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\",\"End_TS_l\",\"RollupDate_l\"   from dailyrolluptimes where \"End_TS\" is not null and \"Server\"='ZEO' and \"RollupDate\">\'#{mecendzeoinfo[0]["endtime"]}\' and \"RollupDate\"<=\'#{mecstartzeoinfo[0]["starttime"]}\' order by \"RollupDate\" ) a	   
		                           left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"Rollup_Date_l\" as  \"rolluodatel\", \"SLA_Met\" from msasla_breach_trackers)  b on  a.\"RollupDate_l\"=b.\"rolluodatel\"  and a.\"Server\"=b.\"aliasserver\"") 
		   rollupemrinfor=Dailyrolluptime.find_by_sql("select * from(select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\",\"End_TS_l\",\"RollupDate_l\"  from dailyrolluptimes where \"End_TS\" is not null and \"Server\"='EMR' and \"RollupDate\">\'#{mecendemrinfo[0]["endtime"]}\' and \"RollupDate\"<=\'#{mecstartemrinfo[0]["starttime"]}\' order by \"RollupDate\") a	      
		                            left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\",\"Rollup_Date_l\" as  \"rolluodatel\" , \"SLA_Met\" from msasla_breach_trackers)  b on  a.\"RollupDate_l\"=b.\"rolluodatel\"  and a.\"Server\"=b.\"aliasserver\"") 
		   rollupjadinfor=Dailyrolluptime.find_by_sql("select * from(select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\",\"End_TS_l\",\"RollupDate_l\"  from dailyrolluptimes where \"End_TS\" is not null and \"Server\"='JAD' and \"RollupDate\">\'#{mecendjadinfo[0]["endtime"]}\' and \"RollupDate\"<=\'#{mecstartjadinfo[0]["starttime"]}\' order by \"RollupDate\") a	   
                                  left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"Rollup_Date_l\" as  \"rolluodatel\", \"SLA_Met\" from msasla_breach_trackers)  b on  a.\"RollupDate_l\"=b.\"rolluodatel\"  and a.\"Server\"=b.\"aliasserver\" where \"SLA_Met\" is not null") 
	
	
	      rollupzeoslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecendzeoinfo[0]["endtime"]}\' and \"RollupDate\"<=\'#{mecstartemrinfo[0]["starttime"]}\' and \"Server\"='ZEO' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
         ) dd where dd.\"SLA_Met\" is not null group by  dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")		 
	
	      rollupemrslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*) as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecendemrinfo[0]["endtime"]}\' and \"RollupDate\"<=\'#{mecstartemrinfo[0]["starttime"]}\' and \"Server\"='EMR' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\"   ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\" 
		   ) dd where dd.\"SLA_Met\" is not null group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")	

		   rollupjadslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mecendjadinfo[0]["endtime"]}\' and \"RollupDate\"<=\'#{mecstartjadinfo[0]["starttime"]}\' and \"Server\"='JAD' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\"  ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")	

    
          slahash=Hash.new
          slahash["sladetailed"]=[]
		  slahash[:missSLA]={:data=>[],:drilldown=>[]}
		  weekinfo=["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
		  i=0
		  while i<weekinfo.length do
		      slahash[:missSLA][:data].push({:name=>weekinfo[i],:y=>0,:drilldown=>weekinfo[i]})
			  slahash[:missSLA][:drilldown].push({:id=>weekinfo[i],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
			  i+=1
		  end
		  
if(params[:env]=='ZEO' || params[:env]=='ALL')
   i=0
   while i<rollupzeoinfor.length do
      if( (DateTime.parse((rollupzeoinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 11/24.0) <=rollupzeoinfor[i]["End_TS_l"])
				     missla[0]= missla[0]+1
                     if((rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Sunday") && (rollupzeoinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][6][:y]+=1
						slahash[:missSLA][:drilldown][6][:data][0][1]+=1
					 elsif((rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Monday") && (rollupzeoinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][0][:y]+=1
						slahash[:missSLA][:drilldown][0][:data][0][1]+=1
					 elsif((rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Tuesday") && (rollupzeoinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][0][1]+=1
					 elsif((rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Wednesday") && (rollupzeoinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][0][1]+=1
					 elsif((rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Thursday") && (rollupzeoinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][0][1]+=1
					 elsif((rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Friday") && (rollupzeoinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][4][:y]+=1
						slahash[:missSLA][:drilldown][4][:data][0][1]+=1
					 elsif((rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Saturday") && (rollupzeoinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][5][:y]+=1
						slahash[:missSLA][:drilldown][5][:data][0][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupzeoinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupzeoinfor[i]["Server"]),
					 :Week=>rollupzeoinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupzeoinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupzeoinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),			
					 :SLAStatus=>((rollupzeoinfor[i]["SLA_Met"]=='Yes') ? "Meet" :"Miss"),
					 :SLAMissReason=>rollupzeoinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				    if(((DateTime.parse((rollupzeoinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 11/24.0) >rollupzeoinfor[i]["End_TS_l"])&&
					((DateTime.parse((rollupzeoinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 01:45:00') + 11/24.0) <rollupzeoinfor[i]["End_TS_l"])
					) 
				     metsla[0]= metsla[0]+1
					
					 if(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[3]+=1
					 elsif(rollupzeoinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[3]+=1
					 else
					    saturday[3]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupzeoinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupzeoinfor[i]["Server"]),
					 :Week=>rollupzeoinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupzeoinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupzeoinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					   :SLAMissReason=>rollupzeoinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupzeoinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupzeoinfor[i]["Server"]),
					 :Week=>rollupzeoinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupzeoinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupzeoinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					  :SLAMissReason=>rollupzeoinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'0'
					 )				 
				  end	
                  end
				  i+=1
    end
end
if(params[:env]=='EMR' || params[:env]=='ALL')  
    i=0
    while i<rollupemrinfor.length do
      if( (DateTime.parse((rollupemrinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 4/24.0) <=rollupemrinfor[i]["End_TS_l"])
	                if(rollupemrinfor[i]["RollupDate"].strftime("%Y/%m/%d")=='2016/03/08')
					  p (DateTime.parse((rollupemrinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 4/24.0)
					  p rollupemrinfor[i]["End_TS_l"]
					end
				     missla[1]= missla[1]+1
					 if((rollupemrinfor[i]["RollupDate"].strftime("%A")=="Sunday") && (rollupemrinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][6][:y]+=1
						slahash[:missSLA][:drilldown][6][:data][2][1]+=1
					 elsif((rollupemrinfor[i]["RollupDate"].strftime("%A")=="Monday") && (rollupemrinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][0][:y]+=1
						slahash[:missSLA][:drilldown][0][:data][2][1]+=1
					 elsif((rollupemrinfor[i]["RollupDate"].strftime("%A")=="Tuesday") && (rollupemrinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][2][1]+=1
					 elsif((rollupemrinfor[i]["RollupDate"].strftime("%A")=="Wednesday") && (rollupemrinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][2][1]+=1
					 elsif((rollupemrinfor[i]["RollupDate"].strftime("%A")=="Thursday") && (rollupemrinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][2][1]+=1
					 elsif((rollupemrinfor[i]["RollupDate"].strftime("%A")=="Friday") && (rollupemrinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][4][:y]+=1
						slahash[:missSLA][:drilldown][4][:data][2][1]+=1
					 elsif((rollupemrinfor[i]["RollupDate"].strftime("%A")=="Saturday") && (rollupemrinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][5][:y]+=1
						slahash[:missSLA][:drilldown][5][:data][2][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupemrinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupemrinfor[i]["Server"]),
					 :Week=>rollupemrinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupemrinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupemrinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>((rollupemrinfor[i]["SLA_Met"]=='Yes') ? "Meet" :"Miss"),
					   :SLAMissReason=>rollupemrinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				    if(((DateTime.parse((rollupemrinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 4/24.0) >rollupemrinfor[i]["End_TS_l"])&&
					((DateTime.parse((rollupemrinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 08:45:00') + 4/24.0) <rollupemrinfor[i]["End_TS_l"])
					) 
				     metsla[1]=metsla[1]+1
					 if(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[4]+=1
					 elsif(rollupemrinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[4]+=1
					 else
					    saturday[4]+=1
					 end
					slahash["sladetailed"].push(
					 :Date=>(rollupemrinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupemrinfor[i]["Server"]),
					 :Week=>rollupemrinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupemrinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupemrinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupemrinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupemrinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupemrinfor[i]["Server"]),
					 :Week=>rollupemrinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupemrinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupemrinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					    :SLAMissReason=>rollupemrinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'0'
					 )		 
				  end	
                  end
				  i+=1
   end
end
if(params[:env]=='JAD' || params[:env]=='ALL')   
   i=0
   while i<rollupjadinfor.length do
      if((DateTime.parse((rollupjadinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 11/24.0+1) <=rollupjadinfor[i]["End_TS_l"])
				     missla[2]= missla[2]+1
					 if((rollupjadinfor[i]["RollupDate"].strftime("%A")=="Sunday") && (rollupjadinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][6][:y]+=1
						slahash[:missSLA][:drilldown][6][:data][1][1]+=1
					 elsif((rollupjadinfor[i]["RollupDate"].strftime("%A")=="Monday") && (rollupjadinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][0][:y]+=1
						slahash[:missSLA][:drilldown][0][:data][1][1]+=1
					 elsif((rollupjadinfor[i]["RollupDate"].strftime("%A")=="Tuesday") && (rollupjadinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][1][1]+=1
					 elsif((rollupjadinfor[i]["RollupDate"].strftime("%A")=="Wednesday") && (rollupjadinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][1][1]+=1
					 elsif((rollupjadinfor[i]["RollupDate"].strftime("%A")=="Thursday") && (rollupjadinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][1][1]+=1
					 elsif((rollupjadinfor[i]["RollupDate"].strftime("%A")=="Friday") && (rollupjadinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][4][:y]+=1
						slahash[:missSLA][:drilldown][4][:data][1][1]+=1
					  elsif((rollupjadinfor[i]["RollupDate"].strftime("%A")=="Saturday") && (rollupjadinfor[i]["SLA_Met"]=='No'))
					    slahash[:missSLA][:data][5][:y]+=1
						slahash[:missSLA][:drilldown][5][:data][1][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupjadinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupjadinfor[i]["Server"]),
					 :Week=>rollupjadinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupjadinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupjadinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>(rollupjadinfor[i]["SLA_Met"]=='Yes' ? "Meet" : "Miss"),
					 :SLAMissReason=>rollupjadinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				    if(((DateTime.parse((rollupjadinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 11/24.0+1) >rollupjadinfor[i]["End_TS_l"])&&
					((DateTime.parse((rollupjadinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 01:45:00') + 11/24.0+1) <rollupjadinfor[i]["End_TS_l"])
					) 
				    metsla[2]=metsla[2]+1
					 if(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[5]+=1
					 elsif(rollupjadinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[5]+=1
					 else
					    saturday[5]+=1
					 end
					slahash["sladetailed"].push(
					 :Date=>(rollupjadinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupjadinfor[i]["Server"]),
					 :Week=>rollupjadinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupjadinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupjadinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					  :SLAStatus=>(rollupjadinfor[i]["SLA_Met"]=='Yes' ? "Meet" : "Miss"),
					  :SLAMissReason=>rollupjadinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupjadinfor[i]["RollupDate_l"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupjadinfor[i]["Server"]),
					 :Week=>rollupjadinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupjadinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupjadinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					  :SLAStatus=>(rollupjadinfor[i]["SLA_Met"]=='Yes' ? "Meet" : "Miss"),
					  :SLAMissReason=>rollupjadinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'0'
					 )			 
				  end	
                  end
				  i+=1
   end
end  
       countslaraasonzeo=0
    countslaraasonemr=0
    countslaraasonjad=0
	slahash[:missSLAReason]={} 
	slahash[:missSLAReason][:data]=[]
		  
	slahash[:missSLAReason][:drilldown]=[]
	
	
		  
	  
	  
	slazeohash={}
	slazeohash["id"]="ZEO"
	slazeohash["data"]=[]
	slaemrhash={}
	slaemrhash["id"]="EMR"
	slaemrhash["data"]=[]
	slajadhash={}
	slajadhash["id"]="JAD"
	slajadhash["data"]=[]
		if(params[:env]=='ZEO')
	slahash[:missSLAReason][:drilldown].push(slazeohash)
	elsif(params[:env]=='EMR')
	slahash[:missSLAReason][:drilldown].push(slaemrhash)
	elsif(params[:env]=='JAD')
	slahash[:missSLAReason][:drilldown].push(slajadhash)
	elsif(params[:env]=='ALL')
	slahash[:missSLAReason][:drilldown].push(slazeohash,slaemrhash,slajadhash)
	end
	i=0
	while i<rollupzeoslareason.length do
	   slazeohash["data"].push([(rollupzeoslareason[i]["SLA_Miss_Reason"]==nil ? "Other":rollupzeoslareason[i]["SLA_Miss_Reason"]),rollupzeoslareason[i]["count"]])
	   countslaraasonzeo+=rollupzeoslareason[i]["count"]
	i+=1
	end
	
	i=0
	while i<rollupemrslareason.length do
	   slaemrhash["data"].push([(rollupemrslareason[i]["SLA_Miss_Reason"]==nil ? "Other":rollupemrslareason[i]["SLA_Miss_Reason"]),rollupemrslareason[i]["count"]])
	   countslaraasonemr+=rollupemrslareason[i]["count"]
	i+=1
	end
	
	
	i=0
	while i<rollupjadslareason.length do
	   slajadhash["data"].push([(rollupjadslareason[i]["SLA_Miss_Reason"]==nil ? "Other":rollupjadslareason[i]["SLA_Miss_Reason"]),rollupjadslareason[i]["count"]])
	   countslaraasonjad+=rollupjadslareason[i]["count"]
	i+=1
	end
	
if(params[:env]!='ALL')
    if(params[:env]=='ZEO')
	    crossing=3
		metcross=0
		reason=countslaraasonzeo
	elsif(params[:env]=='EMR')
	    crossing=4
		metcross=1
		reason=countslaraasonemr
	elsif(params[:env]=='JAD')
	    crossing=5
		metcross=2
		reason=countslaraasonjad
	end
	
    slahash[:missSLAReason][:data]=
	[
#	{:name=>"ZEO",:y=>countslaraasonzeo,:drilldown=>"ZEO"},
#	{:name=>"EMR",:y=>countslaraasonemr,:drilldown=>"EMR"},
	{:name=>params[:env],:y=>reason,:drilldown=>params[:env]}
	]
	 
    slahash[:metSLA]={}
    slahash[:metSLA][:data]=[
#	{:name=>"ZEO",:y=>metsla[0],:drilldown=>"ZEO"},
#	{:name=>"EMR",:y=>metsla[1],:drilldown=>"EMR"},
	{:name=>params[:env],:y=>metsla[metcross],:drilldown=>params[:env]},	
	]
   

	slahash[:metSLA][:drilldown]=[
       {
            :id=> params[:env],
            :data=> [["Monday", monday[crossing]],
                ["Tuesday",tuesday[crossing]],
                ["Wednesday",wednesday[crossing]],
                ["Thursday",thursday[crossing]],
                ["Friday",friday[crossing]],
                [ "Saturday", saturday[crossing]],
                ["Sunday",sunday[crossing]]]
        },	
		]
else
        slahash[:missSLAReason][:data]=
	[
	{:name=>"ZEO",:y=>countslaraasonzeo,:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>countslaraasonemr,:drilldown=>"EMR"},
	{:name=>"JAD",:y=>countslaraasonjad,:drilldown=>"JAD"}
	]
	 
    slahash[:metSLA]={}
    slahash[:metSLA][:data]=[
	{:name=>"ZEO",:y=>metsla[0],:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>metsla[1],:drilldown=>"EMR"},
	{:name=>"JAD",:y=>metsla[2],:drilldown=>"JAD"},	
	]
    	slahash[:metSLA][:drilldown]=[
       {
            :id=> "ZEO",
            :data=> [["Monday", monday[3]],
                ["Tuesday",tuesday[3]],
                ["Wednesday",wednesday[3]],
                ["Thursday",thursday[3]],
                ["Friday",friday[3]],
                [ "Saturday", saturday[3]],
                ["Sunday",sunday[3]]]
        },
       {
            :id=> "EMR",
            :data=> [["Monday",monday[4]],
                ["Tuesday",tuesday[4]],
                ["Wednesday",wednesday[4]],
                ["Thursday",thursday[4]],
                ["Friday",friday[4]],
                [ "Saturday", saturday[4]],
                ["Sunday",sunday[4]]]
        },
        {
            :id=> "JAD",
            :data=> [["Monday",monday[5]],
                ["Tuesday",tuesday[5]],
                ["Wednesday",wednesday[5]],
                ["Thursday",thursday[5]],
                ["Friday",friday[5]],
                [ "Saturday", saturday[5]],
                ["Sunday",sunday[5]]]
        }
    ]
end	
=begin
if(params[:env]!='ALL')	
    if(params[:env]=='ZEO')
	    crossing=0
		miscross=0
	elsif(params[:env]=='EMR')
	    crossing=1
		miscross=1
	elsif(params[:env]=='JAD')
	    crossing=2
		miscross=2
	end
	
	slahash[:missSLA]={}
	 slahash[:missSLA][:data]=[
#	{:name=>"ZEO",:y=>missla[0],:drilldown=>"ZEO"},
#	{:name=>"EMR",:y=>missla[1],:drilldown=>"EMR"},
    {:name=>params[:env],:y=>missla[miscross],:drilldown=>params[:env]},	
	]
    
	slahash[:missSLA][:drilldown]=[ {
            :id=> params[:env],
            :data=> [["Monday",monday[crossing]],
                ["Tuesday",tuesday[crossing]],
                ["Wednesday",wednesday[crossing]],
                ["Thursday",thursday[crossing]],
                ["Friday",friday[crossing]],
                [ "Saturday", saturday[crossing]],
                ["Sunday",sunday[crossing]]]
        },]
else
    slahash[:missSLA]={}
	 slahash[:missSLA][:data]=[
	{:name=>"ZEO",:y=>missla[0],:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>missla[1],:drilldown=>"EMR"},
    {:name=>"JAD",:y=>missla[2],:drilldown=>"JAD"},	
	]
	
	slahash[:missSLA][:drilldown]=[ {
            :id=> "ZEO",
            :data=> [["Monday",monday[0]],
                ["Tuesday",tuesday[0]],
                ["Wednesday",wednesday[0]],
                ["Thursday",thursday[0]],
                ["Friday",friday[0]],
                [ "Saturday", saturday[0]],
                ["Sunday",sunday[0]]]
        },
        {
            :id=> "EMR",
            :data=> [["Monday", monday[1]],
                ["Tuesday",tuesday[1]],
                ["Wednesday",wednesday[1]],
                ["Thursday",thursday[1]],
                ["Friday",friday[1]],
                [ "Saturday", saturday[1]],
                ["Sunday",sunday[1]]]
        },
        {
            :id=> "JAD",
            :data=> [["Monday",sunday[2]],
                ["Tuesday",tuesday[2]],
                ["Wednesday",wednesday[2]],
                ["Thursday",thursday[2]],
                ["Friday",friday[2]],
                [ "Saturday", saturday[2]],
                ["Sunday",sunday[2]]]
        }
		]
end      
=end    
	render json:slahash.to_json
 
else
	 params[:from]=(DateTime.parse((params[:from]))-1).strftime("%Y-%m-%d")
		 rollupinfor=Dailyrolluptime.find_by_sql("select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{params[:from]}\' and \"RollupDate\"<=\'#{params[:to]}\' order by \"RollupDate\"") 
         i=0  
   monthinfo=Array.new
   metsla=Array.new(20,0)
   missla=Array.new(20,0)
   
   monday=Array.new(6,0)
   tuesday=Array.new(6,0)
   wednesday=Array.new(6,0)
   thursday=Array.new(6,0)
   friday=Array.new(6,0)
   saturday=Array.new(6,0)
   sunday=Array.new(6,0)
    slahash=Hash.new
	slahash["sladetailed"]=[]
   monthinfo[0]=rollupinfor[0]["RollupDate"].strftime("%b,%y")
   a=0
   j=0
   
   	      slahash=Hash.new
          slahash["sladetailed"]=[]
		  slahash[:missSLA]={:data=>[],:drilldown=>[]}
		  weekinfo=["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
		  i=0
		  while i<weekinfo.length do
		      slahash[:missSLA][:data].push({:name=>weekinfo[i],:y=>0,:drilldown=>weekinfo[i]})
			  slahash[:missSLA][:drilldown].push({:id=>weekinfo[i],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
			  i+=1
		  end
   while i< rollupinfor.length do
         if( (i!=0) && (rollupinfor[i]["RollupDate"].strftime("%b,%y") != rollupinfor[i-1]["RollupDate"].strftime("%b,%y")) )
		     a+=1
		     monthinfo[a]=rollupinfor[i]["RollupDate"].strftime("%b,%y")
			 j+=1
		 end
		  		  
         if(rollupinfor[i]["Server"]=='ZEO')
				if( (DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 10/24.0) <=rollupinfor[i]["End_TS"])
				     missla[0]= missla[0]+1
                     if(rollupinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    slahash[:missSLA][:data][6][:y]+=1
						slahash[:missSLA][:drilldown][6][:data][0][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    slahash[:missSLA][:data][0][:y]+=1
						slahash[:missSLA][:drilldown][0][:data][0][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][0][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][0][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][0][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    slahash[:missSLA][:data][4][:y]+=1
						slahash[:missSLA][:drilldown][4][:data][0][1]+=1
					 else
					    slahash[:missSLA][:data][5][:y]+=1
						slahash[:missSLA][:drilldown][5][:data][0][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Miss",
					 :SLAMissReason=>rollupinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				    if(((DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 02:00:00') + 10/24.0) >rollupinfor[i]["End_TS"])&&
					((DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 01:45:00') + 10/24.0) <rollupinfor[i]["End_TS"])
					) 
				     metsla[0]= metsla[0]+1
					
					 if(rollupinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[3]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[3]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[3]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[3]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[3]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[3]+=1
					 else
					    saturday[3]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'0'
					 )				 
				  end	
                  end	 
		 elsif(rollupinfor[i]["Server"]=='EMR')
		 		if( (DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 10/24.0) <=rollupinfor[i]["End_TS"])
				     missla[1]= missla[1]+1
					 if(rollupinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    slahash[:missSLA][:data][6][:y]+=1
						slahash[:missSLA][:drilldown][6][:data][2][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    slahash[:missSLA][:data][0][:y]+=1
						slahash[:missSLA][:drilldown][0][:data][2][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][2][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][2][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][2][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    slahash[:missSLA][:data][4][:y]+=1
						slahash[:missSLA][:drilldown][4][:data][2][1]+=1
					 else
					    slahash[:missSLA][:data][5][:y]+=1
						slahash[:missSLA][:drilldown][5][:data][2][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Miss",
					 :SLAMissReason=>rollupinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				  if(((DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 09:00:00') + 10/24.0) >rollupinfor[i]["End_TS"])&&
					((DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 08:45:00') + 10/24.0) <rollupinfor[i]["End_TS"])
					) 
				     metsla[1]=metsla[1]+1
					 if(rollupinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[4]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[4]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[4]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[4]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[4]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[4]+=1
					 else
					    saturday[4]+=1
					 end
					slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :T15Mins=>'0'
					 )				 
				  end	
                  end	
		 elsif(rollupinfor[i]["Server"]=='JAD')
		        if( (DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 19:00:00') + 10/24.0) <=rollupinfor[i]["End_TS"])
				     missla[2]= missla[2]+1
					 if(rollupinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					     slahash[:missSLA][:data][6][:y]+=1
						 slahash[:missSLA][:drilldown][6][:data][1][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Monday")
					     slahash[:missSLA][:data][0][:y]+=1
						 slahash[:missSLA][:drilldown][0][:data][1][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					     slahash[:missSLA][:data][1][:y]+=1
						slahash[:missSLA][:drilldown][1][:data][1][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					     slahash[:missSLA][:data][2][:y]+=1
						slahash[:missSLA][:drilldown][2][:data][1][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					     slahash[:missSLA][:data][3][:y]+=1
						slahash[:missSLA][:drilldown][3][:data][1][1]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Friday")
					     slahash[:missSLA][:data][4][:y]+=1
						 slahash[:missSLA][:drilldown][4][:data][1][1]+=1
					 else
					     slahash[:missSLA][:data][5][:y]+=1
						 slahash[:missSLA][:drilldown][5][:data][1][1]+=1
					 end
					 slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Miss",
					 :SLAMissReason=>rollupinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'N/A'
					 )
				else
				     if(((DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 19:00:00') + 10/24.0) >rollupinfor[i]["End_TS"])&&
					((DateTime.parse((rollupinfor[i]["RollupDate"]).strftime("%Y/%m/%d")+ ' 18:45:00') + 10/24.0) <rollupinfor[i]["End_TS"])
					) 
				    metsla[2]=metsla[2]+1
					 if(rollupinfor[i]["RollupDate"].strftime("%A")=="Sunday")
					    sunday[5]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Monday")
					    monday[5]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Tuesday")
					    tuesday[5]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Wednesday")
					    wednesday[5]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Thursday")
					    thursday[5]+=1
					 elsif(rollupinfor[i]["RollupDate"].strftime("%A")=="Friday")
					    friday[5]+=1
					 else
					    saturday[5]+=1
					 end
					slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'1'
					 )
			      else
					 slahash["sladetailed"].push(
					 :Date=>(rollupinfor[i]["RollupDate"]).strftime("%Y-%m-%d"),
					 :Environment=>(rollupinfor[i]["Server"]),
					 :Week=>rollupinfor[i]["RollupDate"].strftime("%A"),
					 :StartTime=>(rollupinfor[i]["Start_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :EndTime=>(rollupinfor[i]["End_TS"]).strftime("%Y-%m-%d %H:%M:%S"),
					 :SLAStatus=>"Meet",
					 :SLAMissReason=>rollupinfor[i]["SLA_Miss_Reason"],
					 :T15Mins=>'0'
					 )				 
				  end	
                  end	 
		 end
	  i+=1
   end
  	 
   
    rollupslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\" ,\"Server\" from ( select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{params[:from]}\' and \"RollupDate\"<=\'#{params[:to]}\' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
         ) dd where dd.\"SLA_Miss_Reason\" is not null group by  dd.\"SLA_Miss_Reason\",dd.\"Server\" order by  dd.\"SLA_Miss_Reason\"")		 	
 
	

	countslaraasonzeo=0
    countslaraasonemr=0
    countslaraasonjad=0
	slahash[:missSLAReason]={} 
	slahash[:missSLAReason][:data]=[]
	
	slahash[:missSLAReason][:drilldown]=[]
	slazeohash={}
	slazeohash["id"]="ZEO"
	slazeohash["data"]=[]
	slaemrhash={}
	slaemrhash["id"]="EMR"
	slaemrhash["data"]=[]
	slajadhash={}
	slajadhash["id"]="JAD"
	slajadhash["data"]=[]
	slahash[:missSLAReason][:drilldown].push(slazeohash,
	                                         slaemrhash,
											 slajadhash)
	i=0
	while i<rollupslareason.length do
	   if(rollupslareason[i]["Server"]=='ZEO')
	       slazeohash["data"].push([rollupslareason[i]["SLA_Miss_Reason"],rollupslareason[i]["count"]])
		   countslaraasonzeo+=rollupslareason[i]["count"]
	   elsif(rollupslareason[i]["Server"]=='EMR')
	       slaemrhash["data"].push([rollupslareason[i]["SLA_Miss_Reason"],rollupslareason[i]["count"]])
		   countslaraasonemr+=rollupslareason[i]["count"]
	   elsif(rollupslareason[i]["Server"]=='JAD')
	       slajadhash["data"].push([rollupslareason[i]["SLA_Miss_Reason"],rollupslareason[i]["count"]])
		   countslaraasonjad+=rollupslareason[i]["count"]
	   end	   
	  i+=1
	 end
	   
   slahash[:missSLAReason][:data]=
	[
	{:name=>"ZEO",:y=>countslaraasonzeo,:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>countslaraasonemr,:drilldown=>"EMR"},
	{:name=>"JAD",:y=>countslaraasonjad,:drilldown=>"JAD"}
	]
   
    slahash[:metSLA]={}
    slahash[:metSLA][:data]=[
	{:name=>"ZEO",:y=>metsla[0],:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>metsla[1],:drilldown=>"EMR"},
	{:name=>"JAD",:y=>metsla[2],:drilldown=>"JAD"},	
	]

	slahash[:metSLA][:drilldown]=[
       {
            :id=> "ZEO",
            :data=> [["Monday", monday[3]],
                ["Tuesday",tuesday[3]],
                ["Wednesday",wednesday[3]],
                ["Thursday",thursday[3]],
                ["Friday",friday[3]],
                [ "Saturday", saturday[3]],
                ["Sunday",sunday[3]]]
        },
        {
            :id=> "EMR",
            :data=> [["Monday",monday[4]],
                ["Tuesday",tuesday[4]],
                ["Wednesday",wednesday[4]],
                ["Thursday",thursday[4]],
                ["Friday",friday[4]],
                [ "Saturday", saturday[4]],
                ["Sunday",sunday[4]]]
        },
        {
            :id=> "JAD",
            :data=> [["Monday",monday[5]],
                ["Tuesday",tuesday[5]],
                ["Wednesday",wednesday[5]],
                ["Thursday",thursday[5]],
                ["Friday",friday[5]],
                [ "Saturday", saturday[5]],
                ["Sunday",sunday[5]]]
        }
    ]
	
=begin
	slahash[:missSLA]={}
	 slahash[:missSLA][:data]=[
	{:name=>"ZEO",:y=>missla[0],:drilldown=>"ZEO"},
	{:name=>"EMR",:y=>missla[1],:drilldown=>"EMR"},
    {:name=>"JAD",:y=>missla[2],:drilldown=>"JAD"},	
	]

	slahash[:missSLA][:drilldown]=[ {
            :id=> "ZEO",
            :data=> [["Monday",monday[0]],
                ["Tuesday",tuesday[0]],
                ["Wednesday",wednesday[0]],
                ["Thursday",thursday[0]],
                ["Friday",friday[0]],
                [ "Saturday", saturday[0]],
                ["Sunday",sunday[0]]]
        },
        {
            :id=> "EMR",
            :data=> [["Monday", monday[1]],
                ["Tuesday",tuesday[1]],
                ["Wednesday",wednesday[1]],
                ["Thursday",thursday[1]],
                ["Friday",friday[1]],
                [ "Saturday", saturday[1]],
                ["Sunday",sunday[1]]]
        },
        {
            :id=> "JAD",
            :data=> [["Monday",sunday[2]],
                ["Tuesday",tuesday[2]],
                ["Wednesday",wednesday[2]],
                ["Thursday",thursday[2]],
                ["Friday",friday[2]],
                [ "Saturday", saturday[2]],
                ["Sunday",sunday[2]]]
        }
        
    ]
=end
	render json:slahash.to_json 
	 
	 
	 end



end

def index3
   maxrolluptime=Dailyrolluptime.find_by_sql("select max(\"RollupDate\") as \"maxrollupdate\" from dailyrolluptimes where   \"Server\" !='BER'")
   priviousday= (DateTime.parse((maxrolluptime[0]["maxrollupdate"]).strftime("%Y/%m/%d")+ ' 00:00:00') -1)
   msabreachinfo=MsaslaBreachTracker.find_by_sql("SELECT  \"Rollup_Date\", \"Start_Time\", \"End_Time\", \"Environment\", \"Start_On_Time\", 
       \"SLA_Met\", \"SLA_Miss_Reason\", \"SLA_Miss_Reason\", \"Comment\"
       FROM msasla_breach_trackers where \"Rollup_Date\">=\'#{priviousday}\' order by \"Rollup_Date\" desc;")
	   
	  i=0
	  slahash=Hash.new
	  slahash["SLABreach"]=[]
	  while i<msabreachinfo.length do
	      slahash["SLABreach"].push(:Date=>msabreachinfo[i]["Rollup_Date"].strftime("%Y-%m-%d"),
		  :Environment=>msabreachinfo[i]["Environment"],
		  :StartOnTime=>msabreachinfo[i]["Start_On_Time"],
		  :DelayReason=>msabreachinfo[i]["SLA_Miss_Reason"],
		  :SLAMeet=>msabreachinfo[i]["SLA_Met"],
		  :SLAMissReason=>msabreachinfo[i]["SLA_Miss_Reason"],
		  :Comments=>msabreachinfo[i]["Comment"]
		  
		  ) 
		  i+=1
	  end
	   render json: slahash.to_json
end

def index4
    if(params[:month]==nil && params[:from]==nil)
	 		  jaddatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate_l\") as \"MECStartDate_l\" ,max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Environment\"='JAD' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
	 first=true
    i=0
   while i<jaddatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((jaddatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   jadmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{jaddatascope[i]["Year"]}\'  and \"Month\"=\'#{jaddatascope[i]["Month"]}\'  and \"Environment\"='JAD'")
		   first=false
		 end
		 i+=1
   end
    datejadstart=(jadmecstartinfo[0]["currentstarttime"]).strftime("%Y-%m-%d %H:%M:%S")
   	datejadend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	      reasoninfo= Dailyrolluptime.find_by_sql("select distinct \"SLA_Miss_Reason\"  from msasla_breach_trackers where \"Rollup_Date_l\">=\'#{datejadstart}\' and  \"Rollup_Date_l\"<=\'#{datejadend}\' and \"SLA_Miss_Reason\" is not null ")	   
       resonzeodetail=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" ,\"RollupDate_l\"  ,count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate_l\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate_l\") * 100 + EXTRACT(MONTH FROM \"RollupDate_l\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{datejadstart}\' and \"RollupDate\"<=\'#{datejadend}\' and \"Server\"='ZEO' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date_l\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\"  ,\"Rollup_Date_l\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\"  order by  dd.\"SLA_Miss_Reason\"")	
       resonemrdetail=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , \"RollupDate_l\" ,count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate_l\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate_l\") * 100 + EXTRACT(MONTH FROM \"RollupDate_l\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{datejadstart}\' and \"RollupDate\"<=\'#{datejadend}\' and \"Server\"='EMR' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date_l\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\"  ,\"Rollup_Date_l\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\"  order by  dd.\"SLA_Miss_Reason\"")	
       resonjaddetail=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , \"RollupDate_l\" ,count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate_l\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate_l\") * 100 + EXTRACT(MONTH FROM \"RollupDate_l\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{datejadstart}\' and \"RollupDate\"<=\'#{datejadend}\' and \"Server\"='JAD' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date_l\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\"  ,\"Rollup_Date_l\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\" order by  dd.\"SLA_Miss_Reason\"")	
	   
	   mectime =MecCalendar.find_by_sql(" select \"MECStartDate_l\", \"MECEndDate_l\" from mec_calendars where \"MECStartDate_l\">=\'#{datejadstart}\'" )  
	   
	  slahash={}
	  slahash[:mecmissSLAReason]={:data=>[],:mecdrilldown=>[]}	  
	  slahash[:nonmecmissSLAReason]={:data=>[],:nonmecdrilldown=>[]}	  
	  slahash[:totalmissSLAReason]={:data=>[],:totaldrilldown=>[]}

      i=0
	  
	  while i<reasoninfo.length do
	      slahash[:mecmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:mecmissSLAReason][:mecdrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
		  slahash[:nonmecmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:nonmecmissSLAReason][:nonmecdrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
		  slahash[:totalmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:totalmissSLAReason][:totaldrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
	      i+=1
	  end	   
	   
   if(params[:env]=='ALL' || params[:env]=='ZEO') 
	  i=0
	  while i<resonzeodetail.length do
	      ifmecornot=false
	      tt=0
		  while tt<mectime.length do
		     if((ifmecornot==false) && (resonzeodetail[i]["RollupDate_l"]>=mectime[tt]["MECStartDate_l"]   &&  resonzeodetail[i]["RollupDate_l"]<=mectime[tt]["MECEndDate_l"]))			         			
					 j=0
					 ifmecornot=true
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonzeodetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:mecmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:mecmissSLAReason][:mecdrilldown][j][:data][0][1]+=resonzeodetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][0][1]+=resonzeodetail[i]["count"]
						    if(slahash[:mecmissSLAReason][:data][j][:data]=="")					 
			               slahash[:mecmissSLAReason][:data][j][:data]+=resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:mecmissSLAReason][:data][j][:data]+='%253B%2523'+resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d") 
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d") 
                           end
			             end
             	           j+=1
		             end
					 tt=mectime.length
			 end
   			   tt+=1
		   end
		   if(ifmecornot==false) 
			          j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonzeodetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:nonmecmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][0][1]+=resonzeodetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][0][1]+=resonzeodetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")					 
			               slahash[:nonmecmissSLAReason][:data][j][:data]+=resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:nonmecmissSLAReason][:data][j][:data]+='%253B%2523'+resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d") 
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d") 
                           end
			             end
		             j+=1
		             end
			 end		   
	      i+=1
	  end
    end
    
    if(params[:env]=='ALL' || params[:env]=='EMR')	
	  i=0
	  while i<resonemrdetail.length do
	      tt=0		 
		  while tt<mectime.length do
		     ifmecornot=false
		     if((ifmecornot==false) && (resonemrdetail[i]["RollupDate_l"]>=mectime[tt]["MECStartDate_l"]   &&  resonemrdetail[i]["RollupDate_l"]<=mectime[tt]["MECEndDate_l"]))
			         ifmecornot=true
					 j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonemrdetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:mecmissSLAReason][:data][j][:y]+=resonemrdetail[i]["count"]
				           slahash[:mecmissSLAReason][:mecdrilldown][j][:data][2][1]+=resonemrdetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonemrdetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][2][1]+=resonemrdetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:mecmissSLAReason][:data][j][:data]+=resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:mecmissSLAReason][:data][j][:data]+='%253B%2523'+resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d") 
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d") 
                           end
			             end						 						 
			             j+=1
		             end
                     tt=mectime.length					 
             end             
			 tt+=1
             end	 
   			 if(ifmecornot==false)
			        j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonemrdetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:nonmecmissSLAReason][:data][j][:y]+=resonemrdetail[i]["count"]
				           slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][2][1]+=resonemrdetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][2][1]+=resonzeodetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:nonmecmissSLAReason][:data][j][:data]+=resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:nonmecmissSLAReason][:data][j][:data]+='%253B%2523'+resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d") 
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d") 
                           end	
			             end						 					 
			             j+=1
		             end
			 end	     	
	      i+=1
	   end
	 end 
		
	 if(params[:env]=='ALL' || params[:env]=='JAD')	
	  i=0
	  while i<resonjaddetail.length do
	      tt=0		 
		  while tt<mectime.length do
		     ifmecornot=false
		     if((ifmecornot==false) && (resonjaddetail[i]["RollupDate_l"]>=mectime[tt]["MECStartDate_l"]   &&  resonjaddetail[i]["RollupDate_l"]<=mectime[tt]["MECEndDate_l"]))
			         ifmecornot=true
					 j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonjaddetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:mecmissSLAReason][:data][j][:y]+=resonjaddetail[i]["count"]
				           slahash[:mecmissSLAReason][:mecdrilldown][j][:data][1][1]+=resonjaddetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonjaddetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][1][1]+=resonjaddetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:mecmissSLAReason][:data][j][:data]+=resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:mecmissSLAReason][:data][j][:data]+='%253B%2523'+resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
                           end
			             end						 						 
			             j+=1
		             end
                     tt=mectime.length 					 
             end             
			 tt+=1
             end	 
   			 if(ifmecornot==false)
			        j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonjaddetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:nonmecmissSLAReason][:data][j][:y]+=resonjaddetail[i]["count"]
				           slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][1][1]+=resonjaddetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonjaddetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][1][1]+=resonjaddetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:nonmecmissSLAReason][:data][j][:data]+=resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:nonmecmissSLAReason][:data][j][:data]+='%253B%2523'+resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
                           end
			             end						 						 
			             j+=1
		             end
			 end	     	
	      i+=1
	  end
	end 
	render json: slahash.to_json
	
	elsif(params[:month]!=nil)
	       currentdate = params[:month];
	       datestartyear=(DateTime.parse(currentdate+ '-01').strftime("%Y")).to_i
	       datestartmonth=(DateTime.parse(currentdate+ '-01').strftime("%m")).to_i  
	    
           mectime =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"mecendtime\",min(\"MECStartDate_l\") as \"mecstarttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"= \'#{datestartmonth}\' and \"Environment\"='ZEO' ")
	       p  'xxxxxxx'
		   p datestartmonth
		   if(datestartmonth==1)
		      nonmectime=MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"nonmecstarttime\"  from mec_calendars where \"Year\"=\'#{datestartyear}\'-1  and \"Month\"= 12 and \"Environment\"='ZEO' ")
		   else
		      nonmectime=MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"nonmecstarttime\"  from mec_calendars where \"Year\"=\'#{datestartyear}\'    and \"Month\"= \'#{datestartmonth}\'-1 and \"Environment\"='ZEO' ")
		   end
	
	reasoninfo= Dailyrolluptime.find_by_sql("select distinct \"SLA_Miss_Reason\"  from msasla_breach_trackers where \"Rollup_Date_l\">\'#{nonmectime[0]["nonmecstarttime"]}\' and  \"Rollup_Date_l\"<=\'#{mectime[0]["mecendtime"]}\' and \"SLA_Miss_Reason\" is not null ")	   
	
	
	
     if(params[:env]=='ALL' || params[:env]=='ZEO')	
	 meczeomreason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\",\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" , \"RollupDate_l\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate_l\">\'#{mectime[0]["mecstarttime"]}\' and \"RollupDate_l\"<=\'#{mectime[0]["mecendtime"]}\' and \"Server\"='ZEO' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\"  ,\"Rollup_Date_l\"  from msasla_breach_trackers  where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\"
         ) dd where dd.\"SLA_Met\" is not null group by  dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")		 
	 nonmeczeoslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\",\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" , \"RollupDate_l\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate_l\">\'#{nonmectime[0]["nonmecstarttime"]}\' and \"RollupDate_l\"<=\'#{mectime[0]["mecstarttime"]}\' and \"Server\"='ZEO' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\"  ,\"Rollup_Date_l\"  from msasla_breach_trackers  where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\"
         ) dd where dd.\"SLA_Met\" is not null group by  dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")		 	 
	 end
	 if(params[:env]=='ALL' || params[:env]=='EMR')
	 mecemrslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*) as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\", \"RollupDate_l\"  from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate_l\">\'#{mectime[0]["mecstarttime"]}\' and \"RollupDate_l\"<=\'#{mectime[0]["mecendtime"]}\'  and \"Server\"='EMR' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\"  ,\"SLA_Met\"  ,\"Rollup_Date_l\"  from msasla_breach_trackers  where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\" 
		   ) dd where dd.\"SLA_Met\" is not null group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")	
 	 nonmecemrslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*) as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" , \"RollupDate_l\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate_l\">\'#{nonmectime[0]["nonmecstarttime"]}\' and \"RollupDate_l\"<=\'#{mectime[0]["mecstarttime"]}\'  and \"Server\"='EMR' order by \"RollupDate\") a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\" as \"aliasdate\" ,\"Environment\" as \"aliasserver\"  ,\"SLA_Met\"   ,\"Rollup_Date_l\" from msasla_breach_trackers  where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\" 
		   ) dd where dd.\"SLA_Met\" is not null group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")	    
	 end
     if(params[:env]=='ALL' || params[:env]=='JAD')	 
	 mecjadslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\", \"RollupDate_l\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate_l\">\'#{mectime[0]["mecstarttime"]}\' and \"RollupDate_l\"<=\'#{mectime[0]["mecendtime"]}\' and \"Server\"='JAD' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\"  ,\"Rollup_Date_l\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")	
	 nonmecjadslareason=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\", \"RollupDate_l\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate_l\">\'#{nonmectime[0]["nonmecstarttime"]}\' and \"RollupDate_l\"<=\'#{mectime[0]["mecstarttime"]}\' and \"Server\"='JAD' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\"  ,\"Rollup_Date_l\"  from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"Rollup_Date_l\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\" order by  dd.\"SLA_Miss_Reason\"")	     
	end
	  	  
	  slahash={}
	  slahash[:mecmissSLAReason]={:data=>[],:mecdrilldown=>[]}	  
	  slahash[:nonmecmissSLAReason]={:data=>[],:nonmecdrilldown=>[]}	  
	  slahash[:totalmissSLAReason]={:data=>[],:totaldrilldown=>[]}

	  
	  mecdateinfo=Dailyrolluptime.find_by_sql("select distinct \"RollupDate\",\"SLA_Miss_Reason\"  from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{mectime[0]["mecstarttime"]}\' and \"RollupDate\"<=\'#{mectime[0]["mecendtime"]}\' and \"Server\"!='BER' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  order by \"SLA_Miss_Reason\",\"RollupDate\"")	
      
	  nonmecdateinfo=Dailyrolluptime.find_by_sql("select distinct \"RollupDate\",\"SLA_Miss_Reason\"  from(select *  from (select \"Server\",\"RollupDate\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate\") * 100 + EXTRACT(MONTH FROM \"RollupDate\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">\'#{nonmectime[0]["nonmecstarttime"]}\' and \"RollupDate\"<=\'#{mectime[0]["mecendtime"]}\' and \"Server\"!='BER' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  order by \"SLA_Miss_Reason\",\"RollupDate\"")

		  
      i=0	  
	  while i<reasoninfo.length do
	      slahash[:mecmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:mecmissSLAReason][:mecdrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
		  slahash[:nonmecmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:nonmecmissSLAReason][:nonmecdrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
		  slahash[:totalmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:totalmissSLAReason][:totaldrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
	      i+=1
	  end
	 
    i=0
    if(mecdateinfo!=nil)
	   while i<  mecdateinfo.length do
         j=0
		 while j< slahash[:mecmissSLAReason][:data].length do
		       if(mecdateinfo[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
                  if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			      slahash[:mecmissSLAReason][:data][j][:data]+=mecdateinfo[i]["RollupDate"].strftime("%Y")+'%252D'+mecdateinfo[i]["RollupDate"].strftime("%m")+'%252D'+mecdateinfo[i]["RollupDate"].strftime("%d")
			      slahash[:totalmissSLAReason][:data][j][:data]+=mecdateinfo[i]["RollupDate"].strftime("%Y")+'%252D'+mecdateinfo[i]["RollupDate"].strftime("%m")+'%252D'+mecdateinfo[i]["RollupDate"].strftime("%d")
				  else
				  slahash[:mecmissSLAReason][:data][j][:data]+='%253B%2523'+mecdateinfo[i]["RollupDate"].strftime("%Y")+'%252D'+mecdateinfo[i]["RollupDate"].strftime("%m")+'%252D'+mecdateinfo[i]["RollupDate"].strftime("%d") 
				  slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+mecdateinfo[i]["RollupDate"].strftime("%Y")+'%252D'+mecdateinfo[i]["RollupDate"].strftime("%m")+'%252D'+mecdateinfo[i]["RollupDate"].strftime("%d") 
				  end
			   end
			   j+=1
		 end		 
	   i+=1
      end	
    end

    i=0
    if(nonmecdateinfo!=nil)
	   while i<  nonmecdateinfo.length do
         j=0
		 while j< slahash[:mecmissSLAReason][:data].length do
		       if(nonmecdateinfo[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
                  if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			      slahash[:nonmecmissSLAReason][:data][j][:data]+=nonmecdateinfo[i]["RollupDate"].strftime("%Y")+'%252D'+nonmecdateinfo[i]["RollupDate"].strftime("%m")+'%252D'+nonmecdateinfo[i]["RollupDate"].strftime("%d")
			      slahash[:totalmissSLAReason][:data][j][:data]+=nonmecdateinfo[i]["RollupDate"].strftime("%Y")+'%252D'+nonmecdateinfo[i]["RollupDate"].strftime("%m")+'%252D'+nonmecdateinfo[i]["RollupDate"].strftime("%d")
				  else
				  slahash[:nonmecmissSLAReason][:data][j][:data]+='%253B%2523'+nonmecdateinfo[i]["RollupDate"].strftime("%Y")+'%252D'+nonmecdateinfo[i]["RollupDate"].strftime("%m")+'%252D'+nonmecdateinfo[i]["RollupDate"].strftime("%d") 
				  slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+nonmecdateinfo[i]["RollupDate"].strftime("%Y")+'%252D'+nonmecdateinfo[i]["RollupDate"].strftime("%m")+'%252D'+nonmecdateinfo[i]["RollupDate"].strftime("%d") 
				  end
			   end
			   j+=1
		 end		 
	   i+=1
      end	
    end	
	  
      
     i=0
	 if(meczeomreason!=nil)
      while i<  meczeomreason.length do
         j=0
		 while j< slahash[:mecmissSLAReason][:data].length do
		       if(meczeomreason[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			      slahash[:mecmissSLAReason][:data][j][:y]+=meczeomreason[i]["count"]
				  slahash[:mecmissSLAReason][:mecdrilldown][j][:data][0][1]+=meczeomreason[i]["count"]
				  slahash[:totalmissSLAReason][:data][j][:y]+=meczeomreason[i]["count"]
				  slahash[:totalmissSLAReason][:totaldrilldown][j][:data][0][1]+=meczeomreason[i]["count"]
			   end
			   j+=1
		 end		  
	     i+=1
      end	  
	 end
	  i=0
   if(mecemrslareason!=nil)
      while i<  mecemrslareason.length do
         j=0
		 while j< slahash[:mecmissSLAReason][:data].length do
		       if(mecemrslareason[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			     slahash[:mecmissSLAReason][:data][j][:y]+=mecemrslareason[i]["count"]
				 slahash[:mecmissSLAReason][:mecdrilldown][j][:data][2][1]+=mecemrslareason[i]["count"]
				 slahash[:totalmissSLAReason][:data][j][:y]+=mecemrslareason[i]["count"]
				 slahash[:totalmissSLAReason][:totaldrilldown][j][:data][2][1]+=mecemrslareason[i]["count"]
			   end
			   j+=1
		 end		  
	     i+=1
      end
	 end 
	  i=0
	if(mecjadslareason!=nil)
      while i<  mecjadslareason.length do
         j=0
		 while j< slahash[:mecmissSLAReason][:data].length do
		       if(mecjadslareason[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			     slahash[:mecmissSLAReason][:data][j][:y]+=mecjadslareason[i]["count"]
				 slahash[:mecmissSLAReason][:mecdrilldown][j][:data][1][1]+=mecjadslareason[i]["count"]
				 slahash[:totalmissSLAReason][:data][j][:y]+=mecjadslareason[i]["count"]
				 slahash[:totalmissSLAReason][:totaldrilldown][j][:data][1][1]+=mecjadslareason[i]["count"]
			   end
			   j+=1
		 end		  
	     i+=1
      end
	 end
	  i=0
	 if(nonmeczeoslareason!=nil)
      while i<  nonmeczeoslareason.length do
         j=0
		 while j< slahash[:mecmissSLAReason][:data].length do
		       if(nonmeczeoslareason[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			      slahash[:nonmecmissSLAReason][:data][j][:y]+=nonmeczeoslareason[i]["count"]
				  slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][0][1]+=nonmeczeoslareason[i]["count"]
				  slahash[:totalmissSLAReason][:data][j][:y]+=nonmeczeoslareason[i]["count"]
				  slahash[:totalmissSLAReason][:totaldrilldown][j][:data][0][1]+=nonmeczeoslareason[i]["count"]
			   end
			   j+=1
		 end		  
	     i+=1
      end
	 end
	  i=0
   if(nonmecemrslareason!=nil)
      while i<  nonmecemrslareason.length do
         j=0
		 while j< slahash[:mecmissSLAReason][:data].length do
		       if(nonmecemrslareason[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			      slahash[:nonmecmissSLAReason][:data][j][:y]+=nonmecemrslareason[i]["count"]
				  slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][2][1]+=nonmecemrslareason[i]["count"]
				  slahash[:totalmissSLAReason][:data][j][:y]+=nonmecemrslareason[i]["count"]
				  slahash[:totalmissSLAReason][:totaldrilldown][j][:data][2][1]+=nonmecemrslareason[i]["count"]
			   end
			   j+=1
		 end		  
	     i+=1
      end
	 end
	  i=0
	if(nonmecjadslareason!=nil) 
      while i<  nonmecjadslareason.length do
         j=0
		 while j< slahash[:mecmissSLAReason][:data].length do
		       if(nonmecjadslareason[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
                  slahash[:nonmecmissSLAReason][:data][j][:y]+=nonmecjadslareason[i]["count"]
				  slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][1][1]+=nonmecjadslareason[i]["count"]
				  slahash[:totalmissSLAReason][:data][j][:y]+=nonmecjadslareason[i]["count"]
				  slahash[:totalmissSLAReason][:totaldrilldown][j][:data][1][1]+=nonmecjadslareason[i]["count"]
			   end
			   j+=1
		 end		  
	     i+=1
      end
	    
	 end 
	   render json: slahash.to_json
 else  
       reasoninfo= Dailyrolluptime.find_by_sql("select distinct \"SLA_Miss_Reason\"  from msasla_breach_trackers where \"Rollup_Date_l\">=\'#{params[:from]}\' and  \"Rollup_Date_l\"<=\'#{params[:to]}\' and \"SLA_Miss_Reason\" is not null ")	   
       resonzeodetail=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" ,\"RollupDate_l\"  ,count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate_l\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate_l\") * 100 + EXTRACT(MONTH FROM \"RollupDate_l\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">=\'#{params[:from]}\' and \"RollupDate\"<=\'#{params[:to]}\' and \"Server\"='ZEO' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date_l\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\"  order by  dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\"")	
       resonemrdetail=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , \"RollupDate_l\" ,count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate_l\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate_l\") * 100 + EXTRACT(MONTH FROM \"RollupDate_l\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">=\'#{params[:from]}\' and \"RollupDate\"<=\'#{params[:to]}\' and \"Server\"='EMR' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date_l\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\"  order by  dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\"")	
       resonjaddetail=Dailyrolluptime.find_by_sql("select \"SLA_Miss_Reason\" , \"RollupDate_l\" ,count(*)  as \"count\" ,\"SLA_Met\" from(select *  from (select \"Server\",\"RollupDate_l\",\"End_TS\",\"Start_TS\", EXTRACT(YEAR FROM \"RollupDate_l\") * 100 + EXTRACT(MONTH FROM \"RollupDate_l\") as \"Month\" from dailyrolluptimes where \"End_TS\" is not null and \"RollupDate\">=\'#{params[:from]}\' and \"RollupDate\"<=\'#{params[:to]}\' and \"Server\"='JAD' order by \"RollupDate\")  a 
 	     left join (select \"SLA_Miss_Reason\" ,\"Rollup_Date_l\"  as \"aliasdate\" ,\"Environment\" as \"aliasserver\" ,\"SLA_Met\" from msasla_breach_trackers where \"SLA_Met\"='No')  b on  a.\"RollupDate_l\"=b.\"aliasdate\"  and a.\"Server\"=b.\"aliasserver\"
		  ) dd where dd.\"SLA_Met\" is not null  group by dd.\"SLA_Met\", dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\" order by  dd.\"SLA_Miss_Reason\",dd.\"RollupDate_l\"")	
       	   
	   mectime =MecCalendar.find_by_sql(" select \"MECStartDate_l\", \"MECEndDate_l\" from mec_calendars where \"MECStartDate_l\">=\'#{params[:from]}\'" )  
	   
	  slahash={}
	  slahash[:mecmissSLAReason]={:data=>[],:mecdrilldown=>[]}	  
	  slahash[:nonmecmissSLAReason]={:data=>[],:nonmecdrilldown=>[]}	  
	  slahash[:totalmissSLAReason]={:data=>[],:totaldrilldown=>[]}

      i=0
	  
	  while i<reasoninfo.length do
	      slahash[:mecmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:mecmissSLAReason][:mecdrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
		  slahash[:nonmecmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:nonmecmissSLAReason][:nonmecdrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
		  slahash[:totalmissSLAReason][:data].push({:name=>reasoninfo[i]["SLA_Miss_Reason"],:y=>0,:data=>"",:drilldown=>reasoninfo[i]["SLA_Miss_Reason"]})
		  slahash[:totalmissSLAReason][:totaldrilldown].push({:id=>reasoninfo[i]["SLA_Miss_Reason"],:data=>[["ZEO",0],["JAD",0],["EMR",0]]})
	      i+=1
	  end	   
	   
   if(params[:env]=='ALL' || params[:env]=='ZEO') 
	  i=0
	  while i<resonzeodetail.length do
	      ifmecornot=false
	      tt=0
		  while tt<mectime.length do
		     if((ifmecornot==false) && (resonzeodetail[i]["RollupDate_l"]>=mectime[tt]["MECStartDate_l"]   &&  resonzeodetail[i]["RollupDate_l"]<=mectime[tt]["MECEndDate_l"]))			         			
					 j=0
					 ifmecornot=true
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonzeodetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:mecmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:mecmissSLAReason][:mecdrilldown][j][:data][0][1]+=resonzeodetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][0][1]+=resonzeodetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")					 
			               slahash[:mecmissSLAReason][:data][j][:data]+=resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:mecmissSLAReason][:data][j][:data]+='%253B%2523'+resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d") 
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d") 
                           end
			             end
						 j+=1
		             end
					 tt=mectime.length
			 end
   			   tt+=1
		   end
		   if(ifmecornot==false) 
			          j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonzeodetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:nonmecmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][0][1]+=resonzeodetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonzeodetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][0][1]+=resonzeodetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:nonmecmissSLAReason][:data][j][:data]+=resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:nonmecmissSLAReason][:data][j][:data]+='%253B%2523'+resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d") 
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonzeodetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonzeodetail[i]["RollupDate_l"].strftime("%d") 
                           end
			             end						 
			             j+=1
		             end
			 end		   
	      i+=1
	  end
    end
    
    if(params[:env]=='ALL' || params[:env]=='EMR')	
	  i=0
	  while i<resonemrdetail.length do
	      tt=0		 
		  while tt<mectime.length do
		     ifmecornot=false
		     if((ifmecornot==false) && (resonemrdetail[i]["RollupDate_l"]>=mectime[tt]["MECStartDate_l"]   &&  resonemrdetail[i]["RollupDate_l"]<=mectime[tt]["MECEndDate_l"]))
			         ifmecornot=true
					 j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonemrdetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:mecmissSLAReason][:data][j][:y]+=resonemrdetail[i]["count"]
				           slahash[:mecmissSLAReason][:mecdrilldown][j][:data][2][1]+=resonemrdetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonemrdetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][2][1]+=resonemrdetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:mecmissSLAReason][:data][j][:data]+=resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:mecmissSLAReason][:data][j][:data]+='%253B%2523'+resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d") 
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d") 
                           end
			             end			 
			             j+=1
		             end
                     tt=mectime.length					 
             end             
			 tt+=1
             end	 
   			 if(ifmecornot==false)
			        j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonemrdetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:nonmecmissSLAReason][:data][j][:y]+=resonemrdetail[i]["count"]
				           slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][2][1]+=resonemrdetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonemrdetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][2][1]+=resonemrdetail[i]["count"]
						   if(slahash[:nonmecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:mecmissSLAReason][:data][j][:data]+=resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:nonmecmissSLAReason][:data][j][:data]+='%253B%2523'+resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonemrdetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonemrdetail[i]["RollupDate_l"].strftime("%d")
                           end
			             end	 
			             j+=1
		             end
			 end	     	
	      i+=1
	   end
	 end 
		
	 if(params[:env]=='ALL' || params[:env]=='JAD')	
	  i=0
	  while i<resonjaddetail.length do
	      tt=0		 
		  while tt<mectime.length do
		     ifmecornot=false
		     if((ifmecornot==false) && (resonjaddetail[i]["RollupDate_l"]>=mectime[tt]["MECStartDate_l"]   &&  resonjaddetail[i]["RollupDate_l"]<=mectime[tt]["MECEndDate_l"]))
			         ifmecornot=true
					 j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonjaddetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:mecmissSLAReason][:data][j][:y]+=resonjaddetail[i]["count"]
				           slahash[:mecmissSLAReason][:mecdrilldown][j][:data][1][1]+=resonjaddetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonjaddetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][1][1]+=resonjaddetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:mecmissSLAReason][:data][j][:data]+=resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:mecmissSLAReason][:data][j][:data]+='%253B%2523'+resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
                           end
			             end						 
			             j+=1
		             end
                     tt=mectime.length 					 
             end             
			 tt+=1
             end	 
   			 if(ifmecornot==false)
			        j=0
		             while j< slahash[:mecmissSLAReason][:data].length do
		                 if(resonjaddetail[i]["SLA_Miss_Reason"]==slahash[:mecmissSLAReason][:data][j][:name])
			               slahash[:nonmecmissSLAReason][:data][j][:y]+=resonjaddetail[i]["count"]
				           slahash[:nonmecmissSLAReason][:nonmecdrilldown][j][:data][1][1]+=resonjaddetail[i]["count"]
						   slahash[:totalmissSLAReason][:data][j][:y]+=resonjaddetail[i]["count"]
				           slahash[:totalmissSLAReason][:totaldrilldown][j][:data][1][1]+=resonjaddetail[i]["count"]
						   if(slahash[:mecmissSLAReason][:data][j][:data]=="")			   
			               slahash[:nonmecmissSLAReason][:data][j][:data]+=resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
			               slahash[:totalmissSLAReason][:data][j][:data]+=resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
				           else
				           slahash[:nonmecmissSLAReason][:data][j][:data]+='%253B%2523'+resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
				           slahash[:totalmissSLAReason][:data][j][:data]+='%253B%2523'+resonjaddetail[i]["RollupDate_l"].strftime("%Y")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%m")+'%252D'+resonjaddetail[i]["RollupDate_l"].strftime("%d")
                           end
			             end						 
			             j+=1
		             end
			 end	     	
	      i+=1
	  end
	end 
	render json: slahash.to_json
 end
	
end
	  
end
