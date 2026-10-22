# M07 — Submenus I: statistics, records and leaderboard

Status: **partial — Git completion in progress**. Creator approved the rough functional Detailed Stats/Record composition for later backend integration and plans their own visual overhaul. Scoped verification is complete; slice 7 remains unchecked until the implementation commit succeeds. Fast mode; M07 only. No M08 implementation, new M06 acceptance, checkpoint completion or HUB audit.

## Scope and approved references

Assigned M07 and checklist slice 7; AI_Bootstrap universal constraints and project-local `5-build`; PRD Detailed Statistics and Records, Opponent Statistics and Saved Records, Leaderboard, Main Menu and Player Information, Look and Feel; spec Godot Presentation, Lifetime Statistics and Derived Percentages, Backend API, Data Model, Shared Scenes and Tuning Resources, Staged Development Providers. Private learner context read without copying it into evidence. M06 feature `23d8316` and completion record `64818b8` remain the accepted dependency.

## Changed files and why

- `scripts/api/profile_provider.gd`: asynchronous read seam for stats, records and leaderboard.
- `scripts/api/local_preview_provider.gd`, `preview_profile.gd`: session counters, acknowledged records, derived read snapshots and bounded pagination; Clear Data resets new session state.
- `scripts/app/main.gd`, `scenes/main.tscn`: replace the three temporary destinations with modal instances and query the existing provider. Quests stays outside M07.
- `scenes/ui/data_modal.tscn`, `detailed_stats.tscn`, `records.tscn`, `leaderboard.tscn`, `scripts/ui/data_modal.gd`: shared data-modal content with meaningful inherited variants, category selection, scrolling, loading/empty/error/retry, animated opening/closing/content and Back/Escape navigation. Original `modal_shell.tscn` and arena chat are unchanged.
- `scripts/resources/data_view_tuning.gd`, `resources/presentation/data_view_tuning.tres`: Inspector-owned fade, travel, easing, losing-card alpha, page size and modal insets.
- `scripts/development/leaderboard_roster.gd`, `resources/development/leaderboard_roster.tres`: explicit six-entry aggregate roster fixture, separate from personal history.
- `tools/m07_data_checks.gd`, script UID companions, this report, `M07_PackManifest.txt`, `M07_evidence/`, checklist Revisions: scoped verification and completion evidence. Evidence is protected with `.gdignore`.

## Provider/query/record contracts

Views await `request_stats()`, `request_records(cursor, limit)` and `request_leaderboard(metric, cursor, limit)`; they do not read arena nodes, award points or infer history from labels. Stats return provider-derived percentages, with `null` rendered as N/A. Queries return `{error: {code, message, retryable}}` on failure. Loading and retry presentation exist; deliberate failure injection is deferred.

Records return `{records, nextCursor}`. Leaderboard returns `{entries, nextCursor}`. Page size defaults to 3 and is bounded to 1–20 by the provider. Empty-string cursor starts/ends pagination; the development provider uses a decimal offset internally, opaque to views. Pages are detached copies. Leaderboard uses exactly `overallPoints`, `winRate`, `lieCount`, `honestCount`, sorts descending with deterministic player-ID ties and puts absent win rates after measured rates.

Each record snapshots `ownerId`, `resultId`, `matchId`, outcome, points and both actors' `actorId`, `displayName`, `initialCard`, `finalCard`, outcome. Both equal and different initial/final values are retained. Opponent identity comes from the frozen recipient display snapshot. Result shows both final cards using existing inherited card artwork, dimming only the losing final card; draws dim neither. The query returns only the current preview owner's records.

The existing acknowledged-result boundary still validates the matching simulated/nonpersisted receipt, rejects persistent/live credit, excludes ineligible/departed-before-commit/takeover owners and checks the once-only result-ID set **before** changing counters or adding a record. No resolver, frozen submission, receipt gate, sink or cinematic attribution policy changed. Opponent facts may appear in an eligible owner's record without creating personal credit for an excluded opponent.

For the eligible owner, application now retains initial/final card counts, final winning-card counts, total lying/honest match counts and switch count, alongside the existing points/W/L/D/streak/winning allegiance counters. It consumes structured frozen history/results, never UI text. Winning-card and winning-claim percentages divide by total wins; win rate divides by all credited matches, including draws. Two false claims count once. Streak: win increments, draw preserves, loss resets. Allegiance compares **winning** honest/deceptive counts, with nonzero ties hybrid and no wins human; total Lie/Honest counts do not control it.

No round history or aggregates are written to disk or uploaded. Only the existing preview name/identity file persists. New launches/reloads start empty session history; earlier unretained rounds are unavailable, not reconstructed. Clear Data discards profile counters, credited IDs, records and modal content in addition to the existing owned local file; no backend mutation. Static roster fixtures remain fixtures.

## Development fixtures versus actual preview data

The six `.tres` roster entries (Velvet, Cinder, Ivory, Echo, Onyx, Lumen) are synthetic development aggregates representing future roster participants, not a bot roster service, actual global standings or real human accounts. UI says “Development preview • session + sample roster”; individual entries preserve the absence of player-facing bot labels.

The controlled four-submission dataset is isolated in the verification tool and native observation, never loaded as normal personal history. It uses simulated acknowledgements and a scripted opponent named Velvet. Normal launch contains zero personal records; only newly acknowledged eligible preview rounds populate them. The release smoke also completed one ordinary idle/default round against the existing scripted/local-policy Velvet opponent. This actual session result was a loss: Scissor→Scissor against Rock→Rock, honest, zero points. Its simulated acknowledgement added one real preview-session record; it is distinct from the four controlled examples. No real multiplayer, backend persistence or live standings were verified.

## Mechanical verification

Environment: 2026-10-23 Asia/Jakarta; Godot **4.7.stable.official.5b4e0cb0f**, GD-Sync **1.0.2**, MCP toolkit **1.0.0**; native portrait viewport 540×960. Release browser: Codex in-app Chromium **155.0.0.0**, 625×827 capture with portrait canvas. This is basic M07 evidence, not a broad regression or HUB audit.

- All seven changed/new game scripts and the small verification script passed focused MCP `script_check`, empty diagnostics. Records' inherited scene tree was inspected through MCP (shell, header, category, status, scroll, More/Retry). Shared chat source and base scene remain untouched.
- Four controlled frozen submissions: honest Rock→Paper win; two-false-claims Scissor→Scissor win; honest Rock draw; honest Rock loss. Result: 4 matches, 2 W / 1 L / 1 D, 33 points, 50% win rate; winning Rock 0%, Paper 50%, Scissor 50%; winning lie/honest 50/50; Lie Count 1, Honest Count 3; hybrid allegiance. Draw preserved streak 2; later loss reset it to 0. No-history percentages were null/N/A and allegiance Human. Runner exited 0 with zero check failures. [Data evidence](M07_evidence/data_checks.json).
- Native menu buttons opened/closed all three views with completed motion. Controlled displayed stats matched 50%/0/hybrid. Record wheel scrolling moved to 211; records paginated 3+1, More hidden at end. Loss showed dim Rock versus normal Paper; draw final-card visual alphas were `[1, 1]`. Both actors' initial/final values remained separate.
- Native leaderboard switched all four categories and followed page 2 in each: totals 3→6, next cursor `6`; Honest Count also followed page 3 to total 7 and hid More. First entries: local controlled 33 points, Cinder 75% win rate, Onyx 4 lies, Ivory 4 honest. [Native observations](M07_evidence/native_observations.json).

- Release smoke (v2) opened/closed all three views, switched all four categories, loaded another leaderboard page and completed one ordinary idle/default round against scripted/local-policy Velvet. Simulated acknowledgement was applied once: honest loss, +0 points, Scissor→Scissor versus Rock→Rock. The Record view displayed the separate initial values and final pair, dimming only own Scissor. Stats then showed 1 match, 0 W / 1 L / 0 D, 0% win rate, streak 0, Human, Lie Count 0 / Honest Count 1 and N/A winning percentages. [Record](M07_evidence/browser_record.png), [statistics](M07_evidence/browser_stats.png), [smoke log](M07_evidence/browser_smoke.json).
- Some v2 captures omitted the focused Back button until focus changed, although clicks closed the view and packaged node state was normal. A focused deferred redraw corrected the initial Stats observation but did not fully resolve the Leaderboard capture in v4. Runtime header rect remained `(405,78;105,79)`, scale `(1,1)`, visible true, alpha 1. Removing automatic focus in v5 corrected ordinary opening, but the Back caption still disappeared after pagination. The final v6 correction renders the caption as an independent child Label while the inherited Button keeps input/style/press motion; the final browser recheck confirms visible Back text on opening and after loading page 2, with ordinary Back return completing. Semantic data code did not change, so the ordinary timed round was not replayed. [Final affected header/navigation evidence](M07_evidence/browser_header_fix.json) and [capture](M07_evidence/browser_header_fix.png) are recorded separately.

## Godot MCP and export limitations

Discovered Godot tools and verified toolkit ProjectKey root `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor`, exactly matching the assignment after macOS case normalization. Used supported script checks, scene open/tree, main play/stop, scoped expressions/input and native screenshots. No other connected project was mutated. Direct singleton expressions are unsupported; toolkit ProjectKey supplied root verification. Advanced refresh was not needed; scene open and ordinary game launch loaded the new files.

First release-browser inspection exposed Godot 4.7 binary export dropping inherited Control offsets at each inheritance layer; a focused packaged-scene inspection confirmed it. Data-modal runtime now reapplies Resource-owned insets, preserving the shared/inherited scenes and original chat. The second export follows that fix. Browser inspection confirmed restored margins and readable portrait content; the additional focus-rendering discrepancy is tracked in the focused header recheck. This fallback is confined to the M07 modals.

The first five release exports exited 0 (initial build, inset correction, header diagnostic, redraw attempt, automatic-focus correction). The sixth export also exited 0 and confines the caption-rendering fallback to the existing Back button. Host certificate/registry/editor-settings permission diagnostics and inherited SDK `editor_script_saved` teardown diagnostics occur in tooling; this is not a global clean-editor claim. The direct runner first hit the sandbox's unwritable default log path; a `/tmp` log file resolved startup. Inherited no-debugger SDK logger and sandbox runtime-port/registry teardown messages remain; the scoped runner exits 0. The initial runner setup was corrected to supply `current_scene` before rerunning its four examples.

Single-thread support remains false; explicit `res://` SDK autoload, existing SDK web guard and filtered export preset are preserved. Pack inspection finds all data scenes, `.tres` resources, reused card/modal/button art and required path-loaded scripts; no shipped assertions, private documents, tools, toolkit, unused/source artwork or credentials. No state changes depend on assert expressions. [Pack manifest](M07_PackManifest.txt): **133 files, 543,632 bytes**, SHA-256 `9dd7bec3409c432a8a427ed4f6554acf82f0f8a47380eef4b3317fdb5f3b59af`. Localhost-served PCK hash matched that exact local export. SDK-bearing outputs stay ignored and localhost-only; public distribution remains unresolved.

## Creator layout, feedback, launch and completion

Creator approved the proposed rough functional composition: inherited animated modal, title/Back, scrolling statistics or record cards, and More for records. Actual feedback: the current version is fine for later backend integration; the creator will overhaul its visuals later. This resolves the essential layout input and accepts the functional composition, not final visual design or a claim that the creator ran every try-out step. M07 is not a planned fast-mode hands-on checkpoint; none is marked performed.

No art was created. Reused existing `Graphics/Simple Shapes/Rounded-Rect.png`, `card_base.tscn`/`reveal_card.tscn`, menu buttons and the existing modal shell. Menu continues to identify its existing `Graphics/TemporaryAllegiance.svg` as temporary. Final human-head/hybrid icon paths have not been supplied/confirmed; no final icon is assumed. Final layout, art and presentation polish remain creator-owned.

Native launch:

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor
/Applications/Godot.app/Contents/MacOS/Godot --editor --path .
```

Press **F5**, continue/name the preview, then open **Detailed Stats**, **Record**, **Leaderboard** from the menu. For personal records, complete ordinary preview rounds in the same session; reloading clears them. Browser: [M07 localhost](http://localhost:3000/m07.html?build=m07-20261023-v6). Existing localhost server is reused; if stopped, run `python3 tools/serve_m01.py` from the project, then open that URL. No backend server is required.

Short creator try-out: open each view and return with Back; inspect both initial and final values, final-card dimming and scrolling; switch all four leaderboard categories and press More. Assess whether the information is clear without excessive text. The functional composition is approved; further visual overhaul remains creator-owned.

Reviewing the explicit intended source/document/evidence set and staged diff before the planned feature commit. See `M07_evidence/change_review.json`.

The essential layout input is resolved. The planned `feat(submenus): add stats records and leaderboards` implementation commit follows staged review; only after it succeeds will slice 7 be checked in a separate completion record. M06/checkpoint evidence, later slices, Final Review and learning wrap-up are unchanged. Unrelated Finder metadata, sibling artwork and pre-existing untracked planning documents remain outside this change; learner profile/credentials remain ignored and untracked.

## Deferred checks and M08 handoff

No full suite, broad regression, stress/race, malformed input, deliberate service/query failures, duplicate receipt/attribution/disconnect injection, browser/device matrix, full cinematic branches or randomized 30–45-second search wait. Loading/failure UI is implemented; deliberate failure behavior is unverified, never passed. No full M01–M06 verification suites. Future live/backend providers must replace these session/roster fixtures without uploading their history.

Stop at M07. M08 remains unstarted. Preserve the provider read/acknowledgement seams, shared modal family, session-only preview boundary and once-only credit when a separately assigned quest milestone begins. No quest catalogue, progression, reward grants, networking integration, HTTP API or production roster was added here.
