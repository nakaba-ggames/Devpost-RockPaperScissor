# M03 — Gameplay I: arena intro and initial choice

Status: implementation and the creator-authorized basic mechanical verification are complete. Feature commit and slice 3 completion record follow the reviewed file set. M03 creator feedback is pending; no hands-on checkpoint is claimed.

## Scope and approved references

Executed only M03/checklist slice 3 in recorded fast mode, following M02 feature `2425b35` and completion record `5868dca`. Read AI_Bootstrap; Milestones' universal requirements, development adapters, completion protocol and complete M03 brief; checklist slice/mode/checkpoints/Revisions; M01/M02 reports and relevant M02 event/export evidence; scope; the assigned PRD/spec sections; project-local `5-build`; and private learning context without reproducing it.

PRD references: Screens and Layout; Look and Feel; Arena Intro and Conditions; Decision Announcements and Phase Progression; Phase 1 — Option; Opponent Statistics and Saved Records. Spec references: Godot Match Coordinator; Shared Scenes and Tuning Resources; Data Model; Live Match Messages; Lifetime Statistics and Derived Percentages; Staged Development Providers.

Delivered the arena intro and Option only. No Claim, intentions, final choice, scoring, bot personality policy, chat, cinematic/result, receipts, submenus, backend writes or live match transport. No other chat/subagent was created or messaged. The 12-milestone plan remains unchanged.

## Changed files and why

- `scenes/arena/table_base.tscn`, inherited `arena.tscn`, `scripts/app/arena.gd`: portrait table, six face-down representatives, central submissions, condition/timer/tendencies, dimmed choices, animated introductions/motion/dimming/tells/Phase Ends and the explicit development return/boundary.
- `scenes/ui/arena_card.tscn`: inherited variant of the existing `card_base.tscn`, sharing its backing/emblem. Uses existing Rounded-Rect.png and the already permitted icon copy; no artwork was generated. SearchCard and its creator AnimationPlayer hook were preserved.
- `scripts/arena/option_coordinator.gd`, `initial_choice_history.gd`, `round_log.gd`: authoritative deadline, once-per-actor shuffle, accepted revision events, expiry/defaults and in-memory handoff. New script UID companions are included.
- `scripts/resources/arena_rules.gd`, `resources/arena/option_rules.tres`: approved 15-second rule/revision and explicitly unconfigured production arena weights.
- `scripts/resources/arena_motion.gd`, `resources/presentation/arena_motion.tres`: Inspector-editable intro pacing, card movement, spacing/scale, dimming, announcement/phase feedback durations, transition and easing.
- `scripts/development/arena_fixture.gd`, `scripted_option_opponent.gd`, `resources/development/arena_fixture.tres`: controlled condition default and opponent decisions/revision, isolated from production bot/network logic.
- `scripts/matchmaking/match_context.gd`: adds the retained RoundLog reference without changing match/participant/generation/credit identity fields.
- `scenes/matchmaking.tscn`, `scripts/app/matchmaking.gd`: replace minimal destination and consume `match_ready(context)`. Initialize the arena before its fade becomes visible, avoiding a flash of uninitialized table content. Reservation ownership remains in MatchSession until return.
- `scenes/main.tscn`, `scripts/app/main.gd`: labelled condition fixture selector, arena presentation space, restored menu chrome on return, and tighter menu spacing so the added fixture control fits the observed portrait viewport.
- `devpost/checklist.md`, this report, `M03_PackManifest.txt`, `M03_evidence/`: scoped verification revision, actual observations and completion record. Evidence has `.gdignore`; it is not game artwork or saved competitive history.

## Architecture/interface changes and M04 handoff

`OptionCoordinator.begin_match(context, condition)` creates an in-memory RoundLog, attaches it to `context.round_log`, and shuffles each actor's `[Rock, Paper, Scissor]` order once. No selection, revision, tween or lock reshuffles it. `start_option()` sets a monotonic deadline exactly 15,000 ms ahead. `accept_choice(actor_id, choice)` accepts changes only during Option and before that deadline. Re-selecting the same identity does not emit a false revision. The normal same-choice/no-op safeguard was inspected, not separately edge-tested.

`decision_accepted(actor_id, revised)` drives public decided/changed tells. Actual hidden identities stay inside the coordinator/history and card movement mapping; identical face-down art and independently randomized mappings do not label opponent positions as R/P/S. Only the local player's current/locked identity is shown. Explicit `RoundLog.debug_snapshot()` inspection is separate from normal UI and routine logs.

At expiry, logic locks before starting phase-end animation. Each missing initial choice becomes index 0 of that actor's retained order. A process-frame delay in presenting/observing lock does not extend accepted input time: the input path also checks the absolute deadline. Both decisions never trigger early completion. Required state changes and event appends run outside assertions.

RoundLog stores match ID, rules revision, condition, actor fragments, host-relative Option start/deadline/lock times and presentation completion. Each actor fragment carries actor ID, stable starting order, accepted `initial_card`, ordered events, `defaulted`, `locked` and lock time. Events carry match/phase/actor, global sequence, per-actor revision, accepted choice, first-versus-revision/default kind and match/Option-relative time. This is the M03 prefix of the planned RoundLog; no future claim/final/result fields are fabricated.

The presentation emits `option_complete(context)` after feedback/return fade and marks `presentation_complete=true`, `phase=m03_complete`. **It stops there.** M04 can extend the coordinator and actor history with separate claim fields using the retained context/order/initial card, rather than deriving anything from UI. MatchSession still holds the identical context reservation at this boundary. The development Return clears coordinator references and releases only the matching reservation through existing matchmaking ownership; it does not save the round. There is no production result, registration or continuation transport yet.

## Development fixtures versus real services/players

All M03 matches use M02's scripted-found path and preview participants/ratings. Velvet is the controlled development opponent, not a verified human. Its fixture chooses Rock around 3 seconds and revises to Paper around 7 seconds, without consulting the player's hidden choice. This is neither production bot policy nor live peer messaging. No account history has been fetched: all three initial-choice tendencies show N/A. No fabricated sample percentages are supplied.

The menu explicitly selects Devil's Seduction, Angel's Confession or No modifier as a **fixture**. `option_rules.tres` keeps `production_weights_configured=false` and all weights at -1. No equal/arbitrary production distribution or production random condition picker was adopted. The intro explains the future condition; fulfillment/scoring is outside M03.

M02's `development_only=true`, `persistent_credit_allowed=false`, transport, identities, generation and control kinds remain intact. GD-Sync's existing actual connected indicator appeared, but this supplies neither human multiplayer nor backend account verification. No development round was persisted, credited, uploaded or fed into lifetime statistics.

## Mechanical verification: actions, environment, results and evidence

2026-10-22, Asia/Jakarta. macOS on Apple M2, Godot **4.7.stable.official.5b4e0cb0f**, existing GD-Sync **1.0.2**, MCP toolkit **1.0.0**. Native viewport 540×960 displayed at 432×768. Browser: Codex in-app Chromium, UA **Chrome/155.0.0.0**, 625×827 capture with portrait canvas. No device/browser matrix is claimed.

| Scoped action | Observed result |
| --- | --- |
| Focused diagnostics and scene inspection | MCP script_check passed with empty diagnostics for all 11 changed/new scripts; the three subsequently edited scripts were checked again. Inspected inherited table/card hierarchy, six cards, coordinator/adapter, controls and final feedback backing. No whole-project test suite was run. |
| All three controlled intros | Devil, Angel and No modifier appeared before Option, each with its condition explanation. Native screenshots: `devil_intro.png`, `angel_intro.png`, `none_intro.png`. |
| Rock → Paper → Scissor and revisions | Accepted at Option-relative 152, 2,782 and 3,633 ms. Decided/revision tells and card advance/return/dimming were visible. Local order stayed `[Rock, Scissor, Paper]`; opponent order stayed `[Rock, Paper, Scissor]`. Latest Scissor locked. Both had decided by about 3 seconds; the phase still locked after **15,017 ms**. See `choices_start`, `revised`, `choices_locked` in native observations and the three choice screenshots. |
| Ordinary idle Option | No local selection; unchanged order `[Scissor, Rock, Paper]` defaulted to Scissor at **15,000 ms**. Actor/default timing and presentation completion were inspected. Further condition-intro runs were allowed to finish ordinarily, also retaining leftmost defaults. |
| Phase-end presentation | Native `phase_feedback.png` captures the fading central Phase Ends label before completion; it is a fade-tail capture, not a peak-opacity still. Motion/opacity/scale and lock-before-animation paths were inspected. Browser subsequently reached completed feedback and the M04 boundary without a stall. |
| N/A and hidden opponent | Native/browser UI showed Rock/Paper/Scissor N/A, face-down opponent cards, and public decided/changed tells. Opponent accepted identities were inspected only in controlled debug evidence. |
| Affected-path release browser | Scripted-found → visible Devil intro → Option → Rock then Paper revision → locked Paper → completed boundary → Return/menu. Logged **15,000 ms** Option and presentation completion. Final captured browser logs contain no warnings/errors. The observed card positions and revision still include intermediate motion. |
| Export and assertions | Actual final PCK: **82 entries, 433,052 bytes**, SHA-256 `1a99f7bef855d41396bee86f3e9554591c6013f4f0027b155ef0f5602b65bea9`. All new compiled scenes/resources and runtime scripts are present. No shipped script contains an assertion. |

Evidence: [native structured observations](M03_evidence/native_observations.json), [browser events](M03_evidence/browser_events.json), [browser intro](M03_evidence/browser_intro.jpg), [browser revision](M03_evidence/browser_revision.jpg), [browser completion](M03_evidence/browser_complete.jpg), [pack manifest](M03_PackManifest.txt). Screenshots are observations of those moments, not claims that every frame or edge case was tested. Hidden debug snapshots remain evidence only.

Ordinary-use repairs: the first table playtest exposed labels collapsing to the origin in inherited controls; explicit base layout modes fixed their saved offsets. The arena is initialized before its visible fade. Browser inspection exposed an overly tall menu after adding the fixture selector; reduced menu spacing fixed the affected layout. Added an existing-art backing to keep central phase feedback legible. Final browser smoke used the resulting export.

### Explicit verification limitation

The creator directed **basic M03 verification only** and deferred edge cases to a dedicated session. No full suite, broad regression, stress/race testing, malformed input, deadline-boundary injection, deliberate service failure, duplicate/stale-message injection, disconnect/takeover, accelerated clock, or browser/device matrix was performed. These are **unverified**, not passed. No M01/M02 full checks or 30–45-second unsuccessful search was repeated merely to reach M03. This limitation is also recorded under checklist Revisions.

## Learner check / checkpoint

Fast mode remains selected; M03 is not a planned hands-on checkpoint. M03 creator feedback is **pending**. No hands-on/checkpoint/final-review box was marked performed. The creator's actual M02 feedback, “I've tried it and it works,” supersedes that earlier report's pending note; it is not reused as M03 feedback.

Native launch, from this exact project:

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor
/Applications/Godot.app/Contents/MacOS/Godot --editor --path .
```

Press **F5** (main project, not F6 on the standalone arena). Continue the remembered preview name, or enter a nonempty preview name if new. Select **Scripted opponent found** and one labelled arena condition, then **Play**. Search takes about four seconds, followed by the intro and full 15-second Option.

1. Enter the arena and choose Rock, Paper or Scissor; reconsider while the timer runs. Watch the representative advance, previous card return and decided/Changed their mind tells.
2. After Option completes, use **Return to menu • development**. Start another match and give no card input; wait for the full window and inspect the leftmost default.
3. Review player/opponent placement, readable table/timer/N/A information, dimming, visible feedback and motion. Try the other condition fixtures if desired. The flow stops at the labelled M03 boundary; Claim is not implemented.

Browser alternative: the localhost-only server is already serving [http://localhost:3000/](http://localhost:3000/), and the current preview tab remains open at the menu. Reload for the current export. If the server is stopped, run `python3 tools/serve_m01.py` from the project directory; do not start a second server on port 3000. Re-export after source changes using the command below. No backend development server is required for these fixtures.

## Godot MCP operations and limitations

Discovered the project-specific tools and confirmed the connected root through the toolkit's ProjectPaths/ProjectKey helper as `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor`, matching this exact case-normalized project. No other connected project was mutated.

Used supported scene open/tree/query, editor node visibility edits/save, focused script checks, runtime game start/poll/stop, input simulation, screenshots, script-variable reads, expression-based state inspection and logs. Toolkit `execute_code` cannot directly access global singletons; initial project-root expressions were rejected without mutation. The existing plugin's EditorInterface access supplied filesystem scans and focused scene reloads. Dedicated discovered refresh/runtime-inspection groups were not exposed as callable tools in this session; available script-variable/expression operations covered the required inspection.

Some game launches reported runtime discovery timeout, then the documented `game_start(if_running=return, runtime_poll=true)` connected. The editor retained an earlier base-scene view after external edits; explicitly reloading table_base and arena exposed the final backing node. Browser screenshots/logs used the normal local release game through the in-app browser, not an injected debug transport. Native final-session logs contain no gameplay error; old editor output contains prior-session diagnostics, so it is not represented as an entirely clean historical console.

## Web/export checks and limitations

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release Web ../backend/public/index.html
```

Final export exited 0. Reused `tools/inspect_m01_pack.py` against the actual current PCK. Selected-scene dependency export remains filtered, single-threaded (`GODOT_THREADS_ENABLED=false`), without extensions/PWA. New resources are scene-linked, not new path-loaded dependencies. Existing SDK path-loaded scripts, web unique-ID guard and explicit `res://` autoload path are preserved. Only existing required textures and M03/M02 runtime fixtures/dependencies ship; no toolkit runtime, reports, learner profile, unused artwork or future gameplay content ships.

The headless exporter still emits inherited host certificate/registry/editor-settings/port permission diagnostics and the SDK teardown `editor_script_saved` error. They were not hidden or repaired by changing SDK code; they are distinct from the browser smoke's empty warning/error list. This report does not claim clean exporter/editor logs.

The SDK-bearing PCK still contains its existing connection configuration. Generated exports remain ignored and **localhost-only**; no public upload/distribution was performed. Public SDK-package distribution is unresolved as inherited from M01/M02.

## Commits and checklist slice update

Reviewed intended source/resource/scene/evidence paths and excluded unrelated work. Feature commit uses `feat(arena): add intro and timed initial card choice`. Only after that commit succeeds will slice 3 be checked and this section record its hash in a separate completion record. Other slices and all unperformed checkpoints remain untouched.

Pre-existing Finder metadata, sibling backend image/metadata, untracked planning documents and M01 evidence imports are preserved and excluded. The learner profile, local credentials and generated exports remain ignored/untracked. No blanket staging or history rewrite is used.

## Unresolved creator inputs and next assigned milestone

- Production arena weights remain explicitly unset creator-owned `.tres` inputs. Fixtures exercise all intros without deciding distribution.
- Final artwork, allegiance icons, copy/typography and motion refinement remain creator authoring. Existing permitted backing/emblem artwork supports the working M03 flow; it is not claimed as final art.
- M03 try-out feedback is pending. Dedicated edge verification and other browsers/devices remain unverified.
- M04 receives the retained context, stable actor orders, accepted/defaulted initial cards, events/timing and completion flag. It must keep later identity/switch claims separate from actual cards and preserve reservation/hidden-state boundaries. No M04 implementation was started.
