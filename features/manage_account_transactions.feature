Feature: Manage account transactions
  In order to track debits and credits to activity accounts
  As a member of the managing or receiving organization
  I want to manage account transactions

Background:
  Given a user: "admin" exists with admin: true
@todo
Scenario:
  Given a category: "administrative" exists with name: "Administrative"
  And a category: "travel" exists with name: "Travel"
  And a category: "social" exists with name: "Social"
  And a category: "expense" exists with name: "Expense"
  And an organization: "grantor" exists with last_name: "Grantor"
  And a fund_source: "budget" exists with name: "Annual Budget", organization: organization "grantor"
  And an organization: "recipient" exists with last_name: "Recipient"
  And fund_grant exists with fund_source: fund_source "budget", organization: organization "recipient"
#  And a university_account: "recipient" exists with organization: organization "recipient"
  And an activity_account: "administrative" exists with category: category "administrative", fund_grant: the fund_grant
  And an activity_account: "travel" exists with category: category "travel", fund_grant: the fund_grant
  And an activity_account: "social" exists with category: category "social", fund_grant: the fund_grant
  When I log in as user: "admin"
#  And I am on the new account_transaction page for activity_account: activity_account "administrative"
#  And I fill in "Amount" with "100"
#  And I follow "add adjustment"

