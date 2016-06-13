class CreateDailycriticalpaths < ActiveRecord::Migration
  def change
    create_table :dailycriticalpaths do |t|
      t.integer :DCPID
      t.datetime :RollupDate
      t.string :Server
      t.string :CriticalPath

      t.timestamps
    end
  end
end
