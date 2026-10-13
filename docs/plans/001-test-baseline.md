# Implementation Plan: Restore Flutter Test Baseline

## Plan Metadata

- **ID:** `001`
- **Title:** `Restore Flutter test baseline`
- **Status:** `completed`
- **Date:** `2026-10-13`
- **Owner:** `Codex`
- **Approver:** `Repository owner`

> Start implementation only after required approval and a status change to
> `approved` or `in_progress`. This plan does not authorize Git operations.

## Objective

Restore a truthful, deterministic Flutter test baseline for the current
PlayStation hall prototype. Replace the stale counter-app test, isolate only the
billing/collection logic that cannot be tested reliably through the current
private widget state, and add focused regression coverage for pricing, elapsed
duration, integer-only monetary truncation, session transitions, and collected-
charge recording.

The baseline must describe and protect current behavior without silently
implementing missing authorization, audit, persistence, or operational rules.

## Current Behavior

- `test/widget_test.dart` now pumps `PlayStationApp`, verifies the Arabic title
  and four configured devices, and disposes the widget so its timer is cancelled.
- `PlayStationApp` renders `HomeScreen`, whose private state owns device
  inventory, active and completed sessions, the periodic timer, and start/end
  transitions. Pure billing/completion logic is in
  `lib/services/session_billing.dart`, and `CompletedSession` is in its own model
  file.
- Devices expose hard-coded hourly prices for two, three, and four players.
  `selectHourlyPrice` returns the corresponding price and zero for unsupported
  player counts, although the UI offers only two through four.
- Starting a session snapshots the selected player count, hourly price,
  current clock value, session type, and optional planned duration, marks the
  device unavailable, and refuses to start an unavailable/already-active device.
  `PlayStationApp` and `HomeScreen` accept the explicitly approved optional
  clock callback and default to `DateTime.now` in normal use.
- Timed input is accepted only when hours and minutes are non-negative, minutes
  are at most 59, and total minutes are greater than zero. Open sessions store a
  null planned duration.
- Elapsed time is `now - startTime`, clamped to zero for a future start time.
  Timed sessions display a countdown and an expired message, but do not
  automatically end. Billing continues to use total actual elapsed time,
  including time beyond the planned duration.
- The calculated charge is zero for zero/negative duration. For positive
  duration it uses actual elapsed microseconds, applies no minimum duration or
  duration rounding, and uses integer division to discard every fractional
  Syrian pound.
- Ending a session freezes an end time when the end dialog opens. The dialog
  defaults `collectedAmount` to the calculated amount, permits any
  non-negative integer including zero, trims an optional reason, and stores
  blank reasons as null.
- A completed in-memory record preserves the session snapshot, end time, actual
  duration, `calculatedAmount`, `collectedAmount`, and optional reason. Ending
  removes the active session and makes the device available again.
- **Approved requirements now implemented:** no minimum duration; actual elapsed
  duration without duration rounding; truncation of fractional SYP; integer-only
  calculated and collected values; collection including zero; optional trimmed
  reason; and separate calculated/collected fields in memory.
- **Approved requirements not implemented:** administrator/employee
  authorization, cash-report consumption of `collectedAmount`, responsible
  operator, and a distinct collection timestamp. `endTime` is not evidence of a
  collection timestamp. Different calculated/collected amounts still do not
  create a debt record.
- **Behavior to preserve:** current hard-coded prices and availability, price
  snapshot at session start, actual-time billing (including timed-session
  overtime), zero charge for non-positive elapsed duration, current session
  input validation, explicit manual ending, independent calculated/collected
  values, optional trimmed reason, integer-only monetary display/input, and
  in-memory-only operation.

## Scope and Non-Goals

### In Scope

- Replace the obsolete counter scaffold with a smoke test for
  `PlayStationApp`, including deterministic cleanup of its periodic timer.
- Extract charge calculation and completed-session creation into a small
  pure-Dart boundary with explicit duration/end-time inputs, then apply the
  approved truncation formula and `collectedAmount` terminology after separate
  implementation approval; do not change elapsed-duration or transition rules.
- Add deterministic unit tests for hourly-price selection, elapsed-duration
  handling, monetary truncation boundaries, and completed-session fields.
- Add focused widget tests for start validation, timed/open session starts,
  availability transitions, timer/expiry presentation, end-dialog validation,
  integer-only monetary display/input, optional adjustment reason, and manual
  completion.
- Record missing authorization, collection audit fields, and future cash-report
  consumption as uncovered approved requirements requiring later design and
  implementation.

### Non-Goals

- Implement roles, authentication, authorization, responsible-operator capture,
  or a distinct collection timestamp.
- Add Firebase, persistence, schemas, migrations, backend services, history UI,
  or production-data access.
- Decide or implement timed-session extension, overtime operations,
  auto-ending, alerts, controller-capacity enforcement, inventory changes, or
  application-wide localization/RTL configuration.
- Change prices, accepted player counts, validation rules, session transitions,
  unrelated UI copy, or Arabic encoding. The only planned billing changes are
  the separately approved truncation correction and calculated/collected naming.
- Implement cash reports, debt tracking, or accounting outside gaming sessions.
- Introduce a state-management package, dependency-injection framework, clock
  package, mocking library, integration-test layer, or other dependency.
- Fix unrelated known issues merely discovered while adding tests.

## Requirements and Acceptance Criteria

- [x] `flutter test` no longer fails because `MyApp` is undefined or because
      counter-app expectations remain.
- [x] A smoke test pumps `PlayStationApp`, verifies the Arabic screen title and
      four configured devices, and disposes the widget so no periodic timer is
      left pending.
- [x] Pure unit tests prove that 2/3/4-player selections use the existing device
      rates and characterize the current unsupported-count result of zero.
- [x] Billing tests use explicit `Duration` values and prove: zero and negative
      durations cost zero; one microsecond has no minimum charge; every positive
      fractional monetary result is truncated toward zero; representative
      seconds/minutes/full hours use actual elapsed duration; and elapsed time
      beyond a timed plan is billed from the supplied actual duration.
- [x] At a rate of `10,000` SYP/hour, expected examples include: `0 us -> 0`,
      `1 us -> 0`, `179 us -> 0`, `180 us -> 0`, `359 us -> 0`,
      `360 us -> 0`, `359 ms -> 0`, `360 ms -> 1`, `1 second -> 2`,
      `30 minutes -> 5,000`, and `1 hour -> 10,000` SYP.
- [x] At a rate of `3,600` SYP/hour, explicit duration examples prove the
      approved policy: `240.2 seconds -> 240`, `240.5 seconds -> 240`,
      `240.9 seconds -> 240`, and `241.9 seconds -> 241` SYP.
- [x] Completion tests prove negative elapsed time is clamped to zero and that
      session snapshot, end time, actual duration, `calculatedAmount`,
      `collectedAmount`, and null/non-null reason remain distinct and unchanged.
- [x] Widget tests prove valid timed and open sessions change a device from
      available to busy, show the selected player/rate and appropriate timer,
      and cannot be opened again while active.
- [x] Widget tests prove invalid timed durations (`0:00`, a negative component,
      and minutes greater than 59) show the current validation message and do
      not start a session.
- [x] Widget tests prove an expired timed session remains active, displays the
      existing expiry message, and requires manual ending.
- [x] Widget tests prove session monetary values contain neither fractional
      digits nor decimal separators; the collection input defaults to
      `calculatedAmount`; empty/non-integer/negative values are rejected; zero
      and another non-negative integer are accepted; whitespace-only reason is
      absent; a supplied reason is trimmed; and confirmation returns the device
      to available.
- [x] Tests prove `calculatedAmount` and `collectedAmount` can differ without
      creating or implying a debt record, and document that future actual cash
      receipts/reports must use `collectedAmount`.
- [x] Tests do not use real delays or external services; widget time advances
      with `WidgetTester.pump`/the test binding, and pure logic receives explicit
      timestamps/durations.
- [x] Missing role enforcement, responsible-operator capture, distinct
      collection timestamp, and cash-report integration are reported as
      follow-up gaps rather than represented by passing tests or speculative
      production changes.
- [x] No dependency, Firebase, persistence, architecture, pricing, session, or
      unrelated UI behavior changes are introduced.

## Approved Implementation Record

Steps 1–6 were implemented through the focused commits reviewed in Step 7. The
descriptions below retain the approved sequence and record the resulting state.

1. **Repair the application smoke test**
   - Change: Replaced the generated counter test with a `PlayStationApp` render
     test. Assert the current title, four device names, and initial availability
     labels; replace the app with a trivial widget at test end to dispose
     `HomeScreen` and cancel its periodic timer.
   - Verification: The focused test passes without a missing-app or pending-timer
     failure.
2. **Extract the minimum pure business boundary**
   - Change: Moved `CompletedSession` to its own model file and extracted the
     hourly-price lookup, elapsed-duration clamp, and completion-record
     construction into stateless functions in
     `lib/services/session_billing.dart`, initially without changing billing
     output. Explicit inputs are used while timers, UI state, and transition
     ownership remain in `HomeScreen`.
   - Verification: The focused extraction commit and smoke-test result were
     reviewed.
3. **Implement and protect integer-only truncation**
   - Change: Added table-driven pure-Dart tests for supported and unsupported
     player-price selection,
     non-positive duration, no minimum, microsecond truncation boundaries, the
     approved `240.2`/`240.5`/`240.9`/`241.9` examples, representative
     durations, and actual duration beyond a timed plan. The approved production
     formula now uses integer division and discards every fractional pound.
   - Verification: The focused billing suite passes all 17 implemented tests,
     including unsupported player counts returning zero.
4. **Adopt and protect collection semantics**
   - Change: Renamed the in-memory collected-value field and related parameters/
     local variables to `collectedAmount`, updated the session UI label, and
     retained non-negative integer validation including zero. Added pure tests for
     future/end-time clamping, unchanged timestamps and session snapshot, equal
     and differing calculated/collected amounts, and absent/present reason
     values. Do not add debt behavior. Keep UI trimming validation in widget
     tests.
   - Verification: The focused billing/completion tests pass and production code
     contains no stale collected-value field name.
5. **Protect start and timer lifecycle through the UI**
   - Change: Added widget tests that exercise the real dialogs for valid timed and
     open sessions, invalid duration boundaries, duplicate-start prevention,
     availability changes, elapsed/countdown display, and timed expiry without
     auto-end. Use test-controlled frame advancement, not wall-clock sleeps.
   - Verification: The focused lifecycle widget suite passes deterministically.
6. **Protect collection behavior through the UI**
   - Change: Extended lifecycle widget coverage for integer-only monetary display,
     the default collected amount, invalid/non-integer/negative collection
     values, zero and positive overrides, optional reason entry, confirmation,
     and restoration of availability. Verify record construction separately
     through the pure boundary because completed records currently have no
     user-facing history UI. Document that cash-report consumption and operator/
     timestamp capture remain follow-up work.
   - Verification: The lifecycle and billing suites pass independently and as
     part of the full suite.
7. **Run repository-level verification and review**
   - Change: Format only changed Dart files, run static analysis and the entire
     suite, then inspect the final diff/status for scope, UTF-8 Arabic text,
     generated files, secrets, and unrelated changes. Update this plan's result
     fields/handoff only if documentation updates are included in the approved
     implementation scope.
   - Verification: All commands below pass, or an exact pre-existing failure is
     recorded without being misclassified as a regression.

If implementation must differ materially from this approved approach, stop,
record the deviation under **Decisions and Assumptions**, and obtain any required
approval before broadening the scope.

## Affected Files and Components

| Path or component | Planned change | Reason |
| --- | --- | --- |
| `lib/main.dart` | Modified in Steps 2, 4, and 5; mechanically formatted before final closure | Uses the extracted pure functions and completion model, collected-amount UI terminology, and the approved optional clock seam; the later Dart 3.13.3 formatting changed no behavior. |
| `lib/models/completed_session.dart` | Added in Step 2; updated in Step 4 | Holds separate `calculatedAmount` and `collectedAmount` fields. |
| `lib/services/session_billing.dart` | Added in Step 2; corrected in Step 3 | Holds dependency-free price, duration, truncating charge, and completion construction logic with explicit inputs. |
| `test/widget_test.dart` | Modified in Step 1 | Replaces the invalid counter scaffold with the current app smoke test. |
| `test/services/session_billing_test.dart` | Added and expanded in Steps 3, 4, and 6, then completed before final closure | Covers supported and unsupported pricing, duration, truncation, and completed-record behavior. |
| `test/session_lifecycle_widget_test.dart` | Added and expanded in Steps 5 and 6 | Covers dialogs, input boundaries, timers, and start/end UI transitions. |
| `docs/status.md` and this plan | Updated in Step 7 and final closure | Reconcile documentation with the verified implementation, verification results, completed milestone, and remaining product requirements. |

No `pubspec.yaml`, lockfile, Firebase/configuration file, generated file, or
platform project file changed in Steps 1–7.

## Data, Security, and Financial Considerations

- **Data and compatibility:** Current state remains local and in-memory. The
  implemented rename to `collectedAmount` clarifies
  field meaning; there is no persisted history to migrate or recompute. Any
  future persisted schema, migration, or report integration requires separate
  approval.
- **Security and privacy:** Tests use synthetic data only. Current UI has no
  authentication or role enforcement. Do not imply that collected-amount
  entries are authorized merely because the prototype permits them.
- **Financial rules:** Preserve actual elapsed microseconds, zero for
  non-positive duration, no minimum duration, no duration rounding, hourly
  price snapshot, optional reason, and independent calculated/collected amounts.
  The implemented formula truncates every non-negative fractional result toward
  zero. Display and accept session money
  as integers only. `collectedAmount` may be any non-negative integer including
  zero, is the future cash-receipt/reporting source, and must not automatically
  create debt when it differs from `calculatedAmount`. These rules are limited
  to gaming-session accounting.
- **Required approvals or safeguards:** The repository owner approved the
  production truncation correction, collected-amount terminology, focused
  extraction, tests, and the optional clock seam used by Steps 1–6. Separate
  explicit approval and a new or updated plan remain required before
  implementing authentication, authorization, audit persistence, cash reports,
  debt handling, Firebase, or wider state ownership.

## Verification and Testing

| Check | Command or method | Expected result | Result |
| --- | --- | --- | --- |
| Smoke test | `flutter test --no-pub test/widget_test.dart` | Current app renders; no `MyApp` or pending-timer failure | `passed` — 1 test |
| Billing/completion unit tests | `flutter test --no-pub test/services/session_billing_test.dart` | Exact pricing, duration, truncation, and calculated/collected record cases pass | `passed` — 17 tests, including unsupported counts returning zero |
| Lifecycle widget tests | `flutter test --no-pub test/session_lifecycle_widget_test.dart` | Start, validation, timer/expiry, integer-only collection, and end flows pass deterministically | `passed` — 18 tests |
| Changed Dart formatting | `dart format --output=none --set-exit-if-changed lib/main.dart lib/models/completed_session.dart lib/services/session_billing.dart test/widget_test.dart test/services/session_billing_test.dart test/session_lifecycle_widget_test.dart` | No formatting changes required | `passed` — 6 files checked, 0 changes required |
| Static analysis | `flutter analyze --no-pub` | No issues; stale `MyApp` error is gone | `passed` — no issues found |
| Full test suite | `flutter test --no-pub` | All repository tests pass | `passed` — 36 tests |
| Runtime smoke check | Run the app on an available Flutter target; start and end one timed and one open session | UI behavior and Arabic text remain intact | `user-reported passed during Steps 2–5`; not rerun as a Step 7 runtime check |
| Final scope review | `git diff --check`, `git diff --stat`, and `git status --short` | Only approved files changed; no whitespace, generated, secret, or unrelated changes | `passed` — approved documentation, focused test, and mechanical `lib/main.dart` formatting changes only on `develop` |

- **Resolved pre-existing failure:** The obsolete counter scaffold and missing
  `MyApp` reference were replaced in Step 1. Both analysis and the full suite now
  pass.
- **Verified implementation behavior:** Source inspection confirms integer
  division truncates fractional SYP, completion records preserve separate
  `calculatedAmount`/`collectedAmount`, and the optional approved clock seam is
  used for session start, elapsed time, and end-dialog timestamps while defaulting
  to `DateTime.now` in production.
- **Regressions introduced by Step 7:** None. Final closure changes only
  reconcile documentation after the separately approved focused test and
  mechanical formatting changes.
- **Runtime evidence:** The repository owner reports real-device testing during
  Steps 2–5. This is retained as user-reported historical evidence and was not
  repeated or represented as a Step 7 runtime test. Focused deterministic widget
  tests cover the relevant UI workflows in the final automated verification.

## Outstanding Follow-up Requirements

These items were not implemented by plan `001`:

- Firebase Authentication and persistence.
- Role-based authorization for administrators and employees.
- Responsible-operator capture and a distinct collection timestamp.
- Cash reporting sourced from `collectedAmount`.
- Timed/open session extensions. A positive timed extension must be added to the
  previous scheduled expiration, not to the time the operator presses the
  extension action. An open extension must preserve the original session start
  timestamp.
- Background and lock-screen expiry alarms and notifications. Stopping an alarm
  must not automatically end or pause the session. Cross-platform capability
  must not be claimed until platform restrictions are evaluated.
- Arabic/English localization with mixed-direction text handling.
- Light and dark theming.

Each item requires separately approved scope before implementation.

## Risks and Rollback

| Risk | Mitigation | Rollback or recovery |
| --- | --- | --- |
| Extraction changes more than the separately approved truncation correction or alters a timestamp boundary. | Move the current formula first, then make the single integer-arithmetic correction under explicit implementation approval; compare the focused diff and exact boundary tests. | Revert the extraction/call-site changes and restore the prior inline code; do not describe the restored half-up behavior as policy-compliant. |
| Tests accidentally retain half-up expectations or miss fractions close to the next pound. | Assert the approved examples plus `180 us -> 0`, `359 us -> 0`, `360 us -> 0`, `359 ms -> 0`, and `360 ms -> 1` at 10,000 SYP/hour. | Correct the expectations to truncation; never change the approved formula merely to satisfy obsolete tests. |
| Renaming `finalAmount` to `collectedAmount` is treated as cosmetic and downstream cash semantics are lost. | Assert separate fields and differing values, document `collectedAmount` as the cash source, and search changed session code/tests for stale terminology. | Restore the last reviewed code, then reapply the rename coherently after reviewing every consumer; persisted migration remains out of scope. |
| Wall-clock/timer use makes widget tests flaky or leaves periodic timers pending. | Advance time through the Flutter test binding, avoid real waits, and explicitly dispose `HomeScreen` at each test's end. | Narrow unstable tests to pure explicit-time coverage while documenting the UI gap; do not add a clock dependency without approval. |
| Private widget state prevents direct verification of completed records. | Test record construction through the extracted pure boundary and UI transitions through public widget behavior; do not expose private state solely for tests. | Remove any unnecessary test-only API and retain black-box widget plus pure unit coverage. |
| Refactoring grows into new state architecture. | Limit extraction to stateless functions/value types; leave mutable collections and lifecycle ownership in `HomeScreen`. | Stop, record the deviation, and request architecture approval before continuing. |
| Passing tests overstate unimplemented security/audit/reporting requirements. | Explicitly identify authorization, responsible operator, collection timestamp, and cash-report integration as uncovered follow-up requirements; add no misleading passing placeholders. | Correct test names/docs and open a separately approved implementation plan for those requirements. |
| Existing Arabic text or RTL behavior is damaged during edits. | Preserve UTF-8, avoid broad rewrites, assert key Arabic text, and inspect the final diff/runtime. | Restore only affected strings from the reviewed pre-change source. |

Because the planned production changes are localized and no data migration is
involved, rollback is a file-level restoration of the prior inline logic and
test files. No database or external-service recovery is required.

## Implementation Checklist

- [x] Required approvals are recorded and the plan status permits implementation.
- [x] Relevant source, tests, documentation, branch, and working tree were reviewed for planning.
- [x] Explicit implementation approval covers the production truncation formula, `collectedAmount` rename, related UI terminology, and narrow extraction.
- [x] Each proposed step was implemented and independently verified.
- [x] Changed Dart files were formatted, where applicable; the complete
      non-writing check reports zero changes required across all six files.
- [x] Targeted tests, static analysis, and the full test suite were run where feasible.
- [x] UI changes received user-reported real-device testing during Steps 2–5;
      Step 7 did not rerun a live-device test.
- [x] Pre-existing failures were distinguished from regressions.
- [x] Missing authorization, collection-audit, and cash-report requirements remain visible follow-up work.
- [x] Deviations from the approved plan were recorded and approved where required.
- [x] The final diff and Git status were reviewed for scope, secrets, encoding damage,
      accidental generated files, and unrelated changes.
- [x] Documentation and handoff details reflect the final implementation state.

## Decisions and Assumptions

| Date | Decision, assumption, or deviation | Rationale | Approval/status |
| --- | --- | --- | --- |
| `2026-10-13` | Use actual unrounded duration, require a non-negative integer calculated charge, and discard every fractional pound without rounding up. | The owner clarified the final gaming-session billing policy with explicit examples. | `approved and implemented in Step 3` |
| `2026-10-13` | Preserve separate `calculatedAmount` and `collectedAmount`; allow authorized administrators/employees to record any non-negative integer including zero; use collection for future cash receipts/reports; do not infer debt from a difference. | These are the clarified accounting semantics for gaming sessions only. | `field/UI semantics implemented in Step 4; authorization/reporting remain follow-up` |
| `2026-10-13` | Keep the adjustment reason optional and eventually record the responsible operator and collection timestamp. | These are approved requirements, but current identity/audit infrastructure is absent. | `approved policy; proposed follow-up implementation` |
| `2026-10-13` | Extract stateless billing/completion functions and a completion value type, while leaving UI/state ownership intact. | This is the smallest boundary that enables direct deterministic coverage without a dependency or project-wide architecture change. | `approved and implemented in Step 2` |
| `2026-10-13` | Use black-box widget tests for session transitions and Flutter-controlled time for timer displays. | Private state should not be exposed solely for tests, and real waits would be nondeterministic. | `approved and implemented in Steps 5–6` |
| `2026-10-13` | Add an optional clock callback to `PlayStationApp` and `HomeScreen`, default it to `DateTime.now`, and use it for session start, elapsed-time, and end-dialog timestamps. | Direct `DateTime.now()` does not advance with `WidgetTester.pump`; the minimal seam keeps production behavior unchanged while Step 5 timer tests use synchronized deterministic time. | `explicitly approved by repository owner for Step 5` |
| `2026-10-13` | Do not add passing tests for role enforcement, responsible-operator capture, distinct collection timestamp, or cash-report consumption yet. | Those approved requirements are not implemented and depend on unresolved authentication/audit/reporting design; tests must remain truthful. | `proposed follow-up` |
| `2026-10-13` | Treat controller-count mismatch, initially unavailable PlayStation 2, timed extension/overtime operations, missing history UI, and global RTL/localization as existing issues outside this baseline. | Fixing them would change behavior or broaden scope beyond testing restoration. | `proposed non-goals` |
| `2026-10-13` | A positive timed-session extension is added to the previous scheduled expiration, not the button-press time; an open-session extension preserves the original start timestamp. | This preserves scheduled time and the full open-session elapsed history. | `approved requirement; not implemented` |
| `2026-10-13` | Stopping an expiry alarm must not end or pause a session, and cross-platform alarm capability must not be claimed before platform restrictions are evaluated. | Alarm acknowledgement and session lifecycle are separate operations; platform background behavior is constrained. | `approved requirement; not implemented` |
| `2026-10-13` | Keep plan `001` in progress after Step 7. | The unsupported-player-count test is missing and `lib/main.dart` fails the non-writing format check; this documentation-only task cannot change Dart or tests. | `verified closure decision` |
| `2026-10-13` | Add focused coverage proving unsupported player counts return zero. | This completes the originally approved price-selection acceptance criterion without changing production pricing or player-count rules. | `separately approved and verified before final closure` |
| `2026-10-13` | Apply Dart 3.13.3 formatting mechanically to `lib/main.dart`. | The full 174-line diff contained only line wrapping, indentation, and blank-line changes; no symbols, strings, calculations, control flow, or behavior changed. | `separately approved and verified before final closure` |
| `2026-10-13` | Close plan `001` after rerunning the complete Step 7 matrix. | All applicable acceptance criteria and checklist items pass; unresolved product requirements remain explicitly out of scope. | `approved and verified; plan completed` |

## Agent Handoff

- **Outcome:** Plan `001` is complete. Steps 1–6 and both closure follow-ups are
  implemented, and the complete Step 7 verification matrix passes.
- **Files:** The final working tree contains the approved documentation updates,
  the focused unsupported-player-count test, and mechanical Dart 3.13.3
  formatting of `lib/main.dart`. No dependency, Firebase/configuration,
  generated, or unrelated file changed.
- **Decisions:** Fractional SYP is truncated; `calculatedAmount` and
  `collectedAmount` are separate; the approved clock seam is present. Historical
  approvals and the later focused test/formatter approvals remain recorded
  above. Future product requirements remain outside this completed baseline.
- **Verification:** All three targeted test commands passed (1, 17, and 18
  tests), `flutter analyze --no-pub` reported no issues, and the full suite
  passed all 36 tests. The complete non-writing formatter check passed for six
  files, and final Git/diff checks passed. Real-device testing from Steps 2–5 is
  recorded as user-reported evidence, not as a Step 7 runtime execution.
- **Remaining:** Authentication, persistence, authorization, operator/timestamp
  audit, cash reporting, extensions, alarms/notifications, localization, and
  theming remain separately scoped product work; none blocks this plan.
- **Completed plan:** `docs/plans/001-test-baseline.md`
- **Git:** `develop`; four expected files are modified and no commit or push was
  performed.
- **Suggested commit:** `test(billing): complete verified test baseline`
