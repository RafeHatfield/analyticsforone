class MysuiteIntegrationController < ApplicationController
    before_filter :get_user
    
    # Redirect to a google sparkline showing the cumulative percentage of page views over the last 12 weeks.
    def page_view_sparkline
      view_counts = DailyPageView.counts_for_writer_between(@user[:id], Date.today.at_beginning_of_week - 11.weeks, Date.today)

      view_counts_by_week = []
      view_counts.in_groups_of(7, false) do |week_counts|
        view_counts_by_week << week_counts.sum
      end

      total_view_counts = view_counts_by_week.sum    
			
			if total_view_counts == 0
				total_view_counts = 1
			end
			
      sum = 0
      cumulative_view_counts = view_counts_by_week.map {|count| sum += count}
      cumulative_percentages = cumulative_view_counts.map {|count| (100 * count / total_view_counts).to_i}

      redirect_to "http://chart.apis.google.com/chart?cht=lc&chs=50x16&chco=369E00&chd=t:#{cumulative_percentages.join(',')}&chf=bg,s,FFFFFF00&chls=2,1,0"
    end

    # Render a chart showing the view counts for the writer in the last 12 weeks,
    # summed by week.
    def twelve_week_page_view_graph
      @start_date = Date.today.at_beginning_of_week - 11.weeks
      view_counts = DailyPageView.counts_for_writer_between(@user[:id], @start_date, Date.today)
      @view_counts_by_week = []
      view_counts.in_groups_of(7, false) do |week_counts|
        @view_counts_by_week << week_counts.sum
      end

      render :layout => false       
    end

    # Render a chart showing this week vs last week's page views.
    def weekly_page_view_graph
      @this_start_date = Date.today.at_beginning_of_week - 1.day
      @this_end_date = Date.today.at_end_of_week - 1.day
      @last_start_date = @this_start_date - 1.week
      @last_end_date = @this_start_date - 1.day
      # NOTE: We subtract 1 day to use Sunday as the beginning of the week,
      # since this is how mysuite does it currently.

      @view_counts_this_week = DailyPageView.counts_for_writer_between(@user[:id], @this_start_date, @this_end_date)
      @view_counts_last_week = DailyPageView.counts_for_writer_between(@user[:id], @last_start_date, @last_end_date) 

      render :layout => false   
    end

    # Render a chart showing this month vs last month's page views.
    def monthly_page_view_graph
      @this_start_date = Date.today.at_beginning_of_month
      @this_end_date = Date.today
      @last_start_date = 1.month.ago.at_beginning_of_month.to_date
      @last_end_date = 1.month.ago.at_end_of_month.to_date

      @view_counts_this_month = DailyPageView.counts_for_writer_between(@user[:id], @this_start_date, @this_end_date)
      @view_counts_last_month = DailyPageView.counts_for_writer_between(@user[:id], @last_start_date, @last_end_date)

      # Nil pad the arrays so that they contain the same number of days,
      # so that the axes display properly.
      while @view_counts_this_month.count < 31
        @view_counts_this_month << nil
      end
      while @view_counts_last_month.count < 31
        @view_counts_last_month << nil
      end

      render :layout => false
    end
  
    # Render javascript which will update the #total_page_views element with the lifetime page views of this user.
    def update_total_page_views
      total_page_views = DailyPageView.counts_for_writer_between(@user[:id], 90.days.ago.to_date, Date.today).sum
      render :js => "$(function(){$('#total_page_views').text(#{total_page_views});});"
    end
end
