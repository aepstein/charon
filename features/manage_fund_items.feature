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
    And a fund_queue exists with fund_source: the fund_source
    And a fund_grant exists with fund_source: the fund_source, organization: organization "applicant"
    And a fund_request exists with state: "<state>", review_state: "<review_state>", fund_grant: the fund_grant, fund_queue: the fund_queue
    And a fund_item: "root" exists with fund_grant: the fund_grant, node: node "root"
    And a fund_edition exists with fund_item: fund_item "root", perspective: "requestor", fund_request: the fund_request
    And I log in as user: "<user>"
    And I am on the new fund_item page for the fund_request
    Then I should <create> authorized
    Given I post on the fund_items page for the fund_request
    Then I should <create> authorized
    And I am on the edit page for the fund_request and the fund_item
    Then I should <update> authorized
    Given I put on the page for the fund_request and the fund_item
    Then I should <update> authorized
    Given I am on the page for the fund_request and the fund_item
    Then I should <show> authorized
    Given I am on the fund_items page for the fund_request
    Then I should <show> "Root"
    And I should <destroy> "Destroy"
    And I should <remove> "Remove"
    Given I delete on the page for the fund_item
    Then I should <destroy> authorized
    Examples:
      |state    |review_state|user               |create |update |show   |destroy|remove |
      |started  |unreviewed  |admin              |see    |see    |see    |see    |see    |
      |started  |unreviewed  |source_manager     |see    |see    |see    |see    |see    |
      |started  |unreviewed  |source_reviewer    |not see|not see|see    |not see|not see|
      |started  |unreviewed  |applicant_requestor|see    |see    |see    |not see|see    |
      |started  |unreviewed  |conflictor         |see    |see    |see    |not see|see    |
      |started  |unreviewed  |observer_requestor |not see|not see|not see|not see|not see|
      |started  |unreviewed  |regular            |not see|not see|not see|not see|not see|
      |tentative|unreviewed  |admin              |see    |see    |see    |see    |see    |
      |tentative|unreviewed  |source_manager     |see    |see    |see    |see    |see    |
      |tentative|unreviewed  |source_reviewer    |not see|not see|see    |not see|not see|
      |tentative|unreviewed  |applicant_requestor|not see|not see|see    |not see|not see|
      |tentative|unreviewed  |conflictor         |not see|not see|see    |not see|not see|
      |tentative|unreviewed  |observer_requestor |not see|not see|not see|not see|not see|
      |tentative|unreviewed  |regular            |not see|not see|not see|not see|not see|
      |finalized|unreviewed  |admin              |see    |see    |see    |see    |see    |
      |finalized|unreviewed  |source_manager     |see    |see    |see    |see    |see    |
      |finalized|unreviewed  |source_reviewer    |not see|not see|see    |not see|not see|
      |finalized|unreviewed  |applicant_requestor|not see|not see|see    |not see|not see|
      |finalized|unreviewed  |conflictor         |not see|not see|see    |not see|not see|
      |finalized|unreviewed  |observer_requestor |not see|not see|not see|not see|not see|
      |finalized|unreviewed  |regular            |not see|not see|not see|not see|not see|
      |submitted|unreviewed  |admin              |see    |see    |see    |see    |see    |
      |submitted|unreviewed  |source_manager     |see    |see    |see    |see    |see    |
      |submitted|unreviewed  |source_reviewer    |not see|see    |see    |not see|not see|
      |submitted|unreviewed  |applicant_requestor|not see|not see|see    |not see|not see|
      |submitted|unreviewed  |conflictor         |not see|not see|see    |not see|not see|
      |submitted|unreviewed  |observer_requestor |not see|not see|not see|not see|not see|
      |submitted|unreviewed  |regular            |not see|not see|not see|not see|not see|
      |submitted|tentative   |admin              |see    |see    |see    |see    |see    |
      |submitted|tentative   |source_manager     |see    |see    |see    |see    |see    |
      |submitted|tentative   |source_reviewer    |not see|not see|see    |not see|not see|
      |submitted|tentative   |applicant_requestor|not see|not see|see    |not see|not see|
      |submitted|tentative   |conflictor         |not see|not see|see    |not see|not see|
      |submitted|tentative   |observer_requestor |not see|not see|not see|not see|not see|
      |submitted|tentative   |regular            |not see|not see|not see|not see|not see|
      |submitted|ready       |admin              |see    |see    |see    |see    |see    |
      |submitted|ready       |source_manager     |see    |see    |see    |see    |see    |
      |submitted|ready       |source_reviewer    |not see|not see|see    |not see|not see|
      |submitted|ready       |applicant_requestor|not see|not see|see    |not see|not see|
      |submitted|ready       |conflictor         |not see|not see|see    |not see|not see|
      |submitted|ready       |observer_requestor |not see|not see|not see|not see|not see|
      |submitted|ready       |regular            |not see|not see|not see|not see|not see|
      |released |ready       |admin              |see    |see    |see    |see    |see    |
      |released |ready       |source_manager     |see    |see    |see    |see    |see    |
      |released |ready       |source_reviewer    |not see|not see|see    |not see|not see|
      |released |ready       |applicant_requestor|not see|not see|see    |not see|not see|
      |released |ready       |conflictor         |not see|not see|see    |not see|not see|
      |released |ready       |observer_requestor |not see|not see|not see|not see|not see|
      |released |ready       |regular            |not see|not see|not see|not see|not see|

  Scenario Outline: Create or update an fund_item with embedded fund_edition
    Given an organization exists with last_name: "Applicant"
    And a structure exists
    And a node: "new" exists with name: "New", structure: the structure
    And a node: "existing" exists with name: "Existing", structure: the structure
    And a node: "subordinate" exists with name: "Subordinate", structure: the structure, parent: node "existing"
    And a fund_source exists with structure: the structure
    And a fund_grant: "other" exists with fund_source: the fund_source
    And a fund_request: "other" exists with fund_grant: fund_grant "other"
    And a fund_grant: "focus" exists with fund_source: the fund_source, organization: the organization
    And a fund_request: "focus" exists with fund_grant: fund grant "focus"
    And a fund_item exists with node: node "existing", fund_grant: fund_grant "<request>"
    And a fund_edition exists with fund_item: the fund_item, fund_request: fund_request "<request>"
    And a fund_edition exists with fund_item: the fund_item, fund_request: fund_request "<request>", perspective: "reviewer"
    And I log in as user: "admin"
    When I am on the fund_items page for fund_request: "focus"
    Then I should not see "Reviewer"
    When I select "<node>" from "Add New <box>"
    And I press "Add <button>"
    And I fill in "Requestor amount" with "100"
    And I fill in "Requestor comment" with "This is *important*."
    And I press "Create Fund item"
    Then I should see "Fund item was successfully created."
    When I follow "Show" for the <item> fund_item for fund_request: "focus"
    Then I should <parent> "Parent: Existing"
    And I should see "Node: <node>"
    And I should see "Requestor amount: $100.00"
    And I should see "This is important."
    When I follow "Edit"
    And I fill in "Requestor amount" with "200"
    And I fill in "Requestor comment" with "Different comment."
    And I fill in "Reviewer amount" with "100"
    And I fill in "Reviewer comment" with "Final comment."
    And I press "Update Fund item"
    Then I should see "Fund item was successfully updated."
    When I follow "Show" for the <item> fund_item for fund_request: "focus"
    Then I should see "Requestor amount: $200.00"
    And I should see "Different comment."
    And I should see "Reviewer amount: $100.00"
    And I should see "Final comment."
    Examples:
      | request | node        | box                  | button    | item | parent  |
      | other   | New         | Root Item            | Root Item | 1st  | not see |
      | focus   | Subordinate | Subitem for Existing | Subitem   | 2nd  | see     |

  Scenario Outline: Prevent unauthorized user from updating an unauthorized fund_edition
    Given an organization exists with last_name: "Applicant"
    And a fund_grant exists with organization: the organization
    And a fund_request exists with fund_grant: the fund_grant
    And an fund_item exists with fund_grant: the fund_grant
    And an fund_edition exists with fund_item: the fund_item, fund_request: the fund_request, perspective: "requestor"
    And an fund_edition exists with fund_item: the fund_item, fund_request: the fund_request, perspective: "reviewer"
    And a user exists with admin: true
    And a requestor_role exists
    And a membership exists with user: the user, role: the requestor_role, organization: the organization
    And I log in as the user
    When I am on the edit page for fund_request and the fund_item
    And I fill in "Requestor amount" with "100"
    And I fill in "Reviewer amount" with "200"
    Given the user has admin: <admin>
    When I press "Update Fund item"
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
    And a node: "5" exists with structure: the structure, parent: node "4", name: "node 5"
    And a node: "6" exists with structure: the structure, parent: node "4", name: "node 6"
    And a fund_source exists with structure: the structure
    And an organization exists
    And a fund_grant exists with fund_source: the fund_source, organization: the organization
    And a fund_request exists with fund_grant: the fund_grant
    And a fund_item: "1" exists with fund_grant: the fund_grant, node: node "1"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And a fund_item: "2" exists with fund_grant: the fund_grant, node: node "2", parent: fund_item "1"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And a fund_item: "3" exists with fund_grant: the fund_grant, node: node "3", parent: fund_item "1"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And a fund_item: "4" exists with fund_grant: the fund_grant, node: node "4"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And a fund_item: "5" exists with fund_grant: the fund_grant, node: node "5", parent: fund_item "4"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And a fund_item: "6" exists with fund_grant: the fund_grant, node: node "6", parent: fund_item "4"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And a requestor_role exists
    And a user: "applicant_requestor" exists
    And a membership exists with organization: the organization, user: user "applicant_requestor", role: the requestor_role
    And I log in as user: "applicant_requestor"
    When I am on the fund_items page for the fund_request
    Then I should see the following fund_items:
      | Title  |
      | node 1 |
      | node 2 |
      | node 3 |
      | node 4 |
      | node 5 |
      | node 6 |
    When I follow "Edit" for the <old> fund_item for the fund_request
    And I select "<new>" from "Move to priority of"
    And I press "Update Fund item"
    Then I should see "Fund item was successfully updated."
    When I am on the fund_items page for the fund_request
    Then I should see the following fund_items:
      | Title  |
      | <new1> |
      | <new2> |
      | <new3> |
      | <new4> |
      | <new5> |
      | <new6> |
    Examples:
      | old | new    | new1   | new2   | new3   | new4   | new5   | new6   |
      | 6th | node 5 | node 1 | node 2 | node 3 | node 4 | node 6 | node 5 |
      | 5th | node 6 | node 1 | node 2 | node 3 | node 4 | node 6 | node 5 |
      | 4th | node 1 | node 4 | node 5 | node 6 | node 1 | node 2 | node 3 |
      | 3rd | node 2 | node 1 | node 3 | node 2 | node 4 | node 5 | node 6 |
      | 2nd | node 3 | node 1 | node 3 | node 2 | node 4 | node 5 | node 6 |
      | 1st | node 4 | node 4 | node 5 | node 6 | node 1 | node 2 | node 3 |

  Scenario: List and delete fund_items
    Given a structure exists
    And a node: "1" exists with structure: the structure, name: "node 1"
    And a node: "2" exists with structure: the structure, parent: node "1", name: "node 2"
    And a node: "3" exists with structure: the structure, parent: node "1", name: "node 3"
    And a node: "4" exists with structure: the structure, name: "node 4"
    And a fund_source exists with structure: the structure
    And a fund_grant exists with fund_source: the fund_source
    And a fund_request exists with fund_grant: the fund_grant
    And an fund_item: "1" exists with fund_grant: the fund_grant, node: node "1"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And an fund_item: "2" exists with fund_grant: the fund_grant, node: node "2", parent: fund_item "1"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And an fund_item: "3" exists with fund_grant: the fund_grant, node: node "3", parent: fund_item "1"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And an fund_item: "4" exists with fund_grant: the fund_grant, node: node "4"
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd fund_item for the fund_request
    Given I am on the fund_items page for the fund_request
    Then I should see the following fund_items:
      | Title  |
      | node 1 |
      | node 2 |
      | node 4 |
    When I follow "Destroy" for the 1st fund_item for the fund_request
    Given I am on the fund_items page for the fund_request
    Then I should see the following fund_items:
      | Title  |
      | node 4 |

