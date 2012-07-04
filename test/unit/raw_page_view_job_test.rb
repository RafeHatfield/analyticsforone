require 'test_helper'

class RawPageViewJobTest < ActiveSupport::TestCase
  context "valid data" do 
    setup do
      @article_id = 45678
      @valid_raw_data = {
        :permalink =>"http://www.animal.intranet.suite101.com/content/the-gmhp-shiitake-mushroom-growing-kit-a120501", 
        :title => "The GMHP Shiitake Mushroom Growing Kit", 
        :cookie_id => "#{1000 + rand(10000)}", 
        :article_id => @article_id, 
        :referrer_url => "http://www.google.ca/search?q=awesome+sauce&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a", 
        :writer_id => "658084", 
        :date => "{ts '2011-03-02 12:58:52'}"
      }
    end
  
    context "perform with valid data" do
      setup do
        json = ActiveSupport::JSON.encode(@valid_raw_data)
        RawPageViewJob.perform(json)
        @article = Article.find(@article_id)
      end
  
      should "create an article" do
        assert @article
      end  
      should "create a raw page view" do
        assert_equal 1, RawPageView.where(:article_id => @article_id).count
      end
      should "add a daily page view to the viewed article on the proper day" do
        assert_equal 1, @article.daily_page_views.where(:date => "2011-03-02".to_date).count
      end
      should "add a daily keyphrase view to the viewed article on the proper day" do
        assert_equal 1, @article.daily_keyphrase_views.where(:date => "2011-03-02".to_date, :keyphrase => "awesome sauce").count
      end
      should "add a daily domain view to the viewed article on the proper day" do
        assert_equal 1, @article.daily_domain_views.where(:date => "2011-03-02".to_date, :domain => "www.google.ca").count
      end
    
    end
  
    context "perform with a blank referrer url" do
      setup do
        RawPageViewJob.perform(ActiveSupport::JSON.encode(@valid_raw_data.merge!(:referrer_url => "")))
        @article = Article.find(@article_id)
      end
    
      should "create an article" do
        assert @article
      end
      should "create a raw page view" do
        assert_equal 1, RawPageView.where(:article_id => @article_id).count
      end
      should "add a daily page view to the viewed article on the proper day" do
        assert_equal 1, @article.daily_page_views.where(:date => "2011-03-02".to_date).count
      end
      should "not add a daily keyphrase view to the viewed article on the proper day" do
        assert_equal 0, @article.daily_keyphrase_views.where(:date => "2011-03-02".to_date, :keyphrase => "awesome sauce").count
      end
      should "not add a daily domain view to the viewed article on the proper day" do
        assert_equal 0, @article.daily_domain_views.where(:date => "2011-03-02".to_date, :domain => "www.google.ca").count
      end
    
    end
    
    context "perform with a referrer url with spaces in keywords" do
      setup do
        RawPageViewJob.perform(ActiveSupport::JSON.encode(@valid_raw_data.merge!(:referrer_url => "http://www.google.ca/search?q=awesome sauce&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a")))
        @article = Article.find(@article_id)
      end
    
      should "create an article" do
        assert @article
      end
      should "create a raw page view" do
        assert_equal 1, RawPageView.where(:article_id => @article_id).count
      end
      should "add a daily page view to the viewed article on the proper day" do
        assert_equal 1, @article.daily_page_views.where(:date => "2011-03-02".to_date).count
      end
      should "add a daily keyphrase view to the viewed article on the proper day" do
        assert_equal 1, @article.daily_keyphrase_views.where(:date => "2011-03-02".to_date, :keyphrase => "awesome sauce").count
      end
      should "add a daily domain view to the viewed article on the proper day" do
        assert_equal 1, @article.daily_domain_views.where(:date => "2011-03-02".to_date, :domain => "www.google.ca").count
      end
    
    end
    
    context "perform with an null cookie_id" do
      setup do
        data = "{\"permalink\":\"http://www.suite101.com/content/letting-go-a12912\",\"title\":\"Letting%20Go%20Of%20Your%20Past%20%2D%20Moving%20On%20With%20Life\",\"article_id\":\"12912\",\"cookie_id\":null,\"date\":\"2011-03-16T21:18:31+00:00\",\"referrer_url\":\"\",\"writer_id\":\"587420\"}"
        RawPageViewJob.perform(data)
        @article = Article.find(12912)
      end
    
      should "create an article" do
        assert @article
      end
      should "create a raw page view" do
        assert_equal 1, RawPageView.where(:article_id => @article.id).count
      end
    
    end
    
    
    context 'setting timezone given an url' do
      setup do
        @url = 'http://www.suite101.net'
      end
      
      should 'return the correct timezone' do
        RawPageViewJob.set_timezone(@url) == ActiveSupport::TimeZone['Madrid']
      end
      
    end
    
    context "on aggregating page views for an article" do 
      setup do
        @valid_raw_data = {
          :title => "Random Article", 
          :cookie_id => "#{1000 + rand(10000)}", 
          :article_id => 45678, 
          :referrer_url => "", 
          :writer_id => "658084", 
          :date => Time.utc(2011,"mar",17,3,0,0)
        }
        
      end
      
      should 'generate the right dailypage view date on .com' do
        RawPageViewJob.perform(ActiveSupport::JSON.encode(@valid_raw_data.merge!(:permalink => "http://www.suite101.com/content/random-article")))
        assert_equal 1, DailyPageView.where(:date => 'March 16, 2011'.to_date).count
        assert_equal 0, DailyPageView.where(:date => 'March 17, 2011'.to_date).count
      end
      
      should 'generate the right dailypage view date on .net' do
        RawPageViewJob.perform(ActiveSupport::JSON.encode(@valid_raw_data.merge!(:permalink => "http://www.suite101.net/content/random-article")))
        assert_equal 0, DailyPageView.where(:date => 'March 16, 2011'.to_date).count
        assert_equal 1, DailyPageView.where(:date => 'March 17, 2011'.to_date).count
      end    
      
      should 'generate the right dailypage view date on .de' do
        RawPageViewJob.perform(ActiveSupport::JSON.encode(@valid_raw_data.merge!(:permalink => "http://www.suite101.de/content/random-article")))
        assert_equal 0, DailyPageView.where(:date => 'March 16, 2011'.to_date).count
        assert_equal 1, DailyPageView.where(:date => 'March 17, 2011'.to_date).count
      end
      
      should 'generate the right dailypage view date on .fr' do
        RawPageViewJob.perform(ActiveSupport::JSON.encode(@valid_raw_data.merge!(:permalink => "http://www.suite101.de/content/random-article")))
        assert_equal 0, DailyPageView.where(:date => 'March 16, 2011'.to_date).count
        assert_equal 1, DailyPageView.where(:date => 'March 17, 2011'.to_date).count
      end
      
    end
    
    should "fail silently on spider views" do
      data = "{\"permalink\":\"'   escape('http://www.suite101.com/content/slentrolweight-loss-drug-for-dogs-a27283')   '\",\"title\":\"'    escape('Slentrol:Weight Loss Drug for Dogs')   '\",\"cookie_id\":\"'   cookie_id   '\",\"date\":\"2011-05-30T21:14:09Z\",\"article_id\":\"'   escape('27283')   '\",\"referrer_url\":\"'    referrer_url   '\",\"writer_id\":\"'   353507   '\"}"
      RawPageViewJob.perform(data)
    end
    
  end
  
  # should "handle funny dates" do
  #   data = "{\"permalink\":\"http://www.suite101.com/content/how-to-train-and-retain-professional-nurses-a183887\",\"title\":\"How%20to%20Train%20and%20Retain%20Professional%20Nurses\",\"suite101_article_id\":\"183887\",\"cookie_id\":\"5625E6EA-C4D1-3D5C-8F2172C9814BF4CE\",\"date\":\"Fri Mar 11 13:01:29 UTC 1300 2011\",\"referrer_url\":\"http://www.suite101.com/content/hostility-and-violence-in-the-nursing-profession-a149150\",\"writer_id\":\"686710\"}"
  #   RawPageViewJob.perform(data)
  # end
  # 
  # should "handle referrer_urls with improperly parsed query strings" do
  #   data = "{\"permalink\":\"http://www.suite101.com/content/prayer-shawl-meditation-to-pray-with-a-hug-from-jesus-a230676\",\"title\":\"Prayer%20Shawl%20Meditation%20to%20Pray%20with%20a%20Hug%20from%20Jesus\",\"suite101_article_id\":\"230676\",\"cookie_id\":\"F582D2B2-E153-354B-752016C2949742D3\",\"date\":\"Fri Mar 11 2011 08:01:43 GMT 0800 (China Standard Time)\",\"referrer_url\":\"http://www.bing.com/search?q=hug of JESUS now&go=&filt=all&qs=n&sk=&first=11&FORM=PERE\",\"writer_id\":\"656347\"}"
  #   RawPageViewJob.perform(data)
  # end
  # 
  # should "handle very long referrer_urls" do
  #   data = "{\"permalink\":\"http://www.suite101.com/content/scalloping-in-port-st-joe-fl-a132086\",\"title\":\"Scalloping%20in%20Port%20St%2E%20Joe%2C%20FL\",\"suite101_article_id\":\"132086\",\"cookie_id\":\"562DABCD-B6BA-93BF-57D6A6599C65B84E\",\"date\":\"Thu Mar 10 2011 18:01:33 GMT-0600 (Central Standard Time)\",\"referrer_url\":\"http://www.google.com/url?sa=t&source=web&cd=3&ved=0CCcQFjAC&url=http%3A%2F%2Fwww.suite101.com%2Fcontent%2Fscalloping-in-port-st-joe-fl-a132086&rct=j&q=port%20st%20joe%20scallops&ei=S2Z5TfPxC-KQ0QGioZDQAw&usg=AFQjCNFac-l9cHpuzIQiHLOADXhaFrilDg&sig2=BTTE6xZSOygxgvnvJjqeBA\",\"writer_id\":\"620728\"}"
  #   RawPageViewJob.perform(data)
  # end

end
