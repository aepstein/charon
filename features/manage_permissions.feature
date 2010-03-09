Feature: Manage permissions
  In order to assert permissions for various frameworks
  As a security-conscious institution
  I want to create, show, list, update, and destroy permissions

  Background:
    Given a framework: "safc" exists with name: "safc"
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And a role: "president" exists with name: "president"
    And a role: "treasurer" exists with name: "treasurer"
    And a role: "advisor" exists with name: "advisor"
    And a role: "officer" exists with name: "officer"

  Scenario: Register new permission and edit
    Given an agreement exists with name: "Agreement A"
    And an agreement exists with name: "Agreement B"
    And I am logged in as "admin" with password "secret"
    And I am on the new permission page for framework: "safc"
    When I select "started" from "Status"
    And I select "president" from "Role"
    And I select "approve" from "Action"
    And I select "requestor" from "Perspective"
    And I check "Agreement A"
    And I press "Create"
    Then I should see "Permission was successfully created."
    And I should see "safc"
    And I should see "started"
    And I should see "president"
    And I should see "approve"
    And I should see "requestor"
    And I should see "Agreement A"
    And I should not see "Agreement B"
    When I follow "Edit"
    And I select "submitted" from "Status"
    And I select "treasurer" from "Role"
    And I select "update" from "Action"
    And I select "reviewer" from "Perspective"
    And I uncheck "Agreement A"
    And I check "Agreement B"
    And I press "Update"
    Then I should see "Permission was successfully updated."
    And I should see "submitted"
    And I should see "treasurer"
    And I should see "update"
    And I should see "reviewer"
    And I should not see "Agreement A"
    And I should see "Agreement B"

  Scenario Outline: Test permissions for permissions controller actions
    Given a permission: "basic" exists
    And I am logged in as "<user>" with password "secret"
    And I am on the new permission page for framework: "safc"
    Then I should <create>
    Given I post on the permissions page for framework: "safc"
    Then I should <create>
    And I am on the edit page for the permission
    Then I should <update>
    Given I put on the page for the permission
    Then I should <update>
    Given I am on the page for the permission
    Then I should <show>
    Given I delete on the page for the permission
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Delete permission
    Given a permission exists with framework: the framework, status: "started", role: role "president", action: "approve", perspective: "requestor"
    And a permission exists with framework: the framework, status: "started", role: role "treasurer", action: "approve", perspective: "requestor"
    And a permission exists with framework: the framework, status: "started", role: role "advisor", action: "approve", perspective: "requestor"
    And a permission exists with framework: the framework, status: "started", role: role "officer", action: "approve", perspective: "requestor"
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd permission for framework: "safc"
    Then I should see the following permissions:
      | Status  | Role      | Action  | Perspective |
      | started | president | approve | requestor   |
      | started | treasurer | approve | requestor   |
      | started | officer   | approve | requestor   |

