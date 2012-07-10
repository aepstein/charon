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
    And a fund_source exists with organization: organization "source", name: "Annual Budget"
    And a fund_grant exists with organization: organization "recipient", fund_source: the fund_source
#    And a university_account exists with account_code: "A000000", organization: organization "recipient"
    And an activity_account exists with fund_grant: the fund_grant
    And I log in as user: "<user>"
    And I am on the new activity_account page for the fund_grant
    Then I should <create> authorized
    Given I post on the activity_accounts page for the fund_grant
    Then I should <create> authorized
    And I am on the edit page for the activity_account
    Then I should <update> authorized
    Given I put on the page for the activity_account
    Then I should <update> authorized
    Given I am on the page for the activity_account
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the activity_accounts page for organization: "recipient"
    Then I should <show> "Annual Budget"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the activity_accounts page for the fund_grant
    Then I should <show> authorized
    And I should <create> "New activity account"
    Given I delete on the page for the activity_account
    Then I should <destroy> authorized
    Examples:
      | user              | create  | update  | show    | destroy |
      | admin             | see     | see     | see     | see     |
      | source_manager    | see     | see     | see     | see     |
      | member            | not see | not see | see     | not see |
      | regular           | not see | not see | not see | not see |

  Scenario: Create and update activity_accounts
    Given a fund_source exists with name: "SAFC"
    And an organization exists with last_name: "Recipient"
    And a category exists with name: "SAFC Local Event"
    And a category exists with name: "ISPB Food"
    And a fund_grant exists with fund_source: the fund_source, organization: the organization
    And I log in as user: "admin"
    And I am on the new activity_account page for the fund_grant
    When I select "SAFC Local Event" from "Category"
    And I fill in "Comments" with "This is *important*"
    And I press "Create"
    Then I should see "Activity account was successfully created."
    And I should see "Grant: Fund grant to Recipient from SAFC"
    And I should see "Category: SAFC Local Event"
    And I should see "This is important"
    When I follow "Edit"
    And I select "ISPB Food" from "Category"
    And I fill in "Comments" with "This is not so important"
    And I press "Update"
    Then I should see "Activity account was successfully updated."
    And I should see "Category: ISPB Food"
    And I should see "This is not so important"

#  Scenario: List and delete university accounts
#TODO

