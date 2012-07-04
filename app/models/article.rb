# == Schema Information
# Schema version: 20110519222312
#
# Table name: articles
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  writer_id  :integer
#  permalink  :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Article < ActiveRecord::Base

  has_many :daily_page_views, :dependent => :destroy
  has_many :daily_keyphrase_views, :dependent => :destroy
  has_many :daily_domain_views, :dependent => :destroy
  has_many :article_votes, :dependent => :destroy

  validates_presence_of :id, :title, :writer_id, :permalink
  validates_uniqueness_of :id
	
  def self.find_and_update_or_create(data)
    id = data[:id]

    if Article.exists?(id)
      article = Article.find(id)
      article.update_attribute(:title, data[:title]) if data[:title].present?
      article.update_attribute(:permalink, data[:permalink]) if data[:permalink].present?
      return article
    else
      Article.create!(:title => data[:title], :writer_id => data[:writer_id], :permalink => data[:permalink]){|a| a.id = id}
    end
  end
  
  def increment_page_view_on(date)
    date = date.to_date
    
    daily_page_view = self.daily_page_views.find_by_date(date)
    if daily_page_view
      daily_page_view.increment!(:count)
      return daily_page_view
    else
      self.daily_page_views.create!(:date => date, :writer_id => self.writer_id, :count => 1)
    end
  end
  
  def increment_keyphrase_view_on(date,keyphrase)
    date = date.to_date
    
    daily_keyphrase_view = self.daily_keyphrase_views.find_by_date_and_keyphrase(date, keyphrase)
    if daily_keyphrase_view
      daily_keyphrase_view.increment!(:count)
      return daily_keyphrase_view
    else
      self.daily_keyphrase_views.create!(:date => date, :writer_id => self.writer_id, :keyphrase => keyphrase, :count => 1)
    end
  end
  
  def increment_domain_view_on(date, domain)
    date = date.to_date
    
    daily_domain_view = self.daily_domain_views.find_by_date_and_domain(date, domain)
    if daily_domain_view
      daily_domain_view.increment!(:count)
      return daily_domain_view
    else
      self.daily_domain_views.create!(:date => date, :writer_id => self.writer_id, :domain => domain, :count => 1)
    end
  end
  
  def count_between(start_date, end_date)
    self.daily_page_views.between(start_date, end_date).sum("count")
  end


end
