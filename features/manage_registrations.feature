Feature: Manage registrations
  In order to determine organization eligibility and track demographics
  As an interested party
  I want to import, synchronize and delete registrations

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario Outline: Test permissions for registrations controller actions
    Given a user: "member" exists with net_id: "member", password: "secret", admin: false
    And a registration exists
    And a membership exists with registration: the registration, user: user "member"
    And I am logged in as "<user>" with password "secret"
#    And I am on the new registration page
#    Then I should <create>
#    Given I post on the registrations page
#    Then I should <create>
#    And I am on the edit page for the registration
#    Then I should <update>
#    Given I put on the page for the registration
#    Then I should <update>
    Given I am on the page for the registration
    Then I should <show>
#    Given I delete on the page for the registration
#    Then I should <destroy>
    Examples:
      | user           | create                 | update                 | destroy                | show                   |
      | admin          | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | member         | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |
      | regular        | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |

  Scenario: Search organizations
    Given a registration exists with name: "Accounting Club, Cornell"
    And a registration exists with name: "Outing Club, Cornell"
    And a registration exists with name: "Ski Racing Organization"
    And I am logged in as "admin" with password "secret"
    And I am on the registrations page
    Then I should see the following registrations:
      | Name                     |
      | Accounting Club, Cornell |
      | Outing Club, Cornell     |
      | Ski Racing Organization  |
    When I fill in "Search" with "cornell"
    And I press "Go"
    Then I should see the following registrations:
      | Name                     |
      | Accounting Club, Cornell |
      | Outing Club, Cornell     |
    When I fill in "Search" with "ski"
    And I press "Go"
    Then I should see the following registrations:
      | Name                     |
      | Ski Racing Organization  |

  Scenario: Create organization from registration
    Given a registration exists with name: "Accounting Club, Cornell"
    And I am logged in as "admin" with password "secret"
    And I am on the registrations page
    When I follow "New Organization"
    And I press "Create"
    Then I should see "Organization was successfully created."
    Given I am on the organizations page
    Then I should see the following organizations:
      | Name                    |
      | Cornell Accounting Club |

