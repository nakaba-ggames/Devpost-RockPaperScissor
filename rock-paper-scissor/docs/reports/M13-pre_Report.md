# M13-pre — Backend/network stability and gameplay responsiveness

Status: **closed by explicit creator instruction, 2026-10-24**. The creator says “m13 pre is done” and requests closure and Antigravity M13 takeover. This is creator-directed closure, not a new HUB audit or a statement that all vendor/network issues are resolved. Nothing staged or committed by this closure.

## Closure addendum — 2026-10-24

Close checklist slice **13-pre** on the creator's explicit instruction. Preserve the executor's actual implementation, timing observations and offline composition evidence below. Earlier partial/status/“do not check complete” statements describe the execution at that time and are superseded only for milestone closure; unresolved intermittent GD-Sync connection/matchmaking and supported routing override limitations remain recorded, not fixed or silently passed.

The report's measured backend gains and creator responsiveness feedback remain executor-reported evidence; the HUB ran no new tests, playtests, network requests, exports or deployments. The latest source composition gives live and presentation roots the same `scenes/ui/game_ui.tscn`; `scenes/development/presentation.tscn` is the immediate Test-Human/offline authoring entry. Actual online behavior/web export after this refactor remains unverified; existing web output is older, and mixed-version live peer testing is not evidence of compatibility. Existing uncommitted code/scenes/reporting changes remain preserved, with no invented completion commit.

M13 is prepared for the creator-specified **Antigravity / Gemini 3.8 Flash** takeover. The authoritative initial handoff is `../AGY_Polishing_Handoff.md`, with actual polishing results recorded in `AGY_Polishing_report.md`. Start in presentation.tscn, then author shared visual changes in game_ui.tscn. **Direct main.tscn edits require the creator's explicit confirmation AND explicit command for the specific change.** Shared UI propagation is allowed; direct rewriting/resaving main is not. All other initial file/write limits are in the handoff. M13, earlier pending boxes, Final Review, learning wrap-up and shipping are not completed by closing M13-pre.

---

## Preserved execution record

The original report body follows unchanged. Its historical status/continuation directions are superseded by the closure addendum; its evidence and limitations are preserved.

Status: **partial: backend responsiveness repair deployed, measured and positively reviewed by the creator; intermittent matchmaking/connection delay remains undiagnosed. The targeted focus attempt progressed normally.**
Date: 2026-10-24, Asia/Jakarta. M13-pre only. Nothing staged or committed.

## Outcome and current investigation

Latest creator-requested iteration: live and presentation roots now compose the
same `scenes/ui/game_ui.tscn`; presentation starts immediately at the menu as
**Test-Human**, without a connection/intro/name gate. See the final composition
section below; it supersedes the earlier preview startup instructions.

Real final-lock→durable-receipt time improved **17.351s → 2.084s** between the
instrumented original baseline and the approved Singapore deployment. The first
symptom-reproduction run was 19.418s; query repair alone remained slow at 19.682s.
Same normal COM path, three ordered application requests and one history chunk.
All receipts preceded cinematic playback; no uncertainty state was observed in
the Singapore run. These are small observations, not a service latency guarantee.

Comparable initial web menu: **8.963s → 0.968s** overall. Query reduction alone
improved 8.963s→7.599s, commands 26→20 and transaction 3.841s→2.495s. The approved
region change removed most remaining database connection/command time without
changing query/write ordering, history, identity, transaction or award contracts.

Final Singapore flow saved the server +3 draw and paid the earned +5 weekly
quest: balance **39→47**, with 5-match history reflected in the menu's 20% win
ratio. Prior query-repair flow verified paid Scissors +1 and reload without
repayment. No reset/reseed/import/front-end deployment.

Creator feedback: **“Yes, the responsiveness is good now”**, followed by a new
concern that human matchmaking/relay progress may depend on focusing/unfocusing
the editor or local build. The creator subsequently confirmed that the targeted
human attempt progressed normally without needing focus, using the temporary
native game and existing web client. The intermittent concern is not diagnosed
or dismissed as the intentional COM wait. Do not check M13-pre complete yet.

## Starting source and predecessor boundary

Shared repository HEAD: `ce3d5b181bd8f21d0b87e8352d215bddb0b6ff9f`.
Both assigned workspaces are subdirectories of that repository. Starting state:
14 modified tracked files, three untracked documents, no staged files.
Predecessor work includes backend README/config/http/settlement-rules/tsconfig;
Godot API origin/settings/export/pack inspection; checklist/bootstrap/milestone/
polish-report edits; M12.5 report/manifest and the M13-pre brief. Preserved all of
it. Starting diff/inventory are outside Git at
`/private/tmp/m13pre-starting.patch` and `m13pre-starting-untracked.txt`.
A later exact comparison confirmed every untouched predecessor diff section
remained identical. M13-pre adds only its changes within the shared HTTP source
files; it does not absorb predecessor work into a commit.

Read the complete standalone brief, relevant M12.5 evidence and affected source.
No Devpost skills, learner profile, curriculum or full planning bundle loaded.
M12.5 acceptance is carried forward; no earlier boxes/reports or Final Review
were rewritten as completed. No delegation/chat operations.

## Measurements and method

API: `https://devpost-rockpaperscissor-backend.vercel.app`.
Same local single-threaded web candidate, existing owned **Firsthand** account,
actual unrestricted GD-Sync search and operational Ember. Four purposeful COM
rounds: symptom reproduction, instrumented baseline, query-repair check, then
approved-region verification. Each is a normal flow for a distinct measured change.
No preview, shortened windows, synthetic history or local rewards.

Client spans use monotonic `Time.get_ticks_msec()`. Queue = enqueue to dispatch;
request = dispatch to completion callback, including browser/preflight/network/
platform/backend costs. Server spans use process-local `performance.now()`.
No unsynchronized client/server wall-clock subtraction. Server spans overlap;
do not add transaction/index/DB spans together. Client-minus-handler includes
several unobserved components and is not pure measured network latency.

### A — current M12.5 deployment, symptom reproduced

| Operation | Queue | Client request | Calls |
| --- | ---: | ---: | ---: |
| Anonymous resume | 13ms | 2.193s | 1 |
| Initial menu | 15ms | 9.000s | 1 |
| COM registration | 0ms | 7.785s | 1 |
| Final status GET | 1ms | 3.681s | 1 |
| History upload POST | 0ms | 6.100s | 1 chunk / 1 call |
| Finalize POST | 0ms | 9.632s | 1 |
| Return menu | 1ms | 6.063s | 1 |
| Saved stats GET | 1ms | 3.531s | 1 |
| Saved records GET | 0ms | 3.685s | 1 |

Monotonic final freeze → validated durable receipt: **19.418s**, including
19.413s in three sequential HTTP requests. Server timings were unavailable.
Acknowledgement uncertainty appeared, then the receipt allowed the cinematic.
No retry click or repeated polling in this COM/authority path. Counts are
application calls, not browser OPTIONS or SDK relay traffic.

### B — timing-only deployed baseline, original behavior

| Operation | Client request | Handler | Connect | Index checks | Transaction | Summed DB commands | Count |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Resume | 3.265s | 2.153s | 1.917s | — | — | 0.222s | 1 |
| Initial menu | 8.963s | 7.778s | 1.898s | 1.800s | 3.841s | 5.839s | 26 |
| Register | 7.565s | 6.381s | 1.891s | 1.782s | 2.470s | 4.453s | 20 |
| Status | 3.047s | 2.334s | 1.878s | — | — | 0.439s | 2 |
| History upload | 5.717s | 4.975s | 2.092s | 1.759s | — | 2.858s | 13 |
| Finalize | 8.581s | 7.889s | 1.930s | 1.750s | 3.973s | 5.900s | 27 |
| Return menu | 8.596s | 7.869s | 1.933s | 1.817s | 3.879s | 5.901s | 26 |
| Quests | 7.268s | 5.909s | 1.869s | 1.778s | 2.026s | 4.005s | 18 |

Queue waits 0–5ms. Settlement **17.351s**, same three application requests and
one chunk, no retry/poll repetition. Across settlement, initial connect spans
summed about 5.9s and DB commands about 9.2s. Handler entry excludes module/import
and platform startup. Subsequent pool checkout/connection expansion is not
separately timed. Observed routing header: `sin1::iad1::...`; build region iad1.
No database configuration/region values are printed or recorded.

### C — deployed query repair, region unchanged

| Operation | Client request | Handler | Connect | Index checks | Transaction | Summed DB commands | Count |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Resume | 3.415s | 2.128s | 1.897s | — | — | 0.226s | 1 |
| Initial menu | 7.599s | 6.423s | 1.895s | 1.795s | 2.495s | 4.507s | 20 |
| Register | 6.765s | 6.070s | 1.908s | 1.832s | 2.086s | 4.126s | 18 |
| Status | 3.678s | 2.302s | 1.854s | — | — | 0.432s | 2 |
| History upload | 6.132s | 4.715s | 1.851s | 1.730s | — | 2.834s | 13 |
| Finalize | 9.865s | 8.603s | 1.923s | 1.769s | 4.679s | 6.626s | 30 |
| Return menu, reward paid | 5.183s | 4.504s | — | — | 3.130s | 3.341s | 15 |
| Menu after reload, no repayment | 4.488s | 3.852s | — | — | 2.468s | 2.684s | 12 |

Queue waits 0–13ms. Settlement **19.682s**, same three requests/one chunk and no
retry/poll repetition. This round completed Scissors: five additional commands
for its contribution/completion/next assignment versus B, while owner processing
removed two, explaining 27→30. Request overhead also varied. Therefore the
settlement samples do not establish a net latency improvement. The two initial
menu samples are comparable: same account/period, no payable reward, both show
initial connection and eight readiness reads. Return-menu samples differ in
process reuse/payment state and are not treated as an isolated latency gain.

### D — confirmed Singapore runtime, same query repair

| Operation | Client request | Handler | Connect | Index checks | Transaction | Summed DB commands | Count |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Resume | 0.322s | 0.0047s | — | — | — | 0.0023s | 1 |
| Initial menu | 0.968s | 0.1939s | 0.1309s | 0.0158s | 0.0344s | 0.0463s | 20 |
| Register | 0.483s | 0.2266s | 0.1480s | 0.0202s | 0.0398s | 0.0461s | 18 |
| Status | 0.747s | 0.1873s | 0.1660s | — | — | 0.0046s | 2 |
| History upload | 0.612s | 0.2277s | 0.1520s | 0.0227s | — | 0.0489s | 13 |
| Finalize | 0.717s | 0.3411s | 0.1756s | 0.0203s | 0.1270s | 0.1101s | 25 |
| Return menu, weekly paid | 0.449s | 0.1325s | — | — | 0.0737s | 0.0675s | 15 |

Queue waits 0–13ms; settlement **2.084s**, three requests/one chunk/no retry or
repeated poll. Resume did not show initial connection work; other rows explicitly
show initial connect and relevant readiness work. Baseline B versus D has two
fewer finalize commands from the owner-query repair (27→25). Outcomes/condition
and quest contents differ normally; command/request counts are reported rather
than pretending identical payloads. Same-code C→D also shows command round trips
falling from about 220ms to a few milliseconds, which isolates the material
regional improvement from query reduction and unrelated client queue behavior.

## Actual gameplay, receipts and saved consequences

Every receipt passed existing match/result/revision/history-digest/committed-time
validation before cinematic playback. Complete canonical history, immutable
chunk upload identity and original status→upload→finalize ordering are retained.

| Round | Server match | Receipt | Actual saved outcome |
| --- | --- | --- | --- |
| A | b8eaa8e7-d25e-4040-a7fc-ff6ce5ba12b3 | c3510d5a-7a6d-4cea-8f98-25ffd36fc71b | Honest Paper/Scissor loss, +0; balance 3 |
| B | ed705331-3509-4bf3-8adc-bae0ae6baf3c | 744149d6-c821-4020-a0b7-c4a90ca0a86d | Honest Paper/Rock Angel win, +25; balance 28 |
| C | e1059536-0732-40a3-a243-d2b023a6e781 | 17075bae-06be-43db-81bd-e88dc9d88249 | Honest Scissor/Scissor Angel draw, +10; then +1 earned daily payment, balance 39 |
| D | 04857c20-81cf-4de5-8faa-74b914f84e43 | 48ba05f4-0be4-4cf1-b92f-205ccdb801d2 | Honest Rock/Rock Devil draw, +3; then earned +5 weekly payment, balance 47 |

| Round | Normal fallback | Four decision windows |
| --- | ---: | --- |
| A | 38.517s | 15.016 / 15.000 / 15.014 / 15.015s |
| B | 30.763s | 15.000 / 15.000 / 15.015 / 15.014s |
| C | 40.237s | 15.015 / 15.000 / 15.015 / 15.016s |
| D | 33.015s | 15.014 / 15.000 / 15.004 / 15.015s |

Ordinary defaults and bot policy inputs were retained. In C a late initial
Scissors click is not claimed as accepted; Scissors was the actual leftmost
default and final choice. No timing was bypassed to manufacture history.
A saved stats read showed 2 matches, 0W/1L/1D, Lie 1/Honest 1; records retained
both its new loss and the earlier Secondhand draw. B's quests showed Play 3/5,
Switch 1/3, Lie 1/3 and active Scissors 0/1. C's return showed **39 points**, fresh
Win-3 0/3, win ratio 25%, streak 1. Ordinary reload restored Firsthand and a
second actual menu entry retained **39**, without paying Scissors again.
Saved menu screenshot: ignored `export/m13pre/repaired-menu-39.jpg`.
These are real UI/API saved-state observations, not a direct Atlas document audit.
C subsequently showed weekly Play 4/5, Switch 1/3, Lie 1/3, paid Scissors 1/1
and active Win-3 0/3. Its quests read took 6.734s / 16 commands versus baseline
7.268s / 18 commands. Screenshot retained at `export/m13pre/repaired-paid-quest.jpg`.
D outcome/menu screenshots are `sin1-acknowledged-outcome.jpg` and
`sin1-saved-menu-47.jpg` in the same ignored folder. Additional final browser
quest/stat/record reads were blocked before execution by automatic browser review
hitting the account usage limit. They are not claimed as performed; menu balance
47 and real receipt evidence were already captured. No alternate browser/raw
protocol workaround was attempted. Same-operation uncertainty retries/departure
arbitration were not fault-injected.

## Established causes, changes and remaining hypotheses

Client queue starvation did not explain these runs: waits were negligible.
There were no unnecessary COM polls. No human handshake/peer fault was
established; human session/coordinator code was inspected but not changed.

Confirmed redundant backend work: menu initialized/locked/expired the same quest
owner twice in one transaction at the same server time; normal owner processing
also split its read/locking revision increment and rewrote unchanged metadata.
The repair initializes once, combines read+locking increment atomically, and
persists period metadata only on an actual day/week transition. Expiry still
precedes payment/contribution. Status/profile/grant reads remain fresh within
the transaction. No cross-request authoritative cache, concurrent writes or
weakened transaction/participant/ownership checks.

The larger cause now measured is substantial deployment-to-database command
and connection time. Pool establishment occurs independently for the affected
functions. The existing per-process shared connection promise/pool limits are
preserved; no pool leak or close-per-request fault was found. The same-code regional
comparison confirmed materially lower connection/command time after switching
the function runtime to Singapore. Platform/import
startup and individual later pool-checkout waits remain unseparated.

A focused read-only local index comparison took serial **236.2ms** (225.4ms DB)
versus bounded parallel **317.5ms** (226.8ms summed DB), eight commands each.
Additional connection expansion offset concurrency locally; parallel index
checks were removed. No data was changed. Local conditions differ from Vercel;
no deployed startup speedup from that abandoned candidate is claimed.

M13-pre changed files, relative to the starting uncommitted tree:

- `backend/src/authoritative-quests.ts`: owner/query reductions and fresh view
  after once-only menu payment.
- `backend/src/m11-api.ts`: same menu route uses transaction-local menu operation.
- `backend/src/request-timing.ts`: small numeric request timing context.
- `backend/src/db.ts`: numeric connect/command timing; no command documents retained.
- `backend/src/settlement-store.ts`: readiness/transaction timing only.
- `backend/src/http.ts`: numeric Server-Timing header and exact allowed-origin
  exposure, layered over preserved M12.5 CORS handling.
- `scripts/api/http_api.gd`: optional queue/request timings; native user argument
  `--network-timing`, web `?network_timing=1`, disabled otherwise.
- `scripts/api/backend_result_sink.gd`: optional freeze→receipt duration/chunk count.
- `backend/vercel.json`: creator-approved single runtime region `sin1`.
- This report. Checklist and all earlier documents remain at their starting state.

No credentials, Authorization, query values, hidden gameplay payloads or MongoDB
configuration enter telemetry. Server diagnostics remain small and operationally
useful while the main latency diagnosis remains open. Pool/transaction timeouts,
UI uncertainty timeout, rules/configuration, API architecture and services are
unchanged. Source timing/reward/binding/history/departure contracts are preserved.

## Deployment and validation

An initial deployment was rejected by automatic approval review; it did not
execute. The creator subsequently explicitly approved backend-only api/src/
existing configuration/build uploads to the named Vercel project. The first two
M13-pre production deployments completed and aliased to the existing API:

1. Timing-only baseline: `dpl_3RFLqWstBFnGPkGrHGcvAq7gr9th`,
   `https://devpost-rockpaperscissor-backend-900tgsfv8-jam-jam-jam.vercel.app`.
2. Query repair: `dpl_4m5LwSqyazTQehfrjAYtN7k3YjPz`,
   `https://devpost-rockpaperscissor-backend-ghld7u4qa-jam-jam-jam.vercel.app`.

Both READY. Backend-only allowlisted trees: `/private/tmp/m13pre-timing-baseline-deploy`
and `/private/tmp/m13pre-repair-deploy`. 37 payload files uploaded (38 prepared
files including project-link metadata); no .env, credentials or Godot export.
Confirmed Root Directory **backend**, Output Directory **static-api-only**,
Node **24.x**. Same database/m12_ separation, accounts/history, bot/personality and
release configuration revision:
`sha256:12276ec41b7eb7894a2423e7721475ddbc225def4bf99c6459caaddd7e27787c`.
No reset, reseed, preview import or paid-service change. The later region change
was separately and explicitly approved by the creator.

Backend typecheck/build passed. Changed GDScripts passed explicit-path Godot
check-only. Focused HTTP-wrapper checks passed: allowed-origin OPTIONS 204,
missing-auth PATCH 401 with CORS/numeric timing/zero commands, disallowed-origin
403 without allow-origin. Those three were local direct-handler checks, not
claimed deployed endpoint coverage. Actual gameplay used the deployed functions.
`git diff --check` passed and nothing is staged.

Godot MCP tools were discovered, but supported editor path-expression access
returned missing/invalid-token AUTH_FAILED; runtime access returned stale or
unavailable state. No successful supported MCP project-path confirmation, so
no MCP scene/input success is claimed. No credential-like plugin state inspected.

Explicit-path fallback used Godot 4.7.stable.official.5b4e0cb0f and the assigned
absolute project path. Initial native launches resumed the owned account and
connected to actual GD-Sync (3.523s/1.828s account requests); no native COM claim.
A focused temporary headless main-scene menu smoke after repair resumed the same
named native identity (**1 match, 11 points**), connected to GD-Sync and completed
menu: 6.919s client, 6.431s handler, 2.476s transaction, **20 commands**. Its temporary
SceneTree harness emitted SDK null-current-scene startup errors before loading
main, then succeeded. This is API/menu evidence with a harness limitation, not
clean editor/full native gameplay acceptance. Harness/log in
`/private/tmp/m13pre-native-menu.gd` and `m13pre-native-menu.log`. Launched native
and extra editor processes exited; existing editor was left intact. Extra
editor also exposed unrelated development PreviewProfile parse errors, unmodified.

One targeted release export was necessary for client diagnostics:
`--export-release Web export/m13pre/index.html`, exit 0. Original preset unchanged.
Package: **136 entries, 596352 bytes**, SHA-256
`6373310c13a6ddb92a4b37e36f2d141a3b6722db1eb685efeffa3b27994e6f1e`.
Inspection found no unwanted development/private/preview assets, missing required
resources or packaged assertions. Manifest: ignored `export/m13pre/PackManifest.txt`.
Thread/extension/PWA settings stayed disabled and approved SDK distribution stayed
unchanged. Export emitted inherited SDK/editor-settings/MCP sandbox diagnostics;
exit/package/actual gameplay are the success evidence. No further export needed
for backend-only repairs.

Reused the already-running localhost:8125 static server through ignored link
`export/m12.5/m13pre` to the new candidate. Old export/server untouched. Served
pack hash matched. Actual URL:
`http://localhost:8125/m13pre/index.html?network_timing=1`.
No local backend substitute and no frontend deployment.

No exhaustive regression, race/concurrent-request campaign, failure injection,
stress/load, device matrix, human pair exercise or earlier feature suite repeated.
COM does not prove human join/handshake/takeover/departure/reconnection behavior.
No reconnection feature was added. Calendar boundaries were not re-exercised.

## Creator feedback, region decision and M13 handoff

Creator explicitly approved backend deployments and, separately, the Singapore
region change. After the 17.351s→2.084s receipt and 8.963s→0.968s menu measurements
were shown, the creator replied: “Yes, the responsiveness is good now”, then
reported a focus/unfocus concern about matchmaking/relay progress. This is positive
response-time feedback, not permission to ignore that new in-scope issue. The
creator's subsequent clarification and targeted test are recorded below.

The creator explicitly approved the region proposal: add only
`"regions": ["sin1"]` to backend/vercel.json, keeping the database/data, services,
project and plan unchanged. Vercel supports single-region selection on Hobby in
its [configuration reference](https://vercel.com/docs/project-configuration/vercel-json).

The source-only region deployment `dpl_6dxXk5cwHLyX2Kbqpz82MtrBtebq`
(`https://devpost-rockpaperscissor-backend-def4ivv7j-jam-jam-jam.vercel.app`)
was READY and its build metadata contained regions=[sin1], but actual live
routing remained sin1::iad1 and timings remained unchanged. No extra COM
round was run against that ineffective region application. This was detected
before claiming success.

The approved region was then applied explicitly using:
`vercel deploy --prod --yes --regions sin1 --cwd /private/tmp/m13pre-repair-deploy`.
Deployment **dpl_57Qf5iEFUPKrXeDYpACxRfmvHVQS** is READY, immutable URL
`https://devpost-rockpaperscissor-backend-8u063mf6l-jam-jam-jam.vercel.app`.
Actual API routing now confirms **sin1::sin1**. Build still runs in iad1;
build region is not the function runtime region. For this outer upload-tree /
nested Root Directory workflow, keep the explicit CLI region option and verify
runtime routing; do not assume nested configuration metadata alone changed it.
Root Directory backend and Output Directory static-api-only are unchanged.

The corrected ordinary-startup native scene harness against confirmed sin1
completed with the same native identity, 1 match and 11 points. Resume **0.595s**
(handler 0.161s, initial connect 0.144s, one DB command 0.0023s); menu **0.752s**
(handler 0.251s, connect 0.157s, index checks 0.0256s, transaction 0.0531s,
20 commands totaling 0.0612s). Compare the same 20-command iad1 native menu at
6.919s / transaction 2.476s. Temporary inherited scene/node harness paths are
`/private/tmp/m13pre-native-menu.tscn` and `m13pre-native-menu-node.gd`;
log `m13pre-native-sin1-confirmed.log`. The earlier null-current-scene harness
errors were absent; standalone SDK missing-debugger/shutdown diagnostics remain.

The regional COM verification completed with the real receipt and saved menu
consequences recorded above. M13-pre remains open only for the creator's new
focus-related matchmaking concern and its targeted evidence/feedback.

## Focus/unfocus follow-up — investigation open

Creator-reported symptom, not yet reproduced by the executor. Source inspection
found no custom focus-loss pause in the game or SDK. GDSync uses PROCESS_MODE_ALWAYS,
but its ConnectionController sends/polls ENet/WebSocket packets from _process,
and peer offer retries/pairing also depend on process frames. PROCESS_MODE_ALWAYS
bypasses SceneTree pause, not browser/OS scheduling suspension. Godot's editor
unfocused sleep setting is 16666µs, with the toolkit's responsive-unfocused option
enabled; that setting alone does not establish a multi-second runtime stall.
The COM fallback uses a SceneTreeTimer; relay switch/connect loops also await
process-driven timers. Whether this causes the creator's symptom remains a
hypothesis pending platform/flow clarification and real focused/unfocused evidence.

Automatic browser review hit an account usage limit and denied further localhost
browser observation. Godot MCP project access also still reports missing registry
AUTH_FAILED. No bypass via another browser/raw protocol was attempted. Read-only
source inspection continues; actual focus/relay reproduction is not claimed.
No speculative SDK/focus/timer changes have been made.

Stop boundary remains M13-pre: no M13 polishing, frontend deployment, Final Review,
learning or submission work. Preserve the verified regional latency fix while
resolving or honestly documenting this focused matchmaking follow-up.


### Creator clarification and prepared native measurement

Creator clarified the symptom affects **both two-human pairing and COM fallback**;
initial GD-Sync connection is fast. Both clients run on the same Mac, and both
visibly continue running in the background. Progress often appears when focusing
the editor playmode/game window or the local build. This does not establish an
inactive-tab suspension cause; distinguish unfocused-but-visible windows from
hidden tabs before attributing it to browser scheduling.

Current Godot documentation explicitly distinguishes these cases: inactive tabs
stop game processing; unfocused browser windows are not subject to that particular
limitation. See [Godot background processing](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html#background-processing).
SDK source polling/retry dependencies make frame-gap correlation relevant, but
no focus fix has been implemented or claimed.

A temporary **native-only observation harness** was checked and launched through
the assigned absolute project path. Files: `/private/tmp/m13pre-focus-trace.gd`
and `m13pre-focus-trace.tscn`; log `/private/tmp/m13pre-focus-native.log`. It loads
the real main scene and existing owned native account, starts no match itself,
and records OS window focus events, monotonic frame gaps/sample frame counts,
SceneTree pause state, coarse queue/relay/peer-binding stages, peer count and
active HTTP route without queries/payloads. No credentials, account IDs, relay
proofs or addresses. No game settings, SDK behavior, timeouts or gameplay changed.
Initial runtime log confirmed exact project path, actual GD-Sync connection and
valid observation output with no diagnostic script errors.

The creator was asked for **one targeted real two-client attempt**, using the
existing native/web identities, both windows visible and brief focus changes.
Native logs can be read without controlling/observing the blocked web browser.
This does not bypass the browser review gate: the agent does not read browser
content through another tool or extract browser state indirectly. Native focus
data plus creator-observed peer progress is the intended evidence. No new web
export was needed for this native-only temporary harness.

### Targeted human-pair observation

Creator reported: **“Human pair reached arena and round finished.”** They then
confirmed the two clients were the **temporary native game and existing web
client**, and clarified: **“Somehow no, this attempt progressed normally. But this
time the gd-sync connection handshake took a bit longer.”** The temporary native
process subsequently exited normally. Its trace independently establishes human
reservation/arena handoff, but contains no phase/result/receipt output after
handoff; therefore this report records creator-observed completion and does
**not** independently certify human saved consequences from that attempt.

Native search used unrestricted matchmaking and selected a normal **44.077s**
fallback. SDK queue-found was observed at search age **8.747s**, peer offer at
**11.293s**, and arena handoff at **13.043s**. The single `matches/join` request
took **1.116s**, queue wait 0ms; server handler 224.1ms, connect 149.7ms,
index checks 20.4ms, transaction 35.5ms, DB commands 42.8ms / 17 commands.
Permanent match ID: `a55b5c16-1329-4e21-86d9-45ff140e8ce5`.
No COM fallback was consumed in this successful pairing attempt.

An unfocused sample recorded **596 process frames over 5.000s**, peak inter-frame
gap **37ms**, and `paused=false`. Subsequent search-stage samples had peak gaps
21ms, 17ms and 20ms. Available native samples do not demonstrate a multi-second
focus-loss processing stall. Refocusing occurred near queue progress; temporal
proximity alone does not establish a focus dependency, especially without the
other client's start/focus trace. This one attempt does not establish the cause
of the separately reported COM fallback symptom or prove every background case.

After the prior browser usage-limit reset time, the same official browser surface
was retried: the old tab handle was stale and the selected IAB's tab inventory
was empty. No alternate browser, raw browser protocol or credential extraction
was used. Existing creator/editor clients were not closed. No speculative
focus/timer/SDK change or additional deployment resulted from this observation.

### GD-Sync / Photon comparison and residual work

The creator's experiential benchmark is Unity/Photon, which feels significantly
faster. No equivalent Photon run or official comparative latency benchmark was
established in this assignment. Do not label GD-Sync inherently slower or treat
this single first-client queue age as supplier matchmaking latency.

The installed SDK identifies itself as **1.0.2**. GD-Sync's
[connection documentation](https://www.gd-sync.com/docs/general-information)
describes load-balancer routing, latency-based game-server selection and moving
players to a common server when necessary. Its
[matchmaking documentation](https://www.gd-sync.com/docs/matchmaking)
distinguishes match-found from lobby-joined and supports queue-only matching.
This game already uses MATCHMAKE_ONLY, two players and unrestricted skill matching;
no public-lobby scan or rating-window expansion is configured. The SDK's current
[1.0.2 notes](https://www.gd-sync.com/patch-notes/patch-notes-1-0-2) discuss packet
correctness fixes, not a general promise of connection or matchmaking speed.
No SDK upgrade or vendor modification was made.

Photon's [matchmaking guide](https://doc.photonengine.com/realtime/v5/matchmaking/matchmaking-and-lobby)
describes random room matching and same-region requirements. A comparison needs
equivalent queue/room mode, region, transport, both clients already ready and the
same endpoint definition. Unity versus Godot alone does not isolate a cause.
This is an interpretation of the documented flows, not a measured vendor ranking.

For the actual trace, queue-found → arena was **4.296s**, including the local
**1.116s** join request, lobby/peer coordination and the host's necessary permanent
registration/binding path. Host request timing and the other client's queue-entry
time are unavailable. The initial SDK connection has no start/connected duration
pair in this trace, so the creator's longer initial handshake remains unmeasured.
The approved Vercel sin1 repair affects the separate application API, not the
GD-Sync relay region. The intentional 30–45s COM wait is not a supplier speed test.

No reproducible focus stall or unnecessary peer delay was established, so no
speculative timer/transport/architecture change is justified. Next concrete step
if this concern is pursued: one targeted attempt with sanitized **per-process**
start→connected and queue-start→match-found→lobby-joined→backend-bind→arena event
spans on both real clients, including focus/frame gaps. Separate waiting for the
second client from service join and application binding; do not subtract client
wall clocks. For a COM-specific recurrence, capture the selected wait, monotonic
expiry, cancellation ACK and registration spans while recording focus/frame gaps.
Do not repeat a broad gameplay suite or shorten the required wait.

M13 stability handoff: retain the measured backend/query/region repair and
optional sanitized timings; preserve all receipt and data contracts. The
intermittent connection/matchmaking concern is a residual investigation, not a
confirmed repaired defect. M13-pre completion remains unchecked; no M13 polishing
or frontend deployment has begun. Nothing staged or committed.

### Creator-requested Singapore GD-Sync routing check

The creator explicitly requested choosing Southeast Asia / Singapore for GD-Sync
because the observed wait feels unacceptable compared with their Photon work.
This authorizes that specific region change if a valid mechanism is available;
no additional region approval was requested. This is separate from the already
approved and verified Vercel sin1 application API deployment.

Inspected installed 1.0.2 `MultiplayerClient.start_multiplayer()`,
`ConnectionController._start_native_connect()`, `_start_web_connect()`, ranking
and server-switch paths, `MatchmakingRequest`, game ServiceConnection and current
search Resource. No supported Singapore/region selector or country metadata was
found. Native fetches the service-provided server list and ranks UDP ping replies;
web ranks the configured ws1/ws2 gateways, and its lobby transfer reconnects to
the chosen gateway while the service coordinates the destination. The internal
`_manual_connect(address)` is not a documented region API and does not provide a
verified Singapore endpoint or a native/web routing guarantee. No invented
address, hardcoded ephemeral server, extra region matchmaking tag, credentials
change or SDK modification was introduced. A region tag would only split matching
players; it would not establish the server's physical location.

Official [connection documentation](https://www.gd-sync.com/docs/general-information)
describes automatic lowest-latency selection and shared-server transfer. Checked
the official advanced/matchmaking docs, repository and 1.0.2 notes; these checks
did not establish a supported manual Singapore selection mechanism. This does
not prove the provider has no Singapore capacity. Dashboard-only or unpublished
provider controls were not verified. **No GD-Sync region change was applied.**

To isolate the newly reported initial connection delay, made a temporary
connection-only native observer through the explicit assigned project path.
It starts the real existing SDK once, logs monotonic numeric states/durations,
then disconnects and exits. It performs no matchmaking or application account/
history writes and logs no endpoints, payloads, keys or credentials. Verbose SDK
logging was disabled in this temporary process before starting the connection.
No source/export/backend deployment was required.

An initial custom SceneTree-script attempt reached connected at 3.706s but
triggered the SDK's null-current-scene startup errors; it is not the primary
result. Corrected to ordinary scene startup, checked the script successfully,
and measured **3.342s** total:

| Observed native connection segment | Duration |
| --- | ---: |
| Start / FINDING_LB → PINGING_SERVERS | 1.602s |
| PINGING_SERVERS → CONNECTING | 0.622s |
| CONNECTING → assigned-client CONNECTED | 0.427s |
| CONNECTED → SDK connected signal | 0.691s |

The final span includes the installed SDK's fixed 0.5s readiness timer in
`RequestProcessor.secure_connection()`. It was not removed or shortened without
establishing protocol correctness. These are process-local observed state spans,
not individual network RTTs, country evidence or a matchmaking benchmark. The
ordinary-scene attempt had no null-current-scene errors; inherited standalone
missing-debugger/profiler shutdown diagnostics remain. Both observations exited.
The first sandboxed check also failed opening the default user log and crashed;
an explicit temporary log path allowed check-only to pass. Do not count failed
diagnostic setup as successful gameplay evidence.

Temporary ordinary observer: `/private/tmp/m13pre-sdk-connect.tscn`,
`/private/tmp/m13pre-sdk-connect-node.gd`; primary log:
`/private/tmp/m13pre-sdk-connect-ordinary.log`. Godot MCP path confirmation was
retried and still returned missing registry AUTH_FAILED; no MCP scene/runtime
success is claimed. The absolute CLI project path was printed by the observer.

Remaining prerequisite for the requested routing change: GD-Sync must confirm a
supported Singapore route/region override for **both native and web**, its effect
on cross-region lobby transfer and unrestricted global matching, and any plan
requirement. No provider message was sent. Once that exists, apply the already
requested region preference and make one comparable ready-client pairing check.
Until then the requested region change is unavailable with verified capabilities;
M13-pre stays partial with the backend responsiveness repair preserved.

### Creator-authorized entry gate and offline presentation follow-up

The creator subsequently requested a quick, simple flying-text/title opening,
account/multiplayer readiness gate, first-name prompt after Tap To Continue,
direct-bot iteration and a completely simulated session for presentation work.
This explicitly expands the earlier stop boundary for these named changes only;
it does not authorize the rest of M13 polishing. They requested editor checks
only, without a broad suite. No further deployment or web export was performed.
The previously served M13-pre web candidate does **not** contain these new changes.

Read only the owning PRD opening subsection and narrow opening references in
scope/spec/Game_Vision to resolve the requested flow. No exact flying-text
choreography/copy was found there; reused the existing “Every claim hides a
choice” caption with a simple upward entrance/exit and Inspector-exposed timings.
No new art, sound or elaborate title treatment was added.

Live startup still begins the existing asynchronous account and GD-Sync work
concurrently. Continue waits for the opening, account identity and actual SDK
connected signal. The title shows Connecting to server / Connecting to multiplayer
server as appropriate, retains real failure/retry feedback, then exposes Continue.
New players tap before the name prompt; validated naming then opens the menu.
Returning players retain their owned account and normal menu request. A loading
guard prevents repeated taps from dispatching duplicate menu entry requests.
This is a readiness/feedback improvement, **not a measured connection-time fix**.

Development usage:

- Open `scenes/development/presentation.tscn` and use **F6** for offline authoring.
- Alternatively, editor runs of the ordinary menu expose **Presentation • offline
  bot**. Release builds hide/guard that action.
- In the preview menu, **Play bot now** reserves a local bot immediately, bypassing
  the service queue. The condition selector is available for presentation work.
- No application HTTP transport or GD-Sync connection is started by this scene.
  Its blocking API adapter fails closed on accidental use. Identity, aggregate
  statistics, quests and records are simulated in memory; reset affects only this
  preview. No live credential/account/history file is read or changed by it.
- Existing arena, bot policy, chat presentation, full 15-second windows and reveal
  are reused. Simulated receipts are explicitly labelled; a separate development
  gate accepts them only for development/nonpersistent envelopes. The production
  receipt gate is unchanged and continues requiring durable server commitment.
- The offline scene includes explicitly fake 70/20/10 initial-card, 60% lie and
  50% switch examples. They are never sent to the backend or used as live stats.

Changed files for this follow-up:

- `scripts/app/main.gd`, `scenes/main.tscn`,
  `scripts/networking/service_connection.gd`: readiness gate and editor shortcut.
- `scripts/resources/opening_motion.gd`, `resources/presentation/opening_motion.tres`,
  `scripts/presentation/opening_sequence.gd`, `scenes/ui/opening_sequence.tscn`:
  small reusable opening and tuning.
- `scenes/development/presentation.tscn` and
  `scripts/development/presentation_{main,provider,service,api,match_session,gate,receipt}.gd`:
  isolated offline adapters, inherited scene and simulated-receipt contract.
- `scripts/api/local_preview_provider.gd`: restore its development-only receipt
  validation instead of passing simulated receipts to the real commitment gate.
- `scripts/app/arena.gd`: clarify the existing snapshot comment; no stats behavior
  changed. `export_presets.cfg`: add scenes/development exclusion, preserving the
  predecessor preset changes and existing script/resource exclusions.

Focused verification: Godot editor import passed; final main-script check-only
passed. The creator's existing editor showed an unsaved `main.gd` buffer, so it
was not saved, run or closed. A separate editor was opened for import/parse
observation and then closed. MCP project confirmation still failed (missing
registry, then invalid token); no token probing or successful MCP runtime claim.
Runtime verification used temporary inherited-scene checks with the **editor
binary**, explicit assigned project path and normal renderer. Actual F6 automation
in the creator's original editor was not performed. No web/device matrix checks.

Live-entry check (`/private/tmp/m13pre-entry-check.log`, exit 0): initial Continue
blocked; title displayed Connecting to server; only after actual identity/SDK
readiness did Continue enable; existing saved menu loaded and editor presentation
button appeared. Two HTTP calls only: anonymous resume 1.496s, menu 1.071s. No
matchmaking or new live account was created by this check.

One offline round (`/private/tmp/m13pre-presentation-check.log`, exit 0): opening
blocked Continue; resetting memory then tapping exposed naming; naming opened
menu; immediate local-bot handoff succeeded. Four windows measured 15000/15001/
15010/15003ms. Simulated result applied once in memory and reached the outcome;
receipt simulated=true, persisted=false, serverAcknowledged=false. API adapter
send_attempts **0**, SDK connection status **DISABLED**. No real receipt/credit is
claimed for this deliberately simulated check. Existing standalone SDK debugger/
profiler diagnostics remain; no errors from the new scripts were observed.

Evidence screenshots (ignored local artifacts) are in
`export/m13pre-entry-evidence/`: opening, ready, offline-menu, offline-bot,
offline-outcome, live-connecting, live-ready and live-editor-menu PNGs. Temporary
check scripts/scenes remain outside source in `/private/tmp`. All temporary run
processes and the extra editor exited; the creator's editor/server were preserved.
An exact diff-section comparison against `/private/tmp/m13pre-entry-starting.patch`
confirmed no unexpected changes to preceding tracked work. Nothing staged/committed.

Opponent statistics answer, established by source: backend registration/join
responses carry opponentPublicProfile; the session installs it into the
MatchParticipant. `arena.gd` uses that snapshot for initial-card, lie and switching
tendencies. Displaying a phase or redrawing a label makes **no HTTP request**.
Binding confirmations may return the snapshot again during setup; there is no
per-phase stats fetch. Existing saved-data modal requests remain explicit user
actions. No unnecessary new stats cache/provider/API was added.

Transport clarification: [Photon's PUN2 documentation](https://doc.photonengine.com/pun/current/reference/encryption)
states Unity WebGL exports use WSS by default, independent of the selected native
protocol. Native PUN can use UDP. Therefore WebSockets alone do not establish the
cause of the creator's observed vendor difference. No transport/service replacement.

Creator review of this latest entry/offline follow-up is pending. The earlier
backend response-time approval and unresolved intermittent matchmaking/routing
limits remain as recorded above; no milestone/Final Review boxes were changed.

### Latest iteration — shared UI with independent live/presentation roots

The creator requested a separate shared UI scene, live-only connection
requirements, and immediate offline startup under the fixed name **Test-Human**.
They want rapid presentation iteration without repeated server connections or
intro hold times. The hypothetical 100-connection loop was not executed.

Current composition:

```text
scenes/main.tscn
  UI                       -> scenes/ui/game_ui.tscn
  ConnectionRequirement    -> scenes/networking/connection_requirement.tscn
    ProfileProvider / Api / ServiceConnection / OpeningSequence

scenes/development/presentation.tscn
  UI                       -> the SAME scenes/ui/game_ui.tscn
  ProfileProvider          -> memory-only presentation provider
```

Presentation no longer inherits the live main scene or its startup script.
It contains no ConnectionRequirement, ServiceConnection, Api or OpeningSequence
node. Its provider initializes synchronously as Test-Human; the menu is visible
at full opacity in the root ready callback, before the first process frame.
No Tap To Continue, naming prompt, startup tween, hold or network prerequisite.
Reset clears only memory and immediately reinstalls Test-Human. Existing direct
bot, condition selector, arena presentation and explicitly simulated receipt
adapters remain. No real account, statistics, credentials or backend data touched.

The shared UI scene owns the visual hierarchy, menu interactions, data views,
matchmaking/arena presentation and provider bindings. It does not start account
or service connections. Shared layout work should be authored there (and in its
existing nested arena/UI scenes), so both entry scenes receive the changes.
Live-only `connection_requirement.gd` owns entry/naming/readiness/retries and the
opening. ServiceConnection now starts only when its owning controller explicitly
calls `start()`, rather than connecting as a side effect of its ready callback.
The live composition retains the real provider, API, SDK signals and receipt gate.

Files added: `scenes/ui/game_ui.tscn`, `scripts/app/game_ui.gd`,
`scenes/networking/connection_requirement.tscn`,
`scripts/networking/connection_requirement.gd` (and generated script UIDs).
Files reworked: `scenes/main.tscn`, `scripts/app/main.gd`,
`scripts/networking/service_connection.gd`,
`scenes/development/presentation.tscn`,
`scripts/development/presentation_main.gd`,
`scripts/development/presentation_provider.gd`.
Removed the preceding iteration's now-unneeded presentation_api/service stubs
and their UIDs; they were introduced by this executor, not predecessor files.
Starting boundary: `/private/tmp/m13pre-shared-ui-starting.patch` plus saved
pre-extraction main script/scene copies in `/private/tmp`.

Verification was deliberately short and offline. Editor import/class registration
completed; no new-script parse errors. Existing SDK editor shutdown signal and
MCP stale-process diagnostics/duplicate ignored export-image UID warnings remain.
Supported MCP project confirmation still failed AUTH_FAILED; original unsaved
editor buffers were not saved or modified. Explicit-path editor-binary observer
`/private/tmp/m13pre-composition-check.tscn` exited **0**. Its trace confirmed:

- Menu ready at full opacity before first process frame; name Test-Human.
- Entry/naming/Continue disabled; no live connection nodes or intro instance.
- **Zero HTTPRequest nodes** in the process tree; GD-Sync status DISABLED.
- Live scene successfully parsed/instantiated **without entering the tree**;
  its required connection nodes exist and its UI scene path matches presentation.
- Memory reset remained immediate and retained Test-Human.
- Direct bot reservation/Option entry retained Test-Human; still zero HTTP nodes
  and GD-Sync DISABLED. Four full window rules and reveal adapters were unchanged;
  no repeat of the already completed offline full-round check was needed.

No backend/multiplayer service connection or account request was made by this
verification. No web export, deployment, vendor change, load loop or broad suite.
Log: `/private/tmp/m13pre-composition-check.log`; screenshots:
`export/m13pre-entry-evidence/test-human-menu.png` and `test-human-bot.png`.
The existing web export predates this source refactor. Both clients must use an
updated matching build before another live human test: extracting the UI changes
the SDK-exposed session node's scene path. Mixed old-web/new-native human pairing
was not tested or claimed compatible. Actual online entry after the refactor was
not rerun; the live composition was checked without making server requests.

Current authoring entry: open **scenes/development/presentation.tscn**, press **F6**,
then **Play bot now**. Edit **scenes/ui/game_ui.tscn** for shared layout changes.
No additional creator acceptance, M13-pre completion or Final Review completion
is fabricated. Existing backend repairs and unresolved vendor routing limits
remain as recorded; nothing staged or committed.
