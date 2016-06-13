# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151111062555) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "criticalpathstatuses", force: true do |t|
    t.string   "MID"
    t.string   "Server"
    t.datetime "RollupDate"
    t.float    "EST"
    t.float    "EET"
    t.float    "LST"
    t.float    "LET"
    t.float    "Slack"
    t.integer  "level"
    t.string   "BatchID"
  end

  add_index "criticalpathstatuses", ["RollupDate"], name: "criticalpathstatuses_RollupDate_idx", using: :btree

  create_table "dailycriticalpaths", force: true do |t|
    t.integer  "DCPID"
    t.datetime "RollupDate"
    t.string   "Server"
    t.string   "CriticalPath"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dailylongrunningjobs", force: true do |t|
    t.integer  "Id"
    t.string   "Server"
    t.integer  "MasterID"
    t.string   "Delay"
    t.integer  "BatchID"
    t.datetime "Start_TS"
    t.datetime "End_TS"
    t.string   "Real_Delay"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dailyrollupoffcycles", id: false, force: true do |t|
    t.string   "Server"
    t.float    "ElapseTime"
    t.datetime "RollupDate"
    t.datetime "Start_TS"
    t.datetime "End_TS"
    t.string   "OffCycleType"
  end

  create_table "dailyrolluptimes", id: false, force: true do |t|
    t.string   "Server"
    t.float    "ElapseTime"
    t.datetime "RollupDate"
    t.datetime "Start_TS"
    t.datetime "End_TS"
    t.integer  "CriticalPathTag"
    t.datetime "Estimated_End_TS"
  end

  create_table "dialbatchiddumps", force: true do |t|
    t.integer  "BatchImportID"
    t.integer  "BatchID"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dialdumps", force: true do |t|
    t.integer  "DIALDumpID"
    t.integer  "MasterID"
    t.string   "ServerName"
    t.string   "ApplicationName"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "eventdependencies", id: false, force: true do |t|
    t.string "Server"
    t.string "PREC_EVENT_ID"
    t.string "SUCC_EVENT_ID"
    t.string "EVENT_DEPENDENCY_TP_CD"
  end

  create_table "file_loading_infors", force: true do |t|
    t.string   "Load_Job_Nr"
    t.string   "File_Name"
    t.string   "Requestor"
    t.datetime "Load_Start_TS"
    t.datetime "Load_End_TS"
    t.string   "Source_System_Key"
    t.string   "Data_Subject"
    t.datetime "File_Generated_TS"
    t.string   "Request_ID"
    t.string   "Request_TP"
    t.string   "Source_Loc_CD"
    t.datetime "Complition_TS"
    t.string   "Complition_Status"
    t.datetime "Requested_TS"
  end

  create_table "file_rollup_infors", force: true do |t|
    t.string   "Batch_ID"
    t.integer  "Master_ID"
    t.string   "Error_Code"
    t.string   "Error_Infor"
    t.string   "Load_Job_NR"
    t.datetime "UPD_GMT_TS"
  end

  create_table "mec_calendars", id: false, force: true do |t|
    t.integer  "Month"
    t.integer  "Year"
    t.datetime "MECStartDate"
    t.datetime "MECEndDate"
    t.string   "Environment"
  end

  create_table "mecemailissues", force: true do |t|
    t.integer  "MECEMailIssue"
    t.integer  "TrackID"
    t.integer  "MECEmailID"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mecemails", force: true do |t|
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

  create_table "midmtpinformations", force: true do |t|
    t.integer  "ID"
    t.float    "MID"
    t.string   "Server"
    t.datetime "LastMTPDate"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oncallissuetrackers", id: false, force: true do |t|
    t.string   "Status"
    t.integer  "MasterID"
    t.integer  "BatchID"
    t.string   "Subject"
    t.string   "Action"
    t.string   "EscalatetoDevteam"
    t.string   "Owner"
    t.string   "Environment"
    t.string   "Domain"
    t.string   "RootCause"
    t.text     "ErrorDetails"
    t.datetime "Date"
    t.datetime "TimeFailure"
    t.datetime "TimeSucceeded"
    t.integer  "TimetoEngage"
    t.integer  "TimetoFix"
    t.integer  "Time_that_AO_called_oncall"
    t.integer  "Time_that_AO_emailed_oncall"
    t.integer  "TimetoReExec"
    t.string   "InCriticalPath"
    t.string   "Expected_MTD"
    t.string   "Expected_MTI"
    t.string   "Expected_MTP"
    t.string   "Actual_MTD"
    t.string   "Actual_MTI"
    t.string   "Actual_MTP"
    t.string   "Instance_Owner"
    t.string   "Notes"
    t.string   "ApplicationName"
    t.datetime "EngagementTime"
    t.string   "RecoveryActDesc"
    t.text     "Attachments"
    t.string   "ResolutionOwner"
    t.string   "ResolutionStatus"
    t.datetime "ResolvedInProdDate"
    t.string   "AttachmentName"
    t.datetime "SubmitIssueTimeStamp"
    t.datetime "WhenStartWorking"
    t.string   "AOContact"
    t.string   "AOReason"
    t.string   "EngagementTimeHrMn"
    t.string   "JobRecoveredTimeHrMn"
    t.datetime "TimeToEngage_TS"
    t.datetime "Time_that_AO_emailed_Oncall_TS"
    t.integer  "EventID"
  end

  create_table "oncallprodissuetbls", force: true do |t|
    t.integer  "IssueID"
    t.string   "ApplicationName"
    t.string   "ServerName"
    t.integer  "JobID"
    t.integer  "MasterID"
    t.string   "JobName"
    t.string   "ErrorDescription"
    t.datetime "IssueDate"
    t.datetime "EngagementTime"
    t.datetime "JobRecoveredTime"
    t.string   "TimeToFix"
    t.string   "RecoveryActDesc"
    t.text     "Attachments"
    t.integer  "HandledBy"
    t.integer  "RootCause"
    t.string   "ResolutionOwner"
    t.string   "ResolutionStatus"
    t.datetime "ResolvedInProdDate"
    t.string   "EngagementTimeHrMn"
    t.string   "JobRecoveredTimeHrMn"
    t.string   "AttachmentName"
    t.datetime "SubmitIssueTimeStamp"
    t.datetime "WhenStartWorking"
    t.string   "AOContact"
    t.string   "AOReason"
    t.string   "TimeToEngage"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "portfolios", id: false, force: true do |t|
    t.integer "MasterID"
    t.string  "PORTFOLIO"
  end

  create_table "rollup_performances", id: false, force: true do |t|
    t.datetime "RollupDate"
    t.datetime "Start_TS"
    t.datetime "End_TS"
    t.float    "ElapseTime"
    t.integer  "DiskIOTotal"
    t.integer  "CPUBusySecs"
    t.integer  "MemAllocMb"
    t.integer  "MemUsedMb"
    t.string   "RowsRetrievedTotal"
    t.float    "DiskIONorm"
    t.float    "CPUBusyNorm"
    t.float    "MemAllocNorm"
    t.float    "MemUsedNorm"
    t.string   "RowsAccessedNorm"
    t.string   "RowsIUDNorm"
    t.float    "RowsRetrievedNorm"
    t.string   "RowsAccessed"
    t.string   "RowsIUDTotal"
    t.float    "FileSize"
    t.string   "Environment"
  end

  create_table "rollup_performances_details", force: true do |t|
    t.datetime "RollupDate"
    t.integer  "Hours"
    t.integer  "MemAllocMb"
    t.integer  "DiskIOTotal"
    t.integer  "CPUBusySecs"
    t.string   "RowsIUDTotal"
    t.string   "RowsAccessed"
    t.float    "ElapseTime"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rollupaggrinformations", force: true do |t|
    t.integer  "ID"
    t.datetime "RollupDate"
    t.float    "MID"
    t.integer  "BatchID"
    t.datetime "Average30days"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rolluperrorinformations", id: false, force: true do |t|
    t.string   "MID"
    t.string   "Server"
    t.string   "ErrorCode"
    t.text     "ErrorInformation"
    t.string   "SystemIssueFlag"
    t.float    "Duration"
    t.datetime "RollupDate"
    t.integer  "BatchID"
  end

  add_index "rolluperrorinformations", ["RollupDate"], name: "rolluperrorinformations_RollupDate_idx", using: :btree

  create_table "rolluprowaffecteds", force: true do |t|
    t.integer  "ID"
    t.datetime "RollupDate"
    t.float    "MID"
    t.integer  "BatchID"
    t.integer  "Row_Attected"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rollupstatuses", id: false, force: true do |t|
    t.string   "BATCH_ID"
    t.float    "DURATION"
    t.string   "EVENT_ID"
    t.string   "MID"
    t.string   "SERVER"
    t.string   "EVENT_TYPE"
    t.datetime "Start_TS"
    t.datetime "End_TS"
    t.string   "DATA_SUBJ"
  end

  add_index "rollupstatuses", ["Start_TS"], name: "rollupstatuses_Start_TS_idx", using: :btree

  create_table "src_sys_infors", force: true do |t|
    t.string "Source_System_Key"
    t.string "Source_System_Name"
    t.string "Data_Subject"
    t.string "Portfolio"
    t.string "Lz_Table"
    t.string "Key_Source_System_Flag"
  end

end
