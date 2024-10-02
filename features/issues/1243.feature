# https://github.com/badeball/cypress-cucumber-preprocessor/issues/1243

Feature: custom config location
  Scenario: custom config location
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", function() {})
      """
    And a file named "config/cypress.config.js" with:
      """
      module.exports = require("../cypress.config.js");
      """
    When I run cypress with "--config-file config/cypress.config.js"
    Then it passes
