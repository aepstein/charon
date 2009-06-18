Feature: Manage nodes
  In order to Manage structure of request using node
  As an applicant
  wants request node form

  @qeer
  Scenario: Register new node
    Given I am on the new node page
    When I fill in "node_name" with "Lovish"
    And I fill in "node_requestable_type" with "Administrative"
    And I fill in "node_item_amount_limit" with "1000.0"
    And I fill in "node_item_quantity_limit" with "4"
    And I fill in "node_structure_id" with "1212"
    And I fill in "node_parent_id" with "111"
    And I press "Create"
    Then I should see "Lovish"
    And I should see "Administrative"
    And I should see "1000.0"
    And I should see "4"
    And I should see "1212"
    And I should see "111"

  Scenario: Delete node
    Given the following nodes:
      |name|requestable_type|item_amount_limit|item_quantity_limit|structure_id|parent_id|
      |name 1|requestable_type 1|item_amount_limit 1|item_quantity_limit 1|structure_id 1|parent_id 1|
      |name 2|requestable_type 2|item_amount_limit 2|item_quantity_limit 2|structure_id 2|parent_id 2|
      |name 3|requestable_type 3|item_amount_limit 3|item_quantity_limit 3|structure_id 3|parent_id 3|
      |name 4|requestable_type 4|item_amount_limit 4|item_quantity_limit 4|structure_id 4|parent_id 4|
    When I delete the 3rd node
    Then I should see the following nodes:
      |name|requestable_type|item_amount_limit|item_quantity_limit|structure_id|parent_id|
      |name 1|requestable_type 1|item_amount_limit 1|item_quantity_limit 1|structure_id 1|parent_id 1|
      |name 2|requestable_type 2|item_amount_limit 2|item_quantity_limit 2|structure_id 2|parent_id 2|
      |name 4|requestable_type 4|item_amount_limit 4|item_quantity_limit 4|structure_id 4|parent_id 4|

