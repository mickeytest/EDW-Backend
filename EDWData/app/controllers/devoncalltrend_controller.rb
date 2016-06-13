class DevoncalltrendController < ApplicationController
  def index
	
   
   serverinfo=Array.new
   serverinfo[0]='ZEO'
   serverinfo[1]='EMR'
   serverinfo[2]='JAD'

   mecticket=Array.new(20,0)
   nonmecticket=Array.new(20,0)
   mectto=Array.new(20,0)
   nonmectto=Array.new(20,0)
   mecttf=Array.new(20,0)
   nonmecttf=Array.new(20,0)
   classnum=Array.new(20,0)
   
   
        devoncallhash=Hash.new
=begin		
   		  classificationinfo={}
		  classificationinfo[:title]="classify"	 
          classificationinfo[:data]=[]		  
		  devoncallhash[:classtrend]=[]
		  devoncallhash[:classtrend].push(classificationinfo)

	  
		  
		  devoncallhash[:classdilldowncategories]=[]
		  devoncallhash[:classdilldowndate]=[]
          assignedinfo=EdwOpsCallTracker.find_by_sql("select distinct \"Classification\" from edw_ops_call_trackers" )		
          
		 ddd=0
		  while ddd<assignedinfo.length do 
		      devoncallhash[:classdilldowncategories].push(assignedinfo[ddd]["Classification"])
			  ddd+=1
		  end
=end		
       jjj=0
          while jjj<serverinfo.length do
             everymonthdate=MecCalendar.find_by_sql("select \"Year\",\"Month\",max(\"MECEndDate_l\") as \"everymaxmonth\" from mec_calendars where \"Environment\"=\'#{serverinfo[jjj]}\' group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ") 
   devoncallinfo=Oncallissuetracker.find_by_sql("select \"Date_l\" ,\"TimetoFix\",\"Environment\",\"TimetoEngage\" from oncallissuetrackers 
   where  \"Environment\"=\'#{serverinfo[jjj]}\' and  \"Date_l\">\'#{everymonthdate[0]["everymaxmonth"]}\' order by \"Date_l\"")
    		  jjj+=1
            end
	
	i=0
  
   	if(everymonthdate[0]["Month"]!=1)
               firstmonth=MecCalendar.find_by_sql("
               select max(\"MECEndDate_l\") as \"everymaxmonth\" from mec_calendars where \"Year\"=\'#{everymonthdate[0]["Year"]}\'
               and \"Month\"=\'#{everymonthdate[0]["Month"]-1}\'") 
     else
               firstmonth=MecCalendar.find_by_sql("
               select max(\"MECEndDate_l\") as \"everymaxmonth\" from mec_calendars where \"Year\"=\'#{everymonthdate[0]["Year"]-1}\'
               and \"Month\"=12")
     end
     monthinfo=Array.new
	 
		i=1
		j=0
		if(firstmonth[0]["everymaxmonth"]==nil)
		i=0
		j=0
		else
		monthinfo[0]=firstmonth[0]["everymaxmonth"]		
		end
	
	    while j<everymonthdate.length do		     
              monthinfo[i]=everymonthdate[j]["everymaxmonth"]	
			  i+=1
			  j+=1
        end
		
   devoncallhash[:mecttocategories]=[]
   devoncallhash[:nonmecttocategories]=[]
   devoncallhash[:mecttfcategories]=[]
   devoncallhash[:nonmecttfcategories]=[]
   
   devoncallhash[:mecttodrilldown]=[]
   devoncallhash[:nonmecttodrilldown]=[]
   devoncallhash[:mecttfdrilldown]=[]
   devoncallhash[:nonmecttfdrilldown]=[]
   
   a=0
   j=0
   i=0
   _aa=0
   datadetailinfo=Array.new
    meccount=Array.new(20,0)
   nonmeccount=Array.new(20,0)
   while i< monthinfo.length-1 do
        oncallisstrackerinfo=Dailyrolluptime.find_by_sql("select \"Date_l\" ,\"TimetoFix\",\"Environment\",\"TimetoEngage\",\"MasterID\"   from oncallissuetrackers  where   \"Date_l\">\'#{monthinfo[i]}}\'
 			   and \"Date_l\"<=\'#{monthinfo[i+1]}\' ")
	 mecZEOinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{monthinfo[i]}}\' and \"MECStartDate_l\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='ZEO'")
	 mecEMRinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{monthinfo[i]}}\' and \"MECStartDate_l\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='EMR'")
     mecJADinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate_l\",\"MECEndDate_l\", \"Environment\" from mec_calendars where \"MECStartDate_l\">\'#{monthinfo[i]}}\' and \"MECStartDate_l\"<=\'#{monthinfo[i+1]}\' and \"Environment\"='JAD'")
     
	    opsinfo=EdwOpsCallTracker.find_by_sql("select * from(
(select distinct \"Classification\" from edw_ops_call_trackers) a  
left join (select  \"Classification\", count(*) as \"number\" from edw_ops_call_trackers where \"Complete_Date_l\">\'#{monthinfo[i]}\'  and  \"Complete_Date_l\"<=\'#{monthinfo[i+1]}\' group by \"Classification\" ) b  on a.\"Classification\"=b.\"Classification\") bbb
")
        classnum[j]=0
        datadetailinfo.push([])
        eee=0
		while eee<opsinfo.length do		     	
              datadetailinfo[j].push((opsinfo[eee]["number"]==nil ? nil :opsinfo[eee]["number"]))				  
			  classnum[j]+=(opsinfo[eee]["number"]==nil ? 0:opsinfo[eee]["number"])
		      eee+=1
		end
		 
		 devoncallhash[:mecttodrilldown].push([])
         devoncallhash[:nonmecttodrilldown].push([])
         devoncallhash[:mecttfdrilldown].push([])
         devoncallhash[:nonmecttfdrilldown].push([])
		 a=0
         while a<oncallisstrackerinfo.length do
		 
         if(oncallisstrackerinfo[a]["Environment"]=='ZEO')
				    tt=0
					ifmecornot=false
					while tt < mecZEOinfo.length do
			        if (ifmecornot==false && oncallisstrackerinfo[a]["Date_l"]>=mecZEOinfo[tt]["MECStartDate_l"]  &&  oncallisstrackerinfo[a]["Date_l"]<=mecZEOinfo[tt]["MECEndDate_l"])
						ifmecornot=true	
						meccount[j]+=1
						mecticket[j]=mecticket[j]+1	
                        if(oncallisstrackerinfo[a]["TimetoEngage"]<=3)	
						   mectto[j]+=1
                        else
						   if(!devoncallhash[:mecttocategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
						     devoncallhash[:mecttocategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
							 devoncallhash[:mecttodrilldown][j][devoncallhash[:mecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]
						   else						     
						     devoncallhash[:mecttodrilldown][j][devoncallhash[:mecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]
						   end
                        end						
                        if(oncallisstrackerinfo[a]["TimetoFix"]<=60)	
						   mecttf[j]+=1
                        else
						  p oncallisstrackerinfo[a]["MasterID"].to_s
						  p devoncallhash[:mecttfcategories]
						  if(!devoncallhash[:mecttfcategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
						   devoncallhash[:mecttfcategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
						   p "check question"
						   p devoncallhash[:mecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)
						   p devoncallhash[:mecttfdrilldown]
						   p j
						   devoncallhash[:mecttfdrilldown][j][devoncallhash[:mecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						  else
						   devoncallhash[:mecttfdrilldown][j][devoncallhash[:mecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						  end
                        end						
			            tt=mecZEOinfo.length
					end			        
					tt+=1					
			        end				    
                    if(ifmecornot==false)
					   nonmecticket[j]=nonmecticket[j]+1
                       if(oncallisstrackerinfo[a]["TimetoEngage"]<=10)	
						   nonmectto[j]+=1
                       else
					       if(!devoncallhash[:nonmecttocategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
					        devoncallhash[:nonmecttocategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
                            devoncallhash[:nonmecttodrilldown][j][devoncallhash[:nonmecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]							
                           else
						    devoncallhash[:nonmecttodrilldown][j][devoncallhash[:nonmecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]						
                           end						   
                       end					    	
                       if(oncallisstrackerinfo[a]["TimetoFix"]<=120)	
						   nonmecttf[j]+=1
                       else
					      if(!devoncallhash[:nonmecttfcategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
					        devoncallhash[:nonmecttfcategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
							devoncallhash[:nonmecttfdrilldown][j][devoncallhash[:nonmecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]		
						  else
						    devoncallhash[:nonmecttfdrilldown][j][devoncallhash[:nonmecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						  end
					   end
                       nonmeccount[j]+=1					   
					end					
		 elsif(oncallisstrackerinfo[a]["Environment"]=='EMR')
				    tt=0
					ifmecornot=false
					while tt < mecEMRinfo.length do
			       if (ifmecornot==false && oncallisstrackerinfo[a]["Date_l"]>=mecEMRinfo[tt]["MECStartDate_l"]  &&  oncallisstrackerinfo[a]["Date_l"]<=mecEMRinfo[tt]["MECEndDate_l"])
                        ifmecornot=true	
						meccount[j]+=1
						mecticket[j]=mecticket[j]+1	
                        if(oncallisstrackerinfo[a]["TimetoEngage"]<=3)	
						   mectto[j]+=1
                        else
						   if(!devoncallhash[:mecttocategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
						     devoncallhash[:mecttocategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
							 devoncallhash[:mecttodrilldown][j][devoncallhash[:mecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]			
						   else						     
						     devoncallhash[:mecttodrilldown][j][devoncallhash[:mecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]			
						   end
                        end		
                        if(oncallisstrackerinfo[a]["TimetoFix"]<=60)	
						   mecttf[j]+=1
                        else
						   if(!devoncallhash[:mecttfcategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
						   devoncallhash[:mecttfcategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
						   devoncallhash[:mecttfdrilldown][j][devoncallhash[:mecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						   else
						   devoncallhash[:mecttfdrilldown][j][devoncallhash[:mecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						   end
                        end							
			            tt=mecEMRinfo.length
					end			        
					tt+=1					
			        end
					if(ifmecornot==false)
					   nonmecticket[j]=nonmecticket[j]+1	 
					   if(oncallisstrackerinfo[a]["TimetoEngage"]<=10)	
						   nonmectto[j]+=1
                       else
					        if(!devoncallhash[:nonmecttocategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
					        devoncallhash[:nonmecttocategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
                            devoncallhash[:nonmecttodrilldown][j][devoncallhash[:nonmecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]					
                            else
						    devoncallhash[:nonmecttodrilldown][j][devoncallhash[:nonmecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]						
                            end		
                       end
					   if(oncallisstrackerinfo[a]["TimetoFix"]<=120)	
						   nonmecttf[j]+=1
                       else
					       if(!devoncallhash[:nonmecttfcategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
					        devoncallhash[:nonmecttfcategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
							devoncallhash[:nonmecttfdrilldown][j][devoncallhash[:nonmecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						   else
						    devoncallhash[:nonmecttfdrilldown][j][devoncallhash[:nonmecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						   end
					   end	
					   nonmeccount[j]+=1			
					end					
		 elsif(oncallisstrackerinfo[a]["Environment"]=='JAD')
				    tt=0
					ifmecornot=false
					while tt < mecJADinfo.length do
			        if (ifmecornot==false && oncallisstrackerinfo[a]["Date_l"]>=mecJADinfo[tt]["MECStartDate_l"]  &&  oncallisstrackerinfo[a]["Date_l"]<=mecJADinfo[tt]["MECEndDate_l"])
                        ifmecornot=true	
						meccount[j]+=1
						mecticket[j]=mecticket[j]+1	 
                        if(oncallisstrackerinfo[a]["TimetoEngage"]<=3)	
						   mectto[j]+=1
                        else
						   if(!devoncallhash[:mecttocategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
						     devoncallhash[:mecttocategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
							 devoncallhash[:mecttodrilldown][j][devoncallhash[:mecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]	
						   else						     
						     devoncallhash[:mecttodrilldown][j][devoncallhash[:mecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]	
						   end
                        end	
                        if(oncallisstrackerinfo[a]["TimetoFix"]<=60)	
						   mecttf[j]+=1
                        else
						   if(!devoncallhash[:mecttfcategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
						   devoncallhash[:mecttfcategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
						   devoncallhash[:mecttfdrilldown][j][devoncallhash[:mecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						   else
						   devoncallhash[:mecttfdrilldown][j][devoncallhash[:mecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						   end
                        end							
			            tt=mecJADinfo.length						
					end			        
					tt+=1					
			        end
					if(ifmecornot==false)
					   nonmecticket[j]=nonmecticket[j]+1	
                       if(oncallisstrackerinfo[a]["TimetoEngage"]<=10)	
						   nonmectto[j]+=1
                       else
					        if(!devoncallhash[:nonmecttocategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
					        devoncallhash[:nonmecttocategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
                            devoncallhash[:nonmecttodrilldown][j][devoncallhash[:nonmecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]			
                            else
						    devoncallhash[:nonmecttodrilldown][j][devoncallhash[:nonmecttocategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoEngage"]						
                            end		
                       end
                       if(oncallisstrackerinfo[a]["TimetoFix"]<=120)	
						   nonmecttf[j]+=1
                       else
					       if(!devoncallhash[:nonmecttfcategories].include?(oncallisstrackerinfo[a]["MasterID"].to_s))
					        devoncallhash[:nonmecttfcategories].push(oncallisstrackerinfo[a]["MasterID"].to_s)
							devoncallhash[:nonmecttfdrilldown][j][devoncallhash[:nonmecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						  else
						    devoncallhash[:nonmecttfdrilldown][j][devoncallhash[:nonmecttfcategories].index(oncallisstrackerinfo[a]["MasterID"].to_s)]=oncallisstrackerinfo[a]["TimetoFix"]
						  end
					   end
                       nonmeccount[j]+=1								   
					end						 
		 end
		 a+=1
		 end
	  i+=1
	  j+=1  
   end
         _tt=2
		 _zz=devoncallhash[:mecttodrilldown][devoncallhash[:mecttodrilldown].length-1].length
         while _tt<devoncallhash[:mecttodrilldown].length-1 do
		       everyitem=_zz-devoncallhash[:mecttodrilldown][_tt].length
			   currentitencount=devoncallhash[:mecttodrilldown][_tt].length
			   _yy=0
		       while _yy<everyitem do
			    devoncallhash[:mecttodrilldown][_tt][(currentitencount + _yy)]=nil
			    _yy+=1
			   end		   
		 _tt+=1
		 end
		 devoncallhash[:mecttodrilldown].delete_at(0)
		 devoncallhash[:mecttodrilldown].delete_at(0)
		 
		 _tt=2
		 _zz=devoncallhash[:mecttfdrilldown][devoncallhash[:mecttfdrilldown].length-1].length
         while _tt<devoncallhash[:mecttfdrilldown].length-1 do
		       everyitem=_zz-devoncallhash[:mecttfdrilldown][_tt].length
			   currentitencount=devoncallhash[:mecttfdrilldown][_tt].length
			   _yy=0
		       while _yy<everyitem do
			    devoncallhash[:mecttfdrilldown][_tt][(currentitencount + _yy)]=nil
			    _yy+=1
			   end		   
		 _tt+=1
		 end
		 devoncallhash[:mecttfdrilldown].delete_at(0)
		 devoncallhash[:mecttfdrilldown].delete_at(0)
		 
		 _tt=2
		 _zz=devoncallhash[:nonmecttodrilldown][devoncallhash[:nonmecttodrilldown].length-1].length
         while _tt<devoncallhash[:nonmecttodrilldown].length-1 do
		       everyitem=_zz-devoncallhash[:nonmecttodrilldown][_tt].length
			   currentitencount=devoncallhash[:nonmecttodrilldown][_tt].length
			   _yy=0
		       while _yy<everyitem do
			    devoncallhash[:nonmecttodrilldown][_tt][(currentitencount + _yy)]=nil
			    _yy+=1
			   end		   
		 _tt+=1
		 end
		 devoncallhash[:nonmecttodrilldown].delete_at(0)
		 devoncallhash[:nonmecttodrilldown].delete_at(0)
		 
		 _tt=2
		 _zz=devoncallhash[:nonmecttfdrilldown][devoncallhash[:nonmecttfdrilldown].length-1].length
         while _tt<devoncallhash[:nonmecttfdrilldown].length-1 do
		       everyitem=_zz-devoncallhash[:nonmecttfdrilldown][_tt].length
			   currentitencount=devoncallhash[:nonmecttfdrilldown][_tt].length
			   _yy=0
		       while _yy<everyitem do
			    devoncallhash[:nonmecttfdrilldown][_tt][(currentitencount + _yy)]=nil
			    _yy+=1
			   end		   
		 _tt+=1
		 end
		 devoncallhash[:nonmecttfdrilldown].delete_at(0)
		 devoncallhash[:nonmecttfdrilldown].delete_at(0)
		 
         if(Time.new <everymonthdate[everymonthdate.length-1]["everymaxmonth"])
		         slength= everymonthdate.length-1
		 else
		         slength= everymonthdate.length
		 end  
 

           monthdata=Array.new
		   if(firstmonth[0]["everymaxmonth"]==nil)
           i=1
		   else
		   i=0
		   end
           j=0
		   i=3
           while i< slength
               monthdata[j]=(DateTime.parse(everymonthdate[i]["Year"].to_s + '-' + everymonthdate[i]["Month"].to_s + '-01')).strftime("%b,%Y")
               i+=1
               j+=1
           end
  
          devoncallhash[:categories]=monthdata		  
		  mecticketinfo={}
		  mecticketinfo[:title]="MEC Ticket"	  		  
		  mecticketinfo[:data]=[]
		  devoncallhash[:TicketTrend]=[]
		  devoncallhash[:TicketTrend].push(mecticketinfo)
		  
		  nonmecticketinfo={}
		  nonmecticketinfo[:title]="Non-MEC Ticket"	  		  
		  nonmecticketinfo[:data]=[]
		  devoncallhash[:TicketTrend].push(nonmecticketinfo)
		  
		  
		  mecttoinfo={}
		  mecttoinfo[:title]="MEC TTO"	  		  
		  mecttoinfo[:data]=[]
		  devoncallhash[:TTOTrend]=[]
		  devoncallhash[:TTOTrend].push(mecttoinfo)
		  
		  
		  nonmecttoinfo={}
		  nonmecttoinfo[:title]="Non-MEC TTO"	  		  
		  nonmecttoinfo[:data]=[]
		  devoncallhash[:TTOTrend].push(nonmecttoinfo)
		  
		  
		  mecttfinfo={}
		  mecttfinfo[:title]="MEC TTF"	  		  
		  mecttfinfo[:data]=[]
		  devoncallhash[:TTFTrend]=[]
		  devoncallhash[:TTFTrend].push(mecttfinfo)
		  
		  
		  nonmecttfinfo={}
		  nonmecttfinfo[:title]="Non-MEC TTF"	  		  
		  nonmecttfinfo[:data]=[]
		  devoncallhash[:TTFTrend].push(nonmecttfinfo)
	
          i=0
          j=j-1
           while i<=j do
             mecticketinfo[:data].push([i,mecticket[i+2]])
			 nonmecticketinfo[:data].push([i,nonmecticket[i+2]])
			 mecttoinfo[:data].push([i,(meccount[i+2]==0 ? 0 : ((mectto[i+2]/(meccount[i+2]).to_f)*100).round(0))])
			 nonmecttoinfo[:data].push([i,(nonmeccount[i+2]==0 ? 0: ((nonmectto[i+2]/(nonmeccount[i+2]).to_f)*100).round(0))])
			 mecttfinfo[:data].push([i,(meccount[i+2]==0 ? 0 : ((mecttf[i+2]/(meccount[i+2]).to_f)*100).round(0))])
			 nonmecttfinfo[:data].push([i,(nonmeccount[i+2]==0 ? 0: ((nonmecttf[i+2]/(nonmeccount[i+2]).to_f)*100).round(0))])
			# classificationinfo[:data].push([i,classnum[i+2]])
			# devoncallhash[:classdilldowndate].push(datadetailinfo[i+2])
             i+=1
            end

render json:devoncallhash.to_json   	
		
  end
end
