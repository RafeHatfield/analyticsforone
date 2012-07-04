class TrackingController < ApplicationController  
  def add_page_view
    
    current_utc = Time.now.utc
    
    raw_page_view_data = {
      :article_id => params[:suite101_article_id],
      :permalink => params[:permalink],
      :title => params[:title],
      :writer_id  => params[:writer_id],
      :referrer_url => params[:referrer_url] || "",
      :cookie_id => params[:cookie_id],
      :date => current_utc
    }
    
    Resque.enqueue(RawPageViewJob, raw_page_view_data.to_json)
    
    # Send a 1px image back to the requester.
    redirect_to 'http://graphics.suite101.com/page_view.gif'
  end

end
