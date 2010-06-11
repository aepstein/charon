Feature: Manage approvals
  In order to digitally sign documents
  As a duty-bound organization
  I want to create and destroy approvals

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists
    And a user: "owner" exists with last_name: "Focus User"
@wip
  Scenario Outline: Test permissions for approvals of agreements
    Given an agreement exists
    And an approval exists with user: user "owner", approvable: the agreement
    And I log in as user: "<user>"
    And I am on the page for the approval
    Then I should <show> authorized
    Given I am on the approvals page for the agreement
    Then I should <show> "Focus User"
    And I should <destroy> "Destroy"
    Given I am on the new approval page for the agreement
    Then I should <create> authorized
    Given I post on the approvals page for the agreement
    Then I should <create> authorized
    Given I delete on the page for the approval
    Then I should <destroy> authorized
    Examples:
      | user    | create  | destroy | show    |
      | admin   | see     | see     | see     |
      | owner   | not see | not see | see     |
      | regular | see     | not see | not see |

  Scenario Outline: Test permissions for approvals of requests
    Given an organization: "source" exists with last_name: "Funding Source"
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
    And a membership exists with user: user "owner", organization: organization "applicant", role: role "<owner>"
    And a basis exists with name: "Annual", organization: organization "source"
    And a request exists with basis: the basis, organization: organization "applicant"
    And an approval exists with user: user "owner", approvable: the request
    And the request has status: "<status>"
    And I log in as user: "<user>"
    And I am on the page for the approval
    Then I should <show> authorized
    Given I am on the approvals page for the request
    Then I should <show> authorized
    And I should <create> "New approval"
    And I should <destroy> "Destroy"
    Given I am on the new approval page for the request
    Then I should <create> authorized
    Given I post on the approvals page for the request
    Then I should <create> authorized
    Given I delete on the page for the approval
    Then I should <destroy> authorized
    Examples:
      | owner     | status    | user                | create  | destroy | show    |
      | requestor | started   | admin               | not see | see     | see     |
      | requestor | started   | source_manager      | not see | see     | see     |
      | requestor | started   | source_reviewer     | not see | not see | see     |
      | requestor | started   | applicant_requestor | see     | see     | see     |
      | requestor | started   | owner               | not see | see     | see     |
      | requestor | started   | observer_requestor  | not see | not see | not see |
      | requestor | started   | regular             | not see | not see | not see |
      | requestor | completed | admin               | not see | see     | see     |
      | requestor | completed | source_manager      | not see | see     | see     |
      | requestor | completed | source_reviewer     | not see | not see | see     |
      | requestor | completed | applicant_requestor | see     | not see | see     |
      | requestor | completed | owner               | not see | see     | see     |
      | requestor | completed | observer_requestor  | not see | not see | not see |
      | requestor | completed | regular             | not see | not see | not see |
      | requestor | submitted | admin               | not see | see     | see     |
      | requestor | submitted | source_manager      | not see | see     | see     |
      | requestor | submitted | source_reviewer     | not see | not see | see     |
      | requestor | submitted | applicant_requestor | not see | not see | see     |
      | requestor | submitted | owner               | not see | not see | see     |
      | requestor | submitted | observer_requestor  | not see | not see | not see |
      | requestor | submitted | regular             | not see | not see | not see |
      | requestor | accepted  | admin               | not see | see     | see     |
      | requestor | accepted  | source_manager      | not see | see     | see     |
      | requestor | accepted  | source_reviewer     | see     | not see | see     |
      | requestor | accepted  | applicant_requestor | not see | not see | see     |
      | requestor | accepted  | owner               | not see | not see | see     |
      | requestor | accepted  | observer_requestor  | not see | not see | not see |
      | requestor | accepted  | regular             | not see | not see | not see |
      | requestor | reviewed  | admin               | not see | see     | see     |
      | requestor | reviewed  | source_manager      | not see | see     | see     |
      | requestor | reviewed  | source_reviewer     | see     | not see | see     |
      | requestor | reviewed  | applicant_requestor | not see | not see | see     |
      | requestor | reviewed  | owner               | not see | not see | see     |
      | requestor | reviewed  | observer_requestor  | not see | not see | not see |
      | requestor | reviewed  | regular             | not see | not see | not see |
      | requestor | certified | admin               | not see | see     | see     |
      | requestor | certified | source_manager      | not see | see     | see     |
      | requestor | certified | source_reviewer     | not see | not see | see     |
      | requestor | certified | applicant_requestor | not see | not see | see     |
      | requestor | certified | observer_requestor  | not see | not see | not see |
      | requestor | certified | owner               | not see | not see | see     |
      | requestor | certified | regular             | not see | not see | not see |
      | requestor | released  | admin               | not see | see     | see     |
      | requestor | released  | source_manager      | not see | see     | see     |
      | requestor | released  | source_reviewer     | not see | not see | see     |
      | requestor | released  | applicant_requestor | not see | not see | see     |
      | requestor | released  | owner               | not see | not see | see     |
      | requestor | released  | observer_requestor  | not see | not see | not see |
      | requestor | released  | regular             | not see | not see | not see |

  Scenario: Register new approval of an agreement
    Given an agreement exists with name: "safc"
    And I log in as user: "admin"
    And I am on the new approval page for the agreement
    Then I should see "Name: safc"
    Given 1 second elapses
    And the Agreement records change
    When I press "Confirm Approval"
    Then I should not see "Approval was successfully created."
    When I press "Confirm Approval"
    Then I should see "Approval was successfully created."

  Scenario: Register new approval of a request
    Given a user exists
    And a requestor_role exists
    And an organization: "applicant" exists
    And a membership exists with user: the user, role: the requestor_role, organization: the organization
    And a request exists with organization: the organization
    And I log in as the user
    And I am on the new approval page for the request
    And I press "Confirm Approval"
    Then I should see "Approval was successfully created."

  Scenario: Delete approval
    Given an agreement exists
    And a user: "user4" exists with first_name: "John", last_name: "Doe 4"
    And a user: "user3" exists with first_name: "John", last_name: "Doe 3"
    And a user: "user2" exists with first_name: "John", last_name: "Doe 2"
    And a user: "user1" exists with first_name: "John", last_name: "Doe 1"
    And an approval exists with user: user "user4", approvable: the agreement
    And an approval exists with user: user "user3", approvable: the agreement
    And an approval exists with user: user "user2", approvable: the agreement
    And an approval exists with user: user "user1", approvable: the agreement
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd approval for the agreement
    Given I am on the approvals page for the agreement
    Then I should see the following approvals:
      | User      |
      | John Doe 1|
      | John Doe 2|
      | John Doe 4|

