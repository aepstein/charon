Feature: Manage administrative_expenses
  In order to calculate administrative expense amounts
  as an applicant
  wants administrative expenses form

  Scenario: Register new administrative_expense
    Given I am on the new administrative_expense page
    When I fill in "Copies" with "copies 1"
    And I fill in "Copies expense" with "copies_expense 1"
    And I fill in "Repairs restocking" with "repairs_restocking 1"
    And I fill in "Mailbox wsh" with "mailbox_wsh 1"
    And I fill in "Total request" with "total_request 1"
    And I fill in "Total" with "total 1"
    And I press "Create"
    Then I should see "copies 1"
    And I should see "copies_expense 1"
    And I should see "repairs_restocking 1"
    And I should see "mailbox_wsh 1"
    And I should see "total_request 1"
    And I should see "total 1"

  Scenario: Delete administrative_expense
    Given the following administrative_expenses:
      |copies  |copies_expense  |repairs_restocking  |mailbox_wsh  |total_request  |total  |
      |copies 1|copies_expense 1|repairs_restocking 1|mailbox_wsh 1|total_request 1|total 1|
      |copies 2|copies_expense 2|repairs_restocking 2|mailbox_wsh 2|total_request 2|total 2|
      |copies 3|copies_expense 3|repairs_restocking 3|mailbox_wsh 3|total_request 3|total 3|
      |copies 4|copies_expense 4|repairs_restocking 4|mailbox_wsh 4|total_request 4|total 4|
    When I delete the 3rd administrative_expense
    Then I should see the following administrative_expenses:
      |copies  |copies_expense  |repairs_restocking  |mailbox_wsh  |total_request  |total  |
      |copies 1|copies_expense 1|repairs_restocking 1|mailbox_wsh 1|total_request 1|total 1|
      |copies 2|copies_expense 2|repairs_restocking 2|mailbox_wsh 2|total_request 2|total 2|
      |copies 4|copies_expense 4|repairs_restocking 4|mailbox_wsh 4|total_request 4|total 4|

