import type { LoaderDefinition } from "webpack";

import { compile } from "../template";

const loader: LoaderDefinition = function (data) {
  const callback = this.async();

  compile(this.query as any, data, this.resourcePath).then(
    (result) => callback(null, result),
    (error) => callback(error),
  );
};

export default loader;
