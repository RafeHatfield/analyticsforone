class CreateDailyDomainViews < ActiveRecord::Migration
  using(:com, :de, :fr, :net) if SHARDING_ENABLED
  
  def self.up
    create_table :daily_domain_views do |t|
      t.date :date
      t.integer :article_id
      t.string :domain
      t.integer :count
      t.integer :writer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_domain_views
  end
end
