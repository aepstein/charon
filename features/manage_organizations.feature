Feature: Manage organizations
  In order to Manage fund_requests for an organization
  As a member of an organization
  I want the organization profile page

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists
# TODO provide way for users to find out what criteria are not met in a framework context
#  Scenario Outline: Show unfulfilled requirements for organization in profile
#    Given a role exists
#    And a framework exists with name: "SAFC"
#    And a registration_criterion exists with must_register: true, minimal_percentage: 10, type_of_member: "staff"
#    And a requirement exists with permission: permission "first", fulfillable: the registration_criterion
#    And a requirement exists with permission: permission "second", fulfillable: the registration_criterion
#    And an organization: "qualified" exists
#    And a registration exists with organization: organization "qualified", number_of_staff: 10, registered: true
#    And an organization: "unqualified" exists
#    And a membership exists with active: true, organization: organization "qualified", role: the role
#    And a membership exists with active: true, organization: organization "unqualified", role: the role
#    And I am logged in as "admin" with password "secret"
#    And I am on the profile page for organization: "<organization>"
#    Then I should <see> "The organization has unfulfilled requirements that may limit what it is able to do:"
#    And I should <see> "The organization must be registered and have at least 10% staff as members in the registration in order to create, update SAFC fund_requests. Click here to update the registration."
#    Examples:
#      | organization | see     |
#      | qualified    | not see |
#      | unqualified  | see     |

  Scenario Outline: Test permissions for organizations controller
    Given an organization exists with last_name: "Focus Organization"
    And a manager_role exists
    And a user: "manager" exists
    And a membership exists with organization: the organization, user: user "manager", role: the manager_role
    And a fund_requestor_role exists
    And a user: "fund_requestor" exists
    And a membership exists with organization: the organization, user: user "fund_requestor", role: the fund_requestor_role
    And a reviewer_role exists
    And a user: "reviewer" exists
    And a membership exists with organization: the organization, user: user "reviewer", role: the reviewer_role
    And I log in as user: "<user>"
    Given I am on the profile page for the organization
    Then I should <profile> authorized
    Given I am on the page for the organization
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the organizations page
    Then I should <show> "Focus Organization"
    And I should <profile> "Profile"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    And I should <create> "New organization"
    And I am on the new organization page
    Then I should <create> authorized
    Given I post on the organizations page
    Then I should <create> authorized
    And I am on the edit page for the organization
    Then I should <update> authorized
    Given I put on the page for the organization
    Then I should <update> authorized
    Given I delete on the page for the organization
    Then I should <destroy> authorized
    Examples:
      | user      | create  | update  | destroy | show | profile |
      | admin     | see     | see     | see     | see  | see     |
      | manager   | not see | see     | see     | see  | see     |
      | fund_requestor | not see | not see | not see | see  | see     |
      | reviewer  | not see | not see | not see | see  | see     |
      | regular   | not see | not see | not see | see  | not see |

  Scenario Outline: Show headings for fund_requests appropriately based on fund_requests status
    Given an organization exists
    And a fund_source exists with name: "Focus FundSource"
    And a user: "fund_requestor" exists
    And a fund_requestor_role exists
    And a membership exists with organization: the organization, user: user "fund_requestor", role: the fund_requestor_role
    And a fund_request exists with organization: the organization, fund_source: the fund_source, status: "<status>"
    And I log in as user: "<user>"
    And I am on the profile page for the organization
    Then I should <creatable> "FundSources for you to make new fund_requests"
    And I should <started> "FundRequests you have started"
    And I should <completed> "FundRequests you have completed"
    And I should <submitted> "FundRequests you have submitted"
    And I should <accepted> "FundRequests that have been accepted for review"
    And I should <released> "FundRequests that have been released"
    And I should see "Focus FundSource"
    Examples:
      | user      | status    | creatable | started | completed | submitted | accepted | released |
      | admin     | started   | not see   | see     | not see   | not see   | not see  | not see  |
      | admin     | completed | not see   | not see | see       | not see   | not see  | not see  |
      | fund_requestor | started   | not see   | see     | not see   | not see   | not see  | not see  |
      | fund_requestor | completed | not see   | not see | see       | not see   | not see  | not see  |
      | fund_requestor | submitted | see       | not see | not see   | see       | not see  | not see  |
      | fund_requestor | accepted  | see       | not see | not see   | not see   | see      | not see  |
      | fund_requestor | reviewed  | see       | not see | not see   | not see   | see      | not see  |
      | fund_requestor | certified | see       | not see | not see   | not see   | see      | not see  |
      | fund_requestor | released  | see       | not see | not see   | not see   | not see  | see      |

  Scenario Outline: Register a new organization and edit
    Given a current_registration exists with name: "Cornell Club", registered: true
    And a framework exists with name: "Budget FundRequests"
    And a registration_criterion exists with type_of_member: "undergrads", minimal_percentage: 0, must_register: true
    And a fund_requestor_requirement exists with fulfillable: the registration_criterion, framework: the framework
    And I log in as user: "admin"
    And I am on the new organization <context>
    When I fill in "First name" with "Cornell"
    And I fill in "Last name" with "Club"
    And I choose "Yes"
    And I press "Create"
    Then I should see "Organization was successfully created."
    And I should see "First name: Cornell"
    And I should see "Last name: Club"
    And I should see "Club sport? Yes"
    When I follow "Edit"
    And I fill in "First name" with "The Cornell"
    And I fill in "Last name" with "Night Club"
    And I choose "No"
    And I press "Update"
    Then I should see "Organization was successfully updated."
    And I should see "First name: The Cornell"
    And I should see "Last name: Night Club"
    And I should see "Club sport? No"
    And I should <registered> "Budget FundRequests"
    And I should <registered> "Registered? Yes"
    Examples:
      | context                           | registered |
      | page                              | not see    |
      | page for the current_registration | see        |

  Scenario: Search organizations
    Given there are no organizations
    And an organization exists with first_name: "Cornell", last_name: "Outing Club"
    And an organization exists with first_name: "Cornell", last_name: "Fishing Club"
    And an organization exists with last_name: "Optimist Society"
    And an organization exists with first_name: "Optimist", last_name: "Group"
    And I log in as user: "admin"
    And I am on the organizations page
    Then I should see the following organizations:
      | Name                 |
      | Cornell Fishing Club |
      | Optimist Group       |
      | Optimist Society     |
      | Cornell Outing Club  |
    When I fill in "Name" with "cornell"
    And I press "Search"
    Then I should see the following organizations:
      | Name                 |
      | Cornell Fishing Club |
      | Cornell Outing Club  |
    When I fill in "Name" with "optimist"
    And I press "Search"
    Then I should see the following organizations:
      | Name             |
      | Optimist Group   |
      | Optimist Society |

