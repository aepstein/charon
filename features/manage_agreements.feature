Feature: Manage agreements
  In order to keep and track binding agreements
  As a contract-bound organization
  I want to create, edit, destroy, show, and list agreements

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario: Register new agreement
    Given I am logged in as "admin" with password "secret"
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
    And I am logged in as "<user>" with password "secret"
    And I am on the new agreement page
    Then I should <create>
    Given I post on the agreements page
    Then I should <create>
    And I am on the edit page for agreement: "basic"
    Then I should <update>
    Given I put on the page for agreement: "basic"
    Then I should <update>
    Given I am on the page for agreement: "basic"
    Then I should <show>
    Given I delete on the page for agreement: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Delete agreement
    Given I am logged in as "admin" with password "secret"
    And an agreement exists with name: "name 4", content: "content"
    And an agreement exists with name: "name 3", content: "content"
    And an agreement exists with name: "name 2", content: "content"
    And an agreement exists with name: "name 1", content: "content"
    When I delete the 3rd agreement
    Then I should see the following agreements:
      |Name  |
      |name 1|
      |name 2|
      |name 4|

