require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  
  context "validations" do
    should "require an id" do
      assert_equal false, FactoryGirl.build(:article, :id => nil).valid?
    end
    should "require a title" do
      assert_equal false, FactoryGirl.build(:article, :title => nil).valid?
    end
    should "require a writer_id" do
      assert_equal false, FactoryGirl.build(:article, :writer_id => nil).valid?
    end
    should "require a permalink" do
      assert_equal false, FactoryGirl.build(:article, :permalink => nil).valid?
    end
    should "not accept a zero-length title" do
      assert_equal false, FactoryGirl.build(:article, :title => "").valid?
    end
    should "not accept a zero-length permalink" do
      assert_equal false, FactoryGirl.build(:article, :permalink => "").valid?
    end
    
    should "require id to be unique" do
      id = 999
      article1 = FactoryGirl.build(:article, :id => id)
      article1.save!
      article2 = FactoryGirl.build(:article, :id => id)
      assert_equal false, article2.valid?
    end
    
    should "have many daily page views" do
      article = FactoryGirl.build(:article)
      assert article.respond_to?(:daily_page_views)
    end
    
    should "have many daily keyphrase views" do
      article = FactoryGirl.build(:article)
      assert article.respond_to?(:daily_keyphrase_views)
    end
    
    should "have many daily domain views" do
      article = FactoryGirl.build(:article)
      assert article.respond_to?(:daily_domain_views)
    end
    
  end
  
  context "incrementing daily page views" do
    
    setup do
      @article = FactoryGirl.create(:article)
    end
    
    should "give 1 page view if there are none for today" do
      @article.increment_page_view_on(Date.today)
      assert_equal 1, @article.daily_page_views.where(:date => Date.today).first.count
    end
    
    should "give 2 page view if there is already 1 for today" do
      @article.increment_page_view_on(Date.today)
      @article.increment_page_view_on(Date.today)
      assert_equal 2, @article.daily_page_views.where(:date => Date.today).first.count
    end
    
  end
  
  context "incrementing daily keyphrase views" do

     setup do
       @keyphrase = "awesome sauce"
       @article = FactoryGirl.create(:article)
     end
     
     should "give 1 keyphrase view if there are none for today" do
       @article.increment_keyphrase_view_on(Date.today, @keyphrase )
       assert_equal 1, @article.daily_keyphrase_views.where(:date => Date.today,:keyphrase => @keyphrase ).first.count
     end

     should "give 2 keyphrase view if there is already 1 for today" do
       @article.increment_keyphrase_view_on(Date.today, @keyphrase )
       @article.increment_keyphrase_view_on(Date.today, @keyphrase )
       assert_equal 2, @article.daily_keyphrase_views.where(:date => Date.today,:keyphrase => @keyphrase ).first.count
     end

     should "should create new keyphrase for today if keyphrase is not found for today" do
        @article.increment_keyphrase_view_on(Date.today, "not awesome sauce" )
        @article.increment_keyphrase_view_on(Date.today, @keyphrase )
        assert_equal 1, @article.daily_keyphrase_views.where(:date => Date.today,:keyphrase => @keyphrase ).first.count
      end
     
   end
   
   context "incrementing daily domain views" do

      setup do
        @domain = "google.com"
        @article = FactoryGirl.create(:article)
      end

      should "give 1 domain view if there are none for today" do
        @article.increment_domain_view_on(Date.today, @domain )
        assert_equal 1, @article.daily_domain_views.where(:date => Date.today,:domain => @domain ).first.count
      end

      should "give 2 domain view if there is already 1 for today" do
        @article.increment_domain_view_on(Date.today, @domain )
        @article.increment_domain_view_on(Date.today, @domain )
        assert_equal 2, @article.daily_domain_views.where(:date => Date.today,:domain => @domain ).first.count
      end

      should "should create new domain for today if domain is not found for today" do
         @article.increment_domain_view_on(Date.today, "yahoo.ca" )
         @article.increment_domain_view_on(Date.today, @domain )
         assert_equal 1, @article.daily_domain_views.where(:date => Date.today,:domain => @domain ).first.count
       end

    end
   
  
  context "find and update title or create" do
    
    should "create an article if it doesn't exist" do
      article_id = 111
      attributes = FactoryGirl.attributes_for(:article, :id => article_id)
      Article.find_and_update_title_or_create(attributes)
      assert Article.exists?(:id => article_id)
    end
    
    should "update the title of an article that exists" do
      article = FactoryGirl.create(:article, :title => "first")
      Article.find_and_update_title_or_create(FactoryGirl.attributes_for(:article, :title => "second"))
      article.reload
      assert article.title == "second"
    end

  end
  
  context "counting views" do
    should "get the right view count between two dates" do
      article = FactoryGirl.create(:article)
      3.times do
        article.increment_page_view_on(Date.yesterday)
      end
      6.times do
        article.increment_page_view_on(Date.today)
      end
      assert_equal 9, article.count_between(Date.yesterday, Date.today)
    end
  end
  
  context "getting id, titles, permalinks and counts for a writer" do
        
    should "get all the article_id, titles, permalinks and counts for those articles ordered by count descending" do
      writer_id = 345    
      1.upto(3) do |i|
        article = FactoryGirl.create(:article, :id => i, :writer_id => writer_id, :title => "Article #{i}", :permalink => "http://www.google.com")
        i.times do
          article.increment_page_view_on(Date.today)
        end
      end
      title_counts_out = DailyPageView.article_counts_for_writer_between(writer_id, Date.today, Date.today, 10, 0)
      title_counts_in = [
        {:id => 3, :title =>"Article 3",:permalink => "http://www.google.com", :page_views_count => 3},
        {:id => 2, :title =>"Article 2",:permalink => "http://www.google.com", :page_views_count => 2},
        {:id => 1, :title =>"Article 1",:permalink => "http://www.google.com", :page_views_count => 1}
        ]
      article_counts = []
      title_counts_out.each do |a|
        article_counts << {:id => a.id, :title => a.title, :permalink => a.permalink, :page_views_count => a.count_all.to_i}
      end
      assert_equal title_counts_in, article_counts
    end
    
  end

end
