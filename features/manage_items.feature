Feature: Manage items
  In order to Manage structure of items using request item
  As an applicant
  I want request item form

  Background:
    Given a user: "admin" exists with admin: true
@wip
  Scenario Outline: Test permissions for items controller
    Given an organization: "source" exists with last_name: "Funding Source"
    And an organization: "applicant" exists with last_name: "Applicant"
    And an organization: "observer" exists with last_name: "Observer"
    And a manager_role: "manager" exists
    And a requestor_role: "requestor" exists
    And a reviewer_role: "reviewer" exists
    And a user: "source_manager" exists
    And a membership exists with user: user "source_manager", organization: organization "source", role: role "manager"
    And a user: "source_reviewer" exists
    And a membership exists with user: user "source_reviewer", organization: organization "source", role: role "reviewer"
    And a user: "applicant_requestor" exists
    And a membership exists with user: user "applicant_requestor", organization: organization "applicant", role: role "requestor"
    And a user: "observer_requestor" exists
    And a membership exists with user: user "observer_requestor", organization: organization "observer", role: role "requestor"
    And a user: "regular" exists
    And a structure exists
    And a node: "root" exists with structure: the structure, name: "Root"
    And a basis exists with name: "Annual", organization: organization "source", structure: the structure
    And a request exists with basis: the basis, organization: organization "applicant", status: "<status>"
    And an item: "root" exists with request: the request, node: node "root"
    And an edition exists with item: item "root", perspective: "requestor"
    And I log in as user: "<user>"
    And I am on the new item page for the request
    Then I should <create> authorized
    Given I post on the items page for the request
    Then I should <create> authorized
    And I am on the edit page for the item
    Then I should <update> authorized
    Given I put on the page for the item
    Then I should <update> authorized
    Given I am on the page for the item
    Then I should <show> authorized
    Given I am on the items page for the request
    Then I should <show> "Root"
    Given I delete on the page for the item
    Then I should <destroy> authorized
    Examples:
      | status      | user                | create  | update  | show    | destroy |
      | started     | admin               | see     | see     | see     | see     |
      | started     | source_manager      | see     | see     | see     | see     |
      | started     | source_reviewer     | not see | not see | see     | not see |
      | started     | applicant_requestor | see     | see     | see     | see     |
      | started     | observer_requestor  | not see | not see | not see | not see |
      | started     | regular             | not see | not see | not see | not see |
      | completed   | admin               | see     | see     | see     | see     |
      | completed   | source_manager      | see     | see     | see     | see     |
      | completed   | source_reviewer     | not see | not see | see     | not see |
      | completed   | applicant_requestor | not see | not see | see     | not see |
      | completed   | observer_requestor  | not see | not see | not see | not see |
      | completed   | regular             | not see | not see | not see | not see |

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
    When I move the 1st item
    And I select "publication expense" from "Move to priority of"
    And I press "Move"
    Then I should see "Item was successfully moved."
    And I should see the following items:
      | Perspective            |
      | durable good expense   |
      | Requestor edition      |
      | publication expense    |
      | Requestor edition      |
      | administrative expense |
      | Requestor edition      |
      | travel event expense   |
      | Requestor edition      |

  Scenario: Move an item (with parent)
    Given a node: "top" exists with structure: structure "annual", name: "top"
    And a node: "administrative_n" exists with structure: structure "annual", requestable_type: "AdministrativeExpense", name: "child administrative expense", parent: node "top"
    And a node: "travel_n" exists with structure: structure "annual", requestable_type: "TravelEventExpense", name: "child travel event expense", parent: node "top"
    And a node: "durable_n" exists with structure: structure "annual", requestable_type: "DurableGoodExpense", name: "child durable good expense", parent: node "top"
    And a node: "publication_n" exists with structure: structure "annual", requestable_type: "PublicationExpense", name: "child publication expense", parent: node "top"
    And an item: "top" exists with request: the request, node: node "top"
    And an item exists with request: the request, node: node "administrative_n", parent: item "top"
    And an item exists with request: the request, node: node "durable_n", parent: item "top"
    And an item exists with request: the request, node: node "publication_n", parent: item "top"
    And an item exists with request: the request, node: node "travel_n", parent: item "top"
    And I am logged in as "president" with password "secret"
    And I am on the items page for the request
    When I move the 2nd item
    And I select "child publication expense" from "Move to priority of"
    And I press "Move"
    Then I should see "Item was successfully moved."
    And I should see the following items:
      | Perspective                  |
      | top                          |
      | Requestor edition            |
      | child durable good expense   |
      | Requestor edition            |
      | child publication expense    |
      | Requestor edition            |
      | child administrative expense |
      | Requestor edition            |
      | child travel event expense   |
      | Requestor edition            |

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
      | Requestor edition      |
      | durable good expense   |
      | Requestor edition      |
      | travel event expense   |
      | Requestor edition      |

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
      | administrative expense | Move           |
      | Requestor edition      | $0.00          |
      | Reviewer edition       | $0.00          |
      | durable good expense   | Move           |
      | Requestor edition      | $0.00          |
      | Reviewer edition       | None yet.      |
      | publication expense    | Move           |
      | Requestor edition      | None yet.      |

