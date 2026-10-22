# M02 — Play and simulated matchmaking with live-shaped behavior

Status: complete for the assigned M02 scope and creator-authorized basic verification. Feature committed; slice 2 checked. Creator feedback and final authoring remain pending and are not claimed complete.

## Scope and approved references

Only M02/checklist slice 2 was implemented, continuing the recorded fast mode after M01 commits `2b773ac` and `8a66489`. Read AI_Bootstrap, Milestones (universal rules, adapters, completion protocol and M02), checklist, M01 report/evidence, scope, the assigned PRD/spec sections and the local `5-build` skill. Private learning context was read without reproducing personal reflections. The 12-milestone order was preserved. No other chat, subagent or M03 implementation was created.

Delivered animated menu/search/leave flow, a small MatchSession contract, explicit scripted development fixtures, a single reservation, randomized normal fallback and a minimal match-ready destination. No arena rules, bot decisions, chat, backend requests, account saves, result storage or competitive credit were introduced.

## Changed files and why

- `scenes/main.tscn`, `scripts/app/main.gd`: replace Play's temporary M02 feedback with animated navigation, snapshot the existing preview profile and expose a labelled development fixture selector. Existing menu, preview provider and actual connection status remain in place.
- `scenes/matchmaking.tscn`, `scripts/app/matchmaking.gd`: search title, animated dots, leave control, animated found/failure presentation and match-ready destination with development return. `ready_count` is a runtime observation counter across the session, not a saved result counter.
- `scenes/ui/card_base.tscn`, inherited `search_card.tscn`, `scripts/app/search_card.gd`: meaningful shared card art/structure with search-specific motion and a creator AnimationPlayer hook. Uses existing Rounded-Rect.png and the M01 permitted MCP icon copy; no artwork was generated. The base uses fixed local card dimensions and a CenterContainer for the emblem, preserving layout in the nested compiled export.
- `scripts/matchmaking/match_session.gd`, `match_context.gd`, `match_participant.gd`: lifecycle, reservation and typed handoff snapshots. Script `.uid` companions are included.
- `scripts/development/scripted_match_session.gd`, `search_fixture.gd`, `resources/development/search_fixture.tres`: isolated development-only found, ordinary cancellation, normal timeout and failure support. No GD-Sync matchmaking calls.
- `scripts/resources/matchmaking_settings.gd`, `resources/matchmaking/search_settings.tres`: configured 30–45-second fallback bounds and explicitly unset production rating-policy fields.
- `scripts/resources/search_motion.gd`, `resources/presentation/search_motion.tres`: Inspector-editable dots, bob, fade durations, displacement, tween transition and easing.
- `devpost/checklist.md`: slice 2's mechanical wording and Revisions record the creator-authorized testing reduction, fast mode and pending authoring/feedback. Completion checkbox is updated only after the feature commit succeeds.
- This report, `M02_PackManifest.txt`, `M02_evidence/`: actual observations, screenshots and sanitized events. `.gdignore` prevents evidence media importing as game artwork. Generated exports, credentials and unrelated files are excluded from commits.

## Architecture/interface changes and deviations

`MatchSession extends Node` offers `begin(player) -> generation`, `cancel()`, `is_current(token)`, `commit_found(token, context)`, `report_failure(token, detail)` and identity-checked `release_match(match_id)`. Events are `began(generation)`, `cancelled(generation)`, `found(context)` and `failed(generation, detail)`.

Only one search may be active. Begin refuses while searching or holding a reservation. Cancellation increments the generation and clears search ownership before emitting its event or starting UI motion. Timer callbacks first require a current token, active search and empty reservation. A found context must carry that generation; reservation is assigned synchronously before `found` emits. A duplicate/obsolete callback therefore has no commit path in the inspected code. Failure invalidates the generation. Returning from the development destination releases only its matching reservation. These safeguards were inspected, but the deferred race/injection cases were not tested.

`MatchContext` carries `match_id`, `search_generation`, typed local/opponent `MatchParticipant` snapshots, `transport`, `development_only` and `persistent_credit_allowed`. Participants carry `player_id`, `display_name`, `overall_points`, `rating_source`, `backend_verified`, `peer_id` and `control_kind`. Overall Points is the approved eventual saved rating. Current local/opponent values are preview data; peer IDs remain -1 and backend verification false. No phase/rule/message transport implementation is implied.

`matchmaking.gd` retains `ready_context` and emits `match_ready(context)` once its destination transition completes; the session has already committed the reservation. M03 can consume that context and replace the minimal destination. Presentation completion does not determine match authority or a search deadline. No arena gameplay exists.

The development selector maps to found, normal timeout or failure; leave works during a normal search. Fixture found/failure delays are 4/3 seconds, stored in the development resource. Normal timeout always uses the production-shaped bounds resource, sampled with `randf_range(30, 45)` on each begin, with release-visible bounds validation outside assertions. No accelerated timeout fixture substitutes for it.

Production allowed gap, maximum gap and widening fields remain -1 with `rating_policy_configured=false`. The development adapter does not enforce ranking and these values are not adopted production tuning. No essential tuning decision was invented to run fixtures.

## Development fixtures versus actual services/players

Velvet (`fixture-opponent`) is a scripted opponent, not a verified human peer. Ember (`fixture-bot`) is a development fallback identity, not a fetched bot leaderboard entry or completed bot gameplay. Both fixture ratings are 0 and explicitly development-only. Contexts use random `dev-` match IDs, `transport=scripted_development`, `development_only=true`, `persistent_credit_allowed=false` and internal control kinds distinguishing scripted opponent from development bot. Search/player-facing opponent presentation has no bot label; evidence states the actual kind.

The existing GD-Sync connection remains independent of profile/search identity. Its existing indicator appeared during ordinary use; M01's SDK connectivity proof was not rerun as an independent test. No queue/lobby/peer, server authentication, MongoDB, HTTP API or GD-Sync account save was exercised. M09 must replace the scripted adapter and await real queue cancellation/leave confirmation before committing bot fallback; no such queue exists here. Preview history is not uploaded.

## Mechanical verification

Date: 2026-10-22, Asia/Jakarta. Environment: macOS 26.3.1 on Apple M2; Godot `4.7.stable.official.5b4e0cb0f`; installed 4.7 single-threaded release template; GD-Sync package 1.0.2 with the unchanged M01 web guard; MCP toolkit 1.0.0. Browser: Codex in-app Chromium, recorded UA Chrome/155.0.0.0. No device/browser matrix is claimed.

| Authorized action | Observed result and evidence |
| --- | --- |
| Focused changed-script diagnostics and scene inspection | MCP `script_check` returned valid/empty diagnostics for all 10 changed/new scripts after filesystem registration completed. Inspected the M02 scene tree including Session, Dots, Search, inherited card/AnimationPlayer and Destination. Initial checks during class indexing could not resolve the new classes; after scan completed, they passed. |
| Normal menu → search → leave → menu | Native generation 1 entered the animated search and left ordinarily, well before found. Logs record invalidation before return and completed menu transition. No arrival race was attempted. |
| Normal scripted found | Native generation 3 reserved `scripted_opponent` after 4.017s and completed one handoff with `ready_count=1`; inspected the retained context kind. Destination showed Velvet and a development-only return. |
| One full normal unsuccessful search | Native generation 5 sampled **40.8552755718554s** from the unchanged 30–45 bounds. Reserved `development_bot` after **40.867s** and completed the destination transition. `ready_count=2` represents the second separate match, after explicitly releasing the first. No time acceleration or bot gameplay. |
| Single-threaded release browser | Observed search, animated dots/card, ordinary leave/menu return, found destination/return and completion logs. Fixed a nested exported card layout defect found by this check, then repeated only affected presentation/navigation. Final screenshot includes the backing and centered emblem. Final captured browser interval contains no warnings/errors. |
| Focused export/assertion review | Actual final PCK directory inspected: 62 entries, 403,572 bytes; SHA-256 `7e63ba7ff2c675db29130b94a432bcf8fad71d9f6388daa59c4dd3f45c5ec64a`. Required compiled scenes/resources and runtime scripts are present. No shipped script contains an assertion. No required operations are hidden inside assert expressions. |

Evidence: [native events](M02_evidence/native_events.json), [native search](M02_evidence/m02_native_search.png), [native found](M02_evidence/m02_native_found.png), [native timeout destination](M02_evidence/m02_native_timeout.png), [final browser search](M02_evidence/browser_search.jpg), [browser found](M02_evidence/browser_found.jpg), [browser events](M02_evidence/browser_events.json), [actual pack manifest](M02_PackManifest.txt).

### Explicitly deferred checks

The creator explicitly limited this assignment to basic M02 verification, overriding the original milestone's broader test plan. **No full suite, broad regression, stress testing, cancellation-at-arrival race, duplicate/late-callback injection, deliberate failure, malformed input, disconnect injection or browser/device matrix was performed.** The implemented scripted failure path, failure recovery, obsolete/duplicate-event rejection under races, rapid navigation and invalid configuration handling remain unverified. They are deferred to the creator's dedicated later session, never marked passed. M01's full checks were not rerun.

## Learner check / checkpoint

Fast mode remains selected. M02 is not one of the checklist's planned hands-on checkpoint boundaries (M01/M06/M09/M12). The M02 creator try-out below is provided; **no M02 feedback has been received and no unperformed checkpoint is checked**. M01's accepted feedback is not reused as M02 acceptance. Final matchmaking choreography/rating tuning remains creator-owned.

Exact browser launch, from the project directory:

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor
python3 tools/serve_m01.py
```

The existing localhost-only static server was reused and is already serving [http://localhost:3000/](http://localhost:3000/); do not start a second server on that port. Open/reload that address, continue from the remembered local preview name (or enter a trimmed nonempty preview name if this browser has none).

1. Select **Normal timeout (30–45 seconds)** in the labelled fixture selector. Tap **Play**, observe the search, then **Leave search** and confirm the menu returns.
2. Select **Scripted opponent found**, tap **Play**, wait about four seconds and inspect the minimal match-ready destination. Use its development return.
3. Select **Normal timeout (30–45 seconds)** again, tap **Play** and allow the full wait. It reaches the same handoff using the development bot context.
4. Assess whether the flow, dots, temporary card motion and fades match the intended direction. Final card choreography can now be authored in `scenes/ui/search_card.tscn > CreatorAnimation`: add a looping animation named `search` targeting `../Visual` or its children. That animation replaces the temporary bob automatically; do not use it to choose match results or timing. Motion/fallback/fixture settings are the `.tres` files listed above.

Native alternative: `/Applications/Godot.app/Contents/MacOS/Godot --editor --path .`, then F5. This starts the same main scene; no M03 scene is needed. Report actual feedback when received; do not infer acceptance.

## Godot MCP operations and limitations

Discovered the `godot_rock_paper_scissor` tools. Before mutations, confirmed the actual connected root through the toolkit's ProjectPaths/ProjectKey helper as `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor`, the exact case-normalized project path. No other connected project was mutated.

Used supported scene open/tree inspection, editor resource filesystem scan/scene reload through the existing EditorPlugin, focused script checks, game start, runtime readiness polling, input simulation, screenshots, runtime property reads and game logs. Expression access to globals/constants required addressing the actual MCPServer node and its script constant map; early attempts were rejected without mutations. Discovery advertised editor-refresh/idle/runtime-inspection groups but their dedicated callables were unavailable in this tool session. The supported expression and screenshot/log tools covered the assigned work.

Initial playtest readiness timed out; the documented `game_start(if_running=return, runtime_poll=true)` follow-up connected. The editor initially retained an old main-scene version; running it exposed a missing Matchmaking node. Reapplied the intended scene change and explicitly reloaded it before the successful native checks. That startup failure is not reported as a deliberate failure-scenario test.

Exported nested card inspection showed the backing at zero size despite the base scene's correct size. Fixed local dimensions and a CenterContainer remove dependence on lost nested anchors/position offsets. An isolated read-only pack inspection helper confirmed the backing size after repair; its standalone harness produced MCP-runtime/autoload diagnostics because it was outside the normal game lifecycle, and its first invocation could not open the default user log. These are inspection-tool limitations, not clean game-runtime checks. No helper was added to the game or commit.

## Web/export checks and limitations

Export command: `/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release Web ../backend/public/index.html`. Final export returned exit 0. Reused `tools/inspect_m01_pack.py` for actual PCK directory/assertion inspection; its filename is historical, its inspected package is the current M02 export.

The preset is unchanged: selected main scene with transitive M02 scenes and `.tres`, explicit runtime script includes (including existing path-loaded SDK scripts), single-threaded, no extensions/PWA. HTML contains `GODOT_THREADS_ENABLED = false`. Only the required existing textures, M02 fixtures and game/SDK dependencies ship; no toolkit, docs, learner profile, source/unused artwork or future scenes. No new path-loaded game dependency was introduced. Inspecting the manifest confirms the required development adapter/resource is present intentionally for this staged build.

Headless export still reports host certificate/editor-settings/registry permission/port warnings and the existing SDK editor teardown `editor_script_saved` signal error, as in M01. No client/SDK source was altered to hide them. Initial evidence screenshots had JPEG bytes under PNG filenames; corrected their extensions and excluded evidence imports with `.gdignore`. Final export has no evidence-image import error. These exporter host/tool diagnostics are not described as a clean editor log.

The SDK still embeds connection configuration in the exported PCK. **Localhost-only** workflow and ignored generated files are preserved; no public hosting/upload/distribution occurred. Configuration values are absent from the intended commit and evidence. No browser/device compatibility beyond the recorded Chromium smoke was re-proven.

## Commits and checklist slice update

Feature commit: `2425b35` — `feat(matchmaking): add cancellable simulated search flow`. Reviewed the exact 39-file staged set and source/resource/scene diff; whitespace checks and a local credential-string scan passed. Only explicit M02 source/resource/scene/evidence/report files and checklist revisions were committed. After the feature commit succeeded, only slice 2 was checked, under the authorized mechanical-verification reduction; fast mode has no planned M02 hands-on checkpoint. Other slices and hands-on checkpoint boxes remain untouched. This report/checklist completion record is saved separately as `docs: record M02 completion and verification limits`.

Pre-existing `.DS_Store` changes, sibling backend image/metadata, untracked planning documents and M01 evidence imports are preserved and excluded. The learner profile, local GD-Sync keys and generated credential-bearing exports remain ignored/untracked. No blanket staging is used.

## Unresolved issues and creator inputs

- Creator try-out feedback is pending. Final card animation belongs to the creator via the supplied hook; temporary bob is not final choreography.
- Production rating gap, maximum and widening values remain unset creator-controlled `.tres` inputs. Current fixture identity/rating must be replaced in the assigned integration milestones.
- Failure/race/error/device checks remain explicitly deferred. Ordinary scoped native/browser flows passed after the export presentation repair.

## M03 handoff notes

Stop at M02. M03, when separately assigned, can consume `match_ready(context)`/`ready_context` and replace the minimal destination with its arena intro/initial-choice flow. Preserve one active generation/reservation and release ownership only when leaving the context. Do not save these development contexts as competitive history. Preserve M01's preview identity versus actual SDK status distinction, explicit `res://` autoload path, web unique-ID guard, filtered single-threaded export and localhost-only credential-bearing preview. M09 must implement real queue/leave acknowledgement before bot fallback; current callbacks do not prove human multiplayer.
