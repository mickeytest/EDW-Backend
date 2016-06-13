class CreateDailyrollupoffcycles < ActiveRecord::Migration
  def change
    create_table :dailyrollupoffcycles do |t|
      t.string :Server
      t.float :ElapseTime
      t.datetime :RollupDate
      t.datetime :Start_TS
      t.datetime :End_TS
      t.string :OffCycleType

      t.timestamps
    end
  end
end
