# Project Status

## Project Summary

`playstation_hall_manager` is a Flutter prototype for tracking PlayStation hall devices and play sessions. The current implementation is a single-screen, local, in-memory application with hard-coded device and pricing data. No Firebase package, configuration, authentication, persistent storage, or production service integration is present.

## Current Development Phase

The core start/end workflow, timer presentation, billing calculation, and
collection entry are implemented and protected by a passing automated test
baseline. Implementation plan `001` is completed: all applicable acceptance
criteria pass, including unsupported-player-count coverage and formatter
verification.

## Implemented Features

- Displays four hard-coded PlayStation devices with availability and hourly prices for two, three, or four players.
- Starts either a timed session (hours and minutes) or an open session for an available device.
- Stores the selected player count, hourly price, start time, session type, and optional planned duration in memory.
- Uses an optional injected clock in `PlayStationApp` and `HomeScreen` for
  deterministic session start, elapsed-time, and end-dialog timestamps; normal
  application use still defaults to `DateTime.now`.
- Updates elapsed or remaining time every second while sessions are active. An
  expired timed session stays active until an operator ends it manually.
- Ends a session manually and calculates its charge from actual elapsed
  microseconds with no minimum duration or duration rounding. Integer division
  discards every fractional Syrian pound instead of rounding it up.
- Accepts any non-negative integer, including zero, as `collectedAmount` and
  records an optional trimmed adjustment reason.
- Preserves `calculatedAmount` and `collectedAmount` as separate fields in each
  in-memory completed-session record.
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

The in-memory prototype implements the billing, collection-name, integer-entry,
optional-reason, and separate-amount rules. It does not yet implement identity,
authorization, collection audit metadata, persistence, or cash reporting.

## Outstanding Requirements

- Firebase Authentication and persistence remain unimplemented. Any Firebase
  configuration, schema, rule, Function, migration, emulator, or deployment
  work requires separate approval.
- Role-based authorization for administrators and employees is not implemented.
- Completed sessions do not record the responsible operator or a distinct
  collection timestamp; `endTime` is not a substitute for collection audit
  time.
- Cash reporting is not implemented. Future cash reports must use
  `collectedAmount`, not `calculatedAmount`.
- Timed and open session extensions are not implemented. For a timed extension,
  a positive operator-selected duration must be added to the previous scheduled
  expiration, not to the instant the extension button is pressed. Extending an
  open session must preserve its original start timestamp.
- Background or lock-screen expiry alarms and notifications are not
  implemented. Stopping an expiry alarm must not automatically end or pause the
  session. Cross-platform alarm capability must not be claimed until platform
  restrictions have been evaluated.
- Arabic/English localization and mixed-direction text handling are not
  implemented as an application-wide system.
- Light and dark themes are not implemented as selectable application themes.
- Completed sessions have no history, reporting, export, or review UI.
- Device inventory, availability, controller counts, and player-based prices
  remain hard-coded in `lib/main.dart`.

## Verification Status

Step 7 verification on `2026-10-13` produced these results:

- `flutter test --no-pub test/widget_test.dart`: passed (`1` test).
- `flutter test --no-pub test/services/session_billing_test.dart`: passed
  (`17` tests), including unsupported player counts returning zero.
- `flutter test --no-pub test/session_lifecycle_widget_test.dart`: passed
  (`18` tests).
- `flutter analyze --no-pub`: passed with no issues.
- `flutter test --no-pub`: passed (`36` tests).
- `git diff --check`: passed before and after documentation reconciliation.
- `git status --short`: contains only the four expected approved changes on
  `develop`.
- The complete non-writing Dart format check passed for all six changed or
  relevant Dart files with zero changes required.

The obsolete `MyApp` counter test failure is resolved. The smoke test now pumps
`PlayStationApp`, checks the Arabic title and four configured devices, and
disposes the widget. Billing and lifecycle tests cover the implemented billing,
collection, validation, deterministic timer, expiry, and manual-end behavior.

The repository owner reports real-device testing during Steps 2–5. That record
is historical user-reported evidence; Step 7 did not perform a new live-device
runtime test. The final automated verification and scope review satisfy plan
`001`, which is now completed.

## Known Issues and Technical Debt

- `controllersCount` is stored but not displayed or enforced; every device currently offers two-, three-, and four-player sessions even when its controller count is lower.
- PlayStation 2 starts as unavailable without a corresponding active session, and the UI provides no way to change that state.
- Timed-session duration affects only the countdown display. Charges use total actual elapsed time, including time after the planned duration, until an operator manually ends the session.
- UI state and session lifecycle ownership remain in `HomeScreen`; only the
  completion value and pure billing functions have been extracted.
- The generated README still describes a generic new Flutter project.

## Pending Architectural Decisions

The approved business requirements above are settled. The following technical and operational decisions remain unresolved and require explicit approval where required by `AGENTS.md`:

- Persistence and backend boundaries, including whether and how Firebase services will be introduced.
- Authentication implementation, staff-role representation, authorization enforcement, and audit-storage design.
- State ownership and any broader separation of UI and session lifecycle logic.
- Platform-specific restrictions and delivery guarantees for background or
  lock-screen alarms and notifications.
- How overtime is handled operationally after a timed session expires.
- Rules connecting controller capacity, player count, and device availability.
- Localization architecture, supported Arabic/English content, mixed-direction
  text handling, and light/dark theme design.

## Current Priorities

1. Treat the completed test baseline as the regression foundation for future
   work.
2. Scope the outstanding authentication, persistence, authorization, audit,
   reporting, extension/alarm, localization, and theming requirements before
   implementation.
3. Keep future financial, persistence, security, and architectural work behind
   separately approved implementation plans.

## Next Task

Select and approve the next product milestone separately. This status update
does not start a feature, choose among the outstanding priorities, or authorize
production changes beyond the completed plan `001` scope.

## Git Workflow

- Current branch: `develop` (integration branch).
- Stable baseline: `master`.
- `AGENTS.md` defines Codex as the primary development agent; Antigravity may continue only through an explicit handoff, and development is sequential unless the user directs otherwise.
- Existing uncommitted and untracked files are user-owned and must be preserved.
- No commit, push, merge, rebase, reset, branch change/creation, amend, or Git configuration change may be performed without explicit user approval.
- Final plan `001` closure preserves the approved documentation updates, focused
  unsupported-count test, and mechanical `lib/main.dart` formatting change.
