Feature: Manage bases
  In order to [goal]
  [stakeholder]
  wants [behaviour]

  Scenario: Register new basis
    Given I am on the new basis page
    When I fill in "Structure" with "structure_id 1"
    And I fill in "Open at" with "open_at 1"
    And I fill in "Closed at" with "closed_at 1"
    And I press "Create"
    Then I should see "structure_id 1"
    And I should see "open_at 1"
    And I should see "closed_at 1"

  Scenario: Delete basis
    Given the following bases:
      |structure_id|open_at|closed_at|
      |structure_id 1|open_at 1|closed_at 1|
      |structure_id 2|open_at 2|closed_at 2|
      |structure_id 3|open_at 3|closed_at 3|
      |structure_id 4|open_at 4|closed_at 4|
    When I delete the 3rd basis
    Then I should see the following bases:
      |structure_id|open_at|closed_at|
      |structure_id 1|open_at 1|closed_at 1|
      |structure_id 2|open_at 2|closed_at 2|
      |structure_id 4|open_at 4|closed_at 4|

