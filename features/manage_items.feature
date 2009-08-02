@current
Feature: Manage items
  In order to Manage structure of items using request item
  As an applicant
  I want request item form

  Background:
    Given the following organizations:
      | last_name                |
      | our club                 |
      | undergraduate commission |
    And the following users:
      | net_id       | password | admin |
      | admin        | secret   | true  |
      | president    | secret   | false |
      | commissioner | secret   | false |
    And the following roles:
      | name         |
      | president    |
      | commissioner |
    And the following memberships:
      | organization             | role         | user         |
      | our club                 | president    | president    |
      | undergraduate commission | commissioner | commissioner |
    And the following structures:
      | name               |
      | budget             |
    And the following nodes:
      | structure | requestable_type      | name                   |
      | budget    | AdministrativeExpense | administrative expense |
      | budget    | LocalEventExpense     | local event expense    |
      | budget    | TravelEventExpense    | travel event expense   |
      | budget    | DurableGoodExpense    | durable good expense   |
      | budget    | PublicationExpense    | publication expense    |
    And the following frameworks:
      | name      |
      | undergrad |
    And the following permissions:
      | framework | status  | role         | action     | perspective |
      | undergrad | started | president    | see        | requestor   |
      | undergrad | started | president    | create     | requestor   |
      | undergrad | started | president    | update     | requestor   |
      | undergrad | started | president    | destroy    | requestor   |
      | undergrad | started | commissioner | see        | reviewer    |
    And the following bases:
      | name              | organization             | structure | framework |
      | annual budget     | undergraduate commission | budget    | undergrad |
    And the following requests:
      | status   | organizations  | basis         |
      | started  | our club       | annual budget |

  Scenario: Create new item
    Given I am logged in as "admin" with password "secret"
    When I am on "our club's requests page"
    And I follow "Show Items"
    And I select "administrative expense" from "Add New Item"
    And I press "Add"
    Then I should see "Item was successfully created."

  Scenario Outline: Create new item only if admin or may update request
    Given I am logged in as "<user>" with password "secret"
    When I am on the requests page
    And I follow "Show Items"
    Then I should <should>

    Examples:
      | user         | should                 |
      | admin        | see "Add New Item"     |
      | president    | see "Add New Item"     |
      | commissioner | not see "Add New Item" |
#    And I fill in "version_administrative_expense_attributes_copies" with "100"
#    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "100"
#    And I choose "version_administrative_expense_attributes_mailbox_wsh_25"
#    And I fill in "version_amount" with "100"
#    And I fill in "version_comment" with "this is only a test"
#    And I press "Create"
#    When I follow "Show"
#    Then I should see "Requestable type: AdministrativeExpense"
#    And I should see "Request node: administrative expense"
#    And I should see "Maximum request: $200.00"
#    And I should see "Requestor amount: $100.00"
#    And I should see "Requestor comment: this is only a test"

#  Scenario: Register new item
#    Given the following items:
#      | request_id |
#      | 1          |
#    And I am on the items page
#    Then I should see "add next stage"

#    When I follow "add next stage"
#    Then I should see "Form type: AdministrativeExpense"
#    And I should see "Stage: request"


#  Scenario: Do not show link for next stage if the item already has two
#    Given the following items:
#      | request_id |
#      | 1          |
#    And the following versions:
#      | stage_id | item_id | amount |
#      | 0        | 1       | 100    |
#      | 1        | 1       | 100    |
#    And I am on the items page
#    Then I should not see "add next stage"

#  Scenario: Select a node to go to the new item page (uses javascript)
#    Given the following items:
#      | request_id |
#      | 1          |
#    And I am on the items page
#    When I select "administrative expense" from "node"
#    Then I should see "Number of copies"
#    And I should see "Repairs and Restocking"
#    And I should see "Mailbox at Willard Straight Hall"
#    And I should see "Request Amount"
#    And I should see "Request Comment"

