Feature: Manage items
  In order to Manage structure of items using request item
  As an applicant
  I want request item form

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
    And a node: "administrative" exists with structure: structure "annual", requestable_type: "AdministrativeExpense", name: "administrative expense"
    And a node: "local" exists with structure: structure "annual", requestable_type: "LocalEventExpense", name: "local event expense"
    And a node: "travel" exists with structure: structure "annual", requestable_type: "TravelEventExpense", name: "travel event expense"
    And a node: "durable" exists with structure: structure "annual", requestable_type: "DurableGoodExpense", name: "durable good expense"
    And a node: "publication" exists with structure: structure "annual", requestable_type: "PublicationExpense", name: "publication expense"
    And a node: "speaker" exists with structure: structure "annual", requestable_type: "SpeakerExpense", name: "speaker expense"
    And a framework: "safc" exists with name: "undergrad"
    And a permission exists with framework: framework "safc", status: "started", role: role "president", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", status: "started", role: role "president", action: "create", perspective: "requestor"
    And a permission exists with framework: framework "safc", status: "started", role: role "president", action: "update", perspective: "requestor"
    And a permission exists with framework: framework "safc", status: "started", role: role "president", action: "destroy", perspective: "requestor"
    And a permission exists with framework: framework "safc", status: "started", role: role "commissioner", action: "see", perspective: "reviewer"
    And a basis: "annual_safc" exists with name: "annual budget", structure: structure "annual", framework: framework "safc", organization: organization "commission"
    And a request exists with status: "started", basis: basis "annual_safc"
    And organization: "club" is amongst the organizations of the request

  Scenario Outline: Test permissions for items controller actions
    Given an item exists with request: the request, node: node "administrative"
    And I am logged in as "<user>" with password "secret"
    And I am on the new item page for the request
    Then I should <create>
    Given I post on the items page for the request
    Then I should <create>
    And I am on the edit page for the item
    Then I should <update>
    Given I put on the page for the item
    Then I should <update>
    Given I am on the page for the item
    Then I should <show>
    Given I delete on the page for the item
    Then I should <destroy>
    Examples:
      | user        | create                 | update                 | destroy                | show                   |
      | admin       | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | president   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | commissioner| see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |
      | regular     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |

  Scenario: Create new item and edition
    Given I am logged in as "president" with password "secret"
    And I am on the items page for the request
    And I select "administrative expense" from "Add New Item"
    And I press "Add"
    Then I should see "Item was successfully created."

  Scenario Outline: Create new item only if admin or may update request
    Given I am logged in as "<user>" with password "secret"
    When I am on the items page for the request
    Then I should <should>
    Examples:
      | user         | should                 |
      | admin        | see "Add New Item"     |
      | president    | see "Add New Item"     |
      | commissioner | not see "Add New Item" |

  Scenario: Move an item
    Given an item exists with request: the request, node: node "administrative"
    And an item exists with request: the request, node: node "durable"
    And an item exists with request: the request, node: node "publication"
    And an item exists with request: the request, node: node "travel"
    And I am logged in as "president" with password "secret"
    And I am on the items page for the request
    When I follow "Move"
    And I select "publication expense" from "Move to priority of"
    And I press "Move"
    Then I should see "Item was successfully moved."
    And I should see the following items:
      | Perspective            |
      | durable good expense   |
      | requestor              |
      | publication expense    |
      | requestor              |
      | administrative expense |
      | requestor              |
      | travel event expense   |
      | requestor              |

  Scenario: Delete an item
    Given an item exists with request: the request, node: node "administrative"
    And an item exists with request: the request, node: node "durable"
    And an item exists with request: the request, node: node "publication"
    And an item exists with request: the request, node: node "travel"
    And I am logged in as "president" with password "secret"
    When I delete the 5th item for the request
    Then I should see "Item was successfully destroyed."
    And I should see the following items:
      | Perspective            |
      | administrative expense |
      | requestor              |
      | durable good expense   |
      | requestor              |
      | travel event expense   |
      | requestor              |

  Scenario: Show correct add edition links
    Given an item: "administrative" exists with request: the request, node: node "administrative"
    And an item: "durable" exists with request: the request, node: node "durable"
    And an item exists with request: the request, node: node "publication"
    And an edition exists with item: item "administrative", perspective: "requestor"
    And an edition exists with item: item "administrative", perspective: "reviewer"
    And an edition exists with item: item "durable", perspective: "requestor"
    And I am logged in as "admin" with password "secret"
    When I am on the items page for the request
    Then I should see the following items:
      | Perspective            | Amount         |
      | administrative expense | Move Destroy   |
      | requestor              | $0.00          |
      | reviewer               | $0.00          |
      | durable good expense   | Move Destroy   |
      | requestor              | $0.00          |
      | reviewer               | None yet.      |
      | publication expense    | Move Destroy   |
      | requestor              | None yet.      |

