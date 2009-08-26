Feature: Manage structures
  In order to Manage structure of request
  As an applicant
  I want a structure form

  Background:
    Given the following users:
      | net_id | password | admin |
      | admin  | secret   | true  |

  Scenario: Register new structure
    Given I am logged in as "admin" with password "secret"
    And I am on the new structure page
    When I fill in "Name" with "safc semester"
    And I press "Create"
    Then I should see "Structure was successfully created."
    And I should see "Name: safc semester"
    When I follow "Edit"
    And I fill in "structure_name" with "changed"
    And I press "Update"
    Then I should see "Structure was successfully updated."
    And I should see "Name: changed"

  Scenario: Delete structure
    Given I am logged in as "admin" with password "secret"
    And the following structures:
      | name   |
      | name 1 |
      | name 2 |
      | name 3 |
      | name 4 |
    When I delete the 3rd structure
    Then I should see the following structures:
      | name   |
      | name 1 |
      | name 2 |
      | name 4 |

