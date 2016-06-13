$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../config'

require 'db'

module EDWFactCaculate
	class Yottaplatform
		def get_data
			# Check wheter there is new data first, if yes, begin to fetch the data and inser the new data
			
			sql = %Q[
				select count(*) as COUNTA from dailyrolluptimes group by "Server"
			]

			EDWDriver.fetch(sql) do |row|
			  puts row[:counta]
			end

			sql = %Q[
				INSERT INTO fact_test(
			            "Type", "Value", "MECMonth")
			    VALUES (?,?,?)
			]

			insert_ds = EDWDriver[sql, 'Ticket in HPSM',2,'2016-02-01']

			insert_ds.insert
		end
	end
end


 


