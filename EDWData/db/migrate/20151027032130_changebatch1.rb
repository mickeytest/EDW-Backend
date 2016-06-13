class Changebatch1 < ActiveRecord::Migration
  def change
      remove_column("criticalpathstatuses","BatchID")
	  add_column("criticalpathstatuses","BatchID","string")
  end
end
