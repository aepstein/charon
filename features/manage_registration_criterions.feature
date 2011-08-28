Feature: Manage registration_criterions
  In order to specify conditions a registered organization must meet
  As an administrator
  I want to create, update, destroy, show, and list registration criterions

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for registration criterions controller actions
    Given a registration_criterion: "basic" exists with type_of_member: "undergrads", minimal_percentage: 10
    And I log in as user: "<user>"
    And I am on the page for registration_criterion: "basic"
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the registration_criterions page
    Then I should <show> authorized
    And I should <show> "undergrads"
    And I should <create> "New registration criterion"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new registration_criterion page
    Then I should <create> authorized
    Given I post on the registration_criterions page
    Then I should <create> authorized
    And I am on the edit page for registration_criterion: "basic"
    Then I should <update> authorized
    Given I put on the page for registration_criterion: "basic"
    Then I should <update> authorized
    Given I delete on the page for registration_criterion: "basic"
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | destroy | show    |
      | admin   | see     | see     | see     | see     |
      | regular | not see | not see | not see | see     |

  Scenario: Register new registration_criterion
    Given I log in as user: "admin"
    And I am on the new registration_criterion page
    When I choose "registration_criterion_must_register_true"
      And I fill in "Minimal percentage" with "10"
      And I select "grads" from "Type of member"
      And I press "Create"
    Then I should see "Must register: Yes"
    And I should see "Minimal percentage: 10%"
    And I should see "Type of member: grads"
    When I follow "Edit"
      And I choose "registration_criterion_must_register_false"
      And I fill in "Minimal percentage" with "20"
      And I select "others" from "Type of member"
      And I press "Update"
    Then I should see "Must register: No"
    And I should see "Minimal percentage: 20%"
    And I should see "Type of member: others"

  Scenario: Delete registration_criterion
    Given a registration_criterion exists with must_register: true, type_of_member: "undergrads", minimal_percentage: 1
    And a registration_criterion exists with must_register: true, type_of_member: "undergrads", minimal_percentage: 2
    And a registration_criterion exists with must_register: true, type_of_member: "undergrads", minimal_percentage: 3
    And a registration_criterion exists with must_register: true, type_of_member: "undergrads", minimal_percentage: 4
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd registration_criterion
    Then I should see the following registration_criterions:
      |Must register|Minimal percentage  |Type of member  |
      |Yes          |1%                  |undergrads      |
      |Yes          |2%                  |undergrads      |
      |Yes          |4%                  |undergrads      |

