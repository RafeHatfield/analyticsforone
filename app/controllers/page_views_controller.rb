class PageViewsController < ApplicationController
  before_filter :set_start_and_end_date
  @@PER_PAGE = 20
  
  def for_article
    counts = DailyPageView.counts_for_article_between(params[:article_id], @start_date, @end_date)
    render :json => counts.to_json
  end
  
  def for_writer
    counts = DailyPageView.counts_for_writer_between(params[:writer_id], @start_date, @end_date)
    render :json => counts.to_json
  end

end
