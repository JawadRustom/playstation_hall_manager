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
- Ends a session manually, calculates its charge from actual elapsed microseconds, and rounds only the monetary result to the nearest whole Syrian pound.
- Allows a non-negative final charge to override the calculated charge and records an optional adjustment reason. The current prototype does not restrict this action by user role or record the adjusting user's identity.
- Preserves the calculated amount and approved final amount as separate fields in each in-memory completed-session record.
- Keeps completed-session details in memory for the lifetime of the `HomeScreen` state.
- Preserves Arabic UI strings as UTF-8.

## Approved Business Requirements

The following rules are approved requirements, not pending decisions:

- There is no minimum billable duration.
- Billing uses actual elapsed play time without rounding the duration.
- Only the calculated monetary amount is rounded, to the nearest Syrian pound.
- Administrators and employees may manually adjust the final charge.
- An adjustment reason is optional.
- The calculated amount and approved final amount must be preserved separately.
- The adjusting user's identity and the adjustment timestamp must be recorded.

The in-memory prototype implements the duration and monetary rounding rules, permits manual final-charge adjustment without role enforcement, accepts an optional reason, and preserves both amounts separately. It does not implement users or roles, and it does not record the adjusting user's identity or a distinct adjustment timestamp.

## Incomplete or Planned Features

- Firebase Authentication, Firestore, Cloud Functions, and all persistent storage are planned in `AGENTS.md` but are not implemented.
- Completed sessions are collected but have no history, reporting, export, or review UI.
- Role-based authorization for administrators and employees is not implemented.
- Adjustment audit data is incomplete: the adjusting user's identity and a distinct adjustment timestamp are not recorded.
- Device inventory, availability, controller counts, and player-based prices are not configurable; they are hard-coded in `lib/main.dart`.
- Timed sessions do not auto-end, notify externally, or provide the extension action mentioned by the expiry message.
- User accounts, staff roles/permissions, operational reporting, and other production modules are not present. Their exact scope is unverified.
- Explicit application-wide RTL/localization configuration is not present; runtime behavior across supported platforms is unverified.

## Known Issues and Technical Debt

- `test/widget_test.dart` is the untouched counter-app scaffold test. It references the nonexistent `MyApp` class, so both `flutter analyze --no-pub` and `flutter test --no-pub` fail before any useful test runs.
- There are no tests protecting session transitions, input boundaries, timers, price selection, rounding, or final-charge adjustments.
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

1. Restore a truthful passing test baseline without changing current business behavior.
2. Protect the approved billing and adjustment requirements with focused deterministic tests, including boundary cases.
3. Resolve the two outstanding timed-session extension and overtime questions before implementing those workflows.
4. Prepare an approved implementation plan before introducing persistence, authentication, Firebase, or project-wide architectural changes.

## Next Task

Replace the stale counter widget test with tests for the current `PlayStationApp`, then add focused tests that lock down the approved no-minimum-duration, actual-elapsed-time, monetary-rounding, separate-amount, optional-reason, and start/end session behavior. Record the missing user/timestamp audit implementation as follow-up work; do not change the approved rules while establishing this baseline.

## Git Workflow

- Current branch: `develop` (integration branch).
- Stable baseline: `master`.
- `AGENTS.md` defines Codex as the primary development agent; Antigravity may continue only through an explicit handoff, and development is sequential unless the user directs otherwise.
- Existing uncommitted and untracked files are user-owned and must be preserved.
- No commit, push, merge, rebase, reset, branch change/creation, amend, or Git configuration change may be performed without explicit user approval.
- At the start of this documentation task, the working tree was clean.
