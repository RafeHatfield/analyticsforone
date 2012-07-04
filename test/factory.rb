FactoryGirl.define do

  factory :raw_page_view do
    article_id 123456
    writer_id 65432
    cookie_id "arandomcookie"
    title "Chocolate has an Expiration Date"
    permalink "http://www.suite101.com/content/chocolate-has-an-expiration-date-a347637"
    referrer_url "http://www.google.ca/search?q=awesome+sauce&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a"
    date {Time.now}
  end
  
  factory :article do
    id 1
    title "MyString"
    writer_id 1
    permalink "MyString"
  end
  
  factory :daily_page_view do
    date "2011-02-28"
    article_id 1
    count 1
    writer_id 1
  end

  factory :daily_keyphrase_view do
    date "2011-03-03"
    article_id 1
    keyphrase "MyString"
    count 1
  end

  factory :daily_domain_view do
    date "2011-03-09"
    article_id 1
    domain "MyString"
    count 1
    writer_id 1
  end
end