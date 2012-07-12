Feature: Manage categories
  In order to group funds
  As a finance manager
  I want to create and delete categories

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true

  Scenario Outline: Test permissions for categories controller actions
    Given a user: "regular" exists
    And a category exists with name: "Durable Goods"
    And I log in as user: "<user>"
    And I am on the page for the category
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the categories page
    Then I should <show> authorized
    And I should <show> "Durable Goods"
    And I should <create> "New category"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new category page
    Then I should <create> authorized
    Given I post on the categories page
    Then I should <create> authorized
    And I am on the edit page for the category
    Then I should <update> authorized
    Given I put on the page for the category
    Then I should <update> authorized
    Given I delete on the page for the category
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | staff   | see     | see     | not see | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Register new category and update
    Given I log in as user: "admin"
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
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd category
    Then I should see the following categories:
      |Name      |
      |category 1|
      |category 2|
      |category 4|

