Feature: Manage versions
  In order to [goal]
  [stakeholder]
  wants [behaviour]
  
  Scenario: Register new version
    Given I am on the new version page
    When I fill in "Item" with "item_id 1"
    And I fill in "Amount" with "amount 1"
    And I fill in "Comment" with "comment 1"
    And I fill in "Perspective" with "perspective 1"
    And I press "Create"
    Then I should see "item_id 1"
    And I should see "amount 1"
    And I should see "comment 1"
    And I should see "perspective 1"

  Scenario: Delete version
    Given the following versions:
      |item_id|amount|comment|perspective|
      |item_id 1|amount 1|comment 1|perspective 1|
      |item_id 2|amount 2|comment 2|perspective 2|
      |item_id 3|amount 3|comment 3|perspective 3|
      |item_id 4|amount 4|comment 4|perspective 4|
    When I delete the 3rd version
    Then I should see the following versions:
      |Item|Amount|Comment|Perspective|
      |item_id 1|amount 1|comment 1|perspective 1|
      |item_id 2|amount 2|comment 2|perspective 2|
      |item_id 4|amount 4|comment 4|perspective 4|
