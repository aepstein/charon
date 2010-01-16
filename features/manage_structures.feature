Feature: Manage structures
  In order to Manage structure of request
  As an applicant
  I want a structure form

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario Outline: Test permissions for structures controller actions
    Given an structure: "basic" exists
    And I am logged in as "<user>" with password "secret"
    And I am on the new structure page
    Then I should <create>
    Given I post on the structures page
    Then I should <create>
    And I am on the edit page for structure: "basic"
    Then I should <update>
    Given I put on the page for structure: "basic"
    Then I should <update>
    Given I am on the page for structure: "basic"
    Then I should <show>
    Given I delete on the page for structure: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new structure and edit
    Given I am logged in as "admin" with password "secret"
    And I am on the new structure page
    When I fill in "Name" with "safc semester"
    And I fill in "Maximum requestors" with "1"
    And I fill in "Minimum requestors" with "1"
    And I press "Create"
    Then I should see "Structure was successfully created."
    And I should see "Name: safc semester"
    And I should see "Maximum requestors: 1"
    And I should see "Minimum requestors: 1"
    When I follow "Edit"
    And I fill in "structure_name" with "changed"
    And I fill in "Maximum requestors" with "2"
    And I fill in "Minimum requestors" with "2"
    And I press "Update"
    Then I should see "Structure was successfully updated."
    And I should see "Name: changed"
    And I should see "Maximum requestors: 2"
    And I should see "Minimum requestors: 2"

  Scenario: Delete structure
    Given a structure exists with name: "structure 4"
    And a structure exists with name: "structure 3"
    And a structure exists with name: "structure 2"
    And a structure exists with name: "structure 1"
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd structure
    Then I should see the following structures:
      | Name        |
      | structure 1 |
      | structure 2 |
      | structure 4 |

