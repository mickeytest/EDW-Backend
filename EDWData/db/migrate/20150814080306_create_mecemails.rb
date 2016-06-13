class CreateMecemails < ActiveRecord::Migration
  def change
    create_table :mecemails do |t|
    t.integer  "MECEmailID"
	t.string   "SendEmailTo"
	t.string   "Environment"
	t.string   "WorkDay"
	t.string   "SLAMet"
	t.string   "RollupTime"
    t.string   "Notes"	
	t.datetime "FromDate"
	t.datetime "ToDate"
	t.string   "DraftString"
	t.string   "IssueIDs"
    end
  end
end
