Feature: Manage bases
  In order to set terms on which requests are made
  As a reviewer
  I want to manage bases

  Background:
    Given the following structures:
      | name |
      | test |
    And the following frameworks:
      | name        |
      | a framework |
    And the following organizations:
      | last_name      |
      | organization 1 |
    And the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
      | regular | secret   | true  |

  Scenario: Register new basis
    Given I am logged in as "admin" with password "secret"
    And I am on "organization 1's new basis page"
    When I fill in "Name" with "Basis 1"
    And I select "test" from "Structure"
    And I select "a framework" from "Framework"
    And I fill in "Open at" with "2009-10-15 12:00:00"
    And I fill in "Closed at" with "2009-10-20 12:00:00"
    And I press "Create"
    Then I should see "Basis was successfully created."

  Scenario: Edit basis
    Given the following bases:
      | name   | structure_id | organization_id |
      | name 1 | 1            | 1               |
    And I am logged in as "admin" with password "secret"
    And I am on "organization 1's bases page"
    When I follow "Edit"
    And I fill in "Open at" with "2009-10-15 12:00:00"
    And I fill in "Closed at" with "2009-10-20 12:00:00"
    And I press "Update"
    Then I should see "Basis was successfully updated."

  Scenario: Delete basis
    Given the following bases:
      | name   | structure_id | organization_id |
      | name 1 | 1            | 1               |
      | name 2 | 1            | 1               |
      | name 3 | 1            | 1               |
      | name 4 | 1            | 1               |
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd basis
    Then I should see the following bases:
      | name|
      | name 1 |
      | name 2 |
      | name 4 |

