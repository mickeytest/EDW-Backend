class ErrorController < ApplicationController
     def index
	 pf = params[:Environment]
	 rollupendtime=Dailyrolluptime.find_by_sql("select max(\"RollupDate\") as \"rollupendtime\" from dailyrolluptimes where \"Server\"=\'#{pf}\' and  \"End_TS\" is not null")
     privious90time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 90).strftime("%Y-%m-%d %H:%M:%S")
     oncallissueerror=Oncallissuetracker.find_by_sql("select a.\"Date\",count(*) as \"oncallissueerror\",sum(\"Duration\") as \"duration\" from oncallissuetrackers a left join rolluperrorinformations b  on  a.\"BatchID\"=b.\"BatchID\"  and a.\"Environment\"=b.\"Server\" and a.\"Date\"=b.\"RollupDate\" where \"Environment\"=\'#{pf}\' and \"Date\">=\'#{privious90time}\' and \"Date\"<=\'#{rollupendtime[0]["rollupendtime"]}\' group by a.\"Date\" order by a.\"Date\"")
	 oncallsystemerror=Oncallissuetracker.find_by_sql("select a.\"Date\",count(*) as \"oncallsyserror\",sum(\"Duration\") as \"duration\" from oncallissuetrackers a left join rolluperrorinformations b  on  a.\"BatchID\"=b.\"BatchID\"  and a.\"Environment\"=b.\"Server\" and a.\"Date\"=b.\"RollupDate\" where \"Environment\"=\'#{pf}\' and b.\"SystemIssueFlag\"='YES' and \"Date\">=\'#{privious90time}\' and \"Date\"<=\'#{rollupendtime[0]["rollupendtime"]}\'  group by a.\"Date\" order by a.\"Date\"")
	 rolluperror=Rolluperrorinformation.find_by_sql("select count(*) as \"rolluperror\",sum(\"Duration\") as \"duration\",\"RollupDate\" from rolluperrorinformations where \"Server\"=\'#{pf}\' and \"RollupDate\">=\'#{privious90time}\' and \"RollupDate\"<=\'#{rollupendtime[0]["rollupendtime"]}\'  group by \"RollupDate\" order by \"RollupDate\"")
	 rollupsystemerror=Rolluperrorinformation.find_by_sql("select count(*) as \"rollupsyserror\",sum(\"Duration\") as \"duration\",\"RollupDate\" from rolluperrorinformations where \"Server\"=\'#{pf}\' and \"RollupDate\">=\'#{privious90time}\' and \"RollupDate\"<=\'#{rollupendtime[0]["rollupendtime"]}\'  and \"SystemIssueFlag\"='YES' group by \"RollupDate\" order by \"RollupDate\"")
     rolluperrorcp=Rolluperrorinformation.find_by_sql("select count(*) as \"cperror\",a.\"RollupDate\" ,sum(\"Duration\") as \"duration\" from rolluperrorinformations a left join 
                                            criticalpathstatuses b  on  a.\"BatchID\"=cast(b.\"BatchID\" as int)  and a.\"Server\"=b.\"Server\" and a.\"RollupDate\"=b.\"RollupDate\"  where a.\"Server\"=\'#{pf}\' and a.\"RollupDate\">=\'#{privious90time}\' and a.\"RollupDate\"<=\'#{rollupendtime[0]["rollupendtime"]}\' and b.\"Server\" is not null group by a.\"RollupDate\" order by a.\"RollupDate\" ")	 
	 oncallissuecp=Oncallissuetracker.find_by_sql("select sum(\"Duration\") as \"duration\",count(*) as \"oncallcp\",\"RollupDate\" from 
                                                  (select a.\"BatchID\",a.\"Environment\", a.\"Date\" from oncallissuetrackers a left join criticalpathstatuses b  on  a.\"BatchID\"=cast(b.\"BatchID\" as int)  and a.\"Environment\"=b.\"Server\" and a.\"Date\"=b.\"RollupDate\"  where \"Date\">=\'#{privious90time}\' and \"Date\"<=\'#{rollupendtime[0]["rollupendtime"]}\'  and a.\"Environment\"=\'#{pf}\' and \"Server\" is not null) c
                                                  left join rolluperrorinformations d on c.\"BatchID\"=d.\"BatchID\"  and c.\"Environment\"=d.\"Server\" and c.\"Date\"=d.\"RollupDate\" where \"RollupDate\" is not null group by \"RollupDate\" order by  \"RollupDate\"
                                                  ")
	 elapsetimeinfo=Dailyrolluptime.find_by_sql("select sum(\"ElapseTime\") as \"elapsetime\",\"RollupDate\" from dailyrolluptimes where \"RollupDate\">=\'#{privious90time}\' and \"RollupDate\"<=\'#{rollupendtime[0]["rollupendtime"]}\' and \"Server\"=\'#{pf}\' group by \"RollupDate\" order by \"RollupDate\"")
	 
	 errorinfo=Hash.new
	 errorinfoarray=Array.new
     timeinfoarray=Array.new
	
	
    rolluperrordataset=Array.new
	rolluperrorsysdataset=Array.new
	rolluperrorcpdataset=Array.new
    rolluptimedataset=Array.new   
    rolluptimesysdataset=Array.new
	rolluptimecpdataset=Array.new
	elapsetimedataset=Array.new
	
    oncallissuedataset=Array.new   
	oncallissuesysdataset=Array.new
	oncallissuecpdataset=Array.new
	oncalltimedataset=Array.new
	oncalltimesysdataset=Array.new	
	oncalltimecpdataset=Array.new
	
	rolluperrorhash=Hash.new
	rolluperrorcphash=Hash.new
    rolluperrorsyshash=Hash.new 	 
	rolluptimehash=Hash.new	 
    rolluptimecphash=Hash.new		
	rolluptimesyshash=Hash.new
	elapsetimehash=Hash.new
	
	oncallissuehash=Hash.new
	oncallissuecphash=Hash.new
    oncallissuesyshash=Hash.new	 
	oncalltimehash=Hash.new	
    oncalltimecphash=Hash.new	 	
    oncalltimesyshash=Hash.new
	 
	 i=0
     while i < elapsetimeinfo.length do
	       totalduration=Hash.new
		   totalduration["x"]=(elapsetimeinfo[i]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(elapsetimeinfo[i]["elapsetime"]).to_i
		   elapsetimedataset[i]=totalduration		   
		   i+=1
	 end
	 
	 i=0
     while i < rolluperrorcp.length do
	       errorcount=Hash.new
		   errorcount["x"]=(rolluperrorcp[i]["RollupDate"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(rolluperrorcp[i]["cperror"]).to_i
		   rolluperrorcpdataset[i]=errorcount
		   totalduration=Hash.new
		   totalduration["x"]=(rolluperrorcp[i]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(rolluperrorcp[i]["duration"]).to_i
		   rolluptimecpdataset[i]=totalduration
		   i+=1
	 end
	 
	 i=0
     while i < oncallissuecp.length do
	       errorcount=Hash.new
		   errorcount["x"]=(oncallissuecp[i]["RollupDate"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(oncallissuecp[i]["oncallcp"]).to_i
		   oncallissuecpdataset[i]=errorcount
		   totalduration=Hash.new
		   totalduration["x"]=(oncallissuecp[i]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(oncallissuecp[i]["duration"]).to_i
		   oncalltimecpdataset[i]=totalduration
		   i+=1
	 end
	
     i=0
     while i < rolluperror.length do
	       errorcount=Hash.new
		   errorcount["x"]=(rolluperror[i]["RollupDate"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(rolluperror[i]["rolluperror"]).to_i
		   rolluperrordataset[i]=errorcount
		   totalduration=Hash.new
		   totalduration["x"]=(rolluperror[i]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(rolluperror[i]["duration"]).to_i
		   rolluptimedataset[i]=totalduration
		   i+=1
	 end
	 
	 i=0
	 while i < rollupsystemerror.length do
	       errorcount=Hash.new
		   errorcount["x"]=(rollupsystemerror[i]["RollupDate"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(rollupsystemerror[i]["rollupsyserror"]).to_i
		   rolluperrorsysdataset[i]=errorcount		   
		   totalduration=Hash.new
		   totalduration["x"]=(rollupsystemerror[i]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(rollupsystemerror[i]["duration"]).to_i
		   rolluptimesysdataset[i]=totalduration
		   i+=1
	 end
	 
	 i=0
	 while i < oncallissueerror.length do
	       errorcount=Hash.new
		   errorcount["x"]=(oncallissueerror[i]["Date"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(oncallissueerror[i]["oncallissueerror"]).to_i
		   oncallissuedataset[i]=errorcount		   
		   totalduration=Hash.new
		   totalduration["x"]=(oncallissueerror[i]["Date"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(oncallissueerror[i]["duration"]).to_i
		   oncalltimedataset[i]=totalduration
		   i+=1
	 end
	 
	 i=0
	 while i < oncallsystemerror.length do
	       errorcount=Hash.new
		   errorcount["x"]=(oncallsystemerror[i]["Date"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(oncallsystemerror[i]["oncallsyserror"]).to_i
		   oncallissuesysdataset[i]=errorcount		   
		   totalduration=Hash.new
		   totalduration["x"]=(oncallsystemerror[i]["Date"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(oncallsystemerror[i]["duration"]).to_i
		   oncalltimesysdataset[i]=totalduration
		   i+=1
	 end
	 
	 rolluperrorhash["name"]="Rollup error"
	 rolluperrorhash["dataset"]=rolluperrordataset
	 oncallissuehash["name"]="Oncall Issue"
	 oncallissuehash["dataset"]=oncallissuedataset	 
	 rolluperrorsyshash["name"]="Rollup system error"
	 rolluperrorsyshash["dataset"]=rolluperrorsysdataset	
	 oncallissuesyshash["name"]="Oncall system Issue"
	 oncallissuesyshash["dataset"]=oncallissuesysdataset	 
	 rolluperrorcphash["name"]="Error in CP"
	 rolluperrorcphash["dataset"]=rolluperrorcpdataset
	 oncallissuecphash["name"]="Oncall Issue in CP"
	 oncallissuecphash["dataset"]=oncallissuecpdataset
	 

	 rolluptimehash["name"]="Rollup error"
	 rolluptimehash["dataset"]=rolluptimedataset
	 oncalltimehash["name"]="Oncall Issue"
	 oncalltimehash["dataset"]=oncalltimedataset	
	 rolluptimesyshash["name"]="Rollup system error"
	 rolluptimesyshash["dataset"]=rolluptimesysdataset
	 oncalltimesyshash["name"]="Oncall system Issue"
	 oncalltimesyshash["dataset"]=oncalltimesysdataset	 
	 rolluptimecphash["name"]="Error in CP"
	 rolluptimecphash["dataset"]=rolluptimecpdataset
	 oncalltimecphash["name"]="Oncall Issue in CP"
	 oncalltimecphash["dataset"]=oncalltimecpdataset
	 
	 
	 elapsetimehash["name"]="Elapsed Time (Hours)"
	 elapsetimehash["dataset"]=elapsetimedataset
	 
	 errorinfoarray[0]=rolluperrorhash
	 errorinfoarray[1]=oncallissuehash
	 errorinfoarray[2]=rolluperrorsyshash
	 errorinfoarray[3]=oncallissuesyshash
	 errorinfoarray[4]=rolluperrorcphash
	 errorinfoarray[5]=oncallissuecphash
	 errorinfoarray[6]=elapsetimehash
	 
	 timeinfoarray[0]=rolluptimehash
	 timeinfoarray[1]=oncalltimehash
	 timeinfoarray[2]=rolluptimesyshash
	 timeinfoarray[3]=oncalltimesyshash
	 timeinfoarray[4]=rolluptimecphash
	 timeinfoarray[5]=oncalltimecphash
	 timeinfoarray[6]=elapsetimehash
	 errorinfo["Number"]=errorinfoarray	
     errorinfo["Time"]=timeinfoarray	 	 
	 render json: errorinfo.to_json
	 end
end
