Feature: Manage structures
  In order to Manage structure of request
  As an applicant
  I want a structure form

@request
  Scenario: Register new structure
    Given I am on the new structure page
    When I fill in "structure_name" with "Lovish"
    And I press "Create"
    Then I should see "Lovish"

  Scenario: Delete structure
    Given the following structures:
      |name|
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd structure
    Then I should see the following structures:
      |name|
      |name 1|
      |name 2|
      |name 4|

