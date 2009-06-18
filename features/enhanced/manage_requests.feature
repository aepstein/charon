Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests

  Scenario: Register new request
    Given the following structures:
      | name   |
      | first  |
      | second |
    Given the following nodes:
      | structure | parent | name  |
      | first     |        | root  |
      | first     | root   | child |
    And I am on the new request page with the structure named "first"
    And I follow "Add root item"
    And I follow "Add child item"
    And I follow "Add child item"
    And I press "Create"
    Then I should see "Child 2"

