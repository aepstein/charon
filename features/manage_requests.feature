Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests
@wip
  Scenario Outline: Test permissions for requests controller
    Given an organization: "source" exists with last_name: "Funding Source"
    And an organization: "applicant" exists with last_name: "Applicant"
    And an organization: "observer" exists with last_name: "Observer"
    And a manager_role: "manager" exists with name: "Manager"
    And a requestor_role: "requestor" exists with name: "Requestor"
    And a reviewer_role: "reviewer" exists with name: "Reviewer"
    And a user: "admin" exists with admin: true
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
    And a request: "annual" exists with basis: the basis
    And organization: "applicant" is alone amongst the organizations of the request
    And I log in as user: "<user>"
    And I am on the new request page for the organization
    Then I should <create> authorized
    Given I post on the requests page for the organization
    Then I should <create> authorized
    And I am on the edit page for the request
    Then I should <update> authorized
    Given I put on the page for the request
    Then I should <update> authorized
    Given I am on the page for the request
    Then I should <show> authorized
    Given I am on the requests page for the organization
    Then I should <show> "Request of Applicant from Annual"
    Given I delete on the page for the request
    Then I should <destroy> authorized
    Examples:
      | user    | create  | update  | show    | destroy |
      | admin   | see     | see     | see     | see     |

  Scenario: Register new request
    Given I am on the profile page for organization: "safc1"
    And I am logged in as "requestor" with password "secret"
    When I press "Create"
    Then I should see "Request was successfully created."

  Scenario: List requests for an organization with 1 request
    Given I am logged in as "requestor" with password "secret"
    And I am on the requests page for organization: "safc1"
    Then I should see the following requests:
      | Basis        |
      | safc basis 1 |

  Scenario: List requests for an organization with 2 requests
    Given I am logged in as "requestor" with password "secret"
    And I am on the requests page for organization: "safc2"
    Then I should see the following requests:
      | Basis        |
      | safc basis 1 |
      | safc basis 2 |

  Scenario: List requests for an organization with no requests
    Given I am logged in as "requestor" with password "secret"
    And I am on the requests page for the organization: "safc3"
    Then I should see the following requests:
      | Organizations |

  Scenario: List requests for a basis
    Given a basis: "fall" exists with name: "fall semester"
    And a basis: "spring" exists with name: "spring semester"
    And an organization: "org1" exists with last_name: "Abc Club"
    And an organization: "org2" exists with last_name: "14 Society"
    And an organization: "org3" exists with last_name: "Zxy Club"
    And a request exists with basis: basis "fall", status: "accepted"
    And organization: "org3" is alone amongst the organizations of the request
    And a request exists with basis: basis "spring", status: "accepted"
    And organization: "org1" is alone amongst the organizations of the request
    And a request exists with basis: basis "fall", status: "reviewed"
    And organization: "org1" is alone amongst the organizations of the request
    And a request exists with basis: basis "fall", status: "accepted"
    And organization: "org2" is alone amongst the organizations of the request
    And I am logged in as "admin" with password "secret"
    And I am on the requests page for basis: "fall"
    Then I should see the following requests:
      | Organizations |
      | 14 Society    |
      | Abc Club      |
      | Zxy Club      |
    When I fill in "Search" with "club"
    And I press "Go"
    Then I should see the following requests:
      | Organizations |
      | Abc Club      |
      | Zxy Club      |
    When I select "accepted" from "Status"
    And I press "Go"
    Then I should see the following requests:
      | Organizations |
      | 14 Society    |
      | Zxy Club      |

