Feature: Manage users
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new user
    Given I am on the new user page
    When I fill in "Net" with "net_id 1"
    And I fill in "Password" with "password 1"
    And I fill in "First name" with "first_name 1"
    And I fill in "Email" with "email 1"
    And I fill in "First name" with "first_name 1"
    And I fill in "Middle name" with "middle_name 1"
    And I fill in "Last name" with "last_name 1"
    And I press "Create"
    Then I should see "net_id 1"
    And I should see "password 1"
    And I should see "first_name 1"
    And I should see "email 1"
    And I should see "first_name 1"
    And I should see "middle_name 1"
    And I should see "last_name 1"

  Scenario: Delete user
    Given the following users:
      |net_id|password|first_name|email|first_name|middle_name|last_name|
      |net_id 1|password 1|first_name 1|email 1|first_name 1|middle_name 1|last_name 1|
      |net_id 2|password 2|first_name 2|email 2|first_name 2|middle_name 2|last_name 2|
      |net_id 3|password 3|first_name 3|email 3|first_name 3|middle_name 3|last_name 3|
      |net_id 4|password 4|first_name 4|email 4|first_name 4|middle_name 4|last_name 4|
    When I delete the 3rd user
    Then I should see the following users:
      |net_id|password|first_name|email|first_name|middle_name|last_name|
      |net_id 1|password 1|first_name 1|email 1|first_name 1|middle_name 1|last_name 1|
      |net_id 2|password 2|first_name 2|email 2|first_name 2|middle_name 2|last_name 2|
      |net_id 4|password 4|first_name 4|email 4|first_name 4|middle_name 4|last_name 4|
