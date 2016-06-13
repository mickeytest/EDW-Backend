class DqtrendController < ApplicationController

	      
 def index
       dqcloseinfo=HpsmYotta.find_by_sql("select \"Open_Time_l\" as \"TTF\"  from  hpsm_dqs where \"Status\"='Closed'  order by \"Open_Time_l\"")
       
       everymonthdate=Dailyrolluptime.find_by_sql("
	     select * from (
  select \"Year\",\"Month\",max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars where \"Environment\"='ZEO'  group by \"Year\",\"Month\"  order by \"Year\",\"Month\" ) aaa
  where aaa.\"everymaxmonth\" >\'#{dqcloseinfo[0]["TTF"]}\'") 
  
  

	if(everymonthdate[0]["Month"]!=1)
               firstmonth=Dailyrolluptime.find_by_sql("
               select max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars where \"Year\"=\'#{everymonthdate[0]["Year"]}\'
               and \"Month\"=\'#{everymonthdate[0]["Month"]-1}\'") 
     else
               firstmonth=Dailyrolluptime.find_by_sql("
               select max(\"MECEndDate\") as \"everymaxmonth\" from mec_calendars where \"Year\"=\'#{everymonthdate[0]["Year"]-1}\'
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
        	
        closeticketinfo=Array.new(20,0)
		allticketinfo=Array.new(20,0)
		ticketbyssitinfo=Array.new(20,0)
		ticketbackloginfo=Array.new(20,0)
		  j=0	
	      i=0
		 while i< monthinfo.length-1 do
		       tttstart=(DateTime.parse((monthinfo[i]).strftime("%Y-%m-%d")+ ' 00:00:00')+1).strftime("%Y-%m-%d 00:00:00") 
		       tttend=  (DateTime.parse((monthinfo[i+1]).strftime("%Y-%m-%d")+ ' 00:00:00')).strftime("%Y-%m-%d 24:00:00") 
               dqcloseinfo=HpsmYotta.find_by_sql("select count(*) as \"countttf\"  from  hpsm_dqs where  \"Close_Time_l\">\'#{tttstart}}\'
 			   and \"Close_Time_l\"<=\'#{tttend}\' ")
               dqallinfo=HpsmYotta.find_by_sql("select count(*) as \"countttf\"  from  hpsm_dqs where  \"Open_Time_l\">\'#{tttstart}}\' and \"Open_Time_l\"<=\'#{tttend}\' ")
               dqticketbyssit=HpsmYotta.find_by_sql("select count(*) as \"countttf\"  from  hpsm_dqs where  \"Close_Time_l\">\'#{tttstart}}\' and \"Close_Time_l\"<=\'#{tttend}\' 
			      and \"Assignee\" not in ('patrick.sigourney@hpe.com', 
                 'dana.orr@hpe.com', 
                 'grace.chao@hpe.com', 
                 'annmarie.mcginley@hpe.com',
                 'patrick.sigourney@hp.com', 
                 'dana.orr@hp.com', 
                 'grace.chao@hp.com', 
                 'annmarie.mcginley@hp.com')")
			   dqticketbacklog=HpsmYotta.find_by_sql("select count(*) as \"countttf\"  from  hpsm_dqs where  \"Open_Time_l\">\'#{tttstart}}\' and \"Open_Time_l\"<=\'#{tttend}\'
                   and (\"Close_Time_l\">\'#{tttend}\'  or   \"Status\" <> 'Closed'  )")   
			   
			   closeticketinfo[j]=dqcloseinfo[0]["countttf"]
			   allticketinfo[j]=dqallinfo[0]["countttf"]
               ticketbyssitinfo[j]=dqticketbyssit[0]["countttf"]
                ticketbackloginfo[j]=dqticketbacklog[0]["countttf"]	   
			   i+=1
			   j+=1
		 end

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
           while i< slength
               monthdata[j]=(DateTime.parse(everymonthdate[i]["Year"].to_s + '-' + everymonthdate[i]["Month"].to_s + '-01')).strftime("%b,%Y")
               i+=1
               j+=1
           end
          dqtrend={}
		  dqtrend[:categories]=monthdata
		  
		  
		  ticketall={}
		  ticketall[:title]="New Ticket"	  		  
		  ticketall[:data]=[]
		  dqtrend[:NewTicket]=[]
		  dqtrend[:NewTicket].push(ticketall)
		  
		  ticketclose={}
		  ticketclose[:title]="Ticket Closed"	  		  
		  ticketclose[:data]=[]
		  dqtrend[:TicketClosed]=[]
		  dqtrend[:TicketClosed].push(ticketclose)
		  
		  
		  ticketbyssit={}
		  ticketbyssit[:title]="Ticket Closed by SSIT"	  		  
		  ticketbyssit[:data]=[]
	      dqtrend[:TicketClosedBySSIT]=[]
		  dqtrend[:TicketClosedBySSIT].push(ticketbyssit)

		  	  
          ticketbacklog={}
		  ticketbacklog[:title]="Ticket Backlog"	  		  
		  ticketbacklog[:data]=[]
		  dqtrend[:TicketBacklog]=[]
		  dqtrend[:TicketBacklog].push(ticketbacklog)
		  
		#  ticketbackloginfo[5]=38
		  i=0
          j=j-1
           while i<=j do
             ticketclose[:data].push([i,closeticketinfo[i]])
			 ticketall[:data].push([i,allticketinfo[i]])
			 ticketbacklog[:data].push([i,ticketbackloginfo[i]])
			 ticketbyssit[:data].push([i,ticketbyssitinfo[i],((ticketbyssitinfo[i]/closeticketinfo[i].to_f)*100).round(1)])
             i+=1
            end
			 
			 
		 render json:dqtrend.to_json
   end
    

end
