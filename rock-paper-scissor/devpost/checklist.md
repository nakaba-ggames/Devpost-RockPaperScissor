---
doc: checklist
status: approved
updated: 2026-10-22
---

# Build Checklist

Plan approved on 2026-10-22: the creator explicitly approved the displayed checklist, Milestones, AI_Bootstrap and Game_Vision together (“Sure”), including the 12-milestone distribution. Approval does not complete any build step or hands-on check.

Build mode: fast — explicitly selected by the creator in the M01 implementation chat on 2026-10-22. Required hands-on feedback remains part of M01; adjustments follow actual review.

Scope gate: execute only the milestone explicitly assigned by the human. Each slice maps 1:1 to the matching MNN in [Milestones.md](../docs/Milestones.md), which owns detailed scope/criteria and reports. Completion is recorded only in the applicable boxes below. Complete only the assigned slice and stop; a later unchecked slice is not authorization to continue. Keep the learner profile and credentials out of commits.

## Slices

- [x] **1. Rough main menu and real GD-Sync connection**
  Becomes usable: The portrait app reaches a functional rough menu, accepts preview identity/profile data, exposes the requested navigation and Clear Data control, and makes an actual GD-Sync service connection.
  Why now: Follows the requested entry-first sequence and proves the web/network dependency while building the first usable screen, rather than adding a separate setup milestone.
  PRD ref: `prd.md > Opening and Anonymous Entry`; `prd.md > Main Menu and Player Information`; `prd.md > Screens and Layout`; `prd.md > Look and Feel`.
  Spec ref: `spec.md > Godot Presentation`; `spec.md > Shared Scenes and Tuning Resources`; `spec.md > HTTP API Client`; `spec.md > GD-Sync Integration`; `spec.md > Service Selection and Version Policy`; `spec.md > Where It Runs and How Someone Tries It`.
  Build: Execute M01 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Use MCP diagnostics/editor/runtime inspection and a release browser export. Observe actual GD-Sync connected/failure signals, reload the preview profile, exercise menu/navigation, and verify Clear Data resets only local game cache/data without a backend mutation request. Record exact plugin/engine/browser versions; do not claim online account persistence.
  Learner check: Open the browser build, enter the menu, try the buttons and basic motion, and verify that the connection indicator reflects a real GD-Sync connection.
  Commit: `feat(menu): add preview menu and GD-Sync connection`

- [x] **2. Play and simulated matchmaking with live-shaped behavior**
  Becomes usable: Play opens an animated search, cancellation works, and a controlled development search outcome enters a match-ready arena context.
  Why now: Adds the next actual-flow step while the full live match transport remains in its requested later milestone.
  PRD ref: `prd.md > Ranked Matchmaking`; `prd.md > The Core Journey`.
  Spec ref: `spec.md > Ranked Matchmaking Coordinator`; `spec.md > GD-Sync Integration`; `spec.md > Live Match Messages`.
  Build: Execute M02 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Creator-authorized M02 reduction: focused changed-scene/script diagnostics; normal menu → search → leave → menu; normal scripted found → one match-ready context; one ordinary unsuccessful search through the real configured randomized 30–45-second wait → development bot context; affected-path single-threaded release-browser smoke covering layout and animation completion; focused export-dependency/assertion review. Failure, cancellation-at-arrival, duplicate/late-callback injection and broader edge checks are deferred, not passed. See Revisions and M02_Report.md.
  Learner check: Tap Play, leave the search, repeat it, and try the scripted found/timeout paths; report whether the sequence feels close to the intended live flow.
  Commit: `feat(matchmaking): add cancellable simulated search flow`

- [x] **3. Gameplay I — arena intro and initial choice**
  Becomes usable: A development match announces its arena condition, presents both table sides and completes the Option phase with a real timed card choice.
  Why now: The deception game begins immediately after entry/search, keeping the unique kernel ahead of peripheral submenus.
  PRD ref: `prd.md > Arena Intro and Conditions`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Phase 1 — Option`; `prd.md > Opponent Statistics and Saved Records`.
  Spec ref: `spec.md > Godot Match Coordinator`; `spec.md > Shared Scenes and Tuning Resources`; `spec.md > Data Model`; `spec.md > Live Match Messages`.
  Build: Execute M03 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Creator-authorized basic M03 only: focused changed-scene/script inspection and diagnostics; controlled intros for all three conditions; one normal Rock → Paper → Scissor revision run through the full 15 seconds; one ordinary idle run confirming the unchanged leftmost default; N/A history and hidden-opponent UI inspection; one affected-path single-threaded release-browser smoke through matchmaking → intro → Option → phase end; focused export-dependency/assertion review. Broader edge, race, failure, malformed-input, deadline-injection and browser/device checks are deferred, not passed. See Revisions and M03_Report.md.
  Learner check: Enter the arena, choose and reconsider a card, then let another run time out; assess table readability and motion.
  Commit: `feat(arena): add intro and timed initial card choice`

- [x] **4. Gameplay II — identity claim and change claim**
  Becomes usable: The selected initial card flows through both claim phases, with independent actual/claimed data, public bubbles, revisions and defaults.
  Why now: Delivers the central deception decisions before actual switching/result work.
  PRD ref: `prd.md > Phase 2 — Claim`; `prd.md > Phase 3 — Change Claim`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Arena Chat`.
  Spec ref: `spec.md > Godot Match Coordinator`; `spec.md > Godot Presentation`; `spec.md > Live Match Messages`; `spec.md > Data Model`.
  Build: Execute M04 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Creator-authorized basic M04 only: focused changed-script diagnostics and scene inspection; one normal truthful/false identity and Keep/Switch revision flow through full 15-second windows; one ordinary idle flow confirming honest identity/Keep defaults; open/close chat over each dimmed claim screen and send local preview messages without a reply; one affected-path single-threaded release-browser smoke for transitions, chat layering and motion completion; focused export-dependency/assertion review. Deferred edge checks remain unverified. See Revisions and M04_Report.md.
  Learner check: Try lying about the initial card, then change your switch claim; open chat over each dimmed selection screen.
  Commit: `feat(claims): add both timed claims and chat overlay`

- [x] **5. Gameplay III — final choice, round resolution and local bot behavior**
  Becomes usable: All decision phases form a complete local round, producing actual initial/claim/final history and a calculated outcome ready for reveal.
  Why now: Closes the playable decision loop and establishes the result contract used by both the cinematic and eventual server.
  PRD ref: `prd.md > Phase 4 — Change`; `prd.md > Points and Match Classification`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Disconnect and Bot Takeover`.
  Spec ref: `spec.md > Godot Match Coordinator`; `spec.md > Bot Controller and Personality Resources`; `spec.md > Result Commitment Before the Cinematic`; `spec.md > Data Model`; `spec.md > Lifetime Statistics and Derived Percentages`.
  Build: Execute M05 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Check RPS win/loss/draw cases, honest/mixed/two-false claims, fixed arena totals, unchanged-final-card switching statistics, and the active non-leftmost choice followed by default Keep/leftmost case. Inspect Resource tuning and complete history; verify a normal full round in the exported browser.
  Learner check: Play honest and deceptive rounds, deliberately contradict Keep/Switch claims, and try an idle round; assess whether the choices create doubt.
  Commit: `feat(round): add final choice and local round resolution`

- [x] **6. Cinematic reveal, result and return to menu**
  Becomes usable: A complete development match waits for its simulated receipt, tells the actual match story, presents the result, and returns to the menu.
  Why now: Completes the user-visible core journey before the peripheral submenus and late service integrations.
  PRD ref: `prd.md > Phase 5 — Narration, Reveal, and Result`; `prd.md > Arena Chat`; `prd.md > Main Menu and Player Information`.
  Spec ref: `spec.md > Result Commitment Before the Cinematic`; `spec.md > Godot Presentation`; `spec.md > HTTP API Client`; `spec.md > Important Failure Modes`.
  Build: Execute M06 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Run the full menu/search/round/reveal/menu path with different histories. Inject pending/error/duplicate local receipts, check gate ordering, and verify that narration and result agree. Run browser release checks for animation-completion stalls and assertion side effects.
  Learner check: Play the complete local loop and judge suspense, clarity, pacing and the win/loss/draw payoff before later screens are built.
  Commit: `feat(reveal): add acknowledged narrative result flow`

- [x] **7. Submenus I — statistics, records and leaderboard**
  Becomes usable: Menu buttons open functional statistics, record and four-category leaderboard views over the preview data-provider contract.
  Why now: Builds the read-oriented submenus together after a complete round can produce their data.
  PRD ref: `prd.md > Detailed Statistics and Records`; `prd.md > Opponent Statistics and Saved Records`; `prd.md > Leaderboard`; `prd.md > Main Menu and Player Information`.
  Spec ref: `spec.md > Godot Presentation`; `spec.md > Lifetime Statistics and Derived Percentages`; `spec.md > Backend API`; `spec.md > Data Model`.
  Build: Execute M07 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Use controlled no-history, draw, mixed-claim, tied-allegiance and multiple-record cases; compare displayed aggregates with the approved formulas. Verify category switching, pagination shapes, modal navigation and browser layout.
  Learner check: Open every data view after several preview rounds and check whether it is informative without feeling text-heavy.
  Commit: `feat(submenus): add stats records and leaderboards`

- [x] **8. Submenus II — daily and weekly quests**
  Becomes usable: The menu quest strip and quest view support fresh progress, sequential dailies, current-day history, weekly objectives and menu-entry rewards in the preview provider.
  Why now: Groups the time/progress-sensitive submenu behavior into one verifiable feature before replacing its persistence.
  PRD ref: `prd.md > Daily and Weekly Quests`; `prd.md > Main Menu and Player Information`.
  Spec ref: `spec.md > Daily and Weekly Quest Coordinator`; `spec.md > Data Model`; `spec.md > Backend API`.
  Build: Execute M08 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Exercise the Scissors/Win-3/Scissors sequence, relevant draw/loss objectives, repeated menu entry, 04:59/05:00/05:01 and Monday boundaries using controlled time. Confirm expired unpaid rewards do not pay, history is period-filtered, and preview points stay nonnegative.
  Learner check: Complete a quest, return to the menu, try the next one, and inspect current-day/weekly history and a forced reset.
  Commit: `feat(quests): add fresh progress resets and reward views`

- [ ] **9. Live GD-Sync matchmaking and multiplayer**
  Becomes usable: Two real human clients complete the game through live matchmaking, messages/chat, phase coordination and bot fallback/takeover; persistence is still the development adapter.
  Why now: Per the requested order, this is the full multiplayer conversion rather than the first SDK installation.
  PRD ref: `prd.md > Ranked Matchmaking`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Disconnect and Bot Takeover`; `prd.md > Arena Chat`; `prd.md > Phase 5 — Narration, Reveal, and Result`.
  Spec ref: `spec.md > GD-Sync Integration`; `spec.md > Ranked Matchmaking Coordinator`; `spec.md > Live Match Messages`; `spec.md > Godot Match Coordinator`; `spec.md > Bot Controller and Personality Resources`; `spec.md > Result Commitment Before the Cinematic`.
  Build: Execute M09 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Use two distinct browser profiles/devices and observe actual queue matching, full phase timing, revisions and chat. Test rating-window behavior with explicit preview ratings; cancel at match arrival; let search time out; disconnect host and non-host before receipt and after receipt. Inspect logs/hidden-field UI boundaries, traffic and release-browser stability. Report local receipts separately from server commitment.
  Learner check: Play against another real client and try the planned disconnect cases; assess live timing and whether the sequence still matches the earlier development flow.
  Commit: `feat(multiplayer): integrate live GD-Sync match sessions`

- [ ] **10. Backend I — anonymous identity and saved-profile APIs**
  Becomes usable: Runnable API requests create/login an anonymous account, set its name and retrieve saved profile/public-data views from the actual Atlas deployment.
  Why now: Keeps backend development in its requested late position while providing independent input/output evidence of the unfamiliar Vercel/MongoDB path.
  PRD ref: `prd.md > Opening and Anonymous Entry`; `prd.md > Main Menu and Player Information`; `prd.md > Detailed Statistics and Records`; `prd.md > Leaderboard`.
  Spec ref: `spec.md > Anonymous Identity and Credentials`; `spec.md > Vercel API and MongoDB Persistence`; `spec.md > Backend API`; `spec.md > Data Model`; `spec.md > Service Selection and Version Policy`; `spec.md > Shared Scenes and Tuning Resources`.
  Build: Execute M10 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Typecheck and run the backend; call live create/login/profile/read routes with two test identities, restart/reinvoke and confirm persistence, reject invalid/private cross-account access, and verify connection reuse/account limits. Keep credentials out of command output/reports. Confirm actual Node/driver/Atlas versions and environment configuration.
  Learner check: Follow one anonymous login API request into the saved profile and verify that a later request returns the same account; inspect the observed result rather than a code tour alone.
  Commit: `feat(backend): add anonymous identity and profile APIs`

- [ ] **11. Backend II — match settlement and authoritative quests**
  Becomes usable: An API exercise registers a match, finalizes a real submitted history once, updates eligible saved statistics, and settles or expires quest rewards using backend time.
  Why now: Finishes server behavior independently before the final client-provider swap, as requested.
  PRD ref: `prd.md > Points and Match Classification`; `prd.md > Disconnect and Bot Takeover`; `prd.md > Daily and Weekly Quests`; `prd.md > Opponent Statistics and Saved Records`; `prd.md > Leaderboard`; `prd.md > Phase 5 — Narration, Reveal, and Result`.
  Spec ref: `spec.md > Result Commitment Before the Cinematic`; `spec.md > Daily and Weekly Quest Coordinator`; `spec.md > Lifetime Statistics and Derived Percentages`; `spec.md > Data Model`; `spec.md > Backend API`.
  Build: Execute M11 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Typecheck/run API exercises for normal win/draw/loss, mixed claims, duplicate/concurrent finalization, contradictory replay, host departure eligibility and receipt lookup. Inspect real stored aggregates/records and test 04:59/05:00/05:01, Monday, repeated objectives and menu grants against controlled server time. Verify rollback/idempotency rather than merely receiving HTTP 200.
  Learner check: Follow one submitted match into a receipt, stored points/statistics and a quest update; retry it and confirm nothing is paid twice.
  Commit: `feat(backend): add match settlement and authoritative quests`

- [ ] **12. Connect Godot to the backend and verify the submission journey**
  Becomes usable: The hosted portrait game uses real anonymous accounts, live human/bot matches, committed server results and saved menu/submenu/quest data throughout the full journey.
  Why now: Per the requested order, this is the final replacement of preview identity/data/result providers with the completed backend.
  PRD ref: `prd.md > The Core Journey`; `prd.md > Opening and Anonymous Entry`; `prd.md > Disconnect and Bot Takeover`; `prd.md > Daily and Weekly Quests`; `prd.md > Phase 5 — Narration, Reveal, and Result`; `prd.md > What We're Building`.
  Spec ref: `spec.md > HTTP API Client`; `spec.md > Backend API`; `spec.md > Result Commitment Before the Cinematic`; `spec.md > Where It Runs and How Someone Tries It`; `spec.md > Important Failure Modes`; `spec.md > Verification Expectations`.
  Build: Execute M12 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Run the complete HTTPS journey in two distinct browser identities, then reload to prove saved state. Separately exercise real human/fallback/takeover cases, result timeout/retry/duplicate requests, account errors, all data views and controlled reset boundaries. Inspect package inclusion, assert usage, browser console/runtime logs and supported mobile browsers. Record every actual limitation; do not replace missing device/network evidence with assumptions.
  Learner check: Explore the deployed full game, try awkward inputs/disconnects and every submenu, then identify anything broken, unclear or unsatisfying for final review.
  Commit: `feat(integration): connect live backend and verify web journey`

## Hands-on Checkpoints

- [x] Early usable behavior explored — after M01: creator tried the menu, controls, initial motion, SDK connection presentation and local-only Clear Data testing reset. Feedback on 2026-10-22: “Yes, it works perfectly”. No adjustment requested; implementation committed as `2b773ac`.
- [x] Integrated local core journey explored — after M06: creator accepts the functional local loop on 2026-10-23 and is satisfied with its tactile feel. No broken behavior or further M06 change requested; lack of art is intentional and no art is to be created here. Final authoring remains separate. Feature commit `23d8316`.
- [ ] Live multiplayer explored — after M09: creator plays with a second real client and checks timing, chat, cancellation and pre-/post-receipt departures; preview persistence is explicitly identified.
- [ ] Final kick-the-tires exploration and feedback completed — after M12 at the deployed HTTPS build with real backend data.

In learn mode, every assigned slice also gets its learner check before completion; in fast mode, these planned hands-on boundaries still require actual feedback. Do not mark a checkpoint performed from an executor-only test or an unreviewed report. Each milestone chat stops at its assignment in either mode.

## Final Review

- [ ] Final review complete — feedback resolved and learner confirms ready to ship

After M12, the creator explores the actual submission journey, all submenus, real peer/bot behavior and saved account data. Record requested fixes as unchecked tasks here, agree consequential changes, assign their implementation to a milestone/fix chat, and verify/retry them before checking readiness. Targeted creator-authoring/presentation fixes belong here or in their owning milestone, not in an automatically invented extra polish milestone. No reviews or fixes have occurred yet.

## Code Tour and App Map

- [ ] Learning activity complete — guided route, focused alternative, prior practice connected, or brief recap
- [ ] Optional edit and transfer reflection addressed — offered/declined/already covered/not applicable as appropriate
- [ ] `devpost/app-map.html` generated from finished code, checked, and shown, including a project-grounded practice to reuse

Activity and evidence: not performed. Suggested focused activity after the final review: follow one real Godot match finalization through HTTP request, server receipt, stored aggregate update and cinematic gate. Earlier genuine API/network investigations can count if their evidence is recorded; no duplicate beginner code tour is required.
Route and stops: to be taken from actual finished code; do not fabricate paths/symbols before implementation.
Edit outcome: not offered or performed yet; optional.
Reflection: not offered yet; personal answers belong only in the ignored learner profile.
Activity mode: not chosen; use an appropriate focused investigation or prior practice for this experienced planning-first creator.

## Revisions

- 2026-10-22, M02: creator explicitly limits verification to the six basic checks recorded in slice 2 above. This overrides M02's broader original verification wording in Milestones.md. No full suite, broad regression, stress tests, browser/device matrix, cancellation-at-arrival races, late-callback injection, deliberate errors or malformed-input checks were run. Safeguards and failure handling are implemented; their deferred edge behavior is unverified.
- 2026-10-22, M02: fast mode continues. Only development fixtures are supplied; production rating-gap/widening values remain unset in search_settings.tres. Final matchmaking choreography remains creator-owned via search_card.tscn's CreatorAnimation hook. The M02 creator try-out is provided in the report; feedback is pending and no hands-on checkpoint is marked performed.
- 2026-10-22, M02 implementation complete: authorized basic checks passed and feature commit `2425b35` succeeded before checking slice 2. Evidence and exact launch/creator try-out are in `docs/reports/M02_Report.md`. Fast mode has no planned M02 hands-on checkpoint; actual creator feedback remains pending. Deferred edge checks and final creator animation/tuning are not marked complete. No M03 work was started.

- 2026-10-22, M01: creator explicitly limits verification to changed-scene diagnostics, one normal editor entry/menu flow, one single-threaded release-browser smoke flow, one ordinary reload, one local-only Clear Data reset, and focused export/assertion checks. Broad regression, failure/disconnect/timeout injection, stress/race/malformed-input checks and device/browser matrix are deferred to a dedicated later session; none may be marked performed.
- 2026-10-22, M01: creator selected fast mode and has no strict naming rules for this preview. Use trimmed, nonempty local display names; production validation remains M10. Final title/menu choreography and allegiance art remain creator-owned.
- 2026-10-22, M01 complete: scoped mechanical evidence is in `docs/reports/M01_Report.md`; creator accepted the full early hands-on check (“Yes, it works perfectly”). Implementation commit `2b773ac` succeeded before checking slice 1 and its early checkpoint. No deferred edge check or later milestone/checkpoint is marked complete.

- 2026-10-22, M03: creator limits verification to the basic checks recorded in slice 3; this supersedes the broader generic verification loop. No full suite, broad regression, stress/race testing, malformed input, deadline-boundary injection, deliberate service failure or browser/device matrix was run. Edge checks remain unverified for the dedicated later session. M01/M02 full checks and the normal 30–45-second search wait were not repeated; the existing scripted-found path reached the arena.
- 2026-10-22, M03: fast mode continues. The creator confirms M02: “I've tried it and it works.” This supersedes M02_Report.md's historical pending-feedback note; no second M02 approval is requested. M03 is not a planned hands-on checkpoint. Its try-out is supplied in M03_Report.md, with feedback pending; no unperformed checkpoint is checked. Controlled condition selection leaves production weights unset, and final assets/tuning remain creator-owned.

- 2026-10-22, M03 complete: the authorized basic checks passed and feature commit `aa91a91` succeeded before checking only slice 3. Evidence, architecture/M04 handoff and exact creator try-out are in `docs/reports/M03_Report.md`. No M04 work or unperformed hands-on checkpoint is marked complete; edge checks and creator feedback remain pending.

- 2026-10-23, M04: the creator authorizes only the basic checks in slice 4. No full suite, broad regression, stress/race, malformed-input, deadline-boundary injection, deliberate failure or browser/device matrix; those checks are deferred and unverified. Scripted-found reaches the arena without repeating M01–M03 checks or the 30–45-second search. Fast mode continues. The creator confirms M03: “I've tried it and it works.” This supersedes M03_Report.md's pending-feedback note. M04 is not a planned hands-on checkpoint; its feedback is pending. Final copy and cinematic chat-close choreography remain creator-owned.

- 2026-10-23, M04 complete: authorized basic checks passed and feature commit `b4e5eff` succeeded before checking only slice 4. `docs/reports/M04_Report.md` records contracts, evidence, exact launch/try-out, current-package browser observations and M05 handoff. M04 feedback remains pending; no checkpoint is marked performed, deferred edge checks stay unverified, and no M05 implementation was started.

- 2026-10-23, M05: fast mode continues and the creator authorizes **basic M05 only**: focused changed-script diagnostics/scene inspection; one normal select-confirm-revise final flow; ordinary idle final default; direct controlled-history checks for the assigned RPS/scoring/classification/switch rules; restricted bot-input/Resource inspection and ordinary bot observation; one full-round single-threaded release-browser smoke; focused export/assertion review. No full suite, broad regression, stress/race, malformed-input, deliberate failure/retry injection, live disconnect/takeover injection or browser/device matrix. Deferred checks remain unverified for the dedicated later session. Scripted-found avoids repeating earlier milestones or the 30–45-second search. M04 is accepted as complete from the supplied handoff; no new HUB audit or detailed creator feedback is claimed. M05 is not a planned hands-on checkpoint; its try-out feedback remains pending. Production bot personality/selection and arena probability weights remain creator-owned and unapproved; the labelled bot Resource is a development fixture only.

- 2026-10-23, M05 complete: authorized basic checks passed and feature commit `f508a99` succeeded before checking only slice 5. `docs/reports/M05_Report.md` records final-choice/history/scoring, restricted Resource-driven bot policy, frozen eligibility and explicitly simulated receipt contracts, scoped evidence, exact try-out and M06 handoff. No M06 work, new HUB audit or unperformed checkpoint is marked complete. Deferred checks, production tuning and creator try-out feedback remain pending.

- 2026-10-23, M06 in progress: creator confirms M05 works (feature `f508a99`, completion `6da3f9f`); no new M05 acceptance or HUB audit requested. Fast mode continues. The creator authorizes **basic M06 only**: focused changed-script diagnostics/scene inspection; one ordinary receipt → narration → outcome → continue/menu flow; four small frozen-history examples covering truth/deception, Keep/Switch, defaults and win/loss/draw; cinematic chat gating/automatic close; ordinary preview-menu refresh; one full scripted-found single-threaded release-browser journey reused for overlapping checks; focused export dependencies/assertions. No full suite, broad regression, pending/failure/duplicate injection, stress/race/disconnect tests or browser/device matrix. Deferred paths remain unverified. Slice 6 and the integrated local checkpoint stay unchecked until actual creator feedback and the implementation commit.

- 2026-10-23, M06 authoring decisions: creator requests gradual cinematic dimming from **0.3** to **1.0** as phases are revealed, reaching full black immediately before the outcome. Existing chat closes automatically and cannot reopen for the rest of that match. Creator agrees factual temporary copy and a temporary fade/scale final-card/result/points sequence with no skip for this checkpoint. This is a functionality milestone; final choreography and future narrative presets remain authoring work. No final presentation/polish approval is implied.

- 2026-10-23, M06 functionality/basic checks: changed-script diagnostics, four frozen-history examples and ordinary release receipt/narration/result/menu passed. A card-back/text overlap found in the first release flow was fixed; a second export/reveal recheck confirmed the correction and automatic existing-chat closure. Delivery failures/retries/duplicates and broader checks remain unverified. Creator checkpoint launch/feedback requested; actual playthrough feedback and feature commit remain pending, so slice 6 and the integrated checkpoint remain unchecked. See `docs/reports/M06_Report.md`.

- 2026-10-23, M06 creator checkpoint accepted: following the complete-local-loop feedback request, the creator is satisfied with the functional version and its tactile feel. No broken behavior or further M06 change requested. Missing art is intentional; **do not create any art here**. Final artwork/choreography and future narrative presets remain authoring work. Feature commit/completion recording follows; no additional tests or implementation were requested.

- 2026-10-23, M06 complete: creator checkpoint accepted and feature commit `23d8316` (`feat(reveal): add acknowledged narrative result flow`) succeeded before checking only slice 6 and the integrated local core-journey checkpoint. Scoped verification, simulated acknowledgement/session-preview limits, creator choices/feedback and deferred checks are recorded in `docs/reports/M06_Report.md`. No art added, M07 work, Final Review or learning wrap-up.

- 2026-10-23, M07 authorized scope: fast mode; execute only slice 7. Creator confirms M06's complete local loop works; preserve feature `23d8316`, completion `64818b8` and existing checkpoint evidence. **Basic M07 only:** focused changed-script diagnostics/scene inspection; normal opening/closing/scrolling; four controlled submissions covering no history, draw, mixed claims, tied winning allegiance and multiple records; four leaderboard categories and ordinary pagination; one newly acknowledged ordinary preview round; one affected-path single-threaded release-browser smoke; export dependency/assertion review. No full suite, broad regression, stress/race, malformed-input or deliberate service-failure tests, cinematic branch suite, 30–45-second fallback wait, or device/browser matrix. Implemented failure states remain deliberately uninjected; deferred checks are unverified. Controlled records and roster fixtures are development evidence, never real account history. No new HUB audit or M06 acceptance requested.

- 2026-10-23, M07 awaiting input: three provider-backed functional draft views, session records/aggregates and bounded pagination implemented; authorized basic evidence is recorded in `docs/reports/M07_Report.md`. Exported inherited margins were corrected through Resource-owned insets, and focused Back rendering required a separate child caption after redraw/focus attempts. Creator Stats/Record composition agreement and final human/hybrid icon paths remain pending; draft design is not final. No planned hands-on checkpoint claimed. Slice 7 remains unchecked and no feature/completion commit is made until essential layout input is resolved. No M08 work or alteration of M06/checkpoint evidence.

- 2026-10-23, M07 creator layout approved: creator says the current rough functional Stats/Record composition is fine for later backend integration and plans their own visual overhaul. Essential layout input is resolved; final human/hybrid icon paths remain tracked. No new hands-on checkpoint or HUB audit is claimed. Proceed with the verified M07 implementation commit, then check only slice 7 and record completion. No code, export or repeated runtime verification is needed for this documentation-only approval response.

- 2026-10-23, M07 complete: essential creator layout approval received and feature commit `40b0cc2` (`feat(submenus): add stats records and leaderboards`) succeeded before checking only slice 7. Basic verification, preview/fixture contracts, session-only history, export fixes, actual feedback, deferred checks and missing final icon paths are recorded in `docs/reports/M07_Report.md`. The creator retains the later visual overhaul; no extra hands-on checkpoint, final polish, HUB audit, M08, Final Review or learning wrap-up is claimed. Completion documentation is recorded separately.

- 2026-10-23, M08 authorized scope: fast mode, slice 8 only. Creator explicitly limits verification to changed-script diagnostics/scene inspection; small deterministic fresh-sequence, relevant loss/draw/active daily+weekly, normal repeated-menu payment checks; controlled 04:59/05:00/05:01 and Monday cutoff/expiry checks; one ordinary acknowledged quest/reward flow; one affected-path single-threaded release-browser smoke; focused export/assertion review. No full suite, broad regression, stress/race/concurrent requests, malformed input, deliberate service failure, live networking, browser/device matrix, all data/cinematic categories or randomized 30–45-second search wait. Deferred checks remain unverified, never passed. M07 acceptance and creator visual ownership are preserved; no new HUB audit or planned hands-on checkpoint.

- 2026-10-23, M08 catalogue agreement: creator answered “Sure” to the explicitly development-only proposal. Daily ordered repetition: Phase 1 Play Scissors 1 / +1 → Win 3 matches / +3 → repeat. Concurrent weekly objectives: Play 5 / +5, Switch initial card 3 / +3, Lie in 3 matches / +3 (one contribution per match). This approves runnable preview configuration in `resources/quests/development_catalogue.tres`, not production balance or the earlier +2–5 suggestion. Production authoring remains creator-owned. See `docs/reports/M08_Report.md` for contracts, actual evidence and completion status.

- 2026-10-23, M08 complete: creator-approved development catalogue implemented; fresh daily progression, concurrent weekly objectives, fixed GMT+7 periods, unpaid expiry, retained paid points and once-only genuine menu rewards passed the authorized basic checks. Ordinary release Scissors draw returned +3 match / +1 quest points, fresh Win-3 0/3 and paid history; direct clock checks and browser daily/Monday controls passed. Export now explicitly includes shared modal tuning. Feature commit `052575c` (`feat(quests): add fresh progress resets and reward views`) succeeded before checking only slice 8. See `docs/reports/M08_Report.md` for scoped evidence, preview/server boundaries, actual catalogue feedback, deferred unverified checks and creator try-out. No M08 playthrough acceptance, extra hands-on checkpoint or HUB audit is claimed. Stop after M08; M09, Final Review and learning wrap-up remain untouched.
