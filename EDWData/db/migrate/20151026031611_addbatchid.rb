class Addbatchid < ActiveRecord::Migration
  def change
  add_column("criticalpathstatuses","BatchID","integer") 
  end
end
