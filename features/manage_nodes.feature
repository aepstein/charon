Feature: Manage nodes
  In order to Manage structure of request using node
  As an applicant
  I want to create, list, and destroy nodes

  Scenario: Register new node
    Given the following structures:
      | id | name |
      | 1 | test |
    And I am on "test's new node page"
    When I fill in "node_name" with "test node"
    And I fill in "node_requestable_type" with "AdministrativeExpense"
    And I fill in "node_item_amount_limit" with "1000.0"
    And I fill in "node_item_quantity_limit" with "4"
    And I press "Create"
    Then I should see "Node was successfully created."

