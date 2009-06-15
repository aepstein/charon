Feature: Manage request_bases
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new request_basis
    Given I am on the new request_basis page
    When I fill in "Request structure" with "request_structure_id 1"
    And I fill in "Open at" with "open_at 1"
    And I fill in "Closed at" with "closed_at 1"
    And I press "Create"
    Then I should see "request_structure_id 1"
    And I should see "open_at 1"
    And I should see "closed_at 1"

  Scenario: Delete request_basis
    Given the following request_bases:
      |request_structure_id|open_at|closed_at|
      |request_structure_id 1|open_at 1|closed_at 1|
      |request_structure_id 2|open_at 2|closed_at 2|
      |request_structure_id 3|open_at 3|closed_at 3|
      |request_structure_id 4|open_at 4|closed_at 4|
    When I delete the 3rd request_basis
    Then I should see the following request_bases:
      |request_structure_id|open_at|closed_at|
      |request_structure_id 1|open_at 1|closed_at 1|
      |request_structure_id 2|open_at 2|closed_at 2|
      |request_structure_id 4|open_at 4|closed_at 4|
