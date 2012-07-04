module ApplicationHelper
  
  def display_article_title(raw_title)
    truncate(CGI.unescape(raw_title), :length => 60, :separator => ' ')
  end
  
end
