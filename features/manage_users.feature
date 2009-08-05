Feature: Manage users
  In order to authenticate and authorize people to work within the system
  As a user-based system
  I want to create, show, update, delete, and list user accounts

  Background:
    Given the following users:
      | net_id  | admin | password |
      | admin   | true  | secret   |
      | owner   | false | secret   |
      | regular | false | secret   |

  Scenario: Create a new user
    Given I am logged in as "admin" with password "secret"
    And I am on the new user page
    When I fill in "Net" with "net_id"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I fill in "First name" with "first"
    And I fill in "Last name" with "last"
    And I fill in "Email" with "net_id@example.com"
    And I fill in "Date of birth" with "1982-06-04"
    And I check "Admin"
    And I press "Create"
    Then I should see "User was successfully created."
    Given I am on "net_id's show user page"
    Then I should see "Admin: Yes"

  Scenario Outline: New user form
    Given I am logged in as "<user>" with password "secret"
    And I am on the new user page
    Then I should <action>
    And I should be on <page>

    Examples:
      | user    | action          | page                  |
      | admin   | see "Admin"     | the new user page     |
      | owner   | not see "Admin" | the unauthorized page |
      | regular | not see "Admin" | the unauthorized page |

  Scenario Outline: Edit user form
    Given I am logged in as "<user>" with password "secret"
    And I am on "owner's edit user page"
    Then I should <action>
    And I should be on <page>

    Examples:
      | user    | action          | page                     |
      | admin   | see "Admin"     | "owner's edit user page" |
      | owner   | not see "Admin" | "owner's edit user page" |
      | regular | not see "Admin" | the unauthorized page    |

  Scenario: Show organizations and unmatched registrations for the current user
    Given the following role records:
      | name      |
      | president |
      | allowed   |
    And the following organizations:
      | last_name                      |
      | matched organization           |
      | unregistered organization      |
      | irrelevant organization        |
    And the following registrations:
      | name                    | organization                 |
      | matched organization    | matched organization         |
      | unmatched organization  |                              |
      | irrelevant registration |                              |
    And the following memberships:
      | user  | role      | registration           | active | organization              |
      | owner | allowed   | matched organization   |        |                           |
      | owner | allowed   | unmatched organization |        |                           |
      | owner | allowed   |                        | true   | unregistered organization |
    And I am logged in as "owner" with password "secret"
    And I am on the profile page
    Then I should see "matched organization"
    And I should see "unmatched organization"
    And I should see "unregistered organization"
    And I should not see "irrelevant organization"
    And I should not see "irrelevant registration"

  Scenario: Delete user
    Given I am logged in as "admin" with password "secret"
    When I delete the 2nd user
    Then I should see "User was successfully destroyed."

