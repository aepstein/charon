Feature: Manage roles
  In order to provide roles users can possess in an organization
  As an office-oriented access control system
  I want to create, show, list, and destroy roles

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for roles controller actions
    Given a role: "basic" exists with name: "Focus"
    And I log in as user: "<user>"
    Given I am on the page for role: "basic"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the roles page
    Then I should <show> authorized
    And I should <show> "Focus"
    And I should <create> "New role"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new role page
    Then I should <create> authorized
    Given I post on the roles page
    Then I should <create> authorized
    And I am on the edit page for role: "basic"
    Then I should <update> authorized
    Given I put on the page for role: "basic"
    Then I should <update> authorized
    Given I delete on the page for role: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show |
      | admin   | see     | see     | see     | see  |
      | regular | not see | not see | not see | see  |

  Scenario: Register new role and edit
    Given I log in as user: "admin"
    And I am on the new role page
    When I fill in "Name" with "leader"
    And I press "Create"
    Then I should see "Role was successfully created."
    And I should see "leader"
    When I follow "Edit"
    And I fill in "Name" with "follower"
    And I press "Update"
    Then I should see "Role was successfully updated."
    And I should see "follower"

  Scenario: Delete role
    Given a role exists with name: "role 4"
    And a role exists with name: "role 3"
    And a role exists with name: "role 2"
    And a role exists with name: "role 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd role
    Then I should see the following roles:
      |Name  |
      |role 1|
      |role 2|
      |role 4|

