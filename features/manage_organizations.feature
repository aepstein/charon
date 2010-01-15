Feature: Manage organizations
  In order to Manage requests for an organization
  As a member of an organization
  I want the organization profile page

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "allowed_user" exists with net_id: "allowed_user", password: "secret", admin: false
    And a user: "global" exists with net_id: "global", password: "secret", admin: false
    And a role: "allowed" exists with name: "allowed"
    And a framework: "safc" exists with name: "safc"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "create", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "update", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "destroy", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "started", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "released", action: "see", perspective: "requestor"
    And an organization: "organization_1" exists with last_name: "Org1"
    And a basis: "basis_1" exists with framework: framework "safc", name: "basis 1"
    And a basis: "basis_2" exists with framework: framework "safc", name: "basis 2"
    And a membership exists with user: user "allowed_user", organization: organization "organization_1", role: role "allowed"

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

  Scenario: Register a new organization and edit
    Given I am logged in as "admin" with password "secret"
    And I am on the new organization page
    When I fill in "First name" with "Cornell"
    And I fill in "Last name" with "Club"
    And I choose "organization_club_sport_true"
    And I press "Create"
    Then I should see "Organization was successfully created."
    And I should see "First name: Cornell"
    And I should see "Last name: Club"
    And I should see "Club sport: Yes"
    When I follow "Edit"
    And I fill in "First name" with "The Cornell"
    And I fill in "Last name" with "Night Club"
    And I choose "organization_club_sport_false"
    And I press "Update"
    Then I should see "Organization was successfully updated."
    And I should see "First name: The Cornell"
    And I should see "Last name: Night Club"
    And I should see "Club sport: No"

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

  Scenario: Create a new request and edit
    Given I am logged in as "allowed_user" with password "secret"
    And I am on "Org1's organization profile page"
    And I press "Create"
    Then I should be on the items page for organization: "organization_1"
    And I should see "Request was successfully created."
    When I follow "Show request"
    And I follow "Edit"
    Then I should see "Editing Request for Org1"
    When I press "Update"
    Then I should see "Request was successfully updated."

