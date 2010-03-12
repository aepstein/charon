Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests

  Background:
    Given an organization: "safc1" exists with last_name: "safc 1"
    And an organization: "safc2" exists with last_name: "safc 2"
    And an organization: "safc3" exists with last_name: "safc 3"
    And an organization: "gpsafc1" exists with last_name: "gpsafc 1"
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "requestor" exists with net_id: "requestor", password: "secret", admin: false
    And a user: "global" exists with net_id: "global", password: "secret", admin: false
    And a role: "allowed" exists with name: "allowed"
    And a framework: "safc" exists with name: "safc"
    And a framework: "gpsafc" exists with name: "gpsafc"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "create", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "update", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "destroy", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "completed", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "approve", perspective: "requestor"
    And a membership exists with user: user "requestor", organization: organization "safc1", role: role "allowed"
    And a membership exists with user: user "requestor", organization: organization "safc2", role: role "allowed"
    And a membership exists with user: user "requestor", organization: organization "safc3", role: role "allowed"
    And a structure: "safc" exists with name: "safc structure"
    And a structure: "gpsafc" exists with name: "gpsafc structure"
    And a basis: "safc1" exists with name: "safc basis 1", structure: structure "safc", framework: framework "safc"
    And a basis: "safc2" exists with name: "safc basis 2", structure: structure "safc", framework: framework "safc"
    And a basis: "gpsafc1" exists with name: "gpsafc basis 1", structure: structure "gpsafc", framework: framework "gpsafc"
    And a request: "coorg" exists with basis: basis "safc1"
    And organization: "safc1" is alone amongst the organizations of the request
    And organization: "safc2" is amongst the organizations of the request
    And a request: "single" exists with basis: basis "safc2"
    And organization: "safc2" is alone amongst the organizations of the request
    And a request: "gpsafc" exists with basis: basis "gpsafc1"
    And organization: "gpsafc1" is alone amongst the organizations of the request

  Scenario: Register new request
    Given I am on the profile page for organization: "safc1"
    And I am logged in as "requestor" with password "secret"
    When I press "Create"
    Then I should see "Request was successfully created."

  Scenario: List requests for an organization with 1 request
    Given I am logged in as "requestor" with password "secret"
    And I am on the requests page for organization: "safc1"
    Then I should see the following requests:
      | Basis        |
      | safc basis 1 |

  Scenario: List requests for an organization with 2 requests
    Given I am logged in as "requestor" with password "secret"
    And I am on the requests page for organization: "safc2"
    Then I should see the following requests:
      | Basis        |
      | safc basis 1 |
      | safc basis 2 |

  Scenario: List requests for an organization with no requests
    Given I am logged in as "requestor" with password "secret"
    And I am on the requests page for the organization: "safc3"
    Then I should see the following requests:
      | Organizations |

  Scenario: List requests for a basis
    Given a basis: "fall" exists with name: "fall semester"
    And a basis: "spring" exists with name: "spring semester"
    And an organization: "org1" exists with last_name: "Abc Club"
    And an organization: "org2" exists with last_name: "14 Society"
    And an organization: "org3" exists with last_name: "Zxy Club"
    And a request exists with basis: basis "fall", status: "accepted"
    And organization: "org3" is alone amongst the organizations of the request
    And a request exists with basis: basis "spring", status: "accepted"
    And organization: "org1" is alone amongst the organizations of the request
    And a request exists with basis: basis "fall", status: "reviewed"
    And organization: "org1" is alone amongst the organizations of the request
    And a request exists with basis: basis "fall", status: "accepted"
    And organization: "org2" is alone amongst the organizations of the request
    And I am logged in as "admin" with password "secret"
    And I am on the requests page for basis: "fall"
    Then I should see the following requests:
      | Organizations |
      | 14 Society    |
      | Abc Club      |
      | Zxy Club      |
    When I fill in "Search" with "club"
    And I press "Go"
    Then I should see the following requests:
      | Organizations |
      | Abc Club      |
      | Zxy Club      |
    When I select "accepted" from "Status"
    And I press "Go"
    Then I should see the following requests:
      | Organizations |
      | 14 Society    |
      | Zxy Club      |

