Feature: Fund grant mailers
  In order to alert recipients of allocated funds
  As a workflow-based fund_request process
  I want to send out emails

  Background:
    Given a framework exists
    And a role: "president" exists with name: "president"
    And a role: "treasurer" exists with name: "treasurer"
    And a role: "officer" exists with name: "officer"
    And a role: "commissioner" exists with name: "commissioner"
    And an approver exists with framework: the framework, role: role "president", perspective: "requestor"
    And an approver exists with framework: the framework, role: role "treasurer", perspective: "requestor"
    And an organization: "requestor" exists with last_name: "Money Taking Club"
    And an organization: "reviewer" exists with last_name: "Money Giving Club"
    And a structure exists
    And a fund_source exists with structure: the structure, framework: the framework, organization: organization "reviewer", name: "Money Taking Fund", release_message: "A customized release message."
    And a fund_queue exists with fund_source: the fund_source
    And a fund_request_type: "unrestricted" exists with name: "Unrestricted"
    And the fund_request_type is amongst the fund_request_types of the fund_queue
    And a fund_grant exists with fund_source: the fund_source, organization: organization "requestor"
    And a user: "president" exists with email: "president@example.com", first_name: "John", last_name: "Doe"
    And a user: "treasurer" exists with email: "treasurer@example.com", first_name: "Jane", last_name: "Doe"
    And a user: "officer" exists with email: "officer@example.com", first_name: "Alpha", last_name: "Beta"
    And a user: "old_president" exists with email: "old_president@example.com", first_name: "Jane", last_name: "Jacobs"
    And a membership exists with organization: organization "requestor", role: role "president", user: user "president", active: true
    And a membership exists with organization: organization "requestor", role: role "treasurer", user: user "treasurer", active: true
    And a membership exists with organization: organization "requestor", role: role "officer", user: user "officer", active: true
    And a membership exists with organization: organization "requestor", role: role "president", user: user "old_president", active: false

  Scenario: Send notice regarding a released fund_grant
    Given all emails have been delivered
    And a release notice email is sent for the fund_grant
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Fund grant to Money Taking Club from Money Taking Fund"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that the Fund grant to Money Taking Club from Money Taking Fund has been released for your review."
    And the email parts should contain "A customized release message."

