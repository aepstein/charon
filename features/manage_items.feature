Feature: Manage items
  In order to Manage structure of items using request item
  As an applicant
  wants request item form

  Background:
    Given the following safc eligible organizations:
      | last_name      |
      | organization 1 |
    And the following requests:
      | status   | organizations  |
      | started  | organization 1 |

  Scenario: Register new item
    Given the following items:
      | request_id |
      | 1          |
    And I am on the items page
    Then I should see "add next stage"

    When I follow "add next stage"
    Then I should see "Form type: AdministrativeExpense"
    And I should see "Stage: request"

    When I fill in "version_administrative_expense_attributes_copies" with "100"
    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "100"
    And I choose "version_administrative_expense_attributes_mailbox_wsh_25"
    And I fill in "version_amount" with "100"
    And I fill in "version_comment" with "this is only a test"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: AdministrativeExpense"
    And I should see "request amount: $100.00"
    And I should see "request comment: this is only a test"

  Scenario: Do not show link for next stage if the item already has two
    Given the following items:
      | request_id |
      | 1          |
    And the following versions:
      | stage_id | item_id | amount |
      | 0        | 1       | 100    |
      | 1        | 1       | 100    |
    And I am on the items page
    Then I should not see "add next stage"

  Scenario: Select a node to go to the new item page (uses javascript)
    Given the following items:
      | request_id |
      | 1          |
    And I am on the items page
    When I select "administrative expense" from "node"
    Then I should see "Number of copies"
    And I should see "Repairs and Restocking"
    And I should see "Mailbox at Willard Straight Hall"
    And I should see "Request Amount"
    And I should see "Request Comment"

