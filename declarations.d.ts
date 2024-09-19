declare module "@cypress/browserify-preprocessor";

declare module "find-cypress-specs" {
  export function getSpecs(
    config: Cypress.ConfigOptions,
    type: Cypress.TestingType,
  ): string[];

  export function getSpecs(config: Cypress.PluginConfigOptions): string[];

  export function getConfig(): Cypress.ConfigOptions;
}
