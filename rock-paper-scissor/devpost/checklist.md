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

- [ ] **2. Play and simulated matchmaking with live-shaped behavior**
  Becomes usable: Play opens an animated search, cancellation works, and a controlled development search outcome enters a match-ready arena context.
  Why now: Adds the next actual-flow step while the full live match transport remains in its requested later milestone.
  PRD ref: `prd.md > Ranked Matchmaking`; `prd.md > The Core Journey`.
  Spec ref: `spec.md > Ranked Matchmaking Coordinator`; `spec.md > GD-Sync Integration`; `spec.md > Live Match Messages`.
  Build: Execute M02 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Run menu-to-search and all scripted outcomes; cancel just before and after a found event and prove only one arena context exists. Inspect configured timing/resources and test the normal wait. Use MCP and an affected-path browser smoke check.
  Learner check: Tap Play, leave the search, repeat it, and try the scripted found/timeout paths; report whether the sequence feels close to the intended live flow.
  Commit: `feat(matchmaking): add cancellable simulated search flow`

- [ ] **3. Gameplay I — arena intro and initial choice**
  Becomes usable: A development match announces its arena condition, presents both table sides and completes the Option phase with a real timed card choice.
  Why now: The deception game begins immediately after entry/search, keeping the unique kernel ahead of peripheral submenus.
  PRD ref: `prd.md > Arena Intro and Conditions`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Phase 1 — Option`; `prd.md > Opponent Statistics and Saved Records`.
  Spec ref: `spec.md > Godot Match Coordinator`; `spec.md > Shared Scenes and Tuning Resources`; `spec.md > Data Model`; `spec.md > Live Match Messages`.
  Build: Execute M03 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Exercise all initial choices, repeat/revise selections and allow inactivity to expire. Inspect the stable order/history, full timer, visible tells and phase-end animation. Use MCP and a browser release smoke check.
  Learner check: Enter the arena, choose and reconsider a card, then let another run time out; assess table readability and motion.
  Commit: `feat(arena): add intro and timed initial card choice`

- [ ] **4. Gameplay II — identity claim and change claim**
  Becomes usable: The selected initial card flows through both claim phases, with independent actual/claimed data, public bubbles, revisions and defaults.
  Why now: Delivers the central deception decisions before actual switching/result work.
  PRD ref: `prd.md > Phase 2 — Claim`; `prd.md > Phase 3 — Change Claim`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Arena Chat`.
  Spec ref: `spec.md > Godot Match Coordinator`; `spec.md > Godot Presentation`; `spec.md > Live Match Messages`; `spec.md > Data Model`.
  Build: Execute M04 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Run truthful/false identity claims, both switch intentions, revisions and no-input defaults with all 15-second windows. Inspect separate history fields and bubble values. Verify chat layering and that the development/bot path generates no unsolicited reply.
  Learner check: Try lying about the initial card, then change your switch claim; open chat over each dimmed selection screen.
  Commit: `feat(claims): add both timed claims and chat overlay`

- [ ] **5. Gameplay III — final choice, round resolution and local bot behavior**
  Becomes usable: All decision phases form a complete local round, producing actual initial/claim/final history and a calculated outcome ready for reveal.
  Why now: Closes the playable decision loop and establishes the result contract used by both the cinematic and eventual server.
  PRD ref: `prd.md > Phase 4 — Change`; `prd.md > Points and Match Classification`; `prd.md > Decision Announcements and Phase Progression`; `prd.md > Disconnect and Bot Takeover`.
  Spec ref: `spec.md > Godot Match Coordinator`; `spec.md > Bot Controller and Personality Resources`; `spec.md > Result Commitment Before the Cinematic`; `spec.md > Data Model`; `spec.md > Lifetime Statistics and Derived Percentages`.
  Build: Execute M05 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Check RPS win/loss/draw cases, honest/mixed/two-false claims, fixed arena totals, unchanged-final-card switching statistics, and the active non-leftmost choice followed by default Keep/leftmost case. Inspect Resource tuning and complete history; verify a normal full round in the exported browser.
  Learner check: Play honest and deceptive rounds, deliberately contradict Keep/Switch claims, and try an idle round; assess whether the choices create doubt.
  Commit: `feat(round): add final choice and local round resolution`

- [ ] **6. Cinematic reveal, result and return to menu**
  Becomes usable: A complete development match waits for its simulated receipt, tells the actual match story, presents the result, and returns to the menu.
  Why now: Completes the user-visible core journey before the peripheral submenus and late service integrations.
  PRD ref: `prd.md > Phase 5 — Narration, Reveal, and Result`; `prd.md > Arena Chat`; `prd.md > Main Menu and Player Information`.
  Spec ref: `spec.md > Result Commitment Before the Cinematic`; `spec.md > Godot Presentation`; `spec.md > HTTP API Client`; `spec.md > Important Failure Modes`.
  Build: Execute M06 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Run the full menu/search/round/reveal/menu path with different histories. Inject pending/error/duplicate local receipts, check gate ordering, and verify that narration and result agree. Run browser release checks for animation-completion stalls and assertion side effects.
  Learner check: Play the complete local loop and judge suspense, clarity, pacing and the win/loss/draw payoff before later screens are built.
  Commit: `feat(reveal): add acknowledged narrative result flow`

- [ ] **7. Submenus I — statistics, records and leaderboard**
  Becomes usable: Menu buttons open functional statistics, record and four-category leaderboard views over the preview data-provider contract.
  Why now: Builds the read-oriented submenus together after a complete round can produce their data.
  PRD ref: `prd.md > Detailed Statistics and Records`; `prd.md > Opponent Statistics and Saved Records`; `prd.md > Leaderboard`; `prd.md > Main Menu and Player Information`.
  Spec ref: `spec.md > Godot Presentation`; `spec.md > Lifetime Statistics and Derived Percentages`; `spec.md > Backend API`; `spec.md > Data Model`.
  Build: Execute M07 scope and completion criteria in docs/Milestones.md; use only the assigned development/live providers and creator inputs defined there.
  Verify (mechanical): Use controlled no-history, draw, mixed-claim, tied-allegiance and multiple-record cases; compare displayed aggregates with the approved formulas. Verify category switching, pagination shapes, modal navigation and browser layout.
  Learner check: Open every data view after several preview rounds and check whether it is informative without feeling text-heavy.
  Commit: `feat(submenus): add stats records and leaderboards`

- [ ] **8. Submenus II — daily and weekly quests**
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
- [ ] Integrated local core journey explored — after M06: creator plays menu/search/deception/reveal/menu, shaping feel/narration before later UI/integrations.
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

- 2026-10-22, M01: creator explicitly limits verification to changed-scene diagnostics, one normal editor entry/menu flow, one single-threaded release-browser smoke flow, one ordinary reload, one local-only Clear Data reset, and focused export/assertion checks. Broad regression, failure/disconnect/timeout injection, stress/race/malformed-input checks and device/browser matrix are deferred to a dedicated later session; none may be marked performed.
- 2026-10-22, M01: creator selected fast mode and has no strict naming rules for this preview. Use trimmed, nonempty local display names; production validation remains M10. Final title/menu choreography and allegiance art remain creator-owned.
- 2026-10-22, M01 complete: scoped mechanical evidence is in `docs/reports/M01_Report.md`; creator accepted the full early hands-on check (“Yes, it works perfectly”). Implementation commit `2b773ac` succeeded before checking slice 1 and its early checkpoint. No deferred edge check or later milestone/checkpoint is marked complete.
