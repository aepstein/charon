Feature: Manage organizations
  In order to Manage requests for an organization
  As a member of an organization
  wants organizations profile page

  @organization
  Scenario: Provide Edit and Destroy links for incomplete requests
    Given the following organization record:
      | id | last_name |
      | 1  | miner     |
    And the following request record:
      | status |
      | draft  |
    And I am on the 1 organization profile page

    Then I should see "Edit"
    And I should see "Destroy"

  @organization
  Scenario: Provide a View link for released requests
    Given the following organization record:
      | id | last_name |
      | 1  | miner     |
    And the following requests:
      | status   | organizations |
      | released | miner         |
    And I am on the 1 organization profile page

    Then I should see "Show"

