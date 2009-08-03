Feature: Manage organizations
  In order to Manage requests for an organization
  As a member of an organization
  I want the organization profile page

  Background:
    Given the following user records:
      | net_id       | password | admin  |
      | admin        | secret   | true   |
      | allowed_user | secret   | false  |
      | global       | secret   | false  |
    And the following role records:
      | name    |
      | allowed |
    And the following framework records:
      | name |
      | safc |
    And the following permissions:
      | framework | role    | status  | action  | perspective |
      | safc      | allowed | started | create  | requestor   |
      | safc      | allowed | started | update  | requestor   |
      | safc      | allowed | started | destroy | requestor   |
      | safc      | allowed | started | see     | requestor   |
    And the following organization records:
      | last_name |
      | org1      |
    And the following bases:
      | framework | name    |
      | safc      | basis 1 |
      | safc      | basis 2 |
    And the following memberships:
      | user         | organization | role    |
      | allowed_user | org1         | allowed |

  Scenario Outline: Show the headings for categories of requests
    Given the following requests:
      | status   | organizations | basis   |
      | started  | org1          | basis 1 |
      | released | org1          | basis 1 |
    And I am logged in as "<user>" with password "secret"
    And I am on "org1's organization profile page"
    Then I should <creatable_action> "Bases for you to make requests"
    And I should <started_action> "Requests you've started"
    And I should <released_action> "Requests that have been released"

    Examples:
      | user         | creatable_action | started_action | released_action |
      | admin        | see              | see            | see             |
      | allowed_user | see              | see            | see             |
      | global       | not see          | not see        | not see         |

  Scenario Outline: Show or hide Create, Edit, Destroy, and Show request links
    Given the following requests:
      | status   | organizations | basis   |
      | started  | org1          | basis 2 |
    And I am logged in as "<user>" with password "secret"
    And I am on "org1's organization profile page"
    Then I should <create_action>
    And I should <edit_action>
    And I should <destroy_action>
    And I should <see_action>

    Examples:
      | user         | create_action     | edit_action    | destroy_action    | see_action     |
      | admin        | see "basis 1"     | see "Edit"     | see "Destroy"     | see "Show"     |
      | allowed_user | see "basis 1"     | see "Edit"     | see "Destroy"     | see "Show"     |
      | global       | not see "basis 1" | not see "Edit" | not see "Destroy" | not see "Show" |

  Scenario: Create a new request
    Given I am logged in as "allowed_user" with password "secret"
    And I am on "org1's organization profile page"
    And I press "Create"
    Then I should be on the items page
    And I should see "Request was successfully created."

  Scenario: Edit a request
    Given the following requests:
      | status   | organizations | basis   |
      | started  | org1          | basis 1 |
    And I am logged in as "allowed_user" with password "secret"
    And I am on "org1's organization profile page"
    When I follow "Edit"
    Then I should see "Editing Request for org1"
    When I press "Update"
    Then I should see "Request was successfully updated."

