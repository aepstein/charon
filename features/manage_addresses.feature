Feature: Manage addresses
  In order to track addresses for users and possibly other entities
  As a mail utilizing organization
  I want to CRUD addresses

  Background:
    Given the following users:
      | net_id  | password | admin |
      | admin   | secret   | true  |
      | owner   | secret   | false |
      | regular | secret   | false |


  Scenario Outline: Gate new address form
    Given I am logged in as "<user>" with password "secret"
    And I am on "owner's" new address page
    Then I should see "<see>"

    Examples:
      | user    | see          |
      | admin   | New          |
      | owner   | New          |
      | regular | Unauthorized |

  Scenario Outline: Register new address
    Given I am logged in as "<user>" with password "secret"
    And I am on "owner's" new address page
    When I fill in "Label" with "house"
    And I fill in "Street" with "100 the Commons"
    And I fill in "City" with "Ithaca"
    And I fill in "State" with "NY"
    And I fill in "Zip" with "14850"
    And I choose "address_on_campus_false"
    And I press "Create"
    Then I should see "Label: house"
    And I should see "Street: 100 the Commons"
    And I should see "City: Ithaca"
    And I should see "State: NY"
    And I should see "Zip: 14850"
    And I should see "On campus: No"
    When I follow "Edit"
    And I fill in "Label" with "work"
    And I fill in "Street" with "109 Day Hall"
    And I fill in "City" with "Ithaca"
    And I fill in "State" with "NY"
    And I fill in "Zip" with "14853"
    And I choose "address_on_campus_true"
    And I press "Update"
    Then I should see "Label: work"
    And I should see "Street: 109 Day Hall"
    And I should see "City: Ithaca"
    And I should see "State: NY"
    And I should see "Zip: 14853"
    And I should see "On campus: Yes"

    Examples:
      | user  |
      | admin |
      | owner |

  Scenario: Delete address
    Given the following addresses:
      |addressable|label  |street  |city  |state  |zip  |on_campus|
      |owner      |label 1|street 1|city 1|state 1|zip 1|false    |
      |owner      |label 2|street 2|city 2|state 2|zip 2|true     |
      |owner      |label 3|street 3|city 3|state 3|zip 3|false    |
      |owner      |label 4|street 4|city 4|state 4|zip 4|true     |
    And I am logged in as "owner" with password "secret"
    When I delete "owner's" 3rd address
    Then I should see the following addresses:
      |Label  |
      |label 1|
      |label 2|
      |label 4|

