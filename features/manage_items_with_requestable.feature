Feature: Manage items with requestable
  In order to calculate and track transaction requests
  As a requestor or reviewer
  I want to create, update, and show editions

  Background:
    Given a user: "admin" exists with admin: true
    And a structure: "focus" exists
    And a basis: "focus" exists with structure: structure "focus", name: "Basis"
    And an organization: "focus" exists with last_name: "Applicant"
    And a request: "focus" exists with basis: basis "focus", organization: organization "focus"

  Scenario: External equity report
    Given a node: "focus" exists with structure: structure "focus", name: "Focus", item_amount_limit: 0, requestable_type: "ExternalEquityReport"
    And I log in as user: "admin"
    And I am on the items page for request: "focus"
    When I select "Focus" from "Add New Root Item"
    And I press "Add Root Item"
    Then I should be on the new item page for request: "focus"
    And I should see "No request amount may be specified for this item."
    When I fill in "Anticipated expenses" with "0.01"
    And I fill in "Anticipated income" with "0.10"
    And I fill in "Current liabilities" with "1.0"
    And I fill in "Current assets" with "10.0"
    And I fill in "Requestor comment" with "comment"
    And I press "Create"
    Then I should see "Item was successfully created."
    And I should see " Focus of Request of Applicant from Basis"
    And I should not see "Maximum request:"
    And I should not see "Requestor amount:"
    And I should see "Requestor comment: comment"
    And I should see "Anticipated expenses: $0.01"
    And I should see "Anticipated income: $0.10"
    And I should see "Current liabilities: $1.00"
    And I should see "Current assets: $10.00"
    And I should see "Net equity: $9.09"
    When I follow "Edit"
    And I fill in "Anticipated expenses" with "0.02"
    And I fill in "Anticipated income" with "0.20"
    And I fill in "Current liabilities" with "2.0"
    And I fill in "Current assets" with "20.0"
    And I fill in "Requestor comment" with "changed comment"
    And I press "Update"
    Then I should see "Item was successfully updated."
    And I should see "Requestor comment: changed comment"
    And I should see "Anticipated expenses: $0.02"
    And I should see "Anticipated income: $0.20"
    And I should see "Current liabilities: $2.00"
    And I should see "Current assets: $20.00"
    And I should see "Net equity: $18.18"

  Scenario: Administrative expense
    Given a node: "focus" exists with structure: structure "focus", name: "Focus", requestable_type: "AdministrativeExpense"
    And I log in as user: "admin"
    And I am on the items page for request: "focus"
    When I select "Focus" from "Add New Root Item"
    And I press "Add Root Item"
    When I fill in "Number of copies" with "100"
    And I fill in "Number of buckets of chalk" with "2"
    And I fill in "Amount for advertisements" with "20"
    And I fill in "Amount for repairs and restocking" with "100"
    And I select "$25 - existing" from "Amount for mailbox at Willard Straight Hall"
    And I fill in "Requestor amount" with "100"
    And I fill in "Requestor comment" with "comment"
    And I press "Create"
    Then I should see "Item was successfully created."
    And I should see "Maximum request: $164.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Number of copies: 100"
    And I should see "Number of buckets of chalk: 2"
    And I should see "Amount for advertisements: $20.00"
    And I should see "Amount for repairs and restocking: $100.00"
    And I should see "Amount for mailbox at Willard Straight Hall: $25.00"
    And I should see "Amount for copies: $3.00"
    And I should see "Amount for buckets of chalk: $16.00"
    When I follow "Edit"
    And I fill in "Number of copies" with "101"
    And I fill in "Number of buckets of chalk" with "1"
    And I fill in "Amount for advertisements" with "10"
    And I fill in "Amount for repairs and restocking" with "99"
    And I select "$40 - new" from "Amount for mailbox at Willard Straight Hall"
    And I fill in "Requestor amount" with "120"
    And I fill in "Requestor comment" with "changed comment"
    And I press "Update"
    Then I should see "Item was successfully updated."
    And I should see "Maximum request: $160.03"
    And I should see "Requestor amount: $120.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Number of copies: 101"
    And I should see "Number of buckets of chalk: 1"
    And I should see "Amount for advertisements: $10.00"
    And I should see "Amount for repairs and restocking: $99.00"
    And I should see "Amount for mailbox at Willard Straight Hall: $40.00"
    And I should see "Amount for copies: $3.03"
    And I should see "Amount for buckets of chalk: $8.00"
    When I follow "Edit"
    And I fill in "Requestor amount" with "170"
    And I press "Update"
    Then I should not see "Item was successfully updated."

  Scenario: Durable good expense
    Given a node: "focus" exists with structure: structure "focus", name: "Focus", requestable_type: "DurableGoodExpense"
    And I log in as user: "admin"
    And I am on the items page for request: "focus"
    When I select "Focus" from "Add New Root Item"
    And I press "Add Root Item"
    Then I should see "New Focus item for Request of Applicant from Basis"
    When I fill in "Description" with "The goods"
    And I fill in "Quantity" with "50"
    And I fill in "Price" with "5"
    And I fill in "Requestor amount" with "100"
    And I fill in "Requestor comment" with "comment"
    And I press "Create"
    Then I should see "Item was successfully created."
    And I should see "Maximum request: $250.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Description: The goods"
    And I should see "Quantity: 50"
    And I should see "Price: $5.00"
    When I follow "Edit"
    Then I should see "Editing The goods"
    When I fill in "Description" with "Other goods"
    And I fill in "Quantity" with "70"
    And I fill in "Price" with "4"
    And I fill in "Requestor amount" with "120"
    And I fill in "Requestor comment" with "changed comment"
    And I press "Update"
    Then I should see "Item was successfully updated."
    And I should see "Maximum request: $280.00"
    And I should see "Requestor amount: $120.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Description: Other goods"
    And I should see "Quantity: 70"
    And I should see "Price: $4.00"
    When I follow "Edit"
    And I fill in "Requestor amount" with "350"
    And I press "Update"
    Then I should not see "Item was successfully updated."

  Scenario: Publication expense
    Given a node: "focus" exists with structure: structure "focus", name: "Focus", requestable_type: "PublicationExpense"
    And I log in as user: "admin"
    And I am on the items page for request: "focus"
    When I select "Focus" from "Add New Root Item"
    And I press "Add Root Item"
    Then I should see "New Focus item for Request of Applicant from Basis"
    When I fill in "Number of issues" with "20"
    And I fill in "Title" with "Geek newsletter"
    And I fill in "Number of copies per issue" with "10"
    And I fill in "Purchase price per copy" with "5"
    And I fill in "Cost of publication per issue" with "8"
    And I fill in "Requestor amount" with "100"
    And I fill in "Requestor comment" with "comment"
    And I press "Create"
    Then I should see "Item was successfully created."
    And I should see "Maximum request: $160.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Title: Geek newsletter"
    And I should see "Number of issues: 20"
    And I should see "Number of copies per issue: 10"
    And I should see "Purchase price per copy: $5.00"
    And I should see "Cost of publication per issue: $8.00"
    And I should see "Total copies: 200"
    And I should see "Revenue: $1,000.00"
    When I follow "Edit"
    Then I should see "Editing Geek newsletter"
    And I fill in "Title" with "Hipster newsletter"
    And I fill in "Number of issues" with "10"
    And I fill in "Number of copies per issue" with "20"
    And I fill in "Purchase price per copy of each issue" with "4"
    And I fill in "Cost of publication per issue" with "5"
    And I fill in "Requestor amount" with "50"
    And I fill in "Requestor comment" with "changed comment"
    And I press "Update"
    Then I should see "Item was successfully updated."
    And I should see "Maximum request: $50.00"
    And I should see "Requestor amount: $50.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Title: Hipster newsletter"
    And I should see "Number of issues: 10"
    And I should see "Number of copies per issue: 20"
    And I should see "Purchase price per copy: $4.00"
    And I should see "Cost of publication per issue: $5.00"
    And I should see "Total copies: 200"
    And I should see "Revenue: $800.00"
    When I follow "Edit"
    And I fill in "Requestor amount" with "150"
    And I press "Update"
    Then I should not see "Item was successfully updated."

  Scenario: Local event expense
    Given a node: "focus" exists with structure: structure "focus", name: "Focus", requestable_type: "LocalEventExpense"
    And I log in as user: "admin"
    And I am on the items page for request: "focus"
    When I select "Focus" from "Add New Root Item"
    And I press "Add Root Item"
    Then I should see "New Focus item for Request of Applicant from Basis"
    When I fill in "Date" with "2009-08-18"
    And I fill in "Title" with "Chicken BBQ"
    And I fill in "Location" with "outside"
    And I fill in "Purpose" with "eat"
    And I fill in "Anticipated number of attendees" with "100"
    And I fill in "Admission charge per attendee" with "5"
    And I fill in "Number of publicity copies" with "100"
    And I fill in "Rental equipment, services, and intellectual property use fees" with "550"
    And I choose "Yes"
    And I fill in "Requestor amount" with "50"
    And I fill in "Requestor comment" with "comment"
    And I press "Create"
    Then I should see "Item was successfully created."
    And I should see "Maximum request: $553.00"
    And I should see "Requestor amount: $50.00"
    And I should see "Requestor comment: comment"
    And I should see "Date: 2009-08-18"
    And I should see "Title: Chicken BBQ"
    And I should see "Location: outside"
    And I should see "Purpose: eat"
    And I should see "Anticipated number of attendees: 100"
    And I should see "Admission charge per attendee: $5.00"
    And I should see "Number of publicity copies: 100"
    And I should see "Rental equipment, services, and intellectual property use fees: $550.00"
    And I should see "Use of University Property form required? Yes"
    And I should see "Copies cost: $3.00"
    When I follow "Edit"
    Then I should see "Editing Chicken BBQ"
    When I fill in "Date" with "2009-08-19"
    And I fill in "Title" with "Cow Tipping"
    And I fill in "Location" with "the pasture"
    And I fill in "Purpose" with "fun"
    And I fill in "Anticipated number of attendees" with "15"
    And I fill in "Admission charge per attendee" with "2"
    And I fill in "Number of publicity copies" with "10"
    And I fill in "Rental equipment, services, and intellectual property use fees" with "51"
    And I choose "No"
    And I fill in "Requestor amount" with "20"
    And I fill in "Requestor comment" with "changed comment"
    And I press "Update"
    Then I should see "Item was successfully updated."
    And I should see "Maximum request: $51.30"
    And I should see "Requestor amount: $20.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Date: 2009-08-19"
    And I should see "Title: Cow Tipping"
    And I should see "Location: the pasture"
    And I should see "Purpose: fun"
    And I should see "Anticipated number of attendees: 15"
    And I should see "Admission charge per attendee: $2.00"
    And I should see "Number of publicity copies: 10"
    And I should see "Rental equipment, services, and intellectual property use fees: $51.00"
    And I should see "Use of University Property form required? No"
    And I should see "Copies cost: $0.30"
    When I follow "Edit"
    And I fill in "Requestor amount" with "150"
    And I press "Update"
    Then I should not see "Item was successfully updated."

