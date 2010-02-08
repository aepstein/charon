Feature: Manage fulfillments
  In order to identify what conditions have been fulfilled
  As a user or organization
  I want to list fulfillments

  Background:
    Given a user: "admin" exists with net_id: "admin", password: "secret"

  Scenario: List fulfillments for a user
    Given a user: "user" exists
    And an agreement exists with name: "Key Agreement"
    And a fulfillment exists
    And a fulfillment exists with fulfiller: user "user", fulfillable: the agreement
    And I am logged in as "admin" with password "secret"
    And I am on the fulfillments page for user: "user"
    Then I should see the following fulfillments:
      |Fulfillable   |
      |Key Agreement |

  Scenario: List fulfillments for a user
    Given an organization: "organization" exists
    And a registration_criterion: "criterion" exists with minimal_percentage: 1, type_of_member: "undergrads", must_register: false
    And a fulfillment exists
    And a fulfillment exists with fulfiller: organization "organization", fulfillable: registration_criterion "criterion"
    And I am logged in as "admin" with password "secret"
    And I am on the fulfillments page for organization: "organization"
    Then I should see the following fulfillments:
      |Fulfillable                                                                                                   |
      |No less than 1 percent of members provided in the current registration of the organization must be undergrads |

