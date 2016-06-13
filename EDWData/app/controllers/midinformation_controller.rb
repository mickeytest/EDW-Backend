class MidinformationController < ApplicationController
    def index
	     	      currentdate = params[:month];
		  jaddatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate_l\") as \"MECStartDate_l\" ,max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Environment\"='JAD' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
          emrdatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate_l\") as \"MECStartDate_l\" ,max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Environment\"='EMR' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")
		  zeodatascope=MecCalendar.find_by_sql("select \"Year\",\"Month\",min(\"MECStartDate_l\") as \"MECStartDate_l\" ,max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Environment\"='ZEO' group by  \"Year\",\"Month\" order by \"Year\" desc,\"Month\" desc")

 if(currentdate!=nil)
		  #datestart=DateTime.parse(currentdate+ '-01').strftime("%Y-%m-%d %H:%M:%S")
		  #dateend=(DateTime.parse((DateTime.parse(currentdate+ '-01')).strftime("%Y-%m") + '-1 00:00:00') >>1).strftime("%Y-%m-%d %H:%M:%S");		             
		  datestartyear=(DateTime.parse(currentdate+ '-01').strftime("%Y")).to_i
	      datestartmonth=(DateTime.parse(currentdate+ '-01').strftime("%m")).to_i 
	       
		   if(datestartmonth!=1)
               mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"= \'#{datestartmonth}\' group by \"Environment\"")
	           mecendinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\'-1 group by \"Environment\"")
           else
	           mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\")  as \"starttime\" from mec_calendars where \"Year\"=\'#{datestartyear}\'  and \"Month\"=\'#{datestartmonth}\' group by \"Environment\"")
	           mecendinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"endtime\" from mec_calendars where \"Year\"=\'#{datestartyear-1}\'  and \"Month\"=12 group by \"Environment\"")
	       end   	           
			   datejadstart=mecendinfo[0]["endtime"]
			   dateemrstart=mecendinfo[1]["endtime"]
			   datezeostart=mecendinfo[2]["endtime"]
			   			   
	           datejadend=mecstartinfo[0]["starttime"]
	           dateemrend=mecstartinfo[1]["starttime"]
	           datezeoend=mecstartinfo[2]["starttime"]
                datestart=mecendinfo[2]["endtime"]
				dateend=mecstartinfo[2]["starttime"]
=begin				
			if(datestartmonth==jaddatascope[0]["Month"].to_i)
			   if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((jaddatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               datejadend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
			   dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
               end	
            end
    
	        if(datestartmonth==emrdatascope[0]["Month"].to_i)
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((emrdatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               dateemrend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
               dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))				   
               end	
			end
			if(datestartmonth==zeodatascope[0]["Month"].to_i)
               if( (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) >= DateTime.parse((zeodatascope[0]["MECStartDate"]).strftime("%Y-%m-%d %H:%M:%S"))) &&  (DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S")) <=DateTime.parse((zeodatascope[0]["MECEndDate"]).strftime("%Y-%m-%d %H:%M:%S"))))
               datezeoend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))	
			   dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
               end	
             end
=end              			   
=begin	 
  	  else
          datestart=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 90).strftime("%Y-%m-%d %H:%M:%S")
		  dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
=end		  
       end
		   prorollupmatic=Hash.new	


#mecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"MECEndDate_l\" from mec_calendars where \"Year\"=\'#{zeodatascope[1]["Year"]}\'  and \"Month\"=\'#{zeodatascope[1]["Month"]}\'")


if(currentdate==nil)
       first=true
    i=0
   while i<jaddatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((jaddatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   jadmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{jaddatascope[i]["Year"]}\'  and \"Month\"=\'#{jaddatascope[i]["Month"]}\' and \"Environment\"='JAD'")
		   first=false
		 end
		 i+=1
   end
   
   first=true
   i=0
   while i<emrdatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((emrdatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   emrmecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{emrdatascope[i]["Year"]}\'  and \"Month\"=\'#{emrdatascope[i]["Month"]}\' and \"Environment\"='EMR'")
		   first=false
		 end
		 i+=1
   end
   
     first=true
    i=0
   while i<zeodatascope.length 
         if((first==true)&&(DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:00")) > DateTime.parse((zeodatascope[i]["MECEndDate_l"]).strftime("%Y-%m-%d %H:%M:%S"))))
		   zeomecstartinfo =MecCalendar.find_by_sql("select  max(\"MECEndDate_l\") as \"currentstarttime\"  from mec_calendars where \"Year\"=\'#{zeodatascope[i]["Year"]}\'  and \"Month\"=\'#{zeodatascope[i]["Month"]}\' and \"Environment\"='ZEO'")
		   first=false
		 end
		 i+=1
   end
   
	datejadstart=jadmecstartinfo[0]["currentstarttime"]
	dateemrstart=emrmecstartinfo[0]["currentstarttime"]
	datezeostart=zeomecstartinfo[0]["currentstarttime"]
	datestart=zeomecstartinfo[0]["currentstarttime"]
    dateend=DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))
	datejadend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	dateemrend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
	datezeoend=(DateTime.parse((Time.new).strftime("%Y-%m-%d %H:%M:%S"))).strftime("%Y-%m-%d %H:%M:%S")
    end 

    if((params[:from] !=nil) && (params[:to]!=nil))
     datejadstart=DateTime.parse(params[:from])
     dateemrstart=DateTime.parse(params[:from])
     # datezeostart=DateTime.parse(params[:from])
     datejadend=DateTime.parse(params[:to])
     dateemrend=DateTime.parse(params[:to])
     datezeoend=DateTime.parse(params[:to])
     datestart=DateTime.parse(params[:from])
     dateend==DateTime.parse(params[:to])
     datezeostart=(DateTime.parse((params[:from]))-1).strftime("%Y-%m-%d")
    end
	
		 tttstart=  (DateTime.parse((datestart).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00")
		 tttend=  (DateTime.parse((dateend).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00") 

		typeinfo= EdwOpsCallTracker.find_by_sql("SELECT *
  FROM edw_ops_call_trackers where (\"Assigned_To\" like 'Chen, Gang%' or \"Assigned_To\"  is null)  and (\"Complete_Date_l\">=\'#{tttstart}\' and \"Complete_Date_l\"<=\'#{tttend}\'  or  \"Complete_Date_l\" is null )
  ")
        statusinfo= EdwOpsCallTracker.find_by_sql("SELECT distinct(\"Status\")
  FROM edw_ops_call_trackers where (\"Assigned_To\" like 'Chen, Gang%' or \"Assigned_To\"  is null)  and (\"Complete_Date_l\">=\'#{tttstart}\' and \"Complete_Date_l\"<=\'#{tttend}\'  or  \"Complete_Date_l\" is null )
  ")
        changetypeinfo= EdwOpsCallTracker.find_by_sql("SELECT distinct(\"Change_Type\")
  FROM edw_ops_call_trackers where (\"Assigned_To\" like 'Chen, Gang%' or \"Assigned_To\"  is null)  and (\"Complete_Date_l\">=\'#{tttstart}\' and \"Complete_Date_l\"<=\'#{tttend}\'  or  \"Complete_Date_l\" is null )
  and \"Change_Type\"!='N/A'")
	    mininfor={:midbystatus=>{:data=>[],:drilldown=>[]},:midbychangetype=>{:data=>[],:drilldown=>[]}}
		
		statusinfo.each do |row|
		    mininfor[:midbystatus][:data].push({:name=>row["Status"],:y=>0,:drilldown=>row["Status"]})
		    mininfor[:midbystatus][:drilldown].push({:id=>row["Status"],:data=>[]})
		end
		changetypeinfo.each do |row|
		    mininfor[:midbychangetype][:data].push({:name=>row["Change_Type"].rstrip,:y=>0,:drilldown=>row["Change_Type"].rstrip})
			mininfor[:midbychangetype][:drilldown].push({:id=>row["Change_Type"].rstrip,:data=>[]})
		end
		mininfor[:detaildata]=[]

		p mininfor[:midbystatus][:data].length
		typeinfo.each do |row|
		     if(!((row["MIDs"].include? "N/A")||(row["MIDs"].include? "n/a")||(row["MIDs"].include? "/NA")))
			    i=0
				 p row["MIDs"]
				while i<row["MIDs"].split(',').length do
		         mininfor[:detaildata].push(:MID=>row["MIDs"].split(',')[i].rstrip,:Status=>row["Status"],:ChangeType=>row["Change_Type"].rstrip,:Decription=>row["Description"],:Solution=>nil)
		         i+=1
				end
			 end
			 
		     i=0
		     while i< mininfor[:midbystatus][:data].length do
			 if(mininfor[:midbystatus][:data][i][:name]==row["Status"])
					  if(!((row["MIDs"].include? "N/A")||(row["MIDs"].include? "n/a")||(row["MIDs"].include? "/NA")))
				         mininfor[:midbystatus][:data][i][:y]+=row["MIDs"].split(',').length	
					  end
  					  j=0
					  exsit=false
					  while j<mininfor[:midbystatus][:drilldown][i][:data].length do
					     if(mininfor[:midbystatus][:drilldown][i][:data][j][0]==row["Change_Type"].rstrip)
						    if(!((row["MIDs"].include? "N/A")||(row["MIDs"].include? "n/a")||(row["MIDs"].include? "/NA")))
                               mininfor[:midbystatus][:drilldown][i][:data][j][1]+=row["MIDs"].split(',').length
							end
							exsit=true
						 end	                        						 
						 j+=1
					  end
					  if((j==0)||(exsit==false))
					     if(!((row["MIDs"].include? "N/A")||(row["MIDs"].include? "n/a")||(row["MIDs"].include? "/NA")))
					      mininfor[:midbystatus][:drilldown][i][:data].push([row["Change_Type"].rstrip,row["MIDs"].split(',').length])
						 end
					  end
				    end				    		   
				    i+=1
			 end
			 i=0
			 while i< mininfor[:midbychangetype][:data].length do
             if(mininfor[:midbychangetype][:data][i][:name]==row["Change_Type"].rstrip)
			          if(!((row["MIDs"].include? "N/A")||(row["MIDs"].include? "n/a")||(row["MIDs"].include? "/NA")))
				        mininfor[:midbychangetype][:data][i][:y]+=row["MIDs"].split(',').length
					  end
					  j=0
					  exsit=false
					  while j<mininfor[:midbychangetype][:drilldown][i][:data].length do
					     if(mininfor[:midbychangetype][:drilldown][i][:data][j][0]==row["Status"])
						   if(!((row["MIDs"].include? "N/A")||(row["MIDs"].include? "n/a")||(row["MIDs"].include? "/NA")))
                            mininfor[:midbychangetype][:drilldown][i][:data][j][1]+=row["MIDs"].split(',').length
						   end
							exsit=true
						 end						 
						 j+=1
					  end
					  if((j==0)||(exsit==false))
					     if(!((row["MIDs"].include? "N/A")||(row["MIDs"].include? "n/a")||(row["MIDs"].include? "/NA")))
					      mininfor[:midbychangetype][:drilldown][i][:data].push([row["Status"],row["MIDs"].split(',').length])
						 end
					  end
				    end		
                 i+=1
			   end					
		end

		render json: mininfor.to_json
	end
end
