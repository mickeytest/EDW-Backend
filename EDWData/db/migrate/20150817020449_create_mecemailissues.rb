class CreateMecemailissues < ActiveRecord::Migration
  def change
    create_table :mecemailissues do |t|
      t.integer :MECEMailIssue
      t.integer :TrackID
      t.integer :MECEmailID

      t.timestamps
    end
  end
end
