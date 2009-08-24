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
    When I fill in "Label" with "label 1"
    And I fill in "Street" with "street 1"
    And I fill in "City" with "city 1"
    And I fill in "State" with "state 1"
    And I fill in "Zip" with "zip 1"
    And I check "On campus"
    And I press "Create"
    Then I should see "Label: label 1"
    And I should see "Street: street 1"
    And I should see "City: city 1"
    And I should see "State: state 1"
    And I should see "Zip: zip 1"
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

