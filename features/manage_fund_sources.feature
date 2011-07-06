Feature: Manage fund_sources
  In order to set terms on which fund_requests are made
  As a reviewer
  I want to manage fund_sources

  Background:
    Given a user: "admin" exists with admin: true
    And an organization: "source" exists with last_name: "Funding Source"

  Scenario Outline: Test permissions for fund_source controller actions
    Given an organization: "applicant" exists with last_name: "Applicant"
    And an organization: "observer" exists with last_name: "Observer"
    And a manager_role: "manager" exists
    And a fund_requestor_role: "fund_requestor" exists
    And a reviewer_role: "reviewer" exists
    And a user: "source_manager" exists
    And a membership exists with user: user "source_manager", organization: organization "source", role: role "manager"
    And a user: "source_reviewer" exists
    And a membership exists with user: user "source_reviewer", organization: organization "source", role: role "reviewer"
    And a user: "applicant_fund_requestor" exists
    And a membership exists with user: user "applicant_fund_requestor", organization: organization "applicant", role: role "fund_requestor"
    And a user: "observer_fund_requestor" exists
    And a membership exists with user: user "observer_fund_requestor", organization: organization "observer", role: role "fund_requestor"
    And a user: "regular" exists
    And a <fund_source>fund_source: "current" exists with name: "Opportunity", organization: organization "source"
    And a fund_request exists with fund_source: the fund_source, organization: organization "applicant"
    And I log in as user: "<user>"
    And I am on the page for the fund_source: "current"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the fund_sources page for organization: "source"
    Then I should <show> "Opportunity"
    And I should <create> "New fund_source"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new fund_source page for organization: "source"
    Then I should <create> authorized
    Given I post on the fund_sources page for organization: "source"
    Then I should <create> authorized
    And I am on the edit page for fund_source: "current"
    Then I should <update> authorized
    Given I put on the page for fund_source: "current"
    Then I should <update> authorized
    Given I delete on the page for fund_source: "current"
    Then I should <destroy> authorized
    Examples:
      | fund_source   | user               | create  | update  | destroy  | show    |
      |         | admin              | see     | see     | see      | see     |
      |         | source_manager     | see     | see     | see      | see     |
      |         | source_reviewer    | not see | not see | not see  | see     |
      |         | observer_fund_requestor | not see | not see | not see  | see     |
      |         | regular            | not see | not see | not see  | see     |
      | past_   | admin              | see     | see     | see      | see     |
      | past_   | source_manager     | see     | see     | see      | see     |
      | past_   | source_reviewer    | not see | not see | not see  | see     |
      | past_   | observer_fund_requestor | not see | not see | not see  | not see |
      | past_   | regular            | not see | not see | not see  | not see |
      | future_ | admin              | see     | see     | see      | see     |
      | future_ | source_manager     | see     | see     | see      | see     |
      | future_ | source_reviewer    | not see | not see | not see  | see     |
      | future_ | observer_fund_requestor | not see | not see | not see  | not see |
      | future_ | regular            | not see | not see | not see  | not see |

  Scenario: Register new fund_source and update
    Given a structure exists with name: "annual"
    And a structure exists with name: "semester"
    And a framework exists with name: "safc"
    And a framework exists with name: "gpsafc"
    And I log in as user: "admin"
    And I am on the new fund_source page for organization: "source"
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
    Then I should see "FundSource was successfully created."
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
    And I fill in "Contact name" with "Another Office"
    And I fill in "Contact email" with "office@other.com"
    And I fill in "Contact web" with "http://example.org/"
    And I fill in "Open at" with "2009-10-16 12:00 pm"
    And I fill in "Submissions due at" with "2009-10-20 12:00 pm"
    And I fill in "Closed at" with "2009-10-21 01:00 pm"
    And I press "Update"
    Then I should see "FundSource was successfully updated."
    And I should see "Name: Semester GPSAFC"
    And I should see "Contact name: Another Office"
    And I should see "Contact email: office@other.com"
    And I should see "Contact web: http://example.org/"
    And I should see "Open at: 2009-10-16 12:00:00"
    And I should see "Submissions due at: 2009-10-20 12:00:00"
    And I should see "Closed at: 2009-10-21 13:00:00"

  Scenario: Delete fund_source
    Given a fund_source exists with organization: organization "source", name: "fund_source 4"
    And a fund_source exists with organization: organization "source", name: "fund_source 3"
    And a fund_source exists with organization: organization "source", name: "fund_source 2"
    And a fund_source exists with organization: organization "source", name: "fund_source 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd fund_source for organization: "source"
    Then I should see the following fund_sources:
      | Name    |
      | fund_source 1 |
      | fund_source 2 |
      | fund_source 4 |

