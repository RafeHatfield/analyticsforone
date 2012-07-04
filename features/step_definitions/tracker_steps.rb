Given /^"a test article" has "1" page view recorded$/ do
  @article_id = 999
  @first_viewer_cookie_id = 111
  RawPageView.where(:suite101_article_id => @article_id).delete_all
  FactoryGirl.create(:raw_page_view, :suite101_article_id => @article_id, :cookie_id => @first_viewer_cookie_id)
end

Then /^I should have "2" page views recorded for "a test article"$/ do
  RawPageView.where(:suite101_article_id => @article_id).length.should == 2
end

When /^I reload the page$/ do
  visit path_to("a test article")
end


# Then /^I should see (\d+) page view$/ do |count|
#   PageView.all.size.should == count
# end
# 
# Given /^test article has no page view$/ do
#   @page = create_page({:tracked_page_id => rand(10000).to_s})
#   @page.page_views.clear
# end
# 
# Given /^I visit the test article (\d+) times within (\d+) minutes$/ do |visit_count, time_period|
#   cookie_id = rand(1000).to_s
#   @page.insert_page_view({:cookie_id => cookie_id, :page_id => @page.id})
#   @page.insert_page_view({:cookie_id => cookie_id, :page_id => @page.id})
# end
# 
# Then /^the system should record (\d+) page view for the test article$/ do |view_count|
#   @page.page_views.size.should == view_count
# end
# 
# 
# Given /^"a test article" has "1" page view$/ do
#   @a_test_article = create_page
#   @a_test_article.page_views.clear
#   @a_test_article.page_views << create_page_view(:page_id => @a_test_article.id)
# end
# 
# Then /^I should see "2" page views for "a test article"$/ do
#   @a_test_article.page_views.size.should == 2
# end
# 
# When /^a page view has an organic referrer$/ do
#   # Fake a visit to a suite101 article with a google search referrer
# 
#   @page = create_page
#   @page.insert_page_view(params_for_page_view.merge!(:referer_url => "http://www.google.ca/search?q=awesome+sauce&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a"))
# end
# 
# Then /^we store the keyphrase searched for and search engine used$/ do
#   page_view = @page.page_views.first
#   page_view.keyword_phrase.should == "awesome sauce"
#   page_view.search_engine.should == "google"
# end