import type { LoaderDefinition } from "webpack";

import { compile } from "../template";

const loader: LoaderDefinition = function (data) {
  const callback = this.async();

  const config: Cypress.PluginConfigOptions = this.query as any;

  compile(config, data, this.resourcePath).then(
    (result) => callback(null, result),
    (error) => callback(error),
  );
};

export default loader;
