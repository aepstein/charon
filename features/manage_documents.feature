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
      | name                       | max_size_quantity | max_size_unit |
      | proof of travel distance   | 2                 | megabyte      |
      | proof of venue reservation | 1                 | kilobyte      |
    And the following structures:
      | name   |
      | budget |
    And the following nodes:
      | structure | requestable_type      | name                   | document_types                                     |
      | budget    | AdministrativeExpense | administrative expense |                                                      |
      | budget    | LocalEventExpense     | local event expense    | proof of travel distance, proof of venue reservation |
      | budget    | TravelEventExpense    | travel event expense   |                                                      |
      | budget    | DurableGoodExpense    | durable good expense   |                                                      |
      | budget    | PublicationExpense    | publication expense    |                                                      |
      | budget    | SpeakerExpense        | speaker expense        |                                                      |
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
    And the following versions:
      | item | perspective |
      | 1    | requestor   |

  Scenario: Create new document
    Given I am logged in as "admin" with password "secret"
    And I am on the new document page of the 1st version
    When I select "proof of venue reservation" from "Document type"
    And I attach the file at "features/support/assets/small.png" to "File"
    And I press "Create"
    Then I should see "Document was successfully created."
    And I should see "Document type: proof of venue reservation"

  @wip
  Scenario: Delete document
    Given the following documents:
      |document_type|
      |documentation|
      |documentation|
      |documentation|
      |documentation|
    When I delete the 3rd document
    Then I should see the following documents:
      |document_type|
      |document_type 1|
      |document_type 2|
      |document_type 4|

