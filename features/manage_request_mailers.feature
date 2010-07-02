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
    And a membership exists with organization: organization "requestor", role: role "president", user: user "president", active: true
    And a membership exists with organization: organization "requestor", role: role "treasurer", user: user "treasurer", active: true
    And a membership exists with organization: organization "requestor", role: role "officer", user: user "officer", active: true
    And an approval exists with approvable: request "completed", user: user "president"

  Scenario: Send notice regarding a started request
    Given a started reminder email is sent for request: "started"
    Then "president@example.com" should receive an email with subject "Request of Money Taking Club from Money Taking Fund needs attention"
    When "president@example.com" opens the email with subject "Request of Money Taking Club from Money Taking Fund needs attention"
    Then they should see "Dear Officers of Money Taking Club," in the email body
    And they should see "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been started, but requires further action before it will be considered submitted." in the email body
    And they should see "Jane Doe" in the email body
    And they should see "John Doe" in the email body
    And they should not see "Alpha Beta" in the email body

  Scenario: Send notice regarding a completed request
    Given a completed reminder email is sent for request: "completed"
    Then "treasurer@example.com" should receive an email with subject "Request of Money Taking Club from Money Taking Fund needs your approval"
    When "treasurer@example.com" opens the email with subject "Request of Money Taking Club from Money Taking Fund needs your approval"
    Then they should see "Dear Officers of Money Taking Club," in the email body
    And they should see "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been completed, but requires further action before it will be considered submitted." in the email body
    And they should see "Jane Doe" in the email body
    And they should not see "John Doe" in the email body
    And they should not see "Alpha Beta" in the email body

  Scenario: Send notice regarding a released request
    Given request: "completed" has status: "released"
    And a release notice email is sent for request: "completed"
    Then "president@example.com" should receive an email with subject "You may now review Request of Money Taking Club from Money Taking Fund"
    And "treasurer@example.com" should receive an email with subject "You may now review Request of Money Taking Club from Money Taking Fund"
    And "officer@example.com" should receive an email with subject "You may now review Request of Money Taking Club from Money Taking Fund"
    When "president@example.com" opens the email with subject "You may now review Request of Money Taking Club from Money Taking Fund"
    Then they should see "Dear Officers of Money Taking Club," in the email body
    And they should see "This email is to inform you that your Request of Money Taking Club from Money Taking Fund has been processed and released for you to review." in the email body
    And they should see "A customized release message." in the email body
