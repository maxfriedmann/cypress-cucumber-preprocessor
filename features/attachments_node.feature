@no-default-plugin
Feature: attachments

  Background:
    Given additional preprocessor configuration
      """
      {
        "json": {
          "enabled": true
        }
      }
      """

  Rule: it should support a variety of options

    Scenario: string identity
      Given a file named "setupNodeEvents.js" with:
        """
        const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
        const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
        const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

        module.exports = async (on, config) => {
          await addCucumberPreprocessorPlugin(on, config, {
            onAfterStep({ wasLastStep, attach }) {
              attach("foobar");
            }
          });
          on(
            "file:preprocessor",
            createBundler({
              plugins: [createEsbuildPlugin(config)]
            })
          );
          return config;
        };
        """
      And a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be a JSON output similar to "fixtures/attachments/string.json"

    Scenario: array buffer
      Given a file named "setupNodeEvents.js" with:
        """
        const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
        const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
        const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

        module.exports = async (on, config) => {
          await addCucumberPreprocessorPlugin(on, config, {
            onAfterStep({ wasLastStep, attach }) {
              attach(Buffer.from("foobar"), "text/plain");
            }
          });
          on(
            "file:preprocessor",
            createBundler({
              plugins: [createEsbuildPlugin(config)]
            })
          );
          return config;
        };
        """
      And a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be a JSON output similar to "fixtures/attachments/string.json"

    Scenario: string encoded
      Given a file named "setupNodeEvents.js" with:
        """
        const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
        const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
        const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

        module.exports = async (on, config) => {
          await addCucumberPreprocessorPlugin(on, config, {
            onAfterStep({ wasLastStep, attach }) {
              attach(Buffer.from("foobar").toString("base64"), "base64:text/plain");
            }
          });
          on(
            "file:preprocessor",
            createBundler({
              plugins: [createEsbuildPlugin(config)]
            })
          );
          return config;
        };
        """
      And a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be a JSON output similar to "fixtures/attachments/string.json"

  Rule: it should be invoked with same arguments as AfterStep(), in addition to `results`

    Scenario: etc arguments
      Given a file named "setupNodeEvents.js" with:
        """
        const assert = require("assert/strict");
        const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
        const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
        const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

        module.exports = async (on, config) => {
          await addCucumberPreprocessorPlugin(on, config, {
            onAfterStep({ attach, pickle, pickleStep, gherkinDocument, testCaseStartedId, testStepId }) {
              assert.equal(pickle.name, "a scenario name");
              assert.equal(pickleStep.text, "a step");
              assert.equal(gherkinDocument.feature.name, "a feature name");
              assert.equal(typeof testCaseStartedId, "string");
              assert.equal(typeof testStepId, "string");
              attach("success");
            }
          });
          on(
            "file:preprocessor",
            createBundler({
              plugins: [createEsbuildPlugin(config)]
            })
          );
          return config;
        };
        """
      And a file named "cypress/e2e/a.feature" with:
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
      When I run cypress
      Then it passes
      And there should be one attachment containing "success"

    Scenario: passing step
      Given a file named "setupNodeEvents.js" with:
        """
        const assert = require("assert/strict");
        const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
        const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
        const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

        module.exports = async (on, config) => {
          await addCucumberPreprocessorPlugin(on, config, {
            onAfterStep({ attach, result }) {
              attach(result.status);
            }
          });
          on(
            "file:preprocessor",
            createBundler({
              plugins: [createEsbuildPlugin(config)]
            })
          );
          return config;
        };
        """
      And a file named "cypress/e2e/a.feature" with:
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
      When I run cypress
      Then it passes
      And there should be one attachment containing "PASSED"

    Scenario: failing step
      Given additional Cypress configuration
        """
        {
          "screenshotOnRunFailure": false
        }
        """
      And a file named "setupNodeEvents.js" with:
        """
        const assert = require("assert/strict");
        const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
        const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
        const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

        module.exports = async (on, config) => {
          await addCucumberPreprocessorPlugin(on, config, {
            onAfterStep({ attach, result }) {
              attach(result.status);
            }
          });
          on(
            "file:preprocessor",
            createBundler({
              plugins: [createEsbuildPlugin(config)]
            })
          );
          return config;
        };
        """
      And a file named "cypress/e2e/a.feature" with:
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
      Then it fails
      And there should be one attachment containing "FAILED"

  Rule: it should correctly propogate a `wasLastStep` property regardless of test path

    Background:
      Given a file named "setupNodeEvents.js" with:
        """
        const createBundler = require("@bahmutov/cypress-esbuild-preprocessor");
        const { addCucumberPreprocessorPlugin } = require("@badeball/cypress-cucumber-preprocessor");
        const { createEsbuildPlugin } = require("@badeball/cypress-cucumber-preprocessor/esbuild");

        module.exports = async (on, config) => {
          await addCucumberPreprocessorPlugin(on, config, {
            onAfterStep({ wasLastStep, attach }) {
              attach(String(wasLastStep));
            }
          });
          on(
            "file:preprocessor",
            createBundler({
              plugins: [createEsbuildPlugin(config)]
            })
          );
          return config;
        };
        """

    Scenario: passing steps
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a step
            And another step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a/another step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be two attachments containing false and true, respectively

    Scenario: skipped step
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a skipped step
            And another step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a skipped step", function() {
          return "skipped";
        });
        Given("another step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be two attachments containing false and true, respectively

    Scenario: pending step
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a pending step
            And another step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a pending step", function() {
          return "pending";
        });
        Given("another step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be two attachments containing false and true, respectively

    Scenario: failing step
      Given additional Cypress configuration
        """
        {
          "screenshotOnRunFailure": false
        }
        """
      And a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a failing step
            And another step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a failing step", function() {
          throw "some error";
        });
        Given("another step", function() {});
        """
      When I run cypress
      Then it fails
      And there should be two attachments containing false and true, respectively

    Scenario: skipped test (from step)
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a skipping step
            And another step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a skipping step", function() {
          this.skip();
        });
        Given("another step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be two attachments containing false and true, respectively

    Scenario: rescued error
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a failing step
            And another step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a failing step", function() {
          throw "some error";
        });
        Given("another step", function() {});
        """
      And a file named "cypress/support/e2e.js" with:
        """
        Cypress.on("fail", (err) => {
          if (err.message.includes("some error")) {
            return;
          }

          throw err;
        })
        """
      When I run cypress
      Then it passes
      And there should be two attachments containing false and true, respectively

    Scenario: with a scenario hook (Before)
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Before, Given } = require("@badeball/cypress-cucumber-preprocessor");
        Before(function() {});
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be one attachment containing "true"

    Scenario: with a scenario hook (After)
      Given a file named "cypress/e2e/a.feature" with:
        """
        Feature: a feature
          Scenario: a scenario
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { After, Given } = require("@badeball/cypress-cucumber-preprocessor");
        After(function() {});
        Given("a step", function() {});
        """
      When I run cypress
      Then it passes
      And there should be one attachment containing "true"
