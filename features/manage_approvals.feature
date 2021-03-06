Feature: Manage approvals
  In order to digitally sign documents
  As a duty-bound organization
  I want to create and destroy approvals

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "staff" exists with staff: true
    And a user: "regular" exists
    And a user: "owner" exists with last_name: "Focus User"

  Scenario Outline: Test permissions for approvals of agreements
    Given an agreement exists
    And an approval exists with user: user "owner", approvable: the agreement
    And I log in as user: "<user>"
    And I am on the page for the approval
    Then I should <show> authorized
    Given I am on the approvals page for the agreement
    Then I should <show> "Focus User"
    And I should <destroy> "Destroy"
    Given I am on the new approval page for the agreement
    Then I should <create> authorized
    Given I post on the approvals page for the agreement
    Then I should <create> authorized
    Given I delete on the page for the approval
    Then I should <destroy> authorized
    Examples:
      | user    | create  | destroy | show    |
      | admin   | see     | see     | see     |
      | owner   | not see | not see | see     |
      | regular | see     | not see | not see |

  Scenario Outline: Test permissions for approvals of fund_requests
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
    And a membership exists with user: user "owner", organization: organization "applicant", role: role "<owner>"
    And a fund_source exists with name: "Annual", organization: organization "source"
    And a fund_queue exists with fund_source: the fund_source
    And a fund_grant exists with fund_source: the fund_source, organization: organization "applicant"
    And an approvable_fund_request exists with fund_grant: the fund_grant
    And an approval exists with user: user "owner", approvable: the fund_request
    And the fund_request has state: "<state>", review_state: "<review_state>", fund_queue: the fund_queue
    And I log in as user: "<user>"
    And I am on the page for the approval
    Then I should <show> authorized
    Given I am on the approvals page for the fund_request
    Then I should <show> authorized
    And I should <create> "New approval"
    And I should <destroy> "Destroy"
    Given I am on the new approval page for the fund_request
    Then I should <create> authorized
    Given I post on the approvals page for the fund_request
    Then I should <create> authorized
    Given I delete on the page for the approval
    Then I should <destroy> authorized
    Examples:
      |owner    |state    |review_state|user               |create |destroy|show   |
      |requestor|started  |unreviewed  |admin              |not see|see    |see    |
      |requestor|started  |unreviewed  |staff              |not see|see    |see    |
      |requestor|started  |unreviewed  |source_manager     |not see|see    |see    |
      |requestor|started  |unreviewed  |source_reviewer    |not see|not see|see    |
      |requestor|started  |unreviewed  |applicant_requestor|see    |not see|see    |
      |requestor|started  |unreviewed  |owner              |not see|not see|see    |
      |requestor|started  |unreviewed  |observer_requestor |not see|not see|not see|
      |requestor|started  |unreviewed  |regular            |not see|not see|not see|
      |requestor|tentative|unreviewed  |admin              |not see|see    |see    |
      |requestor|tentative|unreviewed  |staff              |not see|see    |see    |
      |requestor|tentative|unreviewed  |source_manager     |not see|see    |see    |
      |requestor|tentative|unreviewed  |source_reviewer    |not see|not see|see    |
      |requestor|tentative|unreviewed  |applicant_requestor|see    |see    |see    |
      |requestor|tentative|unreviewed  |owner              |not see|see    |see    |
      |requestor|tentative|unreviewed  |observer_requestor |not see|not see|not see|
      |requestor|tentative|unreviewed  |regular            |not see|not see|not see|
      |requestor|finalized|unreviewed  |admin              |not see|see    |see    |
      |requestor|finalized|unreviewed  |staff              |not see|see    |see    |
      |requestor|finalized|unreviewed  |source_manager     |not see|see    |see    |
      |requestor|finalized|unreviewed  |source_reviewer    |not see|not see|see    |
      |requestor|finalized|unreviewed  |applicant_requestor|not see|not see|see    |
      |requestor|finalized|unreviewed  |owner              |not see|not see|see    |
      |requestor|finalized|unreviewed  |observer_requestor |not see|not see|not see|
      |requestor|finalized|unreviewed  |regular            |not see|not see|not see|
      |requestor|submitted|unreviewed  |admin              |not see|see    |see    |
      |requestor|submitted|unreviewed  |staff              |not see|see    |see    |
      |requestor|submitted|unreviewed  |source_manager     |see    |see    |see    |
      |requestor|submitted|unreviewed  |source_reviewer    |see    |not see|see    |
      |requestor|submitted|unreviewed  |applicant_requestor|not see|not see|see    |
      |requestor|submitted|unreviewed  |owner              |not see|not see|see    |
      |requestor|submitted|unreviewed  |observer_requestor |not see|not see|not see|
      |requestor|submitted|unreviewed  |regular            |not see|not see|not see|
      |requestor|submitted|tentative   |admin              |not see|see    |see    |
      |requestor|submitted|tentative   |staff              |not see|see    |see    |
      |requestor|submitted|tentative   |source_manager     |see    |see    |see    |
      |requestor|submitted|tentative   |source_reviewer    |see    |not see|see    |
      |requestor|submitted|tentative   |applicant_requestor|not see|not see|see    |
      |requestor|submitted|tentative   |owner              |not see|not see|see    |
      |requestor|submitted|tentative   |observer_requestor |not see|not see|not see|
      |requestor|submitted|tentative   |regular            |not see|not see|not see|
      |requestor|submitted|ready       |admin              |not see|see    |see    |
      |requestor|submitted|ready       |staff              |not see|see    |see    |
      |requestor|submitted|ready       |source_manager     |not see|see    |see    |
      |requestor|submitted|ready       |source_reviewer    |not see|not see|see    |
      |requestor|submitted|ready       |applicant_requestor|not see|not see|see    |
      |requestor|submitted|ready       |observer_requestor |not see|not see|not see|
      |requestor|submitted|ready       |owner              |not see|not see|see    |
      |requestor|submitted|ready       |regular            |not see|not see|not see|
      |requestor|released |ready       |admin              |not see|see    |see    |
      |requestor|released |ready       |staff              |not see|see    |see    |
      |requestor|released |ready       |source_manager     |not see|see    |see    |
      |requestor|released |ready       |source_reviewer    |not see|not see|see    |
      |requestor|released |ready       |applicant_requestor|not see|not see|see    |
      |requestor|released |ready       |owner              |not see|not see|see    |
      |requestor|released |ready       |observer_requestor |not see|not see|not see|
      |requestor|released |ready       |regular            |not see|not see|not see|
      |requestor|released |unreviewed  |admin              |not see|see    |see    |
      |requestor|released |unreviewed  |staff              |not see|see    |see    |
      |requestor|released |unreviewed  |source_manager     |see    |see    |see    |
      |requestor|released |unreviewed  |source_reviewer    |see    |not see|see    |
      |requestor|released |unreviewed  |applicant_requestor|not see|not see|see    |
      |requestor|released |unreviewed  |owner              |not see|not see|see    |
      |requestor|released |unreviewed  |observer_requestor |not see|not see|not see|
      |requestor|released |unreviewed  |regular            |not see|not see|not see|
      |requestor|released |tentative   |admin              |not see|see    |see    |
      |requestor|released |tentative   |staff              |not see|see    |see    |
      |requestor|released |tentative   |source_manager     |see    |see    |see    |
      |requestor|released |tentative   |source_reviewer    |see    |not see|see    |
      |requestor|released |tentative   |applicant_requestor|not see|not see|see    |
      |requestor|released |tentative   |owner              |not see|not see|see    |
      |requestor|released |tentative   |observer_requestor |not see|not see|not see|
      |requestor|released |tentative   |regular            |not see|not see|not see|
      |requestor|allocated|ready       |admin              |not see|see    |see    |
      |requestor|allocated|ready       |staff              |not see|see    |see    |
      |requestor|allocated|ready       |source_manager     |not see|see    |see    |
      |requestor|allocated|ready       |source_reviewer    |not see|not see|see    |
      |requestor|allocated|ready       |applicant_requestor|not see|not see|see    |
      |requestor|allocated|ready       |owner              |not see|not see|see    |
      |requestor|allocated|ready       |observer_requestor |not see|not see|not see|
      |requestor|allocated|ready       |regular            |not see|not see|not see|

  Scenario: Register new approval of an agreement
    Given an agreement exists with name: "safc"
    And I log in as user: "admin"
    And I am on the new approval page for the agreement
    Then I should see "Name: safc"
    And I should not see "You will not be permitted to make additional changes to the document once it is approved."
    Given 1 second elapses
    And the Agreement records change
    When I press "Confirm Approval"
    Then I should not see "Approval was successfully created."
    When I press "Confirm Approval"
    Then I should see "Approval was successfully created."

  Scenario: Register new approval of a fund_request
    Given a user exists
    And a requestor_role exists
    And an organization: "applicant" exists
    And a membership exists with user: the user, role: the requestor_role, organization: the organization
    And a fund_grant exists with organization: the organization
    And a fund_item exists with fund_grant: the fund_grant, title: "Important Item"
    And a fund_request exists with fund_grant: the fund_grant
    And a fund_edition exists with fund_item: the fund_item, fund_request: the fund_request, amount: "100.0"
    And I log in as the user
    And I am on the new approval page for the fund_request
    Then I should see "Important Item"
    And I should see "You will not be permitted to make additional changes to the document once it is approved."
#    And I should see "Requestor amount: $100.00"
    And I press "Confirm Approval"
    Then I should see "Approval was successfully created."

  Scenario: Delete approval
    Given an agreement exists
    And a user: "user4" exists with first_name: "John", last_name: "Doe 4"
    And a user: "user3" exists with first_name: "John", last_name: "Doe 3"
    And a user: "user2" exists with first_name: "John", last_name: "Doe 2"
    And a user: "user1" exists with first_name: "John", last_name: "Doe 1"
    And an approval exists with user: user "user4", approvable: the agreement
    And an approval exists with user: user "user3", approvable: the agreement
    And an approval exists with user: user "user2", approvable: the agreement
    And an approval exists with user: user "user1", approvable: the agreement
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd approval for the agreement
    Given I am on the approvals page for the agreement
    Then I should see the following approvals:
      | User name |
      | John Doe 1|
      | John Doe 2|
      | John Doe 4|

