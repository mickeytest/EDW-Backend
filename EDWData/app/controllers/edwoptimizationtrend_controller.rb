class EdwoptimizationtrendController < ApplicationController
  # 	def index
	 #    mecinfo = MecCalendar.find_by_sql("select * from (
	 #                  select \"Month\",\"Year\", max(\"MECEndDate_l\") as \"maxenddate\" from mec_calendars group  by  \"Month\"  ,\"Year\" order by \"Year\" desc,\"Month\" desc ) aaa
	 #                  where now()>aaa.\"maxenddate\" limit 4")
	 #    optimizationjs={}
		# optimizationjs[:classtrend]=[{:title=>"classify",:data=>[]}]
		# optimizationjs[:classdilldowncategories]=[]
		# optimizationjs[:classdilldowndate]=[]
		# optimizationjs[:categories] = []	
		# optimizationjs[:StatusTrend] = [{:title=>"Completed",:data=>[]},{:title=>"In Progress",:data=>[]},{:title=>"Others",:data=>[]}];	
		# optimizationjs[:ChangeTypeTrend] = [{:title=>"Bug Fixing",:data=>[]},{:title=>"Optimization",:data=>[]},{:title=>"TSA",:data=>[]},{:title=>"Others",:data=>[]}];	
	 #    optimizationjs[:longrunning]=[{:title=>"Long Running Jobs",:data=>[]}]	
		# optimizationjs[:longrunningcategories] = [];
	 #    optimizationjs[:longrunningdrilldown]=[]
		# optimizationjs[:longrunningcategories].push("ZEO","JAD","EMR")	
		# assignedinfo=EdwOpsCallTracker.find_by_sql("select distinct \"Classification\" from edw_ops_call_trackers" )		     
		# 	 ddd=0
		# 	  while ddd<assignedinfo.length do 
		# 	      optimizationjs[:classdilldowncategories].push(assignedinfo[ddd]["Classification"])
		# 		  ddd+=1
		# 	  end	
	 #    i=mecinfo.length-1
		# while i>0
		#      optimizationjs[:categories].push(mecinfo[i]["maxenddate"].strftime("%h, %Y"))
		#      i-=1
		# end    
		# i=mecinfo.length-1
		# point=0
		# while i>0 do
		#       optimizationjs[:StatusTrend][0][:data].push([point,0])
		# 	  optimizationjs[:StatusTrend][1][:data].push([point,0])
		# 	  optimizationjs[:StatusTrend][2][:data].push([point,0])
		# 	  optimizationjs[:ChangeTypeTrend][0][:data].push([point,0])
		# 	  optimizationjs[:ChangeTypeTrend][1][:data].push([point,0])
		# 	  optimizationjs[:ChangeTypeTrend][2][:data].push([point,0])
		# 	  optimizationjs[:ChangeTypeTrend][3][:data].push([point,0])
		#       statusinfo= EdwOpsCallTracker.find_by_sql("SELECT \"Status\" ,\"MIDs\",count(*)
		# 	  FROM edw_ops_call_trackers where (\"Assigned_To\" like 'Chen, Gang%' or \"Assigned_To\"  is null)  and (\"Complete_Date_l\">\'#{mecinfo[i]["maxenddate"]}\' and \"Complete_Date_l\"<=\'#{mecinfo[i-1]["maxenddate"]}\'  or  \"Complete_Date_l\" is null )
		# 	  group by \"Status\",\"MIDs\"")
		#       tt=0
		# 	  while tt<statusinfo.length do
		# 	       if(statusinfo[tt]["Status"]=="Completed")
	 #                  if(statusinfo[tt]["MIDs"]==nil)		       
		# 		        optimizationjs[:StatusTrend][0][:data][point][1]+= statusinfo[tt]["count"]
		# 			  else
		# 			    optimizationjs[:StatusTrend][0][:data][point][1]+= statusinfo[tt]["MIDs"].split(',').length * statusinfo[tt]["count"]
		# 			  end
		# 		   elsif(statusinfo[tt]["Status"]=="In Progress")  
		# 		     if(statusinfo[tt]["MIDs"]==nil)	
		# 			      optimizationjs[:StatusTrend][1][:data][point][1]+= statusinfo[tt]["count"]
		# 			 else
		# 			      optimizationjs[:StatusTrend][1][:data][point][1]+=  statusinfo[tt]["MIDs"].split(',').length * statusinfo[tt]["count"]
		# 			 end		     
	 #               else
		# 		     if(statusinfo[tt]["MIDs"]==nil)	
		# 			      optimizationjs[:StatusTrend][2][:data][point][1]+= statusinfo[tt]["count"]
		# 			 else
		# 			      optimizationjs[:StatusTrend][2][:data][point][1]+=  statusinfo[tt]["MIDs"].split(',').length * statusinfo[tt]["count"]
		# 			 end				      
		# 		   end
	 #               tt+=1			   
		# 	  end		  
		#       typeinfo= EdwOpsCallTracker.find_by_sql("SELECT \"Change_Type\" ,\"MIDs\",count(*)
		# 	  FROM edw_ops_call_trackers where (\"Assigned_To\" like 'Chen, Gang%' or \"Assigned_To\"  is null)  and (\"Complete_Date_l\">\'#{mecinfo[i]["maxenddate"]}\' and \"Complete_Date_l\"<=\'#{mecinfo[i-1]["maxenddate"]}\'   or  \"Complete_Date_l\" is null )
		# 	  group by \"Change_Type\",\"MIDs\"")         
		# 	  tt=0
		# 	  while tt<typeinfo.length do
		# 	      if(typeinfo[tt]["Change_Type"] != nil)
		# 	       if((typeinfo[tt]["Change_Type"].include? "Bug Fixing") ==true)  
	 #                  if(typeinfo[tt]["MIDs"]==nil)		       
		# 		        optimizationjs[:ChangeTypeTrend][0][:data][point][1]+= typeinfo[tt]["count"]
		# 			  else
		# 			   optimizationjs[:ChangeTypeTrend][0][:data][point][1]+= typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
		# 			  end
		# 		   elsif((typeinfo[tt]["Change_Type"].include? "Optimization") ==true)
		# 		      if(typeinfo[tt]["MIDs"]==nil)		       
		# 		       optimizationjs[:ChangeTypeTrend][1][:data][point][1]+= typeinfo[tt]["count"]
		# 			  else
		# 			   optimizationjs[:ChangeTypeTrend][1][:data][point][1]+= typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
		# 			  end
	 #               elsif((typeinfo[tt]["Change_Type"].include? "TSA" )==true)
		# 		      if(typeinfo[tt]["MIDs"]==nil)		       
		# 		       optimizationjs[:ChangeTypeTrend][2][:data][point][1]+= typeinfo[tt]["count"]
		# 			  else
		# 			   optimizationjs[:ChangeTypeTrend][2][:data][point][1]+= typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
		# 			  end
	 #               else
		# 		      if(typeinfo[tt]["MIDs"]==nil)		       
		# 		       optimizationjs[:ChangeTypeTrend][3][:data][point][1]+= typeinfo[tt]["count"]
		# 			  else
		# 			   optimizationjs[:ChangeTypeTrend][3][:data][point][1]+= typeinfo[tt]["MIDs"].split(',').length * typeinfo[tt]["count"]
		# 			  end
		# 		   end
	 #              end			   
	 #              tt+=1					   
		# 	  end  
	 #          opsinfo=EdwOpsCallTracker.find_by_sql("select * from(
		# 	(select distinct \"Classification\" from edw_ops_call_trackers) a  
		# 	left join (select  \"Classification\", count(*) as \"number\" from edw_ops_call_trackers where \"Complete_Date_l\">\'#{mecinfo[i]["maxenddate"]}\' and \"Complete_Date_l\"<=\'#{mecinfo[i-1]["maxenddate"]}\'  group by \"Classification\" ) b  on a.\"Classification\"=b.\"Classification\") bbb
		# 	")		
	 #        eee=0
		# 	optimizationjs[:classtrend][0][:data].push([point,0])
		# 	optimizationjs[:classdilldowndate].push([])
		# 	while eee<opsinfo.length do		     	
	 #              optimizationjs[:classdilldowndate][point].push((opsinfo[eee]["number"]==nil ? nil :opsinfo[eee]["number"]))				  
		# 		  optimizationjs[:classtrend][0][:data][point][1]+=(opsinfo[eee]["number"]==nil ? 0:opsinfo[eee]["number"])
		# 	      eee+=1
		# 	end
	 #        longrunninginfo=Rolluperrorinformation.find_by_sql("
	 #                      select \"mid\",\"Environment\"  ,sum(\"amount\") as \"amount\"  from
	 #                      (
	 #                      select a.\"RollupDate\" as \"da\", count(*) as \"amount\", a.\"MID\" as \"mid\",a.\"Environment\" 
	 #                      from long_running_jobs a
	 #                      inner join rollupstatuses b
	 #                      on a.\"Batch_ID\" = b.\"BATCH_ID\" and b.\"DURATION\" > a.\"Threshold\" and b.\"DURATION\" > (a.\"Thirty_Days_Average\" + 15 )
	 #                      where a.\"Environment\" in ('ZEO','JAD','EMR') and   a.\"RollupDate\">\'#{mecinfo[i]["maxenddate"]}\'   and  a.\"RollupDate\"<=\'#{mecinfo[i-1]["maxenddate"]}\'
	 #                      group by a.\"MID\", a.\"RollupDate\",a.\"Environment\" 
	 #                      order by a.\"RollupDate\"
	 #                      ) t
	 #                      group by \"mid\",\"Environment\" 
	 #                      order by \"amount\" desc")						  
	 # 		optimizationjs[:longrunning][0][:data].push([point,0])		
		# 	optimizationjs[:longrunningdrilldown].push([0,0,0]);
		# 	eee=0
		# 	while eee<longrunninginfo.length do		     	
	 #              optimizationjs[:longrunning][0][:data][point][1]+=(longrunninginfo[eee]["amount"]==nil ? 0:longrunninginfo[eee]["amount"].to_i)
	 #              if(longrunninginfo[eee]["Environment"]== 'ZEO')
		# 		    optimizationjs[:longrunningdrilldown][point][0]+=(longrunninginfo[eee]["amount"]==nil ? 0:longrunninginfo[eee]["amount"].to_i)
	 #              elsif(longrunninginfo[eee]["Environment"]=='JAD')
	 #                optimizationjs[:longrunningdrilldown][point][1]+=(longrunninginfo[eee]["amount"]==nil ? 0:longrunninginfo[eee]["amount"].to_i)				  
	 #              elsif(longrunninginfo[eee]["Environment"]=='EMR')
	 #                optimizationjs[:longrunningdrilldown][point][2]+=(longrunninginfo[eee]["amount"]==nil ? 0:longrunninginfo[eee]["amount"].to_i)			  
	 #              end			  
		# 	      eee+=1
		# 	end		
		# 	 i-=1
		# 	 point+=1
	 #    end	
	 #    render json:optimizationjs.to_json
 	# end	
end
