class CreateDailyTotalViews < ActiveRecord::Migration
  def self.up
    create_table :daily_total_views do |t|
      t.integer :total_views
      t.date :date

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_total_views
  end
end
