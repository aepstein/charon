Feature: Manage registrations
  In order to determine organization eligibility and track demographics
  As an interested party
  I want to import, synchronize and delete registrations

  Background:
    Given the following users:
      | net_id | password | admin |
      | admin  | secret   | true  |

  Scenario: Search organizations
    Given the following registrations:
      | name                     |
      | Accounting Club, Cornell |
      | Outing Club, Cornell     |
      | Ski Racing Organization  |
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
  @current
  Scenario: Create organization from registration
    Given the following registrations:
      | name                     |
      | Accounting Club, Cornell |
    And I am logged in as "admin" with password "secret"
    And I am on the registrations page
    When I follow "New Organization"
    And I press "Create"
    Then I should see "Organization was successfully created."
    Given I am on the organizations page
    Then I should see the following organizations:
      | Name                    |
      | Cornell Accounting Club |

