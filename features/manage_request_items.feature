Feature: Manage request_items
  In order to Manage structure of items using request item
  As an applicant
  wants request item form

  @requestitem
  Scenario: Register new request_item
    Given I am on the new request_item page
    When I fill in "request_item_form_id" with "1"
    And I fill in "request_item_form_type" with "admin"
    And I fill in "request_item_request_amount" with "1000"
    And I fill in "request_item_requestor_comment" with "Good"
    And I fill in "request_item_allocation_amount" with "600"
    And I fill in "request_item_allocator_comment" with "Bad"
    And I fill in "request_item_lft" with "2"
    And I fill in "request_item_rgt" with "3"
    And I fill in "request_item_request_node_id" with "101"
    And I press "Create"
    Then I should see "1"
    And I should see "admin"
    And I should see "1000"
    And I should see "Good"
    And I should see "600"
    And I should see "Bad"
    And I should see "2"
    And I should see "3"
    And I should see "101"

  Scenario: Delete request_item
    Given the following request_items:
      |form_id|form_type|request_amount|requestor_comment|allocation_amount|allocator_comment|lft|rgt|request_node_id|
      |form_id 1|form_type 1|request_amount 1|requestor_comment 1|allocation_amount 1|allocator_comment 1|lft 1|rgt 1|request_node_id 1|
      |form_id 2|form_type 2|request_amount 2|requestor_comment 2|allocation_amount 2|allocator_comment 2|lft 2|rgt 2|request_node_id 2|
      |form_id 3|form_type 3|request_amount 3|requestor_comment 3|allocation_amount 3|allocator_comment 3|lft 3|rgt 3|request_node_id 3|
      |form_id 4|form_type 4|request_amount 4|requestor_comment 4|allocation_amount 4|allocator_comment 4|lft 4|rgt 4|request_node_id 4|
    When I delete the 3rd request_item
    Then I should see the following request_items:
      |form_id|form_type|request_amount|requestor_comment|allocation_amount|allocator_comment|lft|rgt|request_node_id|
      |form_id 1|form_type 1|request_amount 1|requestor_comment 1|allocation_amount 1|allocator_comment 1|lft 1|rgt 1|request_node_id 1|
      |form_id 2|form_type 2|request_amount 2|requestor_comment 2|allocation_amount 2|allocator_comment 2|lft 2|rgt 2|request_node_id 2|
      |form_id 4|form_type 4|request_amount 4|requestor_comment 4|allocation_amount 4|allocator_comment 4|lft 4|rgt 4|request_node_id 4|

