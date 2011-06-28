Feature: Manage items with document
  In order to attach documentation to requests
  As a requestor or reviewer
  I want to include documents in editions

  Background:
    Given a user: "admin" exists with admin: true
    And a structure: "focus" exists
    And a node: "focus" exists with structure: structure "focus", name: "Focus", item_amount_limit: 0
    And a basis: "focus" exists with structure: structure "focus", name: "Basis"
    And an organization: "focus" exists with last_name: "Applicant"
    And a request: "focus" exists with basis: basis "focus", organization: organization "focus"

  Scenario: Add and update edition with documentation
    Given a document_type: "price_quote" exists with name: "price quote", max_size_quantity: 3, max_size_unit: "kilobyte"
    And the document_type is amongst the document_types of node: "focus"
    And I log in as user: "admin"
    And I am on the items page for request: "focus"
    When I select "Focus" from "Add New Root Item"
    And I press "Add Root Item"
    And I attach the file "features/support/assets/small.pdf" to "Requestor price quote"
    And I press "Create"
    Then I should see "Item was successfully created."
    And I should see the following documents:
      | Type        |
      | price quote |
    When I follow "Edit"
    And I press "Update"
    Then I should see "Item was successfully updated."
    And I should see the following documents:
      | Type        |
      | price quote |
    When I follow "Edit"
    And I attach the file "features/support/assets/large.pdf" to "Requestor price quote"
    And I press "Update"
    Then I should not see "Item was successfully updated."

