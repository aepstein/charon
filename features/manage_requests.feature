Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests

  Background:
    Given the following organizations:
      | last_name |
      | safc 1    |
      | safc 2    |
      | safc 3    |
      | gpsafc 1  |
    And the following user records:
      | net_id    | password | admin  |
      | admin     | secret   | true   |
      | requestor | secret   | false  |
      | global    | secret   | false  |
    And the following role records:
      | name    |
      | allowed |
    And the following framework records:
      | name   |
      | safc   |
      | gpsafc |
    And the following permissions:
      | framework | role    | status    | action  | perspective |
      | safc      | allowed | started   | create  | requestor   |
      | safc      | allowed | started   | update  | requestor   |
      | safc      | allowed | started   | destroy | requestor   |
      | safc      | allowed | started   | see     | requestor   |
      | safc      | allowed | completed | see     | requestor   |
      | safc      | allowed | started   | approve | requestor   |
    And the following memberships:
      | user      | organization | role    |
      | requestor | safc 1       | allowed |
      | requestor | safc 2       | allowed |
      | requestor | safc 3       | allowed |
    And the following structures:
      | name             |
      | safc structure   |
      | gpsafc structure |
    And the following bases:
      | name           | structure        | framework |
      | safc basis 1   | safc structure   | safc      |
      | safc basis 2   | safc structure   | safc      |
      | gpsafc basis 1 | gpsafc structure | gpsafc    |
    And the following requests:
      | organizations   | basis          |
      | safc 1, safc 2  | safc basis 1   |
      | safc 2          | safc basis 2   |
      | gpsafc 1        | gpsafc basis 1 |
    And I am logged in as "requestor" with password "secret"

  Scenario: Register new request
    Given I am on "safc 1's organization profile page"
    When I press "Create"
    Then I should see "Request was successfully created."

  Scenario: List requests for an organization with 1 request
    When I am on "safc 1's requests page"
    Then I should see the following requests:
      | Basis        |
      | safc basis 1 |

  Scenario: List requests for an organization with 2 requests
    When I am on "safc 2's requests page"
    Then I should see the following requests:
      | Basis        |
      | safc basis 1 |
      | safc basis 2 |

  Scenario: List requests for an organization with no requests
    When I am on "safc 3's requests page"
    Then I should see the following requests:
      | Basis |
  @current
  Scenario: Approve request for existing organization
    Given the following nodes:
      | structure      | requestable_type      | name                   |
      | safc structure | AdministrativeExpense | administrative expense |
      | safc structure | LocalEventExpense     | local event expense    |
      | safc structure | TravelEventExpense    | travel event expense   |
      | safc structure | DurableGoodExpense    | durable good expense   |
      | safc structure | PublicationExpense    | publication expense    |
    And the following items:
      | request | node                   |
      | 1       | administrative expense |
      | 1       | durable good expense   |
      | 1       | publication expense    |
    And the following versions:
      | item | perspective |
      | 1    | requestor   |
      | 1    | reviewer    |
      | 2    | requestor   |
    And I am on "safc 1's requests page"
    When I follow "Approve"
    Then I should see the following items:
      | Perspective            |
      | administrative expense |
      | requestor              |
      | durable good expense   |
      | requestor              |
      | publication expense    |
    When I press "Confirm Approval"
    Then I should see "Approval was successfully created"

