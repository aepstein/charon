#TODO withdrawal functional testing
Feature: Manage fund_requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage fund_requests

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for fund_requests controller
    Given an organization: "source" exists with last_name: "Funding Source"
    And an organization: "applicant" exists with last_name: "Applicant"
    And an organization: "observer" exists with last_name: "Observer"
    And a manager_role: "manager" exists
    And a requestor_role: "requestor" exists
    And a reviewer_role: "reviewer" exists
    And a user: "source_manager" exists
    And a membership exists with user: user "source_manager", organization: organization "source", role: role "manager"
    And a user: "source_reviewer" exists
    And a membership exists with user: user "source_reviewer", organization: organization "source", role: role "reviewer"
    And a user: "applicant_requestor" exists
    And a membership exists with user: user "applicant_requestor", organization: organization "applicant", role: role "requestor"
    And a user: "observer_requestor" exists
    And a membership exists with user: user "observer_requestor", organization: organization "observer", role: role "requestor"
    And a user: "regular" exists
    And a <tense>fund_source exists with name: "Annual", organization: organization "source"
    And a fund_queue exists with fund_source: the <tense>fund_source
    And a fund_grant exists with fund_source: the <tense>fund_source, organization: organization "applicant"
    And a fund_request: "annual" exists with fund_grant: the fund_grant, state: "<state>", fund_queue: the fund_queue
    And I log in as user: "<user>"
    And I am on the new fund_request page for the fund_grant
    Then I should <create> authorized
    Given I post on the fund_requests page for the fund_grant
    Then I should <create> authorized
    And I am on the edit page for the fund_request
    Then I should <update> authorized
    Given I put on the page for the fund_request
    Then I should <update> authorized
    Given I am on the page for the fund_request
    Then I should <show> authorized
    Given I put on the submit page for the fund_request
    Then I should <submit> authorized
    Given the fund_request has state: "<state>"
    And I put on the withdraw page for the fund_request
    Then I should <withdraw> authorized
    Given the fund_request has state: "<state>"
    And I am on the reject page for the fund_request
    Then I should <reject> authorized
    Given I put on the do_reject page for the fund_request
    Then I should <reject> authorized
#    Given I am on the fund_requests page for organization: "applicant"
#    Then I should <show> "Annual"
    Given I delete on the page for the fund_request
    Then I should <destroy> authorized
    Examples:
      |tense  |state    |user               |create |update |show   |submit |withdraw|reject |destroy|
      |       |started  |admin              |see    |see    |see    |not see|not see |not see|see    |
      |       |started  |source_manager     |see    |see    |see    |not see|not see |not see|see    |
      |       |started  |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |started  |applicant_requestor|see    |see    |see    |not see|not see |not see|not see|
      |closed_|started  |applicant_requestor|not see|not see|see    |not see|not see |not see|not see|
      |       |started  |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |started  |regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |tentative|admin              |see    |see    |see    |see    |see     |see    |see    |
      |       |tentative|source_manager     |see    |see    |see    |see    |see     |see    |see    |
      |       |tentative|source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |tentative|applicant_requestor|see    |not see|see    |not see|see     |not see|not see|
      |closed_|tentative|applicant_requestor|not see|not see|see    |not see|not see |not see|not see|
      |       |tentative|observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |tentative|regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |finalized|admin              |see    |see    |see    |see    |see     |see    |see    |
      |       |finalized|source_manager     |see    |see    |see    |see    |see     |see    |see    |
      |       |finalized|source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |finalized|applicant_requestor|see    |not see|see    |not see|see     |not see|not see|
      |closed_|finalized|applicant_requestor|not see|not see|see    |not see|not see |not see|not see|
      |       |finalized|observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |finalized|regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |submitted|admin              |see    |see    |see    |not see|see     |see    |see    |
      |       |submitted|source_manager     |see    |see    |see    |not see|see     |see    |see    |
      |       |submitted|source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |submitted|applicant_requestor|see    |not see|see    |not see|see     |not see|not see|
      |       |submitted|observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |submitted|regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |released |admin              |see    |see    |see    |not see|not see |not see|see    |
      |       |released |source_manager     |see    |see    |see    |not see|not see |not see|see    |
      |       |released |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |released |applicant_requestor|see    |not see|see    |not see|not see |not see|not see|
      |       |released |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |released |regular            |not see|not see|not see|not see|not see |not see|not see|

  Scenario: Create and update fund_requests
    Given a fund_source exists with name: "Annual Budget"
    And a fund_source exists with name: "Semester Budget"
    And an organization exists with last_name: "Spending Club"
    And I log in as user: "admin"
    And I am on the new fund_request page for the organization
    When I select "Annual Budget" from "Fund source"
    And I press "Create"
    Then I should see "FundRequest was successfully created."
    And I should see "FundSource: Annual Budget"
    When I follow "Edit"
    And I press "Update"
    Then I should see "Fund request was successfully updated."

  Scenario: Reject fund_requests
    Given a fund_request exists with status: "tentative"
    And I log in as user: "admin"
    And I am on the reject page for the fund_request
    When I press "Reject"
    Then I should not see "FundRequest was successfully rejected."
    When I fill in "Reject message" with "Not acceptable."
    And I press "Reject"
    Then I should see "Fund request was successfully rejected."

  Scenario: List and delete fund_requests
    Given a fund_source: "annual" exists with name: "Annual"
    And a fund_source: "semester" exists with name: "Semester"
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a fund_request exists with fund_source: fund_source "semester", organization: organization: "last", status: "started"
    And a fund_request exists with fund_source: fund_source "semester", organization: organization: "first", status: "tentative"
    And a fund_request exists with fund_source: fund_source "annual", organization: organization: "last", status: "submitted"
    And a fund_request exists with fund_source: fund_source "annual", organization: organization: "first", status: "submitted"
    And I log in as user: "admin"
    And I am on the fund_requests page
    When I fill in "FundSource" with "annual"
    And I press "Search"
    Then I should see the following fund_requests:
      | FundSource    | Organization |
      | Annual   | First Club   |
      | Annual   | Last Club    |
    And I fill in "Organization" with "first"
    And I press "Search"
    Then I should see the following fund_requests:
      | FundSource    | Organization |
      | Annual   | First Club   |
    Given I am on the fund_requests page for fund_source: "annual"
    Then I should see the following fund_requests:
      | Organization | Status    |
      | First Club   | submitted  |
      | Last Club    | submitted |
    Given I am on the fund_requests page for organization: "first"
    Then I should see the following fund_requests:
      | FundSource    | Status    |
      | Annual   | submitted  |
      | Semester | tentative |
    When I follow "Destroy" for the 3rd fund_request
    And I am on the fund_requests page
    Then I should see the following fund_requests:
      | FundSource    | Organization | Status    |
      | Annual   | First Club   | submitted  |
      | Annual   | Last Club    | submitted |
      | Semester | Last Club    | started   |
    Given I am on the duplicate fund_requests page
    And I am on the duplicate fund_requests page for fund_source: "annual"
    And I am on the duplicate fund_requests page for organization: "first"

