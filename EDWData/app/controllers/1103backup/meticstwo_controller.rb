class MeticstwoController < ApplicationController
      def index
	     privious90time=(DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - 90).strftime("%Y-%m-%d %H:%M:%S")
	     mecZEOinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">=\'#{privious90time}\' and \"Environment\"='ZEO'")
	     mecEMRinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">=\'#{privious90time}\' and \"Environment\"='EMR'")
		 mecJADinfo=MecCalendar.find_by_sql("select \"Month\",\"Year\",\"MECStartDate\",\"MECEndDate\", \"Environment\" from mec_calendars where \"MECStartDate\">=\'#{privious90time}\' and \"Environment\"='EMR'")
		 devoncallinfo=Oncallissuetracker.find_by_sql("select \"Date\" ,\"TimetoFix\",\"Environment\",\"TimetoEngage\" from oncallissuetrackers where \"Date\">=\'#{privious90time}\'")
		 maticstwo={
              "Yotta"=> {"TTO"=> 100,"TTF"=> 90,"AVG"=> 4},
              "Sequest"=> {"TTO"=> 33,"TTF"=> 4,"SystemAvil"=> 99},
              "DIAL"=> {"TTO"=> 33,"TTF"=> 4,"SystemAvil"=> 99},
              "DQ"=> {"TTF"=> 90,"TTFBFX"=> 90,"ESC"=>1,"TTFALM"=> 99,"DailyMeeting"=> 100,"MTP"=> 4},
              "CM"=> {"TTFMTPReview"=> 10,"TTFMTPSchedule"=> 10,"TTFBFX"=> 100,"AVGRFC"=> 20,"AVGBFX"=> 15},
              "DevOncall"=> {"TTOMEC"=> 0,"TTFMEC"=> 0,"TTONonMEC"=> 0,"TTFError"=> 0,"AVG"=> 0},
              "RMT"=> {"Error7"=> 60,"Error2"=> 95,"MTI"=> 90,"MTIReview"=> 90,"DataRefresh"=> 90,"MTDQR"=> 100,"AVGErrorDay"=> 12,"AVGMTIDay"=> 5,"AVGMTIReviewMonth"=> 10,"DataRefreshYear"=> 4},
              "OnBoarding"=> {"FileLoading1"=> 100,"FileFeedback2"=> 90,"Solution3"=> 100,"Maintenance24"=> 100,"AVGFilesMonth"=> 80,"AVGCasesMonth"=> 6,"AVGMaintenanceMonth"=> 1}
              }
		 i=0
		 nonmeccount=0
		 meccount=0
		 ifmecornot=FALSE
		 while i < devoncallinfo.length do		
            if(devoncallinfo[i]["TimetoEngage"]<120)
               maticstwo["DevOncall"]["TTFError"] += 1 
			end			
		    if(devoncallinfo[i]["Environment"]=="ZEO")
              j=0
			  while (ifmecornot==false)&&(j < mecJADinfo.length) do
			        if (devoncallinfo[i]["Date"]>=mecJADinfo[j]["MECStartDate"]  &&  devoncallinfo[i]["Date"]<=mecJADinfo[j]["MECEndDate"])
                     ifmecornot=true					
			        calengatetime("mec",devoncallinfo[i]["TimetoEngage"],maticstwo)
					meccount+=1
					if(devoncallinfo[i]["TimetoFix"]<60)
					      maticstwo["DevOncall"]["TTFMEC"] += 1 
					end
                    j=mecZEOinfo.length					
					end			        
					j+=1					
			  end  
			  if ifmecornot==false
			        calengatetime("nonmec",devoncallinfo[i]["TimetoEngage"],maticstwo)
                    nonmeccount+=1					
			  end
			  ifmecornot=false
			end
			if(devoncallinfo[i]["Environment"]=="EMR")
			  j=0
			  while (ifmecornot==false)&&(j < mecJADinfo.length) do
			        if (devoncallinfo[i]["Date"]>=mecJADinfo[j]["MECStartDate"]  &&  devoncallinfo[i]["Date"]<=mecJADinfo[j]["MECEndDate"])
					    ifmecornot=true
			           calengatetime("mec",devoncallinfo[i]["TimetoEngage"],maticstwo) 
					   meccount+=1
					   if(devoncallinfo[i]["TimetoFix"]<60)
					      maticstwo["DevOncall"]["TTFMEC"] += 1 
					   end
                       j=mecEMRinfo.length					   
					end
					j+=1
			  end
			  if ifmecornot==false
			           calengatetime("nonmec",devoncallinfo[i]["TimetoEngage"],maticstwo)
					   nonmeccount+=1
			  end
			  ifmecornot=false
			end
		    if(devoncallinfo[i]["Environment"]=="JAD")
			  j=0
			  while (ifmecornot==false)&&(j < mecJADinfo.length) do
			        if (devoncallinfo[i]["Date"]>=mecJADinfo[j]["MECStartDate"]  &&  devoncallinfo[i]["Date"]<=mecJADinfo[j]["MECEndDate"])
					ifmecornot=true
					calengatetime("mec",devoncallinfo[i]["TimetoEngage"],maticstwo)
					meccount+=1
                    if(devoncallinfo[i]["TimetoFix"]<60)
					      maticstwo["DevOncall"]["TTFMEC"] += 1 
					end					
					j=mecJADinfo.length
					end
					j+=1
			  end
			  if ifmecornot==false
			        calengatetime("nonmec",devoncallinfo[i]["TimetoEngage"],maticstwo) 
                    nonmeccount+=1					
			  end
			  ifmecornot=false
			  end
		    i+=1
		   end
		   maticstwo["DevOncall"]["TTOMEC"]=((maticstwo["DevOncall"]["TTOMEC"]/(meccount).to_f)*100).round(0)
		   maticstwo["DevOncall"]["TTFMEC"]=((maticstwo["DevOncall"]["TTFMEC"]/(meccount).to_f)*100).round(0)
		   maticstwo["DevOncall"]["TTONonMEC"]=((maticstwo["DevOncall"]["TTONonMEC"]/(nonmeccount).to_f)*100).round(0)
		   maticstwo["DevOncall"]["TTFError"]=((maticstwo["DevOncall"]["TTFError"]/(devoncallinfo.length).to_f)*100).round(0)
		   maticstwo["DevOncall"]["AVG"]=(((devoncallinfo.length).to_f)/3).round(0)
		  render json: maticstwo.to_json
	  end
	  
	   def  calengatetime(mecornot,duration,maticstwo)
	       if mecornot=="mec"
		      case                    
			  when duration<3                          then maticstwo["DevOncall"]["TTOMEC"] += 1
              end			  
		   else
		      case 
			  when duration<3                          then maticstwo["DevOncall"]["TTONonMEC"] += 1
		      end
		   end
	  end
end
