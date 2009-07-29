@wip @request
Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests

  Background:
    Given the following safc eligible organizations:
      | last_name |
      | safc 1    |
      | safc 2    |
      | safc 3    |
    And the following gpsafc eligible organizations:
      | last_name |
      | gpsafc 1  |
      | gpsafc 2  |
    And the following structures:
      | name             |
      | safc structure   |
      | gpsafc structure |
    And the following bases:
      | name           | structure        |
      | safc basis 1   | safc structure   |
      | safc basis 2   | safc structure   |
      | gpsafc basis 1 | gpsafc structure |
    And the following requests:
      | organizations   | basis          |
      | safc 1, safc 2  | safc basis 1   |
      | safc 2          | safc basis 2   |
      | gpsafc 1        | gpsafc basis 1 |

  Scenario: Register new request
    When I am on "safc 1's new request page"
    And I select "safc basis 2" from "Basis"
    And I press "Create"
    Then I should see "Request was successfully created."

  Scenario: List requests for an organization with 1 request
    When I am on "safc 1's requests page"
    Then I should see the following requests:
      | Basis        |
      | safc basis 1 |

  Scenario: List of requests for an organization with 2 requests
    When I am on "safc 2's requests page"
    Then I should see the following requests:
      | Basis        |
      | safc basis 1 |
      | safc basis 2 |

  Scenario: List of requests for an organization with no requests
    When I am on "safc 3's requests page"
    Then I should see the following requests:
      | Basis |

  Scenario: Approve request for existing organization
    When I am on "safc 1's requests page"
    And I press "Approve"
    Then I should see "Approval was successfully created"

