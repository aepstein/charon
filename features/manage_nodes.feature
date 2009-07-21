Feature: Manage nodes
  In order to Manage structure of request using node
  As an applicant
  I want to create, list, and destroy nodes

  Background:
    Given the following structures:
      | name |
      | test |

  Scenario: Register new node
    Given I am on "test's new node page"
    When I fill in "node_name" with "test node"
    And I fill in "node_requestable_type" with "AdministrativeExpense"
    And I fill in "node_item_amount_limit" with "1000.0"
    And I fill in "node_item_quantity_limit" with "4"
    And I press "Create"
    Then I should see "Node was successfully created."

  Scenario: Edit node
    Given the following nodes:
      | structure_id | requestable_type      |
      | 1            | AdministrativeExpense |
    And I am on "test's node page"
    When I follow "Edit"
    And I fill in "node_name" with "antinode"
    And I press "Update"
    Then I should see "Node was successfully updated."

