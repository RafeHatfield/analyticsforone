require 'test_helper'

class DailyTotalViewTest < ActiveSupport::TestCase
  should "be valid" do
    assert DailyTotalView.new.valid?
  end
end
