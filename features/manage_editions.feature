Feature: Manage editions
  In order to calculate and track transaction requests
  As a requestor or reviewer
  I want to create, update, and show editions

  Background:
    Given an organization: "club" exists with last_name: "our club"
    And an organization: "commission" exists with last_name: "undergraduate commission"
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "president" exists with net_id: "president", password: "secret", admin: false
    And a user: "commissioner" exists with net_id: "commissioner", password: "secret", admin: false
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And a role: "president" exists with name: "president"
    And a role: "commissioner" exists with name: "commissioner"
    And a membership exists with organization: organization "club", role: role "president", user: user "president"
    And a membership exists with organization: organization "commission", role: role "commissioner", user: user "commissioner"
    And a structure: "annual" exists with name: "budget"
    And a node: "generic" exists with structure: structure "annual", name: "generic expense"
    And a node: "external" exists with structure: structure "annual", requestable_type: "ExternalEquityReport", name: "external equity report", item_amount_limit: 0.0
    And a node: "administrative" exists with structure: structure "annual", requestable_type: "AdministrativeExpense", name: "administrative expense"
    And a node: "local" exists with structure: structure "annual", requestable_type: "LocalEventExpense", name: "local event expense"
    And a node: "travel" exists with structure: structure "annual", requestable_type: "TravelEventExpense", name: "travel event expense"
    And a node: "durable" exists with structure: structure "annual", requestable_type: "DurableGoodExpense", name: "durable good expense"
    And a node: "publication" exists with structure: structure "annual", requestable_type: "PublicationExpense", name: "publication expense"
    And a node: "speaker" exists with structure: structure "annual", requestable_type: "SpeakerExpense", name: "speaker expense"
    And a basis: "annual_safc" exists with name: "annual budget", structure: structure "annual", framework: framework "safc", organization: organization "commission"
    And a request exists with status: "started", basis: basis "annual_safc"
    And organization: "club" is amongst the organizations of the request

  Scenario Outline: Test permissions for editions controller actions
    Given an item: "administrative" exists with request: the request, node: node "administrative"
    And an item: "local" exists with request: the request, node: node "local"
    And an edition: "basic" exists with item: item "administrative"
    And an administrative_expense exists with edition: edition "basic"
    And I am logged in as "<user>" with password "secret"
    And I am on the new edition page for item: "local"
    Then I should <create>
    Given I post on the editions page for item: "local"
    Then I should <create>
    And I am on the edit page for the edition
    Then I should <update>
    Given I put on the page for the edition
    Then I should <update>
    Given I am on the page for the edition
    Then I should <show>
    Given I delete on the page for the edition
    Then I should <destroy>
    Examples:
      | user        | create                 | update                 | destroy                | show                   |
      | admin       | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | president   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | commissioner| see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |
      | regular     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |


  Scenario: Add and update edition (speaker_expense)
    Given an item exists with request: the request, node: node "speaker"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
    When I fill in "Name of Speaker, Performer, or Group" with "Bob"
    And I fill in "Travel distance" with "300"
    And I fill in "Number of travelers" with "1"
    And I fill in "Nights of lodging" with "2"
    And I fill in "Engagement fee" with "100"
    And I choose "edition_speaker_expense_attributes_dignitary_true"
    And I fill in "edition_amount" with "400"
    And I fill in "edition_comment" with "comment"
    And I press "Create"
    Then I should see "Edition was successfully created."
    And I should see "Requestable type: SpeakerExpense"
    And I should see "Request node: speaker expense"
    And I should see "Maximum request: $460.00"
    And I should see "Requestor amount: $400.00"
    And I should see "Requestor comment: comment"
    And I should see "Name of Speaker, Performer, or Group: Bob"
    And I should see "Travel distance: 300 miles round trip"
    And I should see "Number of travelers: 1"
    And I should see "Nights of lodging: 2"
    And I should see "Engagement fee: $100.00"
    And I should see "Dignitary: Yes"
    And I should see "Travel cost: $150.00"
    And I should see "Lodging cost: $150.00"
    And I should see "Meals cost: $60.00"
    When I follow "Edit"
    And I fill in "Name of Speaker, Performer, or Group" with "Jim"
    And I fill in "Travel distance" with "100"
    And I fill in "Number of travelers" with "3"
    And I fill in "Nights of lodging" with "1"
    And I fill in "Engagement fee" with "200"
    And I fill in "edition_amount" with "500"
    And I fill in "edition_comment" with "changed comment"
    And I choose "edition_speaker_expense_attributes_dignitary_false"
    And I press "Update"
    Then I should see "Edition was successfully updated."
    And I should see "Requestable type: SpeakerExpense"
    And I should see "Request node: speaker expense"
    And I should see "Maximum request: $665.00"
    And I should see "Requestor amount: $500.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Name of Speaker, Performer, or Group: Jim"
    And I should see "Travel distance: 100 miles round trip"
    And I should see "Number of travelers: 3"
    And I should see "Nights of lodging: 1"
    And I should see "Engagement fee: $200.00"
    And I should see "Dignitary: No"
    And I should see "Travel cost: $150.00"
    And I should see "Lodging cost: $225.00"
    And I should see "Meals cost: $90.00"
    When I follow "Edit"
    And I fill in "edition_amount" with "1500"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

