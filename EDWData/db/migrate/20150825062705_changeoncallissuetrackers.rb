class Changeoncallissuetrackers < ActiveRecord::Migration
  def change 
  add_column("oncallissuetrackers","TimetoReExec","integer")
  end
end
