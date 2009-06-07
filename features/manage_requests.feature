Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests

  Scenario: Register new request
    Given the following request_structures:
      | name   |
      | first  |
      | second |
    Given the following request_nodes:
      | structure | parent | name  |
      | first     |        | root  |
      | first     | root   | child |
    And I am on the new request page with the request_structure named "first"
    And I press "Create"
    Then I should see ""

  Scenario: Delete request
    Given the following requests:
      ||
      ||
      ||
      ||
      ||
    When I delete the 3rd request
    Then I should see the following requests:
      ||
      ||
      ||
      ||

