Feature: Manage structures
  In order to Manage structure of fund_request
  As an applicant
  I want a structure form

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for structures controller actions
    Given an structure: "basic" exists with name: "SAFC"
    And I log in as user: "<user>"
    And I am on the page for structure: "basic"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the structures page
    Then I should <show> authorized
    And I should <show> "SAFC"
    And I should <create> "New structure"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new structure page
    Then I should <create> authorized
    Given I post on the structures page
    Then I should <create> authorized
    And I am on the edit page for structure: "basic"
    Then I should <update> authorized
    Given I put on the page for structure: "basic"
    Then I should <update> authorized
    Given I delete on the page for structure: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | staff   | see     | see     | not see | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Register new structure and edit
    Given I log in as user: "admin"
    And I am on the new structure page
    When I fill in "Name" with "safc semester"
    And I press "Create"
    Then I should see "Structure was successfully created."
    And I should see "Name: safc semester"
    When I follow "Edit"
    And I fill in "structure_name" with "changed"
    And I press "Update"
    Then I should see "Structure was successfully updated."
    And I should see "Name: changed"

  Scenario: Delete structure
    Given a structure exists with name: "structure 4"
    And a structure exists with name: "structure 3"
    And a structure exists with name: "structure 2"
    And a structure exists with name: "structure 1"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd structure
    Then I should see the following structures:
      | Name        |
      | structure 1 |
      | structure 2 |
      | structure 4 |

