@current
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
      | framework | role    | status   | action  | perspective |
      | safc      | allowed | started  | create  | requestor   |
      | safc      | allowed | started  | update  | requestor   |
      | safc      | allowed | started  | destroy | requestor   |
      | safc      | allowed | started  | see     | requestor   |
      | safc      | allowed | released | see     | requestor   |
    And the following organization records:
      | last_name |
      | Org1      |
    And the following bases:
      | framework | name    |
      | safc      | basis 1 |
      | safc      | basis 2 |
    And the following memberships:
      | user         | organization | role    |
      | allowed_user | Org1         | allowed |

  Scenario Outline: Show the headings for categories of requests
    Given the following requests:
      | status   | organizations | basis   |
      | started  | Org1          | basis 1 |
      | released | Org1          | basis 1 |
    And I am logged in as "<user>" with password "secret"
    And I am on "Org1's organization profile page"
    Then I should <creatable_action> "Bases for you to make requests"
    And I should <started_action> "Requests you've started"
    And I should <released_action> "Requests that have been released"

    Examples:
      | user         | creatable_action | started_action | released_action |
      | admin        | see              | see            | see             |
      | allowed_user | see              | see            | see             |
      | global       | not see          | not see        | not see         |

  Scenario: Register a new organization
    Given I am logged in as "admin" with password "secret"
    And I am on the new organization page
    When I fill in "First name" with "Cornell"
    And I fill in "Last name" with "Club"
    And I check "Club sport"
    And I press "Create"
    Then I should see "First name: Cornell"
    And I should see "Last name: Club"
    And I should see "Club sport: Yes"

  Scenario: Search organizations
    Given there are no organizations
    And the following organizations:
      | first_name | last_name        |
      | Cornell    | Outing Club      |
      | Cornell    | Fishing Club     |
      |            | Optimist Society |
      | Optimist   | Group            |
    And I am logged in as "admin" with password "secret"
    And I am on the organizations page
    Then I should see the following organizations:
      | Name                 |
      | Cornell Fishing Club |
      | Optimist Group       |
      | Optimist Society     |
      | Cornell Outing Club  |
    When I fill in "Search" with "cornell"
    And I press "Go"
    Then I should see the following organizations:
      | Name                 |
      | Cornell Fishing Club |
      | Cornell Outing Club  |
    When I fill in "Search" with "optimist"
    And I press "Go"
    Then I should see the following organizations:
      | Name             |
      | Optimist Group   |
      | Optimist Society |

  Scenario Outline: Show or hide Create, Edit, Destroy, and Show request links
    Given the following requests:
      | status   | organizations | basis   |
      | started  | Org1          | basis 2 |
    And I am logged in as "<user>" with password "secret"
    And I am on "Org1's organization profile page"
    Then I should <create_action>
    And I should <destroy_action>
    And I should <see_action>

    Examples:
      | user         | create_action     | destroy_action    | see_action     |
      | admin        | see "basis 1"     | see "Destroy"     | see "Show"     |
      | allowed_user | see "basis 1"     | see "Destroy"     | see "Show"     |
      | global       | not see "basis 1" | not see "Destroy" | not see "Show" |

  Scenario: Create a new request
    Given I am logged in as "allowed_user" with password "secret"
    And I am on "Org1's organization profile page"
    And I press "Create"
    Then I should be on the items page
    And I should see "Request was successfully created."
  @wip
  Scenario: Edit a request
    Given the following requests:
      | status   | organizations | basis   |
      | started  | Org1          | basis 1 |
    And I am logged in as "allowed_user" with password "secret"
    And I am on "Org1's organization profile page"
    When I follow "Edit"
    Then I should see "Editing Request for Org1"
    When I press "Update"
    Then I should see "Request was successfully updated."

