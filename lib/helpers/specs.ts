import { getSpecs as origGetSpecs } from "find-cypress-specs";

function ensureArray<T>(el: T | T[]): T[] {
  return Array.isArray(el) ? el : [el];
}

export function getSpecs(
  config: Cypress.ConfigOptions & {},
  type: Cypress.TestingType,
): string[];

export function getSpecs(config: Cypress.PluginConfigOptions): string[];

/**
 * TODO: Remove once https://github.com/bahmutov/find-cypress-specs/issues/301 is resolved.
 *
 * This is important for two reasons:
 *
 * 1. A typical Cypress + Cucumber project will contain
 *    node_modules/@cucumber/gherkin-streams/testdata/good/minimal.feature
 *    .. which will affect the determined implicit integration folder.
 *
 * 2. Projects created during integration tests contains a symlink from node_modules to self, in
 *    order to test a dirty build. This makes globby loop indefinitely and Node eventually errors
 *    with heap exhaustion.
 */
export function getSpecs(
  config: Cypress.ConfigOptions | Cypress.PluginConfigOptions,
  type?: Cypress.TestingType,
): string[] {
  if ("testingType" in config) {
    return origGetSpecs({
      ...config,
      excludeSpecPattern: ensureArray(config.excludeSpecPattern).concat(
        "**/node_modules/**",
      ),
    });
  } else {
    return origGetSpecs(
      {
        ...config,
        e2e: {
          ...(config.e2e ?? {}),
          excludeSpecPattern: ensureArray(
            config.e2e?.excludeSpecPattern ?? [],
          ).concat("**/node_modules/**"),
        },
      },
      type!,
    );
  }
}
