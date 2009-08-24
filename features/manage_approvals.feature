@wip
Feature: Manage approvals
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  Scenario: Register new approval
    Given I am on the new approval page
    When I fill in "User" with "user_id 1"
    And I press "Create"
    Then I should see "user_id 1"

  Scenario: Delete approval
    Given the following approvals:
      |user_id|
      |user_id 1|
      |user_id 2|
      |user_id 3|
      |user_id 4|
    When I delete the 3rd approval
    Then I should see the following approvals:
      |User|
      |user_id 1|
      |user_id 2|
      |user_id 4|

