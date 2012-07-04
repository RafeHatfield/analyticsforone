Given /^Homer has a writer_id (\d+)$/ do |id|
  @homer_id = id
end

When /^Homer visits the dashboard with the proper key$/ do
  @key = Base64.encode64(@homer_id)
  visit dashboard_url(@homer_id, @key)
end

When /^Homer visits the dashboard with the wrong key$/ do
  @key = "awesomesauce"
  visit dashboard_url(@homer_id, @key)
end

Then /^Homer sees his dashboard$/ do
  within("h1") do
    assert_equal true, page.has_content?("My stats")
  end
end

Then /^Homer sees a 404 error page$/ do
  assert_equal 404, page.driver.status_code
  assert_equal true, page.has_content?("The page you were looking for doesn't exist.")
end
