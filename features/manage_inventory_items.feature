Feature: Manage fund_requests
  In order to track inventories of organizations
  As an organization officer or staff
  I want to manage inventory_items

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for inventory_items controller
    Given an organization exists
    And a user: "member" exists
    And a fund_requestor_role exists
    And a membership exists with user: user "member", organization: the organization, role: the fund_requestor_role
    And a user: "regular" exists
    And an inventory_item exists with description: "Boots", organization: the organization
    And an inventory_item exists with description: "Socks", organization: the organization, acquired_on: "2010-01-01", retired_on: "2010-02-01"
    And I log in as user: "<user>"
    And I am on the new inventory_item page for the organization
    Then I should <create> authorized
    Given I post on the inventory_items page for the organization
    Then I should <create> authorized
    And I am on the edit page for the inventory_item
    Then I should <update> authorized
    Given I put on the page for the inventory_item
    Then I should <update> authorized
    Given I am on the page for the inventory_item
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the inventory_items page for the organization
    Then I should <show> "Boots"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New inventory fund_item"
    Given I am on the active inventory_items page for the organization
    Then I should <show> "Boots"
    Given I am on the retired inventory_items page for the organization
    Then I should <show> "Socks"
    Given I am on the inventory_items page
    Then I should <show> "Boots"
    Given I am on the active inventory_items page
    Then I should <show> "Boots"
    Given I am on the retired inventory_items page
    Then I should <show> "Socks"
    Given I delete on the page for the inventory_item
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | show    | destroy |
      | admin   | see     | see     | see     | see     |
      | member  | not see | see     | see     | not see |
      | regular | not see | not see | not see | not see |

  Scenario: Create and update inventory_items
    Given an organization exists with last_name: "Spending Club"
    And I log in as user: "admin"
    And I am on the new inventory_item page for the organization
    When I fill in "Description" with "Boots"
    And I fill in "Identifier" with "Boots-0001"
    And I fill in "Comments" with "These come in *pairs*."
    And I fill in "Purchase price" with "50"
    And I fill in "Current value" with "25"
    And I choose "Usable"
    And I choose "Not missing"
    And I fill in "Acquired on" with "2010-01-01"
    And I fill in "Scheduled retirement on" with "2015-01-01"
    And I press "Create"
    Then I should see "Inventory fund_item was successfully created."
    And I should see "Description: Boots"
    And I should see "Identifier: Boots-0001"
    And I should see "These come in pairs."
    And I should see "Purchase price: $50.00"
    And I should see "Current value: $25.00"
    And I should see "Usable? Usable"
    And I should see "Missing? Not missing"
    And I should see "Acquired on: January 1, 2010"
    And I should see "Scheduled retirement on: January 1, 2015"
    And I should not see "Retired on"
    When I follow "Edit"
    And I fill in "Description" with "Ski boots"
    And I fill in "Identifier" with "Boots-0002"
    And I fill in "Comments" with "These are for skiing."
    And I fill in "Purchase price" with "55"
    And I fill in "Current value" with "30"
    And I choose "Not usable"
    And I choose "Missing"
    And I fill in "Acquired on" with "2011-01-01"
    And I fill in "Scheduled retirement on" with "2015-01-02"
    And I fill in "Retired on" with "2012-01-01"
    And I press "Update"
    Then I should see "Inventory fund_item was successfully updated."
    And I should see "Description: Ski boots"
    And I should see "Identifier: Boots-0002"
    And I should see "These are for skiing."
    And I should see "Purchase price: $55.00"
    And I should see "Current value: $30.00"
    And I should see "Usable? Not usable"
    And I should see "Missing? Missing"
    And I should see "Acquired on: January 1, 2011"
    And I should see "Scheduled retirement on: January 2, 2015"
    And I should see "Retired on: January 1, 2012"

  Scenario: List and delete inventory fund_items
    Given an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And an inventory_item exists with description: "Sandals", identifier: "foot31", organization: organization "last"
    And an inventory_item exists with description: "Sandals", identifier: "foot30", organization: organization "last"
    And an inventory_item exists with description: "Boots", identifier: "foot2", organization: organization "first"
    And an inventory_item exists with description: "Boots", identifier: "foot1", organization: organization "first"
    And I log in as user: "admin"
    And I am on the inventory_items page
    When I fill in "Description" with "Boot"
    And I press "Search"
    Then I should see the following inventory_items:
      | Organization | Identifier |
      | First Club   | foot1      |
      | First Club   | foot2      |
    Given I am on the inventory_items page
    And I fill in "Identifier" with "foot3"
    And I press "Search"
    Then I should see the following inventory_items:
      | Organization | Identifier |
      | Last Club    | foot30     |
      | Last Club    | foot31     |
    Given I am on the inventory_items page for organization: "first"
    Then I should see the following fund_requests:
      | Identifier |
      | foot1      |
      | foot2      |
    When I follow "Destroy" for the 3rd inventory_item
    And I am on the inventory_items page
    Then I should see the following inventory_items:
      | Organization | Identifier |
      | First Club   | foot1      |
      | First Club   | foot2      |
      | Last Club    | foot31     |

