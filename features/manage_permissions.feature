Feature: Manage permissions
  In order to assert permissions for various frameworks
  As a security-conscious institution
  I want to create, show, list, update, and destroy permissions

  Background:
    Given the following frameworks:
      | name   |
      | safc   |
    And the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
      | regular | secret   | false |
    And the following roles:
      | name      |
      | president |
      | treasurer |
      | advisor   |
      | officer   |

  Scenario: Register new permission and edit
    Given I am logged in as "admin" with password "secret"
    And I am on "safc's new permission page"
    When I select "started" from "Status"
    And I select "president" from "Role"
    And I select "approve" from "Action"
    And I select "requestor" from "Perspective"
    And I press "Create"
    Then I should see "Permission was successfully created."
    And I should see "safc"
    And I should see "started"
    And I should see "president"
    And I should see "approve"
    And I should see "requestor"
    When I follow "Edit"
    And I select "submitted" from "Status"
    And I select "treasurer" from "Role"
    And I select "update" from "Action"
    And I select "reviewer" from "Perspective"
    And I press "Update"
    Then I should see "Permission was successfully updated."
    And I should see "submitted"
    And I should see "treasurer"
    And I should see "update"
    And I should see "reviewer"

  Scenario Outline:
    Given I am logged in as "<user>" with password "secret"
    And I am on "safc's new permission page"
    Then I should see "<see>"

    Examples:
      | user    | see            |
      | admin   | New permission |
      | regular | Unauthorized   |

  Scenario: Delete permission
    And the following permissions:
      | framework | status  | role      | action  | perspective |
      | safc      | started | president | approve | requestor   |
      | safc      | started | treasurer | approve | requestor   |
      | safc      | started | advisor   | approve | requestor   |
      | safc      | started | officer   | approve | requestor   |
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd permission for "safc"
    Then I should see the following permissions:
      | status  | role      | action  | perspective |
      | started | president | approve | requestor   |
      | started | treasurer | approve | requestor   |
      | started | officer   | approve | requestor   |

