class CreateOncallissuetrackers < ActiveRecord::Migration
  def change
    create_table :oncallissuetrackers do |t|
      t.string :Status
      t.integer :MasterID
      t.integer :BatchID
      t.string :Subject
      t.string :Action
      t.string :EscalatetoDevteam
      t.string :Owner
      t.string :Environment
      t.string :Domain
      t.string :RootCause
      t.text :ErrorDetails
      t.datetime :Date
      t.datetime :TimeFailure
      t.datetime :TimeSucceeded
      t.integer :TimetoEngage
      t.integer :TimetoFix
      t.integer :Time_that_AO_called_oncall
      t.integer :Time_that_AO_emailed_oncall
      t.integer :TimetoReExec
      t.string :InCriticalPath
      t.string :Expected_MTD
      t.string :Expected_MTI
      t.string :Expected_MTP
      t.string :Actual_MTD
      t.string :Actual_MTI
      t.string :Actual_MTP
      t.string :Instance_Owner
      t.string :Notes
      t.string :ApplicationName
      t.datetime :EngagementTime
      t.string :RecoveryActDesc
      t.text :Attachments
      t.string :ResolutionOwner
      t.string :ResolutionStatus
      t.datetime :ResolvedInProdDate
      t.string :AttachmentName
      t.datetime :SubmitIssueTimeStamp
      t.datetime :WhenStartWorking
      t.string :AOContact
      t.string :AOReason
      t.string :EngagementTimeHrMn
      t.string :JobRecoveredTimeHrMn
      t.datetime :TimeToEngage_TS
      t.datetime :Time_that_AO_emailed_Oncall_TS

      t.timestamps
    end
  end
end
