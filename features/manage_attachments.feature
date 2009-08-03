Feature: Manage attachments
  In order to attach files to versions
  As a documentation-dependent organization
  I want to create, update, list, and delete attachments

  Scenario: Create new attachment
    Given I am on the new attachment page
    When I fill in "Attachment type" with "attachment_type 1"
    And I press "Create"
    Then I should see "attachment_type 1"

  Scenario: Delete attachment
    Given the following attachments:
      |attachment_type|
      |documentation|
      |documentation|
      |documentation|
      |documentation|
    When I delete the 3rd attachment
    Then I should see the following attachments:
      |attachment_type|
      |attachment_type 1|
      |attachment_type 2|
      |attachment_type 4|

