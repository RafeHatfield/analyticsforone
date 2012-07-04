class AddIndexAndUniquenessContraintOnDate < ActiveRecord::Migration
  def self.up
    add_index :daily_total_views, :date, :unique => true
  end

  def self.down
    remove_index :daily_total_views, :date
  end
end
