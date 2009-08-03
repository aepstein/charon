Feature: Manage versions
  In order to calculate and track transaction requests
  As a requestor or reviewer
  I want to create, update, and show versions

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
      | budget    | SpeakerExpense        | speaker expense        |
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
    And the following items:
      | request | node                   |
      | 1       | administrative expense |
      | 1       | durable good expense   |
      | 1       | publication expense    |
      | 1       | local event expense    |
      | 1       | travel event expense   |
      | 1       | speaker expense        |

  @current
  Scenario: Add and update version (administrative_expense)
    And I am logged in as "admin" with password "secret"
    And I am on the new version page of the 1st item
    When I fill in "version_administrative_expense_attributes_copies" with "100"
    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "100"
    And I choose "version_administrative_expense_attributes_mailbox_wsh_25"
    And I fill in "version_amount" with "100"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: AdministrativeExpense"
    And I should see "Request node: administrative expense"
    And I should see "Maximum request: $128.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    When I follow "Edit"
    And I fill in "version_administrative_expense_attributes_copies" with "101"
    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "99"
    And I choose "version_administrative_expense_attributes_mailbox_wsh_40"
    And I fill in "version_amount" with "120"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: AdministrativeExpense"
    And I should see "Request node: administrative expense"
    And I should see "Maximum request: $142.03"
    And I should see "Requestor amount: $120.00"
    And I should see "Requestor comment: changed comment"
    When I follow "Edit"
    And I fill in "version_amount" with "150"
    And I press "Update"
    Then I should not see "Version was successfully updated."

