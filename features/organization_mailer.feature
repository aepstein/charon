Feature: Organization mailer
  In order to alert organizations
  As a workflow-based process
  I want to send emails

  Background:
    Given an organization exists with first_name: "The", last_name: "Mutual Admiration Society"
    And a registration: "last" exists with organization: the organization
    And the organization has last_current_registration: the registration
    And a requestor_role exists
    And a reviewer_role exists
    And a user: "recipient" exists with email: "recipient@example.com"
    And a membership exists with registration: the registration, active: false, role: the requestor_role, user: user "recipient"
    And a user: "reviewer" exists with email: "reviewer@example.com"
    And a membership exists with organization: the organization, active: true, role: the reviewer_role, user: user "reviewer"
    And a registration: "ancient" exists
    And a user: "ancient" exists with email: "ancient@example.com"
    And a membership exists with registration: the registration, active: false, role: the requestor_role, user: user "ancient"

  Scenario: Send registration_required notice
    Given all emails have been delivered
    And a registration required notice email is sent for the organization
    Then 0 emails should be delivered to "reviewer@example.com"
    And 0 emails should be delivered to "ancient@example.com"
    And 1 email should be delivered to "recipient@example.com"
    And the last email subject should contain "Current registration required for The Mutual Admiration Society"
    And the email parts should contain "Dear recent officers of The Mutual Admiration Society"
    And the email parts should contain "You are receiving this message because important information is available for The Mutual Admiration Society, but cannot be released until the organization is registered.  You can register the organization here:"
    And the email parts should contain "Best regards,"
    And the email parts should contain "Office of the Assemblies"

