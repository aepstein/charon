Feature: Manage registrations
  In order to determine organization eligibility and track demographics
  As an interested party
  I want to import, synchronize and delete registrations

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for registrations controller actions
    Given a user: "requestor" exists
    And a registration exists with name: "Cool Club"
    And there are no roles
    And a requestor_role exists
    And a membership exists with registration: the registration, user: user "requestor", role: the requestor_role
    And I log in as user: "<user>"
    Given I am on the page for the registration
    Then I should <show> authorized
    Given I am on the registrations page
    Then I should <show> "Cool Club"
    Examples:
      | user           | show    |
      | admin          | see     |
      | requestor      | see     |
      | regular        | not see |

  Scenario: Search organizations
    Given a registration exists with name: "Accounting Club, Cornell"
    And a registration exists with name: "Outing Club, Cornell"
    And a registration exists with name: "Ski Racing Organization"
    And I log in as user: "admin"
    And I am on the registrations page
    Then I should see the following registrations:
      | Name                     |
      | Accounting Club, Cornell |
      | Outing Club, Cornell     |
      | Ski Racing Organization  |
    When I fill in "Name" with "cornell"
    And I press "Search"
    Then I should see the following registrations:
      | Name                     |
      | Accounting Club, Cornell |
      | Outing Club, Cornell     |
    When I fill in "Name" with "ski"
    And I press "Search"
    Then I should see the following registrations:
      | Name                     |
      | Ski Racing Organization  |

  Scenario: Create organization from registration
    Given a registration exists with name: "Accounting Club, Cornell"
    And I log in as user: "admin"
    And I am on the registrations page
    When I follow "New Organization"
    And I press "Create"
    Then I should see "Organization was successfully created."
    Given I am on the organizations page
    Then I should see the following organizations:
      | Name                    |
      | Cornell Accounting Club |

