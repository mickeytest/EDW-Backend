class BdsticketController < ApplicationController

def index
view = params[:View];
bdsjs={};
bdsjs[:data]=[];
bdsjs[:drilldown]=[];
if view == "Day" then
   privious7time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 7).strftime("%Y-%m-%d %H:%M:%S")
   bdsinfo=BdStrackers.find_by_sql("SELECT \"date\", count(*) as \"bdscount\"FROM bd_strackers where \"date\">=\'#{privious7time}\' group by \"date\" order by \"date\"")
   i=0
   if bdsinfo.length >= 1 then
      bdsinfo.each_with_index do |row, index|
	        bdsdate=row["date"].strftime("%b,%d")
			num=row["bdscount"]
			#topId = "top" + (index + 1).to_s;
            bdsjs[:data].push({
							:name => bdsdate,
							:y => num,
							:drilldown => bdsdate
							});
          bdsdetail=BdStrackers.find_by_sql("SELECT \"date\",\"timeToEngage\"  FROM bd_strackers where \"date\"=\'#{row["date"]}\'")		    
          j=0
		  countsix=0
		  countten=0
		  countthirty=0
		  countsmallsixty=0
		  countbigsixty=0
		  while j<bdsdetail.length do
		   if(bdsdetail[j]["timeToEngage"]>=0 && bdsdetail[j]["timeToEngage"]<6)
		   countsix+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=6 && bdsdetail[j]["timeToEngage"]<10)
		   countten+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=10 && bdsdetail[j]["timeToEngage"]<30)
		   countthirty+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=30 && bdsdetail[j]["timeToEngage"]<60)
		   countsmallsixty+=1
		   else
		   countbigsixty+=1
		   end
           j+=1		   
		  end

		   bdsjs[:drilldown].push(:id=>bdsdate,
		                    :data=>[
							["TTE: 0-5 mins",
							countsix],[
							"TTE: 6-10 mins",
							countten
							],[
							"TTE: 10-30 mins",
							countthirty,
							],[
							"TTE: 30-60 mins",
							countsmallsixty,
							],[
							"TTE: &gt; 60 mins",
							countbigsixty,
							]
							]);
							i+=1
end
end
elsif view == "Month" then
      last3mStart = (DateTime.parse((Time.new).strftime("%Y-%m") + '-1 00:00:00') << 2).strftime("%Y-%m-%d %H:%M:%S");
      last3mEnd = (DateTime.parse((Time.new).strftime("%Y-%m-%d 00:00:01"))).strftime("%Y-%m-%d %H:%M:%S");
	  
	  p last3mStart
	  p last3mEnd
	  bdsinfo=BdStrackers.find_by_sql("select * from (select EXTRACT(YEAR FROM \"date\") * 100 + EXTRACT(MONTH FROM \"date\") as month, min(\"date\") as test ,max(\"date\") as testmax,count(*) as \"bdscount\" from bd_strackers where  \"date\" between \'#{last3mStart}\' and \'#{last3mEnd}\' group by EXTRACT(YEAR FROM \"date\") * 100 + EXTRACT(MONTH FROM \"date\")) a order by test" );
      i=0
      if bdsinfo.length >= 1 then
      bdsinfo.each_with_index do |row, index|
	        bdsdate=row["test"].strftime("%h, %Y")
			num=row["bdscount"]
			#topId = "top" + (index + 1).to_s;
            bdsjs[:data].push({
							:name => bdsdate,
							:y => num,
							:drilldown => bdsdate
							});
		  
          bdsdetail=BdStrackers.find_by_sql("SELECT \"date\",\"timeToEngage\"  FROM bd_strackers where \"date\">=\'#{row["test"]}\'
		  and \"date\"<=\'#{row["testmax"]}\'")		    
          j=0
		  countsix=0
		  countten=0
		  countthirty=0
		  countsmallsixty=0
		  countbigsixty=0
		  while j<bdsdetail.length do
		   if(bdsdetail[j]["timeToEngage"]>=0 && bdsdetail[j]["timeToEngage"]<6)
		   countsix+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=6 && bdsdetail[j]["timeToEngage"]<10)
		   countten+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=10 && bdsdetail[j]["timeToEngage"]<30)
		   countthirty+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=30 && bdsdetail[j]["timeToEngage"]<60)
		   countsmallsixty+=1
		   else
		   countbigsixty+=1
		   end
           j+=1		   
		  end
		  bdsjs[:drilldown].push(:id=>bdsdate,
		                    :data=>[
							["TTE: 0-5 mins",
							countsix],[
							"TTE: 6-10 mins",
							countten
							],[
							"TTE: 10-30 mins",
							countthirty,
							],[
							"TTE: 30-60 mins",
							countsmallsixty,
							],[
							"TTE: &gt; 60 mins",
							countbigsixty,
							]
							]);
							i+=1
	  end	  
end	
elsif view == "Year" then
 		currentYearFirstDay = DateTime.parse((Time.new).strftime("%Y") + '-1-1 00:00:00').strftime("%Y-%m-%d %H:%M:%S");
		bdsinfo=BdStrackers.find_by_sql("select * from (select EXTRACT(YEAR FROM \"date\") as year, min(\"date\") as test ,count(*) as \"bdscount\" from bd_strackers where  \"date\">\'#{currentYearFirstDay}\'  group by EXTRACT(YEAR FROM \"date\")) a order by year" );
       i=0
     if bdsinfo.length >= 1 then
      bdsinfo.each_with_index do |row, index|
	        bdsdate=row["year"].round(0)
			num=row["bdscount"]
			#topId = "top" + (index + 1).to_s;
            bdsjs[:data].push({
							:name => bdsdate,
							:y => num,
							:drilldown => bdsdate
							});
          bdsdetail=BdStrackers.find_by_sql("SELECT \"date\",\"timeToEngage\"  FROM bd_strackers where \"date\">=\'#{currentYearFirstDay}\'")		    
          j=0
		  countsix=0
		  countten=0
		  countthirty=0
		  countsmallsixty=0
		  countbigsixty=0
		  while j<bdsdetail.length do
		   if(bdsdetail[j]["timeToEngage"]>=0 && bdsdetail[j]["timeToEngage"]<6)
		   countsix+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=6 && bdsdetail[j]["timeToEngage"]<10)
		   countten+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=10 && bdsdetail[j]["timeToEngage"]<30)
		   countthirty+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=30 && bdsdetail[j]["timeToEngage"]<60)
		   countsmallsixty+=1
		   else
		   countbigsixty+=1
		   end
           j+=1		   
		  end
		   bdsjs[:drilldown].push(:id=>bdsdate,
		                    :data=>[
							["TTE: 0-5 mins",
							countsix],[
							"TTE: 6-10 mins",
							countten
							],[
							"TTE: 10-30 mins",
							countthirty,
							],[
							"TTE: 30-60 mins",
							countsmallsixty,
							],[
							"TTE: &gt; 60 mins",
							countbigsixty,
							]
							]);
							i+=1
	  end	  
end
elsif view == "Week" then
		last4wStart = (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).strftime("%u").to_i - 4*7 + 1).strftime("%Y-%m-%d %H:%M:%S");
		last4wEnd = DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 23:59:59').strftime("%Y-%m-%d %H:%M:%S")
 		bdsinfo=BdStrackers.find_by_sql("select min(\"date\") as test,count(*) as \"bdscount\" from (select \"date\", trunc(extract( day from (\"date\" - \'#{last4wStart}\')) /7) as week from bd_strackers where \"date\" between \'#{last4wStart}\' and \'#{last4wEnd}\') a  group by week order by week " );
p last4wStart
p last4wEnd
        i=0
     if bdsinfo.length >= 1 then
      bdsinfo.each_with_index do |row, index|
	        weekMonday = DateTime.parse(bdsinfo[i]["test"].strftime("%Y-%m-%d")+ ' 00:00:00') - bdsinfo[i]["test"].strftime("%u").to_i + 1
		    weekSunday = weekMonday + 6;
		    displayMonday = weekMonday.strftime("%h, %d")
		    displaySunday = weekSunday.strftime("%h, %d")
	        bdsdate="#{displayMonday}~#{displaySunday}"
			num=row["bdscount"]
			#topId = "top" + (index + 1).to_s;
            bdsjs[:data].push({
							:name => bdsdate,
							:y => num,
							:drilldown => bdsdate
							});
          bdsdetail=BdStrackers.find_by_sql("SELECT \"date\",\"timeToEngage\"  FROM bd_strackers where \"date\">=\'#{weekMonday}\' and \"date\"<=\'#{weekSunday}\'")		    
          j=0
		  countsix=0
		  countten=0
		  countthirty=0
		  countsmallsixty=0
		  countbigsixty=0
		  while j<bdsdetail.length do
		   if(bdsdetail[j]["timeToEngage"]>=0 && bdsdetail[j]["timeToEngage"]<6)
		   countsix+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=6 && bdsdetail[j]["timeToEngage"]<10)
		   countten+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=10 && bdsdetail[j]["timeToEngage"]<30)
		   countthirty+=1
		   elsif(bdsdetail[j]["timeToEngage"]>=30 && bdsdetail[j]["timeToEngage"]<60)
		   countsmallsixty+=1
		   else
		   countbigsixty+=1
		   end
           j+=1		   
		  end
		  
		   bdsjs[:drilldown].push(:id=>bdsdate,
		                    :data=>[
							["TTE: 0-5 mins",
							countsix],[
							"TTE: 6-10 mins",
							countten
							],[
							"TTE: 10-30 mins",
							countthirty,
							],[
							"TTE: 30-60 mins",
							countsmallsixty,
							],[
							"TTE: &gt; 60 mins",
							countbigsixty,
							]
							]);
							i+=1
	  end	  
end
end													
render json: bdsjs.to_json
end
end
