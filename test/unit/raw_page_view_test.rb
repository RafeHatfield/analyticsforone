require 'test_helper'

class RawPageViewTest < ActiveSupport::TestCase
  context "validations" do
    should "require a title" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :title => nil).valid?
    end
    should "require an article_id" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :article_id => nil).valid?
    end
    should "require a permalink" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :permalink => nil).valid?
    end
    should "require a writer_id" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :writer_id => nil).valid?
    end
    should "require a non-empty or nil cookie_id" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :cookie_id => "").valid?
      assert_equal true, FactoryGirl.build(:raw_page_view, :cookie_id => nil).valid?
    end
    should "require a date" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :date => nil).valid?
    end
    should "require writer_id to be an integer" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :writer_id => "notanint").valid?
    end
    should "require article_id to be an integer" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :article_id => "notanint").valid?
    end
    should "require date's year to be recent" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :date => Date.today - 100.years).valid?
      assert_equal false, FactoryGirl.build(:raw_page_view, :date => Date.today + 100.years).valid?
    end
    should "require a valid date" do
      assert_equal false, FactoryGirl.build(:raw_page_view, :date => 1234).valid?
    end
    # should "require referrer_url to be a parseable url" do
    #   assert_equal false, FactoryGirl.build(:raw_page_view, :referrer_url => "www.google.ca").valid?
    # end
    should "allow an empty string as a referrer url" do
      assert_equal true, FactoryGirl.build(:raw_page_view, :referrer_url => "").valid?
    end
  end
  
  context "data cleaning" do
    should "replace spaces with pluses in a referrer url" do
      url = "http://www.google.ca/?q=awesome sauce"
      converted_url = "http://www.google.ca/?q=awesome+sauce"
      assert_equal converted_url, FactoryGirl.create(:raw_page_view, :referrer_url => url).referrer_url
    end
    should "assign a random cookie id if a nil cookie id is given" do
      assert FactoryGirl.create(:raw_page_view, :cookie_id => nil).cookie_id.length > 3
    end
  end
  
  context "uniqueness" do
    setup do  
      # Clear the uniqueness cache for every test.
      RawPageView.uniqueness_cache.flush_all
      first_view = FactoryGirl.create(:raw_page_view, :date => Time.now)
    end
   
    should "not save if the same payload was recorded less than 30 minutes ago" do
      second_view = FactoryGirl.build(:raw_page_view, :date => 10.minutes.from_now)
      assert_equal false, second_view.save
    end

    should "save if the same payload was seen more than 30 minutes ago" do
      second_view = FactoryGirl.build(:raw_page_view, :date => 50.minutes.from_now)
      assert_equal true, second_view.save
    end
    
    should "save if the same payload hasn't been seen before" do
      second_view = FactoryGirl.build(:raw_page_view, :cookie_id => "superrandom", :date => 10.minutes.from_now)
      assert_equal true, second_view.save
    end

  end
  


end
