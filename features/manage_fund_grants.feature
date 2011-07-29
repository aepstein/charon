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
    When I am on the edit page for the fund_grant
    Then I should <edit> authorized
    And I should <status> "You must be undergrad."
    And I should <agreement> "You must approve the Key Agreement."
    And I should <registration> "Applicant must have a current registration with at least 15 percent undergrads and an approved status."
    Examples:
      | user      | perspective | fulfillable            | edit    | status  | agreement | registration |
      | admin     | requestor   | user_status_criterion  | see     | not see | not see   | not see      |
      | requestor | requestor   | user_status_criterion  | not see | see     | not see   | not see      |
      | requestor | requestor   | agreement              | not see | not see | see       | not see      |
      | requestor | requestor   | registration_criterion | not see | not see | not see   | see          |

  Scenario: Create and update fund_grants
    Given a fund_source exists with name: "Annual Budget"
    And a fund_queue exists with fund_source: the fund_source
    And a fund_source exists with name: "Semester Budget"
    And a fund_queue exists with fund_source: the fund_source
    And an organization exists with last_name: "Spending Club"
    And I log in as user: "admin"
    And I am on the new fund_grant page for the organization
    When I select "Annual Budget" from "Fund source"
    And I press "Create"
    Then I should see "Fund grant was successfully created."
    And I should see "Fund source: Annual Budget"
    When I follow "Edit"
    And I press "Update"
    Then I should see "Fund grant was successfully updated."

  Scenario: List and delete fund_grants
    Given a fund_source: "annual" exists with name: "Annual"
    And a fund_source: "semester" exists with name: "Semester"
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a fund_grant exists with fund_source: fund_source "semester", organization: organization: "last"
    And a fund_grant exists with fund_source: fund_source "semester", organization: organization: "first"
    And a fund_grant exists with fund_source: fund_source "annual", organization: organization: "last"
    And a fund_grant exists with fund_source: fund_source "annual", organization: organization: "first"
    And I log in as user: "admin"
    Given I am on the fund_grants page for fund_source: "annual"
    Then I should see the following fund_grants:
      | Organization |
      | First Club   |
      | Last Club    |
    When I fill in "Organization" with "last"
    And I press "Search"
    Then I should see the following fund_grants:
      | Organization |
      | Last Club    |
    Given I am on the fund_grants page for organization: "first"
    Then I should see the following fund_grants:
      | Fund source |
      | Annual      |
      | Semester    |
    When I fill in "Fund source" with "semester"
    And I press "Search"
    Then I should see the following fund_grants:
      | Fund source |
      | Semester    |
    When I follow "Destroy" for the 2nd fund_grant for organization: "first"
    And I am on the fund_grants page for fund_source: "semester"
    Then I should see the following fund_grants:
      | Organization |
      | Last Club    |

