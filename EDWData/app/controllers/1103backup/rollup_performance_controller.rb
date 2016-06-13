class RollupPerformanceController < ApplicationController
      def index
	    pf = params[:type]
        if 	pf=="memory"	
		privious30time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 30).strftime("%Y-%m-%d %H:%M:%S")
        #performationinfo = RollupPerformance.select('RollupDate','MemAllocMb','DiskIOTotal','CPUBusySecs','ElapseTime')
		performationinfo = RollupPerformance.find_by_sql("select \"RollupDate\",\"MemAllocMb\",\"DiskIOTotal\",\"CPUBusySecs\",\"ElapseTime\" from rollup_performances where \"Environment\"=\'#{params[:Environment]}\' order by \"RollupDate\"")
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
		end 
		else if pf=="row"
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
	  end
end
