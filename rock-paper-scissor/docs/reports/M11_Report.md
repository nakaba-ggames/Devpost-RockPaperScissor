# M11 — Backend II: match settlement and authoritative quests

Status: **partial / awaiting M10 checkpoint and explicit exercise configuration agreement**. Recorded fast mode; slice 11 only. Independent draft modules and endpoint entry points compile. **No M11 API/Atlas exercise, transaction commitment, reward payment or storage evidence has been performed.** Slice 11 remains unchecked and no implementation commit has been made. Updated 2026-10-23.

## Scope and approved references

Read the bootstrap; universal requirements, adapters, completion protocol and complete M11 brief in `docs/Milestones.md`; slice 11, mode and Revisions in `devpost/checklist.md`; M10 report; assigned PRD/spec sections; project-local `5-build`; private learner context; backend README and relevant existing modules. Preserve the approved TypeScript/Node backend, `.tres` authoring, bounded shared pool, permanent identities, unrestricted jam matchmaking and trusted-host limitation. No delegation, chat creation/messaging or M12 work.

Initial and final read-only Git inspections found HEAD `e8bb537` (`m10`), an empty index, and the supplied pending M10 diffs in `backend/README.md`, `backend/package.json`, `backend/src/model.ts`, `backend/scripts/seed-bots.ts`, M10 report and checklist. Those backend/report diffs have not been modified, staged or absorbed. The checklist receives only the M11 Revisions appendix below. Existing M09/M10 reports/checkpoints are not finalized here. The creator was asked to finish M10 in its own chat and supply its checkpoint hash; no answer has yet been received.

## Changed files and why

All backend paths below are **new uncommitted M11 files**:

- `src/settlement-model.ts`: registrations, compact history/events, receipts, quest instances, owner coordination, contributions, grants and menu identities.
- `src/settlement-rules.ts`: known generated configuration, explicit readiness gate, structured history validation, server calculations, lifetime counters/percentages and quest predicates.
- `src/server-time.ts`: real-clock default and fixed GMT+7 daily/weekly boundaries.
- `src/settlement-store.ts`: collection access using M10's pool, index setup/checks and short transaction wrapper.
- `src/authoritative-quests.ts`: zero-counter assignment, captured-instance eligibility, contribution, fresh daily sequence, reset/expiry, menu payment and paginated current-day reads.
- `src/match-settlement.ts`: immutable participant bindings, stable registration nonce, once-only settlement/receipt lookup, eligible profile/owner-record updates and takeover exclusion.
- `src/m11-api.ts`, `api/menu.ts`, `api/quests.ts`, `api/matches/{register,join,finalize,result}.ts`: authenticated API handlers. Default deployed entry points retain the production gate and real clock.
- `scripts/setup-m11.ts`: explicit prerequisite index setup, **not executed**.
- `scripts/m11-local-server.ts`: separate localhost-only adapter, including existing M10 routes, private in-process exercise capability and optional injected clock. **Not started**.
- `scripts/try-m11.mjs`: small credential-private creator walkthrough; controlled history, receipt/profile/record/quest reads and identical sequential replay. **Not executed**; it is not the full required M11 verification harness.

This report and the M11-only checklist Revisions entry record the actual partial status. No existing backend implementation file was edited. `backend/public/`, existing credentials/environment files, learner profile, client code/scenes/settings/art and previous history remain untouched.

## Architecture, schema, indexes and API contracts — draft, not storage evidence

`matches` stores unique `matchId`/global `matchNonce`, creator, normalized registration digest, expected peer, known rules revision, participant name/control snapshots and captured quest IDs, waiting/ready/committed status, submission digest and receipt. A replay by the same creator returns the binding; another creator or contradictory registration cannot replace it. A requested human must exist, and independently authenticated join finishes human binding before finalization. No rating filter or bot scheduling is added. The isolated Ember option resolves the existing `m10-ember-v1` profile; it does not seed/import an identity or history. Production fallback selection remains unavailable pending authoring.

Compact `roundLog` carries `matchId`, full artifact `rulesRevision`, `condition` (`devil`, `angel`, `none`), four locked phase timings, and two actor histories. Each actor preserves `actorId`, an RPS permutation `startingOrder`, separate initial/final cards, identity/intention claims and bounded decision/revision events (`phase`, `sequence`, `revision`, host-relative `elapsedMsec`, `value`). Validation checks binding, revision, phase duration/order, unique event sequence, event revisions/timing and accepted final values. M12 will need to map the richer Godot RoundLog into this wire shape. Validation does **not** independently verify live gameplay, the reported condition or departure facts; the approved host remains trusted.

Only a bound, nondeparted human can finalize. One reported precommit departed human excludes that side from every profile/record/quest update; its history/name may remain in the survivor's opponent snapshot. No separate takeover bot profile is credited. Ordinary fallback profiles receive normal competitive profile/record updates; bots have no human-authenticated quest/menu assignments. A committed receipt freezes result and eligibility; contradictory replay returns 409 and later departures cannot rewrite it. Authorized participants can read waiting/ready/committed status and the receipt without a reconnect/resume endpoint.

The short transaction writes match result/receipt, eligible profiles, owner records and quest contributions together. It uses the existing module-scoped MongoClient, snapshot reads, primary preference and majority write concern; operations inside a session are sequential. The API returns the callback value only after `withTransaction` resolves. Driver transient/uncertain-commit retry handling is reused; bounded fresh-transaction retries handle competing unique inserts. No external success is emitted inside callbacks. These safeguards are **implemented but not exercised against Atlas**. See the official [MongoDB transaction API/retry guidance](https://www.mongodb.com/docs/drivers/node/current/crud/transactions/).

`questOwners` serializes per-owner assignment/capture/contribution/reset/payment operations with a revision write. `questInstances` stores individual definition snapshots, unique instance IDs, activation/expiry, counter and active/completed/paid/expired states. `questContributions` uniquely binds instance+match; `questGrants` uniquely binds instance payment; `menuEntries` uniquely binds owner+request ID. No lifetime initialization or record replay; new dailies activate at zero and cannot receive the event that completed their predecessor. Captured IDs prevent in-flight matches from contributing to subsequent/reset instances. Paid rewards are preserved at reset. Current-day history is stored separately from player documents and returned in pages of 100 (`historyBefore` / `dailyHistoryNextBefore`), with no daily completion cap.

Prepared unique indexes: match ID, nonce, partial receipt ID; owner coordinator; quest instance ID; instance+match contribution; instance grant; owner+menu request; match+record owner. Owner-period/status query indexes supplement these and existing M10 indexes. Readiness checks required unique indexes before invoking transaction handlers. **These M11 indexes have not been created or inspected in Atlas.**

Prepared routes:

| Route | Request / responsibility |
| --- | --- |
| `POST /api/matches/register` | `{matchNonce,lobbyId?,peerPlayerId?,fallbackRequested,rulesRevision}`; authenticated creator, stable nonce, bound snapshots and opponent public profile. |
| `POST /api/matches/join` | `{matchId,matchNonce}`; authenticated peer, immutable binding. |
| `POST /api/matches/finalize` | `{matchId,rulesRevision,roundLog,departures:[playerId?]}`; server calculation and atomic committed receipt. |
| `GET /api/matches/result?matchId=…` | Bound human only; committed receipt or explicit pending status. |
| `POST /api/menu` | `{requestId}`; expiry first, eligible once-only grants, current profile/stats/quests/history/grants/periods/server time. Retry of the same menu ID cannot pay subsequently completed quests. |
| `GET /api/quests?historyBefore=…` | Authenticated current-period view/reset; never pays. |

Existing public stats/leaderboard/owner-record routes are reused as consumers of the stored aggregate/record schema. They have **not** been checked with M11 outcomes. The original `scripts/dev.ts` remains unchanged and does not mount M11; the separate adapter is prepared for isolated checks. Existing Vercel configuration also remains unchanged: nested match-function settings must be reviewed after the M10 boundary clears, before claiming deployed routing. No deployment/upload was attempted.

## Exact configuration and creator decisions

Unchanged generated revision:

`sha256:d0e9b971b245891addf9a13e056bec263c5e5a18b3cd07e6935e8a3a9637edf3`

Authored rules `m05-round-v1`; quests `m08-creator-approved-preview-v1`; `development_only:true`; `daily_selection:ordered_cycle`; `productionReady:false`; production arena weights unconfigured. Build verifies the artifact and `.tres` source hashes. No authored values changed and no competing Node payout constants were added. The exported rules supply base 10/3/0 and qualifying Devil 20/8 or Angel 25/10; losses get no bonus/deduction. Classification compares identity to initial card and intention to actual final-versus-initial change, counting any lying match once. Counters implement the approved denominators, null zero-denominator percentages and win/draw/loss streak rules.

Creator agreement was requested for **this exact existing development catalogue/rules in an isolated nonproduction API/Atlas exercise**, retaining its labels and production gate, and selecting the approved existing Ember for the ordinary fallback exercise. **No agreement received yet; no settlement enabled or exercised.** Prior M08 preview approval and M10 seed approval are not represented as this new agreement. Production selection/balance remains a future creator input.

## Mechanical verification and evidence

| Action / environment | Actual observation |
| --- | --- |
| Git boundary, backend commands | HEAD `e8bb537`; pending predecessor changes preserved; index empty; only separate new backend files added. No M10 completion inferred. |
| `npm run typecheck` and `npm run build`, backend workspace | Passed after the final code change. Existing pinned toolchain/dependencies retained. Build verified the exact revision above and `productionReady=false`. |
| `node --check scripts/try-m11.mjs` | Passed syntax check. No API requests or accounts created. |
| `git diff --check` | Passed. Ignore checks confirm `.env`, `.local/m11-tryout.json`, existing public export and learner profile are ignored; learner profile remains untracked. |
| Godot MCP editor read | Exact connected root returned `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor` (case-normalized). No mutation/runtime/playtest/export performed. |
| Local M11 API / actual Atlas | **Not run.** No M11 collections/indexes, transaction commits, result receipts, profile deltas, records, contributions or grants observed. M10's recorded Atlas/auth/restart evidence was read, not repeated. |

Required basic checks **pending**, never passed: actual local API/Atlas launch; small normal win/draw/loss and honest/mixed/two-false histories with before/after storage; identical sequential replay; contradictory replay and unauthorized result denial without writes; separate ordinary fallback and survivor-only takeover storage; Scissors → Win-3 → Scissors and active weekly progress; repeated menu entry; injected daily 04:59/05:00/05:01 and Monday expiry/payment/paid-point preservation; receipt/profile/four leaderboard/records/quest reads and transaction evidence. The prepared creator script covers only a subset and does not replace storage-level verification.

The creator explicitly reduces M11 verification to those basic checks. **Deferred/unverified:** concurrent duplicates, uncertain-network races, deliberate rollback/failure injection, full suites, load/stress, fuzzing, outages, browser/device/gameplay checks. No claim is made that rollback, retry races or a live Godot game passed. Repeat affected checks only after relevant fixes.

## Time authority and isolation

Normal handler instances use `new Date()` through the server-clock default. Daily periods start at fixed GMT+7 05:00 and weekly periods Monday 05:00. An injected clock requires an explicit private exercise capability in the handler factory. The separate localhost adapter can receive that function only from an in-process test harness; public clients cannot set time via body/header/query/clock route. Exercise revision validation rejects Vercel environments and never flips `productionReady`. The clock/reset logic compiles but **boundary/payment behavior has not been run**. The full controlled-time Atlas harness remains to be added/executed after the gates clear.

## Creator try-out — prepared, not executed

**Prerequisites:** completed M10 checkpoint from its own chat, explicit agreement to the exact isolated exercise revision, protected existing `.env`, and the remaining focused M11 review/verification. These commands are instructions for continuation after those inputs, not evidence that they ran. Use only `backend/`:

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/backend
npm run build
node --env-file-if-exists=.env dist/scripts/setup-m11.js
node --env-file-if-exists=.env dist/scripts/m11-local-server.js sha256:d0e9b971b245891addf9a13e056bec263c5e5a18b3cd07e6935e8a3a9637edf3
```

The adapter prints its localhost URL with an allocated port. In a second backend terminal, set `API_BASE` to that exact printed URL, then:

```sh
node scripts/try-m11.mjs prepare
node scripts/try-m11.mjs play
node scripts/try-m11.mjs inspect
node scripts/try-m11.mjs replay
```

`prepare` issues two dedicated identities and saves credentials immediately in ignored `.local/m11-tryout.json` (0600). It refuses to overwrite existing credentials. It does not use/recreate M10 accounts. `play` registers/binds the humans, submits a clearly controlled Scissor→Rock honest win versus Scissor and persists the operation for identical retries. Expected first-match A data: +10 points, one win, one owner record, initial-Scissors daily completed, next Win-3 daily still zero, weekly play +1 and switch +1. Completion does not itself pay quest rewards. `inspect` follows the match through its receipt and saved reads. `replay` expects the same receipt and unchanged API-visible profile/records/quest counters; separate actual database before/after observations are still required for milestone evidence. Never display/share the credential file. Interrupted preparation must be investigated using saved credentials, without recreating accounts.

No actual creator try-out feedback received. M11 is not a planned fast-mode hands-on checkpoint; none is invented or checked.

## Tool/service and web/export limitations

Only supported Godot read inspection was used. Resource export was not rerun because authored sources did not change; build verified their hashes. No client provider swap, networking changes, art, scene/settings mutation or gameplay/browser/device testing. Existing SDK-bearing `backend/public/` remains untouched/ignored/excluded under the existing upload boundary. No upload or deployment occurred; localhost code is not deployed evidence. Atlas connectivity/transactions for M11 remain unexercised, not substituted with independent non-atomic writes or mocks. Dependencies were not changed or reinstalled.

## Commit/checklist status, unresolved inputs and M12 handoff

Planned commit remains `feat(backend): add match settlement and authoritative quests`; **not made**. No files staged, no history rewritten, no predecessor diffs absorbed. Slice 11 stays unchecked because essential checkpoint/configuration inputs, runnable API/storage evidence and the implementation commit are missing. Only an M11 Revisions note was appended; slices 9/10/12, checkpoints, Final Review and learning wrap-up remain untouched.

Continuation must first obtain/recheck M10's own-chat checkpoint and the explicit configuration/Ember exercise decisions. Then review the new modules, finish any necessary existing-adapter/nested-function settings changes within M11, implement/run only the assigned basic Atlas exercise, fix affected failures and collect sanitized before/after/transaction evidence. Review explicit intended/staged diffs and commit only verified M11 files before completing its slice. Never recommit pending M10 work as M11.

**M12 remains unstarted and unauthorized.** Its eventual handoff will need the verified API wire schema/receipt ordering, approved production content/selection inputs, client mapping of permanent actors and captured histories, real-clock production handlers and unresolved public SDK distribution. No integration is performed to conceal this incomplete prerequisite.
