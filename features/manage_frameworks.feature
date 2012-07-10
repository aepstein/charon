Feature: Manage frameworks
  In order to maintain permission frameworks for different fund_request scenarios
  As a security-minded institution
  I want to create, show, delete, and list frameworks

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for frameworks controller actions
    Given an framework: "basic" exists with name: "SAFC"
    And I log in as user: "<user>"
    And I am on the page for framework: "basic"
    Then I should <show> authorized
    And I should <update> "Edit"
    And I am on the frameworks page
    Then I should <show> authorized
    And I should <show> "SAFC"
    And I should <create> "New framework"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new framework page
    Then I should <create> authorized
    Given I post on the frameworks page
    Then I should <create> authorized
    And I am on the edit page for framework: "basic"
    Then I should <update> authorized
    Given I put on the page for framework: "basic"
    Then I should <update> authorized
    Given I delete on the page for framework: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Register new framework and edit
    Given a registration_criterion exists with must_register: false, minimal_percentage: 1, type_of_member: "others"
    And an agreement exists with name: "Key Agreement"
    And a role exists with name: "President"
    And I log in as user: "admin"
    And I am on the new framework page
    When I fill in "Name" with "safc framework"
    And I select "Key Agreement" from "Criterion"
    And I select "President" from "Role"
    And I press "Create"
    Then I should see "Framework was successfully created."
    And I should see "Name: safc framework"
    And I should see "Key Agreement required for President"
    When I follow "Edit"
    And I fill in "Name" with "gpsafc framework"
    And I choose "Yes"
    And I press "Update"
    Then I should see "Framework was successfully updated."
    And I should not see "Key Agreement required for President"
    And I should see "Name: gpsafc framework"

  Scenario: Delete framework
    Given a framework exists with name: "framework 4"
    And a framework exists with name: "framework 3"
    And a framework exists with name: "framework 2"
    And a framework exists with name: "framework 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd framework
    Then I should see the following frameworks:
      |Name       |
      |framework 1|
      |framework 2|
      |framework 4|

