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
    And a fund_item exists with fund_grant: the fund_grant, node: node "administrative", amount: "100.0", released_amount: "200.0"
    And a fund_item exists with fund_grant: the fund_grant, node: node "event", amount: "150.0", released_amount: "250.0"
    And I log in as user: "<user>"
    And I am on the page for the fund_grant
    Then I should <unreleased> the following categories:
      | Category       | Unreleased Amount  | Released Amount |
      | Administrative | $100.00 | $200.00         |
      | Events         | $150.00 | $250.00         |
      | TOTAL          | $250.00 | $450.00         |
    And I should <released> the following categories:
      | Category       | Released Amount |
      | Administrative | $200.00         |
      | Events         | $250.00         |
      | TOTAL          | $450.00         |
    Examples:
      | user                | unreleased | released |
      | admin               | see        | not see  |
      | applicant_requestor | not see    | see      |

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

  Scenario Outline: Display unfulfilled fund grant information on new fund_grant
    Given a framework: "focus" exists
    And a framework: "other" exists
    And a registration_criterion exists with must_register: true
    And an agreement exists with name: "Ethical Conduct Statement"
    And a requestor_requirement exists with framework: framework "<o_requirement>", fulfillable: the registration_criterion
    And a requestor_requirement exists with framework: framework "<u_requirement>", fulfillable: the agreement
    And a fund_source exists with name: "Annual Budget", framework: framework "focus"
    And a fund_queue exists with fund_source: the fund_source
    And fund_request_type: "unrestricted" is amongst the fund_request_types of the fund_queue
    And a fund_source exists with name: "Semester Budget"
    And a fund_queue exists with fund_source: the fund_source
    And a fund_request_type exists
    And the fund_request_type is amongst the fund_request_types of the fund_queue
    And an organization exists with last_name: "Spending Club"
    And a requestor_role exists
    And a user: "applicant_requestor" exists
    And a membership exists with organization: the organization, role: the requestor_role, user: user "applicant_requestor", active: true
    And I log in as user: "<user>"
    And I am on the new fund_grant page for the organization
    Then I should <unfulfilled> "You may be interested in the following fund sources, for which you or your organization have not fulfilled all requirements."
    And I should <unfulfilled> "Certain requirements must be fulfilled before you may request funds from Annual Budget on behalf of Spending Club."
    And I should <see_o> "Spending Club:"
    And I should <see_o> "must have a current registration with an approved status"
    And I should <see_u> "You:"
    And I should <see_u> "must approve the Ethical Conduct Statement"
    Examples:
      | o_requirement | u_requirement | user                | unfulfilled | see_o   | see_u   |
      | focus         | focus         | applicant_requestor | see         | see     | see     |
      | focus         | other         | applicant_requestor | see         | see     | not see |
      | other         | focus         | applicant_requestor | see         | not see | see     |
      | other         | other         | applicant_requestor | not see     | not see | not see |

