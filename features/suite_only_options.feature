@cypress>=12
Feature: suite only options
  Scenario: Configuring testIsolation on a Feature
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

  Scenario: Configuring testIsolation on a Rule
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
      Feature: a feature
        @testIsolation(false)
        Rule: a rule
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

  Scenario: Configuring testIsolation on a Scenario fails
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
      Feature: a feature
        @testIsolation(false)
        Scenario: a scenario
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { Given, Then } = require("@badeball/cypress-cucumber-preprocessor");
      Given("a step", () => {
        cy.get("body").invoke('html', 'Hello world')
      });
      """
    When I run cypress
    Then it fails
    And the output should contain
      """
      Tag @testIsolation(false) can only be used on a Feature or a Rule
      """
