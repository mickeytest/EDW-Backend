class Changebatch < ActiveRecord::Migration
  def change
      remove_column("rolluperrorinformations","BatchID")
	  add_column("rolluperrorinformations","BatchID","string")
  end
end
