Feature: Manage user sessions
  In order to login to an account
  As a user
  I want to login

  Background:
    Given a user exists with net_id: "zzz999"

  Scenario: Login an exisiting user
    Given I am on the login page
    When I fill in "Net" with "aa1"
    And I fill in "Password" with "secret"
    And I press "Login"
    Then I should see "You logged in successfully."

