Feature: Manage fund_items with document
  In order to attach documentation to fund_requests
  As a requestor or reviewer
  I want to include documents in fund_editions

  Background:
    Given a user: "admin" exists with admin: true
    And a structure: "focus" exists
    And a node: "focus" exists with structure: structure "focus", name: "Focus", item_amount_limit: 0
    And a fund_source: "focus" exists with structure: structure "focus", name: "FundSource"
    And an organization: "focus" exists with last_name: "Applicant"
    And a fund_grant: "focus" exists with fund_source: fund_source "focus", organization: organization "focus"
    And a fund_request: "focus" exists with fund_grant: fund_grant "focus"

  Scenario: Add and update fund_edition with documentation
    Given a document_type: "price_quote" exists with name: "price quote", max_size_quantity: 3, max_size_unit: "kilobyte"
    And the document_type is amongst the document_types of node: "focus"
    And I log in as user: "admin"
    And I am on the fund_items page for fund_request: "focus"
    When I select "Focus" from "Add New Root Item"
    And I press "Add Root Item"
    And I attach the file "features/support/assets/small.pdf" to "Requestor price quote"
    Then I should see "There is no previously uploaded requestor price quote."
    And I should not see "The file you attach will replace the previously uploaded requestor price quote."
    When I press "Create"
    Then I should see "Fund item was successfully created."
    When I follow "Show" for the 1st fund_item for fund_request: "focus"
    Then I should see the following entries in "#documents":
      | Type        |
      | price quote |
    When I follow "Edit"
    Then I should not see "There is no previously uploaded requestor price quote."
    And I should see "The file you attach will replace the previously uploaded requestor price quote."
    When I press "Update"
    Then I should see "Fund item was successfully updated."
    When I follow "Show" for the 1st fund_item for fund_request: "focus"
    Then I should see the following entries in "#documents":
      | Type        |
      | price quote |
    When I follow "Edit"
    And I attach the file "features/support/assets/large.pdf" to "Requestor price quote"
    And I press "Update"
    Then I should not see "Fund item was successfully updated."

#TODO: Test that this works from a reviewer perspective, requestor perspective

