Feature: Manage travel_event_expenses
  In order to calculate travel event expense amounts
  As an applicant
  I want travel event expenses form

  Scenario: Register new travel_event_expense
    Given I am on the new travel_event_expense page
    When I fill in "travel_event_expense_members_per_group" with "3"
    And I fill in "travel_event_expense_number_of_groups" with "2"
    And I fill in "travel_event_expense_mileage" with "100"
    And I fill in "travel_event_expense_nights_of_lodging" with "2"
    And I fill in "travel_event_expense_per_person_fees" with "10"
    And I fill in "travel_event_expense_per_group_fees" with "10"
    And I press "Create"
    Then I should see "Total eligible expenses: $230.00"

  Scenario: Delete travel_event_expense
    Given the following travel_event_expenses:
      ||
      ||
      ||
      ||
      ||
    When I delete the 3rd travel_event_expense
    Then I should see the following travel_event_expenses:
      ||
      ||
      ||
      ||

