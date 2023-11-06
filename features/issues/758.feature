# https://github.com/badeball/cypress-cucumber-preprocessor/issues/758

Feature: beforeAll and afterAll hooks
  @fav
  Scenario: beforeAll and afterAll hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature x
        Scenario: a scenario b
          Given a step

        @foo
        Scenario: a scenario c
          Given a step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const { BeforeAll, AfterAll, Given } = require("@badeball/cypress-cucumber-preprocessor");
      let counter = 0
      BeforeAll(() => {
        expect(counter++, "Expect counter to be 0").to.equal(0)
      })
      Given("a step", function() {
      })
      AfterAll(() => {
        expect(counter++, "Expect counter to be 1").to.equal(1)
      })
      """
    When I run cypress
    Then it passes
