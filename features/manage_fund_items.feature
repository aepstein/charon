Feature: Manage fund_items
  In order to Manage structure of fund_items using fund_request fund_item
  As an applicant
  I want fund_request fund_item form

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for fund_items controller
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
    And a fund_source exists with name: "Annual", organization: organization "source", structure: the structure
    And a fund_request exists with fund_source: the fund_source, organization: organization "applicant", status: "<status>"
    And an fund_item: "root" exists with fund_request: the fund_request, node: node "root"
    And an fund_edition exists with fund_item: fund_item "root", perspective: "requestor"
    And I log in as user: "<user>"
    And I am on the new fund_item page for the fund_request
    Then I should <create> authorized
    Given I post on the fund_items page for the fund_request
    Then I should <create> authorized
    And I am on the edit page for the fund_item
    Then I should <update> authorized
    Given I put on the page for the fund_item
    Then I should <update> authorized
    Given I am on the page for the fund_item
    Then I should <show> authorized
    Given I am on the fund_items page for the fund_request
    Then I should <show> "Root"
    Given I delete on the page for the fund_item
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

  Scenario Outline: Create or update an fund_item with embedded fund_edition
    Given an organization exists with last_name: "Applicant"
    And a structure exists
    And a node: "new" exists with name: "New", structure: the structure
    And a node: "existing" exists with name: "Existing", structure: the structure
    And a node: "subordinate" exists with name: "Subordinate", structure: the structure, parent: node "existing"
    And a fund_source exists with structure: the structure
    And a fund_request: "other" exists with fund_source: the fund_source
    And a fund_request: "focus" exists with fund_source: the fund_source, organization: the organization
    And an fund_item exists with node: node "existing", fund_request: fund_request "<fund_request>"
    And I log in as user: "admin"
    When I am on the fund_items page for fund_request: "focus"
    Then I should not see "Reviewer"
    When I select "<node>" from "Add New <box>"
    And I press "Add <button>"
    And I fill in "FundRequestor amount" with "100"
    And I fill in "FundRequestor comment" with "This is *important*."
    And I press "Create FundItem"
    Then I should see "FundItem was successfully created."
    And I should <parent> "Parent: Existing"
    And I should see "Node: <node>"
    And I should see "FundRequestor amount: $100.00"
    And I should see "This is important."
    When I follow "Edit"
    And I fill in "FundRequestor amount" with "200"
    And I fill in "FundRequestor comment" with "Different comment."
    And I fill in "Reviewer amount" with "100"
    And I fill in "Reviewer comment" with "Final comment."
    And I press "Update FundItem"
    Then I should see "FundItem was successfully updated."
    And I should see "FundRequestor amount: $200.00"
    And I should see "Different comment."
    And I should see "Reviewer amount: $100.00"
    And I should see "Final comment."
    Examples:
      | fund_request | node        | box                  | button    | parent  |
      | other   | New         | Root FundItem            | Root FundItem | not see |
      | focus   | Subordinate | Subfund_item for Existing | Subfund_item   | see     |

  Scenario Outline: Prevent unauthorized user from updating an unauthorized fund_edition
    Given an organization exists with last_name: "Applicant"
    And a fund_request exists with organization: the organization
    And an fund_item exists with fund_request: the fund_request
    And an fund_edition exists with fund_item: the fund_item, perspective: "requestor"
    And an fund_edition exists with fund_item: the fund_item, perspective: "reviewer"
    And a user exists with admin: true
    And a requestor_role exists
    And a membership exists with user: the user, role: the requestor_role, organization: the organization
    And I log in as the user
    When I am on the edit page for the fund_item
    And I fill in "FundRequestor amount" with "100"
    And I fill in "Reviewer amount" with "200"
    Given the user has admin: <admin>
    When I press "Update FundItem"
    Then I should <update> authorized
    Examples:
      | admin | update  |
      | true  | see     |
      | false | not see |

  Scenario Outline: Move fund_items among priorities
    Given a structure exists
    And a node: "1" exists with structure: the structure, name: "node 1"
    And a node: "2" exists with structure: the structure, parent: node "1", name: "node 2"
    And a node: "3" exists with structure: the structure, parent: node "1", name: "node 3"
    And a node: "4" exists with structure: the structure, name: "node 4"
    And a fund_source exists with structure: the structure
    And a fund_request exists with fund_source: the fund_source
    And an fund_item: "1" exists with fund_request: the fund_request, node: node "1"
    And fund_edition exists with fund_item: the fund_item
    And an fund_item: "2" exists with fund_request: the fund_request, node: node "2", parent: fund_item "1"
    And fund_edition exists with fund_item: the fund_item
    And an fund_item: "3" exists with fund_request: the fund_request, node: node "3", parent: fund_item "1"
    And fund_edition exists with fund_item: the fund_item
    And an fund_item: "4" exists with fund_request: the fund_request, node: node "4"
    And fund_edition exists with fund_item: the fund_item
    And I log in as user: "admin"
    When I am on the fund_items page for the fund_request
    Then I should see the following fund_items:
      | Title  |
      | node 1 |
      | node 2 |
      | node 3 |
      | node 4 |
    When I follow "Edit" for the <old> fund_item for the fund_request
    And I select "<new>" from "Move to priority of"
    And I press "Update FundItem"
    Then I should see "FundItem was successfully updated."
    When I am on the fund_items page for the fund_request
    Then I should see the following fund_items:
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

  Scenario: List and delete fund_items
    Given a structure exists
    And a node: "1" exists with structure: the structure, name: "node 1"
    And a node: "2" exists with structure: the structure, parent: node "1", name: "node 2"
    And a node: "3" exists with structure: the structure, parent: node "1", name: "node 3"
    And a node: "4" exists with structure: the structure, name: "node 4"
    And a fund_source exists with structure: the structure
    And a fund_request exists with fund_source: the fund_source
    And an fund_item: "1" exists with fund_request: the fund_request, node: node "1"
    And an fund_item: "2" exists with fund_request: the fund_request, node: node "2", parent: fund_item "1"
    And an fund_item: "3" exists with fund_request: the fund_request, node: node "3", parent: fund_item "1"
    And an fund_item: "4" exists with fund_request: the fund_request, node: node "4"
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd fund_item for the fund_request
    Then I should see the following fund_items:
      | Title  |
      | node 1 |
      | node 2 |
      | node 4 |
    When I follow "Destroy" for the 1st fund_item for the fund_request
    Then I should see the following fund_items:
      | Title  |
      | node 4 |

