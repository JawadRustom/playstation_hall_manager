# AGENTS.md

## Purpose and scope

These are the permanent repository rules for AI coding agents. They apply to the
entire repository. Task prompts and approved implementation plans may add
constraints, but must not silently override these safety rules.

Keep task-specific requirements, investigation notes, and progress in the task
plan rather than expanding this file.

## Repository context

- This is a Flutter prototype for managing PlayStation hall devices, timed or
  open sessions, player-based pricing, elapsed time, and final charges.
- The current application is local and in-memory. Firebase Authentication,
  Firestore, and Cloud Functions are planned but are not yet the established
  implementation.
- `master` is the stable baseline and `develop` is the integration branch.
- Codex is the primary development agent; Antigravity may continue work through
  an explicit handoff. Development is sequential unless the user says otherwise.
- Preserve Arabic UI text, right-to-left behavior where applicable, and UTF-8
  encoding.

## Before changing code

1. Read this file, the user's task, and any relevant files under `docs/`,
   including the active implementation plan when one exists.
2. Inspect the relevant source, tests, Git branch, and working-tree status.
3. Treat existing uncommitted or untracked files as user-owned. Do not overwrite,
   revert, delete, or reformat unrelated changes.
4. Confirm the requested scope and identify behavior that must remain unchanged.
5. If required documentation or an approved plan is missing, report that fact;
   create it only when the task authorizes documentation changes.

## Approval and operational safety

- Never commit, push, merge, rebase, reset, switch or create branches, amend
  commits, or change Git configuration without explicit user approval.
- Never add, remove, upgrade, or replace a dependency, SDK, plugin, or build tool
  without explicit approval. Do not run commands that may rewrite dependency
  resolution, such as `flutter pub add` or `flutter pub upgrade`, unapproved.
- Obtain explicit approval before introducing or changing project-wide
  architecture, state management, navigation, dependency injection, persistence,
  or generated-code conventions.
- Obtain explicit approval before adding or changing Firebase integration,
  configuration, data schemas, indexes, security rules, Authentication behavior,
  Cloud Functions, emulator configuration, migrations, or deployments.
- Never access, modify, seed, or delete production data unless the user explicitly
  authorizes that exact operation. Prefer emulators or test doubles.
- Never expose or commit secrets, service-account keys, tokens, `.env` contents,
  customer data, or credentials.
- Do not perform destructive operations or broad automated rewrites unless they
  are explicitly requested and their exact scope has been verified.

## Preserve behavior and business rules

- Preserve existing functionality unless the accepted task explicitly changes
  it. Prefer the smallest coherent change and avoid unrelated cleanup.
- Treat prices, session duration, billing calculations, rounding, final-amount
  adjustments, and session start/end transitions as financial business rules.
- Do not change financial behavior from assumptions alone. Record the current
  behavior, obtain approval for the intended rule, and protect changes with
  focused tests, including boundary cases.
- Preserve stored or displayed audit information when changing completed-session
  behavior. Do not silently recompute historical prices from current rates.

## Architecture and code quality

- Evaluate the existing code before proposing abstractions. Do not impose Clean
  Architecture, MVVM, a state-management library, or another framework by
  default.
- Keep widgets focused on presentation and UI interaction. Extract reusable or
  financially significant logic into testable Dart code when the task warrants
  it.
- Keep infrastructure access out of widgets. When Firebase is approved, place
  its access behind explicit, testable boundaries appropriate to the codebase.
- Prefer immutable data, explicit inputs and outputs, constructor injection at
  external boundaries, and clear names over global mutable state or hidden work.
- Follow Dart null-safety and repository lint rules. Avoid unchecked `dynamic`,
  unjustified lint suppressions, dead code, speculative generalization, and
  duplicate sources of truth.
- Keep changes readable and localized. Add comments for intent or non-obvious
  constraints, not to narrate straightforward code.
- Preserve the established formatting and encoding of files. Do not alter Arabic
  strings through lossy terminal or encoding conversions.

## When an implementation plan is required

Create or update a written plan before implementation when a task involves any
of the following:

- multiple coordinated behavioral changes or a broad multi-file refactor;
- architecture, state ownership, navigation, persistence, or a new dependency;
- Firebase schema, rules, Authentication, Functions, migrations, or deployment;
- financial rules, data compatibility, security, destructive operations, or a
  rollback concern;
- material ambiguity, staged delivery, or work likely to require an agent handoff.

A separate plan is normally unnecessary for a small localized fix, a focused
test, a documentation-only edit, or a mechanical change with obvious behavior.
For those tasks, state a short approach in the working update.

Plans should remain concise and include objective, acceptance criteria, current
behavior, scope and non-goals, proposed steps, affected areas, risks, verification,
and a checklist. Update the plan when implementation materially diverges; do not
silently broaden scope.

## Testing and verification

- Add or update tests for changed behavior. Prefer unit tests for pure business
  logic, widget tests for rendering and interaction, and integration tests only
  for important cross-boundary workflows.
- Mirror relevant `lib/` paths under `test/` where practical. Tests must be
  deterministic and must not depend on production services or real wall-clock
  timing when a controllable clock is feasible.
- Format changed Dart files, then run targeted tests, `flutter analyze`, and the
  full `flutter test` suite when feasible.
- For UI changes, also perform a focused runtime smoke check using hot reload or
  restart when a Flutter runtime is available.
- For Firebase work, verify rules and behavior with emulators or approved test
  doubles. Never use production as a test environment.
- Do not apply automated fixes blindly. Review their scope first.
- If a check cannot run or fails for a pre-existing reason, report the exact
  command, result, and impact. Never claim a check passed when it was not run.

## Completion and handoff

Before declaring a task complete, review the diff for scope, regressions,
accidental generated files, encoding damage, secrets, and unapproved dependency
or configuration changes. Recheck Git status. Do not commit or push.

Use this handoff format for both Codex and Antigravity:

- **Outcome:** what changed and why.
- **Files:** files changed; explicitly note unrelated pre-existing changes.
- **Decisions:** approved decisions, assumptions, and preserved behavior.
- **Verification:** exact checks run and their results; list checks not run.
- **Remaining:** open work, risks, blockers, and the active plan path if any.
- **Git:** current branch and concise working-tree status.
- **Suggested commit:** a Conventional Commit message, without executing it.
