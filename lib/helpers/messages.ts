import type * as messages from "@cucumber/messages";

export type StrictTimestamp = {
  seconds: number;
  nanos: number;
};

export function createTimestamp(): StrictTimestamp {
  const now = new Date().getTime();

  const seconds = Math.floor(now / 1_000);

  const nanos = (now - seconds * 1_000) * 1_000_000;

  return {
    seconds,
    nanos,
  };
}

export function duration(
  start: StrictTimestamp,
  end: StrictTimestamp,
): StrictTimestamp {
  return {
    seconds: end.seconds - start.seconds,
    nanos: end.nanos - start.nanos,
  };
}

export function durationToNanoseconds(duration: StrictTimestamp): number {
  return Math.floor(duration.seconds * 1_000_000_000 + duration.nanos);
}

export function removeDuplicatedStepDefinitions(
  envelopes: messages.Envelope[],
) {
  const seenDefinitions: {
    id: string;
    uri: string;
    line: number;
    column: number;
  }[] = [];

  const findSeenStepDefinition = (stepDefinition: messages.StepDefinition) =>
    seenDefinitions.find((seenDefinition) => {
      return (
        seenDefinition.uri === stepDefinition.sourceReference.uri &&
        seenDefinition.line === stepDefinition.sourceReference.location?.line &&
        seenDefinition.column ===
          stepDefinition.sourceReference.location?.column
      );
    });

  for (let i = 0; i < envelopes.length; i++) {
    const { stepDefinition } = envelopes[i];

    if (
      stepDefinition &&
      stepDefinition.sourceReference.uri !== "not available"
    ) {
      const seenDefinition = findSeenStepDefinition(stepDefinition);

      if (seenDefinition) {
        // Remove this from the stack.
        envelopes.splice(i, 1);
        // Make sure we iterate over the "next".
        i--;

        // Find TestCase's in which this is used.
        for (let x = i; x < envelopes.length; x++) {
          const { testCase } = envelopes[x];

          if (testCase) {
            for (const testStep of testCase.testSteps) {
              // Replace ID's of spliced definition with ID of the prevously seen definition.
              testStep.stepDefinitionIds = testStep.stepDefinitionIds?.map(
                (stepDefinitionId) =>
                  stepDefinitionId.replace(
                    stepDefinition.id,
                    seenDefinition.id,
                  ),
              );
            }
          }
        }
      } else {
        seenDefinitions.push({
          id: stepDefinition.id,
          uri: stepDefinition.sourceReference.uri!,
          line: stepDefinition.sourceReference.location!.line,
          column: stepDefinition.sourceReference.location!.column!,
        });
      }
    }
  }
}
