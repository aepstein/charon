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
    And a fund_request: "annual" exists with fund_grant: the fund_grant, state: "<state>", review_state: "<review_state>", fund_queue: the fund_queue
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
      |tense  |state    |review_state|user               |create |update |show   |submit |withdraw|reject |destroy|
      |       |started  |unreviewed  |admin              |see    |see    |see    |not see|not see |not see|see    |
      |       |started  |unreviewed  |source_manager     |see    |see    |see    |not see|not see |not see|see    |
      |       |started  |unreviewed  |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |started  |unreviewed  |applicant_requestor|see    |see    |see    |not see|not see |not see|not see|
      |closed_|started  |unreviewed  |applicant_requestor|not see|not see|see    |not see|not see |not see|not see|
      |       |started  |unreviewed  |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |started  |unreviewed  |regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |tentative|unreviewed  |admin              |see    |see    |see    |see    |see     |not see|see    |
      |       |tentative|unreviewed  |source_manager     |see    |see    |see    |see    |see     |not see|see    |
      |       |tentative|unreviewed  |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |tentative|unreviewed  |applicant_requestor|see    |not see|see    |not see|see     |not see|not see|
      |closed_|tentative|unreviewed  |applicant_requestor|not see|not see|see    |not see|not see |not see|not see|
      |       |tentative|unreviewed  |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |tentative|unreviewed  |regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |finalized|unreviewed  |admin              |see    |see    |see    |see    |see     |see    |see    |
      |       |finalized|unreviewed  |source_manager     |see    |see    |see    |see    |see     |see    |see    |
      |       |finalized|unreviewed  |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |finalized|unreviewed  |applicant_requestor|see    |not see|see    |not see|see     |not see|not see|
      |closed_|finalized|unreviewed  |applicant_requestor|not see|not see|see    |not see|not see |not see|not see|
      |       |finalized|unreviewed  |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |finalized|unreviewed  |regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |submitted|unreviewed  |admin              |see    |see    |see    |not see|see     |see    |see    |
      |       |submitted|unreviewed  |source_manager     |see    |see    |see    |not see|see     |see    |see    |
      |       |submitted|unreviewed  |source_reviewer    |not see|see    |see    |not see|not see |not see|not see|
      |closed_|submitted|unreviewed  |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |submitted|unreviewed  |applicant_requestor|see    |not see|see    |not see|see     |not see|not see|
      |       |submitted|unreviewed  |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |submitted|unreviewed  |regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |submitted|tentative   |admin              |see    |see    |see    |not see|see     |see    |see    |
      |       |submitted|tentative   |source_manager     |see    |see    |see    |not see|see     |see    |see    |
      |       |submitted|tentative   |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |submitted|tentative   |applicant_requestor|see    |not see|see    |not see|not see |not see|not see|
      |       |submitted|tentative   |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |submitted|tentative   |regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |submitted|ready       |admin              |see    |see    |see    |not see|see     |see    |see    |
      |       |submitted|ready       |source_manager     |see    |see    |see    |not see|see     |see    |see    |
      |       |submitted|ready       |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |submitted|ready       |applicant_requestor|see    |not see|see    |not see|not see |not see|not see|
      |       |submitted|ready       |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |submitted|ready       |regular            |not see|not see|not see|not see|not see |not see|not see|
      |       |released |ready       |admin              |see    |see    |see    |not see|not see |not see|see    |
      |       |released |ready       |source_manager     |see    |see    |see    |not see|not see |not see|see    |
      |       |released |ready       |source_reviewer    |not see|not see|see    |not see|not see |not see|not see|
      |       |released |ready       |applicant_requestor|see    |not see|see    |not see|not see |not see|not see|
      |       |released |ready       |observer_requestor |not see|not see|not see|not see|not see |not see|not see|
      |       |released |ready       |regular            |not see|not see|not see|not see|not see |not see|not see|

  Scenario: Create and update fund_requests
    Given a fund_source exists with name: "Annual Budget"
    And an organization exists with last_name: "Applicant"
    And a fund_grant exists with fund_source: the fund_source, organization: the organization
    And I log in as user: "admin"
    And I am on the new fund_request page for the fund_grant
    And I press "Create"
    Then I should see "Fund request was successfully created."
    And I should see "Fund source: Annual Budget"
    And I should see "Requestor: Applicant"
    When I follow "Edit"
    And I press "Update"
    Then I should see "Fund request was successfully updated."

  Scenario: Reject fund_requests
    Given a fund_request exists with state: "finalized"
    And I log in as user: "admin"
    And I am on the reject page for the fund_request
    When I press "Reject"
    Then I should not see "Fund request was successfully rejected."
    When I fill in "Reject message" with "Not acceptable."
    And I press "Reject"
    Then I should see "Fund request was successfully rejected."

  Scenario: List and delete fund_requests
    Given a fund_source: "annual" exists with name: "Annual"
    And a fund_queue: "annual" exists with fund_source: fund_source "annual"
    And a fund_source: "semester" exists with name: "Semester"
    And a fund_queue: "semester" exists with fund_source: fund_source "semester"
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a fund_grant: "semester_last" exists with fund_source: fund_source "semester", organization: organization: "last"
    And a fund_grant: "semester_first" exists with fund_source: fund_source "semester", organization: organization: "first"
    And a fund_grant: "annual_last" exists with fund_source: fund_source "annual", organization: organization: "last"
    And a fund_grant: "annual_first" exists with fund_source: fund_source "annual", organization: organization: "first"
    And a fund_request exists with fund_grant: fund_grant "semester_last", state: "started"
    And a fund_request exists with fund_grant: fund_grant "semester_first", state: "tentative"
    And a fund_request exists with fund_grant: fund_grant "annual_last", state: "submitted", fund_queue: fund_queue "annual"
    And a fund_request exists with fund_grant: fund_grant "annual_first", state: "submitted", fund_queue: fund_queue "annual"
    And I log in as user: "admin"
    And I am on the fund_requests page
    When I fill in "Fund source" with "annual"
    And I press "Search"
    Then I should see the following fund_requests:
      | Fund source    | Requestor    |
      | Annual         | First Club   |
      | Annual         | Last Club    |
    And I fill in "Requestor" with "first"
    And I press "Search"
    Then I should see the following fund_requests:
      | Fund source    | Requestor  |
      | Annual         | First Club |
    Given I am on the fund_requests page for fund_source: "annual"
    Then I should see the following fund_requests:
      | Requestor  | State      |
      | First Club | submitted  |
      | Last Club  | submitted  |
    Given I am on the fund_requests page for organization: "first"
    Then I should see the following fund_requests:
      | Fund source | State     |
      | Annual      | submitted |
      | Semester    | tentative |
    When I follow "Destroy" for the 3rd fund_request
    And I am on the fund_requests page
    Then I should see the following fund_requests:
      | Fund source | Requestor  | State     |
      | Annual      | First Club | submitted |
      | Annual      | Last Club  | submitted |
      | Semester    | Last Club  | started   |
    Given I am on the duplicate fund_requests page for fund_queue: "annual"
    Then I should see the following fund_requests:
      | Fund source | Requestor  | State     |

