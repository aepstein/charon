Feature: Manage frameworks
  In order to maintain permission frameworks for different request scenarios
  As a security-minded institution
  I want to create, show, delete, and list frameworks

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario Outline: Test permissions for frameworks controller actions
    Given an framework: "basic" exists
    And I am logged in as "<user>" with password "secret"
    And I am on the new framework page
    Then I should <create>
    Given I post on the frameworks page
    Then I should <create>
    And I am on the edit page for framework: "basic"
    Then I should <update>
    Given I put on the page for framework: "basic"
    Then I should <update>
    Given I am on the page for framework: "basic"
    Then I should <show>
    Given I delete on the page for framework: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new framework and edit
    Given I am logged in as "admin" with password "secret"
    And I am on the new framework page
    When I fill in "Name" with "safc framework"
    And I press "Create"
    Then I should see "Framework was successfully created."
    And I should see "Name: safc framework"
    When I follow "Edit"
    And I fill in "Name" with "gpsafc framework"
    And I press "Update"
    Then I should see "Framework was successfully updated."
    And I should see "Name: gpsafc framework"

  Scenario: Delete framework
    Given a framework exists with name: "framework 4"
    And a framework exists with name: "framework 3"
    And a framework exists with name: "framework 2"
    And a framework exists with name: "framework 1"
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd framework
    Then I should see the following frameworks:
      |Name       |
      |framework 1|
      |framework 2|
      |framework 4|

