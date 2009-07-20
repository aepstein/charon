Feature: Manage local_event_expenses
  In order to validate requests for local event expenses
  As an applicant
  I want a local event expense addendum

  Scenario: Register new local_event_expense
    Given I am on the new local_event_expense page
    When I fill in "local_event_expense_anticipated_no_of_attendees" with "1"
    And I fill in "local_event_expense_admission_charge_per_attendee" with "1"
    And I fill in "local_event_expense_number_of_publicity_copies" with " 1"
    And I fill in "local_event_expense_rental_equipment_services" with " 1"
    And I fill in "local_event_expense_copyright_fees" with " 1"
    And I press "Create"
    And I should see "Total copy rate: $0.03"
    And I should see "Total eligible expenses: $2.03"
    And I should see "Admission charge revenue: $1.0"
    And I should see "Total request amount: $1.03"

