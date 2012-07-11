Feature: Approval mailer
  In order to alert users
  As a workflow-based process
  I want to send notices when approvals are created or destroyed

  Background:
    Given a user exists with first_name: "John", last_name: "Doe", email: "approver@example.com"

  Scenario: Send approval_notice regarding an agreement
    Given an agreement exists with name: "Key Agreement"
    And an approval exists with approvable: the agreement, user: the user
    Then 1 email should be delivered to "approver@example.com"
    And the last email subject should contain "Confirmation of your approval for Key Agreement"
    And the email parts should not contain "With your approval, the request is locked so no additional changes will be permitted."

  Scenario Outline: Send approval_notice regarding a request
    Given an organization exists with last_name: "Money Takers"
    And a requestor_role exists
    And a membership exists with user: the user, organization: the organization, role: the requestor_role
    And a fund_source exists with name: "Money Givers"
    And a fund_grant exists with fund_source: the fund_source, organization: the organization
    And an approvable_fund_request exists with fund_grant: the fund_grant, state: "<state>"
    And an approval exists with approvable: the approvable_fund_request, user: the user
    Then <quantity> emails should be delivered to "approver@example.com"
    And the last email subject should contain "Confirmation of your approval for Request of Money Takers from Money Givers"
    And the email parts should contain "With your approval, the request is locked so no additional changes will be permitted."
    And the email parts <unlockable> contain "At this time, you still have an opportunity to remove your approval."
    Examples:
      | state     | quantity | unlockable |
      | started   | 2        | should     |
      | tentative | 3        | should not |

  Scenario: Send unapproval_notice regarding an agreement
    Given an agreement exists with name: "Key Agreement"
    And an approval exists with approvable: the agreement, user: the user
    And all emails have been delivered
    And the approval is destroyed
    Then 1 email should be delivered to "approver@example.com"
    And the last email subject should contain "Your approval for Key Agreement has been removed"
    And the email parts should contain "This email is a notice that your approval was removed for Key Agreement."

