# https://github.com/badeball/cypress-cucumber-preprocessor/issues/758

Feature: visualizing hook with filter
  Scenario: visualizing hook with filter
    Given a file named "cypress/e2e/a.feature" with:
      """
      @foo
      Feature: a feature x
        Scenario: a scenario a
          Given a step

      Feature: a feature x
      Scenario: a scenario b
        Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { BeforeAll, AfterAll, Given } = require("@badeball/cypress-cucumber-preprocessor");
      BeforeAll(() => {})
      Given("a step", function() {
      })
      AfterAll(() => {})
      """
    When I run cypress
    Then it passes
