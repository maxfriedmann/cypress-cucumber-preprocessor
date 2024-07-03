import {
  When,
  Before,
  After,
  attach,
} from "@badeball/cypress-cucumber-preprocessor";

Before(function () {
  // no-op
});

Before({ name: "A named hook" }, function () {
  // no-op
});

When("a step passes", function () {
  // no-op
});

When("a step fails", function () {
  throw new Error("Exception in step");
});

After(function () {
  // no-op
});

After("@some-tag or @some-other-tag", function () {
  throw new Error("Exception in conditional hook");
});

After("@with-attachment", function () {
  cy.readFile("cucumber.svg", "base64").then((file) => {
    attach(file, "base64:image/svg+xml");
  });
});
