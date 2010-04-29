Feature: Manage request_mailers
  In order to alert stakeholders
  As a workflow-based request process
  I want to send out emails

  Background:
    Given a framework exists
    And a role: "president" exists with name: "president"
    And a role: "treasurer" exists with name: "treasurer"
    And a role: "commissioner" exists with name: "commissioner"
    And a permission exists with action: "update", status: "started", role: role "president", perspective: "requestor", framework: the framework
    And an approver exists with framework: the framework, role: role "president", perspective: "requestor", status: "completed"
    And an approver exists with framework: the framework, role: role "treasurer", perspective: "requestor", status: "completed"
    And an organization: "requestor" exists with last_name: "Money Taking Club"
    And an organization: "reviewer" exists with last_name: "Money Giving Club"
    And a basis exists with framework: the framework, organization: organization "reviewer", name: "Money Taking Fund"
    And a request: "first" exists with basis: the basis
    And organization: "requestor" is alone amongst the organizations of the request
    And a user: "president" exists with email: "president@example.com"
    And a user: "treasurer" exists with email: "treasurer@example.com"
    And a membership exists with organization: organization "requestor", role: role "president", user: user "president", active: true
    And a membership exists with organization: organization "requestor", role: role "treasurer", user: user "treasurer", active: true

  @wip
  Scenario: Send notice regarding a started request
    Given a started reminder email is sent for request: "first"
    Then "president@example.com" should receive an email with subject "Request of Money Taking Club from Money Taking Fund"

