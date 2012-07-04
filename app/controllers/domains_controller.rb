class DomainsController < ApplicationController
  before_filter :set_start_and_end_date
  @@PER_PAGE = 20
  
  def for_writer
		if params[:limit].to_i > 5000
			params[:limit] = 5000
		end
	  
    domain_counts = DailyDomainView.domain_counts_for_writer_between(params[:writer_id], @start_date, @end_date, params[:limit].to_i || @@PER_PAGE, params[:offset] || 0)
    
    # Update the number of domains to show.
    session[:domains_length] = session[:domains_length].to_i + params[:limit].to_i
    
    render :partial => 'domains', :locals => {:domain_counts => domain_counts} and return
  end
  
  def for_article
    domain_counts = DailyDomainView.domain_counts_for_article_between(params[:article_id], @start_date, @end_date, params[:limit] || @@PER_PAGE, params[:offset] || 0)
    render :partial => 'domains', :locals => {:domain_counts => domain_counts} and return
  end  
  
end
