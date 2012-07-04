Feature: Authentication

Scenario: Successful login
  Given Homer has a writer_id 123
  When Homer visits the dashboard with the proper key
  Then Homer sees his dashboard
  
Scenario: Successful login
  Given Homer has a writer_id 123
  When Homer visits the dashboard with the wrong key
  Then Homer sees a 404 error page
  


# @authentication
# Feature: Provide authentication functionality for Suite101 Stats
# 	In order to stop other people from seeing my stats
# 	As a Suite101 writer
# 	I want to have my stats be password protected
# 	
# 	Scenario: Successful login
# 		Given "Homer" has an account at Suite101
# 		When "Homer" enters correct details for login
# 		Then "Homer" is logged in
# 			And stays on the page he was reading
# 	
# 	Scenario: Unsuccessful login 3 times in a row
# 		Given "Homer" has an account at Suite101
# 			And "Homer" has entered the wrong details for login 2 times in a row
# 		When "Homer" enters wrong details for login
# 		Then "Homer" goes to the "login blocked" page
# 			And "Homer"'s IP is blocked from logging in for 2 hours.
# 		
# 	Scenario: Unsuccessful login
# 		Given "Homer" has an account at Suite101
# 		When "Homer" enters wrong details for login
# 		Then "Homer" goes to the "login failed" page
# 
# 	Scenario: Access Suite101 Stats
# 		Given "Homer" isn't logged in
# 		When "Homer" visits any page in Suite101 Stats other than the "login" page
# 		Then "Homer" goes to the "login" page
# 
# 	Scenario: Can't access another person's stats
# 		Given "Homer" is logged in
# 			And "Solon" has an account at Suite101
# 		When "Homer" visits a page with "Solon"'s stats
# 		Then "Homer" goes to the "permission denied" page
# 		
