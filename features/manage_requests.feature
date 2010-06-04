Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests

  Background:
    Given a user: "admin" exists with admin: true

  Scenario Outline: Test permissions for requests controller
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
    And a basis exists with name: "Annual", organization: organization "source"
    And a request: "annual" exists with basis: the basis, organization: organization "applicant", status: "<status>"
    And I log in as user: "<user>"
    And I am on the new request page for organization: "applicant"
    Then I should <create> authorized
    Given I post on the requests page for organization: "applicant"
    Then I should <create> authorized
    And I am on the edit page for the request
    Then I should <update> authorized
    Given I put on the page for the request
    Then I should <update> authorized
    Given I am on the page for the request
    Then I should <show> authorized
    Given I am on the requests page for organization: "applicant"
    Then I should <show> "Annual"
    Given I delete on the page for the request
    Then I should <destroy> authorized
    Examples:
      | status    | user                | create  | update  | show    | destroy |
      | started   | admin               | see     | see     | see     | see     |
      | started   | source_manager      | not see | see     | see     | see     |
      | started   | source_reviewer     | not see | not see | see     | not see |
      | started   | applicant_requestor | see     | see     | see     | see     |
      | started   | observer_requestor  | not see | not see | not see | not see |
      | started   | regular             | not see | not see | not see | not see |
      | completed | admin               | see     | see     | see     | see     |
      | completed | source_manager      | not see | see     | see     | see     |
      | completed | source_reviewer     | not see | not see | see     | not see |
      | completed | applicant_requestor | see     | not see | see     | not see |
      | completed | observer_requestor  | not see | not see | not see | not see |
      | completed | regular             | not see | not see | not see | not see |
      | submitted | admin               | see     | see     | see     | see     |
      | submitted | source_manager      | not see | see     | see     | see     |
      | submitted | source_reviewer     | not see | not see | see     | not see |
      | submitted | applicant_requestor | see     | not see | see     | not see |
      | submitted | observer_requestor  | not see | not see | not see | not see |
      | submitted | regular             | not see | not see | not see | not see |
      | accepted  | admin               | see     | see     | see     | see     |
      | accepted  | source_manager      | not see | see     | see     | see     |
      | accepted  | source_reviewer     | not see | not see | see     | not see |
      | accepted  | applicant_requestor | see     | not see | see     | not see |
      | accepted  | observer_requestor  | not see | not see | not see | not see |
      | accepted  | regular             | not see | not see | not see | not see |

  Scenario: Create and update requests
    Given a basis exists with name: "Annual Budget"
    And a basis exists with name: "Semester Budget"
    And an organization exists with last_name: "Spending Club"
    And I log in as user: "admin"
    And I am on the new request page for the organization
    When I select "Annual Budget" from "Basis"
    And I press "Create"
    Then I should see "Request was successfully created."
    And I should see "Basis: Annual Budget"
    When I follow "Edit"
    And I press "Update"
    Then I should see "Request was successfully updated."

  Scenario: List and delete requests
    Given a basis: "annual" exists with name: "Annual"
    And a basis: "semester" exists with name: "Semester"
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a request exists with basis: basis "semester", organization: organization: "last", status: "started"
    And a request exists with basis: basis "semester", organization: organization: "first", status: "completed"
    And a request exists with basis: basis "annual", organization: organization: "last", status: "submitted"
    And a request exists with basis: basis "annual", organization: organization: "first", status: "accepted"
    And I log in as user: "admin"
    And I am on the requests page
    When I fill in "Basis" with "annual"
    And I press "Search"
    Then I should see the following requests:
      | Basis    | Organization |
      | Annual   | First Club   |
      | Annual   | Last Club    |
    And I fill in "Organization" with "first"
    And I press "Search"
    Then I should see the following requests:
      | Basis    | Organization |
      | Annual   | First Club   |
    Given I am on the requests page for basis: "annual"
    Then I should see the following requests:
      | Organization | Status    |
      | First Club   | accepted  |
      | Last Club    | submitted |
    Given I am on the requests page for organization: "first"
    Then I should see the following requests:
      | Basis    | Status    |
      | Annual   | accepted  |
      | Semester | completed |
    When I delete the 3rd request
    And I am on the requests page
    Then I should see the following requests:
      | Basis    | Organization | Status    |
      | Annual   | First Club   | accepted  |
      | Annual   | Last Club    | submitted |
      | Semester | Last Club    | started   |

