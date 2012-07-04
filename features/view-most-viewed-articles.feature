# @most_successful @pageviews
# Feature: View most viewed articles
# In order to focus my efforts on my most valuable ideas
# As a Suite101 writer
# I want to see which of my articles are generating the most page views
# 	
# 	@most_successful	@wip
# 	Scenario: View stats dashboard with more than 10 articles
# 		Given I am a Suite101 writer
# 			And I have at least 10 articles published
# 		When I log into Suite101 Stats
# 		Then I should see my top 10 "most viewed" articles over the last week
# 			And the "page view" graph for each article.
# 
# 	@most_successful	@wip		
# 	Scenario: View stats dashboard with less than 10 articles
# 		Given I am a Suite101 writer
# 			And I have less than 10 articles published
# 		When I log into Suite101 Stats
# 		Then I should see all my articles
# 			And the "page view" graph for each article