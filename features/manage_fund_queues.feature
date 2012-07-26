Feature: Display fund queues
  In order to report information about batches of submissions and allocations
  As an administrator
  I want to show fund_queues

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true

  Scenario Outline: Show a fund queue
    Given a fund_source exists
    And a fund_queue exists with fund_source: the fund_source
    And a fund_grant exists with fund_source: the fund_source
    And an approvable_fund_request exists with state: "<state>", review_state: "ready", fund_queue: the fund_queue, fund_grant: the fund_grant
    And a fund_item exists with fund_grant: the fund_grant
    And a fund_edition exists with fund_item: the fund_item, fund_request: the approvable_fund_request, perspective: "requestor", amount: 1000.0
    And a fund_edition exists with fund_item: the fund_item, fund_request: the approvable_fund_request, perspective: "reviewer", amount: 100.0
    And a fund_allocation exists with fund_item: the fund_item, fund_request: the approvable_fund_request, amount: 100.0
    And I log in as user: "admin"
    And I am on the page for the fund_queue
    Then I should see "Total requests (count): 1"
    And I should see "Total requests (amount): $1,100.00"
    And I should see "Total reviewer amount (before caps and cuts): $100.00"
    And I should see "Total pending allocations: $<pending>.00"
    And I should see "Total final allocations: $<final>.00"
    Examples:
      | state     | pending | final |
      | released  | 100     | 0     |
      | allocated | 0       | 100   |

