Feature: Manage memberships
  In order to manage memberships associated with users and organizations
  As an administrator or user
  I want to create, list, and destroy memberships

  Background:
    Given a user: "admin" exists with admin: true
    And a user: "regular" exists

  Scenario Outline: Test permissions for memberships controller actions
    Given an organization: "focus" exists with last_name: "Focus organization"
    And a user: "focus" exists with last_name: "Focus user"
    And a user: "colleague" exists
    And a membership: "focus" exists with organization: the organization, user: user "focus"
    And a membership exists with organization: the organization, user: user "colleague"
    And I log in as user: "<user>"
    And I am on the page for the membership
    Then I should <show> authorized
    And I should <update> "Edit"
    Given I am on the memberships page for <context>: "focus"
    And I should <show> "Focus"
    And I should <create> "New membership"
    And I should <update> "Edit"
    And I should <destroy> "Destroy"
    Given I am on the new membership page for <context>: "focus"
    Then I should <create> authorized
    Given I post on the memberships page for <context>: "focus"
    Then I should <create> authorized
    And I am on the edit page for the membership
    Then I should <update> authorized
    Given I put on the page for the membership
    Then I should <update> authorized
    Given I delete on the page for the membership
    Then I should <destroy> authorized
    Examples:
      | context      | user      | create  | update  | destroy | show    |
      | organization | admin     | see     | see     | see     | see     |
      | organization | focus     | not see | not see | not see | see     |
      | organization | colleague | not see | not see | not see | see     |
      | organization | regular   | not see | not see | not see | not see |
      | user         | admin     | see     | see     | see     | see     |
      | user         | focus     | not see | not see | not see | see     |
      | user         | colleague | not see | not see | not see | see     |
      | user         | regular   | not see | not see | not see | not see |

  Scenario Outline: Create new membership and update
    Given a user exists with net_id: "zzz333", first_name: "Buzz", last_name: "Aldrin"
    And an organization exists with last_name: "Focus organization"
    And a role exists with name: "president"
    And a role exists with name: "treasurer"
    And I log in as user: "admin"
    And I am on the new membership page for the <context>
    When I fill in "<c_context>" with "<entry>"
    And I select "president" from "Role"
    And I choose "Yes"
    And I press "Create"
    Then I should see "Membership was successfully created."
    And I should see "Organization: Focus organization"
    And I should see "User: Buzz Aldrin"
    And I should see "Active? Yes"
    And I should see "Role: president"
    When I follow "Edit"
    Then I should not see "Organization"
    And I should not see "User"
    And I select "treasurer" from "Role"
    And I choose "No"
    And I press "Update"
    Then I should see "Membership was successfully updated."
    And I should see "Organization: Focus organization"
    And I should see "User: Buzz Aldrin"
    And I should see "Active? No"
    And I should see "Role: treasurer"
    Examples:
      | context      | entry               | c_context    |
      | user         | Focus organization, | Organization |
      | organization | John Doe (zzz333)   | User         |

  Scenario: Delete and list memberships
    Given a user: "a" exists with last_name: "Alpha"
    And a user: "b" exists with last_name: "Beta"
    And a user: "c" exists with last_name: "Camma"
    And a user: "d" exists with last_name: "Delta"
    And an organization exists
    And a membership exists with user: user "d", organization: the organization
    And a membership exists with user: user "c", organization: the organization
    And a membership exists with user: user "b", organization: the organization
    And a membership exists with user: user "a", organization: the organization
    And I log in as user: "admin"
    When I follow "Destroy" for the 3rd membership for the organization
    Given I am on the memberships page for the organization
    Then I should see the following memberships:
      | User       |
      | John Alpha |
      | John Beta  |
      | John Delta |

