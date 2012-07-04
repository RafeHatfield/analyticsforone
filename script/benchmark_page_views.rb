require 'CGI'

10.times do
  cookie_id = rand(100000).to_s
  server1 = "http://localhost:3000"
  server2 = "stats.staging.suite101.com"
  uri = "'http://stats.staging.suite101.com/add_page_view?suite101_article_id=1234&permalink=http://www.google.ca&title=hello&writer_id=987&cookie_id=fakeid2&date=Wed+Feb+23+10%3A45%3A38+-0800+2011&referrer_url=http://www.google.com'"
  system("curl -I #{server1}#{uri}")
  #system("httperf --hog --server #{server2} --uri #{uri}")
end