class CreateDailyrolluptimes < ActiveRecord::Migration
  def change
    create_table :dailyrolluptimes do |t|
      t.integer :DailyRollupTimeID
      t.string :Server
      t.float :ElapseTime
      t.datetime :RollupDate
      t.datetime :Start_TS
      t.datetime :End_TS

      t.timestamps
    end
  end
end
