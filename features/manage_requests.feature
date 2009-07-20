@wip
Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests

  Background:
    Given the following safc eligible organizations:
      | last_name      |
      | organization 1 |
      | organization 2 |
      | organization 3 |
    And the following requests:
      | organizations                  |
      | organization 1, organization 2 |
      | organization 2                 |

  Scenario: Register new request
    When I am on "organization 1's new request page"
    And I select "Basis 2" from "Basis"
    And I press "Create"
    Then I should see "Request was successfully created."

  Scenario: List requests for an organization with 1 request
    When I am on "organization 1's requests page"
    Then I should see the following requests:

  Scenario: List of requests for an organization with 2 requests
    When I am on "organization 2's requests page"
    Then I should see the following requests:

  Scenario: List of requests for an organization with no requests
    When I am on "organization 3's requests page"
    Then I should see the following requests:

  Scenario: Approve request for existing organization
    When I am on "organization 1's requests page"
    And I press "Approve"
    Then I should see "Approval was successfully created"

