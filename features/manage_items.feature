Feature: Manage items
  In order to Manage structure of items using request item
  As an applicant
  wants request item form

  @item
  Scenario: Register new item
    Given 1 item record
    And the following stage record:
      | name    | position |
      | request | 1        |
    And I am on the items page

    Then I should see "add next stage"

    When I follow "add next stage"
    Then I should see "Form type: AdministrativeExpense"
    And I should see "Stage: request"

    When I fill in "version_amount" with "100"
    And I fill in "version_comment" with "this is only a test"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: AdministrativeExpense"
    And I should see "Amount: $100.00"
    And I should see "Comment: this is only a test"

  @item
  Scenario: Do not show link for next stage if the item already has two
    Given the following item record:
      | id |
      | 1 |
    And the following version records:
      | stage_id | item_id |
      | 1 | 1 |
      | 2 | 1 |
    And the following stage records:
      | id | name       | position |
      | 1  | request    | 1        |
      | 2  | allocation | 2        |
    And I am on the items page

    Then I should not see "add next stage"

  Scenario: Select a node to go to the new item page
    Given I am on the items page
    When I select "admin expense node" from "node"
    Then I should see "requestable_copies"
    And I should see "requestable_repairs_restocking"
    And I should see "requestable_mailbox_wsh_25"
    And I should see "requestable_total_request"
    And I should see "request_item_amount"
    And I should see "item_requestor_comment"

