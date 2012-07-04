namespace :dev_seeds do  

  WRITER_ID = 1
  
  ARTICLES = []
  1.upto(30) do |i|
    ARTICLES << {:id => i, :title => "Article #{i}", :writer_id => WRITER_ID}
  end

  REFERRER_URLS = [
    "http://www.google.ca/search?q=awesome+sauce&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a",
    "http://www.google.ca/search?q=happy+dogs&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a",
    "http://www.bing.com/search?q=sauce&x=0&y=0&form=MSNH14&qs=n&sk=",
    "http://www.google.com/search?q=awesome&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a",
    "http://www.google.com/search?q=awesome+sauce&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a",
    "http://www.bing.com/search?q=greatness&x=0&y=0&form=MSNH14&qs=n&sk=",
    "",
    "",
    "http://www.happyplanet.net/ten-great-articles-you-should-read",
    "http://www.suite101.com/my_article_that_i_wrote",
    "http://my.suite101.de/my_article_that_i_wrote",
    "http://ca.search.yahoo.com/search?p=totally+awesome+sauce&fr2=sb-top&fr=yfp-t-715&rd=r1",
    "http://www.msn.com/search?q=apple+sauce&x=0&y=0&form=MSNH14&qs=n&sk=",
    "http://www.search.com/search?q=french+people",
    "http://www.openlinkingpeople.de",
    "http://www.myblog.wordpress.com",
    "http://search.aol.ca/aol/search?invocationType=&query=people+eaters",
    "http://www.google.com/search?q=purple&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a",
    "http://www.google.com/search?q=apples&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a",
    "http://www.google.au/search?q=tally+hoo&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a",
    "http://www.bing.de/search?q=flying+saucer&x=0&y=0&form=MSNH14&qs=n&sk=",
    "http://www.bing.net/search?q=open+easy+rider&x=0&y=0&form=MSNH14&qs=n&sk="
  ]

  desc "Cleanup the development database"
  task :cleanup => :environment do
    puts "Cleaning up the test data..."
    ARTICLES.each do |article|
      Article.where(:id => article[:id]).destroy_all
    end
    puts 'done.'
  end

  desc "Inject test data for development environment"
  task :fill => [:cleanup, :environment] do
    puts 'Hardcore populating action...'
    ARTICLES.each do |article|
      30.downto(0) do |i_day|

        # Register page views.
        count = (6.*Math.sin(i_day*(360/6.28))).to_i + 6 + rand(4)
        count.times do
          RawPageViewJob.perform(
            {
              :writer_id => article[:writer_id],
              :permalink => "http://www.suite101.com/content/chocolate-has-an-expiration-date-a347637",
              :article_id => article[:id],
              :referrer_url => REFERRER_URLS[rand(REFERRER_URLS.count)],
              :title => article[:title],
              :date => i_day.days.ago,
              :cookie_id => "#{1000 + rand(1000000)}"
            }.to_json
          )
        end
        
        # Register helpful votes.
        helpful_count = (4.*Math.sin(i_day*(360/6.28))).to_i + 6 + rand(3)
        helpful_count.times do
          ArticleVote.create(:article_id => article[:id], :title => article[:title], :writer_id => article[:writer_id], :date => i_day.days.ago, :vote => true)
        end
        
        # Register unhelpful votes.
        unhelpful_count = (3.*Math.sin(i_day*(360/6.28))).to_i + 6 + rand(2)
        unhelpful_count.times do
          ArticleVote.create(:article_id => article[:id], :title => article[:title], :writer_id => article[:writer_id], :date => i_day.days.ago, :vote => false, :note => "A test note that mitch wrote.")
        end

        puts "Registered #{count} views #{helpful_count} helpful votes, and #{unhelpful_count} unhelpful votes, on article #{article[:id]} for member #{article[:writer_id]} on #{i_day.days.ago.to_date}."

      end
    end
    puts "Done..."
  end
  
end
