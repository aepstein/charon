Feature: Manage items with requestable
  In order to calculate and track transaction requests
  As a requestor or reviewer
  I want to create, update, and show editions

  Background:
    Given a user: "admin" exists with admin: true
    And a structure: "focus" exists
    And a basis: "focus" exists with structure: structure "focus", name: "Basis"
    And an organization: "focus" exists with last_name: "Applicant"
    And a request: "focus" exists with basis: basis "focus", organization: organization "focus"
@wip
  Scenario: External equity report
    Given a node: "focus" exists with structure: structure "focus", name: "Focus", item_amount_limit: 0, requestable_type: "ExternalEquityReport"
    And I log in as user: "admin"
    And I am on the items page for request: "focus"
    When I select "Focus" from "Add New Root Item"
    And I press "Add Root Item"
    Then I should be on the new item page for request: "focus"
    And I should see "No request amount may be specified for this item."
    When I fill in "Anticipated expenses" with "0.01"
    And I fill in "Anticipated income" with "0.10"
    And I fill in "Current liabilities" with "1.0"
    And I fill in "Current assets" with "10.0"
    And I fill in "Requestor comment" with "comment"
    And I press "Create"
    Then I should see "Item was successfully created."
    And I should see " Focus of Request of Applicant from Basis"
    And I should not see "Maximum request:"
    And I should not see "Requestor amount:"
    And I should see "Requestor comment: comment"
    And I should see "Anticipated expenses: $0.01"
    And I should see "Anticipated income: $0.10"
    And I should see "Current liabilities: $1.00"
    And I should see "Current assets: $10.00"
    And I should see "Net equity: $9.09"
    When I follow "Edit"
    And I fill in "Anticipated expenses" with "0.02"
    And I fill in "Anticipated income" with "0.20"
    And I fill in "Current liabilities" with "2.0"
    And I fill in "Current assets" with "20.0"
    And I fill in "Requestor comment" with "changed comment"
    And I press "Update"
    Then I should see "Item was successfully updated."
    And I should see "Requestor comment: changed comment"
    And I should see "Anticipated expenses: $0.02"
    And I should see "Anticipated income: $0.20"
    And I should see "Current liabilities: $2.00"
    And I should see "Current assets: $20.00"
    And I should see "Net equity: $18.18"

