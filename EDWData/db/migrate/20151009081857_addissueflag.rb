class Addissueflag < ActiveRecord::Migration
  def change
  add_column("rolluperrorinformations","SystemIssueFlag","string")
  add_column("oncallissuetrackers","SystemIssueFlag","string")
  end
end
