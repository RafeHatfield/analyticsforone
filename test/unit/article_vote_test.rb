require 'test_helper'

class ArticleVoteTest < ActiveSupport::TestCase
  context "Voting for an article" do
    
    setup do
      @article = FactoryGirl.create(:article)
    end
    
    should "return votes count for an article" do
      date = '2011-05-24'
      @article_vote = FactoryGirl.create(:article_vote, :vote => false, :date =>date)
      @article_vote = FactoryGirl.create(:article_vote, :vote => true, :date =>date)
      @article_vote = FactoryGirl.create(:article_vote, :vote => true, :date =>date)
      
      assert_equal 2, ArticleVote.vote_counts_for_article_between(1, date, date, 0, 10)
      assert_equal 1, ArticleVote.vote_counts_for_article_between(1, date, date, 0, 10)
    end
        
  end
  
end
