class FileloadingController < ApplicationController
      def index
	     
		 privious3time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 4)				 
         rolluptimeinfo=Dailyrolluptime.find_by_sql("select \"Server\",\"RollupDate\",\"Start_TS\",\"End_TS\"  from dailyrolluptimes  where \"Server\"!='BER' and \"End_TS\" is not null and \"RollupDate\">=\'#{privious3time}\' order by \"RollupDate\" desc,\"Server\" asc")		 		 
         i=0
		 jadalltime=Array.new
		 zeoalltime=Array.new
		 j_adcount=0
		 z_eocount=0
		 j=0
		 c=0
		 d=0
		 f=0
		 while i<rolluptimeinfo.length do
		 if(rolluptimeinfo[0]["Server"]=='JAD' || rolluptimeinfo[0]["Server"]=='EMR')
		       if(j_adcount<3 && (rolluptimeinfo[i]["Server"]=='JAD') ) 
		       jadalltime[j]=rolluptimeinfo[i]["Start_TS"]
			   jadalltime[j+1]=rolluptimeinfo[i]["End_TS"]
			   j+=2
			   j_adcount+=1
			   elsif(z_eocount<2 && (rolluptimeinfo[i]["Server"]=='ZEO'))
		       zeoalltime[d]=rolluptimeinfo[i]["Start_TS"]
			   zeoalltime[d+1]=rolluptimeinfo[i]["End_TS"]
			   d+=2
			   z_eocount+=1
			   end
		 else
		       if(j_adcount<2 && (rolluptimeinfo[i]["Server"]=='JAD')) 
		       jadalltime[c]=rolluptimeinfo[i]["Start_TS"]
			   jadalltime[c+1]=rolluptimeinfo[i]["End_TS"]
			   c+=2
			   j_adcount+=1
			   elsif(z_eocount<3 && (rolluptimeinfo[i]["Server"]=='ZEO'))
		       zeoalltime[f]=rolluptimeinfo[i]["Start_TS"]
			   zeoalltime[f+1]=rolluptimeinfo[i]["End_TS"]
			   f+=2
			   z_eocount+=1
			   end
		 end
         i+=1		 
		 end
		fileloadinghash=Hash.new
		dataarray=Array.new 
         datastart=nil
		 dataend=nil
		 jadrollupcount=0
		 zeorollupcount=0
	    if(rolluptimeinfo[0]["Server"]=='JAD' || rolluptimeinfo[0]["Server"]=='EMR')
		      filecountinformation=FileLoadingInfor.find_by_sql("select * from (select \"Server\",  date_trunc('minute',  \"Load_End_TS\") as \"detailtime\",count(*) as \"loadfilecount\" from file_loading_infors where \"Load_Start_TS\">=\'#{jadalltime[jadalltime.length-1]}\' and \"Load_End_TS\"<=\'#{jadalltime[1]}\' and \"Server\"!='BER' group by \"Server\",date_trunc('minute', \"Load_End_TS\"))a  order by  \"Server\" desc,\"detailtime\" asc")
              dataarray[0]=jadalltime[jadalltime.length-1].strftime("%Y/%m/%d") #privious3time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")) - 2).strftime("%Y/%m/%d")	
              bb=0
			  while (DateTime.parse((jadalltime[jadalltime.length-1]).strftime("%Y-%m-%d")) + bb)<=(DateTime.parse((jadalltime[1]).strftime("%Y-%m-%d"))) do
              dataarray[bb]=(DateTime.parse((jadalltime[jadalltime.length-1]).strftime("%Y-%m-%d")) + bb).strftime("%Y/%m/%d")
			  bb+=1
			  end          			  
		      fileloadinghash["STARTTIME"]=jadalltime[jadalltime.length-1].strftime("%Y/%m/%d %H:%M:%S")
		      datastart=jadalltime[jadalltime.length-1]
		      dataend=jadalltime[1]
			  jadrollupcount=2
		      zeorollupcount=1
		else
		filecountinformation=FileLoadingInfor.find_by_sql("select * from (select \"Server\",  date_trunc('minute',  \"Load_End_TS\") as \"detailtime\",count(*) as \"loadfilecount\" from file_loading_infors where \"Load_Start_TS\">=\'#{zeoalltime[zeoalltime.length-1]}\' and \"Load_End_TS\"<=\'#{zeoalltime[1]}\' and \"Server\"!='BER' group by \"Server\",date_trunc('minute', \"Load_End_TS\"))a  order by  \"Server\" desc,\"detailtime\" asc")
		 bb=0
			  while (DateTime.parse((zeoalltime[zeoalltime.length-1]).strftime("%Y-%m-%d")) + bb)<=(DateTime.parse((zeoalltime[1]).strftime("%Y-%m-%d"))) do
              dataarray[bb]=(DateTime.parse((zeoalltime[zeoalltime.length-1]).strftime("%Y-%m-%d")) + bb).strftime("%Y/%m/%d")
			  bb+=1
			  end  
		fileloadinghash["STARTTIME"]=zeoalltime[zeoalltime.length-1].strftime("%Y/%m/%d %H:%M:%S")
		datastart=zeoalltime[zeoalltime.length-1]
		dataend=zeoalltime[1]
		jadrollupcount=1
		zeorollupcount=2
		end		
		fileloadinghash["date"]=dataarray
		fileloadinghash["ZEODST"]=0
		fileloadinghash["EMRDST"]=0
	
		
		 zeofilecounthash=Hash.new
		 jadfilecounthash=Hash.new
		 zeofilecount=0
		 jadfilecount=0
		 zeofilecount1=0
		 jadfilecount1=0
		 zeostarttime=nil
		 jadstarttime=nil
		 jadstarttime1=nil
		 zeostarttime1=nil
		  zeodatastartpoint=0
          zeodatastartpoint1=0
          jaddatastartpoint=0
          jaddatastartpoint1=0 
		  i=0

		  alldateinfo=Array.new
		  j=0
		  a=0
          c=0
		  d=0
	     while i<filecountinformation.length do	
            if	filecountinformation[i]["Server"]=='JAD'	
			    if (jadalltime[3] < filecountinformation[i]["detailtime"])
				      if(j==0)	
					  jaddatastartpoint=i
				      jadstarttime=filecountinformation[i]["detailtime"]
				      j=1
					  end
				  jadfilecount+=filecountinformation[i]["loadfilecount"]
			    else 
				      if(a==0)
					  jaddatastartpoint1=i
				      jadstarttime1=filecountinformation[i]["detailtime"]
					  a=1
				      end
				  jadfilecount1+=filecountinformation[i]["loadfilecount"]
				end
			else
			    if (zeoalltime[3] < filecountinformation[i]["detailtime"])
				      if(c==0)	
					  zeodatastartpoint=i
				      zeostarttime=filecountinformation[i]["detailtime"]
				      c=1
					  end
				  zeofilecount+=filecountinformation[i]["loadfilecount"]
			    else 
				      if(d==0)
					  zeodatastartpoint1=i
				      zeostarttime1=filecountinformation[i]["detailtime"]
					  d=1
				      end
				  zeofilecount1+=filecountinformation[i]["loadfilecount"]
				end   
			end
			
			alldateinfo[i]=filecountinformation[i]["loadfilecount"]
			i+=1	
		 end  

         zeodatacount=Array.new
		 jaddatacount=Array.new
		 emrdatacount=Array.new
         jadcurrent=jadfilecount1
		 jadcurrent1=jadfilecount
		 zeocurrent=zeofilecount
		 zeocurrent1=zeofilecount1
	     puts jadstarttime
		 puts zeostarttime
		 e_nd=(((dataend-datastart)/60.0).to_int).round(0)

		 if(jadrollupcount==1 && zeorollupcount==2)
		     if(zeostarttime1!=nil)
		     zeorollupstarttime1=(((zeoalltime[zeoalltime.length-1]-datastart)/60.0).to_int).round(0)
		     zeofirststarttime1=(((zeostarttime1-datastart)/60.0).to_int).round(0)
			 end
			 if(zeostarttime!=nil)
			 zeorollupstarttime=(((zeoalltime[3]-datastart)/60.0).to_int).round(0)
		     zeofirststarttime=(((zeostarttime-datastart)/60.0).to_int).round(0)
			 end
			 if(jadstarttime!=nil)
		     jadrollupstarttime=(((jadalltime[jadalltime.length-1]-datastart)/60.0).to_int).round(0)
		     jadfirststarttime=(((jadstarttime-datastart)/60.0).to_int).round(0)	
			 end
		 elsif(jadrollupcount==2 && zeorollupcount==1)
		     if(jadstarttime1!=nil)
		     jadrollupstarttime1=(((jadalltime[jadalltime.length-1]-datastart)/60.0).to_int).round(0)
		     jadfirststarttime1=(((jadstarttime1-datastart)/60.0).to_int).round(0)
			 end
			 if(jadstarttime!=nil)
			 jadrollupstarttime=(((jadalltime[3]-datastart)/60.0).to_int).round(0)
		     jadfirststarttime=(((jadstarttime-datastart)/60.0).to_int).round(0)
			 end
			 if(zeostarttime!=nil)
		     zeorollupstarttime=(((zeoalltime[zeoalltime.length-1]-datastart)/60.0).to_int).round(0)
		     zeofirststarttime=(((zeostarttime-datastart)/60.0).to_int).round(0)
             end			 
		 end
		 puts 'jadrollupstarttime'
		 puts jadrollupstarttime
		 puts 'jadfirststarttime'
		 puts jadfirststarttime
		 puts 'jadalltime[jadalltime.length-1]'
		 puts jadalltime[jadalltime.length-1]
		 puts 'jadstarttime'
		 puts jadstarttime
		 puts 'jadfilecount'
		 puts jadfilecount
		  puts 'jadfilecount1'
		 puts jadfilecount1
		 puts 'jadalltime[3]'
		 puts jadalltime[3]
		 puts 'jadstarttime1'
		 puts jadstarttime1
		 puts 'jadstarttime'
		 puts jadstarttime
		 
		 puts 'jadcurrent'
		 puts jadcurrent
		 puts 'jaddatastartpoint1'
         puts jaddatastartpoint1	
		 
		 
		 
		 
		 puts 'zeorollupstarttime'
		 puts zeorollupstarttime
		 puts 'zeofirststarttime'
		 puts zeofirststarttime
		 puts 'zeoalltime[zeoalltime.length-1]'
		 puts zeoalltime[zeoalltime.length-1]
		 puts 'zeostarttime'
		 puts zeostarttime
		 puts 'zeofilecount'
		 puts zeofilecount
		 puts 'zeoalltime[3]'
		 puts zeoalltime[3]
		 puts 'zeostarttime1'
		 puts zeostarttime1
		 puts 'zeostarttime'
		 puts zeostarttime
		 
		 puts 'zeocurrent'
		 puts zeocurrent
		 puts 'zeodatastartpoint1'
         puts zeodatastartpoint1
 	 
         i=0
         jadfirstadd=0
         jadsecondadd=0	 
		 zeofirstadd=0
         zeosecondadd=0	
		 while i<e_nd do
         emrdatacount[i]=0				   
		 if(rolluptimeinfo[0]["Server"]=='JAD' || rolluptimeinfo[0]["Server"]=='EMR')
		      if(zeostarttime!=nil)
		           if(i>=zeorollupstarttime && i<zeofirststarttime)
				          zeodatacount[i]=0
					elsif(i==zeofirststarttime)	 
					    zeodatacount[i]=zeocurrent
					elsif(zeocurrent>=0 && i>zeofirststarttime)	   
					   if(zeocurrent>0)
					        inteval=((filecountinformation[zeodatastartpoint+1]["detailtime"]-filecountinformation[zeodatastartpoint]["detailtime"])/60.0).round(0)					           
							   zeocurrent= zeocurrent-alldateinfo[zeodatastartpoint]				   
					           zeodatacount[i+zeofirstadd]=zeocurrent
							   if(inteval!=1)
							         bbbb=1
							           while bbbb<inteval
									      zeofirstadd+=1
							              zeodatacount[i+zeofirstadd]=zeocurrent							                                   								  
								          bbbb+=1	                                       							  
							           end
							   end
					   else
					   zeodatacount[i+zeofirstadd]=0
					   end
					   zeodatastartpoint+=1			   				   
				   else
					   zeodatacount[i+zeofirstadd]=0	
                   end
               else
			           zeodatacount[i+zeofirstadd]=0	
			   end
			   
               if(jadstarttime1!=nil) 			   
				   if(i>=jadrollupstarttime1 && i<jadfirststarttime1)
		               jaddatacount[i]=0
					elsif(i==jadfirststarttime1)
					 jaddatacount[i]=jadcurrent
					elsif(jadcurrent>=0 && i>=jadfirststarttime1)	   
					   if(jadcurrent>0)
					           inteval=((filecountinformation[jaddatastartpoint1+1]["detailtime"]-filecountinformation[jaddatastartpoint1]["detailtime"])/60.0).round(0)					           
							   jadcurrent= jadcurrent-alldateinfo[jaddatastartpoint1]				   
					           jaddatacount[i+jadfirstadd]=jadcurrent
							   if(inteval!=1)
							         bbbb=1
							           while bbbb<inteval
									      jadfirstadd+=1
							              jaddatacount[i+jadfirstadd]=jadcurrent							                                   								  
								          bbbb+=1	                                       							  
							           end
							   end
					   else
					   jaddatacount[i+jadfirstadd]=0
					   end
					   jaddatastartpoint1+=1
                   else
					   jaddatacount[i+jadfirstadd]=0					   
                   end	
				end
                if(jadstarttime1!=nil) 					
                   if(i>=jadrollupstarttime && i<jadfirststarttime)
		               jaddatacount[i]=0
				elsif(i==jadfirststarttime)
					 jaddatacount[i]=jadcurrent1
				   elsif(jadcurrent1>=0 && i>jadfirststarttime && (jaddatastartpoint+1)<filecountinformation.length)	   
					   if(jadcurrent1>0)
					           inteval=((filecountinformation[jaddatastartpoint+1]["detailtime"]-filecountinformation[jaddatastartpoint]["detailtime"])/60.0).round(0)					           
							   jadcurrent1= jadcurrent1-alldateinfo[jaddatastartpoint]				   
					           jaddatacount[i+jadsecondadd]=jadcurrent1
							   if(inteval!=1)
							         bbbb=1
							           while bbbb<inteval
									      jadsecondadd+=1
							              jaddatacount[i+jadsecondadd]=jadcurrent1							                                   								  
								          bbbb+=1	                                       							  
							           end
							   end
					   else
					   jaddatacount[i+jadsecondadd]=0
					   end
					   jaddatastartpoint+=1			   				   				  	
                   end		
                 end
				   
         else
		     if(jadstarttime1!=nil) 	  
		       if(i>=jadrollupstarttime && i<jadfirststarttime)
		               jaddatacount[i]=0
					elsif(i==jadfirststarttime)
					    jaddatacount[i]=jadcurrent
					elsif(jadcurrent>=0 && i>jadfirststarttime)	   
					   if(jadcurrent>0)
					   jadcurrent= jadcurrent-alldateinfo[jaddatastartpoint]				   
					   jaddatacount[i]=jadcurrent
					   else
					   jaddatacount[i]=0
					   end
					   jaddatastartpoint+=1			   				   
				   else
					   jaddatacount[i]=0	
                   end
               else
			       jaddatacount[i]=0
			   end
			   
			   
			   if(zeostarttime1!=nil)
				   if(i>=zeorollupstarttime1 && i<zeofirststarttime1)
		               zeodatacount[i]=0
					elsif(i==zeofirststarttime1)
					   zeodatacount[i]=zeocurrent
					elsif(zeocurrent>=0 && i>zeofirststarttime1)	   
					   if(zeocurrent>0)
					   zeocurrent= zeocurrent-alldateinfo[zeodatastartpoint1]				   
					   zeodatacount[i]=zeocurrent
					   else
					   zeodatacount[i]=0
					   end
					   zeodatastartpoint1+=1
                   else
					   zeodatacount[i]=0					   
                   end	
				end
                if(zeostarttime1!=nil)				
                   if(i>=zeorollupstarttime && i<zeofirststarttime)
		               zeodatacount[i]=0
				   elsif(i==zeofirststarttime)	
                        zeodatacount[i]=zeocurrent1				   
				   elsif(zeocurrent1>=0 && i>zeofirststarttime)	   
					   if(zeocurrent1>0)
					   zeocurrent1= zeocurrent1-alldateinfo[zeodatastartpoint]				   
					   zeodatacount[i]=zeocurrent1
					   else
					   zeodatacount[i]=0
					   end
					   zeodatastartpoint+=1			   				   				  	
                   end
                 end				   
		 
		 end
		 
		 i+=1
		 end		 
			fileloadinghash["ZEO"]=zeodatacount
			fileloadinghash["EMR"]=emrdatacount
            fileloadinghash["JAD"]=jaddatacount
			testhash=Hash.new
			testhash["chart1"]=fileloadinghash
			
			charts2 = Hash.new()
		ds_category = Array.new() 
		jad_ds_count = Array.new() 
		jad_ds_category= Array.new() 
		emr_ds_count = Array.new() 
		emr_ds_category= Array.new() 
		zeo_ds_count = Array.new()
		zeo_ds_category= Array.new()
		date = "#{14.days.ago.strftime("%Y-%m-%d")}"
 		ds_category_all = FileLoadingInfor.find_by_sql("SELECT * FROM (SELECT  \"Data_Subject\",count(\"Data_Subject\") FROM file_loading_infors where \"File_Generated_TS\" > \'#{date}\' and  \"Server\" in(\'JAD\',\'EMR\',\'ZEO\') group by \"Data_Subject\")t where count >= 500;")
		jad_ds = FileLoadingInfor.find_by_sql("SELECT * FROM (SELECT  \"Data_Subject\",count(\"Data_Subject\") FROM file_loading_infors where  \"Server\"=\'JAD\' and \"File_Generated_TS\" > \'#{date}\' group by \"Data_Subject\")t where count >= 500;")
 		emr_ds = FileLoadingInfor.find_by_sql("SELECT * FROM (SELECT  \"Data_Subject\",count(\"Data_Subject\") FROM file_loading_infors where  \"Server\"=\'EMR\' and \"File_Generated_TS\" > \'#{date}\' group by \"Data_Subject\")t where count >= 500;")
		zeo_ds = FileLoadingInfor.find_by_sql("SELECT * FROM (SELECT  \"Data_Subject\",count(\"Data_Subject\") FROM file_loading_infors where  \"Server\"=\'ZEO\' and \"File_Generated_TS\" > \'#{date}\' group by \"Data_Subject\")t where count >= 500;")
  		#about category
 		ds_category_all.each do |f|
 			ds_category.push ( f.Data_Subject )
 		end
 		#about jad_ds
 		jad_ds.each do |f|
 			jad_ds_count.push ( f.count )
 		end
 		jad_ds.each do |f|
 			jad_ds_category.push ( ds_category.index(f.Data_Subject) )
 		end
 		jad_ds_count.each_with_index do |x,index|
 			jad_ds_count[index]=[ jad_ds_category[index],x,x]
 		end
 		#about zeo_ds
		zeo_ds.each do |f|
 			zeo_ds_count.push ( f.count )
 		end
 		zeo_ds.each do |f|
 			zeo_ds_category.push ( ds_category.index(f.Data_Subject) )
 		end
 		zeo_ds_count.each_with_index do |x,index|
 			zeo_ds_count[index]=[ zeo_ds_category[index],x,x]
 		end
  		#about emr_ds		
		emr_ds.each do |f|
 			emr_ds_count.push ( f.count )
 		end
		emr_ds.each do |f|
 			emr_ds_category.push ( ds_category.index(f.Data_Subject) )
 		end
 		emr_ds_count.each_with_index do |x,index|
 			emr_ds_count[index]=[ emr_ds_category[index],x,x]
 		end
 		charts2["category"] = ds_category
 		charts2["JAD"] = jad_ds_count
 		charts2["EMR"] = emr_ds_count
 		charts2["ZEO"] = zeo_ds_count
#####################################################################charts3
		charts3 = Hash.new()
		req_category = Array.new() 
		jad_req_count = Array.new() 
		jad_req_category= Array.new() 
		emr_req_count = Array.new() 
		emr_req_category= Array.new() 
		zeo_req_count = Array.new()
		zeo_req_category= Array.new() 
		req_category_all = FileLoadingInfor.find_by_sql("SELECT  \"Requestor\",count(\"Requestor\") FROM file_loading_infors where \"Requestor\"!=\'DIAL_CATALOGER\' and  \"Server\" in(\'JAD\',\'EMR\',\'ZEO\') group by \"Requestor\"")
		jad_req = FileLoadingInfor.find_by_sql("SELECT  \"Requestor\",count(\"Requestor\") FROM file_loading_infors where \"Server\"=\'JAD\' and \"Requestor\"!=\'DIAL_CATALOGER\' group by \"Requestor\"")
 		emr_req = FileLoadingInfor.find_by_sql("SELECT  \"Requestor\",count(\"Requestor\") FROM file_loading_infors where \"Server\"=\'EMR\' and \"Requestor\"!=\'DIAL_CATALOGER\' group by \"Requestor\"")
		zeo_req= FileLoadingInfor.find_by_sql("SELECT  \"Requestor\",count(\"Requestor\") FROM file_loading_infors where \"Server\"=\'ZEO\' and \"Requestor\"!=\'DIAL_CATALOGER\' group by \"Requestor\"")
		#about category
 		req_category_all.each do |f|
 			req_category.push ( f.Requestor )
 		end
 		#about jad_req
 		jad_req.each do |f|
 			jad_req_count.push ( f.count )
 		end
 		jad_req.each do |f|
 			jad_req_category.push ( req_category.index(f.Requestor) )
 		end
 		jad_req_count.each_with_index do |x,index|
 			jad_req_count[index]=[ jad_req_category[index],x,x]
 		end
 		#about zeo_req
		zeo_req.each do |f|
 			zeo_req_count.push ( f.count )
 		end
 		zeo_req.each do |f|
 			zeo_req_category.push ( req_category.index(f.Requestor) )
 		end
 		zeo_req_count.each_with_index do |x,index|
 			zeo_req_count[index]=[ zeo_req_category[index],x,x]
 		end
  		#about emr_req	
		emr_req.each do |f|
 			emr_req_count.push ( f.count )
 		end
		emr_req.each do |f|
 			emr_req_category.push ( req_category.index(f.Requestor) )
 		end
 		emr_req_count.each_with_index do |x,index|
 			emr_req_count[index]=[ emr_req_category[index],x,x]
 		end
 		charts3["category"] = req_category
 		charts3["JAD"] = jad_req_count
 		charts3["EMR"] = emr_req_count
 		charts3["ZEO"] = zeo_req_count
###################################################################################total
		
		
		testhash["chart2"]=charts2
		testhash["chart3"]=charts3
	
		
	    render json: testhash.to_json

end
end













