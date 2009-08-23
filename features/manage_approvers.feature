@wip
Feature: Manage approvers
  In order to allow applications to advance only after necessary approvals are received
  As a security-minded organization
  I want to specify approvers for certain request states

  Background:
    Given the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
      | regular | secret   | false |
    And the following frameworks:
      | name   |
      | safc   |
      | gpsafc |
    And the following roles:
      | name      |
      | president |
      | treasurer |

  Scenario Outline: Gating creation of records
    Given I am logged in as "<user>" with password "secret"
    And I am on "safc's new approver page"
    Then I should see "<see>"

    Examples:
      | user    | see          |
      | admin   | New          |
      | regular | Unauthorized |

  Scenario: Register new approver
    Given I am logged in as "admin" with password "secret"
    And I am on "safc's new approver page"
    When I select "requestor" from "Perspective"
    And I select "president" from "Role"
    And I select "completed" from "Status"
    And I press "Create"
    Then I should see "Framework: safc"
    And I should see "Perspective: requestor"
    And I should see "Role: president"
    And I should see "Status: completed"

  Scenario: Delete approver
    Given the following approvers:
      | perspective | role           | status    |
      | requestor   | president      | completed |
      | requestor   | treasurer      | completed |
      | requestor   | advisor        | completed |
      | requestor   | vice-president | completed |
    When I delete the 3rd approver
    Then I should see the following approvers:
      | Perspective | Role           | Status    |
      | requestor   | advisor        | completed |
      | requestor   | president      | completed |
      | requestor   | vice-president | completed |

