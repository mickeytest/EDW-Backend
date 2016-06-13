class CreateDialdumps < ActiveRecord::Migration
  def change
    create_table :dialdumps do |t|
      t.integer :DIALDumpID
      t.integer :MasterID
      t.string :ServerName
      t.string :ApplicationName

      t.timestamps
    end
  end
end
