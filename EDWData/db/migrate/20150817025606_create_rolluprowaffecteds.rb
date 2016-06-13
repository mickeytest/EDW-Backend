class CreateRolluprowaffecteds < ActiveRecord::Migration
  def change
    create_table :rolluprowaffecteds do |t|
      t.integer :ID
      t.datetime :RollupDate
      t.float :MID
      t.integer :BatchID
      t.integer :Row_Attected

      t.timestamps
    end
  end
end
