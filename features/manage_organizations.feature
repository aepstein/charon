@jdm65
Feature: Manage organizations
  In order to Manage requests for an organization
  As a member of an organization
  I want the organization profile page

  Background:
    Given the following organization record:
      | last_name |
      | org1      |

  Scenario: Show the heading for requests that can be made
    Given 1 basis record
    And I am on "org1's organization profile page"
    Then I should see "Bases for you to make requests"

  Scenario: Show the heading for incomplete requests
    Given the following requests:
      | status | organizations |
      | started  | org1 |
    And I am on "org1's organization profile page"
    Then I should see "Requests you've started"

  Scenario: Show the heading for released requests
    Given the following requests:
      | status   | organizations |
      | released | org1          |
    And I am on "org1's organization profile page"
    Then I should see "Requests that have been released"

  Scenario: Create a new request
    Given 1 basis record
    And I am on "org1's organization profile page"
    Then I should see "Bases for you to make requests"
    And I should see "Create"
    When I follow "Create"
    Then I should see "New Request for org1"
    When I select basis 1 as the basis
    And I press "Create"
    Then I should be on the items page
    And I should see "Request was successfully created."

  Scenario: Edit a request
    Given the following requests:
      | status | organizations |
      | started  | org1        |
    And I am on "org1's organization profile page"
    When I follow "Edit"
    Then I should see "Editing Request for org1"

    When I press "Update"
    Then I should see "Request was successfully updated."

  @wip
  Scenario: Display the profile page for an admin user
    Given I am logged in as admin with password admin
    And the following framework records:
      | name |
      | safc |
    And the following role records:
      | name |
      | admin |
    And the following permissions:
      | role    | perspective | action | status  | framework |
      | allowed | requestor   | update | started | safc      |

