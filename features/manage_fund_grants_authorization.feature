#TODO withdrawal functional testing
Feature: Manage fund_grants authorization
  In order to have secure management
  As an administrator
  I want to verify authorization control of funds_grants actions

  Background:
    Given a user: "admin" exists with admin: true
    And an organization: "source" exists with last_name: "Funding Source"
    And an organization: "applicant" exists with last_name: "Applicant"
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

  Scenario Outline: Test permissions for fund_grants controller w/o fund_source
    Given a fund_source exists with name: "Annual", organization: organization "source"
    And a fund_grant: "annual" exists with fund_source: the fund_source, organization: organization "applicant"
    And I log in as user: "<user>"
    And I am on the new fund_grant page for organization: "applicant"
    Then I should <create> authorized
    Given I post on the fund_grants page for organization: "applicant"
    Then I should <create> authorized
    And I am on the edit page for the fund_grant
    Then I should <update> authorized
    Given I put on the page for the fund_grant
    Then I should <update> authorized
    Given I am on the page for the fund_grant
    Then I should <show> authorized
    Given I am on the fund_grants page for organization: "applicant"
    Then I should see authorized
    And I should <show> "Annual" within "tbody"
    Given I am on the fund_grants page for the fund_source
    Then I should see authorized
    And I should <show> "Applicant" within "tbody"
    Given I delete on the page for the fund_grant
    Then I should <destroy> authorized
    Examples:
      | user                | create  | update  | show    | destroy |
      | admin               | see     | see     | see     | see     |
      | source_manager      | not see | see     | see     | see     |
      | source_reviewer     | not see | not see | see     | not see |
      | applicant_requestor | see     | not see | see     | not see |
      | observer_requestor  | not see | not see | not see | not see |
      | regular             | not see | not see | not see | not see |

  Scenario Outline: Test permissions for fund_grants controller with fund_source
    Given a fund_source exists with name: "Annual", organization: organization "source"
    And a fund_queue exists with fund_source: the fund_source
    And I log in as user: "<user>"
    And I am on the new fund_grant page for organization: "applicant"
    When I select "Annual" from "Fund source"
    And there are no fund_queues
    And the fund_source is <state>
    And a fund_queue exists with fund_source: the fund_source
    And I press "Create"
    Then I should <create> authorized
    Examples:
      | state    | user                | create  |
      | open     | applicant_requestor | see     |
      | upcoming | applicant_requestor | not see |
      | closed   | applicant_requestor | not see |

