Feature: Manage bases
  In order to set terms on which requests are made
  As a reviewer
  I want to manage bases

  Background:
    Given a user: "admin" exists with admin: true
    And an organization: "source" exists with last_name: "Funding Source"

  Scenario Outline: Test permissions for basis controller actions
    Given an organization: "applicant" exists with last_name: "Applicant"
    And an organization: "observer" exists with last_name: "Observer"
    And a manager_role: "manager" exists
    And a requestor_role: "requestor" exists
    And a reviewer_role: "reviewer" exists
    And a user: "source_manager" exists
    And a membership exists with user: user "source_manager", organization: organization "source", role: role "manager"
    And a user: "source_reviewer" exists
    And a membership exists with user: user "source_reviewer", organization: organization "source", role: role "reviewer"
    And a user: "applicant_requestor" exists
    And a membership exists with user: user "applicant_requestor", organization: organization "applicant", role: role "requestor"
    And a user: "observer_requestor" exists
    And a membership exists with user: user "observer_requestor", organization: organization "observer", role: role "requestor"
    And a user: "regular" exists
    And a <basis>basis: "current" exists with name: "Opportunity", organization: organization "source"
    And a request exists with basis: the basis, organization: organization "applicant"
    And I log in as user: "<user>"
    And I am on the page for the basis: "current"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the bases page for organization: "source"
    Then I should <show> "Opportunity"
    And I should <create> "New basis"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new basis page for organization: "source"
    Then I should <create> authorized
    Given I post on the bases page for organization: "source"
    Then I should <create> authorized
    And I am on the edit page for basis: "current"
    Then I should <update> authorized
    Given I put on the page for basis: "current"
    Then I should <update> authorized
    Given I delete on the page for basis: "current"
    Then I should <destroy> authorized
    Examples:
      | basis   | user               | create  | update  | destroy  | show    |
      |         | admin              | see     | see     | see      | see     |
      |         | source_manager     | see     | see     | see      | see     |
      |         | source_reviewer    | not see | not see | not see  | see     |
      |         | observer_requestor | not see | not see | not see  | see     |
      |         | regular            | not see | not see | not see  | see     |
      | past_   | admin              | see     | see     | see      | see     |
      | past_   | source_manager     | see     | see     | see      | see     |
      | past_   | source_reviewer    | not see | not see | not see  | see     |
      | past_   | observer_requestor | not see | not see | not see  | not see |
      | past_   | regular            | not see | not see | not see  | not see |
      | future_ | admin              | see     | see     | see      | see     |
      | future_ | source_manager     | see     | see     | see      | see     |
      | future_ | source_reviewer    | not see | not see | not see  | see     |
      | future_ | observer_requestor | not see | not see | not see  | not see |
      | future_ | regular            | not see | not see | not see  | not see |
@wip
  Scenario: Register new basis and update
    Given a structure exists with name: "annual"
    And a structure exists with name: "semester"
    And a framework exists with name: "safc"
    And a framework exists with name: "gpsafc"
    And I log in as user: "admin"
    And I am on the new basis page for organization: "source"
    When I fill in "Name" with "Annual SAFC"
    And I select "annual" from "Structure"
    And I select "safc" from "Framework"
    And I fill in "Contact name" with "Office of the Assemblies"
    And I fill in "Contact email" with "office@example.com"
    And I fill in "Contact web" with "http://example.com/"
    And I fill in "Open at" with "2009-10-15 12:00 pm"
    And I fill in "Submissions due at" with "2009-10-19 12:00 pm"
    And I fill in "Closed at" with "2009-10-20 12:00 pm"
    And I press "Create"
    Then I should see "Basis was successfully created."
    And I should see "Name: Annual SAFC"
    And I should see "Structure: annual"
    And I should see "Framework: safc"
    And I should see "Contact name: Office of the Assemblies"
    And I should see "Contact email: office@example.com"
    And I should see "Contact web: http://example.com/"
    Then show me the page
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
    And I fill in "Open at" with "2009-10-16 12:00 pm"
    And I fill in "Submissions due at" with "2009-10-20 12:00 pm"
    And I fill in "Closed at" with "2009-10-21 01:00 pm"
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
    And I should see "Closed at: 2009-10-21 13:00:00"

  Scenario: Delete basis
    Given a basis exists with organization: organization "source", name: "basis 4"
    And a basis exists with organization: organization "source", name: "basis 3"
    And a basis exists with organization: organization "source", name: "basis 2"
    And a basis exists with organization: organization "source", name: "basis 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd basis for organization: "source"
    Then I should see the following bases:
      | Name    |
      | basis 1 |
      | basis 2 |
      | basis 4 |

