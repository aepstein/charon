Feature: Manage organizations
  In order to Manage requests for an organization
  As a member of an organization
  I want the organization profile page

  Background:
    Given the following safc eligible organizations:
      | last_name      |
      | organization 1 |

  Scenario: Show the heading for requests that can be made
    Given 1 basis record
    And I am on "organization 1's organization profile page"
    Then I should see "Bases for you to make requests"

  Scenario: Show the heading for incomplete requests
    Given the following requests:
      | status | organizations |
      | draft  | organization 1|
    And I am on "organization 1's organization profile page"
    Then I should see "Requests you've started"

  Scenario: Show the heading for released requests
    Given the following requests:
      | status   | organizations |
      | released | organization 1|
    And I am on "organization 1's organization profile page"
    Then I should see "Requests that have been released"

  Scenario: Create a new request
    Given 1 basis record
    And I am on "organization 1's organization profile page"
    Then I should see "Bases for you to make requests"
    And I should see "Create"
    When I follow "Create"
    Then I should see "New Request for organization 1"
    When I select basis 1 as the basis
    And I press "Create"
    Then I should be on the items page

  Scenario: Edit a request
    Given the following requests:
      | status | organizations |
      | draft  | organization 1|
    And I am on "organization 1's organization profile page"
    When I follow "Edit"
    Then I should see "Editing Request for organization 1"

    When I press "Update"
    Then I should see "Request was successfully updated."

