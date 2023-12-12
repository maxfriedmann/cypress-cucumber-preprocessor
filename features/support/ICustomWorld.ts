export default interface ICustomWorld {
  tmpDir: string;
  verifiedLastRunError: boolean | undefined;
  lastRun:
    | {
        stdout: string;
        stderr: string;
        output: string;
        exitCode: number;
      }
    | undefined;

  runCypress(
    extraArgs?: string[],
    extraEnv?: Record<string, string>
  ): Promise<void>;

  runDiagnostics(
    extraArgs?: string[],
    extraEnv?: Record<string, string>
  ): Promise<void>;
}
