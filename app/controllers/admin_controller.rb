class AdminController < ApplicationController
  def index
    @raw_page_views = RawPageView.limit(100)
  end
  
end
