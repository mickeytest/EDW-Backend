class ErrorController < ApplicationController
     def index
	 pf = params[:Environment]
	 rollupendtime=Dailyrolluptime.find_by_sql("select max(\"RollupDate\") as \"rollupendtime\" from dailyrolluptimes where \"Server\"=\'#{pf}\' and  \"End_TS\" is not null")
     privious30time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 30).strftime("%Y-%m-%d %H:%M:%S")
     oncallissueerror=Oncallissuetracker.find_by_sql("select a.\"Date\",count(*) as \"oncallissueerror\",sum(\"Duration\") as \"duration\" from oncallissuetrackers a left join rolluperrorinformations b  on  a.\"BatchID\"=b.\"BatchID\"  and a.\"Environment\"=b.\"Server\" and a.\"Date\"=b.\"RollupDate\" where \"Environment\"=\'#{pf}\' and \"Date\">=\'#{privious30time}\' and b.\"BatchID\"  is not null   and \"Date\"<=\'#{rollupendtime[0]["rollupendtime"]}\' group by a.\"Date\" order by a.\"Date\"")
	 oncallsystemerror=Oncallissuetracker.find_by_sql("select a.\"Date\",count(*) as \"oncallsyserror\",sum(\"Duration\") as \"duration\" from oncallissuetrackers a left join rolluperrorinformations b  on  a.\"BatchID\"=b.\"BatchID\"  and a.\"Environment\"=b.\"Server\" and a.\"Date\"=b.\"RollupDate\" where \"Environment\"=\'#{pf}\' and b.\"SystemIssueFlag\"='YES' and \"Date\">=\'#{privious30time}\' and b.\"BatchID\"  is not null and \"Date\"<=\'#{rollupendtime[0]["rollupendtime"]}\'  group by a.\"Date\" order by a.\"Date\"")
	 rolluperror=Rolluperrorinformation.find_by_sql("select count(*) as \"rolluperror\",sum(\"Duration\") as \"duration\",\"RollupDate\" from rolluperrorinformations where \"Server\"=\'#{pf}\' and \"RollupDate\">=\'#{privious30time}\' and \"RollupDate\"<=\'#{rollupendtime[0]["rollupendtime"]}\'  group by \"RollupDate\" order by \"RollupDate\"")
	 rollupsystemerror=Rolluperrorinformation.find_by_sql("select count(*) as \"rollupsyserror\",sum(\"Duration\") as \"duration\",\"RollupDate\" from rolluperrorinformations where \"Server\"=\'#{pf}\' and \"RollupDate\">=\'#{privious30time}\' and \"RollupDate\"<=\'#{rollupendtime[0]["rollupendtime"]}\'  and \"SystemIssueFlag\"='YES' group by \"RollupDate\" order by \"RollupDate\"")
     rolluperrorcp=Rolluperrorinformation.find_by_sql("select count(*) as \"cperror\",a.\"RollupDate\" ,sum(a.\"Duration\") as \"duration\" from rolluperrorinformations a left join 
                                            criticalpathstatuses b  on  a.\"BatchID\"=cast(b.\"BatchID\" as int)  and a.\"Server\"=b.\"Server\" and a.\"RollupDate\"=b.\"RollupDate\"  where a.\"Server\"=\'#{pf}\' and a.\"RollupDate\">=\'#{privious30time}\' and a.\"RollupDate\"<=\'#{rollupendtime[0]["rollupendtime"]}\' and b.\"Server\" is not null group by a.\"RollupDate\" order by a.\"RollupDate\" ")	 
	 oncallissuecp=Oncallissuetracker.find_by_sql("select sum(\"Duration\") as \"duration\",count(*) as \"oncallcp\",\"RollupDate\" from 
                                                  (select a.\"BatchID\",a.\"Environment\", a.\"Date\" from oncallissuetrackers a left join criticalpathstatuses b  on  a.\"BatchID\"=cast(b.\"BatchID\" as int)  and a.\"Environment\"=b.\"Server\" and a.\"Date\"=b.\"RollupDate\"  where \"Date\">=\'#{privious30time}\' and \"Date\"<=\'#{rollupendtime[0]["rollupendtime"]}\'  and a.\"Environment\"=\'#{pf}\' and \"Server\" is not null) c
                                                  left join rolluperrorinformations d on c.\"BatchID\"=d.\"BatchID\"  and c.\"Environment\"=d.\"Server\" and c.\"Date\"=d.\"RollupDate\" where \"RollupDate\" is not null  and d.\"BatchID\"  is not null  group by \"RollupDate\" order by  \"RollupDate\"
                                                  ")
	 elapsetimeinfo=Dailyrolluptime.find_by_sql("select sum(\"ElapseTime\") as \"elapsetime\",\"RollupDate\" from dailyrolluptimes where \"RollupDate\">=\'#{privious30time}\' and \"RollupDate\"<=\'#{rollupendtime[0]["rollupendtime"]}\' and \"Server\"=\'#{pf}\' group by \"RollupDate\" order by \"RollupDate\"")
	 	 
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
	 j=0
     while i < 30 do	      
	       if  (j<elapsetimeinfo.length) && (elapsetimeinfo[j]["RollupDate"]==(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).utc)		   
	       totalduration=Hash.new
		   totalduration["x"]=(elapsetimeinfo[j]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(elapsetimeinfo[j]["elapsetime"]).round(2)
		   j+=1
		   else
		   totalduration=Hash.new
		   totalduration["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")
		   totalduration["y"]=0
		   end
		   elapsetimedataset[i]=totalduration		   
		   i+=1
	 end
	 
	 i=0
	 j=0	
     while i < 30 do
	       errorcount=Hash.new
		   totalduration=Hash.new
	       if  (j<rolluperrorcp.length) && (rolluperrorcp[j]["RollupDate"]==(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).utc)	   
		   errorcount["x"]=(rolluperrorcp[j]["RollupDate"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(rolluperrorcp[j]["cperror"]).to_i		   		   
		   totalduration["x"]=(rolluperrorcp[j]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(rolluperrorcp[j]["duration"]).to_i	
           j+=1		   
		   else
		   errorcount["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")
		   errorcount["y"]=0
		   totalduration["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")
		   totalduration["y"]=0
		   end
		   rolluperrorcpdataset[i]=errorcount
		   rolluptimecpdataset[i]=totalduration
		   i+=1
	 end	 

     i=0
	 j=0
     while i < 30 do
	       errorcount=Hash.new
		   totalduration=Hash.new
		   if  (j<oncallissuecp.length)  && (oncallissuecp[j]["RollupDate"]==(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).utc)	      
		   errorcount["x"]=(oncallissuecp[j]["RollupDate"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(oncallissuecp[j]["oncallcp"]).to_i
		   totalduration["x"]=(oncallissuecp[j]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(oncallissuecp[j]["duration"]).to_i
		   j+=1
		   else
		   errorcount["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")	    
		   errorcount["y"]=0
		   totalduration["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")	    
		   totalduration["y"]=0
		   end		   
		   oncallissuecpdataset[i]=errorcount
		   oncalltimecpdataset[i]=totalduration
		   i+=1
	 end
	
     i=0
	 j=0
     while i < 30 do
	       errorcount=Hash.new
		   totalduration=Hash.new
		   if  (j<rolluperror.length)  && (rolluperror[j]["RollupDate"]==(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).utc)	
		   errorcount["x"]=(rolluperror[j]["RollupDate"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(rolluperror[j]["rolluperror"]).to_i		   
		   totalduration["x"]=(rolluperror[j]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(rolluperror[j]["duration"]).to_i
		   j+=1
		   else
		   errorcount["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")	
		   errorcount["y"]=0		   
		   totalduration["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")	
		   totalduration["y"]=0	   
		   end
		   rolluperrordataset[i]=errorcount
		   rolluptimedataset[i]=totalduration
		   i+=1
	 end
	 
	 i=0
	 j=0
     while i < 30 do
	       errorcount=Hash.new
		   totalduration=Hash.new
		   if  (j<rollupsystemerror.length)  && (rollupsystemerror[j]["RollupDate"]==(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).utc)	
		   errorcount["x"]=(rollupsystemerror[j]["RollupDate"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(rollupsystemerror[j]["rollupsyserror"]).to_i		   
		   totalduration["x"]=(rollupsystemerror[j]["RollupDate"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(rollupsystemerror[j]["duration"]).to_i
		   j+=1
		   else
		   errorcount["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")	
		   errorcount["y"]=0		   
		   totalduration["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")	
		   totalduration["y"]=0
		   end
		   rolluperrorsysdataset[i]=errorcount	
		   rolluptimesysdataset[i]=totalduration
		   i+=1
	 end
	 
	 i=0
	 j=0
     while i < 30 do 
	       errorcount=Hash.new
		   totalduration=Hash.new
		   if  (j<oncallissueerror.length)  && (oncallissueerror[j]["Date"]==(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).utc)	  		   
		   errorcount["x"]=(oncallissueerror[j]["Date"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(oncallissueerror[j]["oncallissueerror"]).to_i		   		   		   
		   totalduration["x"]=(oncallissueerror[j]["Date"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(oncallissueerror[j]["duration"]).to_i
		   j+=1
		   else
		   errorcount["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")
		   errorcount["y"]=0   		   		   
		   totalduration["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")
		   totalduration["y"]=0
		   end
		   oncallissuedataset[i]=errorcount
		   oncalltimedataset[i]=totalduration
		   i+=1
	 end
	 
	 i=0
	 j=0
     while i < 30 do 
	       errorcount=Hash.new
		   totalduration=Hash.new
		   if  (j<oncallsystemerror.length)  && (oncallsystemerror[j]["Date"]==(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).utc)
		   errorcount["x"]=(oncallsystemerror[j]["Date"]).strftime("%Y-%m-%d")
		   errorcount["y"]=(oncallsystemerror[j]["oncallsyserror"]).to_i
		   totalduration["x"]=(oncallsystemerror[j]["Date"]).strftime("%Y-%m-%d")
		   totalduration["y"]=(oncallsystemerror[j]["duration"]).to_i		 	
           j+=1		   
		   else
		   errorcount["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")
		   errorcount["y"]=0
		   totalduration["x"]=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00')-30+i).strftime("%Y-%m-%d")
		   totalduration["y"]=0
		   end
		   oncallissuesysdataset[i]=errorcount	
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
