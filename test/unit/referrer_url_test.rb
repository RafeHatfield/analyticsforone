require 'test_helper'

class ReferrerUrlTest < ActiveSupport::TestCase
  setup do
    @search_url = {
      :google => "http://www.google.ca/search?q=awesome+sauce&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-aSearchUrlParser",
      :yahoo => "http://ca.search.yahoo.com/search;_ylt=A0oGk24.bl1NlR0B2rfrFAx.;_ylc=X1MDMjExNDcyMTAwMwRfcgMyBGFvAzEEZnIDeWZwLXQtNzE1BGhvc3RwdmlkA2htNWRla29Ha3luelJmN0ZUUzlqb1FYRlJSLjZZazFkYmo0QUR3RDcEbl9ncHMDMARuX3ZwcwMwBG9yaWdpbgNzcnAEcXVlcnkDZGViYXRlIHRvcGljcyBzdWl0ZTEwMQRzYW8DMQR2dGVzdGlkAw--?p=awesome+sauce&fr2=sb-top&fr=yfp-t-715&rd=r1",
      :bing => "http://www.bing.com/search?q=awesome+sauce&x=0&y=0&form=MSNH14&qs=n&sk=",
      :msn => "http://www.msn.com/search?q=awesome+sauce&x=0&y=0&form=MSNH14&qs=n&sk=",
      :search => "http://www.search.com/search?q=awesome+sauce",
      :aol => "http://search.aol.ca/aol/search?invocationType=&query=awesome+sauce",
      :yandex => "http://yandex.com/yandsearch?text=awesome+sauce&lr=21353",
      :ask => "http://www.ask.com/web?q=awesome+sauce&search=&qsrc=0&o=0&l=dir"        
    }
    @searched_keywords = "awesome sauce"
  end

  context "getting search engine" do
    should "get the correct search engine for valid search urls from supported engines" do
      @search_url.each do |engine, url|
        assert_equal engine, ReferrerUrl.new(url).search_engine
      end
    end
    should "return nil for url that is not from a valid engine." do
      non_organic_url = "http://www.coke.com/iamhappywithstuff?q=thisisntasearch"
      assert_equal nil, ReferrerUrl.new(non_organic_url).search_engine
    end
    should "get the right engine for google mobile searches" do
      search_url = "http://www.google.com/m?hl=en&gl=us&client=ms-android-verizon&source=android-unknown&action=devloc&q=awesome%20sauce"
      assert_equal :google, ReferrerUrl.new(search_url).search_engine
    end
  end

  context "getting keyphrase" do
    should "get the correct keyphrase for valid search urls from supported engines" do
      @search_url.each do |engine, url|
        assert_equal @searched_keywords, ReferrerUrl.new(url).keyphrase
      end
    end
    should "get the correct keywords for a google search url with quoted search terms" do
      search_url = "http://www.google.ca/search?q=%22awesome%20sauce%22%20happy&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-a"
      searched_keywords = "\"awesome sauce\" happy"
      assert_equal searched_keywords, ReferrerUrl.new(search_url).keyphrase
    end    
    should "return nil if the keywords couldn't be parsed properly" do
      search_url = "http://www.google.com/imgres?imgurl=http://images.suite101.com/2851319_COM_jose_mourinho_real_madrid_1_.jpg&imgrefurl=http://www.suite101.com/content/mourinhos-real-madrid--fc-barcelona-copa-del-rey-final-2011-a342288&usg=__P35o0PEZ3gZEM8T4FgsGZp8cOH0=&h=300&w=300&sz=17&hl=en&start=43&zoom=1&tbnid=fRrHjtsOVq42NM:&tbnh=131&tbnw=131&ei=pending&prev=/images%3Fq%3Dreal%2Bmadrid%2B2011%26hl%3Den%26biw%3D1280%26bih%3D579%26gbv%3D2%26tbs%3Disch:10,788&itbs=1&iact=rc&dur=394&oei=qTtxTe22OJKGswaCp6GIDg&page=3&ndsp=21&ved=1t:429,r:12,s:43&tx=115&ty=14&biw=1280&bih=579"
      assert_equal nil, ReferrerUrl.new(search_url).keyphrase
    end
    should "properly parse google mobile searches" do
      search_url = "http://www.google.com/m?hl=en&gl=us&client=ms-android-verizon&source=android-unknown&action=devloc&q=awesome%20sauce"
      assert_equal "awesome sauce", ReferrerUrl.new(search_url).keyphrase
    end
    should "return nil for an empty url" do
      assert_equal nil, ReferrerUrl.new("").keyphrase
    end
    should "return nil for an empty keyphrase" do
      assert_equal nil, ReferrerUrl.new("http://www.google.com.sg/m/search?aq=").keyphrase
    end
    should "return truncated keyphrase if it is greater than 254 characters" do
      keyphrase_in = "a" * 255
      assert_equal keyphrase_in.truncate(254), ReferrerUrl.new("http://www.google.com?q=#{keyphrase_in}").keyphrase
    end
    should "work for a url with many strings that look like the query string" do
      assert_equal "calfile california tax return", ReferrerUrl.new("http://search.yahoo.com/search;_ylt=AgGaOf.pKBB4r4CrKlfRoLCbvZx4?fr=yfp-t-701-1-s&toggle=1&cop=mss&ei=UTF8&p=calfile%20california%20tax%20return").keyphrase
      assert_equal "free ca tax filing", ReferrerUrl.new("http://www.google.com/search?sourceid=navclient&aq=0&oq=free+ca+tax&ie=UTF-8&rlz=1T4ADRA_enUS408US408&q=free+ca+tax+filing").keyphrase
      assert_equal "free 940 Ca State tax filing", ReferrerUrl.new("http://www.google.com/search?hl=en&q=free+940+Ca+State+tax+filing&btnG=Search&aq=f&aqi=&aql=&oq=").keyphrase
    end
  end
  
  context "getting domain" do
    should "get the correct domain for urls" do
      urls = [
        "http://www.google.ca/search?q=awesome+sauce&ie=utf-8&oe=utf-8&aq=t&rls=org.mozilla:en-US:official&client=firefox-aSearchUrlParser",
        "http://ca.search.yahoo.com/search;_ylt=A0oGk24.bl1NlR0B2rfrFAx.;_ylc=X1MDMjExNDcyMTAwMwRfcgMyBGFvAzEEZnIDeWZwLXQtNzE1BGhvc3RwdmlkA2htNWRla29Ha3luelJmN0ZUUzlqb1FYRlJSLjZZazFkYmo0QUR3RDcEbl9ncHMDMARuX3ZwcwMwBG9yaWdpbgNzcnAEcXVlcnkDZGViYXRlIHRvcGljcyBzdWl0ZTEwMQRzYW8DMQR2dGVzdGlkAw--?p=awesome+sauce&fr2=sb-top&fr=yfp-t-715&rd=r1",
        "http://www.bing.com/search?q=awesome+sauce&x=0&y=0&form=MSNH14&qs=n&sk=",
        "http://www.msn.com/search?q=awesome+sauce&x=0&y=0&form=MSNH14&qs=n&sk=",
        "http://www.search.com/search?q=awesome+sauce",
        "http://search.aol.ca/aol/search?invocationType=&query=awesome+sauce",
        "http://yandex.com/yandsearch?text=awesome+sauce&lr=21353",
        "http://www.ask.com/web?q=awesome+sauce&search=&qsrc=0&o=0&l=dir"        
      ]
      domains = ["www.google.ca", "ca.search.yahoo.com", "www.bing.com", "www.msn.com", "www.search.com", "search.aol.ca", "yandex.com", "www.ask.com"]

      urls.each_with_index do |url, i|
        assert_equal domains[i], ReferrerUrl.new(url).domain
      end
    end
  end

  
end