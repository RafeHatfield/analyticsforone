class ReportsController < ApplicationController
  before_filter :get_user, :except => [:test_dashboard]
  before_filter :set_start_and_end_date, :except => [:test_dashboard]
  
  # Show the writer's dashboard.
  def dashboard
  end
  
  # Generate a key for the user and redirect to their dashbaord
  def test_dashboard
    redirect_to dashboard_url(params[:writer_id].to_i.alphadecimal)    
  end
    
  # Dashboard for a specific article.
  def article_dashboard
    @article = Article.find(params[:article_id])  
  end
        
  def article_views_csv
    @article_counts = DailyPageView.article_counts_for_writer_between(@user[:id], @start_date, @end_date, 5000, 0)
    
    csv_string = FasterCSV.generate do |csv|
      csv << [I18n.t('report.article'), "#{I18n.t('report.views')} (#{I18n.l(@start_date)} - #{I18n.l(@end_date)})"]
      @article_counts.each do |article_count|
        csv << [CGI.unescape(article_count[:title]), article_count[:count]]
      end
    end

    send_data csv_string,
              :type => 'text/csv; charset=iso-8859-1; header=present',
              :disposition => "attachment; filename=#{I18n.t('report.suite101_article_stats')}.csv"    
  end

private
  
  # Parse the date from a rails select_date tag.
  def get_selected_date(date_hash, default)
    if date_hash
      Date.civil(date_hash["year"].to_i, date_hash["month"].to_i, date_hash["day"].to_i)
    else
      default
    end
  end
  
  # this method is required since there is a discrepancy between daily page views count and daily domain views count
  # This method is a hack to remove the discrepeancy
  def calibrated_count(source_counts, daily_page_views_count)
    internal_and_organic_count = source_counts[:internal] + source_counts[:organic]
    other_count = daily_page_views_count - internal_and_organic_count
    source_counts[:other] = other_count
    source_counts
  end
    
end
