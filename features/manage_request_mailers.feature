Feature: Manage request mailers
  In order to alert stakeholders
  As a workflow-based request process
  I want to send out emails

  Background:
    Given a framework exists
    And a role: "president" exists with name: "president"
    And a role: "treasurer" exists with name: "treasurer"
    And a role: "officer" exists with name: "officer"
    And a role: "commissioner" exists with name: "commissioner"
    And an approver exists with framework: the framework, role: role "president", perspective: "requestor", status: "completed"
    And an approver exists with framework: the framework, role: role "treasurer", perspective: "requestor", status: "completed"
    And an organization: "requestor" exists with last_name: "Money Taking Club"
    And an organization: "reviewer" exists with last_name: "Money Giving Club"
    And a basis exists with framework: the framework, organization: organization "reviewer", name: "Money Taking Fund", release_message: "A customized release message."
    And a request: "started" exists with basis: the basis, organization: organization "requestor"
    And a request: "completed" exists with basis: the basis, status: "completed", organization: organization "requestor"
    And a user: "president" exists with email: "president@example.com", first_name: "John", last_name: "Doe"
    And a user: "treasurer" exists with email: "treasurer@example.com", first_name: "Jane", last_name: "Doe"
    And a user: "officer" exists with email: "officer@example.com", first_name: "Alpha", last_name: "Beta"
    And a user: "old_president" exists with email: "old_president@example.com", first_name: "Jane", last_name: "Jacobs"
    And a membership exists with organization: organization "requestor", role: role "president", user: user "president", active: true
    And a membership exists with organization: organization "requestor", role: role "treasurer", user: user "treasurer", active: true
    And a membership exists with organization: organization "requestor", role: role "officer", user: user "officer", active: true
    And a membership exists with organization: organization "requestor", role: role "president", user: user "old_president", active: false
    And an approval exists with approvable: request "completed", user: user "president"

  Scenario: Send notice regarding a started request
    Given all emails have been delivered
    And a started notice email is sent for request: "started"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the last email subject should contain "Request of Money Taking Club from Money Taking Fund needs attention"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been started, but requires further action before it will be considered submitted."
    And the email parts should contain "Jane Doe"
    And the email parts should contain "John Doe"
    And the email parts should not contain "Alpha Beta"

  Scenario: Send notice regarding a completed request
    Given all emails have been delivered
    And a completed notice email is sent for request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund needs your approval"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been completed, but requires further action before it will be considered submitted."
    And the email parts should contain "Jane Doe"
    And the email parts should not contain "John Doe"
    And the email parts should not contain "Alpha Beta"

  Scenario: Send notice regarding a submitted request
    Given all emails have been delivered
    And request: "completed" has status: "submitted"
    And a submitted notice email is sent for request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund has been submitted"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that you have successfully submitted your request for Money Taking Fund."
    And the email parts should contain "You should receive an additional notice when it is accepted for review."

  Scenario: Send notice regarding an accepted request
    Given all emails have been delivered
    And request: "completed" has status: "accepted"
    And an accepted notice email is sent for request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund has been accepted for review"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that your request for Money Taking Fund has been accepted for review."
    And the email parts should contain "You will receive additional notice when a determination is released."

  Scenario: Send notice regarding a rejected request
    Given all emails have been delivered
    And request: "completed" has reject_message: "Organization is banned from applying this time."
    And an rejected notice email is sent for request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund has been rejected"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been rejected."
    And the email parts should contain "Organization is banned from applying this time."

  Scenario: Send notice regarding a released request
    Given all emails have been delivered
    And request: "completed" has status: "released"
    And a released notice email is sent for request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "You may now review Request of Money Taking Club from Money Taking Fund"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been processed and released for you to review."
    And the email parts should contain "A customized release message."
@wip
  Scenario: Send notice regarding a withdrawn request
    Given all emails have been delivered
    And request: "completed" has status: "submitted"
    And a submitted notice email is sent for request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund has been submitted"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that you have successfully submitted your request for Money Taking Fund."
    And the email parts should contain "You should receive an additional notice when it is accepted for review."

