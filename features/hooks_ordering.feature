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

  @foo
  Scenario: with all hooks incrementing a counter
    Given a file named "cypress/e2e/a.feature" with:
      """
      Feature: a feature
        Background:
          Given a background step
        @foo
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
        expect(counter++, "Expect BeforeAll() to be called after beforeEach()").to.equal(0)
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
