import Parser from "./parser";

type Entry<T> = {
  [K in keyof T]: [K, T[K]];
}[keyof T];

export type ConfigurationEntry = Entry<Cypress.TestConfigOverrides> & {};

export function tagToCypressOptions(tag: string): ConfigurationEntry {
  return new Parser(tag).parse() as any;
}

export function looksLikeOptions(tag: string) {
  return tag.includes("(");
}
