#TODO withdrawal functional testing
Feature: Manage fund_grants
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage fund_grants

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

  #TODO: we need a separate scenario for new (w/o fund_source) vs. create (w/ fund_source)
  Scenario Outline: Test permissions for fund_grants controller
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
    And a fund_grant: "annual" exists with fund_source: the fund_source, organization: organization "applicant"
    And I log in as user: "<user>"
    And I am on the new fund_grant page for organization: "applicant"
    Then I should <create> authorized
    Given I post on the fund_grants page for organization: "applicant"
    Then I should <create> authorized
    And I am on the edit page for the fund_grant
    Then I should <update> authorized
    Given I put on the page for the fund_grant
    Then I should <update> authorized
    Given I am on the page for the fund_grant
    Then I should <show> authorized
    Given I am on the fund_grants page for organization: "applicant"
    Then I should <show> "Annual"
    Given I delete on the page for the fund_grant
    Then I should <destroy> authorized
    Examples:
      | tense     | user                | create  | update  | show    | destroy |
      |           | admin               | see     | see     | see     | see     |
      |           | source_manager      | not see | see     | see     | see     |
      |           | source_reviewer     | not see | not see | see     | not see |
      |           | applicant_requestor | see     | not see | see     | not see |
      | closed_   | applicant_requestor | see     | not see | see     | not see |
      | upcoming_ | applicant_requestor | see     | not see | see     | not see |
      |           | observer_requestor  | not see | not see | not see | not see |
      |           | regular             | not see | not see | not see | not see |

  Scenario: Create and update fund_grants
    Given a fund_source exists with name: "Annual Budget"
    And a fund_source exists with name: "Semester Budget"
    And an organization exists with last_name: "Spending Club"
    And I log in as user: "admin"
    And I am on the new fund_grant page for the organization
    When I select "Annual Budget" from "FundSource"
    And I press "Create"
    Then I should see "FundRequest was successfully created."
    And I should see "FundSource: Annual Budget"
    When I follow "Edit"
    And I press "Update"
    Then I should see "FundRequest was successfully updated."

  Scenario: Reject fund_grants
    Given a fund_grant exists with status: "completed"
    And I log in as user: "admin"
    And I am on the reject page for the fund_grant
    When I press "Reject"
    Then I should not see "FundRequest was successfully rejected."
    When I fill in "Reject message" with "Not acceptable."
    And I press "Reject"
    Then I should see "FundRequest was successfully rejected."

  Scenario: List and delete fund_grants
    Given a fund_source: "annual" exists with name: "Annual"
    And a fund_source: "semester" exists with name: "Semester"
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a fund_grant exists with fund_source: fund_source "semester", organization: organization: "last", status: "started"
    And a fund_grant exists with fund_source: fund_source "semester", organization: organization: "first", status: "completed"
    And a fund_grant exists with fund_source: fund_source "annual", organization: organization: "last", status: "submitted"
    And a fund_grant exists with fund_source: fund_source "annual", organization: organization: "first", status: "accepted"
    And I log in as user: "admin"
    And I am on the fund_grants page
    When I fill in "FundSource" with "annual"
    And I press "Search"
    Then I should see the following fund_grants:
      | FundSource    | Organization |
      | Annual   | First Club   |
      | Annual   | Last Club    |
    And I fill in "Organization" with "first"
    And I press "Search"
    Then I should see the following fund_grants:
      | FundSource    | Organization |
      | Annual   | First Club   |
    Given I am on the fund_grants page for fund_source: "annual"
    Then I should see the following fund_grants:
      | Organization | Status    |
      | First Club   | accepted  |
      | Last Club    | submitted |
    Given I am on the fund_grants page for organization: "first"
    Then I should see the following fund_grants:
      | FundSource    | Status    |
      | Annual   | accepted  |
      | Semester | completed |
    When I follow "Destroy" for the 3rd fund_grant
    And I am on the fund_grants page
    Then I should see the following fund_grants:
      | FundSource    | Organization | Status    |
      | Annual   | First Club   | accepted  |
      | Annual   | Last Club    | submitted |
      | Semester | Last Club    | started   |
    Given I am on the duplicate fund_grants page
    And I am on the duplicate fund_grants page for fund_source: "annual"
    And I am on the duplicate fund_grants page for organization: "first"

