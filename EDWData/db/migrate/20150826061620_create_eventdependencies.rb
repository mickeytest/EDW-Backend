class CreateEventdependencies < ActiveRecord::Migration
  def change
    create_table :eventdependencies do |t|
      t.string :Server
      t.string :PREC_EVENT_ID
      t.string :SUCC_EVENT_ID

      t.timestamps
    end
  end
end
