Feature: Manage approvers
  In order to allow applications to advance only after necessary approvals are received
  As a security-minded organization
  I want to specify approvers for certain request states

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And a framework: "safc" exists with name: "safc"
    And a framework: "gpsafc" exists with name: "gpsafc"
    And a role: "president" exists with name: "president"
    And a role: "treasurer" exists with name: "treasurer"

  Scenario Outline: Test permissions for approver controller actions
    Given an approver: "basic" exists with framework: framework "safc"
    And I am logged in as "<user>" with password "secret"
    And I am on the new approver page for framework: "safc"
    Then I should <create>
    Given I post on the approvers page for framework: "safc"
    Then I should <create>
    And I am on the edit page for approver: "basic"
    Then I should <update>
    Given I put on the page for approver: "basic"
    Then I should <update>
    Given I am on the page for approver: "basic"
    Then I should <show>
    Given I delete on the page for approver: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new approver and update
    Given I am logged in as "admin" with password "secret"
    And I am on the new approver page for framework: "safc"
    When I select "requestor" from "Perspective"
    And I select "president" from "Role"
    And I select "completed" from "Status"
    And I press "Create"
    Then I should see "Approver was successfully created."
    And I should see "Framework: safc"
    And I should see "Perspective: requestor"
    And I should see "Role: president"
    And I should see "Status: completed"
    When I follow "Edit"
    And I select "reviewer" from "Perspective"
    And I select "treasurer" from "Role"
    And I select "reviewed" from "Status"
    And I press "Update"
    Then I should see "Approver was successfully updated."
    And I should see "Framework: safc"
    And I should see "Perspective: reviewer"
    And I should see "Role: treasurer"
    And I should see "Status: reviewed"

  Scenario: Delete approver
    Given a role: "vice-president" exists with name: "vice-president"
    And a role: "advisor" exists with name: "advisor"
    And an approver exists with framework: framework "safc", role: role "vice-president", status: "completed", perspective: "requestor"
    And an approver exists with framework: framework "safc", role: role "treasurer", status: "completed", perspective: "requestor"
    And an approver exists with framework: framework "safc", role: role "president", status: "completed", perspective: "requestor"
    And an approver exists with framework: framework "safc", role: role "advisor", status: "completed", perspective: "requestor"
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd approver for framework: "safc"
    Then I should see the following approvers:
      | Perspective | Role           | Status    |
      | requestor   | advisor        | completed |
      | requestor   | president      | completed |
      | requestor   | vice-president | completed |

