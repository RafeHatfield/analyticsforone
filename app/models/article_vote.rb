# == Schema Information
# Schema version: 20110519222312
#
# Table name: article_votes
#
#  id         :integer         not null, primary key
#  article_id :integer
#  date       :date
#  note       :text
#  vote       :boolean
#  writer_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class ArticleVote < ActiveRecord::Base
  attr_accessible :article_id, :date, :note, :vote, :writer_id
  
  validates_presence_of :article_id
  
  scope :for_writer, lambda {|writer_id| where(:writer_id => writer_id) }
  scope :between, lambda {|start_date, end_date| where(:date => start_date.to_date...(end_date.to_date + 1.day)) }
  
  belongs_to :article 
  
  def self.article_votes_for_writer_between(writer_id, start_date, end_date, limit, offset)
    
    article_votes = ArticleVote.
      for_writer(writer_id).
      between(start_date, end_date).
      joins(:article).
      limit(limit).
      offset(offset).
      select("title").
      group("title").
      order("title")
      
    helpful = article_votes.
      where(:vote => true).
      count()
    
    not_helpful = article_votes.
      where(:vote => false).
      count()
    
    article_votes.map do |av|
      {
        :title => av.title,
        :helpful => helpful[av.title] || 0,
        :not_helpful => not_helpful[av.title] || 0
      }
    end

  end
    
  def self.votes_for_article_between(article_id, start_date, end_date)
    helpful = ArticleVote.
      where(:article_id => article_id).
      between(start_date, end_date).
      where(:vote => true).
      count()
      
    not_helpful = ArticleVote.
      where(:article_id => article_id).
      between(start_date, end_date).
      where(:vote => false).
      count()
      
    {:helpful => helpful, :not_helpful => not_helpful}
  end
  
private

  def self.votes_detail_for_article(votes, aid)
    article_vote = votes.find{|v| v.article_id == aid}
    up_vote_count = votes.count{|v| (v.article_id == aid) && v.vote == true}
    down_vote_count = votes.count{|v| (v.article_id == aid) && v.vote == false}
    {:id => article_vote.article_id, :title => article_vote.title, :permalink => article_vote.permalink, :up_votes_count => up_vote_count, :down_votes_count => down_vote_count, :note => article_vote.note}
  end
  
  def self.merge_add(h1, h2)
    h1.merge(h2){ |key, first, second| first.merge(second) }
  end
  
end
