Feature: Manage user sessions
  In order to login to an account
  As a user
  I want to login

  Background:
    Given a user: "user" exists with net_id: "zzz999"

  Scenario: Login an exisiting user
    Given I log in as user: "user"
    Then I should see "You logged in successfully."

