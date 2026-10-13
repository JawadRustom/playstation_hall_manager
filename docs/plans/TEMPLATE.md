# Implementation Plan: `<title>`

## Plan Metadata

- **ID:** `<plan-id>`
- **Title:** `<short task title>`
- **Status:** `proposed` | `approved` | `in_progress` | `blocked` | `complete`
- **Date:** `<YYYY-MM-DD>`
- **Owner:** `<agent or person>`
- **Approver:** `<person or role; required before implementation>`

> Start implementation only after required approval and a status change to
> `approved` or `in_progress`. This plan does not authorize Git operations.

## Objective

`<Describe the desired outcome, user value, and why the work is needed.>`

## Current Behavior

- `<Describe the relevant behavior and evidence from the current code or docs.>`
- `<Record known test failures or constraints that predate this task.>`
- **Behavior to preserve:** `<List behavior that must remain unchanged.>`

## Scope and Non-Goals

### In Scope

- `<Included change>`

### Non-Goals

- `<Explicitly excluded change>`

## Requirements and Acceptance Criteria

- [ ] `<Requirement stated as an observable, verifiable outcome>`
- [ ] `<Required boundary, error, accessibility, RTL, or compatibility behavior>`
- [ ] `<No regression to identified preserved behavior>`

## Proposed Implementation

Break substantial work into small steps that can be reviewed and verified
independently.

1. **`<Step name>`**
   - Change: `<small, concrete change>`
   - Verification: `<focused check proving this step works>`
2. **`<Step name>`**
   - Change: `<small, concrete change>`
   - Verification: `<focused check proving this step works>`

If implementation must differ materially from this approved approach, stop,
record the deviation under **Decisions and Assumptions**, and obtain any required
approval before broadening the scope.

## Affected Files and Components

| Path or component | Planned change | Reason |
| --- | --- | --- |
| `<path or component>` | `<add / modify / remove>` | `<why it is affected>` |

## Data, Security, and Financial Considerations

- **Data and compatibility:** `<schema, persistence, migration, audit-history, or none>`
- **Security and privacy:** `<authorization, secrets, customer data, production access, or none>`
- **Financial rules:** `<pricing, duration, rounding, adjustments, historical values, or none>`
- **Required approvals or safeguards:** `<approval, emulator/test double, boundary tests, or none>`

Do not infer or silently change financial rules, production data, Firebase
behavior, schemas, authentication, authorization, or audit requirements.

## Verification and Testing

| Check | Command or method | Expected result | Result |
| --- | --- | --- | --- |
| Focused tests | `<command>` | `<expected behavior>` | `not_run` |
| Static analysis | `flutter analyze` | No task-introduced issues | `not_run` |
| Full test suite | `flutter test` | No task-introduced failures | `not_run` |
| Runtime smoke check | `<hot reload/restart flow, if applicable>` | `<expected behavior>` | `not_run` |

- **Pre-existing failures:** `<exact failure, evidence, and impact, or none>`
- **Regressions introduced by this task:** `<failure and impact, or none>`
- **Checks not run:** `<check and reason, or none>`

Do not mark implementation checklist items complete until their relevant checks
have passed or an explicitly documented limitation has been accepted.

## Risks and Rollback

| Risk | Mitigation | Rollback or recovery |
| --- | --- | --- |
| `<risk>` | `<preventive or detection measure>` | `<safe way to restore prior behavior>` |

## Implementation Checklist

- [ ] Required approvals are recorded and the plan status permits implementation.
- [ ] Relevant source, tests, documentation, branch, and working tree were reviewed.
- [ ] Each proposed step was implemented and independently verified.
- [ ] Changed Dart files were formatted, where applicable.
- [ ] Targeted tests, static analysis, and the full test suite were run where feasible.
- [ ] UI changes received a focused runtime smoke check where feasible.
- [ ] Pre-existing failures were distinguished from regressions.
- [ ] Deviations from the approved plan were recorded and approved where required.
- [ ] The final diff and Git status were reviewed for scope, secrets, encoding damage,
      accidental generated files, and unrelated changes.
- [ ] Documentation and handoff details reflect the final implementation state.

## Decisions and Assumptions

| Date | Decision, assumption, or deviation | Rationale | Approval/status |
| --- | --- | --- | --- |
| `<YYYY-MM-DD>` | `<entry>` | `<reason and impact>` | `<proposed / approved by ...>` |

## Agent Handoff

- **Outcome:** `<what changed and why>`
- **Files:** `<files changed; identify unrelated pre-existing changes separately>`
- **Decisions:** `<approved decisions, assumptions, deviations, and preserved behavior>`
- **Verification:** `<exact checks and results; include checks not run>`
- **Remaining:** `<open work, risks, blockers, and the next actionable step>`
- **Active plan:** `docs/plans/<plan-file>.md`
- **Git:** `<current branch and concise working-tree status>`
- **Suggested commit:** `<Conventional Commit message; do not execute it>`
