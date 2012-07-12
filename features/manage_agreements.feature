Feature: Manage agreements
  In order to keep and track binding agreements
  As a contract-bound organization
  I want to create, edit, destroy, show, and list agreements

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And a user: "regular" exists

  Scenario: Register new agreement
    Given I log in as user: "admin"
    And I am on the new agreement page
    When I fill in "Name" with "Ethical Conduct Agreement"
    And I fill in "Content" with "I *agree* to behave ethically."
    And I fill in "Contact name" with "Office of the Assemblies"
    And I fill in "Contact email" with "office@example.com"
    And I press "Create"
    Then I should see "Name: Ethical Conduct Agreement"
    And I should see "I agree to behave ethically."
    And I should see "Contact name: Office of the Assemblies"
    And I should see "Contact email: office@example.com"
    When I follow "Edit"
    And I fill in "Name" with "Modified Ethical Conduct Agreement"
    And I fill in "Content" with "I agree to try to behave ethically."
    And I fill in "Contact name" with "New Office of the Assemblies"
    And I fill in "Contact email" with "new_office@example.com"
    And I press "Update"
    Then I should see "Modified Ethical Conduct Agreement"
    And I should see "I agree to try to behave ethically."
    And I should see "Contact name: New Office of the Assemblies"
    And I should see "Contact email: new_office@example.com"

  Scenario Outline: Test permissions for agreements controller actions
    Given an agreement: "basic" exists
    And I log in as user: "<user>"
    And I am on the new agreement page
    Then I should <create> authorized
    Given I post on the agreements page
    Then I should <create> authorized
    And I am on the edit page for agreement: "basic"
    Then I should <update> authorized
    Given I put on the page for agreement: "basic"
    Then I should <update> authorized
    Given I am on the page for agreement: "basic"
    Then I should <show> authorized
    Given I delete on the page for agreement: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | staff   | see     | see     | not see | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Delete agreement
    Given I log in as user: "admin"
    And an agreement exists with name: "name 4", content: "content"
    And an agreement exists with name: "name 3", content: "content"
    And an agreement exists with name: "name 2", content: "content"
    And an agreement exists with name: "name 1", content: "content"
    When I follow "Destroy" for the 3rd agreement
    Then I should see the following agreements:
      |Name  |
      |name 1|
      |name 2|
      |name 4|

