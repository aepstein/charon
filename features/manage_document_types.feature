Feature: Manage document_types
  In order to identify and specify standards for documents to fund_requests
  As a paperless organization
  I want to create manage and delete document types

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for document types controller actions
    Given an document_type: "basic" exists
    And I log in as user: "<user>"
    And I am on the page for document_type: "basic"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the document_types page
    Then I should <show> authorized
    And I should <create> "New document type"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new document_type page
    Then I should <create> authorized
    Given I post on the document_types page
    Then I should <create> authorized
    And I am on the edit page for document_type: "basic"
    Then I should <update> authorized
    Given I put on the page for document_type: "basic"
    Then I should <update> authorized
    Given I delete on the page for document_type: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | staff   | see     | see     | not see | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Register new document_type and update
    Given I log in as user: "admin"
    And I am on the new document_type page
    When I fill in "Name" with "documentation"
    And I fill in "Max size quantity" with "10"
    And I select "megabyte" from "Max size unit"
    And I press "Create"
    Then I should see "Document type was successfully created."
    And I should see "Name: documentation"
    And I should see "Maximum size: 10 megabytes"
    When I follow "Edit"
    And I fill in "Name" with "price quote"
    And I fill in "Max size quantity" with "5"
    And I select "kilobyte" from "Max size unit"
    And I press "Update"
    Then I should see "Document type was successfully updated."
    And I should see "Name: price quote"
    And I should see "Maximum size: 5 kilobytes"

  Scenario: Delete document_type
    Given a document_type exists with name: "document type 4"
    And a document_type exists with name: "document type 3"
    And a document_type exists with name: "document type 2"
    And a document_type exists with name: "document type 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd document_type
    Then I should see "Document type was successfully destroyed."
    And I should see the following document_types:
      | Name           |
      | document type 1|
      | document type 2|
      | document type 4|

