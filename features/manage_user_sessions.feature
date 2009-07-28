@wip
Feature: Manage user sessions
  In order to login to the account,customize shifts and logout
  As a person
  I want to login and logout as a user

 Background:
    Given the following user records:
    | net_id | email | password|password_confirmation|
    | hss78  | hss78@cornell.edu  | welcome |welcome|


 Scenario: Login an exisiting user
    And I am on the new usersession page
    When I fill in "Net" with "hss78"
    And I fill in "Password" with "welcome"
    And I press "Login"
    Then I should see "Login successful."
    Then I should be on "hss78's upcoming shifts page"
    When I follow "Current Shifts"
    Then I should be on "hss78's current shifts page"
    When I follow "Edit User Profile"
    Then I should be on "hss78's edit profile page"
    When I follow "Logout"
    Then I should be on the new usersession page
    And I should see "Logout successful."

