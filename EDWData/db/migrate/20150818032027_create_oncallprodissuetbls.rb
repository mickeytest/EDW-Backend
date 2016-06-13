class CreateOncallprodissuetbls < ActiveRecord::Migration
  def change
    create_table :oncallprodissuetbls do |t|
      t.integer :IssueID
      t.string :ApplicationName
      t.string :ServerName
      t.integer :JobID
      t.integer :MasterID
      t.string :JobName
      t.string :ErrorDescription
      t.datetime :IssueDate
      t.datetime :EngagementTime
      t.datetime :JobRecoveredTime
      t.string :TimeToFix
      t.string :RecoveryActDesc
      t.text :Attachments
      t.integer :HandledBy
      t.integer :RootCause
      t.string :ResolutionOwner
      t.string :ResolutionStatus
      t.datetime :ResolvedInProdDate
      t.string :EngagementTimeHrMn
      t.string :JobRecoveredTimeHrMn
      t.string :AttachmentName
      t.datetime :SubmitIssueTimeStamp
      t.datetime :WhenStartWorking
      t.string :AOContact
      t.string :AOReason
      t.string :TimeToEngage

      t.timestamps
    end
  end
end
