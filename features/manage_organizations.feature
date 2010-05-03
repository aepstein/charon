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
    And a permission exists with framework: framework "safc", role: role "allowed", status: "completed", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "submitted", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "accepted", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "reviewed", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "certified", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", role: role "allowed", status: "released", action: "see", perspective: "requestor"
    And an organization: "organization_1" exists with last_name: "Org1"
    And a basis: "basis_1" exists with framework: framework "safc", name: "basis 1"
    And a membership exists with user: user "allowed_user", organization: organization "organization_1", role: role "allowed"

  Scenario Outline: Show unfulfilled requirements for organization in profile
    Given a role exists
    And a framework exists with name: "SAFC"
    And a permission: "first" exists with role: the role, framework: the framework, action: "create"
    And a permission: "second" exists with role: the role, framework: the framework, action: "update"
    And a permission: "third" exists with role: the role, framework: the framework, action: "review"
    And a registration_criterion exists with must_register: true, minimal_percentage: 10, type_of_member: "staff"
    And a requirement exists with permission: permission "first", fulfillable: the registration_criterion
    And a requirement exists with permission: permission "second", fulfillable: the registration_criterion
    And an organization: "qualified" exists
    And a registration exists with organization: organization "qualified", number_of_staff: 10, registered: true
    And an organization: "unqualified" exists
    And a membership exists with active: true, organization: organization "qualified", role: the role
    And a membership exists with active: true, organization: organization "unqualified", role: the role
    And I am logged in as "admin" with password "secret"
    And I am on the profile page for organization: "<organization>"
    Then I should <see> "The organization has unfulfilled requirements that may limit what it is able to do:"
    And I should <see> "The organization must be registered and have at least 10% staff as members in the registration in order to create, update SAFC requests. Click here to update the registration."
    Examples:
      | organization | see     |
      | qualified    | not see |
      | unqualified  | see     |

  Scenario Outline: Test permissions for agreements controller actions
    Given I am logged in as "<user>" with password "secret"
    And I am on the new organization page
    Then I should <create>
    Given I post on the organizations page
    Then I should <create>
    And I am on the edit page for organization: "organization_1"
    Then I should <update>
    Given I put on the page for organization: "organization_1"
    Then I should <update>
    Given I am on the page for organization: "organization_1"
    Then I should <show>
    Given I delete on the page for organization: "organization_1"
    Then I should <destroy>
    Examples:
      | user           | create                 | update                 | destroy                | show                   |
      | admin          | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | allowed_user   | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |
      | global         | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario Outline: Show headings for requests appropriately based on requests status
    Given a request exists with basis: basis "basis_1", status: "<status>"
    And organization: "organization_1" is amongst the organizations of the request
    And I am logged in as "<user>" with password "secret"
    And I am on the profile page for organization: "organization_1"
    Then I should <creatable> "Bases for you to make new requests"
    And I should <started> "Requests you have started"
    And I should <completed> "Requests you have completed"
    And I should <submitted> "Requests you have submitted"
    And I should <accepted> "Requests that have been accepted for review"
    And I should <released> "Requests that have been released"
    And I should see "basis 1"
    Examples:
      | user         | status    | creatable | started | completed | submitted | accepted | released |
      | admin        | started   | not see   | see     | not see   | not see   | not see  | not see  |
      | admin        | completed | not see   | not see | see       | not see   | not see  | not see  |
      | allowed_user | started   | not see   | see     | not see   | not see   | not see  | not see  |
      | allowed_user | completed | not see   | not see | see       | not see   | not see  | not see  |
      | allowed_user | submitted | see       | not see | not see   | see       | not see  | not see  |
      | allowed_user | accepted  | see       | not see | not see   | not see   | see      | not see  |
      | allowed_user | reviewed  | see       | not see | not see   | not see   | see      | not see  |
      | allowed_user | certified | see       | not see | not see   | not see   | see      | not see  |
      | allowed_user | released  | see       | not see | not see   | not see   | not see  | see      |

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
    And an organization exists with first_name: "Cornell", last_name: "Outing Club"
    And an organization exists with first_name: "Cornell", last_name: "Fishing Club"
    And an organization exists with last_name: "Optimist Society"
    And an organization exists with first_name: "Optimist", last_name: "Group"
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
    Given a basis: "basis_2" exists with framework: framework "safc", name: "basis 2"
    And a request exists with basis: basis "basis_2"
    And organization: "organization_1" is amongst the organizations of the request
    And I am logged in as "<user>" with password "secret"
    And I am on the profile page for organization: "organization_1"
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
    And I am on the profile page for organization: "organization_1"
    And I press "Create"
    Then I should see "Request was successfully created."
    When I follow "Show request"
    And I follow "Edit"
    Then I should see "Editing request for Org1"
    When I press "Update"
    Then I should see "Request was successfully updated."

