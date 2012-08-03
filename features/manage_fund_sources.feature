Feature: Manage fund_sources
  In order to set terms on which fund_requests are made
  As a reviewer
  I want to manage fund_sources

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And an organization: "source" exists with last_name: "Funding Source"

  Scenario Outline: Test permissions for fund_source controller actions
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
    And a <time>fund_source: "current" exists with name: "Opportunity", organization: organization "source"
    And a fund_grant exists with fund_source: the fund_source, organization: organization "applicant"
    And a fund_request exists with fund_grant: the fund_grant
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
      | time      | user               | create  | update  | destroy  | show    |
      |           | admin              | see     | see     | see      | see     |
      |           | staff              | see     | see     | not see  | see     |
      |           | source_manager     | see     | see     | see      | see     |
      |           | source_reviewer    | not see | not see | not see  | see     |
      |           | observer_requestor | not see | not see | not see  | see     |
      |           | regular            | not see | not see | not see  | see     |
      | closed_   | admin              | see     | see     | see      | see     |
      | closed_   | staff              | see     | see     | not see  | see     |
      | closed_   | source_manager     | see     | see     | see      | see     |
      | closed_   | source_reviewer    | not see | not see | not see  | see     |
      | closed_   | observer_requestor | not see | not see | not see  | see     |
      | closed_   | regular            | not see | not see | not see  | see     |
      | upcoming_ | admin              | see     | see     | see      | see     |
      | upcoming_ | staff              | see     | see     | not see  | see     |
      | upcoming_ | source_manager     | see     | see     | see      | see     |
      | upcoming_ | source_reviewer    | not see | not see | not see  | see     |
      | upcoming_ | observer_requestor | not see | not see | not see  | not see |
      | upcoming_ | regular            | not see | not see | not see  | not see |

  @javascript
  Scenario: Register new fund_source and update
    Given a structure exists with name: "annual"
    And a structure exists with name: "semester"
    And a framework exists with name: "safc"
    And a framework exists with name: "gpsafc"
    And a fund_request_type exists with name: "Unrestricted"
    And a fund_request_type exists with name: "Special Project"
    And a closed_fund_source exists with name: "Prior Year", organization: organization "source"
    And a fund_tier exists with maximum_allocation: 1000.0, organization: organization "source"
    And a fund_tier exists with maximum_allocation: 1500.0
    And a fund_tier exists with maximum_allocation: 2000.0, organization: organization "source"
    And I log in as user: "admin"
    And I am on the new fund_source page for organization: "source"
    Then I should not see "$1,500.00"
    When I fill in "Name" with "Annual SAFC"
    And I select "annual" from "Structure"
    And I select "safc" from "Framework"
    And I select "gpsafc" from "Submission framework"
    And I fill in "Contact name" with "Office of the Assemblies"
    And I fill in "Contact email" with "office@example.com"
    And I fill in "Contact web" with "http://example.com/"
    And I fill in "Open at" with "2009-10-15 12:00 pm"
    And I fill in "Closed at" with "2009-10-20 12:00 pm"
    And I follow "add queue"
    And I fill in "Advertised submit at" with "2009-10-19 11:00 am"
    And I fill in "Submit at" with "2009-10-19 12:00 pm"
    And I fill in "Release at" with "2009-10-19 06:00 pm"
    And I check "Special Project"
    And I check "Prior Year"
    And I check "$1,000.00"
    And I press "Create"
    Then I should see "Fund source was successfully created."
    And I should see "Name: Annual SAFC"
    And I should see "Structure: annual"
    And I should see "Framework: safc"
    And I should see "Submission framework: gpsafc"
    And I should see "Contact name: Office of the Assemblies"
    And I should see "Contact email: office@example.com"
    And I should see "Contact web: http://example.com/"
    And I should see "Open at: 2009-10-15 12:00:00"
    And I should see "Closed at: 2009-10-20 12:00:00"
    And I should see "Prior Year"
    And I should see the following entries in "#fund-queues":
      | Advertised submit at            | Submit at                       | Release at                      | Fund request types |
      | Mon, 19 Oct 2009 11:00:00 -0400 | Mon, 19 Oct 2009 12:00:00 -0400 | Mon, 19 Oct 2009 18:00:00 -0400 | Special Project    |
    And I should see the following entries in "#fund-tiers":
      | Maximum Allocation |
      | $1,000.00          |
    When I follow "Edit"
    And I fill in "Name" with "Semester GPSAFC"
    And I fill in "Contact name" with "Another Office"
    And I fill in "Contact email" with "office@other.com"
    And I fill in "Contact web" with "http://example.org/"
    And I fill in "Open at" with "2009-10-16 12:00 pm"
    And I fill in "Closed at" with "2009-10-21 01:00 pm"
    And I follow "remove queue"
    And I uncheck "Prior Year"
    And I uncheck "$1,000"
    And I press "Update"
    Then I should see "Fund source was successfully updated."
    And I should see "Name: Semester GPSAFC"
    And I should see "Contact name: Another Office"
    And I should see "Contact email: office@other.com"
    And I should see "Contact web: http://example.org/"
    And I should see "Open at: 2009-10-16 12:00:00"
    And I should not see "Prior Year"
    And I should see "No fund queues."
    And I should see "Closed at: 2009-10-21 13:00:00"
    And I should see "No fund tiers."

  Scenario: Delete fund_source
    Given a fund_source exists with organization: organization "source", name: "fund_source 4"
    And a fund_source exists with organization: organization "source", name: "fund_source 3"
    And a fund_source exists with organization: organization "source", name: "fund_source 2"
    And a fund_source exists with organization: organization "source", name: "fund_source 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd fund_source for organization: "source"
    Then I should see the following fund_sources:
      | Name          |
      | fund_source 1 |
      | fund_source 2 |
      | fund_source 4 |

