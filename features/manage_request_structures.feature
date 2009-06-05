Feature: Manage request_structures
  In order to Manage structure of request
  As an applicant
  wants request structure form

@request
  Scenario: Register new request_structure
    Given I am on the new request_structure page
    When I fill in "request_structure_name" with "Lovish"
    And I press "Create"
    Then I should see "Lovish"

  Scenario: Delete request_structure
    Given the following request_structures:
      |name|
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd request_structure
    Then I should see the following request_structures:
      |name|
      |name 1|
      |name 2|
      |name 4|

