class FileloadingoneController < ApplicationController
def index
		begin  
			company = params[:Company]
			#company = "HPE"
			char = params[:Character]
			#char = "C"
			today = (Time.new - 3600*8).strftime("%Y/%m/%d")
			json = Hash.new
			avgtime = Array.new
			scits = "/"
			scits = "SCITS" if char=="S"
			avgtime =  FileLoadingInfor.find_by_sql(
				"select distinct a.\"Source_System_Name\",t.\"Server\",t.\"Source_System_Key\",t.\"avg\",t.\"max\",t.\"min\"
				from src_sys_infors a
				RIGHT JOIN
				(SELECT \"Server\",\"Source_System_Key\",avg(age(\"File_Generated_TS\",date(\"File_Generated_TS\"))),max(date(\"File_Generated_TS\")) ,min(date(\"File_Generated_TS\")) 
				FROM  file_loading_infors
	  			where \"Source_System_Key\" in
	 			 (SELECT \"Source_System_Key\"
	  			from src_sys_infors 
	  			where \"Company_Flag\"  in(\'#{company}\',\'HPQ\') and \"Key_Source_System_Flag\"=\'Yes\'  and \"Source_System_Name\" like \'#{char}%\'  and \"Source_System_Name\" not like \'#{scits}%\') 
	  			group by \"Server\",\"Source_System_Key\"
				)t
				on a.\"Source_System_Key\" = t.\"Source_System_Key\";"
			)

			category = Array.new
			maxtime = Array.new
			mintime = Array.new
			jad_avgtime = Array.new
			zeo_avgtime = Array.new
			emr_avgtime = Array.new
			jad_category = Array.new
			emr_category = Array.new
			zeo_category = Array.new
	 		avgtime.each do |f|
				category.push ( f.Source_System_Name	)
	 		end	
	 		category = category.uniq
	###################################################################from to
	 		avgtime.each do |f|
				maxtime.push (f.max)
	 		end	
	 		avgtime.each do |f|
				mintime.push (f.min)
	 		end	
	##################################################################data of jad
	 		avgtime.each do |f|
				jad_avgtime.push ( f.avg ) if  f.Server == "JAD" 
	 		end		
	 		avgtime.each do |f|
				jad_category.push ( category.index(f.Source_System_Name)) if  f.Server == "JAD" 
	 		end
	 		jad_avgtime.each_with_index do |x,index|
	 			jad_avgtime[index] = [jad_category[index],today + " " + jad_avgtime[index][0,8]]
	 		end

	##################################################################data of zeo
	 		avgtime.each do |f|
				zeo_avgtime.push ( f.avg ) if  f.Server == "ZEO" 
	 		end
	 		avgtime.each do |f|
				zeo_category.push ( category.index(f.Source_System_Name)) if  f.Server == "ZEO" 
	 		end
	 		zeo_avgtime.each_with_index do |x,index|
	 			zeo_avgtime[index] = [zeo_category[index],today + " " + zeo_avgtime[index][0,8]]
	 		end
	##################################################################data of  emr
	 		avgtime.each do |f|
				emr_avgtime.push ( f.avg ) if  f.Server == "EMR" 
	 		end
	 		avgtime.each do |f|
				emr_category.push ( category.index(f.Source_System_Name)) if  f.Server == "EMR" 
	 		end
	 		emr_avgtime.each_with_index do |x,index|
	 			emr_avgtime[index] = [emr_category[index],today + " " + emr_avgtime[index][0,8]]
	 		end
	 ##################################################################upload jason
	 		json["date"] = today
	  		json["from"] = (Time.new - 3600*8).strftime("%Y/%m/%d")
	  		json["to"] = (Time.new - 3600*8).strftime("%Y/%m/%d")
	 		json["from"] = (mintime.min).strftime("%Y/%m/%d") if  mintime.size != 0
	  		json["to"] =  (maxtime.max).strftime("%Y/%m/%d") if maxtime.size != 0
	 		json["categories"] = category
			json["ZEO"] = zeo_avgtime
			json["EMR"] = emr_avgtime
	 		json["JAD"] = jad_avgtime
	 ###############################################################The convention with boss he
			json = {"ERROR"  => "Key Source System File Start With Character #{char} #{company} Does Not Exist"} if  category.size == 0
		rescue
			json = {"ERROR"  => "Some Thing Wrong"}
		end
		render json: json.to_json
	end
end
