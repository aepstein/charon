Feature: Manage university_accounts
  In order to track university accounts associated with organizations
  As a staff member
  I want to manage university accounts

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true

  Scenario Outline: Test permissions for university_accounts controller
    Given an organization exists
    And a user: "member" exists
    And a requestor_role exists
    And a membership exists with user: user "member", organization: the organization, role: the requestor_role
    And a user: "regular" exists
    And a university_account exists with account_code: "A000000", organization: the organization
    And I log in as user: "<user>"
    And I am on the new university_account page for the organization
    Then I should <create> authorized
    Given I post on the university_accounts page for the organization
    Then I should <create> authorized
    And I am on the edit page for the university_account
    Then I should <update> authorized
    Given I put on the page for the university_account
    Then I should <update> authorized
    Given I am on the page for the university_account
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the university_accounts page for the organization
    Then I should <show> "A000000"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New university account"
    Given I am on the university_accounts page
    Then I should <show> "A00"
    Given I am on the activate university_accounts page
    Then I should <activate> authorized
    Given I put on the do_activate university_accounts page
    Then I should <activate> authorized
    Given I delete on the page for the university_account
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | show    | destroy | activate |
      | admin   | see     | see     | see     | see     | see      |
      | staff   | see     | see     | see     | not see | see      |
      | member  | not see | not see | not see | not see | not see  |
      | regular | not see | not see | not see | not see | not see  |

  Scenario: Create and update university_accounts
    Given an organization: "first" exists with last_name: "Spending Club"
    And an organization: "last" exists with last_name: "Other Spending Club", first_name: "The"
    And I log in as user: "admin"
    And I am on the new university_account page for organization: "first"
    When I fill in "Account code" with "A000001"
    And I fill in "Subaccount code" with "00000"
    And I choose "Yes"
    And I press "Create"
    Then I should see "University account was successfully created."
    And I should see "Organization: Spending Club"
    And I should see "Account code: A000001"
    And I should see "Subaccount code: 00000"
    And I should see "Active? Yes"
    When I follow "Edit"
    And I fill in "Organization" with "Other Spending Club, The"
    And I fill in "Account code" with "A000001"
    And I fill in "Subaccount code" with "00005"
    And I choose "No"
    And I press "Update"
    Then I should see "University account was successfully updated."
    And I should see "Organization: The Other Spending Club"
    And I should see "Account code: A000001"
    And I should see "Subaccount code: 00005"
    And I should see "Active? No"

  Scenario: List and delete university accounts
    Given an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a university_account exists with account_code: "B000002", organization: organization "last"
    And a university_account exists with account_code: "B000001", organization: organization "last"
    And a university_account exists with account_code: "A000002", organization: organization "first"
    And a university_account exists with account_code: "A000001", organization: organization "first"
    And I log in as user: "admin"
    And I am on the university_accounts page
    When I fill in "Account code" with "A0"
    And I press "Search"
    Then I should see the following university_accounts:
      | Organization | Account code | Subaccount code |
      | First Club   | A000001      | 00000           |
      | First Club   | A000002      | 00000           |
    Given I am on the university_accounts page
    And I fill in "Account code" with "01"
    And I press "Search"
    Then I should see the following inventory_items:
      | Organization | Account code | Subaccount code |
      | First Club   | A000001      | 00000           |
      | Last Club    | B000001      | 00000           |
    Given I am on the university_accounts page
    When I fill in "Organization" with "first"
    And I press "Search"
    Then I should see the following university_accounts:
      | Organization | Account code | Subaccount code |
      | First Club   | A000001      | 00000           |
      | First Club   | A000002      | 00000           |
    Given I am on the university_accounts page for organization: "first"
    Then I should see the following university_accounts:
      | Account code | Subaccount code |
      | A000001      | 00000           |
      | A000002      | 00000           |
    When I follow "Destroy" for the 3rd university_account
    And I am on the university_accounts page
    Then I should see the following university_accounts:
      | Organization | Account code | Subaccount code |
      | First Club   | A000001      | 00000           |
      | First Club   | A000002      | 00000           |
      | Last Club    | B000002      | 00000           |

  Scenario: Activate university accounts in bulk
    Given a university_account: "active" exists with account_code: "A000000", subaccount_code: "00000", active: true
    And a university_account: "inactive" exists with account_code: "B000000", subaccount_code: "00000", active: false
    And I log in as user: "admin"
    And I am on the activate university_accounts page
    And I fill in "accounts" with "B00000000000"
    And I choose "Activate"
    And I press "Save changes"
    Then I should see "Activated 1 university account."
    And university_account: "inactive"'s active should be true
    Given I am on the activate university_accounts page
    When I fill in "accounts" with "A00000000000,B00000000000"
    And I choose "Inactivate"
    And I press "Save changes"
    Then I should see "Inactivated 2 university accounts."
    And university_account: "active"'s active should be false
    And university_account: "inactive"'s active should be false

