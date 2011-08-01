Feature: Manage users
  In order to authenticate and authorize people to work within the system
  As a user-based system
  I want to create, show, update, delete, and list user accounts

  Background:
    Given a user: "admin" exists with admin: true, last_name: "Bo 4"
    And a user: "owner" exists with last_name: "Bo 3", net_id: "zzz3332"
    And a user: "regular" exists with last_name: "Bo 2", net_id: "zzz3333"
    And a user exists with last_name: "Bo 1", net_id: "zzz4444"

  Scenario Outline: Test permissions for users controller actions
    Given I log in as user: "<user>"
    And I am on the page for user: "owner"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the users page
    And I fill in "Name" with "Bo 3"
    And I press "Search"
    Then I should <show> "Bo 3"
    And I should <create> "New user"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new user page
    Then I should <create> authorized
    Given I post on the users page
    Then I should <create> authorized
    And I am on the edit page for user: "owner"
    Then I should <update> authorized
    Given I put on the page for user: "owner"
    Then I should <update> authorized
    Given I delete on the page for user: "owner"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | owner   | not see | see     | not see | see     |
      | regular | not see | not see | not see | not see |
@wip
  Scenario: Create a new user and edit
    Given I log in as user: "admin"
    And I am on the new user page
    When I fill in "Net" with "net_id"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I fill in "First name" with "first"
    And I fill in "Middle name" with "middle"
    And I fill in "Last name" with "last"
    And I fill in "Email" with "net_id@example.com"
    And I fill in "Date of birth" with "1982-06-04"
    And I choose "Yes"
    And I fill in "Label" with "home"
    And I fill in "Street" with "100 the Commons"
    And I fill in "City" with "Ithaca"
    And I fill in "State" with "NY"
    And I fill in "Zip" with "14850"
    And I choose "off campus"
    And I press "Create"
    Then I should see "User was successfully created."
    And I should see "First name: first"
    And I should see "Middle name: middle"
    And I should see "Last name: last"
    And I should see "Email: net_id@example.com"
    And I should see "Date of birth: June 4, 1982"
    And I should see "Administrator? Yes"
    And I should see "Home street: 100 the Commons"
    And I should see "Home city: Ithaca"
    And I should see "Home state: NY"
    And I should see "Home zip: 14850"
    And I should see "Home is on campus? No"
    When I follow "Edit"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I fill in "First name" with "new"
    And I fill in "Middle name" with "second"
    And I fill in "Last name" with "name"
    And I fill in "Email" with "other@example.com"
    And I fill in "Date of birth" with "1982-06-05"
    And I choose "No"
    And I fill in "Home street" with "109 Day Hall"
    And I fill in "Home city" with "Ithaca"
    And I fill in "Home state" with "NY"
    And I fill in "Home zip" with "14853"
    And I choose "on campus"
    And I press "Update"
    Then I should see "User was successfully updated."
    And I should see "First name: new"
    And I should see "Middle name: second"
    And I should see "Last name: name"
    And I should see "Email: other@example.com"
    And I should see "Date of birth: June 5, 1982"
    And I should see "Administrator? No"
    And I should see "Home street: 109 Day Hall"
    And I should see "Home city: Ithaca"
    And I should see "Home state: NY"
    And I should see "Home zip: 14853"
    And I should see "Home is on campus? Yes"

  Scenario: List and search users
    Given I log in as user: "admin"
    And I am on the users page
    Then I should see the following users:
      | Name          |
      | John Bo 1     |
      | John Bo 2     |
      | John Bo 3     |
      | John Bo 4     |
    When I fill in "Name" with "4"
    And I press "Search"
    Then I should see the following users:
      | Name                |
      | John Bo 1           |
      | John Bo 4           |

  Scenario: Show organizations and unmatched registrations for the current user
    Given a role: "president" exists with name: "president"
    And a role: "allowed" exists with name: "allowed"
    And a organization: "matched" exists with last_name: "matched organization"
    And an organization: "unregistered" exists with last_name: "unregistered organization"
    And an organization: "irrelevant" exists with last_name: "irrelevant organization"
    And a current_registration: "matched" exists with organization: organization "matched"
    And a current_registration: "unmatched" exists with name: "unmatched organization"
    And a current_registration: "irrelevant registration" exists with name: "irrelevant registration"
    And a membership exists with user: user "owner", role: role "allowed", registration: registration "matched"
    And a membership exists with user: user "owner", role: role "allowed", registration: registration "unmatched"
    And a membership exists with user: user "owner", role: role "allowed", organization: organization "unregistered", active: true
    And I log in as user: "owner"
    And I am on the profile page
    Then I should see "matched organization"
    And I should see "unmatched organization"
    And I should see "unregistered organization"
    And I should not see "irrelevant organization"
    And I should not see "irrelevant registration"

  Scenario: Delete user
    Given I log in as user: "admin"
    When I follow "Destroy" for the 3rd user
    Then I should see "User was successfully destroyed."
    And I should see the following users:
      | Name          |
      | John Bo 1     |
      | John Bo 2     |
      | John Bo 4     |

