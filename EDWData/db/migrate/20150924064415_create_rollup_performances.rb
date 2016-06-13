class CreateRollupPerformances < ActiveRecord::Migration
  def change
    create_table :rollup_performances do |t|
      t.timestamp :RollupDate
      t.timestamp :Start_TS
      t.timestamp :End_TS
      t.float :ElapseTime
      t.integer :DiskIOTotal
      t.integer :CPUBusySecs
      t.integer :MemAllocMb
      t.integer :MemUsedMb
      t.string :RowsRetrievedTotal
      t.float :DiskIONorm
      t.float :CPUBusyNorm
      t.float :MemAllocNorm
      t.float :MemUsedNorm
      t.string :RowsAccessedNorm
      t.string :RowsIUDNorm
      t.float :RowsRetrievedNorm
      t.string :RowsAccessed
      t.string :RowsIUDTotal
      t.float :FileSize
      t.string :Environment

      t.timestamps
    end
  end
end
