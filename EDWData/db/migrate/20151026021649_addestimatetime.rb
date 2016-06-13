class Addestimatetime < ActiveRecord::Migration
  def change
  add_column("dailyrolluptimes","Estimated_End_TS","timestamp") 
  end
end
