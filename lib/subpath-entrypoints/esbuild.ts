import fs from "node:fs/promises";

import type esbuild from "esbuild";

import { compile } from "../template";

export function createEsbuildPlugin(
  configuration: Cypress.PluginConfigOptions,
): esbuild.Plugin {
  return {
    name: "feature",
    setup(build) {
      build.onLoad({ filter: /\.feature$/ }, async (args) => {
        const content = await fs.readFile(args.path, "utf8");

        return {
          contents: await compile(configuration, content, args.path),
          loader: "js",
        };
      });
    },
  };
}

export default createEsbuildPlugin;
