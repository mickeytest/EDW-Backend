class RollupbyportfolioController < ApplicationController
  def index
     pf1 = params[:RollupDate]
	 pf2 = params[:Server]
	 pf3=DateTime.parse(pf1).strftime("%Y-%m-%d 00:00:00")

	 fetch_sql = 
				%Q[
					  with start_ts as (SELECT "Start_TS"
					             FROM rollupstatuses 
					             WHERE "SERVER" = '#{pf2}'
						     		and "EVENT_ID" = '11887.TB.999.1'
						      		and "Start_TS" >= '#{pf3}' 
						      		and "Start_TS" <= date('#{pf3}' ) + interval '1 day'
						      	 	order by "Start_TS" limit 1)
					,end_ts as (SELECT "End_TS"
					      		FROM rollupstatuses 
					      		WHERE "SERVER" = '#{pf2}'
					      			and "EVENT_ID" = '19851.DP.999.1'
					     			and "Start_TS" >= (SELECT "Start_TS" from start_ts)
					     			and "Start_TS" <= (SELECT "Start_TS" from start_ts) + interval '1 day'
					      		order by "Start_TS" limit 1)


					SELECT A.*,domain FROM (
						SELECT * FROM rollupstatuses
						WHERE "SERVER" = '#{pf2}'
						and "Start_TS" >= (SELECT "Start_TS" from start_ts)
						and "End_TS" <= (SELECT "End_TS" from end_ts)
					       ) A LEFT JOIN 
					       (  
					       SELECT   "EVENT_ID",  split_part("Rollup_Domain", '-', 1) AS DOMAIN
					  FROM mid_rollup_domains
					  where "Rollup_Domain" not like '%EXT%' and "Rollup_Domain" not like '%DBMAINT%' and "Rollup_Domain" not like '%OFF%' 
					  and split_part("Rollup_Domain", '-', 1) not in ('CRM','PSDC','DNB','SRLNR','LZDELETE','CBMEC')
					       ) B
					       on A."EVENT_ID" = B."EVENT_ID"
					       where domain is not null
					  order by "Start_TS"
				]

			 rollupinfo=Rollupstatus.find_by_sql(fetch_sql)

			 rollup_final_hash = {}

			 rollup_portfolio_data = {}

			 rollupinfo.each do |r|


			 	if rollup_portfolio_data[r["domain"]] == nil then
			 		rollup_portfolio_data[r["domain"]] = []
			 	end
			 	item = {
			 		"EVENTID" => r["EVENT_ID"],
			 		"START_TS" => r["Start_TS"].strftime("%Y/%m/%d %H:%M:%S"),
					"END_TS" => r["End_TS"].strftime("%Y/%m/%d %H:%M:%S"),
			 	}

			 	rollup_portfolio_data[r["domain"]] << item
			 end
			 rollup_final_hash = {
			 	"categories"=> rollup_portfolio_data.keys,
			 	"data"=>rollup_portfolio_data

			 }
			render json: rollup_final_hash.to_json 

  end
end