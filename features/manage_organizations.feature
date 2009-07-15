Feature: Manage organizations
  In order to Manage requests for an organization
  As a member of an organization
  I want the organization profile page

  Background:
    Given the following registered organizations:
      | last_name |
      | miner     |

  Scenario: Show the heading for requests that can be madeCreate a new request
    Given 1 basis record
    And I am on the miner organization profile page
    Then I should see "Bases for you to make requests"

  @organization
  Scenario: Create a new request
    Given 1 basis record
    And I am on the miner organization profile page
    Then I should see "Bases for you to make requests"
    And I should see "Create"
    When I follow "Create"
    Then I should see "New Request for miner"

    When I select basis 1 as the basis
    And I press "Create"
    Then I should be on the items page

  Scenario: Show the heading for incomplete requests
    Given the following requests:
      | status | organizations |
      | draft  | miner         |
    And I am on the miner organization profile page
    Then I should see "Requests you've started"

  Scenario: Edit a request
    Given the following requests:
      | status | organizations |
      | draft  | miner         |
    And I am on the miner organization profile page
    When I follow "Edit"
    Then I should see "Editing Request for miner"

    When I press "Update"
    Then I should be on the miner organization profile page

  Scenario: Show the heading for released requests
    Given the following requests:
      | status   | organizations |
      | released | miner         |
    And I am on the miner organization profile page
    Then I should see "Requests that have been released"

