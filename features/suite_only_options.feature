Feature: suite only options
  Scenario: suite specific test isolation
    Given additional Cypress configuration
      """
      {
        "e2e": {
          "testIsolation": true
        }
      }
      """
    And a file named "cypress/e2e/a.feature" with:
      """
      @testIsolation(false)
      Feature: a feature
        Scenario: a scenario
          Given a step
        Scenario: another scenario
          Then another step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given, Then } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", () => {
        cy.get("body").invoke('html', 'Hello world')
      });
      Given("another step", () => {
        cy.contains("Hello world").should("exist");
      });
      """
    When I run cypress
    Then it passes
