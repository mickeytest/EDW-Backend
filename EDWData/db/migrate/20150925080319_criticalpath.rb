class Criticalpath < ActiveRecord::Migration
  def change
  add_column("criticalpathstatuses","level","integer")
  end
end
