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

