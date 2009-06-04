Feature: Manage publication_expenses
  In order to request funds to produce a community publication
  As an applicant
  wants publication addendum form

  @la254
  Scenario: Register new publication_expense
    Given I am on the new publication_expense page
    When I fill in "publication_expense_no_of_issues" with "1"
    And I fill in "publication_expense_no_of_copies_per_issue" with "1"
    And I fill in "publication_expense_purchase_price" with " 1"
    And I fill in "publication_expense_cost_publication" with " 1"

    And I press "Create"
    And I should see "Total copies: 1"
    And I should see "Revenue: $1.0"
    And I should see "Total cost publication: $1.0"

  Scenario: Delete publication_expense
    Given the following publication_expenses:
      |no_of_issues|no_of_copies_per_issue|total_copies|purchase_price|revenue|cost_publication|total_cost_publication|
      |no_of_issues 1|no_of_copies_per_issue 1|total_copies 1|purchase_price 1|revenue 1|cost_publication 1|total_cost_publication 1|
      |no_of_issues 2|no_of_copies_per_issue 2|total_copies 2|purchase_price 2|revenue 2|cost_publication 2|total_cost_publication 2|
      |no_of_issues 3|no_of_copies_per_issue 3|total_copies 3|purchase_price 3|revenue 3|cost_publication 3|total_cost_publication 3|
      |no_of_issues 4|no_of_copies_per_issue 4|total_copies 4|purchase_price 4|revenue 4|cost_publication 4|total_cost_publication 4|
    When I delete the 3rd publication_expense
    Then I should see the following publication_expenses:
      |no_of_issues|no_of_copies_per_issue|total_copies|purchase_price|revenue|cost_publication|total_cost_publication|
      |no_of_issues 1|no_of_copies_per_issue 1|total_copies 1|purchase_price 1|revenue 1|cost_publication 1|total_cost_publication 1|
      |no_of_issues 2|no_of_copies_per_issue 2|total_copies 2|purchase_price 2|revenue 2|cost_publication 2|total_cost_publication 2|
      |no_of_issues 4|no_of_copies_per_issue 4|total_copies 4|purchase_price 4|revenue 4|cost_publication 4|total_cost_publication 4|

