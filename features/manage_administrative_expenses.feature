Feature: Manage administrative_expenses
  In order to calculate administrative expense amounts
  as an applicant
  wants administrative expenses form

  Scenario: Register new administrative_expense
    Given I am on the new administrative_expense page
    When I fill in "copies" with "1"
    And I fill in "Repairs restocking" with "repairs_restocking 1"
    And I fill in "Mailbox wsh" with "mailbox_wsh 1"
    And I press "Create"
    Then I should see "copies 1"
    And I should see "copies_expense 1"
    And I should see "repairs_restocking 1"
    And I should see "mailbox_wsh 1"
    And I should see "total_request 1"
    And I should see "total 1"

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

