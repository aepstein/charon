Feature: Organization dashboard
  In order to quickly access key information and features for an organization
  As an officer of the organization
  I want a dashboard

  Background:
    Given an organization: "applicant" exists with last_name: "Money Taking Club"
    And a user: "requestor" exists
    And a requestor_role exists
    And a membership exists with user: user "requestor", role: the requestor_role, organization: organization "applicant"
    And I log in as user: "requestor"

  Scenario: No information
    Given I am on the dashboard page for organization: "applicant"
    Then I should see "Money Taking Club Dashboard"
    And I should see "You have no fund requests in process."
    And I should see "You may request grants from 0 fund sources."
    And I should see "You have no current fund grants."
    And I should see "You have no closed fund grants."
    And I should see "You have no available funds."
    And I should see "Your organization has not submitted a financial profile."
    And I should see "You may edit your organization's profile here."

  Scenario: With organization profile
    Given an organization_profile exists with organization: organization "applicant"
    And I am on the dashboard page for organization: "applicant"
    Then I should see "Your organization's financial profile was last updated on"
    And I should see "You may edit your organization's profile here."

  Scenario: Active fund requests
    Given a fund_source exists with name: "Easy Money"
    And a fund_grant exists with organization: organization "applicant", fund_source: the fund_source
    And a fund_request exists with fund_grant: the fund_grant
    And I am on the dashboard page for organization: "applicant"
    Then I should see "You have 1 active request in process:"
    And I should see the following fund_requests:
      | Fund source | State   |
      | Easy Money  | started |
    And I should not see "You have no fund requests in process."

  Scenario: Inactive fund requests
    Given a fund_source exists with name: "Easy Money"
    And a fund_grant exists with organization: organization "applicant", fund_source: the fund_source
    And a fund_request exists with fund_grant: the fund_grant, state: "rejected", reject_message: "No good"
    And I am on the dashboard page for organization: "applicant"
    Then I should see "You may view 1 inactive fund request."

  Scenario: Current fund sources
    Given a fund_source exists with name: "Easy Money"
    And a fund_queue exists with fund_source: the fund_source
    And a fund_request_type exists
    And the fund_request_type is amongst the fund_request_types of the fund_queue
    And I am on the dashboard page for organization: "applicant"
    Then I should see "You may request grants from 1 fund source."

  Scenario: Current fund grants
    Given a fund_source exists with name: "Easy Money"
    And a fund_grant exists with organization: organization "applicant", fund_source: the fund_source
    And I am on the dashboard page for organization: "applicant"
    Then I should see "You have 1 current fund grant:"
    And I should see "Easy Money" within "#current_fund_grants"
    And I should not see "You have no current fund grants."

  Scenario: Closed fund grants
    Given a closed_fund_source exists with name: "Easy Money"
    And a fund_grant exists with organization: organization "applicant", fund_source: the closed_fund_source
    And I am on the dashboard page for organization: "applicant"
    Then I should see "You may view 1 closed fund grant."

  Scenario: Active accounts
    Given a fund_source exists with name: "Easy Money"
    And a fund_grant exists with fund_source: the fund_source, organization: organization "applicant"
    And a category exists with name: "Flexible Funds"
    And an activity_account exists with fund_grant: the fund_grant, category: the category
    And an account_transaction exists
    And account_adjustment exists with account_transaction: the account_transaction, activity_account: the activity_account, amount: 1000.0
    And I am on the dashboard page for organization: "applicant"
    Then I should see the following entries in "#activity-accounts":
      | Source     | Category       | Allocations | Adjustments | Available |
      | Easy Money | Flexible Funds | $0.00       | $1,000.00   | $1,000.00 |

