---
doc: milestones
status: approved
updated: 2026-10-24
---

# Devil's Rock Paper Scissor — Milestones

Approved plan following the creator's implementation order supplied on 2026-10-22. No milestone is executed or verified by approving this plan. The scope, PRD and spec remain the submission contracts; this plan stages their implementation without changing the final boundary.

## Authority and Scope

This HUB prepares/reviews documents only. Implementation belongs in separately assigned milestone chats. Do not create or message chats automatically. In this HUB, `5-build` ends at checklist review even after approval.

Every executor must first read [AI_Bootstrap.md](AI_Bootstrap.md), this workflow, its assigned milestone below, and the mapped slice in [checklist.md](../devpost/checklist.md). Execute **only the milestone ID assigned by the human**, not every unchecked slice. If the assignment is absent or unclear, obtain it before implementation. Completion of one assignment does not authorize the next. Do not introduce worktrees, broad refactors, future screens or service replacements simply to expand the assignment.

The first implementation chat establishes learn/fast mode and records it in the checklist; later chats carry it forward. The creator's request to move quickly is not recorded as a completed hands-on check or an automatic mode selection. Both modes retain mechanical verification and the planned learner feedback.

## Distribution and Dependencies

Original approved distribution: **12 milestones**. On 2026-10-24 the creator explicitly split final integration into revised M12 (deployment preparation, complete) and M12.5 (editor/local-web integration, pending), retaining every original ID and the supplied group order. The creator subsequently added **M13 — Polishing**, likely to be executed using AGY; it is planned, not assigned or started by this HUB. Gameplay has three and submenus have two, within the creator's ranges. Each milestone adds a usable behavior; setup lives in M01. M10–M11 preserve the requested late backend stage but each must leave runnable real API evidence, not an isolated untested technical layer. The core deception sequence starts at M03 and completes its local loop by M06.

The creator added **M13-pre — Backend/network stability and gameplay responsiveness** on 2026-10-24, between M12.5 and M13. It is a narrowly scoped game-engineering assignment, with no Devpost skill/curriculum loading; its standalone brief avoids the full planning bundle. M12.5 acceptance is carried forward from “good to go”; historical completion bookkeeping and uncommitted work remain preserved.

The default dependency is the preceding milestone; additional prerequisites are named in each brief. No parallel execution or reordering is assumed. The official checklist is the single progress owner: one milestone maps to one slice with the same number. This document owns detailed scope, criteria and handoffs; avoid a second set of completion checkboxes here.

| Milestone | Creator group | Usable result | Checklist slice | Executor report |
| --- | --- | --- | --- | --- |
| M01 | Creator step 1 | Rough main menu and real GD-Sync connection | 1 | `docs/reports/M01_Report.md` |
| M02 | Creator step 2 | Play and simulated matchmaking with live-shaped behavior | 2 | `docs/reports/M02_Report.md` |
| M03 | Creator step 3, gameplay 1 of 3 | Gameplay I — arena intro and initial choice | 3 | `docs/reports/M03_Report.md` |
| M04 | Creator step 3, gameplay 2 of 3 | Gameplay II — identity claim and change claim | 4 | `docs/reports/M04_Report.md` |
| M05 | Creator step 3, gameplay 3 of 3 | Gameplay III — final choice, round resolution and local bot behavior | 5 | `docs/reports/M05_Report.md` |
| M06 | Creator step 4 | Cinematic reveal, result and return to menu | 6 | `docs/reports/M06_Report.md` |
| M07 | Creator step 5, submenus 1 of 2 | Submenus I — statistics, records and leaderboard | 7 | `docs/reports/M07_Report.md` |
| M08 | Creator step 5, submenus 2 of 2 | Submenus II — daily and weekly quests | 8 | `docs/reports/M08_Report.md` |
| M09 | Creator step 6 | Live GD-Sync matchmaking and multiplayer | 9 | `docs/reports/M09_Report.md` |
| M10 | Creator step 7, backend 1 of 2 | Backend I — anonymous identity and saved-profile APIs | 10 | `docs/reports/M10_Report.md` |
| M11 | Creator step 7, backend 2 of 2 | Backend II — match settlement and authoritative quests | 11 | `docs/reports/M11_Report.md` |
| M12 | Creator step 8, revised | Backend deployment preparation | 12 | `docs/reports/M12_Report.md` |
| M12.5 | Creator step 8, follow-on | Connect Godot to deployed functions and verify editor/local web gameplay | 12.5 | `docs/reports/M12.5_Report.md` |
| M13-pre | Creator-added network pass | Backend/network stability and gameplay responsiveness | 13-pre | `docs/reports/M13-pre_Report.md` |
| M13 | Creator-added presentation pass | Polishing | 13 | `docs/reports/AGY_Polishing_report.md` |

## Development Adapters and Evidence

M01 connects to the actual GD-Sync service. M02–M08 use development match/data/result adapters; M09 replaces the match transport with real GD-Sync while keeping preview identity/persistence. M10–M11 prove the real backend independently; M12 preserves deployment preparation and initial integration work; M12.5 finishes the remaining provider integration against deployed functions. This is the creator-requested staged build, not a reduction of the submitted multiplayer/backend scope.

Keep a small explicit contract at each boundary: identity/profile, match lifecycle/events, data queries/menu entry, and finalization/receipt. Development and live providers must return compatible shapes so later work replaces a provider, not the UI/rule flow. No generic injection framework or elaborate state machine is required. Fixtures, injected clocks and simulated receipts must be identified in reports and isolated from production; preview history must not be uploaded as real history.

M06 may display a development acknowledgement; it is never evidence that the server knows the result. M09 may prove actual human networking with preview profile ratings; it is not proof of backend-held ranking or persistent credit. M12.5 verifies the integrated server-committed COM journey from editor/native and locally served web; hosted frontend and human/takeover coverage remain distinct evidence. Reports must distinguish real human peers, ordinary fallback bots, takeover bots and scripted opponents even though the player-facing UI has no bot label.

Rough presentation still uses intentional animation from the start, `.tres` tuning, useful base/inherited scenes and the permitted existing art. Full creator-authored opening/matchmaking/result choreography and final UI composition can follow their working foundations. Polishing, SFX, music and subsequent work belong to another agent after the revised integration handoff. Keep final authoring/targeted fixes in Final Review until their actual work and creator confirmation; M12.5 does not perform or complete them.

## Universal Executor Requirements

- Follow the bootstrap's GDScript/TypeScript boundaries, readable code, Resource tuning, existing-art restriction, animation, compatibility, export filtering and assertion rules. Read the assigned PRD/spec headings, not just a checklist title.
- Discover Godot MCP tools and confirm the connected project before relying on them. Use supported editor operations, scene inspection, game execution and runtime verification within the assignment. Record unavailable tools/connections and fallback evidence. A successful tool response is not proof of intended player behavior.
- Keep the project runnable after the assigned work. Do not execute a later milestone to conceal a failed dependency; use the adapter contract or report the missing input. Ask about consequential product/architecture changes rather than guessing. Creator-controlled numeric tuning/content is an explicit dependency, not permission for invented production defaults.
- Use mechanical checks proportional to actual risk: runtime observation, exported browser paths, rule cases, real service/API exercises and retry/race checks. Do not add a test framework or CI solely for ceremony. Passing in the editor does not establish release-browser behavior.
- Record exact engine/plugin/runtime/browser/service versions used where relevant. Export early enough to detect single-threaded SDK incompatibility in M01; repeat affected checks as network/API paths arrive. Do not claim all devices tested if unavailable.
- Preserve unrelated user changes. Before each implementation commit, review explicit intended files and staged diffs; exclude learner profile, credentials, `.env*`, editor metadata and unrelated work. A tracked ignored file still needs attention. Never blanket-stage the repository or silently rewrite history. Commit the verified assigned slice with its checklist message; do not commit failed/unchecked work as completed.
- Update only the assigned checklist slice after its mechanical checks, required hands-on checkpoint and implementation commit are complete. If required feedback/input is pending, leave it unchecked and record that fact in the report. Finish the report, summarize the outcome, and stop; do not continue the global build loop.

## Handoff and Completion Protocol

The human opens the milestone chat and assigns `MNN`. A ready-to-paste assignment is:

> Execute only MNN from docs/Milestones.md and checklist slice NN. Read docs/AI_Bootstrap.md and the referenced PRD/spec sections first. Preserve the approved product, adapter boundaries and creator-owned authoring. Use Godot MCP for supported editor/runtime work and perform the assigned mechanical verification. Inspect intended staged changes before committing. Write docs/reports/MNN_Report.md, update only that slice when its completion conditions are met, and stop. Do not execute another milestone or create/message chats. Surface consequential changes and missing creator inputs explicitly.

Replace MNN/NN with the chosen ID/number; do not treat this example as an assignment. This HUB will not send it to another chat automatically.

The executor creates its report only after actual work, using this outline. **M13 exception:** the creator requested `docs/reports/AGY_Polishing_report.md`; its prepared, explicitly unfilled template is not evidence of execution. Fill that file after actual work rather than creating a competing M13 report:

```text
# MNN — [title]
Status: complete / partial / awaiting input
Scope and approved references:
Changed files and why:
Architecture/interface changes and deviations:
Development fixtures versus real services/players:
Mechanical verification: action, environment, observed result, evidence
Learner check / checkpoint: actual feedback or explicitly pending
Godot MCP operations and limitations:
Web/export checks and limitations:
Commit(s) and checklist slice update:
Unresolved issues and creator inputs:
Handoff notes for the next assigned milestone:
```

A report is an executor claim supported by evidence, not an automatic HUB audit. The HUB audits only when the creator explicitly asks and then uses relevant MCP/runtime inspection. Do not mark a checkpoint or audit performed merely because the report exists. Significant changes to product/stack/architecture need creator agreement; routine internal corrections that preserve the plan can be documented without another approval ceremony.

## Creator Inputs and Current Observations

- **Clear Data:** clarified by the creator as a local browser-cache/data reset for testing. The owning behavior is `prd.md > Main Menu and Player Information`; backend account data stays unchanged.
- Gameplay/resource tuning and creator-reserved UI, animations, icons, copy and quest content are tracked in the milestone where used. The PRD/spec remain their owning behavior definitions.
- Read-only inspection on 2026-10-22 found `addons/GD-Sync/plugin.cfg` declaring **1.0.2**. The local plugin list currently enables only the MCP toolkit, and no main scene is configured. SDK presence is not activation, provenance, compatibility, authentication or a verified connection. Preserve the existing SDK files and verify them in M01 rather than replacing them blindly.
- Godot MCP application settings respond with `RockPaperScissor` and configuration matching this workspace. No game/runtime/service checks have been performed by this planning pass.
- Git is available; the repository root is the parent folder. The learner profile is ignored and untracked; no staged changes were found. Existing SDK/backend files and editor metadata include unrelated user work; no files were staged or committed by this HUB.

## Milestone Briefs

### M01 — Rough main menu and real GD-Sync connection

Checklist slice: **1**. Report: `docs/reports/M01_Report.md`.

**Dependencies:** None; approved scope/PRD/spec and the displayed workflow plan are the starting contract.

**PRD references:** `prd.md > Opening and Anonymous Entry`; `prd.md > Main Menu and Player Information`; `prd.md > Screens and Layout`; `prd.md > Look and Feel`.

**Spec references:** `spec.md > Godot Presentation`; `spec.md > Shared Scenes and Tuning Resources`; `spec.md > HTTP API Client`; `spec.md > GD-Sync Integration`; `spec.md > Service Selection and Version Policy`; `spec.md > Where It Runs and How Someone Tries It`.

**Scope:** Build the minimum entry/menu, portrait sizing, navigation hooks and thin identity/data-provider contracts with an explicitly development-only preview implementation. Verify the existing GD-Sync package/provenance, enable/configure it, observe connection success/failure, and prove a single-threaded browser connection. Add Clear Data for this game's local browser cache/data only, for testing. Keep full authored opening choreography for creator polish; menu/card interactions still animate from this milestone.

**Completion criteria:**

- Menu shows the required central summary/daily-quest position and Play/side-button layout; unimplemented destinations have honest temporary states.
- SDK installation/configuration and a real service connection are observed; a GD-Sync connection is not reported as authentication to the custom backend.
- Preview identity/profile and API-ready seams work without creating a second GD-Sync player-account system.
- Clear Data clears only this game's local browser cache/data and leaves backend account data unchanged.

**Mechanical verification:** Use MCP diagnostics/editor/runtime inspection and a release browser export. Observe actual GD-Sync connected/failure signals, reload the preview profile, exercise menu/navigation, and verify Clear Data resets only local game cache/data without a backend mutation request. Record exact plugin/engine/browser versions; do not claim online account persistence.

**Creator check:** Open the browser build, enter the menu, try the buttons and basic motion, and verify that the connection indicator reflects a real GD-Sync connection.

**Inputs and boundaries:** Creator supplies/agrees naming constraints and reserved opening direction when needed. SDK account/key setup belongs to this milestone; do not put credentials in reports. Inherit every universal executor requirement above; stop after this assignment.


### M02 — Play and simulated matchmaking with live-shaped behavior

Checklist slice: **2**. Report: `docs/reports/M02_Report.md`.

**Dependencies:** M01.

**PRD references:** `prd.md > Ranked Matchmaking`; `prd.md > The Core Journey`.

**Spec references:** `spec.md > Ranked Matchmaking Coordinator`; `spec.md > GD-Sync Integration`; `spec.md > Live Match Messages`.

**Scope:** Add a thin MatchSession contract and a scripted development adapter with the eventual begin/cancel/found/failure events and match identity. Use the creator-reserved matchmaking animation hook, animated dots, configured timing, rank-field shapes and a single match reservation. Simulate human-found, timeout-to-bot, cancellation and late callbacks through that same contract. Full live matchmaking is M09.

**Completion criteria:**

- Play, search animation and leave-search return path run from the existing menu.
- Development scenarios exercise found/cancel/timeout/error ordering; a late event cannot start a cancelled or duplicate match.
- The normal configured fallback window stays 30–45 seconds; accelerated fixture checks are labelled and never replace that player-visible verification.
- Reports identify this as simulated matchmaking, not verified human multiplayer.

**Mechanical verification:** Run menu-to-search and all scripted outcomes; cancel just before and after a found event and prove only one arena context exists. Inspect configured timing/resources and test the normal wait. Use MCP and an affected-path browser smoke check.

**Creator check:** Tap Play, leave the search, repeat it, and try the scripted found/timeout paths; report whether the sequence feels close to the intended live flow.

**Inputs and boundaries:** Creator provides/agrees the matchmaking card animation and rating-gap configuration when authored; use labelled fixtures to test ordering rather than inventing production values. Inherit every universal executor requirement above; stop after this assignment.


### M03 — Gameplay I — arena intro and initial choice

Checklist slice: **3**. Report: `docs/reports/M03_Report.md`.

**Dependencies:** M02.

**PRD references:** `prd.md > Arena Intro and Conditions`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Phase 1 — Option`; `prd.md > Opponent Statistics and Saved Records`.

**Spec references:** `spec.md > Godot Match Coordinator`; `spec.md > Shared Scenes and Tuning Resources`; `spec.md > Data Model`; `spec.md > Live Match Messages`.

**Scope:** Create the shared table/card scene family, .tres rule/motion inputs, arena-intro announcement, one-time shuffled RPS order per side and structured initial-choice history. Add the full 15-second Option phase, dimmed selection, chosen-card advance, decided/revision tells, tendency data presentation and leftmost timeout default. Feed the opponent from a controlled development adapter; expose only legal phase information in the normal UI.

**Completion criteria:**

- All three initial choices and revisions work during the full timer; deciding does not end it early.
- Starting order remains stable for later phases and table position does not reveal the hidden card.
- No-history data shows N/A; sample tendencies are explicitly development fixtures.
- Each arena intro can be exercised with controlled fixtures; production probability weights remain creator-authored .tres inputs.

**Mechanical verification:** Exercise all initial choices, repeat/revise selections and allow inactivity to expire. Inspect the stable order/history, full timer, visible tells and phase-end animation. Use MCP and a browser release smoke check.

**Creator check:** Enter the arena, choose and reconsider a card, then let another run time out; assess table readability and motion.

**Inputs and boundaries:** Arena probability weights and final visual assets are creator-authoring inputs; deterministic fixture selection is only test evidence, not a silent default distribution. Inherit every universal executor requirement above; stop after this assignment.


### M04 — Gameplay II — identity claim and change claim

Checklist slice: **4**. Report: `docs/reports/M04_Report.md`.

**Dependencies:** M03.

**PRD references:** `prd.md > Phase 2 — Claim`; `prd.md > Phase 3 — Change Claim`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Arena Chat`.

**Spec references:** `spec.md > Godot Match Coordinator`; `spec.md > Godot Presentation`; `spec.md > Live Match Messages`; `spec.md > Data Model`.

**Scope:** Implement the identity claim and Keep/Switch intention phases on the shared controller/history. Replace unused cards with bubbles, show modifier/tendency reminders, preserve each full 15-second window and exact defaults, and animate changes. Add the right-center frontmost chat overlay with a development-only message adapter; real peer transport arrives in M09 and bots never reply.

**Completion criteria:**

- Claiming a different identity never mutates the actual initial card.
- Keep/index 0 and Switch/index 1 update intention bubbles without changing the card.
- Timeout defaults are honest identity claim and Keep; first-decision/revision announcements use the shared event contract.
- Chat opens above selection/dimming; the presentation gate can close/disable it for the later cinematic using creator-agreed behavior.

**Mechanical verification:** Run truthful/false identity claims, both switch intentions, revisions and no-input defaults with all 15-second windows. Inspect separate history fields and bubble values. Verify chat layering and that the development/bot path generates no unsolicited reply.

**Creator check:** Try lying about the initial card, then change your switch claim; open chat over each dimmed selection screen.

**Inputs and boundaries:** Final narrative wording and exact chat-close transition at cinematic start need creator authoring before the affected presentation is finished. Inherit every universal executor requirement above; stop after this assignment.


### M05 — Gameplay III — final choice, round resolution and local bot behavior

Checklist slice: **5**. Report: `docs/reports/M05_Report.md`.

**Dependencies:** M04.

**PRD references:** `prd.md > Phase 4 — Change`; `prd.md > Points and Match Classification`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Disconnect and Bot Takeover`.

**Spec references:** `spec.md > Godot Match Coordinator`; `spec.md > Bot Controller and Personality Resources`; `spec.md > Result Commitment Before the Cinematic`; `spec.md > Data Model`; `spec.md > Lifetime Statistics and Derived Percentages`.

**Scope:** Add final-card selection plus Switch confirmation, the stable card order, full timer and leftmost default. Emit particles whether switched or kept. Calculate development results from the agreed rules and structured history, not bubble text. Implement .tres-driven local bot policy behind the opponent adapter using only its own/public information; scripted fixtures can exercise unprovided production tuning. Add a ResultSink contract for acknowledgement and failure; the local sink must identify its receipt as simulated.

**Completion criteria:**

- Actual switching is independent of earlier claims; the accepted default-induced false-Keep case works.
- Every RPS outcome and arena bonus/classification follows the PRD; no negative points or double lie counts.
- Local bot behavior and timing are Resource-driven; hidden human choices do not enter its policy.
- Completed RoundLog, eligible-result flags and a development receipt are available for M06; no server write is claimed.

**Mechanical verification:** Check RPS win/loss/draw cases, honest/mixed/two-false claims, fixed arena totals, unchanged-final-card switching statistics, and the active non-leftmost choice followed by default Keep/leftmost case. Inspect Resource tuning and complete history; verify a normal full round in the exported browser.

**Creator check:** Play honest and deceptive rounds, deliberately contradict Keep/Switch claims, and try an idle round; assess whether the choices create doubt.

**Inputs and boundaries:** Production bot personality/selection values require creator agreement; test fixtures are not final bot balance. Final authored polish is separate from these already-animated interactions. Inherit every universal executor requirement above; stop after this assignment.


### M06 — Cinematic reveal, result and return to menu

Checklist slice: **6**. Report: `docs/reports/M06_Report.md`.

**Dependencies:** M05.

**PRD references:** `prd.md > Phase 5 — Narration, Reveal, and Result`; `prd.md > Arena Chat`; `prd.md > Main Menu and Player Information`.

**Spec references:** `spec.md > Result Commitment Before the Cinematic`; `spec.md > Godot Presentation`; `spec.md > HTTP API Client`; `spec.md > Important Failure Modes`.

**Scope:** Use the ResultSink contract to gate reveal on an acknowledged result, including animated pending/error/retry states. Add card retreat, curtains/projector treatment, phase-derived narration, result display and Tap To Continue. Coordinate the creator-reserved outcome animation and dim-versus-black treatment. Update the preview menu through the same data-provider contract used later. The local receipt remains explicitly simulated until M12.

**Completion criteria:**

- Narration follows recorded initial cards, both claims and actual final choices rather than a fixed sample story.
- No cinematic begins before the current sink acknowledges; retrying the same round never grants duplicate preview credit.
- A departure after receipt cannot change that result; no reconnect/resume screen is added.
- Chat cannot open in the cinematic; existing-overlay handling follows creator direction; final tap returns to the menu.

**Mechanical verification:** Run the full menu/search/round/reveal/menu path with different histories. Inject pending/error/duplicate local receipts, check gate ordering, and verify that narration and result agree. Run browser release checks for animation-completion stalls and assertion side effects.

**Creator check:** Play the complete local loop and judge suspense, clarity, pacing and the win/loss/draw payoff before later screens are built.

**Inputs and boundaries:** Creator supplies/agrees cinematic wording/treatment, final outcome sequence and any skip behavior. Missing final authoring is reported and not silently marked polished. Inherit every universal executor requirement above; stop after this assignment.


### M07 — Submenus I — statistics, records and leaderboard

Checklist slice: **7**. Report: `docs/reports/M07_Report.md`.

**Dependencies:** M06.

**PRD references:** `prd.md > Detailed Statistics and Records`; `prd.md > Opponent Statistics and Saved Records`; `prd.md > Leaderboard`; `prd.md > Main Menu and Player Information`.

**Spec references:** `spec.md > Godot Presentation`; `spec.md > Lifetime Statistics and Derived Percentages`; `spec.md > Backend API`; `spec.md > Data Model`.

**Scope:** Implement shared/inherited modal shells and the three read-oriented views with loading/empty/failure states, navigation, and contract-shaped pagination. Use actual preview-round data where available and label any supplied scenario data in development evidence. Keep the creator-reserved Stats/Record UI direction. Display initial/final cards separately and dim only a losing final card.

**Completion criteria:**

- Exactly Overall Points, Win Rate, Lie Count and Honest Count categories are available.
- Percentages, allegiance icon states and win streak use the approved definitions; N/A is used for absent denominators.
- Records show opponent identity plus both initial/final cards and correct draw/losing-card treatment.
- Data access is through the replaceable provider; no hidden assumption that MongoDB is already connected.

**Mechanical verification:** Use controlled no-history, draw, mixed-claim, tied-allegiance and multiple-record cases; compare displayed aggregates with the approved formulas. Verify category switching, pagination shapes, modal navigation and browser layout.

**Creator check:** Open every data view after several preview rounds and check whether it is informative without feeling text-heavy.

**Inputs and boundaries:** Creator authors/agrees Detailed Stats/Record layout and supplies the hybrid/human-head icons; use only the permitted existing art for approved temporary assets. Inherit every universal executor requirement above; stop after this assignment.


### M08 — Submenus II — daily and weekly quests

Checklist slice: **8**. Report: `docs/reports/M08_Report.md`.

**Dependencies:** M07.

**PRD references:** `prd.md > Daily and Weekly Quests`; `prd.md > Main Menu and Player Information`.

**Spec references:** `spec.md > Daily and Weekly Quest Coordinator`; `spec.md > Data Model`; `spec.md > Backend API`.

**Scope:** Add .tres quest definitions and a provider-backed preview quest view using a controllable development clock. Give every assignment a fresh counter and identity, count only qualifying future play, and process active daily/weekly objectives. Implement reset/expiry and once-only menu-entry reward behavior without converting preview data into production history. Use injected time locally; actual backend time becomes authoritative in M11/M12.

**Completion criteria:**

- New/repeated daily quests start at zero and never replay old match records.
- Daily reset is 05:00 GMT+7; weekly reset is Monday at the same time; old daily history is not shown in the new period.
- Unfinished progress and completed unpaid rewards expire; already-paid points remain.
- Rewards are automatic on menu entry and once per eligible completion; no manual claim button or shop is introduced.

**Mechanical verification:** Exercise the Scissors/Win-3/Scissors sequence, relevant draw/loss objectives, repeated menu entry, 04:59/05:00/05:01 and Monday boundaries using controlled time. Confirm expired unpaid rewards do not pay, history is period-filtered, and preview points stay nonnegative.

**Creator check:** Complete a quest, return to the menu, try the next one, and inspect current-day/weekly history and a forced reset.

**Inputs and boundaries:** Creator supplies/agrees quest catalogue selection/repetition policy, targets and reward values; the earlier +2–5 suggestion is not a production default. Inherit every universal executor requirement above; stop after this assignment.


### M09 — Live GD-Sync matchmaking and multiplayer

Checklist slice: **9**. Report: `docs/reports/M09_Report.md`.

**Dependencies:** M08; M01 SDK/web connection evidence.

**PRD references:** `prd.md > Ranked Matchmaking`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Disconnect and Bot Takeover`; `prd.md > Arena Chat`; `prd.md > Phase 5 — Narration, Reveal, and Result`.

**Spec references:** `spec.md > GD-Sync Integration`; `spec.md > Ranked Matchmaking Coordinator`; `spec.md > Live Match Messages`; `spec.md > Godot Match Coordinator`; `spec.md > Bot Controller and Personality Resources`; `spec.md > Result Commitment Before the Cinematic`.

**Scope:** Replace the simulated MatchSession with GD-Sync queue/skill matching, actual peer decisions/chat, host deadlines and revision checks. Preserve the completed UI/rules. Implement one-reservation cancellation/fallback, local Resource bot execution and the approved remaining-player state handoff. Preview identity/rating/bot data and result receipts remain explicitly non-backend-backed until M12. Do not introduce GD-Sync account saves as a parallel backend.

**Completion criteria:**

- Human-to-human play is proven separately from ordinary fallback bots and takeover bots.
- Cancellation/found/timeout races cannot duplicate a match; the fallback wait stays 30–45 seconds.
- A pre-commit host or non-host departure excludes that human, retains the displayed identity and lets the remaining human continue against a bot; no reconnect/resume exists.
- Peers gate the cinematic on the development receipt; after receipt, a cinematic departure does not alter the result.

**Mechanical verification:** Use two distinct browser profiles/devices and observe actual queue matching, full phase timing, revisions and chat. Test rating-window behavior with explicit preview ratings; cancel at match arrival; let search time out; disconnect host and non-host before receipt and after receipt. Inspect logs/hidden-field UI boundaries, traffic and release-browser stability. Report local receipts separately from server commitment.

**Creator check:** Play against another real client and try the planned disconnect cases; assess live timing and whether the sequence still matches the earlier development flow.

**Inputs and boundaries:** Confirm actual GD-Sync quota and pinned API compatibility. Bot roster/tuning and rating-gap values must be creator-agreed before their normal live behavior is accepted. Inherit every universal executor requirement above; stop after this assignment.


### M10 — Backend I — anonymous identity and saved-profile APIs

Checklist slice: **10**. Report: `docs/reports/M10_Report.md`.

**Dependencies:** M09 for sequence; approved API/data contracts. Backend chat needs the sibling backend workspace.

**PRD references:** `prd.md > Opening and Anonymous Entry`; `prd.md > Main Menu and Player Information`; `prd.md > Detailed Statistics and Records`; `prd.md > Leaderboard`.

**Spec references:** `spec.md > Anonymous Identity and Credentials`; `spec.md > Vercel API and MongoDB Persistence`; `spec.md > Backend API`; `spec.md > Data Model`; `spec.md > Service Selection and Version Policy`; `spec.md > Shared Scenes and Tuning Resources`.

**Scope:** Create the TypeScript/Node Vercel backend and versioned .tres-derived deployment configuration, configure Atlas and a reused bounded MongoClient, and implement anonymous create/login, display-name/profile validation, public profile/statistics and leaderboard/record reads. Add/verify credential ignore rules within the backend workspace, preserving a secret-free .env.example; the Godot subfolder's .gitignore does not protect its sibling backend. Use an independent API exercise to prove persistence. Do not connect the game client yet or import its preview history.

**Completion criteria:**

- Actual API authentication distinguishes valid, invalid and missing credentials, and a returning credential retrieves the same saved profile.
- New humans start at 0; private profile/record access is bound to the caller; public data excludes credentials.
- Read routes return honest empty/zero/N/A data until actual eligible results exist; bot seed identities use agreed source data.
- A runnable API exercise and a typechecked backend leave evidence, not just collection/schema files.

**Mechanical verification:** Typecheck and run the backend; call live create/login/profile/read routes with two test identities, restart/reinvoke and confirm persistence, reject invalid/private cross-account access, and verify connection reuse/account limits. Keep credentials out of command output/reports. Confirm actual Node/driver/Atlas versions and environment configuration.

**Creator check:** Follow one anonymous login API request into the saved profile and verify that a later request returns the same account; inspect the observed result rather than a code tour alone.

**Inputs and boundaries:** Creator agrees name constraints and bot seed identities as needed. External account setup/access is handled in this assigned backend milestone, not by the HUB. Inherit every universal executor requirement above; stop after this assignment.


### M11 — Backend II — match settlement and authoritative quests

Checklist slice: **11**. Report: `docs/reports/M11_Report.md`.

**Dependencies:** M10.

**PRD references:** `prd.md > Points and Match Classification`; `prd.md > Disconnect and Bot Takeover`; `prd.md > Daily and Weekly Quests`; `prd.md > Opponent Statistics and Saved Records`; `prd.md > Leaderboard`; `prd.md > Phase 5 — Narration, Reveal, and Result`.

**Spec references:** `spec.md > Result Commitment Before the Cinematic`; `spec.md > Daily and Weekly Quest Coordinator`; `spec.md > Lifetime Statistics and Derived Percentages`; `spec.md > Data Model`; `spec.md > Backend API`.

**Scope:** Implement registration/join, finalization/receipt reads, validated versioned rules, atomic once-only profile/record/quest updates, menu-entry reward settlement and authoritative quest periods. Apply normal human/fallback-bot credit and pre-commit departed-human/takeover exclusions. Complete the read routes from actual outcomes. Use a runnable API exercise; the Godot provider swap is M12.

**Completion criteria:**

- Duplicate finalization returns the original receipt; conflicting histories and unauthorized result access are rejected without double credit.
- Stored results/aggregates follow exact RPS, claim, arena and denominator rules; a cinematic-era departure cannot rewrite a committed result.
- Fresh quest instances, future-event eligibility, fixed GMT+7 periods and expiry/payment exclusivity work under backend time.
- Remaining-human-only takeover updates and ordinary fallback-bot updates are separately verified in actual storage.

**Mechanical verification:** Typecheck/run API exercises for normal win/draw/loss, mixed claims, duplicate/concurrent finalization, contradictory replay, host departure eligibility and receipt lookup. Inspect real stored aggregates/records and test 04:59/05:00/05:01, Monday, repeated objectives and menu grants against controlled server time. Verify rollback/idempotency rather than merely receiving HTTP 200.

**Creator check:** Follow one submitted match into a receipt, stored points/statistics and a quest update; retry it and confirm nothing is paid twice.

**Inputs and boundaries:** Creator-approved rules/quest catalogue revision and server test-clock control are needed; test clock injection must not become a public client-controlled reward clock. Inherit every universal executor requirement above; stop after this assignment.


### M12 — Backend deployment preparation

Checklist slice: **12**. Report: `docs/reports/M12_Report.md`. **Complete under the creator's revised scope, 2026-10-24.** This closes deployment preparation, not the original integrated hosted-game acceptance.

**Dependencies:** M11 implementation/configuration and existing M12 integration work. Preserve commits `59a88eb` (M12 partial implementation), `d141aad`, `f66e90c`, `06d4514` and `bd02a70` (deployment/configuration fixes). Earlier pending M09/M10 boxes and their historical evidence are not completed by this revision.

**PRD references:** `prd.md > Opening and Anonymous Entry`; `prd.md > What We're Building`. Product behavior remains unchanged.

**Spec references:** `spec.md > Where It Runs and How Someone Tries It`; `spec.md > Vercel API and MongoDB Persistence`; `spec.md > Backend API`; `spec.md > Shared Scenes and Tuning Resources`.

**Revised scope:** Prepare the backend's deployable API functions, generated Resource configuration and Atlas connection/environment setup. Deployment now uses **two separate Vercel projects/repositories**: backend API functions with Atlas, and a separately creator-deployed Godot frontend. Backend Root Directory is `backend`; Output Directory is `static-api-only`. It must neither require nor upload the Godot export. Existing Godot adapters, immutable history uploads, departure arbitration and localhost evidence remain preserved implementation from the original M12 attempt; they are not rewritten as deployed-client proof.

**Completion and evidence:** Existing commits contain the API/configuration and later upload/build fixes; the creator explicitly confirms Vercel now deploys successfully after those fixes. This confirmation is deployment/build evidence only. The HUB reviewed source/configuration and commits without deploying, invoking endpoints, running tests or independently observing Vercel. No hosted Godot journey or hands-on exploration is marked performed.

**Moved work and exclusions:** All unfinished Godot-to-deployed-functions integration acceptance and its hands-on checkpoint move to M12.5 with the revised editor/native → local web verification boundary below. Hosted frontend deployment/testing belongs to the creator afterward. Unperformed human/takeover checks remain explicitly recorded gaps, not evidence inferred from COM play. Polishing, SFX, music, Final Review, learning wrap-up/app map and shipping remain outside this milestone.

**Report/commit record:** `M12_Report.md` retains the original execution record with a dated scope-change/closure addendum. Existing commits satisfy the revised implementation record; this HUB does not stage or create a new implementation commit. The checklist Revisions records why slice 12 is now complete.

### M12.5 — Connect Godot to deployed functions and verify editor/local web gameplay

Checklist slice: **12.5**. Executor report after actual work: `docs/reports/M12.5_Report.md`. **Planned, not executed by this HUB.** This is an explicitly approved follow-on to the original 12-milestone distribution, not a renumbering of M01–M12.

**Workspaces:** Godot `/Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor`; backend `/Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/backend`.

**Dependencies and read first:** Revised M12 deployment preparation; all inherited UI/game/network contracts. Read the bootstrap, this entire brief, checklist slice 12.5/checkpoint/Revisions, `M12_Report.md` including its scope-change addendum, `M11_Report.md`/`M11_Audit.md`, and relevant `M09_Report.md` participant-binding/departure details. Earlier pending checkboxes remain unchanged; do not rerun suites or manufacture their completion. Carry fast mode forward. Read project-local `5-build` for assigned-slice workflow only and the ignored learner profile for communication; do not copy private reflections. Discover available Godot MCP tools and confirm the exact connected project through a supported project-path operation before supported editor/scene/runtime use; record connection/tool limitations rather than relying on the namespace or probing credential-like internal state.

**PRD references:** `prd.md > The Core Journey`; `Opening and Anonymous Entry`; `Main Menu and Player Information`; `Detailed Statistics and Records`; `Ranked Matchmaking`; `Disconnect and Bot Takeover`; `Points and Match Classification`; `Phase 5 — Narration, Reveal, and Result`; `Opponent Statistics and Saved Records`; `Leaderboard`; `Daily and Weekly Quests`.

**Spec references:** `spec.md > Where It Runs and How Someone Tries It`; `HTTP API Client`; `Anonymous Identity and Credentials`; `Backend API`; `Result Commitment Before the Cinematic`; `Bot Controller and Personality Resources`; `Daily and Weekly Quest Coordinator`; `Lifetime Statistics and Derived Percentages`; `Staged Development Providers`; `Live Match Messages`; `Important Failure Modes`; `Verification Expectations`.

**Reuse before adding:** Inspect the existing twelve backend entrypoints (`api/anonymous.ts`, `profile.ts`, `player.ts`, `leaderboard.ts`, `records.ts`, `menu.ts`, `quests.ts`, `matches/register.ts`, `join.ts`, `history.ts`, `finalize.ts`, `result.ts`) and their current handlers. Inspect `src/http.ts`, `m11-api.ts`, `history-upload.ts`, `match-settlement.ts`, settlement/config/store modules and corresponding Godot `scripts/api/` adapters, `gdsync_match_session.gd`, match wire/coordinator and receipt gate. “Create the function scripts” means fill genuinely missing functionality, never recreate working routes or replace the architecture. Reuse the substantial `59a88eb` implementation and later fixes. Record current source differences from the historical M12 report before relying on its claims.

**Settled inputs — do not reopen:** Preserve the creator-approved provisional arena/quest/Ember Resources and generated configuration, unrestricted GD-Sync queue matching, immutable history chunks/paged reads, and departure arbitration serialized against commitment. Keep the current Atlas database and `m12_` collection separation; preserve earlier test collections/accounts and existing earned M12 data. Do not reseed, reset or import preview/synthetic progress. The creator approved distribution of the current SDK connection pair; keep values out of reports/logs. This approval does not authorize this executor to deploy the frontend. Final presentation remains another agent's work.

**Implementation scope:**

1. **Hosted API address and cross-origin access.** Obtain/confirm the exact already-deployed backend HTTPS base URL from project configuration or the creator; `devils-rps` is a chosen name, not proof of a URL. Configure it explicitly through Inspector-exposed Resource settings for both native/editor and web. Current native loopback and web `window.location.origin` assumptions must no longer select a local API or the separately hosted frontend's `/api`. Preserve one asynchronous HTTPRequest adapter with threading disabled. Add appropriate backend CORS/OPTIONS support for the actual local web origin(s) and eventual separate frontend origin, including Authorization/Content-Type and methods actually used (GET/POST/PATCH), with consistent headers on applicable success/error responses. Record exact origins/policy without guessing a future hostname; bearer credentials remain private and CORS does not replace authentication. Use the existing backend deployment workflow for necessary API fixes only; do not upload a game package or change `backend` / `static-api-only`.
2. **Real identity.** Complete anonymous create/resume, first-name prompt/save, credential persistence and private Authorization headers. Server errors/timeouts preserve the remembered credential; invalid-account handling requires explicit recreation. Clear Data deletes only this game's owned local data, leaving the old backend account/history intact. Native `user://` and browser storage have different persistence environments; verify each as applicable. No credential/hash/URI in public profiles, GD-Sync, histories, logs or reports.
3. **Real COM registration and personality.** Use an actual backend bot profile and registration response/permanent identity with the approved Resource personality mapping. Register/capture active quests before play; keep service peer IDs, permanent participant IDs, server match UUID, authored rule revision and deployment artifact revision distinct and consistent. No preview bot IDs or manufactured leaderboard roster. Keep inherited human registration/join/binding intact; COM success cannot prove the human join route.
4. **Canonical durable results.** Finish complete accepted-history encoding/upload via existing immutable chunk contracts; preserve order, revisions, exact phase times/defaults, upload identity/digest, participant binding and authorized paged reads. No truncation or new gameplay revision cap. Finalization/status queries reuse the same match/upload identity on uncertain responses; use actual durable receipts and server-calculated results/rewards before the cinematic. Preserve independent human receipt reads and approved precommit-departure arbitration/postcommit immutability; no returning-player reconnection. Do not replace any production path with simulated receipts or local persisted credit.
5. **All saved views.** Wire actual menu entry/payment snapshots, central/opponent stats, detailed stats, owner records, all four leaderboard categories and daily/weekly/history quest displays. Preserve server time, fresh captured quest instances, once-only menu request IDs, null/N/A and cursor translations. No browser clock injection or UI-awarded saved rewards. Remove production preview/simulated fallback paths while retaining isolated development tools outside the export.

**Required verification order and proportional checks:**

**A — Editor/native first, against deployed functions.** Confirm the real backend URL and deployed API revision/configuration (sanitized). Run from the Godot editor/native client. Exercise the complete normal versus-COM journey: anonymous entry/name/menu → actual COM registration and backend bot/personality → full timed decisions/claims/final choice → canonical upload/finalize → durable receipt → cinematic → menu. Observe real saved profile/counters/records, server menu quest progression/reward where eligible, all leaderboard categories, stats/opponent info and quest/history views. Use a small purposeful number of real rounds for applicable progress/payment, not a scoring/category campaign. Observe ordinary resume/restart and owned-data clearing/new identity while preserving the old account. Run only focused affected diagnostics/build/contract checks needed for fixes. Do not proceed to web acceptance while this journey is failing.

**B — One export, served locally, same deployed functions.** After A passes, export the filtered single-threaded Web release **once** to an ignored local frontend-test destination, independent of the backend deployment. Inspect required/path-loaded resources and assertion side effects; retain existing permitted art, inherited scenes, animations and `.tres` tuning. Serve it over a local HTTP origin and exercise the same applicable backend-powered COM journey and views against the **same deployed functions**, with actual browser CORS/preflight, storage/reload and saved progress evidence. A new browser account is expected unless it already owns a credential; do not assume the native account transfers. Record browser/runtime errors and exact package/environment. If the exported candidate fails, record the actual failure and incomplete acceptance; do not claim a pass or start a repeated-export campaign.

Record endpoint/method coverage from actual traffic or sanitized server observations, not code existence. Explicitly list paths not exercised by COM, including human join/binding, actual human matchmaking/chat delivery, precommit host/non-host takeover, departure POST/arbitration and participant-only history reads when unused. Preserve historical localhost evidence separately. Inspect inherited contracts where affected, but **do not expand this assignment into human/takeover, edge-case or failure-injection campaigns**. Those gaps remain unverified follow-up evidence, not M12.5 completion gates or silently completed acceptance boxes. Reuse M11 reset-boundary evidence; do not repeat earlier suites. No exhaustive regression/fuzz/stress/load/concurrency/race/outage/uncertain-network campaign, hosted-frontend testing or device matrix.

**Required hands-on checkpoint:** Give the creator exact editor launch/local web URL instructions and expected saved-data observations. Obtain actual feedback using this editor/local journey and resolve in-scope integration failures before marking the checkpoint or M12.5 complete. Record observations/feedback verbatim or faithfully summarized; executor-only checks do not count. Capture polish requests for the later agent without starting polish, SFX or music. This checkpoint replaces the unperformed M12 hosted-game integration checkpoint; it does not mark the original hosted exploration or Final Review performed.

**Completion criteria:** A then B pass with real deployed functions, real bot and persisted data; all applicable features above have evidence; missing human-only/other endpoint coverage is explicitly listed; no production fixture/simulated-receipt fallback; hands-on feedback is resolved. Write `docs/reports/M12.5_Report.md` with changed files/commits, actual URL/origins/config revision (no secrets), reused/new handler work, chronological A/B evidence, endpoint coverage, durable receipt/saved progress, export/hash/browser storage checks, MCP limitations, actual creator feedback and remaining gaps. Keep inherited report evidence distinct from newly observed results. Follow explicit intended-file/privacy review and assigned-slice commit workflow (`feat(integration): verify deployed functions in editor and local web`); update **only slice 12.5 and its checkpoint** once conditions are met. Report partial if essential input/access/evidence is missing.

**Final handoff and stop:** Supply local-test evidence and say **“Ready for your frontend deployment/testing.”** The creator deploys/tests the Godot frontend in its separate Vercel project/repository. Hosted frontend verification is not an M12.5 completion gate. Then stop: no frontend deployment, new chats/messages/delegation, polish, SFX/music, Final Review completion, learning wrap-up/app map, 6-ship or submission material. Retain every bootstrap Resource/scene/animation/existing-art/readability/compatibility/export/assertion requirement.

### M13-pre — Backend/network stability and gameplay responsiveness

Checklist slice: **13-pre**. Report: `docs/reports/M13-pre_Report.md`. **Closed by explicit creator instruction, 2026-10-24; no new HUB implementation or audit.** The report closure addendum preserves the original execution record and unresolved vendor/post-refactor online limitations; closure does not claim every issue resolved. The complete self-contained assignment is [M13-pre_Brief.md](M13-pre_Brief.md). It owns the narrow stability/latency investigation, inherited gameplay/data safeguards and proportional checks; read it instead of the full milestone/planning bundle. No `.agents/skills/`, Devpost SKILL.md, learner-profile or curriculum/wrap-up loading. The creator explicitly requested this exception for both M13-pre and M13. Preserve M12.5's uncommitted changes and carry the creator's acceptance forward without rewriting historical evidence. Execute only when assigned by the creator, then stop before M13.

### M13 — Polishing

Checklist slice: **13**. Report: `docs/reports/AGY_Polishing_report.md` (creator-requested filename). **Closed by explicit creator acceptance on 2026-10-26.** The report closure preserves the executed polishing/native evidence and failed package-content check/unperformed browser journey. No new HUB implementation, independent gameplay audit or completion commit; release follow-up, Final Review and wrap-up remain open. The following takeover directions are historical constraints for any separately assigned continuation. Read [AGY_Polishing_Handoff.md](AGY_Polishing_Handoff.md) FIRST: its initial file allowlist and creator approval boundary override broader permissions below. Start in `scenes/development/presentation.tscn`, then shared visual changes in `scenes/ui/game_ui.tscn`. Direct edits/resaves to `scenes/main.tscn` require explicit creator confirmation AND an explicit command for the specific change; inherited UI propagation is allowed. Other initial source/assets/settings changes require scoped creator authorization. No agent/chat is dispatched here.

**Dependencies:** M12.5 integration evidence/creator acceptance, M13-pre stability findings and any repaired-contract handoff, plus the creator's presentation priorities and available assets. Read the latest actual M12.5 report when present; do not infer completion from this plan or a report template. Carry forward any creator frontend-testing observations supplied afterward, without inventing hosted verification or requiring the polishing agent to deploy the frontend. Unresolved integration defects must be identified separately rather than disguised as presentation changes.

**Read first:** the lean `docs/AGY_Polishing_Handoff.md` and polishing report, then only relevant scene/source context. Do not load the entire historical planning bundle. If an actual requirement ambiguity needs a targeted reference, use the relevant bootstrap/PRD/spec subsection. Historical broader references are PRD **Look and Feel**, **Screens and Layout**, **Opening and Anonymous Entry**, **Main Menu and Player Information**, **Detailed Statistics and Records**, **Ranked Matchmaking**, **Decision Announcements and Phase Progression**, **Phase 5 — Narration, Reveal, and Result**, **Arena Chat**, **Creator Authoring and Remaining Presentation Decisions**; spec **Godot Presentation**, **Shared Scenes and Tuning Resources**, **Result Commitment Before the Cinematic**, **Where It Runs and How Someone Tries It**; relevant prior implementation reports and actual creator feedback. Creator override: do not load any Devpost skill/SKILL.md, learner profile or learning/shipping curriculum for this game-polishing assignment. Read only relevant game/project references; do not run a Devpost workflow. Leave Final Review/wrap-up/shipping separate.

**Scope:** Refine the existing presentation according to creator direction: portrait readability, spacing/typography, menu and data-view composition, card/claim feedback, transitions, cinematic pacing, result clarity and final copy. Integrate creator-supplied/explicitly approved icons/art, SFX and music where assigned and available. Exact style, new assets/audio selection and consequential changes require creator direction; the milestone title is not blanket approval for a redesign or new asset creation. Do not generate artwork: preserve the existing-art restriction. Respect the creator-reserved title/menu, matchmaking and outcome choreography, Stats/Record design and allegiance icons; use their delivered assets/configuration or obtain specific agreement before replacing their reserved work. Preserve approved temporary motion/copy until replacements are actually accepted.

**Implementation constraints:** Reuse current scenes, useful base/inherited families and animation hooks. Inspector-exposed custom Resource `.tres` fields own adjustable timing/easing/presentation/audio tuning. Keep code readable, Godot 4 compatible and single-threaded-web compatible. Preserve full 15-second decision windows, chat layering/timer behavior, history/revision/participant/departure contracts, durable receipt-before-cinematic ordering, backend-calculated rewards, identity storage, API URL/CORS and current Atlas `m12_` data separation. No gameplay/balance/quest/auth/backend redesign, new features, database reset or production fixtures/simulated receipts. Record functional blockers and obtain an explicit assignment for work outside polish rather than silently broadening scope.

**Inputs:** Record the creator's concrete priorities, delivered asset/audio paths and usage permissions, retained temporary pieces, reserved-authoring decisions and any missing material. Do not reopen settled gameplay/configuration interviews. Missing required presentation input remains pending; do not invent final art, music, copy or approval. If no audio is supplied/approved, identify it as outstanding rather than claim audio polish complete.

**Focused verification:** The initial takeover is restricted to affected offline F6 sandbox checks and parsing under AGY_Polishing_Handoff.md; live main execution, web export/testing, backend calls and other file writes require a further creator assignment. The broader verification guidance below applies only when that expanded scope is explicitly assigned. Discover available Godot MCP tools and confirm the exact connected Godot project before supported scene/editor/runtime operations; report limitations/fallbacks honestly. Check changed scripts/scenes and observe only affected screens/animations/audio in normal editor use and a proportionate affected-path single-threaded release-browser smoke. Confirm portrait readability, input visibility, animation completion, chat/cinematic layering and any added web-audio activation/volume behavior. Inspect required/path-loaded export resources, exclude source/private/development content and check assertions have no required side effects. Use real integrated providers for any gameplay observation; no preview fallback or synthetic saved progress. No full regression, edge-case campaign, stress/race/failure injection, repeated earlier suites, hosted-frontend deployment/testing or device matrix. Report observed results separately from inherited reports, creator observations and unverified behavior.

**Creator check and completion:** Show the actual affected presentation, collect feedback on readability/feel/pacing/audio and resolve the agreed in-scope items. Record explicit creator acceptance of the delivered polishing scope and any exclusions. Complete only slice 13 after that scope's required changes, focused verification and assigned implementation commit (`feat(polish): refine approved game presentation`) are recorded. Use explicit intended-file/privacy review, preserve unrelated work and never blanket-stage. Fill the existing `AGY_Polishing_report.md` with changed files, before/after descriptions, asset/audio provenance, actual checks, limitations, feedback, commits and remaining work; it must cease being an unfilled template before it can support completion. If required work/input is missing, report partial and keep the slice open.

**Stop:** M13 acceptance is not Final Review or ready-to-ship approval. Leave earlier pending checkboxes, human/takeover/hosted evidence, Final Review, learning wrap-up/app map and submission material open until their actual work and creator confirmations. Do not deploy the frontend, invoke 6-ship, create/message other chats, delegate or continue beyond the human-assigned polishing scope.

## Review Status

The creator explicitly approved the displayed Milestones, checklist, AI_Bootstrap and Game_Vision together on 2026-10-22 (“Sure”), including this 12-milestone distribution. The supplied group order is preserved, with three gameplay milestones and two submenu milestones. That original approval was planning only; the checklist records actual subsequent completion. The creator explicitly authorized the M12/M12.5 scope and deployment split on 2026-10-24; revised M12 closes on existing implementation and creator-confirmed deployment/build, without claiming an integrated hosted journey. M12.5 and its local hands-on checkpoint remain pending. Clear Data is settled as a local-only testing reset. Implementation remains in separately assigned milestone chats; this HUB stops at planning/review.
