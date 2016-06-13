class CreateCriticalpathstatuses < ActiveRecord::Migration
  def change
    create_table :criticalpathstatuses do |t|
      t.string :MID
      t.string :Server
      t.datetime :RollupDate
      t.float :EST
      t.float :EET
      t.float :LST
      t.float :LET
      t.float :Slack

      t.timestamps
    end
  end
end
