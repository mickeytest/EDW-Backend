class Changerollperformance1 < ActiveRecord::Migration
  def change
    remove_column("rollup_performances","RowsIUDTotal") 
  add_column("rollup_performances","RowsIUDTotal","string") 
  end
end
