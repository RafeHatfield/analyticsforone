require 'test_helper'

class DailyDomainViewTest < ActiveSupport::TestCase

  context "validations" do  
    should "require a date" do
      assert_equal false, FactoryGirl.build(:daily_domain_view, :date => nil).valid?
    end
    should "require a article_id" do
      assert_equal false, FactoryGirl.build(:daily_domain_view, :article_id => nil).valid?
    end
    should "require a writer_id" do
      assert_equal false, FactoryGirl.build(:daily_domain_view, :writer_id => nil).valid?
    end
    should "require a count" do
      assert_equal false, FactoryGirl.build(:daily_domain_view, :writer_id => nil).valid?
    end
    should "have an article" do
      assert FactoryGirl.build(:daily_domain_view).respond_to?(:article)
    end
  end
  
  context "getting domain counts for a writer between two dates" do
    should "get the right domain counts ordered by count descending" do
      writer_id = 333
      article = FactoryGirl.create(:article, :writer_id => writer_id)
      domain1 = "www.google.com"
      domain2 = "www.yahoo.com"
      3.times do
        article.increment_domain_view_on(1.day.ago, domain1)
      end
      2.times do
        article.increment_domain_view_on(1.day.ago, domain2)
      end
      6.times do
        article.increment_domain_view_on(0.days.ago, domain1)
      end

      expected_domain_counts = [[domain1, 3+6], [domain2, 2]]
      assert_equal expected_domain_counts, DailyDomainView.domain_counts_for_writer_between(writer_id, 1.day.ago, 0.days.ago).first
    end
    
    should "get limit the results if a limit option is set" do
      writer_id = 333
      article = FactoryGirl.create(:article, :writer_id => writer_id)
      domain1 = "www.google.com"
      domain2 = "www.yahoo.com"
      3.times do
        article.increment_domain_view_on(1.day.ago, domain1)
      end
      2.times do
        article.increment_domain_view_on(1.day.ago, domain2)
      end
      6.times do
        article.increment_domain_view_on(0.days.ago, domain1)
      end

      expected_domain_counts = [[domain1, 3+6]]
      assert_equal expected_domain_counts, DailyDomainView.domain_counts_for_writer_between(writer_id, 1.day.ago, 0.days.ago, 10, 0).first
    end
    
  end
  
  context "getting domain counts for an article between two dates" do
    should "get the right domain counts ordered by count descending" do
      article = FactoryGirl.create(:article)
      domain1 = "www.google.com"
      domain2 = "www.yahoo.com"
      3.times do
        article.increment_domain_view_on(1.day.ago, domain1)
      end
      2.times do
        article.increment_domain_view_on(1.day.ago, domain2)
      end
      6.times do
        article.increment_domain_view_on(0.days.ago, domain1)
      end

      expected_domain_counts = [[domain1, 3+6], [domain2, 2]]
      assert_equal expected_domain_counts, DailyDomainView.domain_counts_for_writer_between(article.id, 1.day.ago, 0.days.ago, 10, 0).first
    end
    
  end
  
  context "getting source counts for a writer between two dates" do
    should "get the right source counts ordered" do
      writer_id = 333
      article = FactoryGirl.create(:article, :writer_id => writer_id)
      domains = ["www.google.com", "www.google.ca", "", "www.suite101.com", "my.suite101.de", "www.happyplanet.com/my-article-linking-yours"]

      domains.each do |domain|
        article.increment_domain_view_on(1.day.ago, domain)
      end

      expected_domain_counts = { :organic => 2, :other => 2, :internal => 2}
      assert_equal expected_domain_counts, DailyDomainView.domain_counts_for_writer_between(writer_id, 1.day.ago, 0.days.ago, 10, 0).last
    end
    
  end
  
  context "getting source counts for an article between two dates" do
    should "get the right source counts ordered" do
      article = FactoryGirl.create(:article)
      domains = ["www.google.com", "www.google.ca", "", "www.suite101.com", "my.suite101.de", "www.happyplanet.com/my-article-linking-yours"]

      domains.each do |domain|
        article.increment_domain_view_on(1.day.ago, domain)
      end

      expected_domain_counts = { :organic => 2, :other => 2, :internal => 2}
      assert_equal expected_domain_counts, DailyDomainView.domain_counts_for_writer_between(article.id, 1.day.ago, 0.days.ago, 10, 0).last
    end
    
  end
  

end
