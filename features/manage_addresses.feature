Feature: Manage addresses
  In order to track addresses for users and possibly other entities
  As a mail utilizing organization
  I want to create, update, delete, list, and show addresses

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "owner" exists with net_id: "owner", password: "secret", admin: false
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false

  Scenario Outline: Test permissions for addresses controller actions
    Given an address: "owner_default" exists with addressable: user "owner"
    And I am logged in as "<user>" with password "secret"
    And I am on the new address page for user: "owner"
    Then I should <create>
    Given I post on the addresses page for user: "owner"
    Then I should <create>
    And I am on the edit page for address: "owner_default"
    Then I should <update>
    Given I put on the page for address: "owner_default"
    Then I should <update>
    Given I am on the page for address: "owner_default"
    Then I should <show>
    Given I delete on the page for address: "owner_default"
    Then I should <destroy>
    Examples:
      | user    | create                 | update                 | destroy                | show                   |
      | admin   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | owner   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | regular | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |

  Scenario Outline: Register new address
    Given I am logged in as "<user>" with password "secret"
    And I am on the new address page for user: "owner"
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
    Given an address exists with addressable: user "owner", label: "label 4"
    And an address exists with addressable: user "owner", label: "label 3"
    And an address exists with addressable: user "owner", label: "label 2"
    And an address exists with addressable: user "owner", label: "label 1"
    And I am logged in as "owner" with password "secret"
    When I delete the 3rd address for user: "owner"
    Then I should see the following addresses:
      |Label  |
      |label 1|
      |label 2|
      |label 4|

