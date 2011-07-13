Feature: Manage fund_requests
  In order to track university accounts associated with organizations
  As a staff member
  I want to manage university accounts

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for university_accounts controller
    Given an organization exists
    And a user: "member" exists
    And a requestor_role exists
    And a membership exists with user: user "member", organization: the organization, role: the requestor_role
    And a user: "regular" exists
    And a university_account exists with department_code: "A00", subledger_code: "0000", organization: the organization
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
    Then I should <show> "A00"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New university account"
    Given I am on the university_accounts page
    Then I should <show> "A00"
    Given I delete on the page for the university_account
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | show    | destroy |
      | admin   | see     | see     | see     | see     |
      | member  | not see | not see | not see | not see |
      | regular | not see | not see | not see | not see |

  Scenario: Create and update university_accounts
    Given an organization: "first" exists with last_name: "Spending Club"
    And an organization: "last" exists with last_name: "Other Spending Club", first_name: "The"
    And I log in as user: "admin"
    And I am on the new university_account page for organization: "first"
    When I fill in "Department code" with "A00"
    And I fill in "Subledger code" with "0001"
    And I press "Create"
    Then I should see "University account was successfully created."
    And I should see "Organization: Spending Club"
    And I should see "Department code: A00"
    And I should see "Subledger code: 0001"
    When I follow "Edit"
    And I fill in "Organization" with "Other Spending Club, The"
    And I fill in "Department code" with "A00"
    And I fill in "Subledger code" with "0001"
    And I press "Update"
    Then I should see "University account was successfully updated."
    And I should see "Organization: The Other Spending Club"
    And I should see "Department code: A00"
    And I should see "Subledger code: 0001"

  Scenario: List and delete university accounts
    Given an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a university_account exists with department_code: "B00", subledger_code: "0002", organization: organization "last"
    And a university_account exists with department_code: "B00", subledger_code: "0001", organization: organization "last"
    And a university_account exists with department_code: "A00", subledger_code: "0002", organization: organization "first"
    And a university_account exists with department_code: "A00", subledger_code: "0001", organization: organization "first"
    And I log in as user: "admin"
    And I am on the university_accounts page
    When I fill in "Department code" with "A0"
    And I press "Search"
    Then I should see the following university_accounts:
      | Organization | Department code | Subledger code |
      | First Club   | A00             | 0001           |
      | First Club   | A00             | 0002           |
    Given I am on the university_accounts page
    And I fill in "Subledger code" with "01"
    And I press "Search"
    Then I should see the following inventory_items:
      | Organization | Department code | Subledger code |
      | First Club   | A00             | 0001           |
      | Last Club    | B00             | 0001           |
    Given I am on the university_accounts page
    When I fill in "Organization" with "first"
    And I press "Search"
    Then I should see the following university_accounts:
      | Organization | Department code | Subledger code |
      | First Club   | A00             | 0001           |
      | First Club   | A00             | 0002           |
    Given I am on the university_accounts page for organization: "first"
    Then I should see the following university_accounts:
      | Department code | Subledger code |
      | A00             | 0001           |
      | A00             | 0002           |
    When I follow "Destroy" for the 3rd university_account
    And I am on the university_accounts page
    Then I should see the following university_accounts:
      | Organization | Department code | Subledger code |
      | First Club   | A00             | 0001           |
      | First Club   | A00             | 0002           |
      | Last Club    | B00             | 0002           |

