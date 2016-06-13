class RemoveDailyRollupTimeIdToDailyrolluotimes < ActiveRecord::Migration
  def up
  remove_column("dailyrolluptimes","DailyRollupTimeID")  
  end
end
