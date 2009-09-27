Feature: Manage categories
  In order to group funds
  As a finance manager
  I want to create and delete categories

  Background:
    Given the following users:
      | net_id | password | admin |
      | admin  | secret   | true  |

  Scenario: Register new category
    Given I am logged in as "admin" with password "secret"
    And I am on the new category page
    When I fill in "Name" with "name 1"
    And I press "Create"
    Then I should see "name 1"

  Scenario: Delete category
    Given the following categories:
      |name  |
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd category
    Then I should see the following categories:
      |Name  |
      |name 1|
      |name 2|
      |name 4|

