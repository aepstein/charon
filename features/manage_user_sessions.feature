Feature: Manage user sessions
  In order to login to an account
  As a user
  I want to login

  Background:
    Given a user: "user" exists with net_id: "zzz999"

  Scenario: Login an existing user
    Given I log in as user: "user"
    Then I should see "You logged in successfully."

  Scenario Outline: Administrative menu appears only for administrator
    Given a user: "admin" exists with admin: true
    And I log in as user: "<user>"
    Then I should <see> "agreements" within "#navigation"
    Examples:
      | user  | see     |
      | admin | see     |
      | user  | not see |

