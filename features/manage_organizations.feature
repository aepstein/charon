Feature: Manage organizations
  In order to Manage requests for an organization
  As a member of an organization
  wants organizations profile page

  @organization
  Scenario: Show the heading for requests that can be made
    Given the following registered organizations:
      | last_name |
      | miner     |
    And the following requests:
      | status | organizations |
      | draft  | miner         |
    And there is an open basis
    And I am on "the miner organization profile page"

    Then I should see "Bases for you to make requests"

  @organization
  Scenario: Show the heading for incomplete requests
    Given the following registered organizations:
      | last_name |
      | miner     |
    And the following requests:
      | status | organizations |
      | draft  | miner         |
    And I am on "the miner organization profile page"

    Then I should see "Requests you've started"

  @organization
  Scenario: Show the heading for released requests
    Given the following registered organizations:
      | last_name |
      | miner     |
    And the following requests:
      | status   | organizations |
      | released | miner         |
    And there is a released request
    And I am on "the miner organization profile page"

    Then I should see "Requests that have been released"

