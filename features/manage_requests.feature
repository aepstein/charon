@ate2
Feature: Manage requests
  In order to prepare, review, and generate transactions
  As a requestor or reviewer
  I want to manage requests

  Scenario: Register new request
    Given the following organization records:
      | last_name |
      | organization 1 |
    And 1 basis record
    When I am on "organization 1's new request page"
    And I press "Create"
    Then I should see "Showing request"

