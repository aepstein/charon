Feature: Manage request_items
  In order to Manage structure of items using request item
  As an applicant
  wants request item form

  @requestitem
  Scenario: Register new request_item
    Given I am on the new request_item page
    When I fill in "request_item_requestable_id" with "1"
    And I fill in "request_item_requestable_type" with "admin"
    And I fill in "request_item_request_amount" with "1000"
    And I fill in "request_item_requestor_comment" with "Good"
    And I fill in "request_item_allocation_amount" with "600"
    And I fill in "request_item_allocator_comment" with "Bad"
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

