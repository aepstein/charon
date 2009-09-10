Feature: Manage versions
  In order to calculate and track transaction requests
  As a requestor or reviewer
  I want to create, update, and show versions

  Background:
    Given the following organizations:
      | last_name                |
      | our club                 |
      | undergraduate commission |
    And the following users:
      | net_id       | password | admin |
      | admin        | secret   | true  |
      | president    | secret   | false |
      | commissioner | secret   | false |
    And the following roles:
      | name         |
      | president    |
      | commissioner |
    And the following memberships:
      | organization             | role         | user         |
      | our club                 | president    | president    |
      | undergraduate commission | commissioner | commissioner |
    And the following structures:
      | name   |
      | budget |
    And the following nodes:
      | structure | requestable_type      | name                   |
      | budget    | AdministrativeExpense | administrative expense |
      | budget    | LocalEventExpense     | local event expense    |
      | budget    | TravelEventExpense    | travel event expense   |
      | budget    | DurableGoodExpense    | durable good expense   |
      | budget    | PublicationExpense    | publication expense    |
      | budget    | SpeakerExpense        | speaker expense        |
    And the following frameworks:
      | name      |
      | undergrad |
    And the following permissions:
      | framework | status  | role         | action     | perspective |
      | undergrad | started | president    | see        | requestor   |
      | undergrad | started | president    | create     | requestor   |
      | undergrad | started | president    | update     | requestor   |
      | undergrad | started | president    | destroy    | requestor   |
      | undergrad | started | commissioner | see        | reviewer    |
    And the following bases:
      | name              | organization             | structure | framework |
      | annual budget     | undergraduate commission | budget    | undergrad |
    And the following requests:
      | status   | organizations  | basis         |
      | started  | our club       | annual budget |
    And the following items:
      | request | node                   |
      | 1       | administrative expense |
      | 1       | durable good expense   |
      | 1       | publication expense    |
      | 1       | local event expense    |
      | 1       | travel event expense   |
      | 1       | speaker expense        |

  Scenario: Add and update version (administrative_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 1st item
    When I fill in "version_administrative_expense_attributes_copies" with "100"
    And I fill in "Number of buckets of chalk" with "2"
    And I fill in "Amount for Daily Sun Ads" with "20"
    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "100"
    And I choose "version_administrative_expense_attributes_mailbox_wsh_25"
    And I fill in "version_amount" with "100"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: AdministrativeExpense"
    And I should see "Request node: administrative expense"
    And I should see "Maximum request: $164.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Number of copies: 100"
    And I should see "Number of buckets of chalk: 2"
    And I should see "Daily Sun Ads: $20.00"
    And I should see "Repairs and Restocking: $100.00"
    And I should see "Mailbox at Willard Straight Hall: $25.00"
    When I follow "Edit"
    And I fill in "version_administrative_expense_attributes_copies" with "101"
    And I fill in "Number of buckets of chalk" with "1"
    And I fill in "Amount for Daily Sun Ads" with "10"
    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "99"
    And I choose "version_administrative_expense_attributes_mailbox_wsh_40"
    And I fill in "version_amount" with "120"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: AdministrativeExpense"
    And I should see "Request node: administrative expense"
    And I should see "Maximum request: $160.03"
    And I should see "Requestor amount: $120.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Number of copies: 101"
    And I should see "Number of buckets of chalk: 1"
    And I should see "Daily Sun Ads: $10.00"
    And I should see "Repairs and Restocking: $99.00"
    And I should see "Mailbox at Willard Straight Hall: $40.00"
    When I follow "Edit"
    And I fill in "version_amount" with "170"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version with documentation (administrative_expense)
    Given the following document_types:
      | name        | nodes                  |
      | price quote | administrative expense |
    And I am logged in as "admin" with password "secret"
    And I am on the new version page of the 1st item
    When I fill in "version_administrative_expense_attributes_copies" with "100"
    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "100"
    And I choose "version_administrative_expense_attributes_mailbox_wsh_25"
    And I fill in "version_amount" with "100"
    And I fill in "version_comment" with "comment"
    And I attach the file at "features/support/assets/small.png" to "price quote"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: AdministrativeExpense"
    And I should see "Request node: administrative expense"
    And I should see "Maximum request: $128.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Number of copies: 100"
    And I should see "Repairs and Restocking: $100.00"
    And I should see "Mailbox at Willard Straight Hall: $25.00"
    And I should see the following documents:
      | Type        |
      | price quote |
    When I follow "Edit"
    And I fill in "version_administrative_expense_attributes_copies" with "101"
    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "99"
    And I choose "version_administrative_expense_attributes_mailbox_wsh_40"
    And I fill in "version_amount" with "120"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: AdministrativeExpense"
    And I should see "Request node: administrative expense"
    And I should see "Maximum request: $142.03"
    And I should see "Requestor amount: $120.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Number of copies: 101"
    And I should see "Repairs and Restocking: $99.00"
    And I should see "Mailbox at Willard Straight Hall: $40.00"
    And I should see the following documents:
      | Type        |
      | price quote |
    When I follow "Edit"
    And I fill in "version_amount" with "150"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version (durable_good_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 2nd item
    When I fill in "version_durable_good_expense_attributes_description" with "The goods"
    And I fill in "version_durable_good_expense_attributes_quantity" with "50"
    And I fill in "version_durable_good_expense_attributes_price" with "5"
    And I fill in "version_amount" with "100"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: DurableGoodExpense"
    And I should see "Request node: durable good expense"
    And I should see "Maximum request: $250.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Description: The goods"
    And I should see "Quantity: 50"
    And I should see "Price: $5.00"
    When I follow "Edit"
    And I fill in "version_durable_good_expense_attributes_description" with "Other goods"
    And I fill in "version_durable_good_expense_attributes_quantity" with "70"
    And I fill in "version_durable_good_expense_attributes_price" with "4"
    And I fill in "version_amount" with "120"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: DurableGoodExpense"
    And I should see "Request node: durable good expense"
    And I should see "Maximum request: $280.00"
    And I should see "Requestor amount: $120.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Description: Other goods"
    And I should see "Quantity: 70"
    And I should see "Price: $4.00"
    When I follow "Edit"
    And I fill in "version_amount" with "350"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version (publication_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 3rd item
    When I fill in "Number of Issues" with "20"
    And I fill in "Title" with "Geek newsletter"
    And I fill in "Number of Copies Per Issue" with "10"
    And I fill in "Purchase Price Per Copy of Each Issue" with "5"
    And I fill in "Cost of Publication Per Issue" with "8"
    And I fill in "version_amount" with "100"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: PublicationExpense"
    And I should see "Request node: publication expense"
    And I should see "Maximum request: $160.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Title: Geek newsletter"
    And I should see "Number of issues: 20"
    And I should see "Number of copies per issue: 10"
    And I should see "Purchase price per copy: $5.00"
    And I should see "Cost of publication per issue: $8.00"
    When I follow "Edit"
    And I fill in "Title" with "Hipster newsletter"
    And I fill in "Number of Issues" with "10"
    And I fill in "Number of Copies Per Issue" with "20"
    And I fill in "Purchase Price Per Copy of Each Issue" with "4"
    And I fill in "Cost of Publication Per Issue" with "5"
    And I fill in "version_amount" with "50"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: PublicationExpense"
    And I should see "Request node: publication expense"
    And I should see "Maximum request: $50.00"
    And I should see "Requestor amount: $50.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Title: Hipster newsletter"
    And I should see "Number of issues: 10"
    And I should see "Number of copies per issue: 20"
    And I should see "Purchase price per copy: $4.00"
    And I should see "Cost of publication per issue: $5.00"
    When I follow "Edit"
    And I fill in "version_amount" with "150"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version (local_event_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 4th item
    When I fill in "Date" with "2009-08-18"
    And I fill in "Title" with "Chicken BBQ"
    And I fill in "Location" with "outside"
    And I fill in "Purpose" with "eat"
    And I fill in "Anticipated Number of Attendees" with "100"
    And I fill in "Admission Charge Per Attendee" with "5"
    And I fill in "Number of Publicity Copies" with "100"
    And I fill in "Rental Equipment, Services, and Intellectual Property Use Fees" with "550"
    And I check "Check if a Use of University Property Form will be filed for this event"
    And I fill in "version_amount" with "50"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: LocalEventExpense"
    And I should see "Request node: local event expense"
    And I should see "Maximum request: $553.00"
    And I should see "Requestor amount: $50.00"
    And I should see "Requestor comment: comment"
    And I should see "Date: 2009-08-18"
    And I should see "Title: Chicken BBQ"
    And I should see "Location: outside"
    And I should see "Purpose: eat"
    And I should see "Anticipated Number of Attendees: 100"
    And I should see "Admission Charge Per Attendee: $5.00"
    And I should see "Number of Publicity Copies: 100"
    And I should see "Rental Equipment, Services, and Intellectual Property Use Fees: $550.00"
    And I should see "Use of University Property Form required: Yes"
    When I follow "Edit"
    And I fill in "Date" with "2009-08-19"
    And I fill in "Title" with "Cow Tipping"
    And I fill in "Location" with "the pasture"
    And I fill in "Purpose" with "fun"
    And I fill in "Anticipated Number of Attendees" with "15"
    And I fill in "Admission Charge Per Attendee" with "2"
    And I fill in "Number of Publicity Copies" with "10"
    And I fill in "Rental Equipment, Services, and Intellectual Property Use Fees" with "51"
    And I uncheck "Check if a Use of University Property Form will be filed for this event"
    And I fill in "version_amount" with "20"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: LocalEventExpense"
    And I should see "Request node: local event expense"
    And I should see "Maximum request: $51.30"
    And I should see "Requestor amount: $20.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Date: 2009-08-19"
    And I should see "Title: Cow Tipping"
    And I should see "Location: the pasture"
    And I should see "Purpose: fun"
    And I should see "Anticipated Number of Attendees: 15"
    And I should see "Admission Charge Per Attendee: $2.00"
    And I should see "Number of Publicity Copies: 10"
    And I should see "Rental Equipment, Services, and Intellectual Property Use Fees: $51.00"
    And I should see "Use of University Property Form required: No"
    When I follow "Edit"
    And I fill in "version_amount" with "150"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version (travel_event_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 5th item
    When I fill in "Event Date" with "2009-08-18"
    And I fill in "Event Title" with "road trip"
    And I fill in "Event Location" with "Wisconsin"
    And I fill in "Event Purpose" with "go far away"
    And I fill in "Number of travelers per group or team" with "6"
    And I fill in "Number of groups or teams" with "3"
    And I fill in "Travel distance" with "1000"
    And I fill in "Nights of lodging" with "5"
    And I fill in "Fees per person" with "25"
    And I fill in "Fees per group or team" with "50"
    And I fill in "version_amount" with "2300"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: TravelEventExpense"
    And I should see "Request node: travel event expense"
    And I should see "Maximum request: $3,264.00"
    And I should see "Requestor amount: $2,300.00"
    And I should see "Requestor comment: comment"
    And I should see "Event Date: 2009-08-18"
    And I should see "Event Title: road trip"
    And I should see "Event Location: Wisconsin"
    And I should see "Event Purpose: go far away"
    And I should see "Number of travelers per group or team: 6"
    And I should see "Number of groups or teams: 3"
    And I should see "Travel distance: 1000 miles round trip"
    And I should see "Nights of lodging: 5"
    And I should see "Fees per person: $25.00"
    And I should see "Fees per group or team: $50.00"
    When I follow "Edit"
    And I fill in "Event Date" with "2009-09-02"
    And I fill in "Event Title" with "Albany trip"
    And I fill in "Event Location" with "Albany"
    And I fill in "Event Purpose" with "say hi to the governor"
    And I fill in "Number of travelers per group or team" with "4"
    And I fill in "Number of groups or teams" with "5"
    And I fill in "Travel distance" with "200"
    And I fill in "Nights of lodging" with "2"
    And I fill in "Fees per person" with "30"
    And I fill in "Fees per group or team" with "40"
    And I fill in "version_amount" with "1200"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: TravelEventExpense"
    And I should see "Request node: travel event expense"
    And I should see "Maximum request: $1,692.00"
    And I should see "Requestor amount: $1,200.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Event Date: 2009-09-02"
    And I should see "Event Title: Albany trip"
    And I should see "Event Location: Albany"
    And I should see "Event Purpose: say hi to the governor"
    And I should see "Number of travelers per group or team: 4"
    And I should see "Number of groups or teams: 5"
    And I should see "Travel distance: 200 miles round trip"
    And I should see "Nights of lodging: 2"
    And I should see "Fees per person: $30.00"
    And I should see "Fees per group or team: $40.00"
    When I follow "Edit"
    And I fill in "version_amount" with "1700"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version (speaker_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 6th item
    When I fill in "Name of Speaker, Performer, or Group" with "Bob"
    And I fill in "Travel distance" with "300"
    And I fill in "Number of travelers" with "1"
    And I fill in "Nights of lodging" with "2"
    And I fill in "Engagement fee" with "100"
    And I check "Check here if visitor is a dignitary"
    And I fill in "version_amount" with "400"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: SpeakerExpense"
    And I should see "Request node: speaker expense"
    And I should see "Maximum request: $485.50"
    And I should see "Requestor amount: $400.00"
    And I should see "Requestor comment: comment"
    And I should see "Name of Speaker, Performer, or Group: Bob"
    And I should see "Travel distance: 300 miles round trip"
    And I should see "Number of travelers: 1"
    And I should see "Nights of lodging: 2"
    And I should see "Engagement fee: $100.00"
    And I should see "Dignitary: Yes"
    When I follow "Edit"
    And I fill in "Name of Speaker, Performer, or Group" with "Jim"
    And I fill in "Travel distance" with "100"
    And I fill in "Number of travelers" with "3"
    And I fill in "Nights of lodging" with "1"
    And I fill in "Engagement fee" with "200"
    And I fill in "version_amount" with "500"
    And I fill in "version_comment" with "changed comment"
    And I uncheck "Check here if visitor is a dignitary"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: SpeakerExpense"
    And I should see "Request node: speaker expense"
    And I should see "Maximum request: $690.50"
    And I should see "Requestor amount: $500.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Name of Speaker, Performer, or Group: Jim"
    And I should see "Travel distance: 100 miles round trip"
    And I should see "Number of travelers: 3"
    And I should see "Nights of lodging: 1"
    And I should see "Engagement fee: $200.00"
    And I should see "Dignitary: No"
    When I follow "Edit"
    And I fill in "version_amount" with "1500"
    And I press "Update"
    Then I should not see "Version was successfully updated."

