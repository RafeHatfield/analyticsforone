class ReferrerUrl
  extend ActiveSupport::Memoizable
  # Match "engine_name" followed by a ".".
  # NOTE: Search.com matching must be last because other engines
  #       use "search." in their domain and we want to catch them first.
  @@ENGINE_REGEX = {
    :google => /google\./,
    :yahoo => /yahoo\./,
    :bing => /bing\./,
    :msn => /msn\./,
    :aol => /aol\./,
    :ask => /ask\./,
    :yandex => /yandex\./,
    :search => /www\.search\.com/
  }
  
  @@ENGINE_SEARCH_KEY_REGEX = {
    :google => /[?&]q=/,
    :bing => /[?&]q=/,
    :yahoo => /[?&]p=/,
    :msn => /[?&]q=/,
    :aol => /[?&]query=/,
    :ask => /[?&]q=/,
    :yandex => /[?&]text=/,
    :search => /[?&]q=/
  }
  
  @@SUITE101_URL_REGEX = /suite101/
  
  def initialize(url)
    @url = url || ""
  end
  
  def domain
    URI.parse(@url).host || ""
  end
  
  def search_engine
    @@ENGINE_REGEX.each do |engine, regex|
      return engine if regex.match(@url)
    end
    return nil
  end
  memoize :search_engine

  def keyphrase
    # Search url make-up:
    # => [junk]?[query]
    # => [junk]?[junk][search_key][raw_keyphrase]&[junk]
    
    if !@@ENGINE_SEARCH_KEY_REGEX.has_key?(search_engine)
      return nil
    end    
    
    query = URI.parse(@url).query
    
    if @@ENGINE_SEARCH_KEY_REGEX[search_engine].match(@url)
      post_key = @url.split(@@ENGINE_SEARCH_KEY_REGEX[search_engine]).second
      if post_key
        raw_keyphrase = post_key.split("&").first
        # Keywords are separated by %20 or +, these are converted to " " when unescaped.
        return CGI.unescape(raw_keyphrase).truncate(254)
      else
        return nil
      end
    else
      return nil
    end
  end
  memoize :keyphrase
  
  def source
    if search_engine
      :organic
    elsif @@SUITE101_URL_REGEX.match(domain)
      :internal
    else
      :other
    end
  end
  memoize :source
  
end
