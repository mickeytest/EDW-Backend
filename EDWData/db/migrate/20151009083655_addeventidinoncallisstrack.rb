class Addeventidinoncallisstrack < ActiveRecord::Migration
  def change
  add_column("oncallissuetrackers","EventID","integer")
  end
end
