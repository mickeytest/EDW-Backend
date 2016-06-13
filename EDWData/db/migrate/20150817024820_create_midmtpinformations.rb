class CreateMidmtpinformations < ActiveRecord::Migration
  def change
    create_table :midmtpinformations do |t|
      t.integer :ID
      t.float :MID
      t.string :Server
      t.datetime :LastMTPDate

      t.timestamps
    end
  end
end
