Feature: Manage roles
  In order to provide roles users can possess in an organization
  As an office-oriented access control system
  I want to create, show, list, and destroy roles

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario Outline: Test permissions for roles controller actions
    Given an role: "basic" exists
    And I am logged in as "<user>" with password "secret"
    And I am on the new role page
    Then I should <create>
    Given I post on the roles page
    Then I should <create>
    And I am on the edit page for role: "basic"
    Then I should <update>
    Given I put on the page for role: "basic"
    Then I should <update>
    Given I am on the page for role: "basic"
    Then I should <show>
    Given I delete on the page for role: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new role and edit
    Given I am logged in as "admin" with password "secret"
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
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd role
    Then I should see the following roles:
      |Name  |
      |role 1|
      |role 2|
      |role 4|

