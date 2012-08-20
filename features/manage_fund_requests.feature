Feature: Manage fund_requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage fund_requests

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true

  Scenario Outline: Test permissions for fund_requests controller
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
    And a user: "conflictor_requestor" exists
    And a membership exists with user: user "conflictor_requestor", organization: organization "applicant", role: role "requestor"
    And a membership exists with user: user "conflictor_requestor", organization: organization "source", role: role "reviewer"
    And a user: "regular" exists
    And a <tense>fund_source exists with name: "Annual", organization: organization "source"
    And a fund_queue exists with fund_source: the <tense>fund_source
    And a fund_grant exists with fund_source: the <tense>fund_source, organization: organization "applicant"
    And a fund_request: "annual" exists with fund_grant: the fund_grant, state: "<state>", review_state: "<review_state>", fund_queue: the fund_queue
    And I log in as user: "<user>"
    And I am on the new fund_request page for the fund_grant
    Then I should <create> authorized
    Given I post on the fund_requests page for the fund_grant
    Then I should <create> authorized
    And I am on the edit page for the fund_request
    Then I should <update> authorized
    Given I put on the page for the fund_request
    Then I should <update> authorized
    Given I am on the page for the fund_request
    Then I should <show> authorized
    Given I put on the submit page for the fund_request
    Then I should <submit> authorized
    Given the fund_request has state: "<state>"
    And I put on the withdraw page for the fund_request
    Then I should <withdraw> authorized
    Given the fund_request has state: "<state>", fund_queue: the fund_queue
    And I put on the reconsider page for the fund_request
    Then I should <reconsider> authorized
    Given the fund_request has state: "<state>", fund_queue: the fund_queue
    And I am on the reject page for the fund_request
    Then I should <reject> authorized
    Given I put on the do_reject page for the fund_request
    Then I should <reject> authorized
#    Given I am on the fund_requests page for organization: "applicant"
#    Then I should <show> "Annual"
    Given I delete on the page for the fund_request
    Then I should <destroy> authorized
    Examples:
|tense  |state    |review_state|user                |create |update |show   |submit |withdraw|reconsider|reject |destroy|
|       |started  |unreviewed  |admin               |see    |see    |see    |not see|not see |not see   |not see|see    |
|       |started  |unreviewed  |staff               |see    |see    |see    |not see|not see |not see   |not see|not see|
|       |started  |unreviewed  |source_manager      |see    |see    |see    |not see|not see |not see   |not see|see    |
|       |started  |unreviewed  |source_reviewer     |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |started  |unreviewed  |applicant_requestor |see    |see    |see    |not see|not see |not see   |not see|not see|
|closed_|started  |unreviewed  |applicant_requestor |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |started  |unreviewed  |conflictor_requestor|see    |see    |see    |not see|not see |not see   |not see|not see|
|closed_|started  |unreviewed  |conflictor_requestor|not see|not see|see    |not see|not see |not see   |not see|not see|
|       |started  |unreviewed  |observer_requestor  |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |started  |unreviewed  |regular             |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |tentative|unreviewed  |admin               |see    |see    |see    |see    |see     |not see   |not see|see    |
|       |tentative|unreviewed  |staff               |see    |see    |see    |see    |see     |not see   |not see|not see|
|       |tentative|unreviewed  |source_manager      |see    |see    |see    |see    |see     |not see   |not see|see    |
|       |tentative|unreviewed  |source_reviewer     |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |tentative|unreviewed  |applicant_requestor |see    |not see|see    |not see|see     |not see   |not see|not see|
|closed_|tentative|unreviewed  |applicant_requestor |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |tentative|unreviewed  |conflictor_requestor|see    |not see|see    |not see|see     |not see   |not see|not see|
|closed_|tentative|unreviewed  |conflictor_requestor|not see|not see|see    |not see|not see |not see   |not see|not see|
|       |tentative|unreviewed  |observer_requestor  |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |tentative|unreviewed  |regular             |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |finalized|unreviewed  |admin               |see    |see    |see    |see    |see     |not see   |see    |see    |
|       |finalized|unreviewed  |staff               |see    |see    |see    |see    |see     |not see   |see    |not see|
|       |finalized|unreviewed  |source_manager      |see    |see    |see    |see    |see     |not see   |see    |see    |
|       |finalized|unreviewed  |source_reviewer     |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |finalized|unreviewed  |applicant_requestor |see    |not see|see    |not see|see     |not see   |not see|not see|
|closed_|finalized|unreviewed  |applicant_requestor |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |finalized|unreviewed  |conflictor_requestor|see    |not see|see    |not see|see     |not see   |not see|not see|
|closed_|finalized|unreviewed  |conflictor_requestor|not see|not see|see    |not see|not see |not see   |not see|not see|
|       |finalized|unreviewed  |observer_requestor  |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |finalized|unreviewed  |regular             |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |submitted|unreviewed  |admin               |see    |see    |see    |not see|see     |not see   |see    |see    |
|       |submitted|unreviewed  |staff               |see    |see    |see    |not see|see     |not see   |see    |not see|
|       |submitted|unreviewed  |source_manager      |see    |see    |see    |not see|see     |not see   |see    |see    |
|       |submitted|unreviewed  |source_reviewer     |not see|see    |see    |not see|not see |not see   |not see|not see|
|closed_|submitted|unreviewed  |source_reviewer     |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |submitted|unreviewed  |applicant_requestor |see    |not see|see    |not see|see     |not see   |not see|not see|
|       |submitted|unreviewed  |conflictor_requestor|see    |not see|see    |not see|see     |not see   |not see|not see|
|       |submitted|unreviewed  |observer_requestor  |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |submitted|unreviewed  |regular             |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |submitted|tentative   |admin               |see    |see    |see    |not see|see     |not see   |see    |see    |
|       |submitted|tentative   |staff               |see    |see    |see    |not see|see     |not see   |see    |not see|
|       |submitted|tentative   |source_manager      |see    |see    |see    |not see|see     |not see   |see    |see    |
|       |submitted|tentative   |source_reviewer     |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |submitted|tentative   |applicant_requestor |see    |not see|see    |not see|not see |not see   |not see|not see|
|       |submitted|tentative   |conflictor_requestor|see    |not see|see    |not see|not see |not see   |not see|not see|
|       |submitted|tentative   |observer_requestor  |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |submitted|tentative   |regular             |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |submitted|ready       |admin               |see    |see    |see    |not see|see     |not see   |see    |see    |
|       |submitted|ready       |staff               |see    |see    |see    |not see|see     |not see   |see    |not see|
|       |submitted|ready       |source_manager      |see    |see    |see    |not see|see     |not see   |see    |see    |
|       |submitted|ready       |source_reviewer     |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |submitted|ready       |applicant_requestor |see    |not see|see    |not see|not see |not see   |not see|not see|
|       |submitted|ready       |conflictor_requestor|see    |not see|see    |not see|not see |not see   |not see|not see|
|       |submitted|ready       |observer_requestor  |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |submitted|ready       |regular             |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |released |ready       |admin               |see    |see    |see    |not see|not see |see       |not see|see    |
|       |released |ready       |staff               |see    |see    |see    |not see|not see |see       |not see|not see|
|       |released |ready       |source_manager      |see    |see    |see    |not see|not see |see       |not see|see    |
|       |released |ready       |source_reviewer     |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |released |ready       |applicant_requestor |see    |not see|see    |not see|not see |not see   |not see|not see|
|       |released |ready       |conflictor_requestor|see    |not see|see    |not see|not see |not see   |not see|not see|
|       |released |ready       |observer_requestor  |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |released |ready       |regular             |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |allocated|ready       |admin               |see    |see    |see    |not see|not see |not see   |not see|see    |
|       |allocated|ready       |staff               |see    |see    |see    |not see|not see |not see   |not see|not see|
|       |allocated|ready       |source_manager      |see    |see    |see    |not see|not see |not see   |not see|see    |
|       |allocated|ready       |source_reviewer     |not see|not see|see    |not see|not see |not see   |not see|not see|
|       |allocated|ready       |applicant_requestor |see    |not see|see    |not see|not see |not see   |not see|not see|
|       |allocated|ready       |conflictor_requestor|see    |not see|see    |not see|not see |not see   |not see|not see|
|       |allocated|ready       |observer_requestor  |not see|not see|not see|not see|not see |not see   |not see|not see|
|       |allocated|ready       |regular             |not see|not see|not see|not see|not see |not see   |not see|not see|

  Scenario: Create and update fund_requests
    Given a fund_source exists with name: "Annual Budget"
    And a fund_queue exists with fund_source: the fund_source
    And a fund_request_type exists with name: "Unrestricted"
    And the fund_request_type is amongst the fund_request_types of the fund_queue
    And an organization exists with last_name: "Applicant"
    And a fund_grant exists with fund_source: the fund_source, organization: the organization
    And I log in as user: "admin"
    And I am on the new fund_request page for the fund_grant
    And I select "Unrestricted" from "Fund request type"
    And I press "Create"
    Then I should see "Fund request was successfully created."
    And I should see "Fund source: Annual Budget"
    And I should see "Requestor: Applicant"
    And I should see "Request type: Unrestricted"
    When I follow "Edit"
    And I press "Update"
    Then I should see "Fund request was successfully updated."

  Scenario Outline: Show appropriate deadline
    Given a <type>fund_source exists
    And a fund_queue exists with fund_source: the <type>fund_source
    And a fund_grant exists with fund_source: the <type>fund_source
    And a fund_request exists with fund_grant: the fund_grant, fund_queue: <queue>
    And I log in as user: "admin"
    And I am on the page for the fund_request
    Then I should see <see> for the deadline
    Examples:
      | type      | queue          | see              |
      | upcoming_ | nil            | the fund_queue   |
      |           | nil            | the fund_queue   |
      | closed_   | nil            | "None available" |
      | upcoming_ | the fund_queue | the fund_queue   |
      |           | the fund_queue | the fund_queue   |
      | closed_   | the fund_queue | the fund_queue   |

  Scenario: Reject fund_requests
    Given a fund_request exists with state: "finalized"
    And I log in as user: "admin"
    And I am on the reject page for the fund_request
    When I press "Reject"
    Then I should not see "Fund request was successfully rejected."
    When I fill in "Reject message" with "Not acceptable."
    And I press "Reject"
    Then I should see "Fund request was successfully rejected."

  Scenario: List and delete fund_requests
    Given a fund_source: "annual" exists with name: "Annual"
    And a fund_queue: "annual" exists with fund_source: fund_source "annual"
    And a fund_source: "semester" exists with name: "Semester"
    And a fund_queue: "semester" exists with fund_source: fund_source "semester"
    And an organization: "first" exists with last_name: "First Club"
    And an organization: "last" exists with last_name: "Last Club"
    And a fund_grant: "semester_last" exists with fund_source: fund_source "semester", organization: organization: "last"
    And a fund_grant: "semester_first" exists with fund_source: fund_source "semester", organization: organization: "first"
    And a fund_grant: "annual_last" exists with fund_source: fund_source "annual", organization: organization: "last"
    And a fund_grant: "annual_first" exists with fund_source: fund_source "annual", organization: organization: "first"
    And a fund_request exists with fund_grant: fund_grant "semester_last", state: "started"
    And a fund_request exists with fund_grant: fund_grant "semester_first", state: "tentative"
    And a fund_request exists with fund_grant: fund_grant "annual_last", state: "submitted", fund_queue: fund_queue "annual"
    And a fund_request exists with fund_grant: fund_grant "annual_first", state: "submitted", fund_queue: fund_queue "annual"
    And I log in as user: "admin"
    And I am on the fund_requests page
    When I fill in "Fund source" with "annual"
    And I press "Search"
    Then I should see the following fund_requests:
      | Fund source    | Requestor    |
      | Annual         | First Club   |
      | Annual         | Last Club    |
    And I fill in "Requestor" with "first"
    And I press "Search"
    Then I should see the following fund_requests:
      | Fund source    | Requestor  |
      | Annual         | First Club |
    Given I am on the fund_requests page for fund_source: "annual"
    Then I should see the following fund_requests:
      | Requestor  | State      |
      | First Club | submitted  |
      | Last Club  | submitted  |
    Given I am on the unqueued fund_requests page for fund_source: "semester"
    Then I should see the following fund_requests:
      | Requestor  | State     |
      | First Club | tentative |
      | Last Club  | started   |
    Given I am on the unqueued fund_requests page for fund_source: "annual"
    Then I should see the following fund_requests:
      | Requestor  | State     |
    Given I am on the fund_requests page for organization: "first"
    Then I should see the following fund_requests:
      | Fund source | State     |
      | Annual      | submitted |
      | Semester    | tentative |
    When I follow "Destroy" for the 3rd fund_request
    And I am on the fund_requests page
    Then I should see the following fund_requests:
      | Fund source | Requestor  | State     |
      | Annual      | First Club | submitted |
      | Annual      | Last Club  | submitted |
      | Semester    | Last Club  | started   |
    Given I am on the duplicate fund_requests page for fund_queue: "annual"
    Then I should see the following fund_requests:
      | Requestor  | State     |

  Scenario Outline: Display unfulfilled submission requirements
    Given a framework: "focus" exists
    And a framework: "other" exists
    And a registration_criterion exists with must_register: true
    And an agreement exists with name: "Ethical Conduct Statement"
    And a requestor_role exists
    And a requirement exists with framework: framework "<o_requirement>", fulfillable: the registration_criterion
    And a requirement exists with framework: framework "<u_requirement>", fulfillable: the agreement, role: the requestor_role
    And an approver exists with framework: framework "focus", role: the requestor_role
    And a fund_source exists with name: "Annual Budget", submission_framework: framework "focus"
    And a fund_queue exists with fund_source: the fund_source
    And a fund_request_type exists
    And the fund_request_type is amongst the fund_request_types of the fund_queue
    And an organization exists with last_name: "Spending Club"
    And a fund_grant exists with organization: the organization, fund_source: the fund_source
    And an approvable_fund_request exists with fund_grant: the fund_grant
    And a user: "applicant_requestor" exists
    And a membership exists with organization: the organization, role: the requestor_role, user: user "applicant_requestor", active: true
    And I log in as user: "<user>"
    And I am on the page for the fund_request
    Then I should <unfulfilled> "Unfulfilled submission requirements"
    And I should <unfulfilled> "Certain requirements must be fulfilled before you may submit this request."
    And I should <see_o> "Spending Club:"
    And I should <see_o> "must have a current registration with an approved status"
    And I should <see_u> "You:"
    And I should <see_u> "must approve the Ethical Conduct Statement"
    Given I am on the new approval page for the approvable_fund_request
    Then I should <authorized> authorized
    Examples:
      |o_requirement|u_requirement|user               |unfulfilled|authorized|see_o  |see_u  |
      |focus        |focus        |applicant_requestor|see        |not see   |see    |see    |
      |focus        |other        |applicant_requestor|see        |not see   |see    |not see|
      |other        |focus        |applicant_requestor|see        |not see   |not see|see    |
      |other        |other        |applicant_requestor|not see    |see       |not see|not see|

