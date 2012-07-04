class CreateDailyKeyphraseViews < ActiveRecord::Migration
  using(:com, :de, :fr, :net) if SHARDING_ENABLED
  
  def self.up
    create_table :daily_keyphrase_views do |t|
      t.date :date
      t.integer :article_id
      t.string :keyphrase
      t.integer :count
      t.integer :writer_id

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_keyphrase_views
  end
end
