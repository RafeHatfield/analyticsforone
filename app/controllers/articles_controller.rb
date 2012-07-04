class ArticlesController < ApplicationController
  before_filter :set_start_and_end_date
  before_filter :get_user
  @@PER_PAGE = 20
  
  def for_writer
		if params[:limit].to_i > 5000
			params[:limit] = 5000
		end
		
    @article_counts = DailyPageView.article_counts_for_writer_between(params[:writer_id], @start_date, @end_date, params[:limit].to_i || @@PER_PAGE, params[:offset] || 0)
    
    # Update the number of articles to show.
    session[:articles_length] = session[:articles_length].to_i + params[:limit].to_i
      
    render :partial => 'articles', :locals => {:article_counts => @article_counts} and return
  end
      
end
