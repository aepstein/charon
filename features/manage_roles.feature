Feature: Manage roles
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new role
    Given I am on the new role page
    When I fill in "Name" with "name 1"
    And I press "Create"
    Then I should see "name 1"

  Scenario: Delete role
    Given the following roles:
      |name|
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd role
    Then I should see the following roles:
      |Name|
      |name 1|
      |name 2|
      |name 4|
