Feature: Manage roles
  In order to provide roles users can possess in an organization
  As an office-oriented access control system
  I want to create, show, list, and destroy roles

  Background:
    Given the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
      | regular | secret   | false |

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

  Scenario Outline:
    Given I am logged in as "<user>" with password "secret"
    And I am on the new role page
    Then I should see "<see>"

    Examples:
      | user    | see          |
      | admin   | New role     |
      | regular | Unauthorized |

  Scenario: Delete role
    Given the following roles:
      |name|
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd role
    Then I should see the following roles:
      |Name|
      |name 1|
      |name 2|
      |name 4|

