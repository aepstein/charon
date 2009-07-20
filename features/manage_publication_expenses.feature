Feature: Manage publication_expenses
  In order to request funds to produce a community publication
  As an applicant
  I want a publication addendum form

  Scenario: Register new publication_expense
    Given I am on the new publication_expense page
    When I fill in "publication_expense_no_of_issues" with "1"
    And I fill in "publication_expense_no_of_copies_per_issue" with "1"
    And I fill in "publication_expense_purchase_price" with " 1"
    And I fill in "publication_expense_cost_publication" with " 1"
    And I press "Create"
    Then I should see "Publication expense was successfully created."

