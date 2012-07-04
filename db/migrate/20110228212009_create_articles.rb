class CreateArticles < ActiveRecord::Migration
  using(:com, :de, :fr, :net) if SHARDING_ENABLED
  
  def self.up
    create_table :articles, :id => false do |t|
      t.integer :id, :options => 'PRIMARY KEY'
      t.string :title
      t.integer :writer_id
      t.string :permalink

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
