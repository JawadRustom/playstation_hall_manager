# Project Status

## Project Summary

`playstation_hall_manager` is a Flutter prototype for tracking PlayStation hall devices and play sessions. The current implementation is a single-screen, local, in-memory application with hard-coded device and pricing data. No Firebase package, configuration, authentication, persistent storage, or production service integration is present.

## Current Development Phase

The project is in an early functional-prototype phase. The core start/end session interaction and charge calculation can be exercised in memory, but the test baseline is broken and the application is not yet ready for persistent or multi-user operation.

## Implemented Features

- Displays four hard-coded PlayStation devices with availability and hourly prices for two, three, or four players.
- Starts either a timed session (hours and minutes) or an open session for an available device.
- Stores the selected player count, hourly price, start time, session type, and optional planned duration in memory.
- Updates elapsed or remaining time every second while sessions are active and marks an expired timed session in the UI.
- Ends a session manually and calculates its charge from actual elapsed microseconds. The current formula rounds the monetary result to the nearest whole Syrian pound using positive half-up behavior; this does not match the approved truncation policy below.
- Allows a non-negative integer `finalAmount` to override the calculated charge and records an optional adjustment reason. The current prototype does not use the approved `collectedAmount` name, restrict this action by user role, or record the responsible operator.
- Preserves `calculatedAmount` and the current `finalAmount` as separate fields in each in-memory completed-session record. The approved accounting meaning and field name for the latter are `collectedAmount`.
- Keeps completed-session details in memory for the lifetime of the `HomeScreen` state.
- Preserves Arabic UI strings as UTF-8.

## Approved Business Requirements

The following rules are approved requirements, not pending decisions:

- There is no minimum billable duration.
- Billing uses actual elapsed play time without rounding the duration.
- The automatically calculated charge must be a non-negative integer number of Syrian pounds.
- The fractional part of the calculated monetary result is discarded; it is never rounded up. Examples: `240.2 -> 240`, `240.5 -> 240`, `240.9 -> 240`, and `241.9 -> 241`.
- Session monetary values must not display fractional digits or decimal separators.
- Administrators and employees may record any non-negative integer, including zero, as the amount actually collected.
- An adjustment reason is optional.
- `calculatedAmount` and `collectedAmount` must be preserved as separate fields.
- `collectedAmount` is the source for actual session cash receipts and cash-based reports.
- The responsible operator and collection timestamp must be recorded when the feature is implemented.
- A difference between calculated and collected amounts does not automatically create a debt.
- These rules apply to gaming-session accounting only.

The in-memory prototype implements actual-duration billing, accepts a non-negative integer override and optional reason, and keeps two amounts in memory. It does not implement monetary truncation: its current positive half-up formula can produce a value one pound higher than the approved result. It also uses `finalAmount` rather than `collectedAmount`, has no receipt/report consumers, does not implement users or roles, and does not record a responsible operator or distinct collection timestamp. Production changes to the financial formula, completion model, UI terminology, or downstream accounting require separate approval through the proposed implementation plan before code is changed.

## Incomplete or Planned Features

- Firebase Authentication, Firestore, Cloud Functions, and all persistent storage are planned in `AGENTS.md` but are not implemented.
- Completed sessions are collected but have no history, reporting, export, or review UI.
- Role-based authorization for administrators and employees is not implemented.
- The approved monetary truncation formula is not implemented; the current calculation rounds positive half-pound and larger fractions up.
- The completed-session model still uses `finalAmount`; migration to the approved `collectedAmount` meaning and name is not implemented.
- Collection audit data is incomplete: the responsible operator and a distinct collection timestamp are not recorded.
- Cash-based reporting does not exist, so `collectedAmount` is not yet consumed as the receipt/reporting source.
- Device inventory, availability, controller counts, and player-based prices are not configurable; they are hard-coded in `lib/main.dart`.
- Timed sessions do not auto-end, notify externally, or provide the extension action mentioned by the expiry message.
- User accounts, staff roles/permissions, operational reporting, and other production modules are not present. Their exact scope is unverified.
- Explicit application-wide RTL/localization configuration is not present; runtime behavior across supported platforms is unverified.

## Known Issues and Technical Debt

- `test/widget_test.dart` is the untouched counter-app scaffold test. It references the nonexistent `MyApp` class, so both `flutter analyze --no-pub` and `flutter test --no-pub` fail before any useful test runs.
- There are no tests protecting session transitions, input boundaries, timers, price selection, monetary truncation, integer-only collection values, or calculated-versus-collected amounts.
- UI, mutable state, clock access, billing logic, and the `CompletedSession` record are combined in `lib/main.dart`, which makes financially significant behavior difficult to test in isolation.
- `controllersCount` is stored but not displayed or enforced; every device currently offers two-, three-, and four-player sessions even when its controller count is lower.
- PlayStation 2 starts as unavailable without a corresponding active session, and the UI provides no way to change that state.
- Timed-session duration affects only the countdown display. Charges use total actual elapsed time, including time after the planned duration, until an operator manually ends the session.
- The generated README still describes a generic new Flutter project.

## Pending Architectural Decisions

The approved business requirements above are settled. The following technical and operational decisions remain unresolved and require explicit approval where required by `AGENTS.md`:

- Persistence and backend boundaries, including whether and how Firebase services will be introduced.
- Authentication implementation, staff-role representation, authorization enforcement, and audit-storage design.
- State ownership and separation of UI, session lifecycle, clock, and billing logic.
- Whether a timed-session extension starts from the original expiration time or from the moment the extension is requested.
- How overtime is handled operationally after a timed session expires.
- Rules connecting controller capacity, player count, and device availability.
- Supported locales and the required application-wide RTL behavior.

## Current Priorities

1. Obtain approval for and implement the narrowly scoped correction from current half-up calculation to the approved truncation policy while restoring a truthful passing test baseline.
2. Protect the approved billing and collection requirements with focused deterministic tests, including fractional-result boundaries and integer-only display/input cases.
3. Resolve the two outstanding timed-session extension and overtime questions before implementing those workflows.
4. Prepare an approved implementation plan before introducing persistence, authentication, Firebase, or project-wide architectural changes.

## Next Task

After `docs/plans/001-test-baseline.md` is reviewed and approved, replace the stale counter widget test, correct the production billing formula to discard every fractional Syrian pound, adopt `calculatedAmount`/`collectedAmount` terminology, and add focused tests for no minimum duration, actual elapsed time, truncation, integer-only monetary display/input, separate amounts, optional reason, and start/end behavior. Record authorization, operator/timestamp audit, and future cash-report integration as follow-up work. Do not change production code before separate implementation approval.

## Git Workflow

- Current branch: `develop` (integration branch).
- Stable baseline: `master`.
- `AGENTS.md` defines Codex as the primary development agent; Antigravity may continue only through an explicit handoff, and development is sequential unless the user directs otherwise.
- Existing uncommitted and untracked files are user-owned and must be preserved.
- No commit, push, merge, rebase, reset, branch change/creation, amend, or Git configuration change may be performed without explicit user approval.
- At the start of this policy-documentation update, the proposed plan was
  already untracked and no other working-tree changes were present.
