Feature: Manage request_nodes
  In order to Manage structure of request using request node
  As an applicant
  wants request node form

  @qeer
  Scenario: Register new request_node
    Given I am on the new request_node page
    When I fill in "request_node_name" with "Lovish"
    And I fill in "request_node_form_type" with "Administrative"
    And I fill in "request_node_item_amount_limit" with "1000.0"
    And I fill in "request_node_item_quantity_limit" with "4"
    And I fill in "request_node_request_structure_id" with "1212"
    And I fill in "request_node_parent_id" with "111"
    And I press "Create"
    Then I should see "Lovish"
    And I should see "Administrative"
    And I should see "1000.0"
    And I should see "4"
    And I should see "1212"
    And I should see "111"

  Scenario: Delete request_node
    Given the following request_nodes:
      |name|form_type|item_amount_limit|item_quantity_limit|request_structure_id|parent_id|
      |name 1|form_type 1|item_amount_limit 1|item_quantity_limit 1|request_structure_id 1|parent_id 1|
      |name 2|form_type 2|item_amount_limit 2|item_quantity_limit 2|request_structure_id 2|parent_id 2|
      |name 3|form_type 3|item_amount_limit 3|item_quantity_limit 3|request_structure_id 3|parent_id 3|
      |name 4|form_type 4|item_amount_limit 4|item_quantity_limit 4|request_structure_id 4|parent_id 4|
    When I delete the 3rd request_node
    Then I should see the following request_nodes:
      |name|form_type|item_amount_limit|item_quantity_limit|request_structure_id|parent_id|
      |name 1|form_type 1|item_amount_limit 1|item_quantity_limit 1|request_structure_id 1|parent_id 1|
      |name 2|form_type 2|item_amount_limit 2|item_quantity_limit 2|request_structure_id 2|parent_id 2|
      |name 4|form_type 4|item_amount_limit 4|item_quantity_limit 4|request_structure_id 4|parent_id 4|

