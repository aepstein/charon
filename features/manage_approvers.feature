Feature: Manage approvers
  In order to allow applications to advance only after necessary approvals are received
  As a security-minded organization
  I want to specify approvers for certain request states

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists
    And a framework: "safc" exists with name: "safc"
    And a framework: "gpsafc" exists with name: "gpsafc"
    And a role: "president" exists with name: "president"
    And a role: "treasurer" exists with name: "treasurer"

  Scenario Outline: Test permissions for approver controller actions
    Given an approver: "basic" exists with framework: framework "safc", role: role "president"
    And I log in as user: "<user>"
    Given I am on the page for approver: "basic"
    Then I should <show> authorized
    Given I am on the approvers page for framework: "safc"
    Then I should <show> "president"
    And I should <create> "New approver"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new approver page for framework: "safc"
    Then I should <create> authorized
    Given I post on the approvers page for framework: "safc"
    Then I should <create> authorized
    And I am on the edit page for approver: "basic"
    Then I should <update> authorized
    Given I put on the page for approver: "basic"
    Then I should <update> authorized
    Given I delete on the page for approver: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy  | show |
      | admin   | see     | see     | see      | see  |
      | regular | not see | not see | not see  | see  |

  Scenario: Register new approver and update
    Given I log in as user: "admin"
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
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd approver for framework: "safc"
    Then I should see the following approvers:
      | Perspective | Role           | Status    |
      | requestor   | advisor        | completed |
      | requestor   | president      | completed |
      | requestor   | vice-president | completed |

