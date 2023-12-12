import { setWorldConstructor } from "@cucumber/cucumber";
import path from "path";
import childProcess from "child_process";
import { PassThrough, Readable } from "stream";
import { WritableStreamBuffer } from "stream-buffers";
import { bin } from "../../package.json";
import ICustomWorld from "./ICustomWorld";

const projectPath = path.join(__dirname, "..", "..");

const isWin = process.platform === "win32";

function combine(...streams: Readable[]) {
  return streams.reduce<PassThrough>((combined, stream) => {
    stream.pipe(combined, { end: false });
    stream.once(
      "end",
      () => streams.every((s) => s.readableEnded) && combined.emit("end")
    );
    return combined;
  }, new PassThrough());
}

export default class CustomWorld implements ICustomWorld {
  tmpDir!: string;
  verifiedLastRunError: boolean | undefined;
  lastRun:
    | {
        stdout: string;
        stderr: string;
        output: string;
        exitCode: number;
      }
    | undefined;

  runCypress(extraArgs: string[] = [], extraEnv: Record<string, string> = {}) {
    return this.runCommand({
      cmd: path.join(
        projectPath,
        "node_modules",
        ".bin",
        isWin ? "cypress.cmd" : "cypress"
      ),
      args: ["run", ...extraArgs],
      extraEnv: {
        NO_COLOR: "1",
        ...extraEnv,
      },
    });
  }

  runDiagnostics(
    extraArgs: string[] = [],
    extraEnv: Record<string, string> = {}
  ) {
    return this.runCommand({
      cmd: "node",
      args: [
        path.join(projectPath, bin["cypress-cucumber-diagnostics"]),
        ...extraArgs,
      ],
      extraEnv,
    });
  }

  async runCommand({
    cmd,
    args = [],
    extraEnv = {},
  }: {
    cmd: string;
    args: string[];
    extraEnv: Record<string, string>;
  }) {
    const child = childProcess.spawn(cmd, args, {
      stdio: ["ignore", "pipe", "pipe"],
      cwd: this.tmpDir,
      env: {
        ...process.env,
        ...extraEnv,
      },
    });

    const combined = combine(child.stdout, child.stderr);

    if (process.env.DEBUG) {
      child.stdout.pipe(process.stdout);
      child.stderr.pipe(process.stderr);
    }

    const stdoutBuffer = child.stdout.pipe(new WritableStreamBuffer());
    const stderrBuffer = child.stderr.pipe(new WritableStreamBuffer());
    const outputBuffer = combined.pipe(new WritableStreamBuffer());

    const exitCode = await new Promise<number>((resolve) => {
      child.on("close", resolve);
    });

    const stdout = stdoutBuffer.getContentsAsString() || "";
    const stderr = stderrBuffer.getContentsAsString() || "";
    const output = outputBuffer.getContentsAsString() || "";

    this.verifiedLastRunError = false;

    this.lastRun = {
      stdout,
      stderr,
      output,
      exitCode,
    };
  }
}

setWorldConstructor(CustomWorld);
