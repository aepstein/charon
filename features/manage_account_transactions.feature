Feature: Manage account transactions
  In order to track debits and credits to activity accounts
  As a member of the managing or receiving organization
  I want to manage account transactions

Background:
  Given a user: "admin" exists with admin: true

Scenario:
  Given a category: "administrative" exists with name: "Administrative"
  And a category: "travel" exists with name: "Travel"
  And a category: "social" exists with name: "Social"
  And a category: "expense" exists with name: "Expense"
  And an organization: "grantor" exists with name: "Grantor"
  And a basis: "budget" exists with name: "Annual Budget", organization: organization "grantor"
  And an organization: "recipient" exists with last_name: "Recipient"
  And a university_account: "recipient" exists with owner: "recipient"
  And an activity_account: "administrative" exists with category: category "administrative", university_account: "recipient"
  And an activity_account: "travel" exists with category: category "travel", university_account: "recipient"
  And an activity_account: "social" exists with category: category "social", university_account: "recipient"
  When I log in as user: "admin"
  And I am on the new account_transaction page for activity_account: "administrative"
  And I fill in "Amount" with "100"
  And I click "add adjustment"
  And I

