Feature: Manage activity accounts
  In order to track activity accounts associated with organizations allocated and spent funds
  As a staff member
  I want to manage activity accounts

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for activity_accounts controller
    Given an organization: "source" exists
    And an organization: "recipient" exists
    And a user: "member" exists
    And a requestor_role exists
    And a membership exists with user: user "member", organization: organization "recipient", role: the requestor_role
    And a user: "recipient_manager" exists
    And a manager_role exists
    And a membership exists with user: user "recipient_manager", organization: organization "recipient", role: the manager_role
    And a user: "source_manager" exists
    And a membership exists with user: user "source_manager", organization: organization "source", role: the manager_role
    And a user: "regular" exists
    And a university_account exists with department_code: "A00", subledger_code: "0000", organization: organization "recipient"
    And an activity_account exists with university_account: the university_account
    And I log in as user: "<user>"
    And I am on the new activity_account page for the university_account
    Then I should <create> authorized
    Given I post on the activity_accounts page for the university_account
    Then I should <create> authorized
    And I am on the edit page for the activity_account
    Then I should <update> authorized
    Given I put on the page for the activity_account
    Then I should <update> authorized
    Given I am on the page for the activity_account
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the activity_accounts page for organization: "recipient"
    Then I should <show> "A00"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the activity_accounts page for the university_account
    Then I should <show_ua> authorized
    And I should <create> "New activity account"
    Given I delete on the page for the activity_account
    Then I should <destroy> authorized
    Examples:
      | user              | create  | update  | show    | destroy | show_ua |
      | admin             | see     | see     | see     | see     | see     |
# TODO: source manager tests should utilize fund_source rather than university account as context
#      | source_manager    | not see | see     | see     | see     | see     |
      | recipient_manager | not see | not see | see     | not see | see     |
      | member            | not see | not see | see     | not see | not see |
      | regular           | not see | not see | not see | not see | not see |

  Scenario: Create and update university_accounts
    Given a university_account: "first" exists with department_code: "A00", subledger_code: "0001"
    And a university_account: "second" exists with department_code: "B00", subledger_code: "0002"
    And a fund_source exists with name: "SAFC"
    And a fund_source exists with name: "ISPB"
    And a category exists with name: "SAFC Local Event"
    And a category exists with name: "ISPB Food"
    And I log in as user: "admin"
    And I am on the new activity_account page for university_account: "first"
    When I select "SAFC" from "Fund source"
    And I select "SAFC Local Event" from "Category"
    And I press "Create"
    Then I should see "Activity account was successfully created."
    And I should see "University account: A00-0001"
    And I should see "FundSource: SAFC"
    And I should see "Category: SAFC Local Event"
    When I follow "Edit"
    And I select "B00-0002" from "University account"
    And I select "ISPB" from "Fund source"
    And I select "ISPB Food" from "Category"
    And I press "Update"
    Then I should see "Activity account was successfully updated."
    And I should see "University account: B00-0002"
    And I should see "FundSource: ISPB"
    And I should see "Category: ISPB Food"

#  Scenario: List and delete university accounts
#TODO

