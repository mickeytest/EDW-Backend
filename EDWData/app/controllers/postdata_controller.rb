class PostdataController < ApplicationController
 def index
     Dst.find_by_sql("INSERT INTO dsts(
            \"Environment\", \"ScheduledStartTime\", \"DST_TYPE\")
     VALUES (\'#{params[:Environment]}\','0001-01-01 09:00:00', 'xxx')")
 
     test={}
	 render json:test.to_json
 end

end
