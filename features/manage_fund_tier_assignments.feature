Feature: Manage fund_tier_assignments
  In order to provide review and set fund tier assignments for organizations which have fund tier associations
  As a leader or manager
  I want to manage fund_tier_assignments

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And an organization "source" exists
    And a fund_tier: "focus" exists with maximum_allocation: 1000.0, organization: organization "source"

  Scenario: Create fund_tier_assignments
    Given a fund_source exists with name: "Annual", organization: organization "source"
    And the fund_tier is amongst the fund_tiers of the fund_source
    And a fund_tier: "higher" exists with maximum_allocation: 2000.0, organization: organization "source"
    And the fund_tier is amongst the fund_tiers of the fund_source
    And an organization exists with last_name: "Spending Club"
    And I log in as user: "admin"
    And I am on the new fund_tier_assignment page for the fund_source
    When I fill in "Organization" with "Spending Club, "
    And I select "$1,000.00" from "Fund tier"
    And I press "Create"
    Then I should see "Fund tier assignment was successfully created."
    And show me the page
    And I should see the following fund_tier_assignments:
      | Organization  | Fund tier |
      | Spending Club | $1,000.00 |

  @javascript
  Scenario: Edit fund_tier_assignments
    Given a fund_source exists with name: "Annual", organization: organization "source"
    And the fund_tier is amongst the fund_tiers of the fund_source
    And a fund_tier: "higher" exists with maximum_allocation: 2000.0, organization: organization "source"
    And the fund_tier is amongst the fund_tiers of the fund_source
    And an organization exists with last_name: "Spending Club"
    And a fund_tier_assignment exists with fund_tier: fund_tier "focus", organization: the organization, fund_source: the fund_source
    And I log in as user: "admin"
    And I am on the fund_tier_assignments page for the fund_source
    When I select "$2,000.00" for the "fund_tier_id" of the fund_tier_assignment in place
    Then the fund_tier_assignment's to_s should be "$2,000.00"

  Scenario: List and delete fund_tier_assignments
    Given a fund_source: "annual" exists with name: "Annual", organization: organization "source"
    And fund_tier: "focus" is amongst the fund_tiers of the fund_source
    And a fund_source: "semester" exists with name: "Semester", organization: organization "source"
    And fund_tier: "focus" is amongst the fund_tiers of the fund_source
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a fund_tier_assignment exists with fund_source: fund_source "semester", organization: organization: "last", fund_tier: fund_tier "focus"
    And a fund_tier_assignment exists with fund_source: fund_source "semester", organization: organization: "first", fund_tier: fund_tier "focus"
    And a fund_tier_assignment exists with fund_source: fund_source "annual", organization: organization: "last", fund_tier: fund_tier "focus"
    And a fund_tier_assignment exists with fund_source: fund_source "annual", organization: organization: "first", fund_tier: fund_tier "focus"
    And I log in as user: "admin"
    Given I am on the fund_tier_assignments page for fund_source: "annual"
    Then I should see the following fund_tier_assignments:
      | Organization |
      | First Club   |
      | Last Club    |
    When I fill in "Organization" with "last"
    And I press "Search"
    Then I should see the following fund_tier_assignments:
      | Organization |
      | Last Club    |
    When I follow "Destroy" for the 2nd fund_tier_assignment for fund_source: "annual"
    And I am on the fund_tier_assignments page for fund_source: "annual"
    Then I should see the following fund_tier_assignments:
      | Organization  |
      | First Club    |

