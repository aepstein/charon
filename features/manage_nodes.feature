Feature: Manage nodes
  In order to Manage structure of fund_request using node
  As an applicant
  I want to create, list, and destroy nodes

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And a user: "regular" exists
    And a structure: "annual" exists with name: "annual"
    And a category: "simple" exists with name: "simple"
    And a category: "complex" exists with name: "complex"

  Scenario Outline: Test permissions for nodes controller actions
    Given a node: "basic" exists with structure: structure "annual", name: "Basic"
    And I log in as user: "<user>"
    And I am on the page for node: "basic"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the nodes page for structure: "annual"
    Then I should <show> authorized
    And I should <show> "Basic"
    And I should <create> "New node"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new node page for structure: "annual"
    Then I should <create> authorized
    Given I post on the nodes page for structure: "annual"
    Then I should <create> authorized
    And I am on the edit page for node: "basic"
    Then I should <update> authorized
    Given I put on the page for node: "basic"
    Then I should <update> authorized
    Given I delete on the page for node: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | staff   | see     | see     | not see | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Create new node and update
    Given a document_type exists with name: "Price quote"
    And a document_type exists with name: "Letter of intent"
    And I log in as user: "admin"
    And I am on the new node page for structure: "annual"
    When I fill in "Name" with "administrative expense"
    And I select "Administrative" from "node_requestable_type"
    And I select "simple" from "Category"
    And I fill in "Item amount limit" with "1000"
    And I fill in "Item quantity limit" with "4"
    And I check "Price quote"
    And I fill in "Instruction" with "You *should* do this."
    And I press "Create"
    Then I should see "Node was successfully created."
    And I should see "Name: administrative expense"
    And I should see "Requestable type: Administrative"
    And I should see "Category: simple"
    And I should see "Item amount limit: $1,000.00"
    And I should see "Item quantity limit: 4"
    And I should see "Document types: Price quote"
    And I should see "You should do this."
    When I follow "Edit"
    And I fill in "Name" with "local event expense"
    And I select "Local Event" from "node_requestable_type"
    And I select "complex" from "Category"
    And I fill in "Item amount limit" with "2000"
    And I fill in "Item quantity limit" with "2"
    And I uncheck "Price quote"
    And I fill in "Instruction" with "You should not do this."
    And I press "Update"
    Then I should see "Node was successfully updated."
    And I should see "Name: local event expense"
    And I should see "Requestable type: Local Event"
    And I should see "Category: complex"
    And I should see "Item amount limit: $2,000.00"
    And I should see "Item quantity limit: 2"
    And I should see "Document types: None"
    And I should see "You should not do this."

  Scenario: Delete and list nodes
    Given a node exists with name: "node 4", structure: structure "annual"
    And a node exists with name: "node 3", structure: structure "annual"
    And a node exists with name: "node 2", structure: structure "annual"
    And a node exists with name: "node 1", structure: structure "annual"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd node for structure: "annual"
    Then I should see the following nodes:
      | Name   |
      | node 1 |
      | node 2 |
      | node 4 |

