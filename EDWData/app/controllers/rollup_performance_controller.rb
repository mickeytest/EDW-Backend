class RollupPerformanceController < ApplicationController
      def index
	    pfdate =params[:RollupDate] 
	    pf = params[:type]
if  pfdate==nil  
        if 	pf=="memory"	
		privious30time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 30).strftime("%Y-%m-%d %H:%M:%S")
        #performationinfo = RollupPerformance.select('RollupDate','MemAllocMb','DiskIOTotal','CPUBusySecs','ElapseTime')
		performationinfo = RollupPerformance.find_by_sql("select \"RollupDate\",\"MemAllocMb\",\"DiskIOTotal\",\"CPUBusySecs\",\"ElapseTime\" from rollup_performances where \"Environment\"=\'#{params[:Environment]}\' order by \"RollupDate\"")
		
		lastrollupinformation=RollupPerformance.find_by_sql("select \"Start_TS\",\"RowsAccessed\",\"DiskIOTotal\",\"End_TS\",\"RowsIUDTotal\",\"MemAllocMb\",\"ElapseTime\",\"CPUBusySecs\",\"MemUsedMb\" from rollup_performances aaa where \"RollupDate\" in
(
select max(\"RollupDate\") from rollup_performances where \"Environment\"=\'#{params[:Environment]}\'
) 
and aaa.\"Environment\"=\'#{params[:Environment]}\'")

		#\"RollupDate\">\'#{privious30time}\'")
		memalloc=Hash.new
		diskio=Hash.new
		cpubusy=Hash.new
		elapsetime=Hash.new	
		memallocinfo=Array.new
		cpubusyinfo=Array.new
		diskioinfo=Array.new
		elapsetimeinfo=Array.new		
		ychar1=Array.new			
		performationinfojson=Hash.new
		performationinfojson["LastRollupStartTS"]=lastrollupinformation[0]["Start_TS"].strftime("%Y-%m-%d %H:%M")
		performationinfojson["LastRollupRowAcc"]=change_str(lastrollupinformation[0]["RowsAccessed"])
		performationinfojson["LastRollupDiskIO"]=change_str(lastrollupinformation[0]["DiskIOTotal"])
		performationinfojson["LastRollupEndTS"]=lastrollupinformation[0]["End_TS"].strftime("%Y-%m-%d %H:%M")
		performationinfojson["LastRollupRowIUD"]=change_str(lastrollupinformation[0]["RowsIUDTotal"])
		performationinfojson["LastRollupMemAll"]=change_str(lastrollupinformation[0]["MemAllocMb"])
		performationinfojson["LastRollupElasped"]=(lastrollupinformation[0]["ElapseTime"]).round(1)
		performationinfojson["LastRollupCPUBusy"]=change_str(lastrollupinformation[0]["CPUBusySecs"])
		performationinfojson["LastRollupMemUsed"]=change_str(lastrollupinformation[0]["MemUsedMb"])
		i=0
		cpubusy["name"]="CPU Busy (Hours)"
	    memalloc["name"]="Mem Alloc (Gb)"
	    elapsetime["name"]="Elapsed Time (Hours)"		
		diskio["name"]="Disk IO Total(million)"
		while i < performationinfo.length do
			  tempHash1=Hash.new
			  tempHash1["x"]=performationinfo[i]["RollupDate"].strftime("%Y-%m-%d")   
			  tempHash1["y"]=performationinfo[i]["CPUBusySecs"]/3600
			  cpubusyinfo[i]=tempHash1
			  tempHash2=Hash.new
			  tempHash2["x"]=performationinfo[i]["RollupDate"].strftime("%Y-%m-%d") 
			  tempHash2["y"]=performationinfo[i]["MemAllocMb"]/1024
			  memallocinfo[i]=tempHash2
			  tempHash3=Hash.new
			  tempHash3["x"]=performationinfo[i]["RollupDate"].strftime("%Y-%m-%d") 
			  tempHash3["y"]=(performationinfo[i]["ElapseTime"]).round(2)
			  elapsetimeinfo[i]=tempHash3
			  tempHash4=Hash.new
			  tempHash4["x"]=performationinfo[i]["RollupDate"].strftime("%Y-%m-%d")   
			  tempHash4["y"]=(performationinfo[i]["DiskIOTotal"].to_f/1000000).round(1)
			  diskioinfo[i]=tempHash4		  
		      i+=1
	    end
		cpubusy["dataset"]=cpubusyinfo
		memalloc["dataset"]=memallocinfo
		elapsetime["dataset"]=elapsetimeinfo
		diskio["dataset"]=diskioinfo
        	ychar1[0]=	 memalloc
			ychar1[1]=	 diskio
			ychar1[2]=	 cpubusy		
			ychar1[3]=	 elapsetime
			performationinfojson["Data"]=ychar1
		 render json: performationinfojson.to_json
		elsif pf=="row"
		puts "coming in"
        performationinfo = RollupPerformance.find_by_sql("select \"RollupDate\",\"RowsAccessed\",\"RowsIUDTotal\",\"FileSize\",\"ElapseTime\" from rollup_performances where \"Environment\"=\'#{params[:Environment]}\' order by \"RollupDate\"")		
		#performationinfo = RollupPerformance.select('RollupDate','RowsAccessed', 'RowsIUDTotal', 'FileSize',  'ElapseTime')	
		rollaccess=Hash.new
		rowsiud=Hash.new
        filesize=Hash.new		
		elapsetime=Hash.new			
		rollaccessinfo=Array.new	
		rowsiudinfo=Array.new
		filesizeinfo=Array.new
		elapsetimeinfo=Array.new			
		ychar2=Array.new
		performationinfojson=Hash.new
		i=0
		rollaccess["name"]="Rows Accessed Total(million)"
		rowsiud["name"]="Rows IUD Total(million)"
		filesize["name"]="File size (Gb)"
		elapsetime["name"]="Elapsed Time (Hours)"					
		while i < performationinfo.length do  
              tempHash1=Hash.new		
			  tempHash1["x"]=performationinfo[i]["RollupDate"].strftime("%Y-%m-%d")   
			  tempHash1["y"]=(performationinfo[i]["RowsIUDTotal"].to_f/1000000).round(1)
			  rowsiudinfo[i]=tempHash1
			  tempHash2=Hash.new		
			  tempHash2["x"]=performationinfo[i]["RollupDate"].strftime("%Y-%m-%d")  
			  tempHash2["y"]=performationinfo[i]["FileSize"]
			  filesizeinfo[i]=tempHash2			  
			  tempHash3=Hash.new		
			  tempHash3["x"]=performationinfo[i]["RollupDate"].strftime("%Y-%m-%d")  
			  tempHash3["y"]=(performationinfo[i]["RowsAccessed"].to_f/1000000).round(1)
			  rollaccessinfo[i]=tempHash3			  
			  tempHash4=Hash.new
			  tempHash4["x"]=performationinfo[i]["RollupDate"].strftime("%Y-%m-%d") 
			  tempHash4["y"]=(performationinfo[i]["ElapseTime"]).round(2)
			  elapsetimeinfo[i]=tempHash4
		      i+=1
	    end
		rowsiud["dataset"]=rowsiudinfo
		rollaccess["dataset"]=rollaccessinfo
		filesize["dataset"]=filesizeinfo
		elapsetime["dataset"]=elapsetimeinfo
		    ychar2[0]=	rollaccess
        	ychar2[1]=	rowsiud
			ychar2[2]=	filesize	
            ychar2[3]=	elapsetime			
			performationinfojson["Data"]=ychar2
		 render json: performationinfojson.to_json
		 end
else

        pfdate=(DateTime.parse(params[:RollupDate])).strftime("%Y-%m-%d 00:00:00")
        performancesinfo=RollupPerformance.find_by_sql("select \"Start_TS\",\"End_TS\" from rollup_performances where \"Environment\"=\'#{params[:Environment]}\' and \"RollupDate\"=\'#{pfdate}\' ") 		
		performancesdetailinfo=RollupPerformancesDetail.find_by_sql("select * from rollup_performances_details where \"Environment\"=\'#{params[:Environment]}\' and \"RollupDate\"=\'#{pfdate}\'  order by \"id\" ") 
		rowcount=0
		if(performancesdetailinfo.length>0)
		rowcount=performancesdetailinfo[performancesdetailinfo.length-1]["id"] - performancesdetailinfo[0]["id"] + 1
        end
		datadetail=Array.new

		datadetail[0]=performancesinfo[0]["Start_TS"].strftime("%H:%M")
		addoneday=false
        i=0
		while i< rowcount do
		  if((0==performancesdetailinfo[i]["Hours"].to_s.split(".")[0].to_i) || (addoneday==true) )
		     addoneday=true
		     datadetail[i]=(DateTime.parse((performancesdetailinfo[0]["RollupDate"]).strftime("%Y/%m/%d"))+1)
	         datadetail[i]=DateTime.parse((datadetail[i]).strftime("%Y/%m/%d %H")) +  (performancesdetailinfo[i]["Hours"].to_s.split(".")[0].to_i)/24.0		  
		     datadetail[i]=(DateTime.parse((datadetail[i]).strftime("%Y/%m/%d %H:%M")) + ((performancesdetailinfo[i]["Hours"].to_s[-1].to_i)*10)/(60.0*24)).strftime("%Y/%m/%d %H:%M")#.strftime("%H:%M")      
	         p datadetail[i]
		  else	
             datadetail[i]=DateTime.parse((performancesdetailinfo[0]["RollupDate"]).strftime("%Y/%m/%d %H")) +  (performancesdetailinfo[i]["Hours"].to_s.split(".")[0].to_i)/24.0		  
		     datadetail[i]=(DateTime.parse((datadetail[i]).strftime("%Y/%m/%d %H:%M")) + ((performancesdetailinfo[i]["Hours"].to_s[-1].to_i)*10)/(60.0*24)).strftime("%Y/%m/%d %H:%M")#.strftime("%H:%M")      
             p datadetail[i]		  
		  end		
		  i+=1
		end

		
		
		rollupdilldown=Hash.new
        rollupdilldown["xdata"]=datadetail
		memoryall=Array.new
		cpubusy=Array.new
		diskiototal=Array.new
		rollaccesstotal=Array.new
		rowchangetotal=Array.new


        i=0
		while i<=performancesdetailinfo.length-1 do
		memoryall[i]=performancesdetailinfo[i]["MemAllocMb"]
		cpubusy[i]=performancesdetailinfo[i]["CPUBusySecs"]
		diskiototal[i]=performancesdetailinfo[i]["DiskIOTotal"]
		rollaccesstotal[i]=performancesdetailinfo[i]["RowsAccessed"].to_i
		rowchangetotal[i]=performancesdetailinfo[i]["RowsIUDTotal"].to_i
		i+=1
		end
        
      rollupdilldown["data"]=[{:name=>"Memory Allocated", :data=>memoryall,:unit=>"Gb",:valueDecimals=>0 },
	  {:name=>"CPU Busy", :data=>cpubusy,:unit=>"Hours",:valueDecimals=>0},
	  {:name=>"Disk IO Total", :data=>diskiototal,:unit=>"Million",:valueDecimals=>1},
	  {:name=>"Rows Accessed Total", :data=>rollaccesstotal,:unit=>"Million",:valueDecimals=>0},
	  {:name=>"Rows Insert Update Delete Total", :data=>rowchangetotal,:unit=>"Million",:valueDecimals=>1},  
	  ]

       render json: rollupdilldown.to_json
end		 		 
end



		
		def change_str(num)
               str = num.to_s
               nil while str.gsub!(/(.*\d)(\d\d\d)/, '\1,\2')
               return str
        end
	  
end
