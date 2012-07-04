require 'test_helper'

class DailyKeyphraseViewTest < ActiveSupport::TestCase
  context "validations" do  
    should "require a date" do
      assert_equal false, FactoryGirl.build(:daily_keyphrase_view, :date => nil).valid?
    end
    should "require a article_id" do
      assert_equal false, FactoryGirl.build(:daily_keyphrase_view, :article_id => nil).valid?
    end
    should "require a writer_id" do
      assert_equal false, FactoryGirl.build(:daily_keyphrase_view, :writer_id => nil).valid?
    end
    should "require a count" do
      assert_equal false, FactoryGirl.build(:daily_keyphrase_view, :writer_id => nil).valid?
    end
    should "have an article" do
      assert FactoryGirl.build(:daily_keyphrase_view).respond_to?(:article)
    end
  end
  
  context "getting keyphrase counts for a writer between two dates" do
    should "get the right keyphrase counts ordered by count descending" do
      writer_id = 333
      article = FactoryGirl.create(:article, :writer_id => writer_id)
      phrase1 = "awesome sauce"
      phrase2 = "awesome"
      3.times do
        article.increment_keyphrase_view_on(1.day.ago, phrase1)
      end
      2.times do
        article.increment_keyphrase_view_on(1.day.ago, phrase2)
      end
      6.times do
        article.increment_keyphrase_view_on(0.days.ago, phrase1)
      end

      expected_keyphrase_counts = [[phrase1, 3+6], [phrase2, 2]]
      assert_equal expected_keyphrase_counts, DailyKeyphraseView.keyphrases_with_total_counts_for_writer_between(writer_id, 1.day.ago, 0.days.ago, 10, 0)
    end
    
    should "limit the keyphrases returned if we set the limit option" do
      writer_id = 333
      article = FactoryGirl.create(:article, :writer_id => writer_id)
      phrase1 = "awesome sauce"
      phrase2 = "awesome"
      3.times do
        article.increment_keyphrase_view_on(1.day.ago, phrase1)
      end
      2.times do
        article.increment_keyphrase_view_on(1.day.ago, phrase2)
      end
      6.times do
        article.increment_keyphrase_view_on(0.days.ago, phrase1)
      end
      expected_keyphrase_counts = [[phrase1, 3+6]]
      assert_equal expected_keyphrase_counts, DailyKeyphraseView.keyphrases_with_total_counts_for_writer_between(writer_id, 1.day.ago, 0.days.ago, 10, 0)
    end
    
  end
  
  context "getting keyphrase counts for an article between two dates" do
    should "get the right keyphrase counts ordered by count descending" do
      article = FactoryGirl.create(:article)
      phrase1 = "awesome sauce"
      phrase2 = "awesome"
      3.times do
        article.increment_keyphrase_view_on(1.day.ago, phrase1)
      end
      2.times do
        article.increment_keyphrase_view_on(1.day.ago, phrase2)
      end
      6.times do
        article.increment_keyphrase_view_on(0.days.ago, phrase1)
      end

      expected_keyphrase_counts = [[phrase1, 3+6], [phrase2, 2]]
      assert_equal expected_keyphrase_counts, DailyKeyphraseView.keyphrases_with_total_counts_for_article_between(article.id, 1.day.ago, 0.days.ago, 10, 0)
    end
  end
  
end
