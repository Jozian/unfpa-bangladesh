#JIRA PRIMERO-166
#JIRA PRIMERO-203

@javascript @primero
Feature: Followup
  As a Social worker, I want to enter information related to follow up visits so that we can report on our interactions with the child (individual) in our care.

  Background:
    Given I am logged in as an admin with username "primero" and password "primero"
    When I access "cases page"
    And I press the "Create a New Case" button
    And I press the "Follow Up" button

  Scenario: I am a logged in Social Worker on the Follow Ups form
    And I fill in the 1st "Followup Subform Section" subform with the follow:
      | Followup needed by                                          | 12/Jun/2014                            |
      | Followup date                                               | 12/Jun/2014                            |
      | Details about action taken                                  | Some details about action taken        |
      | Date action taken?                                          | 10/Jun/2014                            |
      | If yes, when do you recommend the next visit to take place? | The next week                          |
      | Comments                                                    | Some comments                          |
      | Type of followup                                            |<Select> Follow-Up After Reunification  |
      | Was the child/adult seen during the visit?                  |<Select> No                             |
      | If not, why?                                                |<Checkbox> At School                    |
      | Has action been taken?                                      |<Select> Yes                            |
      | Is there a need for further follow-up visits?               |<Select> Yes                            |
    And I fill in the 2nd "Followup Subform Section" subform with the follow:
      | Followup needed by                                          | 15/Jun/2014                            |
      | Followup date                                               | 15/Jun/2014                            |
      | Details about action taken                                  | Some details about action taken        |
      | Date action taken?                                          | 14/Jun/2014                            |
      | Comments                                                    | Some additional comments               |
      | Type of followup                                            | <Select> Follow-up in Care             |
      | Was the child/adult seen during the visit?                  | <Select> No                            |
      | If not, why?                                                | <Checkbox> Visiting Friends/Relatives  |
      | Has action been taken?                                      | <Select> Yes                           |
      | Is there a need for further follow-up visits?               | <Select> No                            |
      | If not, do you recommend that the case be close?            | <Select> Yes                           |
    And I press "Save"
    Then I should see "Case record successfully created" on the page
    And I should see "Follow-Up After Reunification" on the page
    And I should see "12/Jun/2014" on the page
    And I should see "10/Jun/2014" on the page
    And I should see "The next week" on the page
    And I should see "Follow-up in Care" on the page
    And I should see "15/Jun/2014" on the page
    And I should see "14/Jun/2014" on the page
    And I should see "Some additional comments" on the page
    And I should see "Visiting Friends/Relatives" on the page
    And I press the "Edit" button
    And I press the "Follow Up" button
    And I remove the 2nd "Followup Subform Section" subform
    And I click OK in the browser popup
    And I fill in the following:
      | Followup needed by                                          | 11/Jun/2014                            |
      | Followup date                                               | 11/Jun/2014                            |
      | Details about action taken                                  | Some details about action taken        |
      | Date action taken?                                          | 10/Jun/2014                            |
      | If yes, when do you recommend the next visit to take place? | The next week                          |
      | Comments                                                    | Some comments                          |
    And I press "Save"
    And I should not see "Follow-up in Care" on the page
    And I should not see "15/Jun/2014" on the page
    And I should not see "14/Jun/2014" on the page
    And I should not see "Some additional comments" on the page
    And I should not see "Visiting Friends/Relatives" on the page