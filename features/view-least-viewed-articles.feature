# @least_successful @pageviews
# Feature: View least successful articles
# In order to focus my efforts on my most valuable ideas
# As a Suite101 writer with more than 20 articles
# I want to see which of my articles are generating the least traffic
# 	
# 	Background:
# 		Given I am a Suite101 writer
# 			And I have more than 20 articles published
# 			
# 	Scenario: View 5 (plus ties) lowest traffic articles
# 		Given I am logged into Suite101 Stats 
# 		When I click "Which articles aren't getting traffic"
# 		Then I should see the articles with the least number of page views.
