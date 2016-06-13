class Delete30dayavetime < ActiveRecord::Migration
  def change
      remove_column("rollupstatuses","Avg30DaysTime")
  end
end
