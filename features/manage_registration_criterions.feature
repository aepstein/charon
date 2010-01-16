Feature: Manage registration_criterions
  In order to specify conditions a registered organization must meet
  As an administrator
  I want to create, update, destroy, show, and list registration criterions

  Background:
    Given a user exists with password: "secret", net_id: "admin", admin: true
    And a user exists with password: "secret", net_id: "regular", admin: false

  Scenario Outline: Test permissions for registration criterions controller actions
    Given a registration_criterion: "basic" exists
    And I am logged in as "<user>" with password "secret"
    And I am on the new registration_criterion page
    Then I should <create>
    Given I post on the registration_criterions page
    Then I should <create>
    And I am on the edit page for registration_criterion: "basic"
    Then I should <update>
    Given I put on the page for registration_criterion: "basic"
    Then I should <update>
    Given I am on the page for registration_criterion: "basic"
    Then I should <show>
    Given I delete on the page for registration_criterion: "basic"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |

  Scenario: Register new registration_criterion
    Given I am logged in as "admin" with password "secret"
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
    And I am logged in as "admin" with password "secret"
    When I delete the 3rd registration_criterion
    Then I should see the following registration_criterions:
      |Must register|Minimal percentage  |Type of member  |
      |Yes          |1%                  |undergrads      |
      |Yes          |2%                  |undergrads      |
      |Yes          |4%                  |undergrads      |

