class ChangeerrorinformationMid < ActiveRecord::Migration
  def change
  change_column("rolluperrorinformations","MID","string")
  end
end
