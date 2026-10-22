# M06 — Cinematic reveal, result and return to menu

Status: **complete** for assigned functional M06, authorized basic verification and the actual creator checkpoint. Feature commit `23d8316` succeeded before checking slice 6 and the integrated local core-journey checkpoint. Fast mode; M06 only. No M07 work or HUB audit.

## Scope and approved references

M06 in `docs/Milestones.md`, checklist slice 6 and integrated local checkpoint; PRD Phase 5, Arena Chat, Main Menu/Player Information and Look and Feel; spec Result Commitment Before the Cinematic, Godot Presentation, HTTP API Client, Important Failure Modes, Staged Development Providers, Shared Scenes/Tuning Resources and Lifetime Statistics. Read AI_Bootstrap and project-local `5-build`; private learner context remains ignored and excluded. Creator confirms M05 works: feature `f508a99`, completion record `6da3f9f`; no repeated acceptance requested.

The assignment explicitly reduces verification to basic M06. This overrides broader milestone testing instructions and is recorded under checklist Revisions. Deferred failure/retry/duplicate/stress/race/disconnect/device cases are **unverified**, not passed.

## Changed files and why

- `scripts/results/{result_sink,receipt_gate}.gd`, `scripts/development/local_result_sink.gd`: current-sink receipt lookup, early-signal retention, matching gate, timeout/error/retry delivery state and same-envelope retry.
- `scripts/presentation/{round_narration,reveal}.gd`: frozen-history narration and animated delivery/retreat/curtains/projector/gradual dimming/outcome/Continue sequence.
- `scripts/resources/reveal_tuning.gd`, `resources/presentation/reveal_tuning.tres`: Inspector-exposed copy, authoring choices, retry, easing and presentation timings. Creator can configure `OutcomeAnimation` plus `outcome_animation`; temporary outcome is explicitly agreed.
- `scenes/ui/{reveal,reveal_card}.tscn`, `scenes/arena/arena.tscn`, `scripts/app/arena.gd`: presentation composition, inherited face-card variant, automatic chat closure/gate, provider signal and existing navigation cleanup.
- `scripts/api/{profile_provider,local_preview_provider,preview_profile}.gd`, `scripts/app/main.gd`: replaceable acknowledged-result application, session-only points/aggregates and menu refresh/allegiance text.
- `tools/m06_narrative_checks.gd`, UID companions, checklist Revisions, this report, `M06_PackManifest.txt` and `M06_evidence/`: scoped verification and progress evidence. Evidence has `.gdignore`; tools/reports are excluded from export.

## Contracts, boundaries and deviations

ReceiptGate connects to the current sink before final lock, retains early acknowledgements and queries `receipt_for(resultId)` when M05 presentation completes. Matching requires result ID, match ID, rules revision and a nonempty receipt ID. The ordinary synchronous local receipt is consumed without resubmission. Later acknowledgement uses the same gate. Timeout remains uncertain, with animated error and retryability; query/retry uses the identical frozen submission. Nonretryable errors expose no retry. These exceptional paths are implemented/source-reviewed but deliberately not injected.

Narration reads only frozen `result_submission.history`, `.result` and `.recipients`: actual initial cards, identity claims, intention claims, initial-versus-final switching, truth/deception and phase defaults. No bubble parsing, fixed example story or re-resolution from mutable presentation. Departure/Continue only disposes presentation/chat and existing reservation ownership; it never rewrites frozen history, eligibility or awards. No reconnect, restoration, replay or resume flow.

The provider receives the accepted envelope/receipt before presentation. LocalPreviewProvider requires matching simulated/nonpersisted development data and eligible local attribution; a per-session result-ID set prevents repeated credit. It updates points, W/L/D, win streak and honest/deceptive winning counts; draws preserve streak. Main refreshes summary from `enter_menu()` during the existing return transition. Allegiance text follows winning counts; existing temporary icon remains explicitly temporary. No quest rewards, submenu implementation or preview-history upload.

**Development evidence only:** `simulated=true`, `serverAcknowledged=false`, `persisted=false`, `persistentCreditAllowed=false` remain unchanged. Preview aggregates live only in memory and reset on reload; existing name/identity storage is unchanged. No real server commitment, backend API, saved points/history, human peer or live takeover is established. The opponent is the retained scripted-development identity driven by the existing local bot policy; rules and bot behavior were preserved.

## Actual creator choices and authoring

- Gradual dimming: start **0.3**, deepen after each narrated phase to **1.0** just before the outcome; remove treatment before outcome animation.
- Automatically close an already-open chat; it cannot open again for the remainder of this match. Match disposal clears messages/input.
- Creator agrees **temporary factual copy**, with future narrative presets to be authored separately.
- Creator agrees temporary fade/scale card/result/points presentation and **no skip** for this checkpoint, emphasizing functionality while welcoming polish. Final choreography/presets are not claimed complete.

Uses only existing Square/Triangle/Rounded-Rect artwork and inherited card/button families. The projector is a simple warm pulsing light/filter and curtains are rough existing-art treatments; final cinema art/audio and creator polish remain authoring work. An observed overlap between retreated card backs and outcome text was fixed by fading table cards/chrome before the outcome.

## Mechanical verification and evidence

Environment: 2026-10-23 Asia/Jakarta; macOS/Apple M2; Godot **4.7.stable.official.5b4e0cb0f**, GD-Sync **1.0.2**, MCP toolkit **1.0.0**. Single-threaded release in Codex in-app Chromium **155.0.0.0**, portrait canvas in a 625×827 browser capture.

- All 11 changed/new game scripts passed focused MCP `script_check` with empty diagnostics; initial inference errors in narration were corrected with explicit String types. Affected scripts rechecked after presentation fix. Reveal scene inspected through MCP; no broad project scan/full suite.
- `tools/m06_narrative_checks.gd`: four small frozen-history examples; **zero failures**. Truthful Keep/win; deceptive identity + false Switch promise/loss; truthful Switch/draw; default Keep contradicted by leftmost final/win. Both-actor beats, final actions and default annotations agree with existing resolver results. [Examples](M06_evidence/narrative_examples.json).
- First ordinary release journey: menu → scripted-found (4.016 seconds) → four full decision windows → cached simulated receipt → eight narrative beats → loss Rock vs Paper → +0 points/lying → Continue/menu. Initial Rock and deceptive Paper claim accepted; final attempts arrived after deadline, so narration correctly described default Rock/Keep. Receipt preceded cinematic; treatment alpha logged **0.0 before outcome**; Continue appeared after animation. Menu refreshed from N/A to 0% win ratio, 0 points/streak, no-win allegiance. Browser warnings/errors empty. [Logs](M06_evidence/browser_first_flow.json).
- Targeted affected reveal/chat recheck after the overlap fix: left chat open during Claim, without manually closing it; it closed automatically at the acknowledged reveal. Chat-opening attempts during the first narration and the revised result did not reopen it. The revised outcome shows Scissor vs Rock, loss, +0/honest, with no old card/name overlap; Continue returned to the preview menu. No browser warnings/errors. Fresh revised URL plus visibly removed table-card/name overlap confirms the revised build is running. Earlier timed phases only prepared this affected check; no broader regression or failure injection. [Recheck logs](M06_evidence/browser_recheck.json), [corrected outcome](M06_evidence/browser_outcome.png), [menu](M06_evidence/browser_menu.png).

## Godot MCP, browser and export

Discovered tools and confirmed toolkit ProjectKey root `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor`, matching the assigned filesystem root after macOS case normalization. No other connected project was mutated. Used supported scene open/tree, script diagnostics, native main launch/stop and scoped runtime inspection. Native startup reached the existing entry screen; release-browser journey supplies the end-to-end evidence.

Advanced refresh tools were discovered but not exposed as callable tools; used the toolkit editor plugin's supported filesystem scan/reload fallback. The cached arena tree initially showed the old scene; reloading the scene from disk exposed Reveal, ReceiptGate, current ResultSink and the creator animation hook. Expression-only probes cannot access global singletons directly; a toolkit ProjectKey call supplied root verification. No global clean-console claim: historical editor errors, host certificate/registry/editor-settings permissions and SDK `editor_script_saved` teardown diagnostics exist. Direct runner also reports inherited no-debugger SDK logging and sandbox runtime-port warnings; its example output has zero failures and exits 0. Both release export processes exited 0; the second follows the observed presentation fix, not a redundant export.

Final PCK: **118 files, 517,756 bytes**, SHA-256 `0406ce90093461aaad2271aeef5af6d89aaba442db79576d2abf7ad4b1a095d9`. New reveal scenes/tuning/scripts and path-loaded SDK dependencies are included. Pack inspection finds no shipped script assertions, private documents, tools, toolkit, source/unused artwork or credentials. Single-thread support=false, explicit `res://` SDK autoload and existing web guard preserved; preset unchanged. [Manifest](M06_PackManifest.txt).

Existing static server at **127.0.0.1:3000** reused. Fresh M06 filename and visible new reveal/menu behavior confirm the first build; the revised build is confirmed by its fresh URL and observed corrected outcome in the targeted recheck. SDK-bearing exports stay ignored and localhost-only. Public distribution remains unresolved. No generated export is committed.

## Creator checkpoint and exact launch

**Accepted on 2026-10-23.** Following the complete-local-loop checkpoint request, the creator reports the early functional version is satisfactory and appreciates its tactile feel: “It's as good as it's get for functional development”. No broken behavior or further M06 change was requested. The lack of art is intentional; the creator explicitly instructs **DO NOT create any art here**. No new artwork or gameplay/presentation change was made in response. This accepts the functional M06 checkpoint, not final authoring, Final Review, learning or a later checkpoint.

Native launch:

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor
/Applications/Godot.app/Contents/MacOS/Godot --editor --path .
```

Press **F5**, continue/name the local preview, leave **Scripted opponent found** selected, choose a labelled arena fixture and press **Play**. Play all four 15-second phases (final choice requires selection then confirmation). Open chat before the cinematic to see it close automatically. Watch the actual history narrative, gradual blackening, outcome and Tap To Continue; return to the refreshed menu. Browser alternative: [M06 localhost](http://localhost:3000/m06.html?build=m06-20261023-v2). Existing server is running; if stopped, start `python3 tools/serve_m01.py` once from the project. No backend server required.

The checkpoint requested feedback on suspense, narrative accuracy/clarity, pacing and outcome payoff. The creator gave the overall functional acceptance above; no separate per-category assessment is invented. Final artwork/choreography and future narrative presets remain authoring work; no specific additional M06 polish task was requested.

## Commit/checklist and M07 handoff

Required creator checkpoint is accepted. Feature commit: **`23d8316` — `feat(reveal): add acknowledged narrative result flow`**. Reviewed the explicit 30-file intended staged set, staged diffs and whitespace before committing. The supplemental text/evidence scan was rerun after a binary-diff decoding limitation; it does not replace the staged review. Only after the feature commit succeeded were slice 6 and the integrated local checkpoint checked. This report/checklist completion record is saved separately as `docs: record M06 completion and creator checkpoint`. Unrelated Finder metadata, sibling artwork, existing untracked planning documents, private profile, credentials and generated exports remain excluded.

No M07 implementation. No code changed after creator acceptance, so no runtime verification or export was repeated. Only M06 documentation/progress was updated after its feature commit; Final Review, learning wrap-up and later milestones remain unchecked. Handoff retains frozen result/receipt/provider seams and reservation cleanup; remaining authoring includes final outcome choreography, cinema art/audio, narrative presets and creator icons. Deferred delivery failures/duplicate/retry and later live/backend enforcement remain unverified for their assigned sessions.
