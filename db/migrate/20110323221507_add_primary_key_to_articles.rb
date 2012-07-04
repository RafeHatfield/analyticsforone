class AddPrimaryKeyToArticles < ActiveRecord::Migration
  using(:com, :de, :fr, :net) if SHARDING_ENABLED
  
  def self.up
    execute "ALTER TABLE articles ADD PRIMARY KEY (id);"
  end

  def self.down
  end
end
