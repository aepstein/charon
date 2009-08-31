Feature: Manage documents
  In order to attach files to versions
  As a documentation-dependent organization
  I want to create, update, list, and delete documents

  Background:
    Given the following organizations:
      | last_name                |
      | our club                 |
      | undergraduate commission |
    And the following users:
      | net_id       | password | admin |
      | admin        | secret   | true  |
      | president    | secret   | false |
      | commissioner | secret   | false |
    And the following roles:
      | name         |
      | president    |
      | commissioner |
    And the following memberships:
      | organization             | role         | user         |
      | our club                 | president    | president    |
      | undergraduate commission | commissioner | commissioner |
    And the following document_types:
      | name              | max_size_quantity | max_size_unit |
      | venue reservation | 1                 | kilobyte      |
      | travel quote      | 1                 | kilobyte      |
      | intent letter     | 1                 | kilobyte      |
      | ad copy           | 1                 | kilobyte      |
      | lodging quote     | 1                 | kilobyte      |
    And the following structures:
      | name   |
      | budget |
    And the following nodes:
      | structure | requestable_type      | name                   | document_types                                       |
      | budget    | AdministrativeExpense | administrative expense |                                                      |
      | budget    | LocalEventExpense     | local event expense    | travel quote, venue reservation                      |
      | budget    | TravelEventExpense    | travel event expense   |                                                      |
      | budget    | DurableGoodExpense    | durable good expense   |                                                      |
      | budget    | PublicationExpense    | publication expense    |                                                      |
      | budget    | SpeakerExpense        | speaker expense        | travel quote, intent letter, ad copy, lodging quote  |
    And the following frameworks:
      | name      |
      | undergrad |
    And the following permissions:
      | framework | status  | role         | action     | perspective |
      | undergrad | started | president    | see        | requestor   |
      | undergrad | started | president    | create     | requestor   |
      | undergrad | started | president    | update     | requestor   |
      | undergrad | started | president    | destroy    | requestor   |
      | undergrad | started | commissioner | see        | reviewer    |
    And the following bases:
      | name              | organization             | structure | framework |
      | annual budget     | undergraduate commission | budget    | undergrad |
    And the following requests:
      | status   | organizations  | basis         |
      | started  | our club       | annual budget |
    And the following items:
      | request | node                   |
      | 1       | local event expense    |
      | 1       | speaker expense        |
    And the following versions:
      | item | perspective |
      | 1    | requestor   |
      | 2    | requestor   |

  Scenario Outline: Create new document
    Given I am logged in as "admin" with password "secret"
    And I am on the new document page of the 1st version
    When I select "venue reservation" from "Document type"
    And I attach the file at "features/support/assets/<file>.png" to "File"
    And I press "Create"
    Then I should <see> "Document was successfully created."
    And I should <see> "Document type: venue reservation"
    And all documents should be deleted

    Examples:
      | file  | see     |
      | small | see     |
      | large | not see |

  Scenario: Delete document
    Given the following documents:
      | version    | document_type |
      | 2          | intent letter |
      | 2          | travel quote  |
      | 2          | ad copy       |
      | 2          | lodging quote |
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd document of the 2nd version
    Then I should see the following documents:
      | Type          |
      | ad copy       |
      | intent letter |
      | travel quote  |
    And all documents should be deleted

