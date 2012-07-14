Feature: Manage user_status_criterions
  In order to keep and track user_status_criterions
  As a contract-bound organization
  I want to create, edit, destroy, show, and list user_status_criterions

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And a user: "regular" exists

  Scenario: Register new user_status_criterion
    Given I log in as user: "admin"
    And I am on the new user_status_criterion page
    When I check "undergrad"
    And I press "Create"
    Then I should see "User status criterion was successfully created."
    And I should see "Statuses: undergrad"
    When I follow "Edit"
    And I uncheck "undergrad"
    And I check "grad"
    And I check "staff"
    And I press "Update"
    Then I should see "User status criterion was successfully updated."
    And I should see "Statuses: grad, staff"

  Scenario Outline: Test permissions for user_status_criterions controller actions
    Given an user_status_criterion: "basic" exists
    And I log in as user: "<user>"
    And I am on the new user_status_criterion page
    Then I should <create> authorized
    Given I post on the user_status_criterions page
    Then I should <create> authorized
    And I am on the edit page for user_status_criterion: "basic"
    Then I should <update> authorized
    Given I put on the page for user_status_criterion: "basic"
    Then I should <update> authorized
    Given I am on the page for user_status_criterion: "basic"
    Then I should <show> authorized
    Given I delete on the page for user_status_criterion: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | staff   | see     | see     | not see | see     |
      | regular | not see | not see | not see | see     |
#TODO
#  Scenario: Delete user_status_criterion
#    Given I log in as user: "admin"
#    And an user_status_criterion exists with name: "name 4", content: "content"
#    And an user_status_criterion exists with name: "name 3", content: "content"
#    And an user_status_criterion exists with name: "name 2", content: "content"
#    And an user_status_criterion exists with name: "name 1", content: "content"
#    When I follow "Destroy" for the 3rd user_status_criterion
#    Then I should see the following user_status_criterions:
#      |Name  |
#      |name 1|
#      |name 2|
#      |name 4|

