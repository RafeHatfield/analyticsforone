class ApplicationController < ActionController::Base
  protect_from_forgery

  ## Timeout after inactivity of one hour.
  MAX_SESSION_PERIOD = 3600
  
  before_filter :set_locale
  around_filter :select_shard
  before_filter :session_expiry
  before_filter :set_default_table_lengths
       
  def domain_extension
    if request.domain
      request.domain.split('.').last.to_sym
    else
      :com
    end
  end

  def domain_extension?(lang)
    lang == domain_extension
  end
  helper_method :domain_extension?
  
  def set_locale
    extensions = {
      :com => :en,
      :de => :de,
      :fr => :fr,
      :net => :es
    }
    I18n.locale = extensions[domain_extension]    
  end
  
  def select_shard
    if SHARDING_ENABLED
      Octopus.using(domain_extension) { yield }
    else
      yield
    end
  end
  
protected
 
  # Expire session variables after an hour.
  def session_expiry
    reset_session if session[:expiry_time] and session[:expiry_time] < Time.now

    session[:expiry_time] = MAX_SESSION_PERIOD.seconds.from_now
    return true
  end
  
  # Parse a date string using the i18n date format.
  def parse_i18n_date(date_str)
    Date.strptime(date_str, I18n.t('date.formats.default'))
  end
  
  def set_default_table_lengths
    session[:articles_length] ||= 25
    session[:keyphrases_length] ||= 10
    session[:domains_length] ||= 10
    session[:votes_length] ||= 10
  end
  
  def set_start_and_end_date
    if params[:start_date].present?
      @start_date = parse_i18n_date(params[:start_date])
      session[:start_date] = @start_date
    elsif session[:start_date].present?
      @start_date = session[:start_date]
    else
      @start_date = 7.days.ago.to_date
    end
    
    if params[:end_date].present?
      @end_date = parse_i18n_date(params[:end_date])
      session[:end_date] = @end_date
    elsif session[:end_date].present?
      @end_date = session[:end_date]
    else
      @end_date = Date.today
    end
  end
  
  
  # Ensure that the supplied id and key match our encoding.
  # Setup the @user object with authentication info.
  def get_user
    key = params[:key]
    writer_id = key.alphadecimal
    @user = {:id => writer_id, :key => key}
  end
  
end
