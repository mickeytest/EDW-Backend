class CreateDialbatchiddumps < ActiveRecord::Migration
  def change
    create_table :dialbatchiddumps do |t|
      t.integer :BatchImportID
      t.integer :BatchID

      t.timestamps
    end
  end
end
