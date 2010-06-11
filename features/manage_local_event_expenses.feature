Feature: Manage local_event_expenses
  In order to review planned events
  As a university official
  I want to list planned events for which funding is appropriated

  Background:
    Given a user: "admin" exists with admin: true

  Scenario: List local event expenses
    Given the following reviewed local_event_expenses:
      | title        |
      | First event  |
      | Second event |
    And I log in as user: "admin"
    And I am on the local_event_expenses page
    Then I should see "Listing local events"

