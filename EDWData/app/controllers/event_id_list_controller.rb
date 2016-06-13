class EventIdListController < ApplicationController
      def index	      
        eventlistinfor=Rollupstatus.find_by_sql(" SELECT distinct \"EVENT_ID\"
         FROM rollupstatuses ")
        i=0
		eventlist={}
		eventlist[:data]=[]
		while i<eventlistinfor.length
		eventlist[:data].push(eventlistinfor[i]["EVENT_ID"])
		i+=1
		end
	    render json:eventlist.to_json
	  end	  
end
