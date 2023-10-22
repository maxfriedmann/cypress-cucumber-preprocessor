import path from "path";
import { promises as fs } from "fs";
import assert from "assert";

export async function writeFile(filePath: string, fileContent: string) {
  await fs.mkdir(path.dirname(filePath), { recursive: true });
  await fs.writeFile(filePath, fileContent);
}

export function assertAndReturn<T>(
  value: T | null | undefined,
  msg?: string
): T {
  assert(value, msg);
  return value;
}
