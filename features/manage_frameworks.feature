Feature: Manage frameworks
  In order to maintain permission frameworks for different request scenarios
  As a security-minded institution
  I want to create, show, delete, and list frameworks

  Background:
    Given the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
      | regular | secret   | false |

  Scenario Outline: New framework form
    Given I am logged in as "<user>" with password "secret"
    And I am on the new framework page
    Then I should see "<see>"

    Examples:
      | user    | see           |
      | admin   | New framework |
      | regular | Unauthorized  |

  Scenario Outline: Edit framework form
    Given I am logged in as "<user>" with password "secret"
    And the following frameworks:
      | name      |
      | safc      |
    And I am on "safc's edit framework page"
    Then I should see "<see>"

    Examples:
      | user    | see           |
      | admin   | Editing framework |
      | regular | Unauthorized  |

  Scenario: Register new framework and edit
    Given I am logged in as "admin" with password "secret"
    And I am on the new framework page
    When I fill in "Name" with "safc framework"
    And I choose "framework_must_register_true"
    And I fill in "Member percentage" with "50"
    And I select "undergrads" from "Member percentage type"
    And I press "Create"
    Then I should see "Framework was successfully created."
    And I should see "safc framework"
    And I should see "Must register: yes"
    And I should see "Member requirement: 50% undergrads"
    When I follow "Edit"
    And I fill in "Name" with "gpsafc framework"
    And I choose "framework_must_register_false"
    And I fill in "Member percentage" with "60"
    And I select "grads" from "Member percentage type"
    And I press "Update"
    Then I should see "Framework was successfully updated."
    And I should see "gpsafc framework"
    And I should see "Must register: no"
    And I should see "Member requirement: 60% grads"

  Scenario: Delete framework
    Given I am logged in as "admin" with password "secret"
    And the following frameworks:
      |name  |
      |name 1|
      |name 2|
      |name 3|
      |name 4|
    When I delete the 3rd framework
    Then I should see the following frameworks:
      |name  |
      |name 1|
      |name 2|
      |name 4|

