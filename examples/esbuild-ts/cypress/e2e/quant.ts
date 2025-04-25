import { When, Then } from "@badeball/cypress-cucumber-preprocessor";

When("I visit qwant.com", () => {
  cy.visit("https://www.qwant.com/");
});

Then("I should see the quant search bar", () => {
  cy.get("input[type=text]")
    .should("have.attr", "placeholder")
    .and(
      "match",
      /Search the web without being tracked|Search without being tracked/,
    );

  assert.deepEqual({}, {});
});
