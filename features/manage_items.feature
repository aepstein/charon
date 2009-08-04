Feature: Manage items
  In order to Manage structure of items using request item
  As an applicant
  I want request item form

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
    And the following structures:
      | name               |
      | budget             |
    And the following nodes:
      | structure | requestable_type      | name                   |
      | budget    | AdministrativeExpense | administrative expense |
      | budget    | LocalEventExpense     | local event expense    |
      | budget    | TravelEventExpense    | travel event expense   |
      | budget    | DurableGoodExpense    | durable good expense   |
      | budget    | PublicationExpense    | publication expense    |
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

  Scenario: Create new item and version
    Given I am logged in as "president" with password "secret"
    When I am on "our club's requests page"
    And I follow "Show Items"
    And I select "administrative expense" from "Add New Item"
    And I press "Add"
    Then I should see "Item was successfully created."

  Scenario Outline: Create new item only if admin or may update request
    Given I am logged in as "<user>" with password "secret"
    When I am on the requests page
    And I follow "Show Items"
    Then I should <should>

    Examples:
      | user         | should                 |
      | admin        | see "Add New Item"     |
      | president    | see "Add New Item"     |
      | commissioner | not see "Add New Item" |

  Scenario: Delete an item
    Given the following items:
      | request    | node                   |
      | 1          | administrative expense |
      | 1          | durable good expense   |
      | 1          | publication expense    |
      | 1          | travel event expense   |
    And I am logged in as "president" with password "secret"
    When I delete the 5th item of the 1st request
    Then I should see "Item was successfully destroyed."
    And I should see the following items:
      | Perspective            |
      | administrative expense |
      | requestor              |
      | durable good expense   |
      | requestor              |
      | travel event expense   |
      | requestor              |

  Scenario: Show correct add version links
    Given the following items:
      | request | node                   |
      | 1       | administrative expense |
      | 1       | durable good expense   |
      | 1       | publication expense    |
    And the following versions:
      | item | perspective |
      | 1    | requestor   |
      | 1    | reviewer    |
      | 2    | requestor   |
    And I am logged in as "admin" with password "secret"
    When I am on "our club's requests page"
    And I follow "Show Items"
    Then I should see the following items:
      | Perspective            | Amount    |
      | administrative expense | Destroy   |
      | requestor              | $0.00     |
      | reviewer               | $0.00     |
      | durable good expense   | Destroy   |
      | requestor              | $0.00     |
      | reviewer               | None yet. |
      | publication expense    | Destroy   |
      | requestor              | None yet. |

