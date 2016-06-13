class CpmController < ApplicationController  
   def index
   	 zeodst=1
	 emrdst=1
     pf1 = params[:RollupDate]
	 pf2 = params[:Server]
	 pf3=DateTime.parse(pf1).strftime("%Y-%m-%d 00:00:00")

	 if pf2 == 'JAD' then 
	 	pf4=(DateTime.parse(pf1)-1).strftime("%Y-%m-%d 00:00:00")
 	 else
 		pf4=DateTime.parse(pf1).strftime("%Y-%m-%d 00:00:00")
 	 end
  begin	 

	fetch_sql = %Q[
  						SELECT "MID", "Server", "RollupDate", level, "BatchID", "Mininum", "Maximum", "Duration", 
				       "Failed", "Start_Time", "End_Time", "RollupDate_l", "Start_TS_l", "End_TS_l", "Parallel_Count", DOMAIN as "DOMAIN", case SUM(GDUR) when 0 then 0 else SUM(DURPERSUM)/SUM(GDUR) end as "overalDuration"
				FROM  
				(
				  SELECT A.*,D.DOMAIN, B."Duration" AS GDUR,(B."Duration" * B.PERCENTAGE ) AS DURPERSUM 
				  FROM
				  (SELECT  "MID", "Server", "RollupDate", level, "BatchID", "Mininum", "Maximum", "Duration", 
				       "Failed", "Start_Time", "End_Time", "RollupDate_l", "Start_TS_l", "End_TS_l", "Parallel_Count"
				      
				  FROM criticalpathstatuses where  "RollupDate_l" = '#{pf3}' and "Server" = '#{pf2}'  ORDER BY LEVEL) A
				  left join (
				  SELECT  "MID", "Server", "RollupDate", level, "BatchID", "Mininum", "Maximum", "Duration", 
				       "Failed", "Start_Time", "End_Time", "RollupDate_l", "Start_TS_l", "End_TS_l", "Parallel_Count" ,(CASE WHEN "Maximum"="Mininum" THEN 0
				       WHEN ("Duration"-"Mininum")/("Maximum"-"Mininum")>1 THEN 1
				       WHEN ("Duration"-"Mininum")/("Maximum"-"Mininum")<0 THEN 0
				       ELSE ("Duration"-"Mininum")/("Maximum"-"Mininum") END)  as PERCENTAGE
				  FROM criticalpathstatuses where "RollupDate_l" = '#{pf3}' and "Server" = '#{pf2}'
				  ) B				
				  ON A.level >= B.level
				  left join (  SELECT   "EVENT_ID",  split_part("Rollup_Domain", '-', 1) AS DOMAIN
					  FROM mid_rollup_domains) D
			          ON A."MID" = D."EVENT_ID"
				 ) C
				GROUP BY 
				1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16
				ORDER BY level		
	]
	 	 
     criticalpathinfo=Criticalpathstatus.find_by_sql(fetch_sql)
	 i=0	 
     j=0
	 beginindex=0
	 cpminfo=Hash.new
	 cpmdatadetail=Array.new
	 cpm_high_percentage = []
	 categories = []
	 long_categories = []
	 thisDomain = ''

	 overallmin = 40
	 overallmax = 40
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

		if(criticalpathinfo[i]["Failed"]==nil ||criticalpathinfo[i]["Failed"]==0 )
		cpminfodetail["FAILED"]=0
		elsif
		cpminfodetail["FAILED"]=1
		end		
         		
		cpminfodetail["PARALLELCOUNT"]=criticalpathinfo[i]["Parallel_Count"]
		cpminfodetail["START_TS"]=criticalpathinfo[i]["Start_Time"].strftime("%Y/%m/%d %H:%M:%S")	
		cpminfodetail["END_TS"]=criticalpathinfo[i]["End_Time"].strftime("%Y/%m/%d %H:%M:%S")
		

		cpminfodetail["LOCAL_START_TS"]=criticalpathinfo[i]["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S")		
		cpminfodetail["LOCAL_END_TS"]=criticalpathinfo[i]["End_TS_l"].strftime("%Y/%m/%d %H:%M:%S")		 
		

		if criticalpathinfo[i]["DOMAIN"]==nil 
			thisDomain = "OTHER"
		else
			thisDomain = criticalpathinfo[i]["DOMAIN"]
		end
		
		if not(categories.include? thisDomain) then
			categories << thisDomain
		end

		cpminfodetail["PORTFOLIO"]=categories.index(thisDomain)

		if i < 4 then
				cpminfodetail["OVERALLPERCENTAGE"] = 40
		else
				cpminfodetail["OVERALLPERCENTAGE"] = (criticalpathinfo[i-1]["overalDuration"]*100).round(0)
				if cpminfodetail["OVERALLPERCENTAGE"] > overallmax then
						overallmax = cpminfodetail["OVERALLPERCENTAGE"]
				end

				if cpminfodetail["OVERALLPERCENTAGE"] < overallmin then
						overallmin = cpminfodetail["OVERALLPERCENTAGE"]
				end

		end		
		cpmdatadetail[i]=cpminfodetail	

		if percentage> 60 then
			cpm_high_percentage << cpminfodetail
		end

		i+=1   

     end
    start_TS_l = criticalpathinfo[0]["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S")
    end_TS_l   = criticalpathinfo[criticalpathinfo.length-1]["End_TS_l"].strftime("%Y/%m/%d %H:%M:%S")


 
	long_running_sql = 
				%Q[
						SELECT D."EVENT_ID",R."Batch_ID","FDURATION" as "DURATION",R."Thirty_Days_Average",R."Start_TS",R."End_TS",R."Start_TS_l",R."End_TS_l","BatchID", "DOMAIN"
                        FROM (select * from long_running_jobs WHERE "RollupDate" =  '#{pf4}' and "Environment" = '#{pf2}' ) L
                        INNER JOIN
                       (select *, (case "End_TS"
                  when null then EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - interval '8 hour' - "Start_TS"))/60
                  else (EXTRACT(EPOCH FROM ("End_TS" - "Start_TS"))/60) end) as "FDURATION" from long_running_jobs where "Start_TS_l" >'#{start_TS_l}' and "End_TS_l" <  '#{end_TS_l}' and "Environment" ='#{pf2}' ) R
                                                on L."Batch_ID" = R."Batch_ID"
                                                and R."FDURATION" > (L."Thirty_Days_Average" +15)
                                                left join (select "BatchID" from  rolluperrorinformations where "Server" ='#{pf2}') I
                                                on cast(L."Batch_ID" as int) = I."BatchID"
                                                left join (  SELECT distinct   left("EVENT_ID",5) as "EVENTIDTO","EVENT_ID",  split_part("Rollup_Domain", '-', 1) AS "DOMAIN"  FROM mid_rollup_domains) D
                                                ON R."MID" = D."EVENTIDTO"
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
				if (i["Start_TS_l"] <= inner_item["Start_TS_l"]) and (i["End_TS_l"] >= inner_item["Start_TS_l"]) or (i["Start_TS_l"] >= inner_item["Start_TS_l"] and i["Start_TS_l"] <= inner_item["End_TS_l"])  then
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
			"LOCAL_START_TS" => i["Start_TS_l"].strftime("%Y/%m/%d %H:%M:%S"),
			"LOCAL_END_TS" =>  i["End_TS_l"].strftime("%Y/%m/%d %H:%M:%S"),
			"THRIY_DAYS_AVG" => i["Thirty_Days_Average"],
			"onCPM" => 0 
		}


		if  i["DOMAIN"]==nil 
			thisDomain = "OTHER"
		else
			thisDomain =  i["DOMAIN"]
		end
		
		if not(long_categories.include? thisDomain) then
			long_categories << thisDomain
		end

		long_running_detail[index]["PORTFOLIO"]=long_categories.index(thisDomain)

		cpm_high_percentage.each do |cpm|
			if (DateTime.parse(cpm["LOCAL_START_TS"]) <= i["Start_TS_l"]) and (DateTime.parse(cpm["LOCAL_END_TS"]) >= i["Start_TS_l"]) or (DateTime.parse(cpm["LOCAL_START_TS"]) >= i["Start_TS_l"] and DateTime.parse(cpm["LOCAL_START_TS"]) <= i["End_TS_l"])  then					 
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

    cpminfo["portfoliocategory"] = categories

	cpminfo["longportfoliocategory"] = long_categories
    
    cpminfo["overallmin"] = overallmin - 5
    cpminfo["overallmax"] = overallmax + 5
 rescue
      cpminfo= {}
 end
	  render json: cpminfo.to_json
	  end
end
