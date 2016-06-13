class CreatePortfolios < ActiveRecord::Migration
  def change
    create_table :portfolios do |t|
      t.integer :MasterID
      t.string :PORTFOLIO

      t.timestamps
    end
  end
end
