class Addcriticalpathtag < ActiveRecord::Migration
  def change
  add_column("dailyrolluptimes","CriticalPathTag","integer")
  end
end
