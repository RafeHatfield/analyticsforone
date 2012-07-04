require 'test_helper'

class DailyPageViewTest < ActiveSupport::TestCase

  context "validations" do
    should "require a date" do
      assert_equal false, FactoryGirl.build(:daily_page_view, :date => nil).valid?
    end
    should "require a article_id" do
      assert_equal false, FactoryGirl.build(:daily_page_view, :article_id => nil).valid?
    end
    should "require a writer_id" do
      assert_equal false, FactoryGirl.build(:daily_page_view, :writer_id => nil).valid?
    end
    should "require a count" do
      assert_equal false, FactoryGirl.build(:daily_page_view, :writer_id => nil).valid?
    end    
    should "have an article" do
      daily_page_view = FactoryGirl.build(:daily_page_view)
      assert daily_page_view.respond_to?(:article)
    end
  end
  
  
  context "getting the views for a writer between two dates" do
    should "get the right view counts" do
      writer_id = 1
      article1 = Factory.create(:article, :id => 1, :writer_id => writer_id)
      article2 = Factory.create(:article, :id => 2, :writer_id => writer_id)
            
      article1.increment_page_view_on(1.day.ago)
      article2.increment_page_view_on(0.days.ago)

      view_counts = DailyPageView.counts_for_writer_between(writer_id, 2.days.ago, 0.days.ago)
      
      assert_equal [0,1,1], view_counts
    end
  end
  
  context "getting the views for an article between two dates" do
    setup do
      @id = 1
      article = Factory.create(:article, :id => @id)
      article.increment_page_view_on(1.day.ago)
      article.increment_page_view_on(0.days.ago)
    end
    should "get the right view counts" do
      view_counts = DailyPageView.counts_for_article_between(@id, 2.days.ago, 0.days.ago)
      assert_equal [0,1,1], view_counts
    end
    should "get the right view counts if there is more than one article" do
      article = Factory.create(:article, :id => 2)
      article.increment_page_view_on(1.day.ago)
      article.increment_page_view_on(0.days.ago)
      view_counts = DailyPageView.counts_for_article_between(@id, 2.days.ago, 0.days.ago)
      assert_equal [0,1,1], view_counts
    end
  end
  
end
