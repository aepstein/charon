Feature: Manage items
  In order to Manage structure of items using request item
  As an applicant
  I want request item form

  Background:
    Given a user: "admin" exists with admin: true

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
    And a user: "conflictor" exists
    And a membership exists with user: user "conflictor", organization: organization "source", role: role "reviewer"
    And a membership exists with user: user "conflictor", organization: organization "applicant", role: role "requestor"
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
      | status    | user                | create  | update  | show    | destroy |
      | started   | admin               | see     | see     | see     | see     |
      | started   | source_manager      | see     | see     | see     | see     |
      | started   | source_reviewer     | not see | not see | see     | not see |
      | started   | applicant_requestor | see     | see     | see     | see     |
      | started   | conflictor          | see     | see     | see     | see     |
      | started   | observer_requestor  | not see | not see | not see | not see |
      | started   | regular             | not see | not see | not see | not see |
      | completed | admin               | see     | see     | see     | see     |
      | completed | source_manager      | see     | see     | see     | see     |
      | completed | source_reviewer     | not see | not see | see     | not see |
      | completed | applicant_requestor | not see | not see | see     | not see |
      | completed | conflictor          | not see | not see | see     | not see |
      | completed | observer_requestor  | not see | not see | not see | not see |
      | completed | regular             | not see | not see | not see | not see |
      | submitted | admin               | see     | see     | see     | see     |
      | submitted | source_manager      | see     | see     | see     | see     |
      | submitted | source_reviewer     | not see | not see | see     | not see |
      | submitted | applicant_requestor | not see | not see | see     | not see |
      | submitted | conflictor          | not see | not see | see     | not see |
      | submitted | observer_requestor  | not see | not see | not see | not see |
      | submitted | regular             | not see | not see | not see | not see |
      | accepted  | admin               | see     | see     | see     | see     |
      | accepted  | source_manager      | see     | see     | see     | see     |
      | accepted  | source_reviewer     | not see | see     | see     | not see |
      | accepted  | applicant_requestor | not see | not see | see     | not see |
      | accepted  | conflictor          | not see | not see | see     | not see |
      | accepted  | observer_requestor  | not see | not see | not see | not see |
      | accepted  | regular             | not see | not see | not see | not see |
      | reviewed  | admin               | see     | see     | see     | see     |
      | reviewed  | source_manager      | see     | see     | see     | see     |
      | reviewed  | source_reviewer     | not see | not see | see     | not see |
      | reviewed  | applicant_requestor | not see | not see | see     | not see |
      | reviewed  | conflictor          | not see | not see | see     | not see |
      | reviewed  | observer_requestor  | not see | not see | not see | not see |
      | reviewed  | regular             | not see | not see | not see | not see |
      | certified | admin               | see     | see     | see     | see     |
      | certified | source_manager      | see     | see     | see     | see     |
      | certified | source_reviewer     | not see | not see | see     | not see |
      | certified | applicant_requestor | not see | not see | see     | not see |
      | certified | conflictor          | not see | not see | see     | not see |
      | certified | observer_requestor  | not see | not see | not see | not see |
      | certified | regular             | not see | not see | not see | not see |
      | released  | admin               | see     | see     | see     | see     |
      | released  | source_manager      | see     | see     | see     | see     |
      | released  | source_reviewer     | not see | not see | see     | not see |
      | released  | applicant_requestor | not see | not see | see     | not see |
      | released  | conflictor          | not see | not see | see     | not see |
      | released  | observer_requestor  | not see | not see | not see | not see |
      | released  | regular             | not see | not see | not see | not see |

  Scenario Outline: Create or update an item with embedded edition
    Given an organization exists with last_name: "Applicant"
    And a structure exists
    And a node: "new" exists with name: "New", structure: the structure
    And a node: "existing" exists with name: "Existing", structure: the structure
    And a node: "subordinate" exists with name: "Subordinate", structure: the structure, parent: node "existing"
    And a basis exists with structure: the structure
    And a request: "other" exists with basis: the basis
    And a request: "focus" exists with basis: the basis, organization: the organization
    And an item exists with node: node "existing", request: request "<request>"
    And I log in as user: "admin"
    When I am on the items page for request: "focus"
    Then I should not see "Reviewer"
    When I select "<node>" from "Add New <box>"
    And I press "Add <button>"
    And I fill in "Requestor amount" with "100"
    And I fill in "Requestor comment" with "This is *important*."
    And I press "Create Item"
    Then I should see "Item was successfully created."
    And I should <parent> "Parent: Existing"
    And I should see "Node: <node>"
    And I should see "Requestor amount: $100.00"
    And I should see "This is important."
    When I follow "Edit"
    And I fill in "Requestor amount" with "200"
    And I fill in "Requestor comment" with "Different comment."
    And I fill in "Reviewer amount" with "100"
    And I fill in "Reviewer comment" with "Final comment."
    And I press "Update Item"
    Then I should see "Item was successfully updated."
    And I should see "Requestor amount: $200.00"
    And I should see "Different comment."
    And I should see "Reviewer amount: $100.00"
    And I should see "Final comment."
    Examples:
      | request | node        | box                  | button    | parent  |
      | other   | New         | Root Item            | Root Item | not see |
      | focus   | Subordinate | Subitem for Existing | Subitem   | see     |

  Scenario Outline: Prevent unauthorized user from updating an unauthorized edition
    Given an organization exists with last_name: "Applicant"
    And a request exists with organization: the organization
    And an item exists with request: the request
    And an edition exists with item: the item, perspective: "requestor"
    And an edition exists with item: the item, perspective: "reviewer"
    And a user exists with admin: true
    And a requestor_role exists
    And a membership exists with user: the user, role: the requestor_role, organization: the organization
    And I log in as the user
    When I am on the edit page for the item
    And I fill in "Requestor amount" with "100"
    And I fill in "Reviewer amount" with "200"
    Given the user has admin: <admin>
    When I press "Update Item"
    Then I should <update> authorized
    Examples:
      | admin | update  |
      | true  | see     |
      | false | not see |

  Scenario Outline: Move items among priorities
    Given a structure exists
    And a node: "1" exists with structure: the structure, name: "node 1"
    And a node: "2" exists with structure: the structure, parent: node "1", name: "node 2"
    And a node: "3" exists with structure: the structure, parent: node "1", name: "node 3"
    And a node: "4" exists with structure: the structure, name: "node 4"
    And a basis exists with structure: the structure
    And a request exists with basis: the basis
    And an item: "1" exists with request: the request, node: node "1"
    And edition exists with item: the item
    And an item: "2" exists with request: the request, node: node "2", parent: item "1"
    And edition exists with item: the item
    And an item: "3" exists with request: the request, node: node "3", parent: item "1"
    And edition exists with item: the item
    And an item: "4" exists with request: the request, node: node "4"
    And edition exists with item: the item
    And I log in as user: "admin"
    When I am on the items page for the request
    Then I should see the following items:
      | Title  |
      | node 1 |
      | node 2 |
      | node 3 |
      | node 4 |
    When I follow "Edit" for the <old> item for the request
    And I select "<new>" from "Move to priority of"
    And I press "Update Item"
    Then I should see "Item was successfully updated."
    When I am on the items page for the request
    Then I should see the following items:
      | Title  |
      | <new1> |
      | <new2> |
      | <new3> |
      | <new4> |
    Examples:
      | old | new    | new1   | new2   | new3   | new4   |
      | 4th | node 1 | node 4 | node 1 | node 2 | node 3 |
      | 3rd | node 2 | node 1 | node 3 | node 2 | node 4 |
      | 2nd | node 3 | node 1 | node 3 | node 2 | node 4 |
      | 1st | node 4 | node 4 | node 1 | node 2 | node 3 |

  Scenario: List and delete items
    Given a structure exists
    And a node: "1" exists with structure: the structure, name: "node 1"
    And a node: "2" exists with structure: the structure, parent: node "1", name: "node 2"
    And a node: "3" exists with structure: the structure, parent: node "1", name: "node 3"
    And a node: "4" exists with structure: the structure, name: "node 4"
    And a basis exists with structure: the structure
    And a request exists with basis: the basis
    And an item: "1" exists with request: the request, node: node "1"
    And an item: "2" exists with request: the request, node: node "2", parent: item "1"
    And an item: "3" exists with request: the request, node: node "3", parent: item "1"
    And an item: "4" exists with request: the request, node: node "4"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd item for the request
    Then I should see the following items:
      | Title  |
      | node 1 |
      | node 2 |
      | node 4 |
    When I follow "Destroy" for the 1st item for the request
    Then I should see the following items:
      | Title  |
      | node 4 |

