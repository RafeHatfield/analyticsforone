class AddUniquenessConstraintOnArticles < ActiveRecord::Migration
  using(:com, :de, :fr, :net) if SHARDING_ENABLED
  
  def self.up
    execute "ALTER TABLE articles ADD CONSTRAINT uniq_article_check UNIQUE (id);"
  end

  def self.down
  end
end
