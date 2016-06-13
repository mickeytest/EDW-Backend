require 'date'  
puts  (DateTime.parse((Time.new).strftime("%Y-%m-%d")+ ' 00:00:00') - (Time.new).strftime("%u").to_i ).strftime("%Y-%m-%d %H:%M:%S")


=begin
mecarray=Array.[](0,0,0)
nonmecarray=Array.new

rollupmetric=Hash.new
rollupmetric["MEC"]=mecarray	
rollupmetric["Non-MEC"]=nonmecarray

mecarray[2] =  8.83333333333333	
puts   mecarray[0]+8.83333333333333	


require 'time'
ts1 = new Timestamp('2015-09-29 12:13:14')
ts2 = new Timestamp('2015-09-29 12:13:13')
if ts1>ts2
   puts  'yes'
   end
 
test=Array.new
test[0]=1
test[3]=3
puts test[1]
puts test[2]
puts test[3]
if test[1]==nil
puts "yes"
end
puts test.length

require 'date'  
puts (DateTime.parse((Time.new).strftime("%Y-%m-%d"))).strftime("%Y/%m/%d")
puts (DateTime.parse((Time.new).strftime("%Y-%m-%d"))-30).strftime("%Y/%m/%d")


require 'date'  
t1='2015-08-21 12=>00=>00'
t2='2015-08-21 15=>00=>00'
puts DateTime.parse(t2)
puts DateTime.parse(t1)
puts ((DateTime.parse(t2)-DateTime.parse(t1))*24).to_int
puts DateTime.parse((Time.new).strftime("%Y/%m/%d")+ ' 12:00:00') - 3/24.0


test=[{"name"=> "OffIVC not started!","color"=> "#ABABAB","x"=>0,"data"=> [(DateTime.parse((Time.new).strftime("%Y/%m/%d")+ ' 01:00:00') - 3/24.0).strftime("%Y/%m/%d %H:%M:%S"),(Time.new).strftime("%Y/%m/%d")+ ' 01:00:00']}, 
 {"name"=> "OffFIN not started!","color"=> "#ABABAB","x"=>0,"data"=> [(DateTime.parse((Time.new).strftime("%Y/%m/%d")+ ' 01:00:00') - 3/24.0).strftime("%Y/%m/%d %H:%M:%S"),(Time.new).strftime("%Y/%m/%d")+ ' 01:00:00']},
 {"name"=> "Rollup not started!","color"=> "#ABABAB","x"=>0,"data"=> [(Time.new).strftime("%Y/%m/%d")+ ' 01:00:00',(Time.new).strftime("%Y/%m/%d")+ ' 09:30:00']},
 {"name"=> "OffIVC not started!","color"=> "#ABABAB","x"=>1,"data"=> [(Time.new).strftime("%Y/%m/%d")+ ' 05:00:00',(Time.new).strftime("%Y/%m/%d")+ ' 08:00:00']},
 {"name"=> "OffFIN not started!","color"=> "#ABABAB","x"=>1,"data"=> [(Time.new).strftime("%Y/%m/%d")+ ' 05:00:00',(Time.new).strftime("%Y/%m/%d")+ ' 08:00:00']},
 {"name"=> "Rollup not started!","color"=> "#ABABAB","x"=>1,"data"=> [(Time.new).strftime("%Y/%m/%d")+ ' 08:00:00',(Time.new).strftime("%Y/%m/%d")+ ' 18:30:00']},
 {"name"=> "OffIVC not started!","color"=> "#ABABAB","x"=>2,"data"=> [(Time.new).strftime("%Y/%m/%d")+ ' 16:00:00',(Time.new).strftime("%Y/%m/%d")+ ' 19:00:00']},
 {"name"=> "OffFIN not started!","color"=> "#ABABAB","x"=>2,"data"=> [(Time.new).strftime("%Y/%m/%d")+ ' 16:00:00',(Time.new).strftime("%Y/%m/%d")+ ' 19:00:00']},
 {"name"=> "Rollup not started!","color"=> "#ABABAB","x"=>2,"data"=> [(Time.new).strftime("%Y/%m/%d")+ ' 19:00:00',(DateTime.parse((Time.new).strftime("%Y/%m/%d")+ ' 19:00:00') + 8.5/24.0).strftime("%Y/%m/%d %H:%M:%S")]}]

 puts test[8]["data"]
 
 puts 1.0.class
puts 1.2e3.class
puts 1.2e3
puts 1.2*1.2*1.2
puts 10e3

puts "The seconds in a day is: #{24*60*60}"
puts 'The seconds in a day is: #{24*60*60}'
=end