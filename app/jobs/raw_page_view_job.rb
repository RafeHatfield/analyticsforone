class RawPageViewJob
  @queue = :page_view
    
  # retry_criteria_check do |exception, *args|
  #   if exception.message =~ /InvalidJobId/
  #     false # don't retry if we got passed a invalid job id.
  #   else
  #     true  # its okay for a retry attempt to continue.
  #   end
  # end

  def self.perform(raw_page_view_data)
    hash = ActiveSupport::JSON.decode(raw_page_view_data)
    
    unless spider_view?(hash)
    
      select_shard(hash['permalink']) do      
        view = RawPageView.new(hash)
        begin
          view.save!
          process_raw_page_view(view)
        rescue ActiveRecord::RecordNotSaved
          # Only throw validation errors.
        end
      end
      
    end
    
  end

private

  # Determine if this view was from a spider
  def self.spider_view?(data_hash)
    # Spiders don't seem to properly execute the javascript on the tracking page,
    # so the cookie_id variable doesn't get executed, it just inputs "cookie_id" as a string
      
    if /cookie_id/.match(data_hash["cookie_id"])
      return true
    else
      return false
    end
  end

  def self.domain_extension(url)
    extension = Addressable::URI.parse(url).host.split('.').last.to_sym
    unless [:com, :de, :net, :fr].include?(extension)
      raise "Invalid domain extension: #{extension}."
    end
    return extension
  end

  def self.select_shard(url)
    if SHARDING_ENABLED && url.present?
      Octopus.using(domain_extension(url)) { yield }
    else
      yield
    end
  end
  
  def self.set_timezone(url)
    extension_to_timezone_map = {
      :com => "Pacific Time (US & Canada)",
      :de => "Berlin",
      :net => "Madrid",
      :fr => "Paris"
    }
    Time.zone = ActiveSupport::TimeZone[extension_to_timezone_map[domain_extension(url)]]
  end
  
  def self.process_raw_page_view(raw_page_view)   
    
    set_timezone(raw_page_view.permalink)
    
    # domain = Writer.domain_extension(raw_page_view.permalink)
    # Writer.create(domain).writer_ids_set << raw_page_view.writer_id
    
    article = Article.find_and_update_or_create({
      :id => raw_page_view.article_id,
      :title => raw_page_view.title,
      :writer_id => raw_page_view.writer_id,
      :permalink => raw_page_view.permalink
    })

    referrer_url = ReferrerUrl.new(raw_page_view.referrer_url)

    article.increment_page_view_on(Time.zone.utc_to_local(raw_page_view.date.getutc))

    if referrer_url.keyphrase
      article.increment_keyphrase_view_on(Time.zone.utc_to_local(raw_page_view.date.getutc), referrer_url.keyphrase)
    end

    article.increment_domain_view_on(Time.zone.utc_to_local(raw_page_view.date.getutc), referrer_url.domain)
  end  
  
end