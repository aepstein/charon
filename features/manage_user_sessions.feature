Feature: Manage user sessions
  In order to login to an account
  As a user
  I want to login

  Background:
    Given the following user records:
    | first_name | last_name | net_id | email            | password | password_confirmation |
    | Avery      | Adams     | aa1    | aa1@cornell.edu  | secret   | secret                |

  Scenario: Login an exisiting user
    Given I am on the login page
    When I fill in "Net" with "aa1"
    And I fill in "Password" with "secret"
    And I press "Login"
    Then I should see "Login successful!"

