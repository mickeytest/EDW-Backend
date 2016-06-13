class Delportfolio < ActiveRecord::Migration
  def change
  remove_column("rollupstatuses","PORTFOLIO")
  end
end
