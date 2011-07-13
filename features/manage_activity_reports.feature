Feature: Manage fund_requests
  In order to track inventories of organizations
  As an organization officer or staff
  I want to manage activity_reports

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for activity_reports controller
    Given an organization exists
    And a user: "member" exists
    And a requestor_role exists
    And a membership exists with user: user "member", organization: the organization, role: the requestor_role
    And a user: "regular" exists
    And an activity_report exists with description: "Then", organization: the organization
    And a current_activity_report exists with description: "Now", organization: the organization
    And a future_activity_report exists with description: "Later", organization: the organization
    And I log in as user: "<user>"
    And I am on the new activity_report page for the organization
    Then I should <create> authorized
    Given I post on the activity_reports page for the organization
    Then I should <create> authorized
    And I am on the edit page for the activity_report
    Then I should <update> authorized
    Given I put on the page for the activity_report
    Then I should <update> authorized
    Given I am on the page for the activity_report
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the activity_reports page for the organization
    Then I should <show> "Then"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New activity report"
    Given I am on the past activity_reports page for the organization
    Then I should <show> "Then"
    Given I am on the current activity_reports page for the organization
    Then I should <show> "Now"
    Given I am on the future activity_reports page for the organization
    Then I should <show> "Later"
    Given I am on the activity_reports page
    Then I should <show> "Then"
    Given I delete on the page for the activity_report
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | show    | destroy |
      | admin   | see     | see     | see     | see     |
      | member  | see     | see     | see     | see     |
      | regular | not see | not see | not see | not see |

  Scenario: Create and update activity_reports
    Given an organization exists with last_name: "Spending Club"
    And I log in as user: "admin"
    And I am on the new activity_report page for the organization
    When I fill in "Description" with "Concert"
    And I fill in "Number of undergrads" with "10"
    And I fill in "Number of grads" with "10"
    And I fill in "Number of others" with "10"
    And I fill in "Starts on" with "2010-01-01"
    And I fill in "Ends on" with "2010-01-01"
    And I press "Create"
    Then I should see "Activity report was successfully created."
    And I should see "Description: Concert"
    And I should see "Number of undergrads: 10"
    And I should see "Number of grads: 10"
    And I should see "Number of others: 10"
    And I should see "Starts on: January 1st, 2010"
    And I should see "Ends on: January 1st, 2010"
    When I follow "Edit"
    When I fill in "Description" with "Recital"
    And I fill in "Number of undergrads" with "5"
    And I fill in "Number of grads" with "6"
    And I fill in "Number of others" with "7"
    And I fill in "Starts on" with "2010-01-02"
    And I fill in "Ends on" with "2010-01-02"
    And I press "Update"
    Then I should see "Activity report was successfully updated."
    And I should see "Description: Recital"
    And I should see "Number of undergrads: 5"
    And I should see "Number of grads: 6"
    And I should see "Number of others: 7"
    And I should see "Starts on: January 2nd, 2010"
    And I should see "Ends on: January 2nd, 2010"

  Scenario: List and delete activity reports
    Given an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And an activity_report exists with starts_on: "2010-01-04", description: "Concert", organization: organization "last"
    And an activity_report exists with starts_on: "2010-01-03", description: "Concerto", organization: organization "last"
    And an activity_report exists with starts_on: "2010-01-01", description: "Play", organization: organization "first"
    And an activity_report exists with starts_on: "2010-01-01", description: "Musical", organization: organization "first"
    And I log in as user: "admin"
    And I am on the activity_reports page
    When I fill in "Description" with "Concert"
    And I press "Search"
    Then I should see the following activity_reports:
      | Organization | Description |
      | Last Club    | Concerto    |
      | Last Club    | Concert     |
    Given I am on the activity_reports page
    And I fill in "Organization" with "last"
    And I press "Search"
    Then I should see the following activity_reports:
      | Organization | Description |
      | Last Club    | Concerto    |
      | Last Club    | Concert     |
    Given I am on the activity_reports page for organization: "first"
    Then I should see the following fund_requests:
      | Description |
      | Musical     |
      | Play        |
    When I follow "Destroy" for the 3rd activity_report
    And I am on the activity_reports page
    Then I should see the following activity_reports:
      | Organization | Description |
      | First Club   | Musical     |
      | First Club   | Play        |
      | Last Club    | Concert     |

