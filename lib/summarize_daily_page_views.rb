# Summarize the page views on a day.
# Runs on the earliest un-processed date up to 2 days ago.


# Get the date to process
most_recently_processed = DailyTotalView.order("date DESC").limit(1).first
if most_recently_processed
  date_to_process = most_recently_processed.date + 1.day
else
  # If this is our first processing, start at the earliest date for
  # which we have data.
  date_to_process = Date.parse("2011-02-01").to_date
end

if date_to_process < 2.days.ago.to_date
  
  total_views = DailyPageView.summarize_by_date(date_to_process)
  unless DailyTotalView.exists?(:date => date_to_process)
    DailyTotalView.create(:total_views => total_views, :date => date_to_process)
  end
  
end


