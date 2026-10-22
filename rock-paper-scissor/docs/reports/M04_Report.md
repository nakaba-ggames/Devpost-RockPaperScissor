# M04 — Gameplay II: identity claim and change claim

Status: **complete** for assigned M04 behavior and creator-authorized basic verification. M04/slice 4 only; fast mode. M05 has not started.

## Scope, references and changed files

Implements the M04 brief and the assigned PRD Claim, Change Claim, Decision Announcements, Arena Chat and Look and Feel sections; spec coordinator, presentation, messages, data model, shared scenes/tuning and staged providers; AI_Bootstrap and project-local `5-build`. The creator's M03 confirmation, “I've tried it and it works,” supersedes M03_Report.md's historical pending note. The HUB's limited audit was supplied as context, not represented here as rerun tests.

- `scripts/arena/{option_coordinator,initial_choice_history,round_log}.gd`: retained coordinator/history extended with independent claims, phase timing/default/lock state and events.
- `scripts/app/arena.gd`, `scenes/arena/arena.tscn`: animated unused-card exit, shared speech bubbles, two claim screens, announcements/feedback and M05 return boundary.
- `scenes/ui/{speech_bubble,modal_shell,arena_chat}.tscn`: one reusable bubble and a chat variant of a common full-screen modal shell using existing Rounded-Rect art. Existing choice button family is reused; Keep is first/index 0 and Switch second/index 1.
- `scripts/chat/match_chat_session.gd`, `scripts/development/local_preview_chat.gd`: replaceable match-only messaging seam and explicit local preview implementation; UID companions included.
- `scripts/resources/{arena_rules,arena_motion}.gd`, corresponding `resources/arena/option_rules.tres` and `resources/presentation/arena_motion.tres`: 15-second claim windows and Inspector-exposed bubble/card/chat motion with existing easing.
- `scripts/development/{arena_fixture,scripted_option_opponent}.gd`, `resources/development/arena_fixture.tres`: controlled claim/revision inputs, with no production bot policy.
- `devpost/checklist.md`, this report, `M04_PackManifest.txt`, `M04_evidence/`: authorized verification limit and concise evidence. Evidence has `.gdignore` and is never shipped game history/art.

## Coordinator, history and chat contracts

The same `MatchContext`, `RoundLog`, actor order, initial cards and MatchSession reservation continue from Option. `begin_match()` is called once at arena entry. `option_complete(context)` still fires after Option feedback; presentation then prepares Claim and calls `start_claim("identity_claim")`, followed by `start_claim("switch_claim")` after identity feedback. No reshuffle, replacement context or intervening release occurs.

`accept_claim(actorId, value)` uses coordinator phase/deadline checks and the existing `decision_accepted(actorId, revised)` announcement signal. Repeated identical values do not invent revisions. Events retain `{matchId, phase, actorId, sequence, revision, kind, revised, elapsedMsec, payload}` and add claim-relative `phaseElapsedMsec`. Revision numbering restarts per actor/phase; global sequence continues across phases. Actual initial cards never change in either claim phase.

Actor `identity_claim` and `switch_claim` are independent fields. `claim_phases[phase]` retains each phase's events/default/lock flags and lock time; RoundLog `claim_timing` retains starts, deadlines and locks. Option's existing events/default/lock/timing fields remain intact. No-input Claim copies that actor's locked initial card; no-input Change Claim stores `keep`. Logic checks the monotonic deadline before accepting input, and locks before emitting presentation feedback. Both actors deciding never advances early. Animation does not extend a deadline.

Chat contract: `begin(context)`, `send_text(text) -> bool`, `receive_message(envelope) -> bool`, `message_received(envelope)`, `dispose()`. Envelopes identify match, actor, sequence, plain text and delivery status. This development provider only echoes the local message with `delivery=local_preview`; it has no peer/backend send and no reply generator. Plain Labels render text without markup. Messages live outside RoundLog and clear on leaving; no archive, competitive credit or upload exists.

The overlay has z-index 20 above selection/dimming and stops mouse input across its full rect, including transparent artwork corners. The blocker stays stationary while content slides/fades. `set_chat_open_allowed(bool)` disables new opening, deliberately preserving any existing overlay for the creator's future cinematic-close choreography. No cinematic or guessed close transition was added. No plan/stack/product deviation; final copy remains creator-owned.

## Development fixtures versus actual services/players

Scripted-found reaches the arena in about four seconds. Velvet is a development opponent, not a verified human: identity Rock → Scissor and intention Keep → Switch at fixture-controlled 3/7 seconds. The adapter reads only its own fixture, never the player's hidden card. No production personality or balancing is introduced. Missing history shows **N/A**; no sample tendency percentages are fabricated. The existing actual GD-Sync connected indicator is not evidence of peer delivery, matchmaking or backend persistence.

## Basic mechanical verification

2026-10-23 Asia/Jakarta; macOS/Apple M2; Godot **4.7.stable.official.5b4e0cb0f**, GD-Sync **1.0.2**, MCP toolkit **1.0.0**. Native viewport 540×960 shown at 432×768. Release browser: Codex in-app Chromium **155.0.0.0**, 625×827 capture. No browser/device matrix.

| Action | Observed result |
| --- | --- |
| Focused diagnostics/scene inspection | All 10 changed/new GDScript files passed MCP script_check with empty diagnostics after correcting an empty enum annotation. Final presentation change was checked again. Inspected retained table/card family, bubbles, chat shell hierarchy and coordinator/adapter nodes. |
| Normal native revised flow | Initial Rock; truthful Rock at Claim-relative 7,650 ms, revised to false Paper at 8,834 ms. Keep at 8,366 ms, revised Switch at 9,265 ms. Public tells and bubbles updated; initial Rock and actor order remained unchanged. Identity locked after **15,000 ms**; intention after **15,014 ms**. Both actors had decided earlier. |
| Ordinary native no-input flow | Initial leftmost Scissor remained Scissor. Honest identity default at **15,016 ms**, Keep default at **15,001 ms**, separate default/lock events retained, final bubble “I'll keep my choosing”. Feedback finished at `m04_complete`. |
| Chat across both dimmed screens | Opened/closed during Claim and Change Claim. Sent “Claim phase preview” locally; one message remained through completion with no opponent response. Clock continued and phase windows stayed full. Return disposed messages/identity/context; reservation was identical before return. |
| Affected release-browser flow | Current uniquely named release traversed Option → identity → intention → completed feedback/boundary. Opened/closed chat over both claim selections and observed clocks/phase progression continuing behind it. Browser automation entered/sent the single-character local preview “R”; it was labelled not delivered, with no opponent message. Logs show 15,000–15,015 ms claim locks and completed animation. Warning/error list is empty. Separate visits captured the two live windows; no accelerated clock or debug web transport was used. |
| Export/assertion review | Final export exited 0. PCK has **90 files, 454,136 bytes**, SHA-256 `477a047542d64a6420dbee39c231db040799fc01d8567181246d3fd27b484cd4`. All new scene/script dependencies are present; no shipped script contains an assertion. No new path-loaded resource dependency. |

Evidence: [native observations](M04_evidence/native_observations.json), [identity](M04_evidence/identity.png), [intention](M04_evidence/switch.png), [native chat](M04_evidence/chat_switch.png), [pack manifest](M04_PackManifest.txt), [release events](M04_evidence/browser_events.json), [release chat](M04_evidence/browser_chat_identity.png), [release completion](M04_evidence/browser_complete.png). Hidden debug snapshots are controlled evidence, never normal opponent UI or uploaded match records. Screenshots substantiate captured moments, not every animation frame.

Authorized limitation: **basic M04 only**, recorded under checklist Revisions. No full suite, broad regression, stress/race checks, malformed input, deadline-boundary injection, deliberate failure, disconnect/takeover, live peers or browser/device matrix. Deferred behavior remains **unverified**, never passed. No M01–M03 full checks, all intros or 30–45-second search were repeated. The browser initially served the old M03 package from the normal URL; this was detected from visible boundary/logs and is not counted as M04 verification. A uniquely named localhost export is used for current-package observation.

## MCP and web/export limitations

Discovered project-specific MCP tools and confirmed root through the toolkit ProjectKey helper as `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor`, matching the assigned case-normalized project. No other project was mutated. Supported scene open/tree, focused script checks, game start/poll, ordinary input, screenshots, runtime expression state and logs supplied evidence. Discovered editor refresh/runtime advanced groups were not callable directly; the existing plugin EditorInterface filesystem scan/reload plus expression inspection supplied the fallback. Expression singleton/scope limitations required the existing helper; initial failed expressions did not mutate anything.

Single-threaded export filtering, explicit `res://` SDK autoload and existing SDK web guard are unchanged. Scene-linked new assets and existing required SDK path-loaded scripts ship; private docs, source/unused art, toolkit, reports and learner profile do not. Required state changes run outside assertions. A direct sandboxed headless diagnostic attempt crashed opening the host user log; export using `--log-file /tmp/...` succeeded. Export still reports inherited host certificate/registry/editor-settings permissions and SDK `editor_script_saved` teardown diagnostics. These are distinct from runtime observations; no clean historical editor/export console is claimed.

Generated SDK-bearing exports stay ignored and localhost-only. Public SDK-package distribution remains unresolved. No public publishing or backend writes were performed.

## Creator try-out and feedback

M04 feedback is **pending**. Fast mode continues; M04 is not a planned hands-on checkpoint and no unperformed checkpoint/final-review box is marked complete.

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor
/Applications/Godot.app/Contents/MacOS/Godot --editor --path .
```

Press **F5** for the main project. Continue the remembered preview name (or enter a nonempty one), select **Scripted opponent found** and a labelled condition fixture, then **Play**. Choose an initial card; Option continues for 15 seconds, then Claim and Change Claim each have their own 15 seconds.

1. Lie about the locked initial card, then revise the identity claim; watch the bubble and decided/changed tells.
2. Choose Keep, revise to Switch and back if desired; the exact intention bubbles change while the locked card stays put.
3. Open/close chat over both selection screens; send a local preview message. Expect no opponent reply and a continuing clock.
4. Review portrait readability, bubbles and motion. After Change Claim feedback, use **Return to menu • development**.

Browser alternative: [current M04 preview](http://localhost:3000/m04.html). The existing localhost server is retained. If stopped, run `python3 tools/serve_m01.py` from the project; do not start a second port-3000 server. Rebuild with `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --log-file /tmp/m04-export.log --export-release Web ../backend/public/m04.html` after source changes. No backend server is needed for these fixtures.

## Commit, progress and M05 handoff

Feature commit: `b4e5eff` — `feat(claims): add both timed claims and chat overlay`. Only after that implementation commit succeeded was slice 4 checked. The completion record is saved separately as `docs: record M04 completion and verification limits`. The exact 31-file intended staged set, staged diffs, whitespace checks and local credential/private-key pattern scan were reviewed successfully. Explicit intended paths/staged diffs were reviewed; learner profile, credentials, generated exports, pre-existing Finder metadata/sibling image, untracked planning documents and old evidence imports stay excluded.

M05 receives the retained context, unchanged orders/initial cards, separate identity/intention values, phase events/defaults/locks/timing and `claims_presentation_complete=true` through `claims_complete(context)`, with coordinator phase `m04_complete`. Reservation remains held until development Return. It must extend this same context for final-card work; no Phase 4 selection, switching action, scoring/classification, production bot policy, result receipt, cinematic, live transport or submenus were implemented. Creator final copy and cinematic chat-close choreography remain outstanding; dedicated edge verification is deferred.
