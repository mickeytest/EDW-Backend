class CpmtimebasedController < ApplicationController  

   def index
     zeodst=1
	 emrdst=1
     pf1 = params[:RollupDate]
	 pf2 = params[:Server]
	 

	 if pf2 == 'JAD' then 
	 	pf3=(DateTime.parse(pf1)-1).strftime("%Y-%m-%d 00:00:00")
 	 else
 		pf3=DateTime.parse(pf1).strftime("%Y-%m-%d 00:00:00")
 	 end
   	# begin
   		 fetch_sql = 
				%Q[
				SELECT id, "MID", "Server", "RollupDate", level, "BatchID", "Mininum", "Maximum", "Duration", 
				       "Failed", "Start_Time", "End_Time", "Parallel_Count", SUM(DURPERSUM)/SUM(GDUR) as "overalDuration"
				FROM  
				(
				  SELECT A.*, B."Duration" AS GDUR,(B."Duration" * B.PERCENTAGE ) AS DURPERSUM 
				  FROM
				  (SELECT id, "MID", "Server", "RollupDate", level, "BatchID", "Mininum", "Maximum", "Duration", 
				       "Failed", "Start_Time", "End_Time", "Parallel_Count"
				      
				  FROM criticalpathstatuses where "RollupDate" = '#{pf3}' and "Server" = '#{pf2}' ORDER BY LEVEL) A
				  left join (
				  SELECT id, "MID", "Server", "RollupDate", level, "BatchID", "Mininum", "Maximum", "Duration", 
				       "Failed", "Start_Time", "End_Time", "Parallel_Count" ,(CASE WHEN "Maximum"="Mininum" THEN 0
				       WHEN ("Duration"-"Mininum")/("Maximum"-"Mininum")>1 THEN 1
				       WHEN ("Duration"-"Mininum")/("Maximum"-"Mininum")<0 THEN 0
				       ELSE ("Duration"-"Mininum")/("Maximum"-"Mininum") END)  as PERCENTAGE
				  FROM criticalpathstatuses where "RollupDate" = '#{pf3}' and "Server" = '#{pf2}'
				  ) B
				  ON A.level >= B.level
				 ) C
				GROUP BY 
				1,2,3,4,5,6,7,8,9,10,11,12,13
				ORDER BY level				
				]

			criticalpathinfo = Criticalpathstatus.find_by_sql(fetch_sql)

			 i=0	 
		     j=0
			 beginindex=0
			 cpminfo=Hash.new
			 cpmdatadetail=Array.new
			 cpm_high_percentage = []
			 puts (Time.new).strftime("%Y-%m-%d  %H:%M:%S" )
		 	 gap = 1
			 if pf2 == 'ZEO' then
				gap = zeodst == 1? 1: 2
				
			 elsif pf2 == 'EMR' then
				gap = emrdst == 1? -5: -6
			 else
				gap = 8
			 end

			 while i<criticalpathinfo.length do
			    cpminfodetail=Hash.new
				cpminfodetail["EVENTID"]=criticalpathinfo[i]["MID"]
				cpminfodetail["LEVEL"]=criticalpathinfo[i]["level"]
				cpminfodetail["BATCHID"]=criticalpathinfo[i]["BatchID"]
				cpminfodetail["MIN"]=(criticalpathinfo[i]["Mininum"]).round(2)
				cpminfodetail["MAX"]=(criticalpathinfo[i]["Maximum"]).round(2)
				cpminfodetail["DURATION"]=(criticalpathinfo[i]["Duration"]).round(2)
				percentage=((criticalpathinfo[i]["Duration"]-criticalpathinfo[i]["Mininum"])/(criticalpathinfo[i]["Maximum"]-criticalpathinfo[i]["Mininum"])*100).round(0)
				if percentage<=100  &&  percentage>=0
				cpminfodetail["PERCENTAGE"]=percentage
				elsif percentage<0
				cpminfodetail["PERCENTAGE"]=0
				else percentage>100
				cpminfodetail["PERCENTAGE"]=100
				end

				if(criticalpathinfo[i]["Failed"]==nil)
				cpminfodetail["FAILED"]=0
				elsif
				cpminfodetail["FAILED"]=1
				end		
		         		
				cpminfodetail["PARALLELCOUNT"]=criticalpathinfo[i]["Parallel_Count"]
				cpminfodetail["START_TS"]=criticalpathinfo[i]["Start_Time"].strftime("%Y/%m/%d %H:%M:%S")	
				cpminfodetail["END_TS"]=criticalpathinfo[i]["End_Time"].strftime("%Y/%m/%d %H:%M:%S")
				

				cpminfodetail["LOCAL_START_TS"]=(criticalpathinfo[i]["Start_Time"]+(gap*1.0/24).days).strftime("%Y/%m/%d %H:%M:%S")		
				cpminfodetail["LOCAL_END_TS"]=(criticalpathinfo[i]["End_Time"]+(gap*1.0/24).days).strftime("%Y/%m/%d %H:%M:%S")		 

				if i < 2 then
					cpminfodetail["OVERALLPERCENTAGE"] = 40
				else
					cpminfodetail["OVERALLPERCENTAGE"] = (criticalpathinfo[i]["overalDuration"]*100).round(0)
				end		
				cpmdatadetail[i]=cpminfodetail	

				if percentage> 60 then
					cpm_high_percentage << cpminfodetail
				end

				i+=1   

		     end
		    start_TS = criticalpathinfo[0]["Start_Time"].strftime("%Y/%m/%d %H:%M:%S")
		    end_TS = criticalpathinfo[criticalpathinfo.length-1]["End_Time"].strftime("%Y/%m/%d %H:%M:%S")

			long_running_sql = 
						%Q[
								SELECT "EVENT_ID","BATCH_ID","FDURATION" as "DURATION","Thirty_Days_Average",R."Start_TS",R."End_TS","BatchID"
								FROM long_running_jobs L
								INNER JOIN  
								(
									select *, (case "DURATION" when null then EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - interval '8 hour' - "Start_TS"))/60
									else "DURATION" end) as "FDURATION" from rollupstatuses
								 ) R
								on L."Batch_ID" = R."BATCH_ID"
								and R."FDURATION" > (L."Thirty_Days_Average" +15)
							 	left join (select "BatchID" from rolluperrorinformations where "Server" = '#{pf2}') I
							  	on cast(L."Batch_ID" as int) = I."BatchID"
							  	WHERE "RollupDate" = '#{pf3}' and "Environment" = '#{pf2}' 
							  	AND R."Start_TS" >'#{start_TS}' and R."End_TS" < '#{end_TS}'
						];

		    long_running = Oncallissuetracker.find_by_sql(long_running_sql);
		    long_running_detail = []


		    hash = {}
			key = -1	
			long_running.each_with_index do |i, index|
				
				found = false
				current_key = -1
				hash.each do |item|
					found = false
					current_key = item[0]
					item[1].each do |inner_item|
						if (i["Start_TS"] <= inner_item["Start_TS"]) and (i["End_TS"] >= inner_item["Start_TS"]) or (i["Start_TS"] >= inner_item["Start_TS"] and i["Start_TS"] <= inner_item["End_TS"])  then
							found = true
							break
						end
					end
					if found == false then
						break
					end
				end


				long_running_detail[index]= {
					"EVENTID" => i["EVENT_ID"],
					"BATCHID" => i["BATCH_ID"],
					"DURATION" => i["DURATION"],
					"FAILED" => i["BatchID"] == nil ? 0:1,
					"START_TS" => i["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),
					"END_TS" => i["End_TS"].strftime("%Y/%m/%d %H:%M:%S"),
					"LOCAL_START_TS" => (i["Start_TS"]+(gap*1.0/24).days).strftime("%Y/%m/%d %H:%M:%S"),
					"LOCAL_END_TS" => (i["End_TS"]+(gap*1.0/24).days).strftime("%Y/%m/%d %H:%M:%S"),
					"THRIY_DAYS_AVG" => i["Thirty_Days_Average"],
					"onCPM" => 0 
				}

				cpm_high_percentage.each do |cpm|
					if (DateTime.parse(cpm["START_TS"]) <= i["Start_TS"]) and (DateTime.parse(cpm["END_TS"]) >= i["Start_TS"]) or (DateTime.parse(cpm["START_TS"]) >= i["Start_TS"] and DateTime.parse(cpm["START_TS"]) <= i["End_TS"])  then					 
						long_running_detail[index]["onCPM"] = 1
						break
					end
				end

				if found == false
						long_running_detail[index]["x"] = current_key
						if hash.length == 0
							hash[current_key] = [i]	
						else
							hash[current_key] << i
						end		
				else
						key = key - 0.2
						long_running_detail[index]["x"] = key
						hash[key] = [i]		
				end
			end



		    cpminfo["data"]= cpmdatadetail
		    
		    cpminfo["LongRunning"] = long_running_detail

		    cpminfo["LongRunningMaxKey"] = key

   	# rescue
   	#    cpminfo = {}
   	# end
       render json: cpminfo.to_json
   end
 end