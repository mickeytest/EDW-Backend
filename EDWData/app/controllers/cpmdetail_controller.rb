class CpmdetailController < ApplicationController
def index

cpmdetail={}
cpmdetail[:series]={}

if(params[:from]==nil)
pf=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 30).strftime("%Y-%m-%d")
pf1=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') +1).strftime("%Y-%m-%d")
cpmdetail[:from]= DateTime.parse(pf).strftime("%Y/%m/%d")
cpmdetail[:to]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')+0).strftime("%Y/%m/%d")
test=DateTime.parse(cpmdetail[:to]).strftime("%Y/%m/%d")
end

if(params[:from]!=nil)
pf=params[:from]
pf1=(DateTime.parse(params[:to]+ ' 00:00:00') +1).strftime("%Y-%m-%d")
test=DateTime.parse(params[:to]).strftime("%Y/%m/%d")
end


cpmdetailinfo=Rolluprowaffected.find_by_sql("
select * from (
select * from (
select * from (
(select * from rolluprowaffecteds where \"MID\"=\'#{(params[:MID])[0,5]}\' and \"Environment\"=\'#{params[:Server]}\'  and \"RollupDate\">=\'#{pf}\' and \"RollupDate\"<\'#{pf1}\') aaa  full join 
(select \"MID\",\"Duration\",\"BatchID\" as \"ttt\",\"RollupDate\" as \"arollupdate\" from criticalpathstatuses where \"RollupDate\">='#{pf}\' and \"RollupDate\"<\'#{pf1}\' and  \"Server\"=\'#{params[:Server]}\'  and substring(\"MID\",0,6)=\'#{(params[:MID])[0,5]}\')  bbb  on   bbb.\"ttt\"  = cast(aaa.\"BatchID\" as  char(20)) 
) ddd left join 
(select \"MID\",\"DURATION\" ,\"BATCH_ID\" from Rollupstatuses where  \"SERVER\"=\'#{params[:Server]}\' and \"Start_TS\">'#{pf}\' ) eee  on cast(ddd.\"BatchID\" as  char(20))=eee.\"BATCH_ID\"
) fff order by \"RollupDate\"
) hhh
left join (select \"Thirty_Days_Average\", 
       \"Batch_ID\" from long_running_jobs) iii  on hhh.\"BATCH_ID\"=iii.\"Batch_ID\"  order by \"RollupDate\" ,\"arollupdate\"
")

i=0

cpmdetail[:series][:data]=[]
min = nil
max = nil

while i<cpmdetailinfo.length do  
	 item = {:MIDs=>(params[:MID])[0,5],
	  :x=>((cpmdetailinfo[i]["RollupDate"])==nil ? (cpmdetailinfo[i]["arollupdate"]).strftime("%Y/%m/%d") : (cpmdetailinfo[i]["RollupDate"]).strftime("%Y/%m/%d")),
	  :RowAffected=>(cpmdetailinfo[i]["Row_Affected"]==nil  ? 0 : cpmdetailinfo[i]["Row_Affected"]),
	  :Durations=>(cpmdetailinfo[i]["DURATION"]==nil  ?  (cpmdetailinfo[i]["Duration"]==nil ? 0 : cpmdetailinfo[i]["Duration"].round(2) ): cpmdetailinfo[i]["DURATION"].round(2)),
	  :cpm=>(cpmdetailinfo[i]["ttt"]==nil ? "No":"Yes"),
	  :AVG=>(cpmdetailinfo[i]["Thirty_Days_Average"]==nil ? -1:cpmdetailinfo[i]["Thirty_Days_Average"])
	   }
      cpmdetail[:series][:data].push(item)
	
	  if max == nil || item[:RowAffected] > max then
	  	max = item[:RowAffected]
	  end
	  if min == nil || item[:RowAffected] < min then 
	  	min = item[:RowAffected]
	  end
	 
	  i+=1
end
mtpinfo=Midmtpinformation.find_by_sql("SELECT 
       \"DEPLOY_TS\"
  FROM midmtpinformations where \"MID\"=\'#{(params[:MID])[0,5]}\' and \"DEPLOY_SERVER\"=\'#{params[:Server]}\' ")

 cpmdetail[:min] = min
  cpmdetail[:max] = max

 cpmdetail[:MTPDate]=mtpinfo.length==0 ? nil: (mtpinfo[mtpinfo.length-1]["DEPLOY_TS"]).strftime("%Y/%m/%d")
  
portfolioinfo=Rolluprowaffected.find_by_sql("SELECT \"MasterID\", \"PORTFOLIO\"
  FROM portfolios where \"MasterID\"=\'#{(params[:MID])[0,5]}\'")

  if(portfolioinfo.length>=1)
    cpmdetail[:PORTFOLIO]=portfolioinfo[0]["PORTFOLIO"] 
  else
    cpmdetail[:PORTFOLIO]="Others"
  end
  
render json:cpmdetail.to_json
end
end
