Feature: Manage document_types
  In order to identify and specify standards for documents to requests
  As a paperless organization
  I want to create manage and delete document types

  Background:
    Given the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
      | regular | secret   | false |

  Scenario: Register new document_type
    Given I am logged in as "admin" with password "secret"
    And I am on the new document_type page
    When I fill in "Name" with "documentation"
    And I fill in "Max size quantity" with "10"
    And I select "megabyte" from "Max size unit"
    And I press "Create"
    Then I should see "documentation"
    And I should see "Maximum size: 10 megabytes"

  Scenario Outline: Display new item page
    Given I am logged in as "<user>" with password "secret"
    And I am on the new document_type page
    Then I should see "<see>"

    Examples:
      | user    | see                 |
      | admin   | New document type |
      | regular | Unauthorized        |

  Scenario: Delete document_type
    Given the following document_types:
      | name  |
      | name 1|
      | name 2|
      | name 3|
      | name 4|
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd document_type
    Then I should see the following document_types:
      | name  |
      | name 1|
      | name 2|
      | name 4|

