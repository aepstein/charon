#TODO withdrawal functional testing
Feature: Manage fund_requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage fund_requests

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test how permissions failures are reported to the user
    Given an organization: "reviewer" exists with last_name: "Funding Source"
    And an organization: "requestor" exists with last_name: "Applicant"
    And a requestor_role exists
    And a reviewer_role exists
    And a user: "requestor" exists with status: "grad"
    And a user: "reviewer" exists with status: "grad"
    And a membership exists with role: the requestor_role, active: true, organization: organization "requestor", user: user "requestor"
    And a membership exists with role: the reviewer_role, active: true, organization: organization "reviewer", user: user "reviewer"
    And a framework exists with name: "Annual"
    And an agreement exists with name: "Key Agreement"
    And a user_status_criterion exists
    And a registration_criterion exists with must_register: true, minimal_percentage: 15, type_of_member: "undergrads"
    And a requirement exists with framework: the framework, perspectives: nil, perspective: "<perspective>", role: the <perspective>_role, fulfillable: the <fulfillable>
    And a fund_source exists with organization: organization "reviewer", framework: the framework
    And a fund_grant exists with fund_source: the fund_source, organization: organization "requestor"
    And I log in as user: "<user>"
    When I am on the page for the fund_grant
    Then I should <show> authorized
    And I should <status> "You must be undergrad."
    And I should <agreement> "You must approve the Key Agreement."
    And I should <registration> "Applicant must have a current registration with at least 15 percent undergrads and an approved status."
    Examples:
      | user      | perspective | fulfillable            | show    | status  | agreement | registration |
      | admin     | requestor   | user_status_criterion  | see     | not see | not see   | not see      |
      | requestor | requestor   | user_status_criterion  | not see | see     | not see   | not see      |
      | requestor | requestor   | agreement              | not see | not see | see       | not see      |
      | requestor | requestor   | registration_criterion | not see | not see | not see   | see          |

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
    And a fund_request: "annual" exists with fund_source: the fund_source, organization: organization "applicant", status: "<status>"
    And I log in as user: "<user>"
    And I am on the fund_source new fund_request page for organization: "applicant"
    Then I should <create> authorized
    Given I post on the fund_source fund_requests page for organization: "applicant"
    Then I should <create> authorized
    And I am on the edit page for the fund_request
    Then I should <update> authorized
    Given I put on the page for the fund_request
    Then I should <update> authorized
    Given I am on the page for the fund_request
    Then I should <show> authorized
    Given I put on the accept page for the fund_request
    Then I should <accept> authorized
    Given the fund_request has status: "<status>"
    And I am on the reject page for the fund_request
    Then I should <reject> authorized
    Given I put on the do_reject page for the fund_request
    Then I should <reject> authorized
#    Given I am on the fund_requests page for organization: "applicant"
#    Then I should <show> "Annual"
    Given I delete on the page for the fund_request
    Then I should <destroy> authorized
    Examples:
      | tense | status    | user                | create  | update  | show    | accept  | reject  | destroy |
      |       | started   | admin               | see     | see     | see     | not see | not see | see     |
      |       | started   | source_manager      | see     | see     | see     | not see | not see | see     |
      |       | started   | source_reviewer     | not see | not see | see     | not see | not see | not see |
      |       | started   | applicant_requestor | see     | see     | see     | not see | not see | see     |
      | past_ | started   | applicant_requestor | not see | not see | see     | not see | not see | not see |
      |       | started   | observer_requestor  | not see | not see | not see | not see | not see | not see |
      |       | started   | regular             | not see | not see | not see | not see | not see | not see |
      |       | completed | admin               | see     | see     | see     | not see | see     | see     |
      |       | completed | source_manager      | see     | see     | see     | not see | see     | see     |
      |       | completed | source_reviewer     | not see | not see | see     | not see | not see | not see |
      |       | completed | applicant_requestor | see     | not see | see     | not see | not see | not see |
      | past_ | completed | applicant_requestor | not see | not see | see     | not see | not see | not see |
      |       | completed | observer_requestor  | not see | not see | not see | not see | not see | not see |
      |       | completed | regular             | not see | not see | not see | not see | not see | not see |
      |       | submitted | admin               | see     | see     | see     | see     | see     | see     |
      |       | submitted | source_manager      | see     | see     | see     | see     | see     | see     |
      |       | submitted | source_reviewer     | not see | not see | see     | not see | not see | not see |
      |       | submitted | applicant_requestor | see     | not see | see     | not see | not see | not see |
      |       | submitted | observer_requestor  | not see | not see | not see | not see | not see | not see |
      |       | submitted | regular             | not see | not see | not see | not see | not see | not see |
      |       | accepted  | admin               | see     | see     | see     | not see | not see | see     |
      |       | accepted  | source_manager      | see     | see     | see     | not see | not see | see     |
      |       | accepted  | source_reviewer     | not see | not see | see     | not see | not see | not see |
      |       | accepted  | applicant_requestor | see     | not see | see     | not see | not see | not see |
      |       | accepted  | observer_requestor  | not see | not see | not see | not see | not see | not see |
      |       | accepted  | regular             | not see | not see | not see | not see | not see | not see |

  Scenario: Create and update fund_requests
    Given a fund_source exists with name: "Annual Budget"
    And a fund_source exists with name: "Semester Budget"
    And an organization exists with last_name: "Spending Club"
    And I log in as user: "admin"
    And I am on the new fund_request page for the organization
    When I select "Annual Budget" from "FundSource"
    And I press "Create"
    Then I should see "FundRequest was successfully created."
    And I should see "FundSource: Annual Budget"
    When I follow "Edit"
    And I press "Update"
    Then I should see "FundRequest was successfully updated."

  Scenario: Reject fund_requests
    Given a fund_request exists with status: "completed"
    And I log in as user: "admin"
    And I am on the reject page for the fund_request
    When I press "Reject"
    Then I should not see "FundRequest was successfully rejected."
    When I fill in "Reject message" with "Not acceptable."
    And I press "Reject"
    Then I should see "FundRequest was successfully rejected."

  Scenario: List and delete fund_requests
    Given a fund_source: "annual" exists with name: "Annual"
    And a fund_source: "semester" exists with name: "Semester"
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a fund_request exists with fund_source: fund_source "semester", organization: organization: "last", status: "started"
    And a fund_request exists with fund_source: fund_source "semester", organization: organization: "first", status: "completed"
    And a fund_request exists with fund_source: fund_source "annual", organization: organization: "last", status: "submitted"
    And a fund_request exists with fund_source: fund_source "annual", organization: organization: "first", status: "accepted"
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
      | First Club   | accepted  |
      | Last Club    | submitted |
    Given I am on the fund_requests page for organization: "first"
    Then I should see the following fund_requests:
      | FundSource    | Status    |
      | Annual   | accepted  |
      | Semester | completed |
    When I follow "Destroy" for the 3rd fund_request
    And I am on the fund_requests page
    Then I should see the following fund_requests:
      | FundSource    | Organization | Status    |
      | Annual   | First Club   | accepted  |
      | Annual   | Last Club    | submitted |
      | Semester | Last Club    | started   |
    Given I am on the duplicate fund_requests page
    And I am on the duplicate fund_requests page for fund_source: "annual"
    And I am on the duplicate fund_requests page for organization: "first"

