Feature: Manage organizations
  In order to Manage fund_requests for an organization
  As a member of an organization
  I want the organization profile page

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for organizations controller
    Given an organization exists with last_name: "Focus Organization"
    And a manager_role exists
    And a user: "manager" exists
    And a membership exists with organization: the organization, user: user "manager", role: the manager_role
    And a requestor_role exists
    And a user: "requestor" exists
    And a membership exists with organization: the organization, user: user "requestor", role: the requestor_role
    And a reviewer_role exists
    And a user: "reviewer" exists
    And a membership exists with organization: the organization, user: user "reviewer", role: the reviewer_role
    And I log in as user: "<user>"
    Given I am on the dashboard page for the organization
    Then I should <dashboard> authorized
    Given I am on the page for the organization
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the organizations page
    Then I should <show> "Focus Organization"
    And I should <dashboard> "Dashboard"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New organization"
    And I am on the new organization page
    Then I should <create> authorized
    Given I post on the organizations page
    Then I should <create> authorized
    And I am on the edit page for the organization
    Then I should <update> authorized
    Given I put on the page for the organization
    Then I should <update> authorized
    Given I delete on the page for the organization
    Then I should <destroy> authorized
    Examples:
      | user      | create  | update  | destroy | show | dashboard |
      | admin     | see     | see     | see     | see  | see       |
      | staff     | see     | see     | not see | see  | see       |
      | manager   | not see | see     | see     | see  | see       |
      | requestor | not see | see     | not see | see  | see       |
      | reviewer  | not see | not see | not see | see  | see       |
      | regular   | not see | not see | not see | see  | not see   |

  @javascript
  Scenario Outline: Register a new organization and edit
    Given a current_registration exists with name: "Cornell Club", registered: true
    And a framework exists with name: "Fund Requests"
    And a registration_criterion exists with type_of_member: "undergrads", minimal_percentage: 0, must_register: true
    And a requestor_requirement exists with fulfillable: the registration_criterion, framework: the framework
    And a requestor_role exists
    And a user: "registered" exists with first_name: "Mister", last_name: "Registered"
    And a membership exists with role: the requestor_role, user: user "registered", registration: the current_registration
    And I log in as user: "admin"
    And I am on the new organization <context>
    When I fill in "First name" with "Cornell"
    And I fill in "Last name" with "Club"
    And I fill in "Anticipated expenses" with "0.01"
    And I fill in "Anticipated income" with "0.10"
    And I fill in "Current liabilities" with "1.0"
    And I fill in "Current assets" with "10.0"
    And I follow "add tier"
    And I fill in "Maximum allocation" with "1000.0"
    And I press "Create"
    Then I should see "Organization was successfully created."
    And I should see "First name: Cornell"
    And I should see "Last name: Club"
    And I should see "Anticipated expenses: $0.01"
    And I should see "Anticipated income: $0.10"
    And I should see "Current liabilities: $1.00"
    And I should see "Current assets: $10.00"
    And I should see "Net equity: $9.09"
    And I should see the following entries in "#fund-tiers":
      | Maximum Allocation  |
      | $1,000.00           |
    When I follow "Edit"
    And I fill in "First name" with "The Cornell"
    And I fill in "Last name" with "Night Club"
    And I fill in "Anticipated expenses" with "0.02"
    And I fill in "Anticipated income" with "0.20"
    And I fill in "Current liabilities" with "2.0"
    And I fill in "Current assets" with "20.0"
    And I follow "remove tier"
    And I follow "add tier"
    And I fill in "Maximum allocation" with "2000.0"
    And I press "Update"
    Then I should see "Organization was successfully updated."
    And I should see "First name: The Cornell"
    And I should see "Last name: Night Club"
    And I should <registered> "Fund Requests"
    And I should <registered> "Registered? Yes"
    And I should see "Anticipated expenses: $0.02"
    And I should see "Anticipated income: $0.20"
    And I should see "Current liabilities: $2.00"
    And I should see "Current assets: $20.00"
    And I should see "Net equity: $18.18"
    And I should see the following entries in "#fund-tiers":
      | Maximum Allocation  |
      | $2,000.00           |
    And I follow "List memberships"
    Then I should <registered> "Mister Registered"
    Examples:
      | context                           | registered |
      | page                              | not see    |
      | page for the current_registration | see        |

  @javascript
  Scenario Outline: Restricted update rights for user
    Given an organization exists
    And an organization_profile exists with organization: the organization
    And a requestor_role exists
    And a membership exists with organization: the organization, user: user "admin", role: the requestor_role
    And I log in as user: "admin"
    And I am on the edit page for the organization
    When I fill in "First name" with "Kung"
    And I fill in "Last name" with "Fu"
    And I fill in "Anticipated expenses" with "100.0"
    And I follow "add tier"
    And I fill in "Maximum allocation" with "1000"
    And user: "admin" has admin: <admin>
    And I press "Update"
    Then I should see "Organization was successfully updated."
    And I should <see> "First name: Kung"
    And I should <see> "Last name: Fu"
    And I should <see> "$1,000.00"
    And I should see "Anticipated expenses: $100.00"
    Examples:
      | admin | see     |
      | true  | see     |
      | false | not see |

  Scenario: Search organizations
    Given there are no organizations
    And an organization exists with first_name: "Cornell", last_name: "Outing Club"
    And an organization exists with first_name: "Cornell", last_name: "Fishing Club"
    And an organization exists with last_name: "Optimist Society"
    And an organization exists with first_name: "Optimist", last_name: "Group"
    And I log in as user: "admin"
    And I am on the organizations page
    Then I should see the following organizations:
      | Name                 |
      | Cornell Fishing Club |
      | Optimist Group       |
      | Optimist Society     |
      | Cornell Outing Club  |
    When I fill in "Name" with "cornell"
    And I press "Search"
    Then I should see the following organizations:
      | Name                 |
      | Cornell Fishing Club |
      | Cornell Outing Club  |
    When I fill in "Name" with "optimist"
    And I press "Search"
    Then I should see the following organizations:
      | Name             |
      | Optimist Group   |
      | Optimist Society |

