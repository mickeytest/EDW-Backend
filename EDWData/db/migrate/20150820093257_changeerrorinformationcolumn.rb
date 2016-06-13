class Changeerrorinformationcolumn < ActiveRecord::Migration
  def change
    change_column("rolluperrorinformations","ErrorInformation","text")
  end
end
