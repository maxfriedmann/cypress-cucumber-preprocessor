Feature: dry run

  Background:
    Given additional preprocessor configuration
      """
      {
        "dryRun": true
      }
      """

  Rule: it should only fail upon undefined or ambiguous steps

    Scenario: undefined step
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given an undefined step
        """
      When I run cypress
      Then it fails

    Scenario: ambiguous step
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        Given(/a step/, function() {});
        """
      When I run cypress
      Then it fails

    Scenario: failing step
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {
          throw "some error";
        });
        """
      When I run cypress
      Then it passes

    Scenario: failing Before() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Before, Given } = require("@badeball/cypress-cucumber-preprocessor");
        Before(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing BeforeAll() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { BeforeAll, Given } = require("@badeball/cypress-cucumber-preprocessor");
        BeforeAll(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing BeforeStep() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { BeforeStep, Given } = require("@badeball/cypress-cucumber-preprocessor");
        BeforeStep(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing After() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { After, Given } = require("@badeball/cypress-cucumber-preprocessor");
        After(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing AfterAll() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { AfterAll, Given } = require("@badeball/cypress-cucumber-preprocessor");
        AfterAll(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing AfterStep() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { AfterStep, Given } = require("@badeball/cypress-cucumber-preprocessor");
        AfterStep(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing before() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        before(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing beforeEach() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        beforeEach(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing after() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        after(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing afterEach() hook
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        afterEach(function() {
          throw "some error";
        });
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes

    Scenario: failing support file
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature name
          Scenario: a scenario name
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        """
    And a file named "cypress/support/e2e.js" with:
      """
      throw "some error";
      """
      When I run cypress
      Then it passes
