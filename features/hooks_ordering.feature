Feature: hooks ordering

  Hooks should be executed in the following order:
   - before
   - BeforeAll
   - beforeEach
   - Before
   - Background steps
   - BeforeStep
   - Ordinary steps
   - AfterStep (in reverse order)
   - After
   - afterEach
   - AfterAll
   - after

  Hooks with user-defined ordering should run in the correct order

  Scenario: with all hooks incrementing a counter
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Background:
          Given a background step
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        Before,
        After,
        BeforeStep,
        AfterStep,
        BeforeAll,
        AfterAll
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      BeforeAll(() => {
        expect(counter++, "Expect BeforeAll() to be called after before()").to.equal(0)
      })
      beforeEach(function() {
        expect(counter++, "Expected beforeEach() to be called after before()").to.equal(1)
      })
      Before(function() {
        expect(counter++, "Expected Before() to be called after beforeEach()").to.equal(2)
      })
      Given("a background step", function() {
        expect(counter++, "Expected a background step to be called after Before()").to.equal(3)
      })
      BeforeStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected BeforeStep() to be called before ordinary steps").to.equal(4)
        }
      })
      Given("an ordinary step", function() {
        expect(counter++, "Expected an ordinary step to be called after a background step").to.equal(5)
      })
      AfterStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called after ordinary steps").to.equal(7)
        }
      })
      AfterStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called after ordinary steps").to.equal(6)
        }
      })
      After(function() {
        expect(counter++, "Expected After() to be called in reverse order of definition").to.equal(9)
      })
      After(function() {
        expect(counter++, "Expected After() to be called after ordinary steps").to.equal(8)
      })
      afterEach(function() {
        expect(counter++, "Expected afterEach() to be called after After()").to.equal(10)
      })
      AfterAll(function() {
        expect(counter++, "Expected AfterAll() to be called after afterEach()").to.equal(11)
      })
      after(function() {
        expect(counter++, "Expected after() to be called after AfterAll()").to.equal(12)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with default ordering in Before hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        Before
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      Before(function() {
        expect(counter++, "Expected Before() to be called after before()").to.equal(0)
      })
      Before(function() {
        expect(counter++, "Expected Before() to be called after Before()").to.equal(1)
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of Before to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with user-defined ordering in Before hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        Before
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      Before({ order: 2 }, function() {
        expect(counter++, "Expected Before() with order 2 to be called after Before() with order 1").to.equal(1)
      })
      Before({ order: 1 }, function() {
        expect(counter++, "Expected Before() with order 1 to be called after before()").to.equal(0)
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of Before to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with a mix of user-defined and default ordering in Before hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        Before
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      Before(function() {
        expect(counter++, "Expected Before() with default (unset) order to be called after Before() with order 1").to.equal(1)
      })
      Before({ order: 9999 }, function() {
        expect(counter++, "Expected Before() with order 9999 to be called after before()").to.equal(0)
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of Before to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with default ordering in After hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        After
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      After(function() {
        expect(counter++, "Expected After() to be called after After()").to.equal(1)
      })
      After(function() {
        expect(counter++, "Expected After() to be called after Given").to.equal(0)
      })
      after(function() {
        expect(counter, "Expected no. of executions of After to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with user-defined ordering in After hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        After
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      After({ order: 1 }, function() {
        expect(counter++, "Expected After() with order 1 to be called after After() with order 2").to.equal(1)
      })
      After({ order: 2 }, function() {
        expect(counter++, "Expected After() with order 2 to be called after Given").to.equal(0)
      })
      after(function() {
        expect(counter, "Expected no. of executions of After to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with a mix of user-defined and default ordering in After hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        After
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      After({ order: 9999 }, function() {
        expect(counter++, "Expected After() with order 9999 to be called after After() with default order").to.equal(1)
      })
      After(function() {
        expect(counter++, "Expected After() with default order (unset) to be called after Given").to.equal(0)
      })
      after(function() {
        expect(counter, "Expected no. of executions of After to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with default ordering in BeforeStep hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        BeforeStep
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      BeforeStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected BeforeStep() to be called after before()").to.equal(0)
        }
      })
      BeforeStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected BeforeStep() to be called before ordinary steps").to.equal(1)
        }
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of BeforeStep to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with user-defined ordering in BeforeStep hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        BeforeStep
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      BeforeStep({ order: 2 }, function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected BeforeStep() with order 2 to be called after BeforeStep() with order 1").to.equal(1)
        }
      })
      BeforeStep({ order: 1 }, function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected BeforeStep() to be called after before()").to.equal(0)
        }
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of BeforeStep to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with a mix of user-defined and default ordering in BeforeStep hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        BeforeStep
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      BeforeStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected BeforeStep() with default (unset) order to be called after BeforeStep() with order 9999").to.equal(1)
        }
      })
      BeforeStep({ order: 9999 }, function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected BeforeStep() to be called after before()").to.equal(0)
        }
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of BeforeStep to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with default ordering in AfterStep hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        AfterStep
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      AfterStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called before after()").to.equal(1)
        }
      })
      AfterStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called after ordinary steps").to.equal(0)
        }
      })
      after(function() {
        expect(counter, "Expected no. of executions of AfterStep to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with user-defined ordering in AfterStep hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        AfterStep
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      AfterStep({ order: 1 }, function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called before after()").to.equal(1)
        }
      })
      AfterStep({ order: 2 }, function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called after ordinary steps").to.equal(0)
        }
      })
      after(function() {
        expect(counter, "Expected no. of executions of AfterStep to be 2").to.equal(2)
      })
      """@
    When I run cypress
    Then it passes

  Scenario: with a mix of user-defined and default ordering in AfterStep hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        AfterStep
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      AfterStep(function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called after ordinary steps").to.equal(0)
        }
      })
      AfterStep({ order: 9999 }, function ({ pickleStep }) {
        if (pickleStep.text === "an ordinary step") {
          expect(counter++, "Expected AfterStep() to be called before after()").to.equal(1)
        }
      })
      after(function() {
        expect(counter, "Expected no. of executions of AfterStep to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with default ordering in BeforeAll hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        BeforeAll
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      BeforeAll(function() {
        expect(counter++, "Expected BeforeAll() to be called after before()").to.equal(0)
      })
      BeforeAll(function() {
        expect(counter++, "Expected BeforeAll() to be called before Given()").to.equal(1)
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of BeforeAll to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with user-defined ordering in BeforeAll hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        BeforeAll
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      BeforeAll({ order: 2 }, function() {
        expect(counter++, "Expected BeforeAll() with order 2 to be called before BeforeAll() with order 1").to.equal(1)
      })
      BeforeAll({ order: 1 }, function() {
        expect(counter++, "Expected BeforeAll() with order 1 to be called after before()").to.equal(0)
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of BeforeAll to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with a mix of user-defined and default ordering in BeforeAll hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        BeforeAll
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      before(function() {
        counter = 0;
      })
      BeforeAll(function() {
        expect(counter++, "Expected BeforeAll() with default (unset) order to be called after BeforeAll() with order 9999").to.equal(1)
      })
      BeforeAll({ order: 9999 }, function() {
        expect(counter++, "Expected BeforeAll() with order 9999 to be called after before()").to.equal(0)
      })
      Given("an ordinary step", function() {
        expect(counter, "Expected no. of executions of BeforeAll to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with default ordering in AfterAll hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        AfterAll
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      AfterAll(function() {
        expect(counter++, "Expected AfterAll() to be called after AfterAll()").to.equal(1)
      })
      AfterAll(function() {
        expect(counter++, "Expected AfterAll() to be called after Given").to.equal(0)
      })
      after(function() {
        expect(counter, "Expected no. of executions of AfterAll to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with user-defined ordering in AfterAll hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        AfterAll
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      AfterAll({ order: 1 }, function() {
        expect(counter++, "Expected AfterAll() with order 1 to be called after AfterAll() with order 2").to.equal(1)
      })
      AfterAll({ order: 2 }, function() {
        expect(counter++, "Expected AfterAll() with order 2 to be called after Given").to.equal(0)
      })
      after(function() {
        expect(counter, "Expected no. of executions of AfterAll to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes

  Scenario: with a mix of user-defined and default ordering in AfterAll hooks
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Scenario: a scenario
          Given an ordinary step
      """
    And a file named "cypress/support/step_definitions/steps.js" with:
      """
      const {
        Given,
        AfterAll
      } = require("@badeball/cypress-cucumber-preprocessor")
      let counter;
      Given("an ordinary step", function() {
        counter = 0;
      })
      AfterAll({ order: 9999 }, function() {
        expect(counter++, "Expected AfterAll() with order 9999 to be called after AfterAll() with default order").to.equal(1)
      })
      AfterAll(function() {
        expect(counter++, "Expected AfterAll() with default order (unset) to be called after Given").to.equal(0)
      })
      after(function() {
        expect(counter, "Expected no. of executions of AfterAll to be 2").to.equal(2)
      })
      """
    When I run cypress
    Then it passes
