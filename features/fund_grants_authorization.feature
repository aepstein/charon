#TODO withdrawal functional testing
Feature: Manage fund_grants authorization
  In order to have secure management
  As an administrator
  I want to verify authorization control of funds_grants actions

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And an organization: "source" exists with last_name: "Funding Source"
    And an organization: "applicant" exists with last_name: "Applicant"
    And an organization: "observer" exists with last_name: "Observer"
    And a manager_role: "manager" exists
    And a requestor_role: "requestor" exists
    And a role: "reviewer" exists with name: "commissioner"
    And a leader_role: "leader" exists
    And a user: "source_manager" exists
    And a membership exists with user: user "source_manager", organization: organization "source", role: role "manager"
    And a user: "source_leader" exists
    And a membership exists with user: user "source_leader", organization: organization "source", role: role "leader"
    And a user: "source_reviewer" exists
    And a membership exists with user: user "source_reviewer", organization: organization "source", role: role "reviewer"
    And a user: "applicant_requestor" exists
    And a membership exists with user: user "applicant_requestor", organization: organization "applicant", role: role "requestor"
    And a user: "observer_requestor" exists
    And a membership exists with user: user "observer_requestor", organization: organization "observer", role: role "requestor"
    And a user: "regular" exists

  Scenario Outline: Show allocations
    Given a category: "administrative" exists with name: "Administrative"
    And a category: "event" exists with name: "Events"
    And a category: "other" exists with name: "Curios"
    And a structure exists
    And a node: "administrative" exists with structure: the structure, category: category "administrative"
    And a node: "event" exists with structure: the structure, category: category "event"
    And a node: "other" exists with structure: the structure, category: category "other"
    And a fund_source exists with organization: organization "source", structure: the structure
    And a fund_grant exists with organization: organization "applicant", fund_source: the fund_source
    And a fund_queue exists with fund_source: the fund_source
    And a fund_request exists with fund_grant: the fund_grant, fund_queue: the fund_queue, state: "<state>", review_state: "ready"
    And a fund_item exists with fund_grant: the fund_grant, node: node "administrative"
    And a fund_allocation exists with fund_request: the fund_request, fund_item: the fund_item, amount: "200.0"
    And a fund_item exists with fund_grant: the fund_grant, node: node "event"
    And a fund_allocation exists with fund_request: the fund_request, fund_item: the fund_item, amount: "250.0"
    And I log in as user: "<user>"
    And I am on the page for the fund_grant
    Then I should <full> the following entries in "#categories":
      | Category       | Pending Allocation | Released Allocation |
      | Administrative | $<ap>.00           | $<ar>.00            |
      | Events         | $<ep>.00           | $<er>.00            |
      | TOTAL          | $<tp>.00           | $<tr>.00            |
    And I should <part> the following entries in "#categories":
      | Category       | Released Allocation |
      | Administrative | $<ar>.00            |
      | Events         | $<er>.00            |
      | TOTAL          | $<tr>.00            |
    Examples:
      | user                | full    | part     | state     | ap  | ep  | tp  | ar  | er  |  tr |
      | admin               | see     | not see  | allocated | 0   | 0   | 0   | 200 | 250 | 450 |
      | staff               | see     | not see  | allocated | 0   | 0   | 0   | 200 | 250 | 450 |
      | applicant_requestor | not see | see      | allocated |     |     |     | 200 | 250 | 450 |
      | admin               | see     | not see  | submitted | 200 | 250 | 450 | 0   | 0   | 0   |
      | staff               | see     | not see  | submitted | 200 | 250 | 450 | 0   | 0   | 0   |
      | applicant_requestor | not see | see      | submitted |     |     |     | 0   | 0   | 0   |

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
      | staff               | see     | see     | see     | not see |
      | source_manager      | not see | see     | see     | see     |
      | source_leader       | not see | see     | see     | not see |
      | source_reviewer     | not see | not see | see     | not see |
      | applicant_requestor | see     | not see | see     | not see |
      # TODO without with_permissions_to :show how do we implement?
#      | observer_requestor  | not see | not see | not see | not see |
#      | regular             | not see | not see | not see | not see |

  Scenario Outline: Test permissions for fund_grants controller with fund_source
    Given a fund_source exists with name: "Annual", organization: organization "source"
    And I log in as user: "<user>"
    And a fund_queue: "focus" exists with fund_source: the fund_source
    And a fund_queue: "other" exists
    And a fund_request_type exists
    And the fund_request_type is amongst the fund_request_types of fund_queue: "focus"
    And I am on the new fund_grant page for organization: "applicant"
    When I select "Annual" from "Fund source"
    And there are no fund_queues
    And the fund_source is <state>
    And a fund_queue: "focus" exists with fund_source: the fund_source
    And a fund_queue: "other" exists
    And a fund_request_type exists
    And the fund_request_type is amongst the fund_request_types of fund_queue: "<queue>"
    And I press "Create"
    Then I should <create> authorized
    Examples:
      | state    | queue | user                | create  |
      | current  | focus | applicant_requestor | see     |
      | current  | other | applicant_requestor | not see |
      | upcoming | focus | applicant_requestor | not see |
      | closed   | focus | applicant_requestor | not see |

