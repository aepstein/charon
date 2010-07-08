Feature: Manage registration terms
  In order to manage the terms into which registrations are arranged
  As an applicant
  I want a structure form

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for registration terms controller actions
    Given a registration_term exists with description: "2010 Year"
    And I log in as user: "<user>"
    And I am on the page for the registration_term
    Then I should <show> authorized
    Given I am on the registration_terms page
    Then I should <show> authorized
    And I should <show> "2010 Year"
    Examples:
      | user    | show    |
      | admin   | see     |
      | regular | see     |

