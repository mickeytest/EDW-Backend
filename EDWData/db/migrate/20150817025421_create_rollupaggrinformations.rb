class CreateRollupaggrinformations < ActiveRecord::Migration
  def change
    create_table :rollupaggrinformations do |t|
      t.integer :ID
      t.datetime :RollupDate
      t.float :MID
      t.integer :BatchID
      t.datetime :Average30days

      t.timestamps
    end
  end
end
