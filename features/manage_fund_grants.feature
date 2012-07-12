Feature: Manage fund_grants
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage fund_grants

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And a fund_request_type: "unrestricted" exists with name: "Unrestricted"

  Scenario Outline: Test how permissions failures are reported to the user
    Given an organization: "reviewer" exists with last_name: "Funding Source"
    And an organization: "requestor" exists with last_name: "Applicant"
    And a current_registration exists with organization: <organization>, name: "Applicant"
    And a requestor_role exists
    And a reviewer_role exists
    And a user: "requestor" exists with status: "grad"
    And a user: "reviewer" exists with status: "grad"
    And a registered_membership exists with role: the requestor_role, active: true, registration: the current_registration, user: user "requestor"
    And a membership exists with role: the requestor_role, active: true, organization: organization "requestor", user: user "requestor"
    And a membership exists with role: the reviewer_role, active: true, organization: organization "reviewer", user: user "reviewer"
    And a framework exists with name: "Annual"
    And an agreement exists with name: "Key Agreement"
    And a user_status_criterion exists
    And a registration_criterion exists with must_register: true, minimal_percentage: 15, type_of_member: "undergrads"
    And a requirement exists with framework: the framework, role: the requestor_role, fulfillable: the <fulfillable>
    And a fund_source exists with organization: organization "reviewer", framework: the framework
    And a fund_grant exists with fund_source: the fund_source, organization: organization "requestor"
    And I log in as user: "<user>"
    When I am on the edit page for the fund_grant
    Then I should <edit> authorized
    And I should <status> "You must be undergrad."
    And I should <agreement> "You must approve the Key Agreement."
    And I should <registration> "Applicant must have a current registration with at least 15 percent undergrads and an approved status."
    Examples:
      |user     |organization            |fulfillable           |edit   |status |agreement|registration|
      |admin    |organization "requestor"|user_status_criterion |see    |not see|not see  |not see     |
      |staff    |organization "requestor"|user_status_criterion |see    |not see|not see  |not see     |
      |requestor|organization "requestor"|user_status_criterion |not see|see    |not see  |not see     |
      |requestor|organization "requestor"|agreement             |not see|not see|see      |not see     |
      |requestor|organization "requestor"|registration_criterion|not see|not see|not see  |see         |
      |requestor|nil                     |registration_criterion|not see|not see|not see  |see         |

  Scenario: Create and update fund_grants
    Given a fund_source exists with name: "Annual Budget"
    And a fund_queue exists with fund_source: the fund_source
    And fund_request_type: "unrestricted" is amongst the fund_request_types of the fund_queue
    And a fund_source exists with name: "Semester Budget"
    And a fund_queue exists with fund_source: the fund_source
    And an organization exists with last_name: "Spending Club"
    And a user exists
    And a requestor_role exists
    And a membership exists with user: the user, organization: the organization, role: the requestor_role
    And I log in as the user
    And I am on the new fund_grant page for the organization
    When I select "Annual Budget" from "Fund source"
    And I press "Create"
    Then I should see "Fund grant was successfully created."
    And I should see "Fund source: Annual Budget"
    And I should see "Request type: Unrestricted"
    And I should see "State: started"
    # TODO: should we be able to edit a fund_grant?

  Scenario Outline: Display fund requests associated with a fund_grant
    Given an organization exists
    And a user exists
    And a requestor_role exists
    And a membership exists with user: the user, role: the requestor_role, organization: the organization
    And a fund_source exists
    And a fund_queue exists with fund_source: the fund_source
    And a fund_request_type exists with name: "Primary"
    And the fund_request_type is amongst the fund_request_types of the fund_queue
    And a fund_grant: "focus" exists with organization: the organization, fund_source: the fund_source
    And a fund_grant: "other" exists with fund_source: the fund_source
    And a fund_request exists with fund_grant: fund_grant "<grant>", fund_request_type: the fund_request_type
    And I log in as the user
    And I am on the page for the fund_grant: "focus"
    Then I should <no_request> "No fund requests are associated with this grant."
    And I should <request> "The following fund requests are associated with this grant:"
    And I should <request> "started"
    And I should <request> "Primary"
    And I should see "You may prepare a new fund request."
    Examples:
      | grant | no_request | request |
      | other | see        | not see |
      | focus | not see    | see     |

  Scenario: List and delete fund_grants
    Given a fund_source: "annual" exists with name: "Annual"
    And a fund_source: "semester" exists with name: "Semester"
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a fund_grant exists with fund_source: fund_source "semester", organization: organization: "last"
    And a fund_grant exists with fund_source: fund_source "semester", organization: organization: "first"
    And a fund_grant exists with fund_source: fund_source "annual", organization: organization: "last"
    And a fund_grant exists with fund_source: fund_source "annual", organization: organization: "first"
    And I log in as user: "admin"
    Given I am on the fund_grants page for fund_source: "annual"
    Then I should see the following fund_grants:
      | Organization |
      | First Club   |
      | Last Club    |
    When I fill in "Organization" with "last"
    And I press "Search"
    Then I should see the following fund_grants:
      | Organization |
      | Last Club    |
    Given I am on the fund_grants page for organization: "first"
    Then I should see the following fund_grants:
      | Fund source |
      | Annual      |
      | Semester    |
    When I fill in "Fund source" with "semester"
    And I press "Search"
    Then I should see the following fund_grants:
      | Fund source |
      | Semester    |
    When I follow "Destroy" for the 2nd fund_grant for organization: "first"
    And I am on the fund_grants page for fund_source: "semester"
    Then I should see the following fund_grants:
      | Organization |
      | Last Club    |

  Scenario Outline: Display unfulfilled fund grant information on new fund_grant
    Given a framework: "focus" exists
    And a framework: "other" exists
    And a registration_criterion exists with must_register: true
    And an agreement exists with name: "Ethical Conduct Statement"
    And a requirement exists with framework: framework "<o_requirement>", fulfillable: the registration_criterion
    And a requirement exists with framework: framework "<u_requirement>", fulfillable: the agreement
    And a fund_source exists with name: "Annual Budget", framework: framework "focus"
    And a fund_queue exists with fund_source: the fund_source
    And a fund_request_type exists
    And the fund_request_type is amongst the fund_request_types of the fund_queue
    And an organization exists with last_name: "Spending Club"
    And a requestor_role exists
    And a user: "applicant_requestor" exists
    And a membership exists with organization: the organization, role: the requestor_role, user: user "applicant_requestor", active: true
    And I log in as user: "<user>"
    And I am on the new fund_grant page for the organization
    Then I should <unfulfilled> "You may be interested in the following fund sources, for which you or your organization have not fulfilled all requirements."
    And I should <unfulfilled> "Certain requirements must be fulfilled before you may request funds from Annual Budget on behalf of Spending Club."
    And I should <see_o> "Spending Club:"
    And I should <see_o> "must have a current registration with an approved status"
    And I should <see_u> "You:"
    And I should <see_u> "must approve the Ethical Conduct Statement"
    Given a fund_grant exists with organization: the organization, fund_source: the fund_source
    And I am on the new fund_request page for the fund_grant
    Then I should <authorized> authorized
    And I should <see_o> "Spending Club must have a current registration with an approved status"
    And I should <see_u> "You must approve the Ethical Conduct Statement"
    Examples:
      |o_requirement|u_requirement|user               |unfulfilled|authorized|see_o  |see_u  |
      |focus        |focus        |applicant_requestor|see        |not see   |see    |see    |
      |focus        |other        |applicant_requestor|see        |not see   |see    |not see|
      |other        |focus        |applicant_requestor|see        |not see   |not see|see    |
      |other        |other        |applicant_requestor|not see    |see       |not see|not see|

