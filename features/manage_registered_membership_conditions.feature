@ate2
Feature: Manage registered_membership_conditions
  In order to track whether a sufficient constituency of a group is present
  As a university unit
  I want to track and enforce membership percentage conditions

  Scenario: Register new registered_membership_condition
    Given I am on the new registered_membership_condition page
    When I fill in "registered_membership_condition[membership_type]" with "undergrads"
    And I fill in "registered_membership_condition[membership_percentage]" with "60"
    And I press "Create"
    Then I should see "successfully created"

  Scenario: Organizations with active registrations meeting requirements should be fulfilled
    Given the following organization records:
      | id | last_name |
      | 1 | organization 1 |
      | 2 | organization 2 |
    And the following registration records:
      | organization_id | number_of_undergrads | number_of_grads | number_of_staff |
      | 1 | 65 | 10 | 0 |
      | 2 | 10 | 65 | 0 |
    And the following registered_membership_condition records:
      | membership_type | membership_percentage |
      | undergrads | 60 |
    When I go to the fulfillments page
    Then I should see "organization 1"
    And I should not see "organization 2"

