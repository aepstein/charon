Feature: Manage approvals
  In order to digitally sign documents
  As a duty-bound organization
  I want to create and destroy approvals

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And a user: "president" exists with net_id: "president", password: "secret", admin: false
    And a user: "treasurer" exists with net_id: "treasurer", password: "secret", admin: false
    And a user: "advisor" exists with net_id: "advisor", password: "secret", admin: false
    And a role: "president" exists with name: "president"

  Scenario Outline: Test permissions for agreement approvals
    Given an agreement: "basic" exists
    And an approval: "president" exists with approvable: agreement "basic", user: user "president"
    And I am logged in as "<user>" with password "secret"
    And I am on the new approval page for agreement: "basic"
    Then I should <create>
    Given I post on the approvals page for agreement: "basic"
    Then I should <create>
    Given I am on the page for approval: "president"
    Then I should <show>
    Given I delete on the page for approval: "president"
    Then I should <destroy>
    Examples:
      | user      | create                 | destroy                | show                   |
      | admin     | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | president | not see "Unauthorized" | see "Unauthorized"     | not see "Unauthorized" |
      | regular   | not see "Unauthorized" | see "Unauthorized"     | see "Unauthorized"     |

  Scenario Outline: Test permissions for request approvals
    Given a user "allowed" exists with net_id: "allowed", password: "secret"
    And a user "allowed_not_yet" exists with net_id: "allowed_not_yet", password: "secret"
    And a user "supervisor" exists with net_id: "supervisor", password: "secret"
    And a role: "approver" exists
    And a role: "supervisor" exists
    And an organization: "owner" exists with last_name: "Cool Club"
    And a membership exists with role: role "approver", user: user "allowed", active: true, organization: organization "owner"
    And a membership exists with role: role "approver", user: user "allowed_not_yet", active: true, organization: organization "owner"
    And a membership exists with role: role "supervisor", user: user "supervisor", active: true, organization: organization "owner"
    And a framework exists
    And a permission exists with role: role "approver", action: "approve", perspective: "requestor", status: "started", framework: the framework
    And a permission exists with role: role "approver", action: "approve", perspective: "requestor", status: "completed", framework: the framework
    And a permission exists with role: role "approver", action: "unapprove", perspective: "requestor", status: "completed", framework: the framework
    And a permission exists with role: role "supervisor", action: "see", perspective: "requestor", status: "started", framework: the framework
    And a permission exists with role: role "supervisor", action: "unapprove_other", perspective: "requestor", status: "completed", framework: the framework
    And a structure exists with minimum_requestors: 1, maximum_requestors: 2
    And a basis exists with framework: the framework, structure: the structure
    And a request exists with basis: the basis, status: "started"
    And the request is one of the requests of organization: "owner"
    And an approval: "allowed" exists with user: user "allowed", approvable: the request
    And I am logged in as "<user>" with password "secret"
    And I am on the new approval page for the request
    Then I should <create>
    Given I post on the approvals page for the request
    Then I should <create>
    Given I am on the page for approval: "allowed"
    Then I should <show>
    Given I delete on the page for approval: "allowed"
    Then I should <destroy>
    Examples:
      | user            | create                 | destroy                | show                   |
      | admin           | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | allowed         | not see "Unauthorized" | see "Unauthorized"     | not see "Unauthorized" |
      | allowed_not_yet | not see "Unauthorized" | see "Unauthorized"     | see "Unauthorized"     |
      | supervisor      | see "Unauthorized"     | not see "Unauthorized" | see "Unauthorized"     |
      | regular         | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |

  Scenario: Register new approval of an agreement
    Given an agreement exists with name: "safc"
    And I am logged in as "president" with password "secret"
    And I am on the new approval page for the agreement
    Then I should see "Name: safc"
    Given 1 second elapses
    And the Agreement records change
    When I press "Confirm Approval"
    Then I should not see "Approval was successfully created."
    When I press "Confirm Approval"
    Then I should see "Approval was successfully created."

  Scenario: Register new approval of a request
    Given a user "allowed" exists with net_id: "allowed", password: "secret"
    And a role: "approver" exists
    And an organization: "owner" exists with last_name: "Cool Club"
    And a membership exists with role: role "approver", user: user "allowed", active: true, organization: organization "owner"
    And a framework exists
    And a permission exists with role: role "approver", action: "approve", perspective: "requestor", status: "started", framework: the framework
    And a permission exists with role: role "approver", action: "see", perspective: "requestor", status: "completed", framework: the framework
    And a structure exists with minimum_requestors: 1, maximum_requestors: 2
    And a basis exists with framework: the framework, structure: the structure
    And a request exists with basis: the basis, status: "started"
    And the request is one of the requests of organization: "owner"
    And I am logged in as "allowed" with password "secret"
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
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd approval for the agreement
    Then I should see the following approvals:
      | User      |
      | John Doe 1|
      | John Doe 2|
      | John Doe 4|

