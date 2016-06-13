class Rollupstatusadd30avedaystimes < ActiveRecord::Migration
  def change
  add_column("rollupstatuses","Avg30DaysTime","float")
  end
end
