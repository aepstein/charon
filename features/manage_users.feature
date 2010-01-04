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

  Scenario: Create a new user and edit
    Given I am logged in as "admin" with password "secret"
    And I am on the new user page
    When I fill in "Net" with "net_id"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I fill in "First name" with "first"
    And I fill in "Middle name" with "middle"
    And I fill in "Last name" with "last"
    And I fill in "Email" with "net_id@example.com"
    And I fill in "Date of birth" with "1982-06-04"
    And I choose "user_admin_true"
    And I press "Create"
    Then I should see "User was successfully created."
    And I should see "First name: first"
    And I should see "Middle name: middle"
    And I should see "Last name: last"
    And I should see "Email: net_id@example.com"
    And I should see "Date of birth: June  4, 1982"
    And I should see "Admin: Yes"
    When I follow "Edit"
    And I fill in "Net" with "net_id"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I fill in "First name" with "new"
    And I fill in "Middle name" with "second"
    And I fill in "Last name" with "name"
    And I fill in "Email" with "other@example.com"
    And I fill in "Date of birth" with "1982-06-05"
    And I choose "user_admin_false"
    And I press "Update"
    Then I should see "User was successfully updated."
    And I should see "First name: new"
    And I should see "Middle name: second"
    And I should see "Last name: name"
    And I should see "Email: other@example.com"
    And I should see "Date of birth: June  5, 1982"
    And I should see "Admin: No"

  Scenario: List and search users
    Given there are no users
    And the following users:
      | last_name | net_id  | admin | password |
      | Adminirov | fake    | false | secret   |
      | Doe 1     | admin   | true  | secret   |
      | Doe 2     | owner   | false | secret   |
      | Doe 3     | regular | false | secret   |
    And I am logged in as "admin" with password "secret"
    And I am on the users page
    Then I should see the following users:
      | Name           | Net Id  |
      | John Adminirov | fake    |
      | John Doe 1     | admin   |
      | John Doe 2     | owner   |
      | John Doe 3     | regular |
    When I fill in "Search" with "admin"
    And I press "Go"
    Then I should see the following users:
      | Name           | Net Id |
      | John Adminirov | fake   |
      | John Doe 1     | admin  |

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

  Scenario Outline: Display administrative options for admin on profile page
    Given I am logged in as "<user>" with password "secret"
    And I am on the profile page
    Then I <see> see "Administration"

    Examples:
      | user  | see        |
      | admin | should     |
      | owner | should not |

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
    And the following agreements:
      | name   |
      | safc   |
      | gpsafc |
    And the following permissions:
      | role    | agreements   |
      | allowed | safc, gpsafc |
    And the following approvals:
      | agreement | user  |
      | safc      | owner |
    And I am logged in as "owner" with password "secret"
    And I am on the profile page
    Then I should see "matched organization"
    And I should see "unmatched organization"
    And I should see "unregistered organization"
    And I should not see "irrelevant organization"
    And I should not see "irrelevant registration"
    And I should see the following entries in "accepted_agreements":
      | Approvable |
      | safc       |
    And I should see the following entries in "unfulfilled_agreements":
      | Approvable |
      | gpsafc     |

  Scenario: Delete user
    Given I am logged in as "admin" with password "secret"
    When I delete the 2nd user
    Then I should see "User was successfully destroyed."

