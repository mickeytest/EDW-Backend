class Removesystemissueflag < ActiveRecord::Migration
  def change
    remove_column("oncallissuetrackers","SystemIssueFlag")
  end
end
