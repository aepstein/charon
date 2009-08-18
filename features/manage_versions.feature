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
    And I fill in "version_administrative_expense_attributes_repairs_restocking" with "100"
    And I choose "version_administrative_expense_attributes_mailbox_wsh_25"
    And I fill in "version_amount" with "100"
    And I fill in "version_comment" with "comment"
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
    When I follow "Edit"
    And I fill in "version_amount" with "150"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  @current
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
    When I fill in "version_publication_expense_attributes_no_of_issues" with "20"
    And I fill in "version_publication_expense_attributes_no_of_copies_per_issue" with "10"
    And I fill in "version_publication_expense_attributes_purchase_price" with "5"
    And I fill in "version_publication_expense_attributes_cost_publication" with "8"
    And I fill in "version_amount" with "100"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: PublicationExpense"
    And I should see "Request node: publication expense"
    And I should see "Maximum request: $160.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Number of issues: 20"
    And I should see "Number of copies per issue: 10"
    And I should see "Purchase price: $5.00"
    And I should see "Cost of publication: $8.00"
    When I follow "Edit"
    And I fill in "version_publication_expense_attributes_no_of_issues" with "10"
    And I fill in "version_publication_expense_attributes_no_of_copies_per_issue" with "20"
    And I fill in "version_publication_expense_attributes_purchase_price" with "4"
    And I fill in "version_publication_expense_attributes_cost_publication" with "5"
    And I fill in "version_amount" with "50"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: PublicationExpense"
    And I should see "Request node: publication expense"
    And I should see "Maximum request: $50.00"
    And I should see "Requestor amount: $50.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Number of issues: 10"
    And I should see "Number of copies per issue: 20"
    And I should see "Purchase price: $4.00"
    And I should see "Cost of publication: $5.00"
    When I follow "Edit"
    And I fill in "version_amount" with "150"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version (local_event_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 4th item
    When I fill in "version_local_event_expense_attributes_date_of_event" with "2009-08-18"
    And I fill in "version_local_event_expense_attributes_title_of_event" with "Chicken BBQ"
    And I fill in "version_local_event_expense_attributes_location_of_event" with "outside"
    And I fill in "version_local_event_expense_attributes_purpose_of_event" with "eat"
    And I fill in "version_local_event_expense_attributes_anticipated_no_of_attendees" with "100"
    And I fill in "version_local_event_expense_attributes_admission_charge_per_attendee" with "5"
    And I fill in "version_local_event_expense_attributes_number_of_publicity_copies" with "100"
    And I fill in "version_local_event_expense_attributes_rental_equipment_services" with "500"
    And I fill in "version_local_event_expense_attributes_copyright_fees" with "50"
    And I fill in "version_amount" with "50"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: LocalEventExpense"
    And I should see "Request node: local event expense"
    And I should see "Maximum request: $53.00"
    And I should see "Requestor amount: $50.00"
    And I should see "Requestor comment: comment"
    And I should see "Date of Event: 2009-08-18"
    And I should see "Title of Event: Chicken BBQ"
    And I should see "Location of Event: outside"
    And I should see "Purpose of Event: eat"
    And I should see "Anticipated Number of Attendees: 100"
    And I should see "Admission Charge Per Attendee: $5.00"
    And I should see "Number of Publicity Copies: 100"
    And I should see "Rental Equipment and Services: $500.00"
    And I should see "Copyright Fees: $50.00"
    When I follow "Edit"
    And I fill in "version_local_event_expense_attributes_date_of_event" with "2009-08-19"
    And I fill in "version_local_event_expense_attributes_title_of_event" with "Cow Tipping"
    And I fill in "version_local_event_expense_attributes_location_of_event" with "the pasture"
    And I fill in "version_local_event_expense_attributes_purpose_of_event" with "fun"
    And I fill in "version_local_event_expense_attributes_anticipated_no_of_attendees" with "15"
    And I fill in "version_local_event_expense_attributes_admission_charge_per_attendee" with "2"
    And I fill in "version_local_event_expense_attributes_number_of_publicity_copies" with "10"
    And I fill in "version_local_event_expense_attributes_rental_equipment_services" with "50"
    And I fill in "version_local_event_expense_attributes_copyright_fees" with "1"
    And I fill in "version_amount" with "20"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: LocalEventExpense"
    And I should see "Request node: local event expense"
    And I should see "Maximum request: $21.30"
    And I should see "Requestor amount: $20.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Date of Event: 2009-08-19"
    And I should see "Title of Event: Cow Tipping"
    And I should see "Location of Event: the pasture"
    And I should see "Purpose of Event: fun"
    And I should see "Anticipated Number of Attendees: 15"
    And I should see "Admission Charge Per Attendee: $2.00"
    And I should see "Number of Publicity Copies: 10"
    And I should see "Rental Equipment and Services: $50.00"
    And I should see "Copyright Fees: $1.00"
    When I follow "Edit"
    And I fill in "version_amount" with "150"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version (travel_event_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 5th item
    When I fill in "version_travel_event_expense_attributes_event_date" with "2009-08-18"
    And I fill in "version_travel_event_expense_attributes_event_title" with "road trip"
    And I fill in "version_travel_event_expense_attributes_event_location" with "Wisconsin"
    And I fill in "version_travel_event_expense_attributes_event_purpose" with "go far away"
    And I fill in "version_travel_event_expense_attributes_members_per_group" with "6"
    And I fill in "version_travel_event_expense_attributes_number_of_groups" with "3"
    And I fill in "version_travel_event_expense_attributes_mileage" with "1000"
    And I fill in "version_travel_event_expense_attributes_nights_of_lodging" with "5"
    And I fill in "version_travel_event_expense_attributes_per_person_fees" with "25"
    And I fill in "version_travel_event_expense_attributes_per_group_fees" with "50"
    And I fill in "version_amount" with "2300"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: TravelEventExpense"
    And I should see "Request node: travel event expense"
    And I should see "Maximum request: $2,400.00"
    And I should see "Requestor amount: $2,300.00"
    And I should see "Requestor comment: comment"
    And I should see "Date of Event: 2009-08-18"
    And I should see "Title of Event: road trip"
    And I should see "Location of Event: Wisconsin"
    And I should see "Purpose of Event: go far away"
    And I should see "Number of members per group or team: 6"
    And I should see "Number of groups or teams participating: 3"
    And I should see "Total travel mileage: 1000"
    And I should see "Nights of lodging required: 5"
    And I should see "Fees per person: $25.00"
    And I should see "Fees per group or team: $50.00"
    When I follow "Edit"
    And I fill in "version_travel_event_expense_attributes_event_date" with "2009-09-02"
    And I fill in "version_travel_event_expense_attributes_event_title" with "Albany trip"
    And I fill in "version_travel_event_expense_attributes_event_location" with "Albany"
    And I fill in "version_travel_event_expense_attributes_event_purpose" with "say hi to the governor"
    And I fill in "version_travel_event_expense_attributes_members_per_group" with "4"
    And I fill in "version_travel_event_expense_attributes_number_of_groups" with "5"
    And I fill in "version_travel_event_expense_attributes_mileage" with "200"
    And I fill in "version_travel_event_expense_attributes_nights_of_lodging" with "2"
    And I fill in "version_travel_event_expense_attributes_per_person_fees" with "30"
    And I fill in "version_travel_event_expense_attributes_per_group_fees" with "40"
    And I fill in "version_amount" with "1200"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: TravelEventExpense"
    And I should see "Request node: travel event expense"
    And I should see "Maximum request: $1,400.00"
    And I should see "Requestor amount: $1,200.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Date of Event: 2009-09-02"
    And I should see "Title of Event: Albany trip"
    And I should see "Location of Event: Albany"
    And I should see "Purpose of Event: say hi to the governor"
    And I should see "Number of members per group or team: 4"
    And I should see "Number of groups or teams participating: 5"
    And I should see "Total travel mileage: 200"
    And I should see "Nights of lodging required: 2"
    And I should see "Fees per person: $30.00"
    And I should see "Fees per group or team: $40.00"
    When I follow "Edit"
    And I fill in "version_amount" with "1500"
    And I press "Update"
    Then I should not see "Version was successfully updated."

  Scenario: Add and update version (speaker_expense)
    Given I am logged in as "admin" with password "secret"
    And I am on the new version page of the 6th item
    When I fill in "version_speaker_expense_attributes_speaker_name" with "Bob"
    And I fill in "version_speaker_expense_attributes_performance_date" with "2009-09-02"
    And I fill in "version_speaker_expense_attributes_mileage" with "300"
    And I fill in "version_speaker_expense_attributes_number_of_speakers" with "1"
    And I fill in "version_speaker_expense_attributes_nights_of_lodging" with "2"
    And I fill in "version_speaker_expense_attributes_engagement_fee" with "100"
    And I fill in "version_speaker_expense_attributes_car_rental" with "150"
    And I fill in "version_amount" with "600"
    And I fill in "version_comment" with "comment"
    And I press "Create"
    Then I should see "Version was successfully created."
    And I should see "Requestable type: SpeakerExpense"
    And I should see "Request node: speaker expense"
    And I should see "Maximum request: $635.50"
    And I should see "Requestor amount: $600.00"
    And I should see "Requestor comment: comment"
    And I should see "Name of Speaker, Performer, or Group: Bob"
    And I should see "Date of performance: 2009-09-02"
    And I should see "Travel mileage: 300"
    And I should see "Number of speakers or performers traveling: 1"
    And I should see "Nights of lodging required: 2"
    And I should see "Engagement fee for speakers or performers: $100.00"
    And I should see "Car rental: $150.00"
    When I follow "Edit"
    And I fill in "version_speaker_expense_attributes_speaker_name" with "Jim"
    And I fill in "version_speaker_expense_attributes_performance_date" with "2010-01-01"
    And I fill in "version_speaker_expense_attributes_mileage" with "100"
    And I fill in "version_speaker_expense_attributes_number_of_speakers" with "3"
    And I fill in "version_speaker_expense_attributes_nights_of_lodging" with "1"
    And I fill in "version_speaker_expense_attributes_engagement_fee" with "200"
    And I fill in "version_speaker_expense_attributes_car_rental" with "400"
    And I fill in "version_amount" with "1000"
    And I fill in "version_comment" with "changed comment"
    And I press "Update"
    Then I should see "Version was successfully updated."
    And I should see "Requestable type: SpeakerExpense"
    And I should see "Request node: speaker expense"
    And I should see "Maximum request: $1,110.50"
    And I should see "Requestor amount: $1,000.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Name of Speaker, Performer, or Group: Jim"
    And I should see "Date of performance: 2010-01-01"
    And I should see "Travel mileage: 100"
    And I should see "Number of speakers or performers traveling: 3"
    And I should see "Nights of lodging required: 1"
    And I should see "Engagement fee for speakers or performers: $200.00"
    And I should see "Car rental: $400.00"
    When I follow "Edit"
    And I fill in "version_amount" with "1500"
    And I press "Update"
    Then I should not see "Version was successfully updated."

