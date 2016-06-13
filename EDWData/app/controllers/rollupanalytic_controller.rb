# require 'pathname'

class RollupanalyticController < ApplicationController
#rollupendtime=Dailyrolluptime.find_by_sql("select max(\"RollupDate\") as \"rollupendtime\" from dailyrolluptimes where \"Server\"=\'#{pf}\' and  \"End_TS\" is not null")
#rollupsystemerror=Rolluperrorinformation.find_by_sql("")


	def index 
		parView = params[:View] ? params[:View].downcase : "unuse";
		# p parView;
		parEnv = params[:Environment];
		parChart = params[:Chart];
		parType = params[:Type];

		standardTime = 15;

		# 获得当前执行文件的完整路径
		# puts Pathname.new('.').realpath
		serverjs = {};

		# 1111111111111111111111111111111111111111111111111111111111111
		if parChart == "1" then
			# top1
			 if(parEnv=='ALL')
			    sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."Server" !='BER' and a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs = {:ERROR => "There is no #{parEnv} data in table dailyrolluptimes"};
				render json: serverjs.to_json;
				return;
			end
			 else
			    sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."Server" = '#{parEnv}' and a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs = {:ERROR => "There is no #{parEnv} data in table dailyrolluptimes"};
				render json: serverjs.to_json;
				return;
			end
			 end
			
			

			jsonDate = result[0]["r"].strftime("%Y-%m-%d");
			intervalTime = result[0]["e"] - result[0]["s"];
			# p "zzzzzzzzzzzzzzzzzz"
			# p "zzzzzzzzzzzzzzzzzz"
			# p "zzzzzzzzzzzzzzzzzz"
			# p intervalTime
			# p "zzzzzzzzzzzzzzzzzz"
			# p "zzzzzzzzzzzzzzzzzz"
			# p "zzzzzzzzzzzzzzzzzz"
			startTime = result[0]["s"].strftime("%Y-%m-%d %H:%M:%S");
			endTime = result[0]["e"].strftime("%Y-%m-%d %H:%M:%S");
           
		    if(parEnv=='ALL')
			  sqlScript = 
			%Q[
				select split_part(a."ErrorCode", ';', 1) ec, count(*) amount
				from rolluperrorinformations a
				where a."Server" !='BER' and a."RollupDate" = '#{jsonDate}'
				group by split_part(a."ErrorCode", ';', 1)
				order by count(*) desc;
			];
			else
			 sqlScript = 
			%Q[
				select split_part(a."ErrorCode", ';', 1) ec, count(*) amount
				from rolluperrorinformations a
				where a."Server" = '#{parEnv}' and a."RollupDate" = '#{jsonDate}'
				group by split_part(a."ErrorCode", ';', 1)
				order by count(*) desc;
			];
			end
		   
			

			result = Oncallissuetracker.find_by_sql(sqlScript);
			total = 0;
			if result.length < 1 then
				serverjs[:TOP1] = {:Top1 => 0, :Other => 0, :date => jsonDate};
				serverjs[:ERROR] = "No #{parEnv} Error Data";
			else
				serverjs[:TOP1] = {};
				serverjs[:TOP1][:Top1] = result[0]["amount"];
				result.each do |row|
					total += row["amount"];
				end
				serverjs[:TOP1][:Other] = total - serverjs[:TOP1][:Top1];
				serverjs[:TOP1][:date] = jsonDate;
			end
    if(parEnv=='ALL')
			# RUNTIME
			sqlScript = 
			%Q[
				select EXTRACT(epoch FROM sum(duration)) total
				from
				(
					select *, e."End_TS" - d."Start_TS" duration
					from
					(
						select row_number() over() rownum, b."Start_TS"
						from
						(
							select a."BATCH_ID", a."Start_TS", a."End_TS"
							from rollupstatuses a
							join rolluperrorinformations g
							on  cast(g."BatchID" as varchar) = a."BATCH_ID"
							where a."Start_TS" >= '#{startTime}' and a."End_TS" <= '#{endTime}' and a."SERVER" !='BER'
							order by a."Start_TS"
						) b
						where not exists
						(
							select *
							from
							(
								select a."BATCH_ID", a."Start_TS", a."End_TS"
								from rollupstatuses a
								join rolluperrorinformations g
							on  cast(g."BatchID" as varchar) = a."BATCH_ID"
							where a."Start_TS" >= '#{startTime}' and a."End_TS" <= '#{endTime}' and a."SERVER" !='BER'
							order by a."Start_TS"
							) c
							where b."BATCH_ID" <> c."BATCH_ID"
							and (b."Start_TS" = c."End_TS" or b."Start_TS" > c."Start_TS" and b."Start_TS" < c."End_TS")
							--and (b."End_TS" = c."Start_TS" or b."End_TS" > c."Start_TS" and b."End_TS" < c."End_TS")
						)
						order by b."Start_TS"
					) d
					left join
					(
						select row_number() over() rownum, b."End_TS"
						from
						(
							select a."BATCH_ID", a."Start_TS", a."End_TS"
							from rollupstatuses a
							join rolluperrorinformations g
							on  cast(g."BatchID" as varchar) = a."BATCH_ID"
							where a."Start_TS" >= '#{startTime}' and a."End_TS" <= '#{endTime}' and a."SERVER" !='BER'
							order by a."Start_TS"
						) b
						where not exists
						(
							select *
							from
							(
							select a."BATCH_ID", a."Start_TS", a."End_TS"
								from rollupstatuses a
								join rolluperrorinformations g
							on  cast(g."BatchID" as varchar) = a."BATCH_ID"
							where a."Start_TS" >= '#{startTime}' and a."End_TS" <= '#{endTime}' and a."SERVER" !='BER'
							order by a."Start_TS"
							) c
							where b."BATCH_ID" <> c."BATCH_ID"
							--and (b."Start_TS" = c."End_TS" or b."Start_TS" > c."Start_TS" and b."Start_TS" < c."End_TS")
							and (b."End_TS" = c."Start_TS" or b."End_TS" > c."Start_TS" and b."End_TS" < c."End_TS")
						)
						order by b."End_TS"
					) e
					on d.rownum = e.rownum
				) t;
			];
else
          # RUNTIME
			sqlScript = 
			%Q[
				select EXTRACT(epoch FROM sum(duration)) total
				from
				(
					select *, e."End_TS" - d."Start_TS" duration
					from
					(
						select row_number() over() rownum, b."Start_TS"
						from
						(
							select a."BATCH_ID", a."Start_TS", a."End_TS"
							from rollupstatuses a
							join rolluperrorinformations g
							on  cast(g."BatchID" as varchar) = a."BATCH_ID"
							where a."Start_TS" >= '#{startTime}' and a."End_TS" <= '#{endTime}' and a."SERVER" = '#{parEnv}'
							order by a."Start_TS"
						) b
						where not exists
						(
							select *
							from
							(
								select a."BATCH_ID", a."Start_TS", a."End_TS"
								from rollupstatuses a
								join rolluperrorinformations g
							on  cast(g."BatchID" as varchar) = a."BATCH_ID"
							where a."Start_TS" >= '#{startTime}' and a."End_TS" <= '#{endTime}' and a."SERVER" = '#{parEnv}'
							order by a."Start_TS"
							) c
							where b."BATCH_ID" <> c."BATCH_ID"
							and (b."Start_TS" = c."End_TS" or b."Start_TS" > c."Start_TS" and b."Start_TS" < c."End_TS")
							--and (b."End_TS" = c."Start_TS" or b."End_TS" > c."Start_TS" and b."End_TS" < c."End_TS")
						)
						order by b."Start_TS"
					) d
					left join
					(
						select row_number() over() rownum, b."End_TS"
						from
						(
							select a."BATCH_ID", a."Start_TS", a."End_TS"
							from rollupstatuses a
							join rolluperrorinformations g
							on  cast(g."BatchID" as varchar) = a."BATCH_ID"
							where a."Start_TS" >= '#{startTime}' and a."End_TS" <= '#{endTime}' and a."SERVER" = '#{parEnv}'
							order by a."Start_TS"
						) b
						where not exists
						(
							select *
							from
							(
							select a."BATCH_ID", a."Start_TS", a."End_TS"
								from rollupstatuses a
								join rolluperrorinformations g
							on  cast(g."BatchID" as varchar) = a."BATCH_ID"
							where a."Start_TS" >= '#{startTime}' and a."End_TS" <= '#{endTime}' and a."SERVER" = '#{parEnv}'
							order by a."Start_TS"
							) c
							where b."BATCH_ID" <> c."BATCH_ID"
							--and (b."Start_TS" = c."End_TS" or b."Start_TS" > c."Start_TS" and b."Start_TS" < c."End_TS")
							and (b."End_TS" = c."Start_TS" or b."End_TS" > c."Start_TS" and b."End_TS" < c."End_TS")
						)
						order by b."End_TS"
					) e
					on d.rownum = e.rownum
				) t;
			];
end
			result = Oncallissuetracker.find_by_sql(sqlScript);

			if result.length < 1 then
				serverjs[:RUNTIME] = { :Success => 0, :Failed => 0, :date => jsonDate, :FailedDate => [] };
				serverjs[:ERROR] = "No #{parEnv} Rollup Failed Job Run Time Data";
			else
				total = result[0]["total"];
				total = total ? total : 0;
				# p total;
				# p intervalTime;
				# p total / intervalTime;
				# p "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
				serverjs[:RUNTIME] = {};
				# serverjs[:RUNTIME][:Failed] = (total * 10000.0 / intervalTime).round / 100.0;
				serverjs[:RUNTIME][:Failed] = (total * 100.0 / 3600).round / 100.0;
				# serverjs[:RUNTIME][:Success] = 100 - serverjs[:RUNTIME][:Failed];
				serverjs[:RUNTIME][:Success] = ((intervalTime - total) * 100.0 / 3600).round / 100.0;
				serverjs[:RUNTIME][:date] = jsonDate;
				# p serverjs[:RUNTIME][:Failed]
				# p serverjs[:RUNTIME][:Success]
				# p "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ"
	 if(parEnv=='ALL')
		  sqlScript = 
				%Q[
					select a."MID" mid, sum(a."Duration") duration
					from rolluperrorinformations a
					where a."Server" !='BER' and a."RollupDate" = '#{jsonDate}'
					group by a."MID"
					order by sum(a."Duration") desc
					limit 10;
				];

				sqlScript2 = 
				%Q[
					select sum(a."Duration") tt
					from rolluperrorinformations a
					where a."Server" !='BER' and a."RollupDate" = '#{jsonDate}'
					order by sum(a."Duration") desc;
				];	
      else
	      sqlScript = 
				%Q[
					select a."MID" mid, sum(a."Duration") duration
					from rolluperrorinformations a
					where a."Server" = '#{parEnv}' and a."RollupDate" = '#{jsonDate}'
					group by a."MID"
					order by sum(a."Duration") desc
					limit 10;
				];

				sqlScript2 = 
				%Q[
					select sum(a."Duration") tt
					from rolluperrorinformations a
					where a."Server" = '#{parEnv}' and a."RollupDate" = '#{jsonDate}'
					order by sum(a."Duration") desc;
				];
	  end
				result = Oncallissuetracker.find_by_sql(sqlScript);
				result2 = Oncallissuetracker.find_by_sql(sqlScript2);
				serverjs[:RUNTIME][:FailedDate] = [];
				if result.length < 1 then
					serverjs[:info] = "There is no mid error";
				else
					totalTime = result2[0]["tt"];
					result.each do |row|
						# serverjs[:RUNTIME][:FailedDate].push([row["mid"], (row["duration"] / totalTime * 10000).round / 100.0]);
						serverjs[:RUNTIME][:FailedDate].push([row["mid"], (row["duration"] * 100.0 / 60.0).round / 100.0]);
						# p "wawaa"
						# p row["duration"]
					end
				end
			end
		# 2222222222222222222222222222222222222222222222222222222222222
		elsif parChart == "2" then
		  if(parEnv=='ALL')
			sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."Server" !='BER' and a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
		else
		   sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."Server" = '#{parEnv}' and a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
		end
			
			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs = {:ERROR => "There is no #{parEnv} data in table dailyrolluptimes"};
				render json: serverjs.to_json;
				return;
			end




			# unuse
			if 1 == 0 then
				# # day
				# if parView == "day" then
				# 	#TOP10Chart1
				# 	sqlScript = 
				# 	%Q[
				# 		select a."ErrorCode" ec, count(*) amount
				# 		from rolluperrorinformations a
				# 		where a."Server" = '#{parEnv}' and a."RollupDate" = '#{jsonDate}'
				# 		group by a."ErrorCode"
				# 		order by count(*) desc
				# 		limit 10;
				# 	];

				# 	result = Oncallissuetracker.find_by_sql(sqlScript);
				# 	if result.length >= 1 then
				# 		result.each_with_index do |row, index|
				# 			errCode = row["ec"];
				# 			topId = "top" + (index + 1).to_s;
				# 			serverjs[:TOP10Chart1][:data].push({
				# 				:name => errCode,
				# 				:y => row["amount"],
				# 				:drilldown => topId
				# 				});

				# 			sqlScript = 
				# 			%Q[
				# 				select a."MID" mid, sum(a."Duration") duration
				# 				from rolluperrorinformations a
				# 				where a."Server" = '#{parEnv}' and a."RollupDate" = '#{jsonDate}' and a."ErrorCode" = '#{errCode}'
				# 				group by a."MID";
				# 			];

				# 			subResult = Oncallissuetracker.find_by_sql(sqlScript);

				# 			if subResult.length >= 1 then
				# 				errData = [];
				# 				subResult.each do |subRow|
				# 					errData.push([subRow["mid"], subRow["duration"]]);
				# 				end
				# 				serverjs[:TOP10Chart1][:drilldown].push({
				# 						:id => topId,
				# 						:data => errData
				# 					});
				# 			end
				# 		end
				# 	end

				# 	#TOP10Chart2
				# 	sqlScript = 
				# 	%Q[
				# 		select a."MID" mid, count(*) amount
				# 		from rolluperrorinformations a
				# 		where a."Server" = '#{parEnv}' and a."RollupDate" = '#{jsonDate}'
				# 		group by a."MID"
				# 		order by count(*) desc
				# 		limit 10;
				# 	];

				# 	result = Oncallissuetracker.find_by_sql(sqlScript);
				# 	if result.length >= 1 then
				# 		result.each_with_index do |row, index|
				# 			mid = row["mid"];
				# 			topId = "top" + (index + 1).to_s;
				# 			serverjs[:TOP10Chart2][:data].push({
				# 				:name => mid,
				# 				:y => row["amount"],
				# 				:drilldown => topId
				# 				});

				# 			sqlScript = 
				# 			%Q[
				# 				select a."ErrorCode" ec, sum(a."Duration") duration
				# 				from rolluperrorinformations a
				# 				where a."Server" = '#{parEnv}' and a."RollupDate" = '#{jsonDate}' and a."MID" = '#{mid}'
				# 				group by a."ErrorCode";
				# 			];

				# 			subResult = Oncallissuetracker.find_by_sql(sqlScript);

				# 			if subResult.length >= 1 then
				# 				errData = [];
				# 				subResult.each do |subRow|
				# 					errData.push([subRow["ec"], subRow["duration"]]);
				# 				end
				# 				serverjs[:TOP10Chart2][:drilldown].push({
				# 						:id => topId,
				# 						:data => errData
				# 					});
				# 			end
				# 		end
				# 	end
				# else
			end
			currentDay = result[0]["r"];
			#jsonDate = currentDay.strftime("%Y-%m-%d");
			startTime = result[0]["s"].strftime("%Y-%m-%d %H:%M:%S");
			endTime = result[0]["e"].strftime("%Y-%m-%d %H:%M:%S");
			
		   if parView == "day" then
				startDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");
				endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");
				jsonDate = currentDay.strftime("%Y-%m-%d");
			# week
			elsif parView == "week" then
				startDay = (currentDay - 6 * 24 * 3600).strftime("%Y-%m-%d %H:%M:%S");
				endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");
				jsonDate = DateTime.parse(startDay).strftime("%Y-%m-%d")  + "~" + DateTime.parse(endDay).strftime("%Y-%m-%d");
			# month
			elsif parView == "month" then
				startDay = (currentDay - 29 * 24 * 3600).strftime("%Y-%m-%d %H:%M:%S");
				endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");
				jsonDate = DateTime.parse(startDay).strftime("%Y-%m-%d")  + "~" + DateTime.parse(endDay).strftime("%Y-%m-%d");
			# year
			elsif parView == "year" then
				startDay = (currentDay - 364 * 24 * 3600).strftime("%Y-%m-%d %H:%M:%S");
				endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");
				jsonDate = DateTime.parse(startDay).strftime("%Y-%m-%d")  + "~" + DateTime.parse(endDay).strftime("%Y-%m-%d");
			end

		    serverjs[:TOP10Chart1] = {};
			serverjs[:TOP10Chart1][:date] = jsonDate;
			serverjs[:TOP10Chart1][:data] = [];
			serverjs[:TOP10Chart1][:drilldown] = [];

			serverjs[:TOP10Chart2] = {};
			serverjs[:TOP10Chart2][:date] = jsonDate;
			serverjs[:TOP10Chart2][:data] = [];
			serverjs[:TOP10Chart2][:drilldown] = [];
			#TOP10Chart1
			
		if(parEnv=='ALL')	
			sqlScript = 
			%Q[
				select split_part(a."ErrorCode", ';', 1) ec, count(*) amount
				from rolluperrorinformations a
				where a."Server"!='BER' and a."RollupDate" between '#{startDay}' and '#{endDay}'
				group by split_part(a."ErrorCode", ';', 1)
				order by count(*) desc
				limit 10;
			];
         else
		   sqlScript = 
			%Q[
				select split_part(a."ErrorCode", ';', 1) ec, count(*) amount
				from rolluperrorinformations a
				where a."Server" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
				group by split_part(a."ErrorCode", ';', 1)
				order by count(*) desc
				limit 10;
			];
		 end
			result = Oncallissuetracker.find_by_sql(sqlScript);

			if result.length < 1 then
				serverjs[:ERROR] = "No #{parEnv} Error Data by #{parView}";
			else
				result.each_with_index do |row, index|
					errCode = row["ec"];
					topId = "top" + (index + 1).to_s;
					serverjs[:TOP10Chart1][:data].push({
						:name => errCode,
						:y => row["amount"],
						:drilldown => topId
						});
         if(parEnv=='ALL')	
					sqlScript = 
					%Q[
						select a."MID" mid, count(*) duration
						from rolluperrorinformations a
						where a."Server" !='BER' and a."RollupDate" between '#{startDay}' and '#{endDay}' and split_part(a."ErrorCode", ';', 1) = '#{errCode}'
						group by a."MID";
					];
         else
		           sqlScript = 
					%Q[
						select a."MID" mid, count(*) duration
						from rolluperrorinformations a
						where a."Server" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}' and split_part(a."ErrorCode", ';', 1) = '#{errCode}'
						group by a."MID";
					];
		 end
					subResult = Oncallissuetracker.find_by_sql(sqlScript);

					if subResult.length >= 1 then
						errData = [];
						subResult.each do |subRow|
							errData.push([subRow["mid"], subRow["duration"]]);
						end
						serverjs[:TOP10Chart1][:drilldown].push({
								:id => topId,
								:data => errData
							});
					end
				end
			end

			#TOP10Chart2
		  if(parEnv=='ALL')
			sqlScript = 
			%Q[
				select a."MID" mid, count(*) amount
				from rolluperrorinformations a
				where a."Server" !='BER' and a."RollupDate" between '#{startDay}' and '#{endDay}'
				group by a."MID"
				order by count(*) desc
				limit 10;
			];
			else
			 sqlScript = 
			%Q[
				select a."MID" mid, count(*) amount
				from rolluperrorinformations a
				where a."Server" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
				group by a."MID"
				order by count(*) desc
				limit 10;
			];
			end

			result = Oncallissuetracker.find_by_sql(sqlScript);

			if result.length < 1 then
				serverjs[:ERROR] = "No #{parEnv} Error Data by #{parView}";
			else
				result.each_with_index do |row, index|
					mid = row["mid"];
					topId = "top" + (index + 1).to_s;
					serverjs[:TOP10Chart2][:data].push({
						:name => mid,
						:y => row["amount"],
						:drilldown => topId
						});
  if(parEnv=='ALL')
					sqlScript = 
					%Q[
						select split_part(a."ErrorCode", ';', 1) ec, count(*) duration
						from rolluperrorinformations a
						where a."Server" !='BER' and a."RollupDate" between '#{startDay}' and '#{endDay}' and a."MID" = '#{mid}'
						group by split_part(a."ErrorCode", ';', 1)
					];
  else
                 sqlScript = 
					%Q[
						select split_part(a."ErrorCode", ';', 1) ec, count(*) duration
						from rolluperrorinformations a
						where a."Server" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}' and a."MID" = '#{mid}'
						group by split_part(a."ErrorCode", ';', 1)
					];
  end

					subResult = Oncallissuetracker.find_by_sql(sqlScript);

					if subResult.length >= 1 then
						errData = [];
						subResult.each do |subRow|
							errData.push([subRow["ec"], subRow["duration"]]);
						end
						serverjs[:TOP10Chart2][:drilldown].push({
								:id => topId,
								:data => errData
							});
					end
				end
			end
		# 3333333333333333333333333333333333333333333333333333333333333
		elsif parChart == "3" then
		  if(parEnv=='ALL')	
			sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."Server" !='BER' and a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
			else
			sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."Server" = '#{parEnv}' and a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
			end
			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs = {:ERROR => "There is no #{parEnv} data in table dailyrolluptimes"};
				render json: serverjs.to_json;
				return;
			end

			# day
			if parView == "day" then
				currentDay = result[0]["r"];

				startDay = (currentDay - 6 * 24 * 3600).strftime("%Y-%m-%d %H:%M:%S");
				endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");
				intervals = getCompleteIntervalDay2(currentDay - 6 * 24 * 3600, 6);
				sqlScript = 
				%Q[
					select d, er, amount
					from
					(
						select a."RollupDate" d, split_part(a."ErrorCode", ';', 1) er, count(*) amount,
								row_number() over(PARTITION BY a."RollupDate" ORDER BY count(*) desc) rownum
						from rolluperrorinformations a
						where a."RollupDate" between '#{startDay}' and '#{endDay}'
						group by a."RollupDate", split_part(a."ErrorCode", ';', 1)
						order by a."RollupDate"
					) t
					where rownum <= 3
					order by d, rownum
				];

				sqlScript2 = 
				%Q[
					select er, sum(amount) am
					from
					(
						select d, er, amount
						from
						(
							select a."RollupDate" d, split_part(a."ErrorCode", ';', 1) er, count(*) amount,
									row_number() over(PARTITION BY a."RollupDate" ORDER BY count(*) desc) rownum
							from rolluperrorinformations a
							where a."RollupDate" between '#{startDay}' and '#{endDay}'
							group by a."RollupDate", split_part(a."ErrorCode", ';', 1)
							order by a."RollupDate"
						) t
						where rownum <= 3
						order by d, rownum
					) t
					group by er
				];
			# week
			elsif parView == "week" then
				startDay = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).strftime("%u").to_i - 12*7 + 1).strftime("%Y-%m-%d %H:%M:%S");
				endDay = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 23:59:59') - (Time.new).strftime("%u").to_i).strftime("%Y-%m-%d %H:%M:%S");
				intervals = getCompleteIntervalWeek(DateTime.parse(startDay), 11, "%h.%d");
				sqlScript = 
				%Q[
					select d, er, amount
					from
					(
						select min(da) d, er, sum(amount) amount, row_number() over(PARTITION BY week ORDER BY sum(amount) desc) rownum, week
						from
						(
							select a."RollupDate" da, trunc(extract( day from (a."RollupDate" -  '#{startDay} ')) /7) as week,
								split_part(a."ErrorCode", ';', 1) er, count(*) amount
							from rolluperrorinformations a
							where a."RollupDate" between '#{startDay}' and '#{endDay}'
							group by a."RollupDate", split_part(a."ErrorCode", ';', 1)
							order by a."RollupDate"
						) t
						group by week, er
						order by week, er
					) t
					where rownum <= 3
					order by week, rownum
				];

				sqlScript2 = 
				%Q[
					select er, sum(amount) am
					from
					(
						select d, er, amount
						from
						(
							select min(da) d, er, sum(amount) amount, row_number() over(PARTITION BY week ORDER BY sum(amount) desc) rownum, week
							from
							(
								select a."RollupDate" da, trunc(extract( day from (a."RollupDate" -  '#{startDay} ')) /7) as week,
									split_part(a."ErrorCode", ';', 1) er, count(*) amount
								from rolluperrorinformations a
								where a."RollupDate" between '#{startDay}' and '#{endDay}'
								group by a."RollupDate", split_part(a."ErrorCode", ';', 1)
								order by a."RollupDate"
							) t
							group by week, er
							order by week, er
						) t
						where rownum <= 3
						order by week, rownum
					) t
					group by er
				];
			# month
			elsif parView == "month" then
				startDay = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 00:00:00') << 3).strftime("%Y-%m-%d %H:%M:%S");
				endDay = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 23:59:59') - 1).strftime("%Y-%m-%d %H:%M:%S");
				intervals = getCompleteIntervalMonth(DateTime.parse(startDay), 2, "%h, %Y");
				sqlScript = 
				%Q[
					select d, er, amount
					from
					(
						select min(da) d, er, sum(amount) amount, row_number() over(PARTITION BY month ORDER BY sum(amount) desc) rownum, month
						from
						(
							select a."RollupDate" da, EXTRACT(YEAR FROM a."RollupDate") * 100 + EXTRACT(MONTH FROM a."RollupDate") as month,
								split_part(a."ErrorCode", ';', 1) er, count(*) amount
							from rolluperrorinformations a
							where a."RollupDate" between '#{startDay}' and '#{endDay}'
							group by a."RollupDate", split_part(a."ErrorCode", ';', 1)
							order by a."RollupDate"
						) t
						group by month, er
						order by month, er
					) t
					where rownum <= 3
					order by month, rownum
				];

				sqlScript2 = 
				%Q[
					select er, sum(amount) am
					from
					(
						select d, er, amount
						from
						(
							select min(da) d, er, sum(amount) amount, row_number() over(PARTITION BY month ORDER BY sum(amount) desc) rownum, month
							from
							(
								select a."RollupDate" da, EXTRACT(YEAR FROM a."RollupDate") * 100 + EXTRACT(MONTH FROM a."RollupDate") as month,
									split_part(a."ErrorCode", ';', 1) er, count(*) amount
								from rolluperrorinformations a
								where a."RollupDate" between '#{startDay}' and '#{endDay}'
								group by a."RollupDate", split_part(a."ErrorCode", ';', 1)
								order by a."RollupDate"
							) t
							group by month, er
							order by month, er
						) t
						where rownum <= 3
						order by month, rownum
					) t
					group by er
				];
			# mecmonth
			elsif parView == "mecmonth" then
			      	serverjs[:x] = [];
			        serverjs[:ecd] = [];
			        serverjs[:column] = [{:name => "TOP3", :value => []}, {:name => "TOP1", :value => []}, {:name => "TOP2", :value => []}];
			        serverjs[:spline] = {:data => []};
			        serverjs[:pie] = [];
                    mecinfo = MecCalendar.find_by_sql("select * from (
                       select \"Month\",\"Year\", max(\"MECEndDate_l\") as \"maxenddate\" from mec_calendars group  by  \"Month\"  ,\"Year\" order by \"Year\" desc,\"Month\" desc ) aaa
                       where now()>aaa.\"maxenddate\" limit 4")
					   
                    i=mecinfo.length-1
				    while i>0
					   serverjs[:x].push(mecinfo[i]["maxenddate"].strftime("%h, %Y")) 
					   i-=1
					end
					
					i=mecinfo.length-1
					tt=0
					firstpie=0
					secondpie=0
					thirdpie=0
					while i>0
					   errorinfo=Rolluperrorinformation.find_by_sql("select * from(select * from 
                           (select split_part(\"ErrorCode\", ';', 1) as \"errorcode\",count(*) as \"amount\" from rolluperrorinformations
                            where \"RollupDate\" > \'#{mecinfo[i]["maxenddate"]}\' and \"RollupDate\" <=\'#{mecinfo[i-1]["maxenddate"]}\'
                            group by split_part(\"ErrorCode\", ';', 1)
                            order by amount desc) aa
                            limit 3) aaa order by aaa.\"errorcode\"")
					   serverjs[:column][0][:value].push(:x=>tt,:y=>errorinfo[0]["amount"]) 
					   serverjs[:column][1][:value].push(:x=>tt,:y=>errorinfo[1]["amount"]) 
					   serverjs[:column][2][:value].push(:x=>tt,:y=>errorinfo[2]["amount"]) 
					   firstpie+=errorinfo[0]["amount"]
					   secondpie+=errorinfo[1]["amount"]
					   thirdpie+=errorinfo[2]["amount"]
					   serverjs[:spline][:data].push(errorinfo[0]["amount"]+errorinfo[1]["amount"]+errorinfo[2]["amount"])
				    i-=1
					tt+=1
                    end
                 j=0
					   while j<errorinfo.length
                        serverjs[:ecd].push(errorinfo[j]["errorcode"])  
						j+=1
                       end
					   serverjs[:pie].push(:x=>0,:y=>firstpie)
					   serverjs[:pie].push(:x=>1,:y=>secondpie)
					   serverjs[:pie].push(:x=>2,:y=>thirdpie)
			# year
			elsif parView == "year" then
				startDay = "1980-1-1";
				endDay = "2050-12-31";
		if(parEnv=='ALL')		
				sqlScript = 
				%Q[
					select EXTRACT(YEAR FROM min(a."RollupDate")) as year
					from dailyrolluptimes a
					where a."Server" !='BER' and a."End_TS" is not null and a."ElapseTime" > 0
				];
	    else
		     sqlScript = 
				%Q[
					select EXTRACT(YEAR FROM min(a."RollupDate")) as year
					from dailyrolluptimes a
					where a."Server" = '#{parEnv}' and a."End_TS" is not null and a."ElapseTime" > 0
				];
		end
				result = Oncallissuetracker.find_by_sql(sqlScript);
				intervals = getCompleteIntervalYear2(result[0]["year"].round);
				sqlScript = 
				%Q[
					select d, er, amount
					from
					(
						select min(da) d, er, sum(amount) amount, row_number() over(PARTITION BY year ORDER BY sum(amount) desc) rownum, year
						from
						(
							select a."RollupDate" da, EXTRACT(YEAR FROM a."RollupDate") as year,
								split_part(a."ErrorCode", ';', 1) er, count(*) amount
							from rolluperrorinformations a
							where a."RollupDate" between '#{startDay}' and '#{endDay}' and a."SystemIssueFlag" = 'YES'
							group by a."RollupDate", split_part(a."ErrorCode", ';', 1)
							order by a."RollupDate"
						) t
						group by year, er
						order by year, er
					) t
					where rownum <= 3
					order by year, rownum
				];

				sqlScript2 = 
				%Q[
					select er, sum(amount) am
					from
					(
						select d, er, amount
						from
						(
							select min(da) d, er, sum(amount) amount, row_number() over(PARTITION BY year ORDER BY sum(amount) desc) rownum, year
							from
							(
								select a."RollupDate" da, EXTRACT(YEAR FROM a."RollupDate") as year,
									split_part(a."ErrorCode", ';', 1) er, count(*) amount
								from rolluperrorinformations a
								where a."RollupDate" between '#{startDay}' and '#{endDay}' and a."SystemIssueFlag" = 'YES'
								group by a."RollupDate", split_part(a."ErrorCode", ';', 1)
								order by a."RollupDate"
							) t
							group by year, er
							order by year, er
						) t
						where rownum <= 3
						order by year, rownum
					) t
					group by er
				];
			end

          if(parView!="mecmonth")
			serverjs[:x] = [];
			serverjs[:ecd] = [];
			serverjs[:column] = [{:name => "TOP3", :value => []}, {:name => "TOP1", :value => []}, {:name => "TOP2", :value => []}];
			serverjs[:spline] = {:data => []};
			serverjs[:pie] = [];

			intervals.each do |interval|
				serverjs[:x].push(interval);
			end

			intervals.length.times do
				serverjs[:spline][:data].push(0);
				serverjs[:column][0][:value].push({:x => nil, :y => 0});
				serverjs[:column][1][:value].push({:x => nil, :y => 0});
				serverjs[:column][2][:value].push({:x => nil, :y => 0});
			end

			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs[:ERROR] = "No #{parEnv} Rollup Error Status by #{parView}";

				render json: serverjs.to_json;
				return;
			end

			result2 = Oncallissuetracker.find_by_sql(sqlScript2);

			top1Count = 0;
			top2Count = 0;
			top3Count = 0;

			result2.each_with_index do |row, index|
				serverjs[:ecd].push(row["er"]);
				serverjs[:pie].push({:x => index, :y => row["am"].round});
			end

			lastDay = "";
			# p intervals
			result.each do |row|
				amount = row["amount"].round;

				if parView == "day" then
					xDate = row["d"].strftime("%h.%d");
				elsif parView == "week" then
					weekMonday = DateTime.parse(row["d"].strftime("%Y-%m-%d")+ ' 00:00:00') - row["d"].strftime("%u").to_i + 1;
					weekSunday = weekMonday + 6;
					xDate = "#{weekMonday.strftime("%h.%d")} ~ #{weekSunday.strftime("%h.%d")}";
				elsif parView == "month" then
					xDate = row["d"].strftime("%h, %Y");
				elsif parView == "year" then
					xDate = row["d"].strftime("%Y");
				end	

				# p "AAAAAAAAAAAAAAAAAAAAAAAA"
				# p xDate
				# p "date is : "+ xDate;
				# p "erorr code is : "+ row["er"];
				# p "amount is : "+ row["amount"].to_s;

				if lastDay == xDate then
					if top2Count == top3Count then
						top2Count += 1;
						# p "top2Count"
						serverjs[:column][2][:value][serverjs[:x].index(xDate)][:x] = serverjs[:ecd].index(row["er"]);
						serverjs[:column][2][:value][serverjs[:x].index(xDate)][:y] = amount;
					else
						top3Count += 1;
						# p "top3Count"
						serverjs[:column][0][:value][serverjs[:x].index(xDate)][:y] = amount;
						serverjs[:column][0][:value][serverjs[:x].index(xDate)][:x] = serverjs[:ecd].index(row["er"]);
					end
				else
					if top1Count > top2Count then
						top2Count += 1;
						# p "top2Count"
						# serverjs[:column][2][:value].push({:x => nil, :y => nil});
					end

					if top1Count > top3Count then
						top3Count += 1;
						# p "top3Count"
						# serverjs[:column][0][:value].push({:x => nil, :y => nil});
					end

					lastDay = xDate;
					# serverjs[:x].push(xDate);
					# serverjs[:spline][:data].push(0);
					top1Count += 1;
						# p "top1Count"
					# serverjs[:column][1][:value].push({:x => serverjs[:ecd].index(row["er"]), :y => amount});
					serverjs[:column][1][:value][serverjs[:x].index(xDate)][:y] = amount;
					serverjs[:column][1][:value][serverjs[:x].index(xDate)][:x] = serverjs[:ecd].index(row["er"]);
				end
				# p "before is :" + serverjs[:spline][:data][serverjs[:spline][:data].length - 1].to_s;
				serverjs[:spline][:data][serverjs[:x].index(xDate)] += amount;
				# p "after is :" + serverjs[:spline][:data][serverjs[:spline][:data].length - 1].to_s;
			end
           end
			# if top1Count > top2Count then
			# 			# p "top2Count"
			# 	serverjs[:column][2][:value].push({:x => nil, :y => nil});
			# end

			# if top1Count > top3Count then
			# 			# p "top3Count"
			# 	serverjs[:column][0][:value].push({:x => nil, :y => nil});
			# end,
		# 4444444444444444444444444444444444444444444444444444444444444
		elsif parChart == "4" then
			sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs = {:ERROR => "There is no data in table dailyrolluptimes"};
				render json: serverjs.to_json;
				return;
			end

			sysFlag = "true";
			if parType == "1" then
				sysFlag = "true";
			elsif parType == "2" then
				sysFlag = %Q[a."SystemIssueFlag" = 'YES'];
			end

			# day
			if parView == "day" then
				currentDay = result[0]["r"];
				startDay = (currentDay - 6 * 24 * 3600).strftime("%Y-%m-%d %H:%M:%S");
				endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");
				intervals = getCompleteIntervalDay2(currentDay - 6 * 24 * 3600, 6);
				sqlScript = 
				%Q[
					select a."Server" sev, a."RollupDate" d, count(*) amount
					from rolluperrorinformations a
					where a."Server" in ('ZEO', 'EMR', 'JAD') and a."RollupDate" between '#{startDay}' and '#{endDay}' and #{sysFlag}
					group by a."Server", a."RollupDate"
					order by a."RollupDate"
				];

				sqlScript2 = 
				%Q[
					select sev, sum(amount) am
					from
					(
						select a."Server" sev, a."RollupDate" d, count(*) amount
						from rolluperrorinformations a
						where a."Server" in ('ZEO', 'EMR', 'JAD') and a."RollupDate" between '#{startDay}' and '#{endDay}' and #{sysFlag}
						group by a."Server", a."RollupDate"
						order by a."RollupDate"
					) t
					group by sev
				];
			# week
			elsif parView == "week" then
				startDay = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).strftime("%u").to_i - 12*7 + 1).strftime("%Y-%m-%d %H:%M:%S");
				endDay = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 23:59:59') - (Time.new).strftime("%u").to_i).strftime("%Y-%m-%d %H:%M:%S");
				intervals = getCompleteIntervalWeek(DateTime.parse(startDay), 11, "%h.%d");
				sqlScript = 
				%Q[
					select d, sev, amount
					from
					(
						select sev, min(da) d, sum(amount) amount, week
						from
						(
							select a."Server" sev, a."RollupDate" da, trunc(extract( day from (a."RollupDate" -  '#{startDay} ')) /7) as week, count(*) amount
							from rolluperrorinformations a
							where a."Server" in ('ZEO', 'EMR', 'JAD') and a."RollupDate" between '#{startDay}' and '#{endDay}' and #{sysFlag}
							group by a."Server", a."RollupDate"
							order by a."RollupDate"
						) t
						group by sev, week
						order by week
					) t
					order by week
				];

				sqlScript2 = 
				%Q[
					select sev, sum(amount) am
					from
					(
						select d, sev, amount
						from
						(
							select sev, min(da) d, sum(amount) amount, week
							from
							(
								select a."Server" sev, a."RollupDate" da, trunc(extract( day from (a."RollupDate" -  '#{startDay} ')) /7) as week, count(*) amount
								from rolluperrorinformations a
								where a."Server" in ('ZEO', 'EMR', 'JAD') and a."RollupDate" between '#{startDay}' and '#{endDay}' and #{sysFlag}
								group by a."Server", a."RollupDate"
								order by a."RollupDate"
							) t
							group by sev, week
							order by week
						) t
						order by week
					) t
					group by sev
				];
			# month
			elsif parView == "month" then
				startDay = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 00:00:00') << 3).strftime("%Y-%m-%d %H:%M:%S");
				endDay = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 23:59:59') - 1).strftime("%Y-%m-%d %H:%M:%S");
				intervals = getCompleteIntervalMonth(DateTime.parse(startDay), 2, "%h, %Y");
				sqlScript = 
				%Q[
					select d, sev, amount
					from
					(
						select sev, min(da) d, sum(amount) amount, month
						from
						(
							select a."Server" sev, a."RollupDate" da, EXTRACT(YEAR FROM a."RollupDate") * 100 + EXTRACT(MONTH FROM a."RollupDate") as month, count(*) amount
							from rolluperrorinformations a
							where a."Server" in ('ZEO', 'EMR', 'JAD') and a."RollupDate" between '#{startDay}' and '#{endDay}' and #{sysFlag}
							group by a."Server", a."RollupDate"
							order by a."RollupDate"
						) t
						group by sev, month
						order by month
					) t
					order by month
				];

				sqlScript2 = 
				%Q[
					select sev, sum(amount) am
					from
					(
						select d, sev, amount
						from
						(
							select sev, min(da) d, sum(amount) amount, month
							from
							(
								select a."Server" sev, a."RollupDate" da, EXTRACT(YEAR FROM a."RollupDate") * 100 + EXTRACT(MONTH FROM a."RollupDate") as month, count(*) amount
								from rolluperrorinformations a
								where a."Server" in ('ZEO', 'EMR', 'JAD') and a."RollupDate" between '#{startDay}' and '#{endDay}' and #{sysFlag}
								group by a."Server", a."RollupDate"
								order by a."RollupDate"
							) t
							group by sev, month
							order by month
						) t
						order by month
					) t
					group by sev
				];
			elsif parView == "mecmonth" then
				serverjs[:Categories] = [];
			    serverjs["ZEO"] = [];
			    serverjs["EMR"] = [];
			    serverjs["JAD"] = [];
			    serverjs[:Spline] = [];
			    serverjs[:Pie] = [{:name => "ZEO", :y => 0}, {:name => "JAD", :y => 0}, {:name => "EMR", :y => 0}];
			  mecinfo = MecCalendar.find_by_sql("select * from (
                       select \"Month\",\"Year\", max(\"MECEndDate_l\") as \"maxenddate\" from mec_calendars group  by  \"Month\"  ,\"Year\" order by \"Year\" desc,\"Month\" desc ) aaa
                       where now()>aaa.\"maxenddate\" limit 4")
					   
                    i=mecinfo.length-1
				    while i>0
					   serverjs[:Categories].push(mecinfo[i]["maxenddate"].strftime("%h, %Y")) 
					   i-=1
					end
					
					i=mecinfo.length-1
					tt=0
					firstpie=0
					secondpie=0
					while i>0
					   errorinfo=Rolluperrorinformation.find_by_sql("select \"Server\",count(*) \"amount\" from rolluperrorinformations where 
                       \"RollupDate\">\'#{mecinfo[i]["maxenddate"]}\'   and  \"RollupDate\"<\'#{mecinfo[i-1]["maxenddate"]}\'  and \"Server\" in ('ZEO', 'EMR', 'JAD')
                       group by \"Server\"")					   
					   serverjs["ZEO"].push(errorinfo[1]["amount"]) 
					   serverjs["EMR"].push(0) 
					   serverjs["JAD"].push(errorinfo[0]["amount"]) 
					   firstpie+=errorinfo[0]["amount"]
					   secondpie+=errorinfo[1]["amount"]
					   serverjs[:Spline].push((errorinfo[0]["amount"]+errorinfo[1]["amount"]))
				    i-=1
					tt+=1
                    end
					   serverjs[:Pie][0][:y]=secondpie
					   serverjs[:Pie][1][:y]=firstpie
					   serverjs[:Pie][2][:y]=0

			# year
			elsif parView == "year" then
				startDay = "1980-1-1";
				endDay = "2050-12-31";
				sqlScript = 
				%Q[
					select EXTRACT(YEAR FROM min(a."RollupDate")) as year
					from dailyrolluptimes a
					where a."Server" = '#{parEnv}' and a."End_TS" is not null and a."ElapseTime" > 0
				];
				result = Oncallissuetracker.find_by_sql(sqlScript);
				intervals = getCompleteIntervalYear2(result[0]["year"].round);
				sqlScript = 
				%Q[
					select d, sev, amount
					from
					(
						select sev, min(da) d, sum(amount) amount, year
						from
						(
							select a."Server" sev, a."RollupDate" da, EXTRACT(YEAR FROM a."RollupDate") as year, count(*) amount
							from rolluperrorinformations a
							where a."Server" in ('ZEO', 'EMR', 'JAD') and a."RollupDate" between '#{startDay}' and '#{endDay}' and #{sysFlag}
							group by a."Server", a."RollupDate"
							order by a."RollupDate"
						) t
						group by sev, year
						order by year
					) t
					order by year
				];

				sqlScript2 = 
				%Q[
					select sev, sum(amount) am
					from
					(
						select d, sev, amount
						from
						(
							select sev, min(da) d, sum(amount) amount, year
							from
							(
								select a."Server" sev, a."RollupDate" da, EXTRACT(YEAR FROM a."RollupDate") as year, count(*) amount
								from rolluperrorinformations a
								where a."Server" in ('ZEO', 'EMR', 'JAD') and a."RollupDate" between '#{startDay}' and '#{endDay}' and #{sysFlag}
								group by a."Server", a."RollupDate"
								order by a."RollupDate"
							) t
							group by sev, year
							order by year
						) t
						order by year
					) t
					group by sev
				];
			end
         if(parView!="mecmonth")
			serverjs[:Categories] = [];
			serverjs["ZEO"] = [];
			serverjs["EMR"] = [];
			serverjs["JAD"] = [];
			serverjs[:Spline] = [];
			serverjs[:Pie] = [{:name => "ZEO", :y => 0}, {:name => "JAD", :y => 0}, {:name => "EMR", :y => 0}];

			intervals.each do |interval|
				serverjs[:Categories].push(interval);
			end

			intervals.length.times do
				serverjs[:Spline].push(0);
				serverjs["ZEO"].push(0);
				serverjs["EMR"].push(0);
				serverjs["JAD"].push(0);
			end

			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs[:ERROR] = "No Rollup Recovery Data by #{parView}";
				render json: serverjs.to_json;
				return;
			end

			result2 = Oncallissuetracker.find_by_sql(sqlScript2);

			result2.each do |row|
				element = serverjs[:Pie].find do |server|
					server[:name] == row["sev"]
				end
				element[:y] = row["am"].round
			end

			lastDay = "";
			result.each do |row|
				amount = row["amount"].round;

				if parView == "day" then
					xDate = row["d"].strftime("%h.%d");
				elsif parView == "week" then
					weekMonday = DateTime.parse(row["d"].strftime("%Y-%m-%d")+ ' 00:00:00') - row["d"].strftime("%u").to_i + 1;
					weekSunday = weekMonday + 6;
					xDate = "#{weekMonday.strftime("%h.%d")} ~ #{weekSunday.strftime("%h.%d")}";
				elsif parView == "month" then
					xDate = row["d"].strftime("%h, %Y");
				elsif parView == "year" then
					xDate = row["d"].strftime("%Y");
				end	

				# p "date is : "+ xDate;
				# p "erorr code is : "+ row["er"];
				# p "amount is : "+ row["amount"].to_s;

				# if lastDay == xDate then
				# else
					# if serverjs["ZEO"].length > serverjs["EMR"].length then
					# 	serverjs["EMR"].push(0);
					# end

					# if serverjs["ZEO"].length > serverjs["JAD"].length then
					# 	serverjs["JAD"].push(0);
					# end

					# if serverjs["EMR"].length > serverjs["ZEO"].length then
					# 	serverjs["ZEO"].push(0);
					# end

					# if serverjs["EMR"].length > serverjs["JAD"].length then
					# 	serverjs["JAD"].push(0);
					# end

					# if serverjs["JAD"].length > serverjs["ZEO"].length then
					# 	serverjs["ZEO"].push(0);
					# end

					# if serverjs["JAD"].length > serverjs["EMR"].length then
					# 	serverjs["EMR"].push(0);
					# end

					# lastDay = xDate;
					# serverjs[:Categories].push(xDate);
					# serverjs[:Spline].push(0);
				# end
				serverjs[row["sev"]][serverjs[:Categories].index(xDate)] = amount;
				serverjs[:Spline][serverjs[:Categories].index(xDate)] += amount;
			end
		end
		# 5555555555555555555555555555555555555555555555555555555555555
		elsif parChart == "5" then
			sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs = {:ERROR => "There is no data in table dailyrolluptimes"};
				render json: serverjs.to_json;
				return;
			end

			# day
			if parView == "day" then
				currentDay = result[0]["r"];

				startDay = (currentDay - 6 * 24 * 3600).strftime("%Y-%m-%d %H:%M:%S");
				endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");

				sqlScript = 
				%Q[
					select a."RollupDate" da, count(*) amount
					from long_running_jobs a
					inner join rollupstatuses b
					on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
					where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
					group by a."RollupDate"
					order by a."RollupDate"
				];

				serverjs[:date] = (currentDay - 6 * 24 * 3600).strftime("%Y/%m/%d");
				serverjs[:data] = [];

				result = Oncallissuetracker.find_by_sql(sqlScript);
				if result.length < 1 then
					7.times do |t|
						serverjs[:data].push(0);
					end
					serverjs[:ERROR] = "No #{parEnv} Long Runtime Job by Day";
				else
					days = getCompleteIntervalDay(currentDay - 6 * 24 * 3600, 6);
					days.each do |day|
						found = false;
						# p "1111111111"
						result.each do |row|
							# p day
							# p row["da"]
							# p "     22222222222"
							if day == row["da"] then
								serverjs[:data].push(row["amount"]);
								found = true;
							end
						end
						if !found then
							serverjs[:data].push(0);
						end
					end
				end
			else
				# week
				if parView == "week" then
					startDay = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).strftime("%u").to_i - 12*7 + 1).strftime("%Y-%m-%d %H:%M:%S");
					endDay = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 23:59:59') - (Time.new).strftime("%u").to_i).strftime("%Y-%m-%d %H:%M:%S");

					sqlScript2 = 
					%Q[
						select min(d) d, sum(amount) amount, week
						from
						(
							select mid, min(da) d, sum(amount) amount, week
							from
							(
								select a."RollupDate" da, count(*) amount, trunc(extract( day from (a."RollupDate" -  '#{startDay} ')) /7) as week, a."MID" mid
								from long_running_jobs a
								inner join rollupstatuses b
								on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
								where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
								group by a."MID", a."RollupDate"
								order by a."RollupDate"
							) t
							group by mid, week
							order by week
						) t
						group by week
						order by week
					];

					serverjs[:data] = [];
					serverjs[:drilldown] = [];

					weeks = getCompleteIntervalWeek(DateTime.parse(startDay), 11, "%h.%d");

					result2 = Oncallissuetracker.find_by_sql(sqlScript2);
					if result2.length < 1 then
						weeks.each do |week|
							serverjs[:data].push({:name => week, :y => 0, :drilldown => week});
							serverjs[:drilldown].push({:id => week, :data => []});
						end
						serverjs[:ERROR] = "No #{parEnv} Long Runtime Job by Week";
					else
						weeks.each do |week|
							found = false;
							result2.each do |row|
								weekMonday = DateTime.parse(row["d"].strftime("%Y-%m-%d")+ ' 00:00:00') - row["d"].strftime("%u").to_i + 1;
								weekSunday = weekMonday + 6;
								xDate = "#{weekMonday.strftime("%h.%d")} ~ #{weekSunday.strftime("%h.%d")}";
								if week == xDate then
									serverjs[:data].push({:name => week, :y => row["amount"].round, :drilldown => week});

									sqlScript = 
									%Q[
										select mid, min(da) d, sum(amount) amount, min(week) min_week, max(week) max_week
										from
										(
											select a."RollupDate" da, count(*) amount, trunc(extract( day from (a."RollupDate" -  '#{startDay} ')) /7) as week, a."MID" mid
											from long_running_jobs a
											inner join rollupstatuses b
											on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
											where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
											group by a."MID", a."RollupDate"
											order by a."RollupDate"
										) t
										where week = #{row["week"]}
										group by mid
										order by amount desc
										limit 10
									];
									result = Oncallissuetracker.find_by_sql(sqlScript);

									if result.length < 1 then
										serverjs[:drilldown].push({:id => week, :data => []});
									else
										serverjs[:drilldown].push({:id => week, :data => []});
										result.each do |subRow|
											serverjs[:drilldown][serverjs[:drilldown].length - 1][:data].push([subRow["mid"], subRow["amount"].round]);
										end
									end
									found = true;
								end
							end
							if !found then
								serverjs[:data].push({:name => week, :y => 0, :drilldown => week});
								serverjs[:drilldown].push({:id => week, :data => []});
							end
						end
					end
				# month
				elsif parView == "month" then
					startDay = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 00:00:00') << 3).strftime("%Y-%m-%d %H:%M:%S");
					endDay = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 23:59:59') - 1).strftime("%Y-%m-%d %H:%M:%S");

					sqlScript2 = 
					%Q[
						select min(d) d, sum(amount) amount, month
						from
						(
							select mid, min(da) d, sum(amount) amount, month
							from
							(
								select a."RollupDate" da, count(*) amount, EXTRACT(YEAR FROM a."RollupDate") * 100 + EXTRACT(MONTH FROM a."RollupDate") as month, a."MID" mid
								from long_running_jobs a
								inner join rollupstatuses b
								on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
								where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
								group by a."MID", a."RollupDate"
								order by a."RollupDate"
							) t
							group by mid, month
							order by month
						) t
						group by month
						order by month
					];

					serverjs[:data] = [];
					serverjs[:drilldown] = [];

					months = getCompleteIntervalMonth(DateTime.parse(startDay), 2, "%h, %Y");

					result2 = Oncallissuetracker.find_by_sql(sqlScript2);
					if result2.length < 1 then
						months.each do |month|
							serverjs[:data].push({:name => month, :y => 0, :drilldown => month});
							serverjs[:drilldown].push({:id => month, :data => []});
						end
						serverjs[:ERROR] = "No #{parEnv} Long Runtime Job by Month";
					else
						months.each do |month|
							found = false;
							result2.each do |row|
								xDate = row["d"].strftime("%h, %Y");
								if month == xDate then
									serverjs[:data].push({:name => month, :y => row["amount"].round, :drilldown => month});

									sqlScript = 
									%Q[
										select mid, min(da) d, sum(amount) amount, min(month) min_month, max(month) max_month
										from
										(
											select a."RollupDate" da, count(*) amount, EXTRACT(YEAR FROM a."RollupDate") * 100 + EXTRACT(MONTH FROM a."RollupDate") as month, a."MID" mid
											from long_running_jobs a
											inner join rollupstatuses b
											on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
											where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
											group by a."MID", a."RollupDate"
											order by a."RollupDate"
										) t
										where month = #{row["month"]}
										group by mid
										order by amount desc
										limit 10
									];
									result = Oncallissuetracker.find_by_sql(sqlScript);

									if result.length < 1 then
										serverjs[:drilldown].push({:id => month, :data => []});
									else
										serverjs[:drilldown].push({:id => month, :data => []});
										result.each do |subRow|
											serverjs[:drilldown][serverjs[:drilldown].length - 1][:data].push([subRow["mid"], subRow["amount"].round]);
										end
									end
									found = true;
								end
							end
							if !found then
								serverjs[:data].push({:name => month, :y => 0, :drilldown => month});
								serverjs[:drilldown].push({:id => month, :data => []});
							end
						end
					end
				elsif parView == "mecmonth" then				
					mecinfo = MecCalendar.find_by_sql("select * from (
                       select \"Month\",\"Year\", max(\"MECEndDate_l\") as \"maxenddate\" from mec_calendars group  by  \"Month\"  ,\"Year\" order by \"Year\" desc,\"Month\" desc ) aaa
                       where now()>aaa.\"maxenddate\" limit 4")
					serverjs[:data] = [];
					serverjs[:drilldown] = [];
					
                    i=mecinfo.length-1
				    while i>0
					serverjs[:data].push({:name => mecinfo[i]["maxenddate"].strftime("%h, %Y"), :y => 0, :drilldown => mecinfo[i]["maxenddate"].strftime("%h, %Y")});
                    serverjs[:drilldown].push({:id => mecinfo[i]["maxenddate"].strftime("%h, %Y"), :data => []});					
					i-=1
					end
					
					i=mecinfo.length-1
					tt=0
					while i>0 do 
					  if(parEnv!="ALL")
					   errorinfo=Rolluperrorinformation.find_by_sql("select \"mid\", sum(\"amount\") \"amount\"  from
                      (
                      select a.\"RollupDate\" as \"da\", count(*) as \"amount\", a.\"MID\" as \"mid\"
                      from long_running_jobs a
                      inner join rollupstatuses b
                      on a.\"Batch_ID\" = b.\"BATCH_ID\" and b.\"DURATION\" > a.\"Threshold\" and b.\"DURATION\" > (a.\"Thirty_Days_Average\" + 15 )
                      where a.\"Environment\" = \'#{parEnv}\' and   a.\"RollupDate\">\'#{mecinfo[i]["maxenddate"]}\'   and  a.\"RollupDate\"<\'#{mecinfo[i-1]["maxenddate"]}\'
                      group by a.\"MID\", a.\"RollupDate\"
                      order by a.\"RollupDate\"
                      ) t
                      group by \"mid\"
                      order by \"amount\" desc")
                     else
					   errorinfo=Rolluperrorinformation.find_by_sql("select \"mid\", sum(\"amount\") \"amount\"  from
                      (
                      select a.\"RollupDate\" as \"da\", count(*) as \"amount\", a.\"MID\" as \"mid\"
                      from long_running_jobs a
                      inner join rollupstatuses b
                      on a.\"Batch_ID\" = b.\"BATCH_ID\" and b.\"DURATION\" > a.\"Threshold\" and b.\"DURATION\" > (a.\"Thirty_Days_Average\" + 15 )
                      where a.\"Environment\" !='BER' and   a.\"RollupDate\">\'#{mecinfo[i]["maxenddate"]}\'   and  a.\"RollupDate\"<\'#{mecinfo[i-1]["maxenddate"]}\'
                      group by a.\"MID\", a.\"RollupDate\"
                      order by a.\"RollupDate\"
                      ) t
                      group by \"mid\"
                      order by \"amount\" desc")
                     end					 
		              aa=0
					  while  aa<errorinfo.length do
					       if(aa<=9)
                              serverjs[:drilldown][tt][:data].push(errorinfo[aa]["mid"],errorinfo[aa]["amount"].to_i)
						   end	
                           serverjs[:data][tt][:y]+=errorinfo[aa]["amount"].to_i				   
					       aa+=1
					  end
				    i-=1
					tt+=1
                    end				
				# year
				elsif parView == "year" then
					startDay = "1980-1-1";
					endDay = "2050-12-31";

					sqlScript2 = 
					%Q[
						select min(d) d, sum(amount) amount, year
						from
						(
							select mid, min(da) d, sum(amount) amount, year
							from
							(
								select a."RollupDate" da, count(*) amount, EXTRACT(YEAR FROM a."RollupDate") as year, a."MID" mid
								from long_running_jobs a
								inner join rollupstatuses b
								on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
								where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
								group by a."MID", a."RollupDate"
								order by a."RollupDate"
							) t
							group by mid, year
							order by year
						) t
						group by year
						order by year
					];

					serverjs[:data] = [];
					serverjs[:drilldown] = [];

					result2 = Oncallissuetracker.find_by_sql(sqlScript2);

					if result2.length < 1 then
						serverjs[:data].push({:name => "2015", :y => 0, :drilldown => "2015"});
						serverjs[:drilldown].push({:id => "2015", :data => []});
						serverjs[:ERROR] = "No #{parEnv} Long Runtime Job by Year";
					else
						years = getCompleteIntervalYear(result2[0]["year"].round);
						# p years
						years.each do |year|
							found = false;
							result2.each do |row|
								xDate = row["year"].round;
								if year == xDate then
									serverjs[:data].push({:name => year, :y => row["amount"].round, :drilldown => year});

									sqlScript = 
									%Q[
										select mid, min(da) d, sum(amount) amount, min(year) min_year, max(year) max_year
										from
										(
											select a."RollupDate" da, count(*) amount, EXTRACT(YEAR FROM a."RollupDate") as year, a."MID" mid
											from long_running_jobs a
											inner join rollupstatuses b
											on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
											where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
											group by a."MID", a."RollupDate"
											order by a."RollupDate"
										) t
										where year = #{row["year"]}
										group by mid
										order by amount desc
										limit 10
									];
									result = Oncallissuetracker.find_by_sql(sqlScript);

									if result.length < 1 then
										serverjs[:drilldown].push({:id => year, :data => []});
									else
										serverjs[:drilldown].push({:id => year, :data => []});
										result.each do |subRow|
											serverjs[:drilldown][serverjs[:drilldown].length - 1][:data].push([subRow["mid"], subRow["amount"].round]);
										end
									end
									found = true;
								end
							end
							if !found then
								serverjs[:data].push({:name => year, :y => 0, :drilldown => year});
								serverjs[:drilldown].push({:id => year, :data => []});
							end
						end
					end
				end
			end
		# 6666666666666666666666666666666666666666666666666666666666666
		elsif parChart == "6" then
			sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs = {:ERROR => "There is no data in table dailyrolluptimes"};
				render json: serverjs.to_json;
				return;
			end

			# day
			if parView == "day" then
				currentDay = result[0]["r"];

				startDay = (currentDay - 2 * 24 * 3600).strftime("%Y-%m-%d %H:%M:%S");
				endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");
				days = getCompleteIntervalDay(currentDay - 2 * 24 * 3600, 2);
				sqlScript = 
				%Q[
					select a."RollupDate" da, count(*) amount, a."MID" mid
					from long_running_jobs a
					inner join rollupstatuses b
					on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
					inner join criticalpathstatuses c on a."Batch_ID" = c."BatchID"
					where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
					group by a."RollupDate", a."MID"
					order by a."RollupDate", a."MID"
				];

				sqlScript2 = 
				%Q[
					select count(*) amount, a."MID" mid
					from long_running_jobs a
					inner join rollupstatuses b
					on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
					inner join criticalpathstatuses c on a."Batch_ID" = c."BatchID"
					where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
					group by a."MID"
					order by a."MID"
				];

				serverjs[:x] = [];
				serverjs[:mids] = [];
				serverjs[:maximumLength] = 0;
				serverjs[:data] = [];

				days.length.times do
					serverjs[:data].push({:data => []});
				end

				result2 = Oncallissuetracker.find_by_sql(sqlScript2);
				if result2.length > 0 then
					result2.each do |row|
						serverjs[:mids].push(row["mid"]);
					end
				end

				result = Oncallissuetracker.find_by_sql(sqlScript);
				# p "SSSSSSSSSSSSSSSSSSSSSSSSSSS"
				# p result.length
				if result.length < 1 then
					days.each do |day|
						serverjs[:x].push(day.strftime("%h.%d"));
					end
					serverjs[:ERROR] = "No #{parEnv} Long Runtime Job on Critical Path by Day";
				else
					days.each do |day|
						found = false;
						# p "1111111111"
						result.each do |row|
							# p day
							# p row["da"]
							# p "     22222222222"
							if day == row["da"] then
								serverjs[:data][days.index(day)][:data].push({:name => serverjs[:mids].index(row["mid"]), :value => row["amount"]});
								found = true;
							end
						end
						# if !found then
						# 	serverjs[:data].push(0);
						# end
						serverjs[:x].push(day.strftime("%h.%d"));
					end
				end

				dataLengths = [];
				serverjs[:data].each do |pair|
					dataLengths.push(pair[:data].length);
				end

				serverjs[:maximumLength] = dataLengths.max;
			else
				# week
				if parView == "week" then
					startDay = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).strftime("%u").to_i - 12*7 + 1).strftime("%Y-%m-%d %H:%M:%S");
					endDay = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 23:59:59') - (Time.new).strftime("%u").to_i).strftime("%Y-%m-%d %H:%M:%S");

					sqlScript2 = 
					%Q[
						select min(d) d, sum(amount) amount, week
						from
						(
							select mid, min(da) d, sum(amount) amount, week
							from
							(
								select a."RollupDate" da, count(*) amount, trunc(extract( day from (a."RollupDate" -  '#{startDay} ')) /7) as week, a."MID" mid
								from long_running_jobs a
								inner join rollupstatuses b
								on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
								inner join criticalpathstatuses c on a."Batch_ID" = c."BatchID"
								where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
								group by a."MID", a."RollupDate"
								order by a."RollupDate"
							) t
							group by mid, week
							order by week
						) t
						group by week
						order by week
					];

					serverjs[:data] = [];
					serverjs[:drilldown] = [];

					weeks = getCompleteIntervalWeek(DateTime.parse(startDay), 11, "%h.%d");

					result2 = Oncallissuetracker.find_by_sql(sqlScript2);
					if result2.length < 1 then
						weeks.each do |week|
							serverjs[:data].push({:name => week, :y => 0, :drilldown => week});
							serverjs[:drilldown].push({:id => week, :data => []});
						end
						serverjs[:ERROR] = "No #{parEnv} Long Runtime Job on Critical Path by Week";
					else
						weeks.each do |week|
							found = false;
							result2.each do |row|
								weekMonday = DateTime.parse(row["d"].strftime("%Y-%m-%d")+ ' 00:00:00') - row["d"].strftime("%u").to_i + 1;
								weekSunday = weekMonday + 6;
								xDate = "#{weekMonday.strftime("%h.%d")} ~ #{weekSunday.strftime("%h.%d")}";
								if week == xDate then
									serverjs[:data].push({:name => week, :y => row["amount"].round, :drilldown => week});

									sqlScript = 
									%Q[
										select mid, min(da) d, sum(amount) amount, min(week) min_week, max(week) max_week
										from
										(
											select a."RollupDate" da, count(*) amount, trunc(extract( day from (a."RollupDate" -  '#{startDay} ')) /7) as week, a."MID" mid
											from long_running_jobs a
											inner join rollupstatuses b
											on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
											inner join criticalpathstatuses c on a."Batch_ID" = c."BatchID"
											where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
											group by a."MID", a."RollupDate"
											order by a."RollupDate"
										) t
										where week = #{row["week"]}
										group by mid
										order by amount desc
										limit 10
									];
									result = Oncallissuetracker.find_by_sql(sqlScript);

									if result.length < 1 then
										serverjs[:drilldown].push({:id => week, :data => []});
									else
										serverjs[:drilldown].push({:id => week, :data => []});
										result.each do |subRow|
											serverjs[:drilldown][serverjs[:drilldown].length - 1][:data].push([subRow["mid"], subRow["amount"].round]);
										end
									end
									found = true;
								end
							end
							if !found then
								serverjs[:data].push({:name => week, :y => 0, :drilldown => week});
								serverjs[:drilldown].push({:id => week, :data => []});
							end
						end
					end
				# month
				elsif parView == "month" then
					startDay = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 00:00:00') << 3).strftime("%Y-%m-%d %H:%M:%S");
					endDay = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 23:59:59') - 1).strftime("%Y-%m-%d %H:%M:%S");

					sqlScript2 = 
					%Q[
						select min(d) d, sum(amount) amount, month
						from
						(
							select mid, min(da) d, sum(amount) amount, month
							from
							(
								select a."RollupDate" da, count(*) amount, EXTRACT(YEAR FROM a."RollupDate") * 100 + EXTRACT(MONTH FROM a."RollupDate") as month, a."MID" mid
								from long_running_jobs a
								inner join rollupstatuses b
								on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
								inner join criticalpathstatuses c on a."Batch_ID" = c."BatchID"
								where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
								group by a."MID", a."RollupDate"
								order by a."RollupDate"
							) t
							group by mid, month
							order by month
						) t
						group by month
						order by month
					];

					serverjs[:data] = [];
					serverjs[:drilldown] = [];

					months = getCompleteIntervalMonth(DateTime.parse(startDay), 2, "%h, %Y");

					result2 = Oncallissuetracker.find_by_sql(sqlScript2);
					if result2.length < 1 then
						months.each do |month|
							serverjs[:data].push({:name => month, :y => 0, :drilldown => month});
							serverjs[:drilldown].push({:id => month, :data => []});
						end
						serverjs[:ERROR] = "No #{parEnv} Long Runtime Job on Critical Path by Month";
					else
						months.each do |month|
							found = false;
							result2.each do |row|
								xDate = row["d"].strftime("%h, %Y");
								if month == xDate then
									serverjs[:data].push({:name => month, :y => row["amount"].round, :drilldown => month});

									sqlScript = 
									%Q[
										select mid, min(da) d, sum(amount) amount, min(month) min_month, max(month) max_month
										from
										(
											select a."RollupDate" da, count(*) amount, EXTRACT(YEAR FROM a."RollupDate") * 100 + EXTRACT(MONTH FROM a."RollupDate") as month, a."MID" mid
											from long_running_jobs a
											inner join rollupstatuses b
											on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
											inner join criticalpathstatuses c on a."Batch_ID" = c."BatchID"
											where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
											group by a."MID", a."RollupDate"
											order by a."RollupDate"
										) t
										where month = #{row["month"]}
										group by mid
										order by amount desc
										limit 10
									];
									result = Oncallissuetracker.find_by_sql(sqlScript);

									if result.length < 1 then
										serverjs[:drilldown].push({:id => month, :data => []});
									else
										serverjs[:drilldown].push({:id => month, :data => []});
										result.each do |subRow|
											serverjs[:drilldown][serverjs[:drilldown].length - 1][:data].push([subRow["mid"], subRow["amount"].round]);
										end
									end
									found = true;
								end
							end
							if !found then
								serverjs[:data].push({:name => month, :y => 0, :drilldown => month});
								serverjs[:drilldown].push({:id => month, :data => []});
							end
						end
					end
				elsif parView == "mecmonth" then	
				 mecinfo = MecCalendar.find_by_sql("select * from (
                       select \"Month\",\"Year\", max(\"MECEndDate_l\") as \"maxenddate\" from mec_calendars group  by  \"Month\"  ,\"Year\" order by \"Year\" desc,\"Month\" desc ) aaa
                       where now()>aaa.\"maxenddate\" limit 4")
					serverjs[:data] = [];
					serverjs[:drilldown] = [];
					
                    i=mecinfo.length-1
				    while i>0
					serverjs[:data].push({:name => mecinfo[i]["maxenddate"].strftime("%h, %Y"), :y => 0, :drilldown => mecinfo[i]["maxenddate"].strftime("%h, %Y")});
                    serverjs[:drilldown].push({:id => mecinfo[i]["maxenddate"].strftime("%h, %Y"), :data => []});					
					i-=1
					end
					
					i=mecinfo.length-1
					tt=0
					firstpie=0
					secondpie=0
					while i>0 do 
					 if(parEnv!="ALL")
					   errorinfo=Rolluperrorinformation.find_by_sql("select \"mid\", sum(\"amount\") as \"amount\"
                      from(
                      select a.\"RollupDate\" as \"da\", count(*) \"amount\", a.\"MID\" as \"mid\"
                      from long_running_jobs a
                      inner join rollupstatuses b
                      on a.\"Batch_ID\" = b.\"BATCH_ID\" and b.\"DURATION\" > a.\"Threshold\" and b.\"DURATION\" > (a.\"Thirty_Days_Average\" + 15 )
                      inner join criticalpathstatuses c on a.\"Batch_ID\" = c.\"BatchID\"
                      where a.\"Environment\" = \'#{parEnv}\' and   a.\"RollupDate\">\'#{mecinfo[i]["maxenddate"]}\'   and  a.\"RollupDate\"<\'#{mecinfo[i-1]["maxenddate"]}\'
                      group by a.\"MID\", a.\"RollupDate\"
                      order by a.\"RollupDate\") t
                      group by \"mid\"
                      order by \"amount\" desc")
                     else
					  errorinfo=Rolluperrorinformation.find_by_sql("select \"mid\", sum(\"amount\") as \"amount\"
                      from(
                      select a.\"RollupDate\" as \"da\", count(*) \"amount\", a.\"MID\" as \"mid\"
                      from long_running_jobs a
                      inner join rollupstatuses b
                      on a.\"Batch_ID\" = b.\"BATCH_ID\" and b.\"DURATION\" > a.\"Threshold\" and b.\"DURATION\" > (a.\"Thirty_Days_Average\" + 15 )
                      inner join criticalpathstatuses c on a.\"Batch_ID\" = c.\"BatchID\"
                      where a.\"Environment\" !='BER' and   a.\"RollupDate\">\'#{mecinfo[i]["maxenddate"]}\'   and  a.\"RollupDate\"<\'#{mecinfo[i-1]["maxenddate"]}\'
                      group by a.\"MID\", a.\"RollupDate\"
                      order by a.\"RollupDate\") t
                      group by \"mid\"
                      order by \"amount\" desc")
                     end					 
		              aa=0
					  while  aa<errorinfo.length do
					       if(aa<=9)
                              serverjs[:drilldown][tt][:data].push(errorinfo[aa]["mid"],errorinfo[aa]["amount"].to_i)
						   end	
                           serverjs[:data][tt][:y]+=errorinfo[aa]["amount"].to_i				   
					       aa+=1
					  end
				    i-=1
					tt+=1
                    end				
				# year
				elsif parView == "year" then
					startDay = "1980-1-1";
					endDay = "2050-12-31";

					sqlScript2 = 
					%Q[
						select min(d) d, sum(amount) amount, year
						from
						(
							select mid, min(da) d, sum(amount) amount, year
							from
							(
								select a."RollupDate" da, count(*) amount, EXTRACT(YEAR FROM a."RollupDate") as year, a."MID" mid
								from long_running_jobs a
								inner join rollupstatuses b
								on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
								inner join criticalpathstatuses c on a."Batch_ID" = c."BatchID"
								where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
								group by a."MID", a."RollupDate"
								order by a."RollupDate"
							) t
							group by mid, year
							order by year
						) t
						group by year
						order by year
					];

					serverjs[:data] = [];
					serverjs[:drilldown] = [];

					result2 = Oncallissuetracker.find_by_sql(sqlScript2);

					if result2.length < 1 then
						serverjs[:data].push({:name => "2015", :y => 0, :drilldown => "2015"});
						serverjs[:drilldown].push({:id => "2015", :data => []});
						serverjs[:ERROR] = "No #{parEnv} Long Runtime Job on Critical Path by Year";
					else
						years = getCompleteIntervalYear(result2[0]["year"].round);
						# p years
						years.each do |year|
							found = false;
							result2.each do |row|
								xDate = row["year"].round;
								if year == xDate then
									serverjs[:data].push({:name => year, :y => row["amount"].round, :drilldown => year});

									sqlScript = 
									%Q[
										select mid, min(da) d, sum(amount) amount, min(year) min_year, max(year) max_year
										from
										(
											select a."RollupDate" da, count(*) amount, EXTRACT(YEAR FROM a."RollupDate") as year, a."MID" mid
											from long_running_jobs a
											inner join rollupstatuses b
											on a."Batch_ID" = b."BATCH_ID" and b."DURATION" > a."Threshold" and b."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
											inner join criticalpathstatuses c on a."Batch_ID" = c."BatchID"
											where a."Environment" = '#{parEnv}' and a."RollupDate" between '#{startDay}' and '#{endDay}'
											group by a."MID", a."RollupDate"
											order by a."RollupDate"
										) t
										where year = #{row["year"]}
										group by mid
										order by amount desc
										limit 10
									];
									result = Oncallissuetracker.find_by_sql(sqlScript);

									if result.length < 1 then
										serverjs[:drilldown].push({:id => year, :data => []});
									else
										serverjs[:drilldown].push({:id => year, :data => []});
										result.each do |subRow|
											serverjs[:drilldown][serverjs[:drilldown].length - 1][:data].push([subRow["mid"], subRow["amount"].round]);
										end
									end
									found = true;
								end
							end
							if !found then
								serverjs[:data].push({:name => year, :y => 0, :drilldown => year});
								serverjs[:drilldown].push({:id => year, :data => []});
							end
						end
					end
				end
			end
		# 7777777777777777777777777777777777777777777777777777777777777
		elsif parChart == "7" then
			sqlScript = 
			%Q[
				select a."Start_TS" s, a."End_TS" e, a."RollupDate" r
				from dailyrolluptimes a
				where a."End_TS" is not null and a."ElapseTime" > 0
				order by a."RollupDate" desc
				limit 1;
			];
			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs = {:ERROR => "There is no data in table dailyrolluptimes"};
				render json: serverjs.to_json;
				return;
			end

			currentDay = result[0]["r"];
			startDay = (currentDay - 59 * 24 * 3600).strftime("%Y-%m-%d %H:%M:%S");
			endDay = currentDay.strftime("%Y-%m-%d %H:%M:%S");

			sqlScript = 
			%Q[
				select to_char(a."RollupDate", 'yyyy-MM-dd') da, a."Batch_ID" bid, a."MID" mid, 
					case when b."BatchID" is null then 'No' else 'Yes' end cp, c."DURATION" du, 
					a."Thirty_Days_Average" du30, t.ra, t.ra7d, c."DURATION" * 100 / 60.0 / d."ElapseTime" prt
				from public.long_running_jobs a
				inner join
				(
					select a."MID" mid, a."RollupDate" rd, avg(c."Row_Affected") ra7d, 
						sum(case when a."RollupDate" = b."RollupDate" then c."Row_Affected" else null end) ra,
						min(case when a."RollupDate" = b."RollupDate" then a."Batch_ID" else null end) bid
					from public.long_running_jobs a
					inner join rollupstatuses r
on 					a."Batch_ID" = r."BATCH_ID" and r."DURATION" > a."Threshold" and r."DURATION" > (a."Thirty_Days_Average" + #{standardTime} )
					left outer join public.long_running_jobs b
					on a."MID" = b."MID"
					left outer join public.rolluprowaffecteds c
					on b."Batch_ID" = cast(c."BatchID" as text)
					where a."Environment" = '#{parEnv}' and b."Environment" = '#{parEnv}' 
						and a."RollupDate" between '#{startDay}' and '#{endDay}'
						and a."RollupDate" - b."RollupDate" between interval '0' day and interval '7' day
					group by a."MID", a."RollupDate"
					order by a."MID", a."RollupDate"
				) t
				on a."Batch_ID" = t.bid
				left outer join public.criticalpathstatuses b
				on a."Batch_ID" = b."BatchID"
				left outer join public.rollupstatuses c
				on a."Batch_ID" = c."BATCH_ID"
				left outer join public.dailyrolluptimes d
				on a."RollupDate" = d."RollupDate" and a."Environment" = d."Server"
				where a."Environment" = '#{parEnv}'
        			and a."RollupDate" between '#{startDay}' and '#{endDay}'
				order by da desc
			];

			serverjs[:data] = [];

			result = Oncallissuetracker.find_by_sql(sqlScript);
			if result.length < 1 then
				serverjs[:ERROR] = "No #{parEnv} Data";
			else
				result.each do |row|
					serverjs[:data].push(
					{
						:RollupDate => row["da"],
						:BatchID => row["bid"],
						:MID => row["mid"],
						:CPFlag => row["cp"],
						:Duration => row["du"],
						:Duration30DaysAverage => row["du30"],
						:RowsAffected => row["ra"],
						:RowsAffected7DaysAverage => row["ra7d"],
						:PercentageRollupTime => row["prt"]
					});
				end
			end
		end
				

		# p 'zzzzzzzzzzzzzzzzzz'
		# p parView
		# p parEnv
		# p parChart
		
		render json: serverjs.to_json;
	end

	def getCompleteIntervalDay(startDay, extraLength)
		# p startDay;
		result = [startDay];
		extraLength.times do
			startDay += 3600 * 24;
			result.push(startDay);
		end
		# p result
		return result;
	end

	def getCompleteIntervalDay2(startDay, extraLength)
		# p startDay;
		result = [startDay.strftime("%h.%d")];
		extraLength.times do
			startDay += 3600 * 24;
			result.push(startDay.strftime("%h.%d"));
		end
		# p result
		return result;
	end

	def getCompleteIntervalWeek(startDay, extraLength, weekFormat)
		result = ["#{startDay.strftime(weekFormat)} ~ #{(startDay + 6).strftime(weekFormat)}"];
		extraLength.times do
			startDay += 7;
			result.push("#{startDay.strftime(weekFormat)} ~ #{(startDay + 6).strftime(weekFormat)}");
		end
		# p result
		return result;
	end

	def getCompleteIntervalMonth(startDay, extraLength, monthFormat)
		result = ["#{startDay.strftime(monthFormat)}"];
		extraLength.times do
			startDay = startDay >> 1;
			result.push("#{startDay.strftime(monthFormat)}");
		end
		# p result
		return result;
	end

	def getCompleteIntervalYear(startYear)
		result = [startYear];
		currentYear = (Time.new).strftime("%Y").to_i;
		(currentYear - startYear).times do
			startYear += 1;
			result.push(startYear);
		end
		return result;
	end

	def getCompleteIntervalYear2(startYear)
		result = [startYear.to_s];
		currentYear = (Time.new).strftime("%Y").to_i;
		(currentYear - startYear).times do
			startYear += 1;
			result.push(startYear.to_s);
		end
		return result;
	end
end
# http://16.152.122.101:8000/