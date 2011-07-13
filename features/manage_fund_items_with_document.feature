Feature: Manage fund_items with document
  In order to attach documentation to fund_requests
  As a requestor or reviewer
  I want to include documents in fund_editions

  Background:
    Given a user: "admin" exists with admin: true
    And a structure: "focus" exists
    And a node: "focus" exists with structure: structure "focus", name: "Focus", fund_item_amount_limit: 0
    And a fund_source: "focus" exists with structure: structure "focus", name: "FundSource"
    And an organization: "focus" exists with last_name: "Applicant"
    And a fund_request: "focus" exists with fund_source: fund_source "focus", organization: organization "focus"

  Scenario: Add and update fund_edition with documentation
    Given a document_type: "price_quote" exists with name: "price quote", max_size_quantity: 3, max_size_unit: "kilobyte"
    And the document_type is amongst the document_types of node: "focus"
    And I log in as user: "admin"
    And I am on the fund_items page for fund_request: "focus"
    When I select "Focus" from "Add New Root FundItem"
    And I press "Add Root FundItem"
    And I attach the file "features/support/assets/small.pdf" to "FundRequestor price quote"
    And I press "Create"
    Then I should see "FundItem was successfully created."
    And I should see the following documents:
      | Type        |
      | price quote |
    When I follow "Edit"
    And I press "Update"
    Then I should see "FundItem was successfully updated."
    And I should see the following documents:
      | Type        |
      | price quote |
    When I follow "Edit"
    And I attach the file "features/support/assets/large.pdf" to "FundRequestor price quote"
    And I press "Update"
    Then I should not see "FundItem was successfully updated."

