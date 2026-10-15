/** Canonical binary name for command examples, completion, and process labels. */
function resolveCliName(): string {
  const invoked = process.argv[1] ?? "";
  if (invoked.includes("capaticlaw")) return "capaticlaw";
  return "capaticlaw";
}
export const CLI_NAME = resolveCliName();
