Feature: Manage fulfillments
  In order to identify what conditions have been fulfilled
  As a user or organization
  I want to list fulfillments

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for fulfillments controller
    Given a user: "focus" exists with last_name: "Fulfilled User"
    And an organization: "focus" exists with last_name: "Fulfilled Organization"
    And an agreement: "focus" exists with name: "Key Agreement"
    And a user_status_criterion: "focus" exists
    And a registration_criterion: "focus" exists
    And a fulfillment exists with fulfiller: user "focus", fulfillable: agreement "focus"
    And a fulfillment exists with fulfiller: organization "focus", fulfillable: registration_criterion "focus"
    And I log in as user: "<user>"
    And I am on the fulfillments page for user: "focus"
    Then I should <show_user> authorized
    And I should <show_user> "undergrad"
    Given I am on the fulfillments page for organization: "focus"
    Then I should <show_organization> authorized
    And I should <show_organization> "undergrads"
    Given I am on the fulfillments page for agreement: "focus"
    Then I should <show_user> "Fulfilled User"
    Given I am on the fulfillments page for registration_criterion: "focus"
    Then I should <show_organization> "Fulfilled Organization"
    Given I am on the fulfillments page for user_status_criterion: "focus"
    Then I should <show_user> "Fulfilled User"
    Examples:
      | user        | show_user | show_organization |
      | admin       | see       | see               |
      | focus       | see       | see               |
      | regular     | not see   | see               |

  Scenario: List fulfillments for a user
    Given a user: "user" exists
    And an agreement exists with name: "Key Agreement"
    And a fulfillment exists
    And a fulfillment exists with fulfiller: user "user", fulfillable: the agreement
    And I log in as user: "admin"
    And I am on the fulfillments page for user: "user"
    Then I should see the following fulfillments:
      |Fulfillable   |
      |Key Agreement |

  Scenario: List fulfillments for a user
    Given an organization: "organization" exists
    And a registration_criterion: "criterion" exists with minimal_percentage: 1, type_of_member: "undergrads", must_register: false
    And a fulfillment exists
    And a fulfillment exists with fulfiller: organization "organization", fulfillable: registration_criterion "criterion"
    And I log in as user: "admin"
    And I am on the fulfillments page for organization: "organization"
    Then I should see the following fulfillments:
      |Fulfillable                                                                               |
      |No less than 1 percent of members provided in the current registration must be undergrads |

