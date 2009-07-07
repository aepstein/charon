Feature: Manage registered_membership_conditions
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new registered_membership_condition
    Given I am on the new registered_membership_condition page
    And I press "Create"

  Scenario: Delete registered_membership_condition
    Given the following registered_membership_conditions:
      ||
      ||
      ||
      ||
      ||
    When I delete the 3rd registered_membership_condition
    Then I should see the following registered_membership_conditions:
      ||
      ||
      ||
      ||
