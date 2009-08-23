@wip
Feature: Manage approvers
  In order to allow applications to advance only after necessary approvals are received
  As a security-minded organization
  I want to specify approvers for certain request states

  Scenario: Register new approver
    Given I am on the new approver page
    When I fill in "Framework" with "framework 1"
    And I fill in "Role" with "role 1"
    And I press "Create"
    Then I should see "framework 1"
    And I should see "role 1"

  Scenario: Delete approver
    Given the following approvers:
      |framework|role|
      |framework 1|role 1|
      |framework 2|role 2|
      |framework 3|role 3|
      |framework 4|role 4|
    When I delete the 3rd approver
    Then I should see the following approvers:
      |Framework|Role|
      |framework 1|role 1|
      |framework 2|role 2|
      |framework 4|role 4|

