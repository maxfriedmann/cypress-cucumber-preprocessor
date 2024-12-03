const globalPropertyName =
  "__cypress_cucumber_preprocessor_mocha_dont_use_this";

globalThis[globalPropertyName] = {
  before: globalThis.before,
  beforeEach: globalThis.beforeEach,
  after: globalThis.after,
  afterEach: globalThis.afterEach,
};

/**
 * {} isn't strictly speaking a Mocha.Hook, so if Cypress decides to update their shipped Mocha
 * version to v11, which introduces #5231 [1], then this might become problematic. The
 * @types/mocha package did however update their types within its v10 line.
 *
 * [1] https://github.com/mochajs/mocha/issues/5231
 */
window.before = () => ({}) as Mocha.Hook;
window.beforeEach = () => ({}) as Mocha.Hook;
window.after = () => ({}) as Mocha.Hook;
window.afterEach = () => ({}) as Mocha.Hook;
