class Changerolluperror < ActiveRecord::Migration
  def change
  add_column("rolluperrorinformations","Duration","float")
  add_column("rolluperrorinformations","RollupDate","timestamp")
  end
end
