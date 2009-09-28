Feature: Manage local_event_expenses
  In order to review planned events
  As a university official
  I want to list planned events for which funding is appropriated

  Background:
    Given the following users:
      | net_id | password | admin |
      | admin  | secret   | true  |

  Scenario: List local event expenses
    Given the following reviewed local_event_expenses:
      | title        |
      | First event  |
      | Second event |
    And I am logged in as "admin" with password "secret"
    And I am on the local_event_expenses page
    Then I should see "Listing local events"

