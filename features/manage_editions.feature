Feature: Manage editions
  In order to calculate and track transaction requests
  As a requestor or reviewer
  I want to create, update, and show editions

  Background:
    Given an organization: "club" exists with last_name: "our club"
    And an organization: "commission" exists with last_name: "undergraduate commission"
    And a user: "admin" exists with net_id: "admin", password: "secret", admin: true
    And a user: "president" exists with net_id: "president", password: "secret", admin: false
    And a user: "commissioner" exists with net_id: "commissioner", password: "secret", admin: false
    And a user: "regular" exists with net_id: "regular", password: "secret", admin: false
    And a role: "president" exists with name: "president"
    And a role: "commissioner" exists with name: "commissioner"
    And a membership exists with organization: organization "club", role: role "president", user: user "president"
    And a membership exists with organization: organization "commission", role: role "commissioner", user: user "commissioner"
    And a structure: "annual" exists with name: "budget"
    And a node: "generic" exists with structure: structure "annual", name: "generic expense"
    And a node: "external" exists with structure: structure "annual", requestable_type: "ExternalEquityReport", name: "external equity report", item_amount_limit: 0.0
    And a node: "administrative" exists with structure: structure "annual", requestable_type: "AdministrativeExpense", name: "administrative expense"
    And a node: "local" exists with structure: structure "annual", requestable_type: "LocalEventExpense", name: "local event expense"
    And a node: "travel" exists with structure: structure "annual", requestable_type: "TravelEventExpense", name: "travel event expense"
    And a node: "durable" exists with structure: structure "annual", requestable_type: "DurableGoodExpense", name: "durable good expense"
    And a node: "publication" exists with structure: structure "annual", requestable_type: "PublicationExpense", name: "publication expense"
    And a node: "speaker" exists with structure: structure "annual", requestable_type: "SpeakerExpense", name: "speaker expense"
    And a framework: "safc" exists with name: "undergrad"
    And a permission exists with framework: framework "safc", status: "started", role: role "president", action: "see", perspective: "requestor"
    And a permission exists with framework: framework "safc", status: "started", role: role "president", action: "create", perspective: "requestor"
    And a permission exists with framework: framework "safc", status: "started", role: role "president", action: "update", perspective: "requestor"
    And a permission exists with framework: framework "safc", status: "started", role: role "president", action: "destroy", perspective: "requestor"
    And a permission exists with framework: framework "safc", status: "started", role: role "commissioner", action: "see", perspective: "reviewer"
    And a basis: "annual_safc" exists with name: "annual budget", structure: structure "annual", framework: framework "safc", organization: organization "commission"
    And a request exists with status: "started", basis: basis "annual_safc"
    And organization: "club" is amongst the organizations of the request

  Scenario Outline: Test permissions for editions controller actions
    Given an item: "administrative" exists with request: the request, node: node "administrative"
    And an item: "local" exists with request: the request, node: node "local"
    And an edition: "basic" exists with item: item "administrative"
    And an administrative_expense exists with edition: edition "basic"
    And I am logged in as "<user>" with password "secret"
    And I am on the new edition page for item: "local"
    Then I should <create>
    Given I post on the editions page for item: "local"
    Then I should <create>
    And I am on the edit page for the edition
    Then I should <update>
    Given I put on the page for the edition
    Then I should <update>
    Given I am on the page for the edition
    Then I should <show>
    Given I delete on the page for the edition
    Then I should <destroy>
    Examples:
      | user        | create                 | update                 | destroy                | show                   |
      | admin       | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | president   | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" | not see "Unauthorized" |
      | commissioner| see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | not see "Unauthorized" |
      | regular     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     | see "Unauthorized"     |

  Scenario: Add and update edition (external_equity_report)
    Given an item exists with request: the request, node: node "external"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
    Then I should see "No request amount may be specified for this item."
    When I fill in "Anticipated expenses" with "0.01"
    And I fill in "Anticipated income" with "0.10"
    And I fill in "Current liabilities" with "1.0"
    And I fill in "Current assets" with "10.0"
    And I fill in "edition_comment" with "comment"
    And I press "Create"
    Then I should see "Edition was successfully created."
    And I should see "Requestable type: ExternalEquityReport"
    And I should see "Request node: external equity report"
    And I should see "Maximum request: $0.0"
    And I should see "Requestor amount: $0.0"
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
    And I fill in "edition_comment" with "changed comment"
    And I press "Update"
    Then I should see "Edition was successfully updated."
    And I should see "Requestable type: ExternalEquityReport"
    And I should see "Request node: external equity report"
    And I should see "Maximum request: $0.0"
    And I should see "Requestor amount: $0.0"
    And I should see "Requestor comment: changed comment"
    And I should see "Anticipated expenses: $0.02"
    And I should see "Anticipated income: $0.20"
    And I should see "Current liabilities: $2.00"
    And I should see "Current assets: $20.00"
    And I should see "Net equity: $18.18"
    When I follow "Edit"
    And I fill in "edition_amount" with "170"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

  Scenario: Add and update edition (administrative_expense)
    Given an item exists with request: the request, node: node "administrative"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
    When I fill in "edition_administrative_expense_attributes_copies" with "100"
    And I fill in "Number of buckets of chalk" with "2"
    And I fill in "Amount for Daily Sun Ads" with "20"
    And I fill in "edition_administrative_expense_attributes_repairs_restocking" with "100"
    And I choose "edition_administrative_expense_attributes_mailbox_wsh_25"
    And I fill in "edition_amount" with "100"
    And I fill in "edition_comment" with "comment"
    And I press "Create"
    Then I should see "Edition was successfully created."
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
    And I should see "Copies expense: $3.00"
    And I should see "Chalk expense: $16.00"
    When I follow "Edit"
    And I fill in "edition_administrative_expense_attributes_copies" with "101"
    And I fill in "Number of buckets of chalk" with "1"
    And I fill in "Amount for Daily Sun Ads" with "10"
    And I fill in "edition_administrative_expense_attributes_repairs_restocking" with "99"
    And I choose "edition_administrative_expense_attributes_mailbox_wsh_40"
    And I fill in "edition_amount" with "120"
    And I fill in "edition_comment" with "changed comment"
    And I press "Update"
    Then I should see "Edition was successfully updated."
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
    And I should see "Copies expense: $3.03"
    And I should see "Chalk expense: $8.00"
    When I follow "Edit"
    And I fill in "edition_amount" with "170"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

  Scenario: Add and update edition with documentation
    Given a document_type: "price_quote" exists with name: "price quote"
    And the document_type is amongst the document_types of node: "generic"
    And an item exists with request: the request, node: node "generic"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
    When I fill in "edition_amount" with "100"
    And I fill in "edition_comment" with "comment"
    And I attach the file "features/support/assets/small.png" to "price quote"
    And I press "Create"
    Then I should see "Edition was successfully created."
    And I should see "Request node: generic expense"
    And I should see "Maximum request: $1,000,000.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see the following documents:
      | Type        |
      | price quote |
    When I follow "Edit"
    And I fill in "edition_amount" with "120"
    And I fill in "edition_comment" with "changed comment"
    And I press "Update"
    Then I should see "Edition was successfully updated."
    And I should see "Request node: generic expense"
    And I should see "Maximum request: $1,000,000.00"
    And I should see "Requestor amount: $120.00"
    And I should see "Requestor comment: changed comment"
    And I should see the following documents:
      | Type        |
      | price quote |
    When I follow "Edit"
    And I fill in "edition_amount" with "1000001"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

  Scenario: Add and update edition (durable_good_expense)
    Given an item exists with request: the request, node: node "durable"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
    When I fill in "edition_durable_good_expense_attributes_description" with "The goods"
    And I fill in "edition_durable_good_expense_attributes_quantity" with "50"
    And I fill in "edition_durable_good_expense_attributes_price" with "5"
    And I fill in "edition_amount" with "100"
    And I fill in "edition_comment" with "comment"
    And I press "Create"
    Then I should see "Edition was successfully created."
    And I should see "Requestable type: DurableGoodExpense"
    And I should see "Request node: durable good expense"
    And I should see "Maximum request: $250.00"
    And I should see "Requestor amount: $100.00"
    And I should see "Requestor comment: comment"
    And I should see "Description: The goods"
    And I should see "Quantity: 50"
    And I should see "Price: $5.00"
    When I follow "Edit"
    And I fill in "edition_durable_good_expense_attributes_description" with "Other goods"
    And I fill in "edition_durable_good_expense_attributes_quantity" with "70"
    And I fill in "edition_durable_good_expense_attributes_price" with "4"
    And I fill in "edition_amount" with "120"
    And I fill in "edition_comment" with "changed comment"
    And I press "Update"
    Then I should see "Edition was successfully updated."
    And I should see "Requestable type: DurableGoodExpense"
    And I should see "Request node: durable good expense"
    And I should see "Maximum request: $280.00"
    And I should see "Requestor amount: $120.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Description: Other goods"
    And I should see "Quantity: 70"
    And I should see "Price: $4.00"
    When I follow "Edit"
    And I fill in "edition_amount" with "350"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

  Scenario: Add and update edition (publication_expense)
    Given an item exists with request: the request, node: node "publication"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
    When I fill in "Number of Issues" with "20"
    And I fill in "Title" with "Geek newsletter"
    And I fill in "Number of Copies Per Issue" with "10"
    And I fill in "Purchase Price Per Copy of Each Issue" with "5"
    And I fill in "Cost of Publication Per Issue" with "8"
    And I fill in "edition_amount" with "100"
    And I fill in "edition_comment" with "comment"
    And I press "Create"
    Then I should see "Edition was successfully created."
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
    And I should see "Total copies: 200"
    And I should see "Revenue: $1,000.00"
    When I follow "Edit"
    And I fill in "Title" with "Hipster newsletter"
    And I fill in "Number of Issues" with "10"
    And I fill in "Number of Copies Per Issue" with "20"
    And I fill in "Purchase Price Per Copy of Each Issue" with "4"
    And I fill in "Cost of Publication Per Issue" with "5"
    And I fill in "edition_amount" with "50"
    And I fill in "edition_comment" with "changed comment"
    And I press "Update"
    Then I should see "Edition was successfully updated."
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
    And I should see "Total copies: 200"
    And I should see "Revenue: $800.00"
    When I follow "Edit"
    And I fill in "edition_amount" with "150"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

  Scenario: Add and update edition (local_event_expense)
    Given an item exists with request: the request, node: node "local"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
    When I fill in "Date" with "2009-08-18"
    And I fill in "Title" with "Chicken BBQ"
    And I fill in "Location" with "outside"
    And I fill in "Purpose" with "eat"
    And I fill in "Anticipated Number of Attendees" with "100"
    And I fill in "Admission Charge Per Attendee" with "5"
    And I fill in "Number of Publicity Copies" with "100"
    And I fill in "Rental Equipment, Services, and Intellectual Property Use Fees" with "550"
    And I choose "edition_local_event_expense_attributes_uup_required_true"
    And I fill in "edition_amount" with "50"
    And I fill in "edition_comment" with "comment"
    And I press "Create"
    Then I should see "Edition was successfully created."
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
    And I should see "Copies cost: $3.00"
    When I follow "Edit"
    And I fill in "Date" with "2009-08-19"
    And I fill in "Title" with "Cow Tipping"
    And I fill in "Location" with "the pasture"
    And I fill in "Purpose" with "fun"
    And I fill in "Anticipated Number of Attendees" with "15"
    And I fill in "Admission Charge Per Attendee" with "2"
    And I fill in "Number of Publicity Copies" with "10"
    And I fill in "Rental Equipment, Services, and Intellectual Property Use Fees" with "51"
    And I choose "edition_local_event_expense_attributes_uup_required_false"
    And I fill in "edition_amount" with "20"
    And I fill in "edition_comment" with "changed comment"
    And I press "Update"
    Then I should see "Edition was successfully updated."
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
    And I should see "Copies cost: $0.30"
    When I follow "Edit"
    And I fill in "edition_amount" with "150"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

  Scenario: Add and update edition (travel_event_expense)
    Given an item exists with request: the request, node: node "travel"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
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
    And I fill in "edition_amount" with "2300"
    And I fill in "edition_comment" with "comment"
    And I press "Create"
    Then I should see "Edition was successfully created."
    And I should see "Requestable type: TravelEventExpense"
    And I should see "Request node: travel event expense"
    And I should see "Maximum request: $3,084.00"
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
    And I should see "Participants: 18"
    And I should see "Total per person fees: $450.00"
    And I should see "Total per group fees: $150.00"
    And I should see "Travel cost: $1,134.00"
    And I should see "Lodging cost: $1,350.00"
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
    And I fill in "edition_amount" with "1200"
    And I fill in "edition_comment" with "changed comment"
    And I press "Update"
    Then I should see "Edition was successfully updated."
    And I should see "Requestable type: TravelEventExpense"
    And I should see "Request node: travel event expense"
    And I should see "Maximum request: $1,652.00"
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
    And I should see "Participants: 20"
    And I should see "Total per person fees: $600.00"
    And I should see "Total per group fees: $200.00"
    And I should see "Travel cost: $252.00"
    And I should see "Lodging cost: $600.00"
    When I follow "Edit"
    And I fill in "edition_amount" with "1700"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

  Scenario: Add and update edition (speaker_expense)
    Given an item exists with request: the request, node: node "speaker"
    And I am logged in as "president" with password "secret"
    And I am on the new edition page for the item
    When I fill in "Name of Speaker, Performer, or Group" with "Bob"
    And I fill in "Travel distance" with "300"
    And I fill in "Number of travelers" with "1"
    And I fill in "Nights of lodging" with "2"
    And I fill in "Engagement fee" with "100"
    And I choose "edition_speaker_expense_attributes_dignitary_true"
    And I fill in "edition_amount" with "400"
    And I fill in "edition_comment" with "comment"
    And I press "Create"
    Then I should see "Edition was successfully created."
    And I should see "Requestable type: SpeakerExpense"
    And I should see "Request node: speaker expense"
    And I should see "Maximum request: $460.00"
    And I should see "Requestor amount: $400.00"
    And I should see "Requestor comment: comment"
    And I should see "Name of Speaker, Performer, or Group: Bob"
    And I should see "Travel distance: 300 miles round trip"
    And I should see "Number of travelers: 1"
    And I should see "Nights of lodging: 2"
    And I should see "Engagement fee: $100.00"
    And I should see "Dignitary: Yes"
    And I should see "Travel cost: $150.00"
    And I should see "Lodging cost: $150.00"
    And I should see "Meals cost: $60.00"
    When I follow "Edit"
    And I fill in "Name of Speaker, Performer, or Group" with "Jim"
    And I fill in "Travel distance" with "100"
    And I fill in "Number of travelers" with "3"
    And I fill in "Nights of lodging" with "1"
    And I fill in "Engagement fee" with "200"
    And I fill in "edition_amount" with "500"
    And I fill in "edition_comment" with "changed comment"
    And I choose "edition_speaker_expense_attributes_dignitary_false"
    And I press "Update"
    Then I should see "Edition was successfully updated."
    And I should see "Requestable type: SpeakerExpense"
    And I should see "Request node: speaker expense"
    And I should see "Maximum request: $665.00"
    And I should see "Requestor amount: $500.00"
    And I should see "Requestor comment: changed comment"
    And I should see "Name of Speaker, Performer, or Group: Jim"
    And I should see "Travel distance: 100 miles round trip"
    And I should see "Number of travelers: 3"
    And I should see "Nights of lodging: 1"
    And I should see "Engagement fee: $200.00"
    And I should see "Dignitary: No"
    And I should see "Travel cost: $150.00"
    And I should see "Lodging cost: $225.00"
    And I should see "Meals cost: $90.00"
    When I follow "Edit"
    And I fill in "edition_amount" with "1500"
    And I press "Update"
    Then I should not see "Edition was successfully updated."

