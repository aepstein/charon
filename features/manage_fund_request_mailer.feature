Feature: Manage fund_request mailers
  In order to alert stakeholders
  As a workflow-based fund_request process
  I want to send out emails

  Background:
    Given a framework exists
    And a role: "president" exists with name: "president"
    And a role: "treasurer" exists with name: "treasurer"
    And a role: "officer" exists with name: "officer"
    And a role: "commissioner" exists with name: "commissioner"
    And an approver exists with framework: the framework, role: role "president", perspective: "fund_requestor", status: "completed"
    And an approver exists with framework: the framework, role: role "treasurer", perspective: "fund_requestor", status: "completed"
    And an organization: "fund_requestor" exists with last_name: "Money Taking Club"
    And an organization: "reviewer" exists with last_name: "Money Giving Club"
    And a fund_source exists with framework: the framework, organization: organization "reviewer", name: "Money Taking Fund", release_message: "A customized release message."
    And a fund_request: "started" exists with fund_source: the fund_source, organization: organization "fund_requestor"
    And a fund_request: "completed" exists with fund_source: the fund_source, status: "completed", organization: organization "fund_requestor"
    And a user: "president" exists with email: "president@example.com", first_name: "John", last_name: "Doe"
    And a user: "treasurer" exists with email: "treasurer@example.com", first_name: "Jane", last_name: "Doe"
    And a user: "officer" exists with email: "officer@example.com", first_name: "Alpha", last_name: "Beta"
    And a user: "old_president" exists with email: "old_president@example.com", first_name: "Jane", last_name: "Jacobs"
    And a membership exists with organization: organization "fund_requestor", role: role "president", user: user "president", active: true
    And a membership exists with organization: organization "fund_requestor", role: role "treasurer", user: user "treasurer", active: true
    And a membership exists with organization: organization "fund_requestor", role: role "officer", user: user "officer", active: true
    And a membership exists with organization: organization "fund_requestor", role: role "president", user: user "old_president", active: false
    And an approval exists with approvable: fund_request "completed", user: user "president"

  Scenario: Send notice regarding a started fund_request
    Given all emails have been delivered
    And a started notice email is sent for fund_request: "started"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the last email subject should contain "FundRequest of Money Taking Club from Money Taking Fund needs attention"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your FundRequest of Money Taking Club from Money Taking Fund has been started, but requires further action before it will be considered submitted."
    And the email parts should contain "Jane Doe"
    And the email parts should contain "John Doe"
    And the email parts should not contain "Alpha Beta"

  Scenario: Send notice regarding a completed fund_request
    Given all emails have been delivered
    And a completed notice email is sent for fund_request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And the email subject should contain "FundRequest of Money Taking Club from Money Taking Fund needs your approval"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your FundRequest of Money Taking Club from Money Taking Fund has been completed, but requires further action before it will be considered submitted."
    And the email parts should contain "Jane Doe"
    And the email parts should not contain "John Doe"
    And the email parts should not contain "Alpha Beta"

  Scenario: Send notice regarding a submitted fund_request
    Given all emails have been delivered
    And fund_request: "completed" has status: "submitted"
    And a submitted notice email is sent for fund_request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "FundRequest of Money Taking Club from Money Taking Fund has been submitted"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that you have successfully submitted your fund_request for Money Taking Fund."
    And the email parts should contain "You should receive an additional notice when it is accepted for review."

  Scenario: Send notice regarding an accepted fund_request
    Given all emails have been delivered
    And fund_request: "completed" has status: "accepted"
    And an accepted notice email is sent for fund_request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "FundRequest of Money Taking Club from Money Taking Fund has been accepted for review"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that your fund_request for Money Taking Fund has been accepted for review."
    And the email parts should contain "You will receive additional notice when a determination is released."

  Scenario: Send notice regarding a rejected fund_request
    Given all emails have been delivered
    And fund_request: "completed" has reject_message: "Organization is banned from applying this time."
    And an rejected notice email is sent for fund_request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "FundRequest of Money Taking Club from Money Taking Fund has been rejected"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your FundRequest of Money Taking Club from Money Taking Fund has been rejected."
    And the email parts should contain "Organization is banned from applying this time."

  Scenario: Send notice regarding a released fund_request
    Given all emails have been delivered
    And fund_request: "completed" has status: "released"
    And a released notice email is sent for fund_request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "You may now review FundRequest of Money Taking Club from Money Taking Fund"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your FundRequest of Money Taking Club from Money Taking Fund has been processed and released for you to review."
    And the email parts should contain "A customized release message."

  Scenario: Send notice regarding a withdrawn fund_request
    Given all emails have been delivered
    And fund_request: "completed" has withdrawn_by_user: user "officer", withdrawn_at: "2011-06-01 09:00:00"
    And a withdrawn notice email is sent for fund_request: "completed"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "FundRequest of Money Taking Club from Money Taking Fund has been withdrawn"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that your fund_request for Money Taking Fund was withdrawn by Alpha Beta at June 1st, 2011 09:00am"
