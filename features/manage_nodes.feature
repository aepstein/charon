Feature: Manage nodes
  In order to Manage structure of request using node
  As an applicant
  I want to create, list, and destroy nodes

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And a structure: "annual" exists with name: "annual"
    And a category: "simple" exists with name: "simple"
    And a category: "complex" exists with name: "complex"

  Scenario Outline: Test permissions for nodes controller actions
    Given a node: "basic" exists with structure: structure "annual"
    And I am logged in as "<user>" with password "secret"
    And I am on the new node page for structure: "annual"
    Then I should <create>
    Given I post on the nodes page for structure: "annual"
    Then I should <create>
    And I am on the edit page for node: "basic"
    Then I should <update>
    Given I put on the page for node: "basic"
    Then I should <update>
    Given I am on the page for node: "basic"
    Then I should <show>
    Given I delete on the page for node: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Create new node and update
    Given I am logged in as "admin" with password "secret"
    And I am on the new node page for structure: "annual"
    When I fill in "Name" with "administrative expense"
    And I select "Administrative" from "node_requestable_type"
    And I select "simple" from "Category"
    And I fill in "Item amount limit" with "1000"
    And I fill in "Item quantity limit" with "4"
    And I press "Create"
    Then I should see "Node was successfully created."
    And I should see "Name: administrative expense"
    And I should see "Requestable type: Administrative"
    And I should see "Category: simple"
    And I should see "Item amount limit: $1,000.00"
    And I should see "Item quantity limit: 4"
    When I follow "Edit"
    And I fill in "Name" with "local event expense"
    And I select "Local Event" from "node_requestable_type"
    And I select "complex" from "Category"
    And I fill in "Item amount limit" with "2000"
    And I fill in "Item quantity limit" with "2"
    And I press "Update"
    Then I should see "Node was successfully updated."
    And I should see "Name: local event expense"
    And I should see "Requestable type: Local Event"
    And I should see "Category: complex"
    And I should see "Item amount limit: $2,000.00"
    And I should see "Item quantity limit: 2"

  Scenario: Delete and list nodes
    Given a node exists with name: "node 4", structure: structure "annual"
    And a node exists with name: "node 3", structure: structure "annual"
    And a node exists with name: "node 2", structure: structure "annual"
    And a node exists with name: "node 1", structure: structure "annual"
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd node for structure: "annual"
    Then I should see the following nodes:
      | Name   |
      | node 1 |
      | node 2 |
      | node 4 |

