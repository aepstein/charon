Feature: Manage document_types
  In order to identify and specify standards for documents to requests
  As a paperless organization
  I want to create manage and delete document types

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario Outline: Test permissions for document types controller actions
    Given an document_type: "basic" exists
    And I am logged in as "<user>" with password "secret"
    And I am on the new document_type page
    Then I should <create>
    Given I post on the document_types page
    Then I should <create>
    And I am on the edit page for document_type: "basic"
    Then I should <update>
    Given I put on the page for document_type: "basic"
    Then I should <update>
    Given I am on the page for document_type: "basic"
    Then I should <show>
    Given I delete on the page for document_type: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new document_type and update
    Given I am logged in as "admin" with password "secret"
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
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd document_type
    Then I should see the following document_types:
      | Name           |
      | document type 1|
      | document type 2|
      | document type 4|

