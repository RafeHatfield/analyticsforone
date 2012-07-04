# Read about factories at http://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :article_vote do
      article_id 1
      date "2011-05-19"
      note "MyText"
      helpful false
    end
end