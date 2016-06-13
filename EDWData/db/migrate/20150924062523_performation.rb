class Performation < ActiveRecord::Migration
  def change 
  add_column("rollup_performances","FileSize","float")
  add_column("rollup_performances","Environment","string")
  end
end
