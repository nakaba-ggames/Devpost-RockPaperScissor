# M05 — Gameplay III: final choice, round resolution and local bot behavior

Status: **complete** for assigned M05 behavior and authorized basic verification. Fast mode; slice 5 only. M06 has not started.

## Scope and approved references

Implements M05 in `docs/Milestones.md` and checklist slice 5; PRD Phase 4, scoring/classification, decision progression and departure attribution; spec match coordinator, bot Resources, pre-cinematic commitment, data model, lifetime statistics, shared tuning and staged providers. Follows AI_Bootstrap and project-local `5-build` within the human's narrower verification/stop instructions. M04 accepted from supplied feature `b4e5eff`, completion `3286db2` and checked slice 4. No new HUB audit or detailed M04 try-out feedback is claimed.

## Changed files and purpose

- `scripts/app/arena.gd`, `scenes/arena/arena.tscn`: final candidate/confirmation controls, unchanged RPS order, initial reminder, switching tendency/N/A, animated selection, identical face-down submission effects, phase-end feedback and development Return. Reuses inherited table/card/button families and existing Star 2 artwork.
- `scripts/arena/{option_coordinator,initial_choice_history,round_log}.gd`: extend the retained round with final decision/default/lock/timing/events and M06 handoff. `submission_particles.gd` configures the shared CPU particle effect.
- `scripts/resources/{arena_rules,arena_motion,submission_effect}.gd`, `resources/arena/option_rules.tres`, `resources/presentation/{arena_motion,submission_effect}.tres`: final window, fixed scoring rules and Inspector-exposed motion/effects; revision `m05-round-v1`. Production arena weights remain unset.
- `scripts/resources/bot_personality.gd`, `resources/bots/development_personality.tres`, `scripts/bots/{local_bot_policy,local_opponent_adapter}.gd`: Resource-driven local decisions behind the opponent adapter. All numeric policy values are explicitly a development fixture.
- `scripts/development/{arena_fixture,scripted_option_opponent}.gd`: retain separate deterministic scenarios and add final decisions through the same coordinator contract.
- `scripts/results/{round_resolver,result_sink}.gd`, `scripts/development/local_result_sink.gd`, `scripts/matchmaking/{match_context,match_participant}.gd`: pure resolution, frozen finalization envelope, attribution facts and simulated receipt interfaces.
- UID companions, `tools/m05_rule_checks.gd`, checklist Revisions, this report, `M05_PackManifest.txt` and `M05_evidence/`: focused verification/progress evidence. The evidence folder has `.gdignore`; checks/reports are excluded from export.

## History, result and ResultSink contracts

The same MatchContext, actor orders, initial cards, prior events and MatchSession reservation survive every phase. `begin_match()` remains arena-entry only. After `claims_complete(context)` at `m04_complete` with `claims_presentation_complete=true`, `start_final()` opens the full 15-second window. Selecting a candidate does not submit; the bottom Switch confirmation calls `accept_final(actorId, card)`. Keeping, switching and revisions are accepted until the deadline. Reconfirming the same submitted value creates no false revision. Both actors deciding never shortens the window.

`InitialChoiceHistory` retains `initial_card`, `identity_claim`, `switch_claim`, `final_card`, original order and existing Option/claim fields. `final_state` adds events/default/lock/lock time; RoundLog adds `final_timing` and a separate presentation-complete flag. Camel-case snapshot fields include `initialCard`, `identityClaim`, `switchClaim`, `finalCard`, `startingOrder`, `finalState` and `finalTiming`. Final events preserve match/actor/phase, global sequence, phase revision, relative timing and payload. No-input final is startingOrder[0], independent of Keep. Authority locks before motion; animation completion cannot extend a deadline.

`RoundResolver.calculate(snapshot, rules)` reads structured fields, never bubbles. Identity truth compares against the initial card. Intention truth compares Keep/Switch against final-versus-initial difference. Revisions do not inflate switching. Any false claim contributes exactly one lying classification; both true contribute one honest classification. RPS determines outcome. Resource rules award base 10/3/0; qualifying Devil totals 20/8, Angel 25/10; nonqualifying rewards remain base. Losses are zero, deltas are nonnegative, balances are not mutated and no quests/rewards are paid.

At final lock, `RoundResolver.submission()` takes a detached snapshot and recursively makes the envelope, history, results and recipient arrays/dictionaries read-only. The live RoundLog separately tracks completed presentation. MatchContext retains `result_id = match_id + ":result"`, `result_submission` and `result_receipt`. Reuse this same frozen envelope/identity for later retry/query handling; do not recalculate from presentation or changed eligibility.

Envelope fields: `resultId`, `matchId`, `rulesRevision`, `history`, `result`, `recipients`, `developmentOnly`, `persistentCreditAllowed`. Recipients carry actor/display identity, control kind, `departedBeforeCommit`, `takeoverSide`, `eventualEligible` and `persistentCreditAllowed`. Ordinary fallback participants retain normal eventual eligibility; either pre-commit departure or takeover-side flag excludes that side, while the remaining human stays eligible. M09 must supply real departure facts. These hypothetical flags are separate from this build's **persistent_credit_allowed=false**. No live departure/takeover transport was implemented or tested.

`ResultSink.submit(envelope)` exposes `acknowledged(result_id, receipt)` and `failed(result_id, detail, retryable)`. The configured local sink returns a stable, in-memory simulated receipt tagged `simulated=true`, `serverAcknowledged=false`, `persisted=false`, `persistentCreditAllowed=false`. It performs no API, profile, file, record or quest write. Repeated delivery identity is retained; deliberate retry/failure/conflict testing is deferred. An acknowledgement signal from this provider is **not** a server acknowledgement or persistence proof.

After final motion, coordinator `round_ready(context)` and arena `round_complete(context)` expose the `m05_complete` boundary. M06 must use the frozen history/result and provider-specific receipt gate before its own creator-authored presentation. Return disposes chat and releases the reservation by its original match ID through the existing owner. No hidden opponent story, final opponent card, production result screen, cinematic or narration is shown here.

## Bot configuration and service boundary

The active DevelopmentOpponent now uses `local_opponent_adapter.gd`; the M02 scripted-found participant identity/control label remains a development fixture, not a human peer or verified live fallback. The policy receives **no coordinator, MatchContext, human actor or human hidden choice**. Its detached input is `{phase, revision, public: {condition}, own: {startingOrder, initialCard, identityClaim, switchClaim, finalCard, events}}`. Inspection and saved ordinary runtime observations confirm this boundary. The host adapter alone calls the normal coordinator acceptance methods. No bot chat listener/reply exists; existing local-only chat layering/disposal and future presentation gate remain intact.

The personality Resource supplies RPS weights, identity/intention lie probabilities, switch/revision chances and decision/revision time ranges. Its profile ID is `m05-policy-fixture-not-production`, with `development_fixture=true`. The fixture uses equal RPS weights, illustrative tendencies and 2–3/6–7-second decision/revision ranges; these are **not approved production balance or roster-selection policy**. `scripted_option_opponent.gd` plus `arena_fixture.tres` remain separately available for controlled verification. A revision can choose the same value; it then creates no changed announcement, as with human input.

No backend writes, live match transport, disconnect integration, competitive credit, preview-history upload, submenus or quest progression were added. The actual GD-Sync connected indicator only establishes the inherited service connection.

## Basic mechanical verification

2026-10-23 Asia/Jakarta; macOS/Apple M2; Godot **4.7.stable.official.5b4e0cb0f**, GD-Sync **1.0.2**, MCP toolkit **1.0.0**. Native viewport 540×960 displayed at 432×768. One single-threaded release-browser journey in Codex in-app Chromium **155.0.0.0**, viewport 1280×720. No browser/device matrix.

| Check | Observed evidence |
| --- | --- |
| Focused scripts and scene | All 18 changed/new game scripts passed MCP script_check with empty diagnostics after fixing one inferred Dictionary-expression type and editor discovery of new classes. Explicit preloads resolved stale editor class registration. Scene tree contains retained coordinator/cards/chat plus final confirmation, ResultSink and two CPU particle nodes. |
| Normal native final flow | Initial Rock; Keep claim; confirmed Rock then revised/confirmed Paper at final-relative 13,600 ms. Bot final decision already accepted at 2,650 ms. Final lock remained **15,000 ms**. Structured result is a draw, one false intention, one lying classification, Devil total 8. Same reservation retained; simulated receipt and `m05_complete` present. |
| Ordinary idle final | New round left idle; starting order Paper/Scissor/Rock, initial Paper, truthful identity/Keep defaults, final Paper from index 0. Final default/lock at **15,000 ms**, no actual switch, honest classification. Same reservation and simulated receipt present. |
| Assigned direct rule checks | `tools/m05_rule_checks.gd`: 9 RPS outcomes, 36 combinations of honest/identity-false/intention-false/two-false claims × arena × outcome, plus truthful Switch and approved non-leftmost initial → default Keep → leftmost final. **119 focused condition checks, zero failures**; no full timed replay per formula. Zero losses, fixed totals, one classification and final-equals-initial despite intermediate events verified. |
| Bot ordinary behavior | Resource-backed decisions/reconsideration observed in all four phases. Saved `last_policy_input` contains only own history and public condition. No human hidden choices or chat inputs. No production tuning claimed. |
| Release-browser full round | Scripted-found → Option → both claims → Change → M06 boundary. Chose initial Rock, claimed Keep, confirmed Rock, then revised to Paper. Observed identical gold particles and pulse for Keep and Switch; face-down opponent retained, stable Paper/Scissor/Rock choice order, N/A switching history and continuing clock. Locked after **15,016 ms**, simulated receipt logged, final feedback/Return completed. Browser warnings/errors **empty**. |
| Export/assertions | Release export exited 0. PCK **104 files, 486,008 bytes**, SHA-256 `b1b38a4a1247048ceaf63cb7019796475ff2d2a5ec9df23960ac7a5ed223dd8c`. Bot/effect Resources and new scripts present; required SDK path-loaded files remain included. No shipped script assertions, source/private docs, toolkit, test tool or unused/source artwork. Single-thread mode, explicit `res://` SDK autoload and web guard preserved. |

Evidence: [native normal](M05_evidence/native_normal.json), [native idle](M05_evidence/native_idle.json), [direct rules](M05_evidence/rules.json), [release logs](M05_evidence/browser_events.json), [release boundary](M05_evidence/browser_complete.png), [pack manifest](M05_PackManifest.txt). Native snapshots are explicit hidden development inspection, never normal UI or uploaded records. Particle motion was observed during browser interaction; the saved screenshot records the completed boundary, not all animation frames.

Authorized verification limitation is recorded under checklist Revisions. **Unverified/deferred:** full suite, broad regression, stress/race/deadline-boundary/malformed-input checks, deliberate failure/retry/conflict injection, live disconnect/takeover, human peers and browser/device matrix. No earlier milestone full checks or 30–45-second search wait were repeated. No deferred case is marked passed.

## MCP, browser and export limitations

Discovered project-specific tools and confirmed the toolkit ProjectKey root as `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor`, matching the exact assigned project after filesystem case normalization. No other project was mutated. Used supported scene opening/tree inspection, script diagnostics, game start/stop, ordinary inputs, scoped runtime expressions and game logs.

Discovered advanced editor refresh tools were not exposed as callable tools. Used the existing editor plugin's EditorInterface filesystem scan/reload as fallback. New-class registration was stale in the editor; explicit script preloads supplied deterministic dependencies without a restart or setting change. Initial rejected expression/path probes did not mutate project state.

The existing localhost server was stopped. Starting it inside the sandbox was denied binding the port; the authorized scoped escalation started `python3 tools/serve_m01.py` on **127.0.0.1:3000**. The first browser attempt preceded the running server and failed; a fresh current-build tab then supplied the successful smoke evidence. No security protection was bypassed.

Headless tooling reports inherited host certificate/registry/editor-settings permission diagnostics and SDK teardown `editor_script_saved` diagnostics. The direct calculation runner additionally triggers the SDK's no-debugger logger diagnostic; an initial scene-less runner exposed SDK null-scene assumptions, then a temporary current scene removed those null-scene errors. These are tool/autoload limitations, separate from the zero-failure rule output and clean normal game/browser runtime. No clean global historical editor/export console is claimed.

Only one release export was made. Reports/tests/private docs are filtered out; newly linked `.tres` dependencies are included without broadening the preset. SDK-bearing exports stay ignored and **localhost-only**; public distribution remains unresolved. No generated export or credential is committed.

## Creator try-out and pending inputs

M05 feedback is **pending**. Fast mode continues; M05 is not a planned hands-on checkpoint. No checkpoint, Final Review or learning activity is invented. M04's report remains historical; the creator reports it complete, without detailed new feedback.

Launch exactly:

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor
/Applications/Godot.app/Contents/MacOS/Godot --editor --path .
```

Press **F5**, continue the preview name (or save a nonempty one), select **Scripted opponent found** and a labelled arena fixture, then **Play**. Each of the four decision phases lasts 15 seconds. At Change, choose a candidate and press **Switch • confirm choice**; repeat to revise. Merely selecting a candidate does not submit it.

1. Play truthful and deceptive identity/intention choices; deliberately claim Keep then switch, or claim Switch then keep.
2. Confirm the original card and then another card; compare the face-down particles and reconsider before the clock ends.
3. Leave a final phase idle: it submits the leftmost original-order card. A non-leftmost initial plus default Keep can therefore become a lie.
4. At the development boundary use **Return to menu • development**. No saved credit is expected.

Are the initial reminder, candidate versus submitted choice, full timer and Keep/Switch motion clear? What would you change about readability or motion?

Browser alternative: [M05 localhost preview](http://localhost:3000/m05.html). Server remains running. If stopped, run `python3 tools/serve_m01.py` from the project; do not start a duplicate port-3000 server. Rebuild after source changes with `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --log-file /tmp/m05-export.log --export-release Web ../backend/public/m05.html`, then reload. No backend server is required. Direct scoring check: `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --log-file /tmp/m05-rules.log --script res://tools/m05_rule_checks.gd`.

Production bot personalities/selection and arena probability weights still need creator agreement later; no essential M05 input is missing because explicitly labelled development fixtures were authorized. Final assets/copy and creator-owned outcome choreography remain reserved.

## Commit/checklist and M06 handoff

Implementation commit: pending final intended-file/staged-diff review; planned message `feat(round): add final choice and local round resolution`. Slice 5 remains unchecked until that commit succeeds; completion record follows separately. Only M05's authorized Revisions are added before it. Unrelated Finder metadata, sibling assets, existing untracked planning documents, learner profile, credentials and generated exports remain excluded.

M06 receives the retained context/reservation, full RoundLog, frozen `result_submission`, calculated result, stable result identity and explicitly simulated `result_receipt` at coordinator `m05_complete` with final presentation complete. Preserve the existing chat opening gate and creator-owned close/outcome choreography. Build the future narration/reveal/result and acknowledgement/error presentation in M06 only; this assignment stops here.
