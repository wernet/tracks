Feature: Edit a next action from every page
  In order to manage a next action
  As a Tracks user
  I want to to be able to change the next action from every page

  Background:
    Given the following user record
      | login    | password | is_admin |
      | testuser | secret   | false    |
    And I have logged in as "testuser" with password "secret"
    And I have a context called "@pc"

  @selenium
  Scenario: I can toggle the star of a todo
    Given I have a todo "star me" in the context "@home"
    When I go to the home page
    And I star the action "star me"
    Then I should see a starred "star me"
    When I go to the tag page for "starred"
    Then I should see "star me"

  @selenium
  Scenario: I can delete a todo
    Given I have a todo "delete me" in the context "@home"
    When I go to the home page
    Then I should see "delete me"
    When I delete the action "delete me"
    Then I should not see "delete me"

  @selenium
  Scenario: Removing the last todo in context will hide context
    Given I have a todo "delete me" in the context "@home"
    And I have a context called "@pc"
    When I go to the home page
    Then I should see the container for context "@home"
    And I should see "delete me" in the context container for "@home"
    When I mark "delete me" as complete
    Then I should not see the container for context "@home"
    When I mark "delete me" as uncompleted
    Then I should see the container for context "@home"
    When I edit the context of "delete me" to "@pc"
    Then I should not see the container for context "@home"
    When I delete the todo "delete me"
    Then I should not see "delete me"
    And I should not see the container for context "@home"
    And I should not see the container for context "@pc"

  @selenium
  Scenario Outline: Deleting the last todo in container will show empty message # only project, context, tag, not todo
    Given I have a context called "@home"
    And I have a project "my project" that has the following todos
      | context | description   | tags      |
      | @home   | first action  | test, bla |
      | @home   | second action | bla       |
    When I go to the <page>
    Then I should not see "<empty message>"
    And I should see "first action"
    When I delete the todo "first action"
    Then I should not see "<empty message>"
    When I delete the todo "second action"
    Then I should see "<empty message>"

    Scenarios:
      | page                     | empty message                                             |
      | "my project" project     | Currently there are no incomplete actions in this project |
      | context page for "@home" | Currently there are no incomplete actions in this context |
      | tag page for "bla"       | No actions found                                          |

  @selenium
  Scenario Outline: I can mark an active todo complete and it will update empty messages
    Given I have a context called "visible context"
    And I have a project called "visible project"
    When I go to the <page>
    Then I should see "<empty message>"
    When I submit a new action with description "visible todo" to project "visible project" with tags "starred" in the context "visible context"
    Then I should see "visible todo"
    And I should not see "<empty message>"
    When I mark "visible todo" as complete
    And I should see "<empty message>"
    And I should see "visible todo" in the completed container

    Scenarios:
      | page                               | empty message                                             |
      | "visible project" project          | Currently there are no incomplete actions in this project |
      | home page                          | Currently there are no incomplete actions                 |
      | tag page for "starred"             | No actions found                                          |
      | context page for "visible context" | Currently there are no incomplete actions in this context |

  @selenium
  Scenario Outline: I can mark a deferred todo complete and it will update empty messages
    Given I have a context called "visible context"
    And I have a project called "visible project"
    When I go to the <page>
    Then I should see "<empty message>"
    When I submit a new deferred action with description "visible todo" to project "visible project" with tags "starred" in the context "visible context"
    Then I should see "visible todo"
    And I should not see "<empty message>"
    When I mark "visible todo" as complete
    And I should see "<empty message>"
    And I should see "visible todo" in the completed container

    Scenarios:
      | page                      | empty message                                      |
      | tag page for "starred"    | Currently there are no deferred or pending actions |
      | "visible project" project | Currently there are no deferred or pending actions |

  @selenium
  Scenario Outline: I can mark a completed todo active and it will update empty messages and context containers
    Given I have a completed todo with description "visible todo" in project "visible project" with tags "starred" in the context "visible context"
    When I go to the <page>
    Then I should see "<empty message>"
    And I should not see the container for context "visible context"
    And I should not see "<empty completed message>"
    When I mark the complete todo "visible todo" active
    Then I should see the container for context "visible context"
    And I should see "<empty completed message>"
    And I should see "visible todo" in the context container for "visible context"
    And I should not see "<empty message>"

    Scenarios:
      | page                   | empty message    | empty completed message                  |
      | tag page for "starred" | No actions found | Currently there are no completed actions |
      | home page              | No actions found | Currently there are no completed actions |

  @selenium
  Scenario Outline: I can mark a completed todo active and it will update empty messages for pages without context containers
    Given I have a completed todo with description "visible todo" in project "visible project" with tags "starred" in the context "visible context"
    When I go to the <page>
    Then I should see "<empty message>"
    And I should not see "<empty completed message>"
    When I mark the complete todo "visible todo" active
    And I should see "<empty completed message>"
    And I should not see "<empty message>"

    Scenarios:
      | page                               | empty message                                             | empty completed message                  |
      | context page for "visible context" | Currently there are no incomplete actions in this context | Currently there are no completed actions |
      | "visible project" project          | Currently there are no incomplete actions in this project | Currently there are no completed actions |

  @selenium
  Scenario Outline: I can edit a todo to change its description
    # do for more pages, see #1094
    Given I have a todo with description "visible todo" in project "visible project" with tags "starred" in the context "visible context" that is due next week
    When I go to the <page>
    And I edit the description of "visible todo" to "changed todo"
    Then I should not see "visible todo"
    And I should see "changed todo"

    Scenarios:
      | page                               |
      | home page                          |
      | context page for "visible context" |
      | "visible project" project          |
      | tag page for "starred"             |
      | calendar page                      |

  @selenium
  Scenario Outline: I can edit a todo to move it to another context
    Given I have a context called "@pc"
    And I have a context called "@laptop"
    And I have a project "my project" that has the following todos
      | context | description   | tags |
      | @pc     | first action  | bla  |
      | @laptop | second action | bla  |
    When I go to the <page>
    Then I should see "first action" in the context container for "@pc"
    When I edit the context of "first action" to "@laptop"
    Then I should not see "first action" in the context container for "@pc"
    Then I should see "first action" in the context container for "@laptop"

    Scenarios:
    | page               |
    | home page          |
    | tag page for "bla" |

  @selenium
  Scenario: I can edit a todo to move it to another context in tickler page
    Given I have a context called "@pc"
    And I have a context called "@laptop"
    And I have a project "my project" that has the following deferred todos
      | context | description   |
      | @pc     | first action  |
      | @laptop | second action |
    When I go to the tickler page
    Then I should see "first action" in the context container for "@pc"
    When I edit the context of "first action" to "@laptop"
    Then I should not see "first action" in the context container for "@pc"
    Then I should see "first action" in the context container for "@laptop"

  @selenium
  Scenario: I can edit a todo to move it to another project
    Given I have a project called "project one"
    And I have a project "project two" with 1 todos
    When I go to the "project two" project
    And I edit the project of "todo 1" to "project one"
    Then I should not see "todo 1"
    When I go to the "project one" project
    Then I should see "todo 1"

  @selenium
  Scenario: I can edit a todo to move it to the tickler
    When I go to the home page
    And I submit a new action with description "start later" in the context "@pc"
    And I edit the show from date of "start later" to next month
    Then I should not see "start later"
    When I go to the tickler page
    Then I should see "start later"

  @selenium
  Scenario: I can defer a todo
    When I go to the home page
    And I submit a new action with description "start later" in the context "@pc"
    And I defer "start later" for 1 day
    Then I should not see "start later"
    When I go to the tickler page
    Then I should see "start later"

  @selenium
  Scenario: I can make a project from a todo
    When I go to the home page
    And I submit a new action with description "buy mediacenter" in the context "@pc"
    And I make a project of "buy mediacenter"
    #sidebar does not update
    Then I should be on the "buy mediacenter" project
    When I go to the projects page
    Then I should see "buy mediacenter"

  Scenario: I can show the notes of a todo
    Given this is a pending scenario

  Scenario: I can tag a todo
    Given this is a pending scenario

  Scenario: Clicking a tag of a todo will go to that tag page
    Given I have a todo "tag you are it" in context "@tags" with tags "taga, tagb"
    When I go to the home page
    Then I should see "tag you are it"
    And I should see "taga"
    When I follow "taga"
    Then I should be on the tag page for "taga"

  Scenario: I can edit the tags of a todo
    Given this is a pending scenario

  Scenario: Editing the context of a todo to a new context will show new context
    # for home and tickler and tag
    Given this is a pending scenario

  Scenario: Making an error when editing a todo will show error message
    Given this is a pending scenario
