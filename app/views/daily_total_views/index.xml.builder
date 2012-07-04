xml.instruct!
xml.root do
  
  @daily_total_views.each do |daily_total_view|
    xml.item daily_total_view.total_views
  end    
    
  xml.settings do
    @x_axis_dates.each do |date|
      xml.axisx date.strftime('%b %d %Y')
    end
    
    xml.axisy @min_views
    xml.axisy @max_views
  end

end