class Changeerrorinformation < ActiveRecord::Migration
  def change
  remove_column("rolluperrorinformations","ID")
  end
end
