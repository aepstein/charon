Feature: Manage nodes
  In order to Manage structure of request using node
  As an applicant
  I want to create, list, and destroy nodes

  Background:
    Given the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
    And the following structures:
      | name |
      | test |

  Scenario: Create new node
    Given I am logged in as "admin" with password "secret"
    And I am on "test's new node page"
    When I fill in "Name" with "test node"
    And I select "Administrative" from "node_requestable_type"
    And I fill in "Item amount limit" with "1000"
    And I fill in "Item quantity limit" with "4"
    And I press "Create"
    Then I should see "Node was successfully created."
    And I should see "Name: test node"
    And I should see "Requestable type: Administrative"
    And I should see "Item amount limit: $1,000.00"
    And I should see "Item quantity limit: 4"
    When I follow "Edit"
    And I fill in "Name" with "antinode"
    And I press "Update"
    Then I should see "Node was successfully updated."
    And I should see "Name: antinode"

