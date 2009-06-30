Feature: Manage items
  In order to Manage structure of items using request item
  As an applicant
  wants request item form

  @item
  Scenario: Register new item
    Given the following requests:
        | id |
        | 1 |
    And the following nodes:
        | id | name | requestable_type |
        | 1 | node1 | AdministrativeExpense |
    And the following items:
        | id | request_id | node_id |
        | 1 | 1 | 1 |
    And I am on the items page

    When I follow "add next stage"
    And I fill in "item_node_id" with "101"
    And I press "Create"

    Then I should see "1"
    And I should see "admin"
    And I should see "1000"
    And I should see "Good"
    And I should see "600"
    And I should see "Bad"
    And I should see "2"
    And I should see "3"
    And I should see "101"


  Scenario: Select a node to go to the new item page
    Given I am on the item page
    When I select "admin node" from "node"
    Then I should see "requestable_copies"
    And I should see "requestable_repairs_restocking"
    And I should see "requestable_mailbox_wsh_25"
    And I should see "requestable_total_request"
    And I should see "request_item_amount"
    And I should see "item_requestor_comment"

