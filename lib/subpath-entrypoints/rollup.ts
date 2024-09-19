import type { Plugin } from "rollup";

import { compile } from "../template";

export function createRollupPlugin(
  config: Cypress.PluginConfigOptions,
): Plugin {
  return {
    name: "transform-feature",
    async transform(src: string, id: string) {
      if (/\.feature$/.test(id)) {
        return {
          code: await compile(config, src, id),
          map: null,
        };
      }
    },
  };
}

export default createRollupPlugin;
