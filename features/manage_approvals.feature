Feature: Manage approvals
  In order to digitally sign documents
  As a duty-bound organization
  I want to create and destroy approvals

  Background:
    Given the following users:
      | net_id    | password | admin |
      | admin     | secret   | true  |
      | regular   | secret   | false |
      | president | secret   | false |
      | treasurer | secret   | false |
      | advisor   | secret   | false |
    And the following roles:
      | name      |
      | president |

  Scenario: Register new approval (agreement)
    Given the following agreements:
      | name | content        |
      | safc | some agreement |
    And the following permissions:
      | role      | agreements |
      | president | safc       |
    And the following memberships:
      | role      | user      |
      | president | president |
    And I am logged in as "president" with password "secret"
    When I follow "Approve"
    Then I should see "Name: safc"
    Given the Agreement records are updated 2 seconds later
    When I press "Confirm Approval"
    Then I should not see "Approval was successfully created."
    When I press "Confirm Approval"
    Then I should see "Approval was successfully created."

  @wip
  Scenario: Register new approval (request)

  @wip
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

