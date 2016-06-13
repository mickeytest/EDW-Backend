class CreateMecCalendars < ActiveRecord::Migration
  def change
    create_table :mec_calendars do |t|
      t.integer :Month
      t.integer :Year
      t.timestamp :MECStartDate
      t.timestamp :MECEndDate
      t.string :Environment

      t.timestamps
    end
  end
end
