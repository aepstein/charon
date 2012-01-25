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
    And an approvable_fund_request: "started" exists with state: "started", fund_grant: the fund_grant, fund_queue: the fund_queue
    And a user: "president" exists with email: "president@example.com", first_name: "John", last_name: "Doe"
    And a user: "treasurer" exists with email: "treasurer@example.com", first_name: "Jane", last_name: "Doe"
    And a user: "officer" exists with email: "officer@example.com", first_name: "Alpha", last_name: "Beta"
    And a user: "old_president" exists with email: "old_president@example.com", first_name: "Jane", last_name: "Jacobs"
    And a membership exists with organization: organization "requestor", role: role "president", user: user "president", active: true
    And a membership exists with organization: organization "requestor", role: role "treasurer", user: user "treasurer", active: true
    And a membership exists with organization: organization "requestor", role: role "officer", user: user "officer", active: true
    And a membership exists with organization: organization "requestor", role: role "president", user: user "old_president", active: false

  Scenario: Send notice regarding a started fund_request
    Given all emails have been delivered
    And a started notice email is sent for fund_request: "started"
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

  Scenario: Send notice regarding a tentatively completed fund_request
    Given an approval exists with approvable: fund_request "started", user: user "president"
    And all emails have been delivered
    And fund_request: "started" has state: "tentative"
    And a tentative notice email is sent for fund_request: "started"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund needs your approval"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been tentatively completed, but requires further action before it will be considered submitted."
    And the email parts should contain "Jane Doe"
    And the email parts should not contain "John Doe"
    And the email parts should not contain "Alpha Beta"

  Scenario: Send notice regarding a finalized fund_request
    Given all emails have been delivered
    And fund_request: "started" has state: "finalized"
    And a finalized notice email is sent for fund_request: "started"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund is finalized, but not submitted"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that you have completed all submission requirements for your fund request for Money Taking Fund, but the request cannot be automatically submitted because it was submitted after the last posted deadline."
    And the email parts should contain "You should receive an additional notice if it is accepted for review."

  Scenario Outline: Send notice regarding a submitted fund_request
    Given a node: "doc" exists with structure: the structure
    And a document_type exists
    And the document_type is amongst the document_types of the node
    And a node: "no_doc" exists with structure: the structure
    And a fund_item exists with fund_grant: the fund_grant, node: node "<node>"
    And a fund_edition exists with fund_request: fund_request "started", fund_item: the fund_item
    And fund_request: "started" has state: "submitted"
    And an submitted notice email is sent for fund_request: "started"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund has been accepted for review"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that your fund request for Money Taking Fund has been accepted for review."
    And the email parts should contain "You will receive additional notice when a determination is released."
    And the email parts <attachment> contain "You must provide certain supporting documents in support of your fund request.  Please follow the attached instructions and checklist to assemble any required supporting documents."
    And the email <attachment> have an attachment named "money-taking-club-checklist.pdf" of type "application/pdf"
    Examples:
      | node   | attachment |
      | doc    | should     |
      | no_doc | should not |

  Scenario: Send notice regarding a rejected fund_request
    Given all emails have been delivered
    And fund_request: "started" has reject_message: "Organization is banned from applying this time."
    And fund_request: "started" has state: "rejected"
    And an rejected notice email is sent for fund_request: "started"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund has been rejected"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been rejected."
    And the email parts should contain "Organization is banned from applying this time."

  Scenario: Send notice regarding a released fund_request
    Given all emails have been delivered
    And fund_request: "started" has state: "released"
    And a released notice email is sent for fund_request: "started"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "You may now review Request of Money Taking Club from Money Taking Fund"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been processed and released for you to review."
    And the email parts should contain "A customized release message."

  Scenario: Send notice regarding a withdrawn fund_request
    Given all emails have been delivered
    And fund_request: "started" has withdrawn_by_user: user "officer", withdrawn_at: "2011-06-01 09:00:00"
    And a withdrawn notice email is sent for fund_request: "started"
    Then 0 emails should be delivered to "old_president@example.com"
    And 1 email should be delivered to "president@example.com"
    And 1 email should be delivered to "treasurer@example.com"
    And 1 email should be delivered to "officer@example.com"
    And the email subject should contain "Request of Money Taking Club from Money Taking Fund has been withdrawn"
    And the email parts should contain "Dear Officers of Money Taking Club,"
    And the email parts should contain "This email is a confirmation that your request for Money Taking Fund was withdrawn by Alpha Beta at June 1st, 2011 09:00am"

