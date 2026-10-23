# M11 — Backend II: match settlement and authoritative quests

Status: **complete**. Implementation commit **`f9cfbd3`** (`feat(backend): add match settlement and authoritative quests`); slice 11 checked after its success. Fast mode; slice 11 only. Updated 2026-10-23. Evidence is localhost HTTP with controlled submitted histories and actual Atlas storage, not deployed Vercel or live Godot/backend games.

## Scope, references and prerequisite

Read bootstrap; universal requirements/adapters/completion protocol/M11 in Milestones; checklist slice 11/mode/Revisions; M10 report; assigned PRD/spec sections; local `5-build`; private learner context; backend README/modules. Preserve approved TypeScript/Node, Resource authoring, bounded warm pool, permanent identity ownership, unrestricted jam matchmaking and trusted-host limitation. No delegation, other-chat creation/messaging or M12.

Initially preserved `e8bb537` and pending M10 diffs while drafting only separate new modules. Creator subsequently supplied **`0d4d7bb5f5c23b7aca92e31bc098942f0968d0a8`**, confirming M10's own chat checked the checkpoint and found it clean. Inspection confirmed that HEAD and clean tree. The external commit includes this chat's initial M11 drafts/report too; preserve it without rewriting/recommitting unchanged contents. M10's report/checkbox still show historical partial status: this discrepancy is recorded, not repaired or represented as independently audited predecessor completion. Creator's explicit own-chat confirmation cleared this assignment's boundary. No M09/M10 report/checkbox changed here.

## Changed files and why

Initial M11 code already contained in external `0d4d7bb`: backend `src/settlement-model.ts`, `settlement-rules.ts`, `server-time.ts`, `settlement-store.ts`, `authoritative-quests.ts`, `match-settlement.ts`, `m11-api.ts`; `api/menu.ts`, `api/quests.ts`, four `api/matches/*.ts` routes; `scripts/setup-m11.ts`, `m11-local-server.ts`, `try-m11.mjs`. These implement the schemas, validation/calculation, clock, indexes/transactions, quest coordination, bindings/receipts and local tools below.

Continuation changes only:

- New `backend/scripts/exercise-m11.mjs`: scoped HTTP/Atlas exercise, private saved identities/operations, before/after observations and transaction evidence; completed-step tracking prevents accidental repeated credit/account recreation.
- `backend/scripts/dev.ts`: mounts M11 handlers with production gate retained.
- `backend/scripts/m11-local-server.ts`: prints exact second-terminal API_BASE command.
- `backend/package.json`: `db:setup:m11` / `exercise:m11`; no dependency changes.
- `backend/vercel.json`: existing function protections apply to nested match routes via `api/**/*.ts`, per [official Vercel glob documentation](https://vercel.com/docs/project-configuration/vercel-json#functions). Prepared settings, no deployment.
- `backend/README.md`, this report and M11-only checklist Revisions/completion recording: contracts, exact instructions and actual evidence.

No pending predecessor diff was absorbed or predecessor completion/report rewritten. Unrelated files, secrets, learner profile, client/gameplay/network/scenes/settings/art and public exports remain untouched.

## Configuration and creator decisions

Creator explicitly answered **“Yeah sure”** to the exact existing rules/development quest catalogue for isolated nonproduction API/Atlas exercises with productionReady=false, and existing Ember selection for ordinary fallback exercises.

Revision: `sha256:d0e9b971b245891addf9a13e056bec263c5e5a18b3cd07e6935e8a3a9637edf3`.

Rules `m05-round-v1`; quests `m08-creator-approved-preview-v1`; development_only=true; ordered_cycle; productionReady=false; production arena weights unset. No authored `.tres` values changed; existing generated artifact/source digests verified by final build. No competing Node payouts or preview history. Normal/deployed handlers retain readiness rejection for production settlement/quest assignment/payment; exact-revision exercise capability is private to localhost tools. Production balance/selection/arena weights and bot policy remain applicable creator inputs for later production work.

## Schema, indexes, transaction and API contracts

`matches` stores unique match ID/global nonce, authenticated creator/registration digest, optional expected human, known revision, immutable permanent participant/name/control snapshots and captured quest IDs, status, submission digest and committed receipt. Owner-bound nonce replay cannot replace bindings; authenticated peer join completes human binding before play/finalization. Isolated fallback resolves the existing `m10-ember-v1` profile without seed recreation, scheduling or rating filter. Production fallback selection remains gated pending authored policy.

Compact `roundLog` has match/revision, condition devil/angel/none, four locked phase timings and two actor histories: RPS starting order, initial/final cards, identity/intention claims and bounded decision/revision events with sequence/host-relative time. Validation checks identities, phase duration/order, event sequences/revisions/timing and accepted final values. M12 must translate the richer Godot RoundLog. Host-reported condition/history/departures are still trusted; backend validation is not independent live gameplay verification or cheat detection.

Only a bound eligible human may finalize. Server computes rewards/classification and freezes receipt ID, match-derived result ID, match ID, committedAt, revision/history/departures/recipients. Identical replay returns original receipt without writes; contradictory history/eligibility is 409. Bound humans can query pending/committed status after uncertainty. Cinematic departure cannot rewrite commitment. No recovery/reconnect/resume endpoint.

One short transaction writes result/receipt, eligible profiles, owner records and captured quest contributions. It reuses M10's MongoClient with snapshot reads/primary/majority writes and bounded transaction/commit times; operations are sequential. `withTransaction` handles driver transient/uncertain-commit retries; bounded fresh-transaction retry handles competing unique inserts. HTTP success occurs only after commit resolves, never inside callbacks. Menu payment uses its own transaction. Actual Atlas transactions succeeded; no independent non-atomic substitute. Reference: [MongoDB transaction/retry guidance](https://www.mongodb.com/docs/drivers/node/current/crud/transactions/).

Ordinary humans/fallback profiles receive eligible competitive credit. Precommit departed humans receive no saved points/counters/records/quest contributions. Their identity/cards can appear in the survivor record; takeover credits no bot profile. Bots have no human-authenticated menu/quest assignments. Separate stored fallback/takeover cases verified attribution.

`questOwners` serializes owner assignment/capture/contribution/reset/payment with a revision write. Separate `questInstances` snapshot definition/revision, activation/period/expiry, zero counter and active/completed/paid/expired status. Contributions uniquely bind instance+match, grants instance, menu entries owner+request. Registration/join captures active IDs; old/in-flight matches cannot advance newly assigned/reset instances. A completed daily creates its next zero-counter instance without replaying the finishing event. Active daily/weekly objectives may share events. No lifetime initialization or fixed completion cap. Current-day history is stored outside players and paginated at 100 (`historyBefore` / `dailyHistoryNextBefore`). Expiry precedes menu payment; unfinished/unpaid completions expire, paid points remain. Quest reads never pay.

Created/inspected unique indexes: match ID, nonce, partial receipt ID; quest owner; instance ID; instance+match contribution; instance grant; owner+menu request; match+record owner plus existing record ID. Owner-period/status indexes supplement M10 read indexes. Required unique indexes checked before transaction handlers.

| Route | Request / response responsibility |
| --- | --- |
| POST matches/register | Owner + matchNonce/lobbyId?/peerPlayerId?/fallbackRequested/rulesRevision; immutable bindings/public opponent. |
| POST matches/join | Peer + matchId/matchNonce; cannot replace binding. |
| POST matches/finalize | Eligible human + matchId/rulesRevision/roundLog/departures (at most one human); durable receipt. |
| GET matches/result?matchId | Bound human; matchId/status/savedResult, null until committed. |
| POST menu | Owner + requestId UUID; expiry/payment then profile/stats/quests/history/grants/periods/serverTime/revision. |
| GET quests?historyBefore | Owner; current state/history/reset without payment. |

All routes use `/api/`. Existing public player/four leaderboard/owner-record reads consume actual stored M11 results. M10 authentication/projections reused without repeating its whole auth suite.

## Mechanical verification: controlled inputs and real storage

Local macOS Node **24.15.0**; retained mongodb **7.7.0**, TypeScript **7.0.2**, Node types **24.19.2**. Atlas observed **8.0.34**; M0/AWS Singapore remain creator-reported M10 labels, no new quota audit. Five dedicated humans' credentials/operations immediately saved privately in ignored `.local/m11-contract.json` (0600); M10 accounts/credentials not recreated/overwritten/deleted. Existing agreed Ember gained controlled API exercise history, not preview uploads. Test adapters closed normally.

| Scoped check | Actual result |
| --- | --- |
| Build/config/syntax | Final typecheck/build, both M11 script syntax checks and diff whitespace checks passed. Same artifact/source digests; productionReady=false; pins unchanged. |
| Indexes/local API | `db:setup:m11` succeeded on actual Atlas; unique indexes inspected. Private localhost adapter used real handlers. Sandbox setup could not connect; authorized elevated execution succeeded with private details withheld. |
| Seven scoring histories | **76** match points; W/L/D **3/1/3**; lying/honest **3/4**; **7** records. Base **10/3/0**, Devil **20/8**, Angel **25/10**; mixed and two-false cases count lying once. Initial Scissor/final Rock persisted. |
| Aggregates/streak | Win rate **42.857142857142854** (3/7), three winning Rocks/100% winning Rock, lying win percentage 100/3. Draws preserve streak **3**; fallback loss resets **0**. Zero-win profile's winning/lying-win percentages null. |
| Quests/menu | Scissors loss → fresh Win-3 → fresh Scissors requiring another draw. Active weekly play/lie share events; lying once/match. Menu paid **13** (daily 1+3+1, weekly 5+3), total **89**; same and new ordinary entries did not pay again; reads never paid. |
| Identical replay | Match **01f5352c-3b31-4c6e-8543-4aacbbff2645**, receipt **73c7754a-93c0-403a-bcf8-128327b97ec3** unchanged. Actual match/profiles/records/instances/contributions/grants/owner/menu documents identical before/after. |
| Denied operations | Contradictory condition **409**, outsider result **403**; same actual storage snapshot unchanged. |
| Fallback | Match **8f06089e-46ca-46c0-8248-bf17e2b950d2**: existing Ember **+10/+1 win/+1 match/one record**; permanent identity preserved. |
| Takeover | Match **92a0a563-0aa8-4123-987d-04ffbdf0c1ee**, receipt **c6f52605-bcbf-44fa-b73a-2cecd59c46cf**: survivor **+25**, exactly **one record** retaining departed opponent snapshot. Departed profile/quests and Ember profile unchanged. |
| Daily cutoff | Saturday 2026-10-24 GMT+7 **04:59/05:00/05:01**: unpaid completion expired, new-day history/counter fresh, no expired menu reward. Old in-flight match excluded from new daily. Later Scissors paid **1**, preserved after next reset. Three expired daily instances observed, covering unfinished/unpaid. |
| Monday cutoff | Monday 2026-10-26: weekly play completed **04:59**, weekly counters zero **05:00**, no expired reward **05:01**. Three old unfinished/completed-unpaid weeklies expired. Profile retained **50** match points; A retained **114** including prior paid rewards. |
| Finishing-event proof | Focused four-history follow-up used initial Scissors on third Win-3 win. Match **dbe4c4b6-1376-48ab-8776-10b7ed1be392** left new instance **d6c49e2e-860f-4232-84ca-deef78b257cd** at **0**, with **0** finishing-event contributions. Earlier passed cases skipped. |
| Actual reads | A: **114 points / 9 matches / 9 records** matched stored receipt/profile/four leaderboard values. Quest read granted nothing. |
| Transactions | Private harness counted successful actual driver commitTransaction acknowledgements without commands/sessions/secrets: **75** primary-run, **14** follow-up. Each finalization required acknowledgement before receipt, then independently read stored commitment. Before/after storage confirms effects; no rollback/race injection. |
| Privacy | Env/private exercise files mode **0600**; ignored env/local/public/learner paths verified. No credentials/hashes/URIs/exports/profile staged; unrelated processes untouched. |

**21 controlled submitted histories** total. Source harness and ignored `.local/m11-evidence.json` retain observations. Completed-step markers preserve data; skipped reruns are not new passes.

Scoped reduction recorded under Revisions. **Deferred/unverified:** concurrent duplicates, uncertain-network races, rollback/failure injection, full suites, load/stress/fuzzing/outages, browser/device/gameplay and deployed behavior. Safeguards are not proof those tests passed. No broad rerun after documentation-only changes.

## Time authority isolation

Normal handlers use real server time. Daily 05:00 GMT+7 equals previous-date 22:00 UTC; weekly uses Monday's cutoff. Injection requires private in-process clock/exact exercise revision; Vercel environments reject it. No public clock route or request/header/query/environment clock override. Scripts excluded from uploads. Fixture times advance through 2026-10-26 without changing system/production time; creator try-out uses separate real-clock identities. ProductionReady stays false.

## Creator try-out and actual feedback

Full instructions/contracts in backend README. In **backend/**:

```sh
npm run build
npm run db:setup:m11
node --env-file-if-exists=.env dist/scripts/m11-local-server.js sha256:d0e9b971b245891addf9a13e056bec263c5e5a18b3cd07e6935e8a3a9637edf3 --approved-ember
```

Copy the printed exact `export API_BASE=...` into a second backend terminal:

```sh
node scripts/try-m11.mjs prepare
node scripts/try-m11.mjs play
node scripts/try-m11.mjs inspect
node scripts/try-m11.mjs replay
```

Prepare preserves two new real-clock credentials in ignored `.local/m11-tryout.json` (0600), refusing overwrite. Play registers/joins and submits honest Scissor→Rock win versus Scissor. Expected A: **10 points/one win/one record**, first daily complete, next Win-3 **0**, weekly play **1**/switch **1**. Inspect follows receipt/saved data; replay checks original receipt/unchanged credit. Never print/share credentials; preserve partial operations rather than recreate accounts. Separate agent storage/transaction evidence is above.

Actual creator input: checkpoint confirmation and nonproduction configuration/Ember approval. **No M11 try-out feedback received or invented.** M11 is not a planned fast-mode checkpoint; no extra feedback gate invented.

## Godot MCP, export and service limitations

Supported editor read initially confirmed exact root `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor` (case-normalized). No mutation/playtest/game export/client thread/art/scene/settings changes. Unchanged `.tres` digests verified; no tuning changes requiring regeneration. `backend/public/` untouched/ignored/excluded; public SDK distribution unresolved. No Vercel link/build/upload/deployment or hosted egress check. Pool/dependency pins retained; capacity/rollback/race limits unmeasured.

## Commit/checklist and M12 handoff

Implementation committed as **`f9cfbd3`**, `feat(backend): add match settlement and authoritative quests`. Drafts in external `0d4d7bb` preserved. The reviewed eight-file continuation diff contains only M11 code/instructions/evidence/Revisions; no predecessor diffs or secrets. Slice 11 is checked after the successful feature commit, with report/checklist completion saved in a following documentation commit. No M09/M10 completion, M12/checkpoint/Final Review/learning-wrap-up changes.

M12 remains **unstarted**. Handoff: permanent bindings, compact wire history, active-instance capture before play, frozen precommit departures, durable receipt before cinematic, same-match query/retry after uncertainty, stable genuine-menu entry IDs, real server time and trusted-host limitation. Applicable production content/selection/arena weights and public SDK distribution still need creator decisions. Exercise approval is not production balancing/deployment approval. No client/provider integration performed.
