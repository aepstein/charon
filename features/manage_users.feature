Feature: Manage users
  In order to authenticate and authorize people to work within the system
  As a user-based system
  I want to create, show, update, delete, and list user accounts

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true, last_name: "Bo 4"
    And a user: "owner" exists with net_id: "owner", password: "secret", admin: false, last_name: "Bo 3"
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false, last_name: "Bo 2"
    And a user exists with last_name: "Bo 1", net_id: "zzz4"

  Scenario Outline: Test permissions for users controller actions
    Given I am logged in as "<user>" with password "secret"
    And I am on the new user page
    Then I should <create>
    Given I post on the users page
    Then I should <create>
    And I am on the edit page for user: "owner"
    Then I should <update>
    Given I put on the page for user: "owner"
    Then I should <update>
    Given I am on the page for user: "owner"
    Then I should <show>
    Given I delete on the page for user: "owner"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | owner   | see "Unauthorized"     | not see "Unauthorized" | see "Unauthorized"     | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |

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
    Given I am logged in as "admin" with password "secret"
    And I am on the users page
    Then I should see the following users:
      | Name          |
      | John Bo 1     |
      | John Bo 2     |
      | John Bo 3     |
      | John Bo 4     |
    When I fill in "Search" with "4"
    And I press "Go"
    Then I should see the following users:
      | Name                | Net Id   |
      | John Bo 1           | zzz4     |
      | John Bo 4           | admin    |

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
    Given a role: "president" exists with name: "president"
    And a role: "allowed" exists with name: "allowed"
    And an organization: "matched" exists with last_name: "matched organization"
    And an organization: "unregistered" exists with last_name: "unregistered organization"
    And an organization: "irrelevant" exists with last_name: "irrelevant organization"
    And a registration: "matched" exists with organization: organization "matched"
    And a registration: "unmatched" exists with name: "unmatched organization"
    And a registration: "irrelevant registration" exists with name: "irrelevant registration"
    And a membership exists with user: user "owner", role: role "allowed", registration: registration "matched"
    And a membership exists with user: user "owner", role: role "allowed", registration: registration "unmatched"
    And a membership exists with user: user "owner", role: role "allowed", organization: organization "unregistered", active: true
    And I am logged in as "owner" with password "secret"
    And I am on the profile page
    Then I should see "matched organization"
    And I should see "unmatched organization"
    And I should see "unregistered organization"
    And I should not see "irrelevant organization"
    And I should not see "irrelevant registration"

  Scenario: Delete user
    Given I am logged in as "admin" with password "secret"
    When I delete the 3rd user
    Then I should see "User was successfully destroyed."
    And I should see the following users:
      | Name          |
      | John Bo 1     |
      | John Bo 2     |
      | John Bo 4     |

