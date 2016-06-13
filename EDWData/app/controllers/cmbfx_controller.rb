class CmbfxController < ApplicationController
def index
      
view = params[:View];
cmbfx={};
cmbfx[:data]=[];
cmbfx[:drilldown]=[];

if view == "Month" then
      last3mStart = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 00:00:00') << 2).strftime("%Y-%m-%d %H:%M:%S");
      last3mEnd = (DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:01"))).strftime("%Y-%m-%d %H:%M:%S");
	  
	  p last3mStart
	  p last3mEnd             
	  bfxinfo=CmbfxRequestTable.find_by_sql("select * from (select EXTRACT(YEAR FROM \"Requested_Date\") * 100 + EXTRACT(MONTH FROM \"Requested_Date\") as month, min(\"Requested_Date\") as test ,max(\"Requested_Date\") as testmax,count(\"BFX_Refer_ID\") as \"bfxcount\" from cmbfx_request_tables where  \"Requested_Date\" between \'#{last3mStart}\' and \'#{last3mEnd}\' group by EXTRACT(YEAR FROM \"Requested_Date\") * 100 + EXTRACT(MONTH FROM \"Requested_Date\")) a order by test" );
      i=0
      if bfxinfo.length >= 1 then
      bfxinfo.each_with_index do |row, index|
	        bfxRequested_Date=row["test"].strftime("%h, %Y")
			num=row["bfxcount"]
			#topId = "top" + (index + 1).to_s;
            cmbfx[:data].push({
							:name => bfxRequested_Date,
							:y => num,
							:drilldown => bfxRequested_Date
							});
		  
          bfxdetail=CmbfxRequestTable.find_by_sql("SELECT \"Requested_Date\",\"BFX_Type\"  FROM cmbfx_request_tables where \"Requested_Date\">=\'#{row["test"]}\'
		  and \"Requested_Date\"<=\'#{row["testmax"]}\'")		    
          j=0
		  countproactive=0
		  countimmediate=0		 
		  while j<bfxdetail.length do
		   if(bfxdetail[j]["BFX_Type"]=="Immediate Action")
		   countimmediate+=1
		   elsif(bfxdetail[j]["BFX_Type"]=="Proactive")
		   countproactive+=1
		   end
           j+=1		   
		  end
		  cmbfx[:drilldown].push(:id=>bfxRequested_Date,
		                    :data=>[
							["Proactive",
							countproactive],[
							"Immediately",
							countimmediate
							]
							]);
							i+=1
	  end	  
end	
elsif view == "Year" then
 		currentYearFirstDay = DateTime.parse((Time.new).strftime("%Y") + '-1-1 00:00:00').strftime("%Y-%m-%d %H:%M:%S");
		bfxinfo=CmbfxRequestTable.find_by_sql("select * from (select EXTRACT(YEAR FROM \"Requested_Date\") as year, min(\"Requested_Date\") as test ,count(\"BFX_Refer_ID\") as \"bfxcount\" from cmbfx_request_tables where  \"Requested_Date\">\'#{currentYearFirstDay}\'  group by EXTRACT(YEAR FROM \"Requested_Date\")) a order by year" );
       i=0
     if bfxinfo.length >= 1 then
      bfxinfo.each_with_index do |row, index|
	        bfxRequested_Date=row["year"].round(0)
			num=row["bfxcount"]
			#topId = "top" + (index + 1).to_s;
            cmbfx[:data].push({
							:name => bfxRequested_Date,
							:y => num,
							:drilldown => bfxRequested_Date
							});
          bfxdetail=CmbfxRequestTable.find_by_sql("SELECT \"Requested_Date\",\"BFX_Type\"  FROM cmbfx_request_tables where \"Requested_Date\">=\'#{currentYearFirstDay}\'")		    
          j=0
		  countproactive=0
		  countimmediate=0		 
		   while j<bfxdetail.length do
		   if(bfxdetail[j]["BFX_Type"]=="Immediate Action")
		   countimmediate+=1
		   elsif(bfxdetail[j]["BFX_Type"]=="Proactive")
		   countproactive+=1
		   end
           j+=1		   
		   end
		  cmbfx[:drilldown].push(:id=>bfxRequested_Date,
		                    :data=>[
							["Proactive",
							countproactive],[
							"Immediately",
							countimmediate
							]
							]);
							i+=1
	  end	  
end
elsif view == "Week" then
		last4wStart = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).strftime("%u").to_i - 4*7 + 1).strftime("%Y-%m-%d %H:%M:%S");
		last4wEnd = DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 23:59:59').strftime("%Y-%m-%d %H:%M:%S")
 		bfxinfo=CmbfxRequestTable.find_by_sql("select min(\"Requested_Date\") as test,count(*) as \"bfxcount\" from (select \"Requested_Date\", trunc(extract( day from (\"Requested_Date\" - \'#{last4wStart}\')) /7) as week from cmbfx_request_tables where \"Requested_Date\" between \'#{last4wStart}\' and \'#{last4wEnd}\') a  group by week order by week " );
p last4wStart
p last4wEnd
        i=0
     if bfxinfo.length >= 1 then
      bfxinfo.each_with_index do |row, index|
	        weekMonday = DateTime.parse(bfxinfo[i]["test"].strftime("%Y-%m-%d")+ ' 00:00:00') - bfxinfo[i]["test"].strftime("%u").to_i + 1
		    weekSunday = weekMonday + 6;
		    displayMonday = weekMonday.strftime("%h, %d")
		    displaySunday = weekSunday.strftime("%h, %d")
	        bfxRequested_Date="#{displayMonday}~#{displaySunday}"
			num=row["bfxcount"]
			#topId = "top" + (index + 1).to_s;
            cmbfx[:data].push({
							:name => bfxRequested_Date,
							:y => num,
							:drilldown => bfxRequested_Date
							});
          bfxdetail=CmbfxRequestTable.find_by_sql("SELECT \"Requested_Date\",\"BFX_Type\"  FROM cmbfx_request_tables where \"Requested_Date\">=\'#{weekMonday}\' and \"Requested_Date\"<=\'#{weekSunday}\'")		    
          j=0
		  countproactive=0
		  countimmediate=0		 
		   while j<bfxdetail.length do
		   if(bfxdetail[j]["BFX_Type"]=="Immediate Action")
		   countimmediate+=1
		   elsif(bfxdetail[j]["BFX_Type"]=="Proactive")
		   countproactive+=1
		   end
           j+=1		   
		   end
		  cmbfx[:drilldown].push(:id=>bfxRequested_Date,
		                    :data=>[
							["Proactive",
							countproactive],[
							"Immediately",
							countimmediate
							]
							]);
							i+=1
	  end	  
end
end													
render json: cmbfx.to_json

	  

end	  	  
end
