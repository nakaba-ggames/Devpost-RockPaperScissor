# M13-pre — Backend/network stability and gameplay responsiveness

Status: **closed by explicit creator instruction, 2026-10-24; implementation/evidence and residual limitations are in docs/reports/M13-pre_Report.md**. This original assignment is retained for history, not authorization to resume network work. The HUB performed closure/handoff documents only. M13 initial polish follows docs/AGY_Polishing_Handoff.md. Creator-authorized 2026-10-24, before M13 polishing. Checklist slice: **13-pre**. Executor report after actual work: `docs/reports/M13-pre_Report.md`. This is a game-engineering assignment, not a Devpost learning/shipping workflow. The creator assigns the executor manually.

## Minimal context and current baseline

Godot: `/Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor`.
Backend: `/Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/backend`.
Deployed API: `https://devpost-rockpaperscissor-backend.vercel.app` (confirm current configuration).

The creator says M12.5 is good to go and explicitly authorizes this next assignment. Its report still records the earlier pending-feedback/commit state; preserve history. Carry forward acceptance without asking for it again. At preparation, M12.5 source/report/export-manifest changes remain uncommitted, with no staged files; preserve them. Review Git status/diffs and establish the working baseline before editing. Do not reset, blanket-stage, absorb predecessor changes into a new milestone commit, or rewrite their report as completed evidence. Do not block useful work merely because M12.5 completion bookkeeping has not caught up.

Read this brief and only source/report portions relevant to an observed problem. Do **not** load `.agents/skills/`, any Devpost `SKILL.md`, the learner profile, curriculum, full planning bundle or learning/shipping workflow. This explicit creator instruction overrides generic skill-reading requirements for M13-pre and M13. Relevant contracts are summarized here; consult a narrowly targeted owning document only when a real contract ambiguity requires it.

## Objective and starting evidence

Find and fix reproducible backend/HTTP/GD-Sync problems causing unnecessary delays, stuck/repeated operations or poor network-related gameplay responsiveness. Preserve the existing game and permanent data.

M12.5's **executor-reported** local-web observations measured final lock → durable receipt at approximately **18.416s** and **11.006s**, with a brief acknowledgement-uncertain state before successful automatic completion. Native also showed temporary uncertainty. Those successful receipts were real and preceded the cinematic. These observations identify a starting path, not a proven root cause or universal latency benchmark. No fresh audit/performance run was performed by the HUB. M12.5 human-join/takeover/departure cases remain unverified, not failures inferred from COM evidence.

## Focused investigation and allowed work

Trace the player-visible critical path: startup/auth/menu, queue/registration/join, phase/peer coordination, final lock → status/history upload/finalize/commit → receipt/cinematic, return/menu and data views. Start with the reported receipt delay and any concrete creator repro; prioritize observed faults over speculative backend cleanup.

Inspect existing Godot `scripts/api/http_api.gd`, `backend_result_sink.gd`, `history_wire.gd`, `live_profile_provider.gd`, networking session/coordinator and receipt gate; related Resource settings. Inspect affected backend routes/HTTP wrapper/config, history-upload, settlement/store/quest/query modules and MongoClient reuse. Reuse the existing twelve API handlers; do not recreate them.

Use small sanitized timing observations to distinguish client queue wait, request duration, upload steps, polling delay, function startup and database/transaction work where observable. Use monotonic timings within each process; do not subtract unsynchronized client/server wall clocks as a measured network latency. Label unavailable server timings and inferred cold/warm conditions. No credentials, Authorization values, hidden card/history payloads or MongoDB configuration in telemetry.

Fix demonstrated request scheduling, redundant work, repeated polls/callbacks, retry/cancellation lifecycle, avoidable serialization, query/pool/startup or live-session synchronization problems within this scope. Concurrency or caching is an option only when supported by evidence and operation dependencies: preserve match/menu ordering and never serve stale authoritative state as fresh. Do not globally parallelize writes, remove status protection or alter transaction semantics just to reduce request count. Keep diagnostics small and temporary/optional unless needed operationally; no observability framework or benchmark infrastructure.

Pending/retry feedback may be corrected for accurate responsive behavior using existing UI/animation hooks. Merely extending timeouts, suppressing uncertainty or hiding waits is not a latency fix. Separate actual response improvement from feedback-only changes. Exact timing thresholds are measured/discussed, not invented service guarantees. Do not use synthetic previews, local result prediction or precommit cinematic playback to mask delay.

## Contracts that must stay intact

- Godot 4/GDScript client; existing TypeScript/Node backend. Single-threaded portrait web, asynchronous HTTPRequest with `use_threads=false`; no client threading/dependency replacement.
- Readable modular code, explicit if/else, Inspector-exposed custom Resource `.tres` for adjustable tuning, existing base/inherited scenes and animation hooks. No new art, cosmetic overhaul, audio or polish; M13 owns presentation.
- Four full **15-second** revisable choice windows. Required **30–45-second** normal COM fallback wait and unrestricted real GD-Sync matchmaking. These are intentional gameplay time, not unwanted latency to remove. No new reconnection, balance/quest rules, account architecture or hidden-state exposure.
- Private anonymous credentials/owned storage; Authorization/ownership/participant checks; proper CORS. Do not silently recreate identities on transient failure.
- Immutable permanent participant bindings, exact canonical history/defaults/revisions, chunk identity/order/digest/paged-read authorization, authored versus deployment revision distinctions.
- Durable server commitment **before** cinematic; server-calculated results/rewards. Query/retry the same match/upload/menu operation identity on uncertainty; no fabricated receipt, truncation, duplicate credit or new gameplay revision cap.
- Precommit departed human/takeover side receive no saved credit; survivor continues; postcommit result immutable. Keep departure arbitration serialized against commitment and independent human receipt reads.
- Real operational bots and approved Resource personality/configuration; current Atlas database **m12_** collection separation. Preserve all existing accounts/history, earlier test collections and earned data. No reseed/reset/import of preview or synthetic progress.
- Separate Vercel frontend/backend projects/repositories. Backend Root Directory `backend`, Output Directory `static-api-only`; no Godot export uploaded/required. Necessary backend-only corrections use the existing deployment workflow without paid/service/region changes unless specifically approved. Creator retains frontend deployment/testing.
- Required release behavior outside assertions. Filter any necessary local web export to actual scenes/path-loaded resources, excluding private/source/development content. Existing SDK client-pair distribution approval remains; never expose values.

## Proportional verification and acceptance

Reproduce a normal affected flow against the real deployed API and record a modest baseline. Repair the cause, then repeat only the affected normal flow under comparable conditions, reporting request counts, relevant timing spans, errors/stalls and actual stored consequences. Prefer editor/native first; reuse the current local web candidate when valid. If client changes require a fresh candidate for this milestone, make a targeted local web export and record it; do not repeat M12.5's full feature suite. No frontend deployment or hosted-frontend acceptance gate.

Use a real COM round for receipt-path work. Use two distinct real clients only when investigating/fixing an actual human handshake, peer timing or takeover issue; COM cannot establish human networking. Keep verification limited to the changed contract/observed issue. No exhaustive edge/regression/fuzz/load/stress/race/concurrent-request/outage/failure-injection campaign, endless play loops, device matrix or replay of earlier suites. A focused check needed to establish a repaired contract is in scope; broad fault injection is not.

Discover Godot MCP tools and confirm the exact connected Godot project through supported project-path evidence before relying on scene/runtime operations. Record unavailable tools and explicit-path/native/local-web fallback evidence without probing credential-like internal state.

Show the creator measured before/after behavior and obtain feedback on the repaired network-related experience. Carry M12.5 acceptance forward; do not reopen it. Identify platform/network limits and residual gaps honestly. Do not promise zero delay or claim an untested human/departure path works. If an in-scope problem cannot be fixed, report partial with the cause/evidence and next concrete action.

Write `docs/reports/M13-pre_Report.md`: working baseline/uncommitted predecessor boundary; observed symptom; root cause versus hypotheses; changed files; actual backend deployment if needed; before/after comparable timing/request evidence; real receipt/saved-state correctness; affected editor/local-web checks; creator feedback; limitations and remaining issues for M13. No placeholder report now.

Record only this milestone's completion when implementation, focused evidence and creator feedback support it. Never stage/commit automatically in conflict with direct creator instruction; preserve predecessor/unrelated work. If the creator requests a commit, review explicit intended changes and avoid sweeping in M12.5 changes; do not make completion depend on an invented broad testing or curriculum gate. Update only 13-pre's progress/report, not earlier pending boxes or Final Review.

Stop after the assigned stability work. No M13 polishing/SFX/music, frontend deployment, chat creation/messaging/delegation, learning wrap-up/app map, 6-ship or submission material.
