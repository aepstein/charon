Feature: Manage bases
  In order to set terms on which requests are made
  As a reviewer
  I want to manage bases

  Scenario: Register new basis
    Given the following structures:
      | name |
      | test |
    And I am on "test's new basis page"
    When I fill in "Name" with "Basis 1"
    And I fill in "Open at" with "2009-10-15 12:00:00"
    And I fill in "Closed at" with "2009-10-20 12:00:00"
    And I press "Create"
    Then I should see "Basis was successfully created."

  @wip
  Scenario: Delete basis
    Given 1 structure record
    And the following bases:
      |name| structure_id |
      |name 1| 1 |
      |name 2| 1 |
      |name 3| 1 |
      |name 4| 1 |
    When I delete the 3rd basis
    Then I should see the following bases:
      |name|
      |name 1|
      |name 2|
      |name 4|

