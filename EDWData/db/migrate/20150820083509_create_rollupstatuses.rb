class CreateRollupstatuses < ActiveRecord::Migration
  def change
    create_table :rollupstatuses do |t|
      t.string :BATCH_ID
      t.float :DURATION
      t.string :EVENT_ID
      t.string :MID
      t.string :SERVER
      t.string :EVENT_TYPE
      t.datetime :Start_TS
      t.datetime :End_TS
      t.string :DATA_SUBJ
      t.string :PORTFOLIO

      t.timestamps
    end
  end
end
