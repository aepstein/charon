Feature: Manage fund_request_types
  In order to group funds
  As a finance manager
  I want to create and delete fund_request_types

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true

  Scenario Outline: Test permissions for fund_request_types controller actions
    Given a user: "regular" exists
    And a fund_request_type exists with name: "Unrestricted"
    And I log in as user: "<user>"
    And I am on the page for the fund_request_type
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the fund_request_types page
    Then I should <show> authorized
    And I should <show> "Unrestricted"
    And I should <create> "New fund request type"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new fund_request_type page
    Then I should <create> authorized
    Given I post on the fund_request_types page
    Then I should <create> authorized
    And I am on the edit page for the fund_request_type
    Then I should <update> authorized
    Given I put on the page for the fund_request_type
    Then I should <update> authorized
    Given I delete on the page for the fund_request_type
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | staff   | see     | see     | not see | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Register new fund_request_type and update
    Given I log in as user: "admin"
    And I am on the new fund_request_type page
    When I fill in "Name" with "Special Project"
    And I choose "No"
    And I fill in "Amendable quantity limit" with "0"
    And I fill in "Appendable quantity limit" with "1"
    And I fill in "Appendable amount limit" with "1000.05"
    And I fill in "Quantity limit" with "2"
    And I press "Create"
    Then I should see "Fund request type was successfully created."
    And I should see "Name: Special Project"
    And I should see "Allowed for first? No"
    And I should see "Amendable quantity limit: 0 items"
    And I should see "Appendable quantity limit: 1 item"
    And I should see "Appendable amount limit: $1,000.05"
    And I should see "Quantity limit: 2 items"
    When I follow "Edit"
    And I fill in "Name" with "Unrestricted"
    And I choose "Yes"
    And I fill in "Amendable quantity limit" with ""
    And I fill in "Appendable quantity limit" with ""
    And I fill in "Appendable amount limit" with ""
    And I fill in "Quantity limit" with ""
    And I press "Update"
    Then I should see "Fund request type was successfully updated."
    And I should see "Name: Unrestricted"
    And I should see "Allowed for first? Yes"
    And I should see "Amendable quantity limit: No limit"
    And I should see "Appendable quantity limit: No limit"
    And I should see "Appendable amount limit: No limit"
    And I should see "Quantity limit: No limit"


  Scenario: Delete fund_request_type
    Given a fund_request_type exists with name: "fund_request_type 4"
    And a fund_request_type exists with name: "fund_request_type 3"
    And a fund_request_type exists with name: "fund_request_type 2"
    And a fund_request_type exists with name: "fund_request_type 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd fund_request_type
    Then I should see the following fund_request_types:
      |Name               |
      |fund_request_type 1|
      |fund_request_type 2|
      |fund_request_type 4|

