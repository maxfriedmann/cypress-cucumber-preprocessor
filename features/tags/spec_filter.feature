Feature: filter spec

  Background:
    Given additional preprocessor configuration
      """
      {
        "filterSpecs": true
      }
      """

  Rule: it should filter features based on whether they contain a matching scenario

    Scenario: 1 / 2 specs matching
      Given a file named "cypress/e2e/a.feature" with:
        """
        @foo
        Feature: some feature
          Scenario: first scenario
            Given a step
        """
      And a file named "cypress/e2e/b.feature" with:
        """
        @bar
        Feature: some other feature
          Scenario: second scenario
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {})
        """
      When I run cypress with "--env tags=@foo"
      Then it passes
      And it should appear to not have ran spec "b.feature"

  Rule: non-feature specs should be filtered as if they have tags equalling the empty set

    Background:
      Given additional Cypress configuration
        """
        {
          "e2e": {
            "specPattern": "**/*.{spec.js,feature}"
          }
        }
        """
      And a file named "cypress/e2e/a.feature" with:
        """
        @bar
        Feature: some feature
          Scenario: first scenario
            Given a step
        """
      And a file named "cypress/support/step_definitions/steps.js" with:
        """
        const { Given } = require("@badeball/cypress-cucumber-preprocessor");
        Given("a step", function() {})
        """
      And a file named "cypress/e2e/b.spec.js" with:
        """
        it("should work", () => {});
        """

    Scenario: logical not
      When I run cypress with "--env 'tags=not @foo'"
      Then it passes
      And it should appear to have ran spec "a.feature" and "b.spec.js"

    Scenario: not logical not
      When I run cypress with "--env tags=@bar"
      Then it passes
      And it should appear as if only a single test ran
