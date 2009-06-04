Feature: Manage administrative_expenses
  In order to calculate administrative expense amounts
  As an applicant
  I want administrative expenses form

  Scenario: Register new administrative_expense
    Given I am on the new administrative_expense page
    When I fill in "administrative_expense_copies" with "1"
    And I fill in "administrative_expense_repairs_restocking" with "1"
    And I choose "administrative_expense_mailbox_wsh_40"
    And I press "Create"
    Then I should see "Maximum request: $41.03"

  Scenario: Delete administrative_expense
    Given the following administrative_expenses:
      |copies  |repairs_restocking  |mailbox_wsh  |
      |       1|                   1|            1|
      |       2|                   2|            2|
      |       3|                   3|            3|
      |       4|                   4|            4|
    When I delete the 3rd administrative_expense
    Then I should see the following administrative_expenses:
      |copies  |repairs_restocking  |mailbox_wsh  |
      |       1|                   1|            1|
      |       2|                   2|            2|
      |       4|                   4|            4|

