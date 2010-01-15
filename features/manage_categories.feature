Feature: Manage categories
  In order to group funds
  As a finance manager
  I want to create and delete categories

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario Outline: Test permissions for categories controller actions
    Given an category: "basic" exists
    And I am logged in as "<user>" with password "secret"
    And I am on the new category page
    Then I should <create>
    Given I post on the categories page
    Then I should <create>
    And I am on the edit page for category: "basic"
    Then I should <update>
    Given I put on the page for category: "basic"
    Then I should <update>
    Given I am on the page for category: "basic"
    Then I should <show>
    Given I delete on the page for category: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new category and update
    Given I am logged in as "admin" with password "secret"
    And I am on the new category page
    When I fill in "Name" with "local event"
    And I press "Create"
    Then I should see "Category was successfully created."
    And I should see "Name: local event"
    When I follow "Edit"
    And I fill in "Name" with "travel event"
    And I press "Update"
    Then I should see "Category was successfully updated."
    And I should see "Name: travel event"

  Scenario: Delete category
    Given a category exists with name: "category 4"
    And a category exists with name: "category 3"
    And a category exists with name: "category 2"
    And a category exists with name: "category 1"
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd category
    Then I should see the following categories:
      |Name      |
      |category 1|
      |category 2|
      |category 4|

