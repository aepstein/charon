Feature: Manage agreements
  In order to keep and track binding agreements
  As a contract-bound organization
  I want to create, edit, destroy, show, and list agreements

  Background:
    Given the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
      | regular | secret   | false |

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

  Scenario Outline: Properly restrict access to new agreement
    Given I am logged in as "<user>" with password "secret"
    And I am on the new agreement page
    Then I should see "<see>"

    Examples:
      | user    | see           |
      | admin   | New agreement |
      | regular | Unauthorized  |

  Scenario: Delete agreement
    Given I am logged in as "admin" with password "secret"
    And the following agreements:
      |name  |content  |
      |name 1|content 1|
      |name 2|content 2|
      |name 3|content 3|
      |name 4|content 4|
    When I delete the 3rd agreement
    Then I should see the following agreements:
      |Name  |
      |name 1|
      |name 2|
      |name 4|

