class Changeoncallissuetrackers1 < ActiveRecord::Migration
  def change
  add_column("oncallissuetrackers","TimetoReExec","integer")
  remove_column("oncallissuetrackers","add_column")
  end
end
