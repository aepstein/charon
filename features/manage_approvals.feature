Feature: Manage approvals
  In order to digitally sign documents
  As a duty-bound organization
  I want to create and destroy approvals

  Background:
    Given the following users:
      | net_id    | password | admin |
      | admin     | secret   | true  |
      | regular   | secret   | false |
      | president | secret   | false |
      | treasurer | secret   | false |
      | advisor   | secret   | false |
    And the following roles:
      | name      |
      | president |

  Scenario: Register new approval (agreement)
    Given the following agreements:
      | name | content        |
      | safc | some agreement |
    And the following permissions:
      | role      | agreements |
      | president | safc       |
    And the following memberships:
      | role      | user      |
      | president | president |
    And I am logged in as "president" with password "secret"
    When I follow "Approve"
    Then I should see "Name: safc"
    Given 1 second elapses
    And the Agreement records change
    When I press "Confirm Approval"
    Then I should not see "Approval was successfully created."
    When I press "Confirm Approval"
    Then I should see "Approval was successfully created."

  Scenario: Register new approval (request)
    Given a user "allowed" exists with net_id: "allowed", password: "secret"
    And a role: "approver" exists
    And an organization: "owner" exists with last_name: "Cool Club"
    And a membership exists with role: role "approver", user: user "allowed", active: true, organization: organization "owner"
    And a framework exists
    And a permission exists with role: role "approver", action: "approve", perspective: "requestor", status: "started", framework: the framework
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

