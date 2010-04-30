Feature: Manage bases
  In order to set terms on which requests are made
  As a reviewer
  I want to manage bases

  Background:
    Given a structure: "test" exists with name: "test"
    And a framework: "safc" exists with name: "safc"
    And a framework: "gpsafc" exists with name: "gpsafc"
    And a structure: "annual" exists with name: "annual"
    And a structure: "semester" exists with name: "semester"
    And an organization: "organization_1" exists with last_name: "organization 1"
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario Outline: Test permissions for basis controller actions
    Given a basis: "basic" exists with organization: organization "organization_1"
    And I am logged in as "<user>" with password "secret"
    And I am on the new basis page for organization: "organization_1"
    Then I should <create>
    Given I post on the bases page for organization: "organization_1"
    Then I should <create>
    And I am on the edit page for basis: "basic"
    Then I should <update>
    Given I put on the page for basis: "basic"
    Then I should <update>
    Given I am on the page for basis: "basic"
    Then I should <show>
    Given I delete on the page for basis: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new basis and update
    Given I am logged in as "admin" with password "secret"
    And I am on the new basis page for organization: "organization_1"
    When I fill in "Name" with "Annual SAFC"
    And I select "annual" from "Structure"
    And I select "safc" from "Framework"
    And I fill in "Contact name" with "Office of the Assemblies"
    And I fill in "Contact email" with "office@example.com"
    And I fill in "Contact web" with "http://example.com/"
    And I fill in "Open at" with "2009-10-15 12:00:00"
    And I fill in "Submissions due at" with "2009-10-19 12:00:00"
    And I fill in "Closed at" with "2009-10-20 12:00:00"
    And I press "Create"
    Then I should see "Basis was successfully created."
    And I should see "Name: Annual SAFC"
    And I should see "Structure: annual"
    And I should see "Framework: safc"
    And I should see "Contact name: Office of the Assemblies"
    And I should see "Contact email: office@example.com"
    And I should see "Contact web: http://example.com/"
    And I should see "Open at: 2009-10-15 12:00:00"
    And I should see "Submissions due at: 2009-10-19 12:00:00"
    And I should see "Closed at: 2009-10-20 12:00:00"
    When I follow "Edit"
    And I fill in "Name" with "Semester GPSAFC"
    And I select "semester" from "Structure"
    And I select "gpsafc" from "Framework"
    And I fill in "Contact name" with "Another Office"
    And I fill in "Contact email" with "office@other.com"
    And I fill in "Contact web" with "http://example.org/"
    And I fill in "Open at" with "2009-10-16 12:00:00"
    And I fill in "Submissions due at" with "2009-10-20 12:00:00"
    And I fill in "Closed at" with "2009-10-21 12:00:00"
    And I press "Update"
    Then I should see "Basis was successfully updated."
    And I should see "Name: Semester GPSAFC"
    And I should see "Structure: semester"
    And I should see "Framework: gpsafc"
    And I should see "Contact name: Another Office"
    And I should see "Contact email: office@other.com"
    And I should see "Contact web: http://example.org/"
    And I should see "Open at: 2009-10-16 12:00:00"
    And I should see "Submissions due at: 2009-10-20 12:00:00"
    And I should see "Closed at: 2009-10-21 12:00:00"

  Scenario: Delete basis
    Given a basis exists with organization: organization "organization_1", name: "basis 4"
    And a basis exists with organization: organization "organization_1", name: "basis 3"
    And a basis exists with organization: organization "organization_1", name: "basis 2"
    And a basis exists with organization: organization "organization_1", name: "basis 1"
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd basis for organization: "organization_1"
    Then I should see the following bases:
      | Name    |
      | basis 1 |
      | basis 2 |
      | basis 4 |

