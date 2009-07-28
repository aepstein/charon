@wip_jdm65
Feature: Manage organizations
  In order to Manage requests for an organization
  As a member of an organization
  I want the organization profile page

  Background:
    Given the following user records:
      | net_id       | email                | password | password_confirmation | admin  |
      | admin        | admin@cornell.edu    | secret   | secret                | true   |
      | allowed_user | allowed@cornell.edu  | secret   | secret                | false  |
      | global       | global@cornell.edu   | secret   | secret                | false  |
    And the following role records:
      | name    |
      | allowed |
    And the following framework records:
      | name |
      | safc |
    And the following permissions:
      | framework | role    | status  | action | perspective |
      | safc      | allowed | started | update | requestor   |
      | safc      | allowed | started | create | requestor   |
    And the following organization records:
      | last_name |
      | org1      |
    And the following bases:
      | framework |
      | safc      |
    And the following memberships:
      | user         | organization | role    |
      | allowed_user | org1         | allowed |

  Scenario: Show the heading for requests that can be made
    Given I am logged in as "allowed_user" with password "secret"
    And I am on "org1's organization profile page"
    Then I should see "Bases for you to make requests"

  Scenario: Show the heading for incomplete requests
    Given the following requests:
      | status   | organizations | basis_id |
      | started  | org1          | 1        |
    And I am logged in as "allowed_user" with password "secret"
    And I am on "org1's organization profile page"
    Then I should see "Requests you've started"

  Scenario: Show the heading for released requests
    Given the following requests:
      | status   | organizations |
      | released | org1          |
    And I am logged in as "allowed_user" with password "secret"
    And I am on "org1's organization profile page"
    Then I should see "Requests that have been released"

  Scenario: Create a new request
    Given I am logged in as "allowed_user" with password "secret"
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
      | status   | organizations | basis_id |
      | started  | org1          | 1        |
    And I am logged in as "allowed_user" with password "secret"
    And I am on "org1's organization profile page"
    Then I should see "Edit"
    When I follow "Edit"
    Then I should see "Editing Request for org1"
    When I press "Update"
    Then I should see "Request was successfully updated."

  Scenario: Global user should not be able to edit a request
    Given the following requests:
      | status   | organizations | basis_id |
      | started  | org1          | 1        |
    And I am logged in as "global" with password "secret"
    And I am on "org1's organization profile page"
    Then I should not see "Edit"

