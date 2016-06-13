class CreateRolluperrorinformations < ActiveRecord::Migration
  def change
    create_table :rolluperrorinformations do |t|
      t.integer :ID
      t.float :MID
      t.string :Server
      t.string :ErrorCode
      t.string :ErrorInformation

      t.timestamps
    end
  end
end
