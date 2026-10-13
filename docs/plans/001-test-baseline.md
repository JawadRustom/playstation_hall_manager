# Implementation Plan: Restore Flutter Test Baseline

## Plan Metadata

- **ID:** `001`
- **Title:** `Restore Flutter test baseline`
- **Status:** `in_progress`
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

- `test/widget_test.dart` imports `lib/main.dart` but pumps nonexistent `MyApp`,
  then expects counter UI that the application does not contain. The known
  analyzer/test failure therefore predates this plan.
- `PlayStationApp` renders `HomeScreen`, whose private state owns the device
  inventory, active and completed sessions, wall-clock access, periodic timer,
  price selection, billing calculation, and start/end transitions.
- Devices expose hard-coded hourly prices for two, three, and four players.
  `getHourlyPrice` returns the corresponding price and currently returns zero
  for unsupported player counts, although the UI offers only two through four.
- Starting a session snapshots the selected player count, hourly price,
  `DateTime.now()`, session type, and optional planned duration, marks the device
  unavailable, and refuses to start an unavailable/already-active device.
- Timed input is accepted only when hours and minutes are non-negative, minutes
  are at most 59, and total minutes are greater than zero. Open sessions store a
  null planned duration.
- Elapsed time is `now - startTime`, clamped to zero for a future start time.
  Timed sessions display a countdown and an expired message, but do not
  automatically end. Billing continues to use total actual elapsed time,
  including time beyond the planned duration.
- The calculated charge is zero for zero/negative duration. For positive
  duration it uses actual elapsed microseconds, applies no minimum duration or
  duration rounding, and currently rounds the resulting charge to a whole
  Syrian pound using positive half-up behavior. This current formula does not
  comply with the approved truncation rule.
- Ending a session freezes an end time when the end dialog opens. The dialog
  defaults the current `finalAmount` to the calculated amount, permits any
  non-negative integer including zero, trims an optional reason, and stores
  blank reasons as null.
- A completed in-memory record preserves the session snapshot, end time, actual
  duration, `calculatedAmount`, current `finalAmount`, and optional reason.
  Ending removes the active session and makes the device available again. The
  current model does not yet use the approved `collectedAmount` name/meaning.
- **Approved requirements already reflected by current behavior:** no minimum
  billable duration; actual elapsed duration is not rounded; calculated values
  and operator-entered values are non-negative integers at the model/UI
  boundary; zero may be entered; the reason is optional; and two amounts are
  stored separately in memory.
- **Approved requirements not implemented:** administrator/employee
  authorization is not enforced; fractional calculated money is rounded rather
  than discarded; `finalAmount` has not been renamed/defined as
  `collectedAmount`; no receipt/report consumer uses `collectedAmount`; and the
  responsible operator plus a distinct collection timestamp are not recorded.
  The existing `endTime` is not evidence of a collection timestamp. Differences
  between calculated and entered amounts have no debt behavior today, and the
  approved rule says they must not automatically create debts in future work.
- **Behavior to preserve:** current hard-coded prices and availability, price
  snapshot at session start, actual-time billing (including timed-session
  overtime), zero charge for non-positive elapsed duration, current session
  input validation, explicit manual ending, independent calculated/collected
  values, optional trimmed reason, integer-only monetary display/input, and
  in-memory-only operation. The current half-up monetary formula is explicitly
  not behavior to preserve once the production correction is approved.

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

- [ ] `flutter test` no longer fails because `MyApp` is undefined or because
      counter-app expectations remain.
- [ ] A smoke test pumps `PlayStationApp`, verifies the Arabic screen title and
      four configured devices, and disposes the widget so no periodic timer is
      left pending.
- [ ] Pure unit tests prove that 2/3/4-player selections use the existing device
      rates and characterize the current unsupported-count result of zero.
- [ ] Billing tests use explicit `Duration` values and prove: zero and negative
      durations cost zero; one microsecond has no minimum charge; every positive
      fractional monetary result is truncated toward zero; representative
      seconds/minutes/full hours use actual elapsed duration; and elapsed time
      beyond a timed plan is billed from the supplied actual duration.
- [ ] At a rate of `10,000` SYP/hour, expected examples include: `0 us -> 0`,
      `1 us -> 0`, `179 us -> 0`, `180 us -> 0`, `359 us -> 0`,
      `360 us -> 0`, `359 ms -> 0`, `360 ms -> 1`, `1 second -> 2`,
      `30 minutes -> 5,000`, and `1 hour -> 10,000` SYP.
- [ ] At a rate of `3,600` SYP/hour, explicit duration examples prove the
      approved policy: `240.2 seconds -> 240`, `240.5 seconds -> 240`,
      `240.9 seconds -> 240`, and `241.9 seconds -> 241` SYP.
- [ ] Completion tests prove negative elapsed time is clamped to zero and that
      session snapshot, end time, actual duration, `calculatedAmount`,
      `collectedAmount`, and null/non-null reason remain distinct and unchanged.
- [ ] Widget tests prove valid timed and open sessions change a device from
      available to busy, show the selected player/rate and appropriate timer,
      and cannot be opened again while active.
- [ ] Widget tests prove invalid timed durations (`0:00`, a negative component,
      and minutes greater than 59) show the current validation message and do
      not start a session.
- [ ] Widget tests prove an expired timed session remains active, displays the
      existing expiry message, and requires manual ending.
- [ ] Widget tests prove session monetary values contain neither fractional
      digits nor decimal separators; the collection input defaults to
      `calculatedAmount`; empty/non-integer/negative values are rejected; zero
      and another non-negative integer are accepted; whitespace-only reason is
      absent; a supplied reason is trimmed; and confirmation returns the device
      to available.
- [ ] Tests prove `calculatedAmount` and `collectedAmount` can differ without
      creating or implying a debt record, and document that future actual cash
      receipts/reports must use `collectedAmount`.
- [ ] Tests do not use real delays or external services; widget time advances
      with `WidgetTester.pump`/the test binding, and pure logic receives explicit
      timestamps/durations.
- [ ] Missing role enforcement, responsible-operator capture, distinct
      collection timestamp, and cash-report integration are reported as
      follow-up gaps rather than represented by passing tests or speculative
      production changes.
- [ ] No dependency, Firebase, persistence, architecture, pricing, session, or
      unrelated UI behavior changes are introduced.

## Proposed Implementation

Break substantial work into small steps that can be reviewed and verified
independently.

1. **Repair the application smoke test**
   - Change: Replace the generated counter test with a `PlayStationApp` render
     test. Assert the current title, four device names, and initial availability
     labels; replace the app with a trivial widget at test end to dispose
     `HomeScreen` and cancel its periodic timer.
   - Verification: Run only `test/widget_test.dart`; it compiles without `MyApp`
     and completes without a pending-timer failure.
2. **Extract the minimum pure business boundary**
   - Change: Move `CompletedSession` to its own model file and extract the
     hourly-price lookup, elapsed-duration clamp, and completion-record
     construction into stateless functions in
     `lib/services/session_billing.dart`. First move the current charge formula
     without changing its output. Use explicit inputs, including end
     time/duration; keep `DateTime.now()`, timers, UI state, and transition
     ownership in `HomeScreen`.
   - Verification: Review the focused diff against the current formula and run
     the smoke test before making the separately approved financial correction.
3. **Implement and protect integer-only truncation**
   - Change: Add table-driven pure-Dart tests for player-price selection,
     non-positive duration, no minimum, microsecond truncation boundaries, the
     approved `240.2`/`240.5`/`240.9`/`241.9` examples, representative
     durations, and actual duration beyond a timed plan. After explicit
     implementation approval, remove the half-unit addition from the production
     formula so positive results use integer division and discard every
     fractional pound.
   - Verification: Run `flutter test test/services/session_billing_test.dart`;
     every case matches the explicit expected SYP amount.
4. **Adopt and protect collection semantics**
   - Change: After explicit implementation approval, rename the in-memory
     `finalAmount` field and related parameters/local variables to
     `collectedAmount`; update the session UI label to collection terminology;
     retain non-negative integer validation including zero. Add pure tests for
     future/end-time clamping, unchanged timestamps and session snapshot, equal
     and differing calculated/collected amounts, and absent/present reason
     values. Do not add debt behavior. Keep UI trimming validation in widget
     tests.
   - Verification: Run the focused billing/completion test file and inspect each
     assertion for independent calculated and collected amounts. Search changed
     session code/tests for stale `finalAmount` terminology.
5. **Protect start and timer lifecycle through the UI**
   - Change: Add widget tests that exercise the real dialogs for valid timed and
     open sessions, invalid duration boundaries, duplicate-start prevention,
     availability changes, elapsed/countdown display, and timed expiry without
     auto-end. Use test-controlled frame advancement, not wall-clock sleeps.
   - Verification: Run `flutter test test/session_lifecycle_widget_test.dart`;
     all transitions and Arabic messages are deterministic.
6. **Protect collection behavior through the UI**
   - Change: Extend lifecycle widget coverage for integer-only monetary display,
     the default collected amount, invalid/non-integer/negative collection
     values, zero and positive overrides, optional reason entry, confirmation,
     and restoration of availability. Verify record construction separately
     through the pure boundary because completed records currently have no
     user-facing history UI. Document that cash-report consumption and operator/
     timestamp capture remain follow-up work.
   - Verification: Run the lifecycle widget test independently, then the two
     focused test files together.
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
| `lib/main.dart` | Modify after explicit implementation approval | Import/use the extracted pure functions and completion model, adopt collected-amount UI terminology, and preserve clock, timer, and state-transition behavior. |
| `lib/models/completed_session.dart` | Add after explicit implementation approval | Give the completed-session value a directly importable, testable home with separate `calculatedAmount` and `collectedAmount` fields. |
| `lib/services/session_billing.dart` | Add after explicit implementation approval | Hold dependency-free price, duration, truncating charge, and completion construction logic with explicit inputs. |
| `test/widget_test.dart` | Modify | Replace the invalid counter scaffold with the current app smoke test. |
| `test/services/session_billing_test.dart` | Add | Cover deterministic pricing, duration, truncation, and completed-record behavior. |
| `test/session_lifecycle_widget_test.dart` | Add | Cover dialogs, input boundaries, timers, and start/end UI transitions. |
| `docs/plans/001-test-baseline.md` | Update during approved implementation only | Record approved deviations, verification results, and handoff if documentation updates are authorized. |

No `pubspec.yaml`, lockfile, Firebase/configuration file, generated file, or
platform project file is expected to change.

## Data, Security, and Financial Considerations

- **Data and compatibility:** Current state remains local and in-memory. The
  approved rename from the current `finalAmount` to `collectedAmount` clarifies
  field meaning; there is no persisted history to migrate or recompute. Any
  future persisted schema, migration, or report integration requires separate
  approval.
- **Security and privacy:** Tests use synthetic data only. Current UI has no
  authentication or role enforcement. Do not imply that collected-amount
  entries are authorized merely because the prototype permits them.
- **Financial rules:** Preserve actual elapsed microseconds, zero for
  non-positive duration, no minimum duration, no duration rounding, hourly
  price snapshot, optional reason, and independent calculated/collected amounts.
  Change the current positive half-up money formula to truncate every
  non-negative fractional result toward zero. Display and accept session money
  as integers only. `collectedAmount` may be any non-negative integer including
  zero, is the future cash-receipt/reporting source, and must not automatically
  create debt when it differs from `calculatedAmount`. These rules are limited
  to gaming-session accounting.
- **Required approvals or safeguards:** Repository-owner approval is required
  before any production implementation because this plan changes a financial
  formula, renames a financially meaningful field, updates session UI
  terminology, moves financially significant logic, and introduces a small code
  boundary. This documentation update approves the policy but does not authorize
  those production-code edits. Separate explicit approval and a new or updated
  plan are required before implementing authentication, authorization, audit
  persistence, cash reports, debt handling, Firebase, or wider state ownership.

## Verification and Testing

| Check | Command or method | Expected result | Result |
| --- | --- | --- | --- |
| Smoke test | `flutter test test/widget_test.dart` | Current app renders; no `MyApp` or pending-timer failure | `not_run` |
| Billing/completion unit tests | `flutter test test/services/session_billing_test.dart` | All exact pricing, duration, truncation, and calculated/collected record cases pass | `not_run` |
| Lifecycle widget tests | `flutter test test/session_lifecycle_widget_test.dart` | Start, validation, timer/expiry, integer-only collection, and end flows pass deterministically | `not_run` |
| Changed Dart formatting | `dart format --output=none --set-exit-if-changed lib/main.dart lib/models/completed_session.dart lib/services/session_billing.dart test/widget_test.dart test/services/session_billing_test.dart test/session_lifecycle_widget_test.dart` | No formatting changes required | `not_run` |
| Static analysis | `flutter analyze --no-pub` | No task-introduced issues; stale `MyApp` error is gone | `not_run` |
| Full test suite | `flutter test --no-pub` | All repository tests pass | `not_run` |
| Runtime smoke check | Run the app on an available Flutter target; start and end one timed and one open session | UI behavior and Arabic text remain intact | `not_run` |
| Final scope review | `git diff --check`, `git diff --stat`, and `git status --short` | Only approved files changed; no whitespace, generated, secret, or unrelated changes | `not_run` |

- **Pre-existing failures:** Per `docs/status.md` and source inspection,
  `test/widget_test.dart` references nonexistent `MyApp` and stale counter UI;
  consequently `flutter analyze --no-pub` and `flutter test --no-pub` currently
  fail before useful coverage runs. Commands were not rerun while authoring this
  plan because this task prohibits implementation and the failure is already
  documented.
- **Regressions introduced by this task:** None; this task updates documentation
  only and does not change runtime behavior.
- **Checks not run:** All implementation verification commands; there is no
  implementation to verify in this planning-only task.

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

- [ ] Required approvals are recorded and the plan status permits implementation.
- [x] Relevant source, tests, documentation, branch, and working tree were reviewed for planning.
- [ ] Explicit implementation approval covers the production truncation formula, `collectedAmount` rename, related UI terminology, and narrow extraction.
- [ ] Each proposed step was implemented and independently verified.
- [ ] Changed Dart files were formatted, where applicable.
- [ ] Targeted tests, static analysis, and the full test suite were run where feasible.
- [ ] UI changes received a focused runtime smoke check where feasible.
- [ ] Pre-existing failures were distinguished from regressions.
- [ ] Missing authorization, collection-audit, and cash-report requirements remain visible follow-up work.
- [ ] Deviations from the approved plan were recorded and approved where required.
- [ ] The final diff and Git status were reviewed for scope, secrets, encoding damage,
      accidental generated files, and unrelated changes.
- [ ] Documentation and handoff details reflect the final implementation state.

## Decisions and Assumptions

| Date | Decision, assumption, or deviation | Rationale | Approval/status |
| --- | --- | --- | --- |
| `2026-10-13` | Use actual unrounded duration, require a non-negative integer calculated charge, and discard every fractional pound without rounding up. | The owner clarified the final gaming-session billing policy with explicit examples. | `approved by task author; production change not yet authorized` |
| `2026-10-13` | Preserve separate `calculatedAmount` and `collectedAmount`; allow authorized administrators/employees to record any non-negative integer including zero; use collection for future cash receipts/reports; do not infer debt from a difference. | These are the clarified accounting semantics for gaming sessions only. | `approved by task author; production/reporting work not yet authorized` |
| `2026-10-13` | Keep the adjustment reason optional and eventually record the responsible operator and collection timestamp. | These are approved requirements, but current identity/audit infrastructure is absent. | `approved policy; proposed follow-up implementation` |
| `2026-10-13` | Extract stateless billing/completion functions and a completion value type, while leaving UI/state ownership intact. | This is the smallest boundary that enables direct deterministic coverage without a dependency or project-wide architecture change. | `proposed; implementation approval required` |
| `2026-10-13` | Use black-box widget tests for session transitions and Flutter-controlled time for timer displays. | Private state should not be exposed solely for tests, and real waits would be nondeterministic. | `proposed` |
| `2026-10-13` | Add an optional clock callback to `PlayStationApp` and `HomeScreen`, default it to `DateTime.now`, and use it for session start, elapsed-time, and end-dialog timestamps. | Direct `DateTime.now()` does not advance with `WidgetTester.pump`; the minimal seam keeps production behavior unchanged while Step 5 timer tests use synchronized deterministic time. | `explicitly approved by repository owner for Step 5` |
| `2026-10-13` | Do not add passing tests for role enforcement, responsible-operator capture, distinct collection timestamp, or cash-report consumption yet. | Those approved requirements are not implemented and depend on unresolved authentication/audit/reporting design; tests must remain truthful. | `proposed follow-up` |
| `2026-10-13` | Treat controller-count mismatch, initially unavailable PlayStation 2, timed extension/overtime operations, missing history UI, and global RTL/localization as existing issues outside this baseline. | Fixing them would change behavior or broaden scope beyond testing restoration. | `proposed non-goals` |

## Agent Handoff

- **Outcome:** Proposed a minimal incremental route from the broken scaffold test
  to deterministic truncation, collection, and session-lifecycle coverage; no
  production implementation was performed.
- **Files:** Updated `docs/status.md` and `docs/plans/001-test-baseline.md` for the
  clarified policy. No Flutter source, test, dependency, or Git-history change
  was authorized by this documentation task.
- **Decisions:** Approved business requirements are separated from current
  implementation gaps. All fractional calculated money is discarded;
  `collectedAmount` is separate and is the future actual-cash source; differing
  amounts do not imply debt. Production edits still require explicit approval.
- **Verification:** Read `AGENTS.md`, `docs/status.md`, the plan template,
  relevant source/models/tests, configuration, branch, and working-tree status.
  Implementation checks were not run because this is a planning-only task.
- **Remaining:** Review and approve/revise this plan, then explicitly authorize
  the production formula correction, field/UI terminology change, extraction,
  and tests before executing any step. Authorization, operator/timestamp audit,
  and cash-report integration need separately approved design/implementation.
- **Active plan:** `docs/plans/001-test-baseline.md`
- **Git:** `develop`; `docs/status.md` is modified and
  `docs/plans/001-test-baseline.md` remains untracked.
- **Suggested commit:** `docs(billing): finalize integer-only session policy`
