class CreateDailylongrunningjobs < ActiveRecord::Migration
  def change
    create_table :dailylongrunningjobs do |t|
      t.integer :Id
      t.string :Server
      t.integer :MasterID
      t.string :Delay
      t.integer :BatchID
      t.datetime :Start_TS
      t.datetime :End_TS
      t.string :Real_Delay

      t.timestamps
    end
  end
end
