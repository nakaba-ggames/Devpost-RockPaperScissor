# M01 — Rough main menu and real GD-Sync connection

Status: **verification and creator review accepted; commit pending** — implementation and scoped mechanical checks passed. On 2026-10-22 the creator answered the complete hands-on check: “Yes, it works perfectly”. Slice 1 and the early M01 checkpoint will be checked after the implementation commit succeeds. M02 has not been started.

## Scope and approved references

Executed only M01 from `docs/Milestones.md` and checklist slice 1. Read `docs/AI_Bootstrap.md`, the universal/workflow/development-adapter requirements and full M01 brief, `devpost/scope.md`, PRD **Opening and Anonymous Entry**, **Main Menu and Player Information**, **Screens and Layout**, **Look and Feel**, and spec **Godot Presentation**, **Shared Scenes and Tuning Resources**, **HTTP API Client**, **GD-Sync Integration**, **Service Selection and Version Policy**, **Where It Runs and How Someone Tries It**, **Anonymous Identity and Credentials**, **Staged Development Providers**. Applied the local `5-build` skill. Private learning context was read but is not reproduced here.

The creator explicitly selected **fast mode** and stated there are no strict preview naming rules. This preview trims names and requires a nonempty name; no production naming policy was invented. The creator requested any extra adjustment after trying this initial result.

## Changed files and why

- `project.godot`: main scene, 540 × 960 portrait canvas, 432 × 768 native preview, keep-aspect stretch, dark background, enabled GD-Sync and runtime autoload. The autoload uses an explicit `res://` path because its editor-generated UID failed in the first filtered browser package. Godot's settings save removed an obsolete MCP status message; MCP remains enabled for development.
- `scenes/main.tscn`, `scripts/app/main.gd`: entry, local naming, continue, required menu layout, animated temporary feedback, local reset, honest service/profile labels and error presentation. Play and the four side buttons do not open future features.
- `scenes/ui/menu_button.tscn`, inherited `primary_button.tscn`, `scripts/app/menu_button.gd`: shared button structure and animated press/release. No later card/modal families were prebuilt.
- `scripts/resources/ui_motion.gd`, `resources/presentation/menu_motion.tres`: Inspector-editable startup delay, fade/press/release durations, feedback dwell/offset, scale and tween easing. Temporary opening fades leave the creator's final choreography reserved.
- `scripts/api/profile_provider.gd`, `preview_profile.gd`, `local_preview_provider.gd`: small asynchronous identity/menu-data seam, typed zero-history preview profile, and explicitly local development implementation. No HTTP API/backend or GD-Sync account/save system was added. Script `.uid` files accompany source scripts.
- `Graphics/TemporaryAllegiance.svg` and its import settings: unchanged copy of the expressly permitted MCP icon. Copying it out of the toolkit folder lets the exporter strip the entire toolkit while retaining the visible temporary art. Button artwork is the existing `Graphics/Simple Shapes/Rounded-Rect.png`; no placeholder artwork was generated.
- Existing `addons/GD-Sync/`: enabled the inspected 1.0.2 candidate. Source originally matched all 118 files in the [official release revision](https://github.com/GD-Sync/GD-Sync/tree/620e45281f2ee4b96c701cf232f97aad30e43d2a/addons/GD-Sync). One narrow compatibility patch in `Scripts/RequestProcessor.gd` guards an unsupported web `OS.get_unique_id()` call. Native behavior and the existing empty web handshake value are preserved. No blind replacement/upgrade was performed.
- `export_presets.cfg`: release Web preset; threads/extensions/PWA disabled; selected M01 scene plus explicit runtime script dependencies, including path-loaded SDK scripts. Excludes documentation, source art, toolkit and editor SDK UI.
- `tools/serve_m01.py`: localhost-only static preview, no backend routes. Its Python server threads are host tooling, not game-client threads. `tools/inspect_m01_pack.py`: focused PCK directory/assertion inspection that never prints credential contents.
- `.gitignore`, sibling `backend/.gitignore`: protect local keys, generated export, private learner context and editor/system content. Existing unrelated backend files are preserved.
- `devpost/checklist.md`: records mode, preview naming agreement and the creator-directed testing limitation under Revisions. No progress box was checked.
- This report, `M01_PackManifest.txt`, `M01_SDK_Provenance.json` and `M01_evidence/`: inspectable evidence. Generated release files are in sibling `backend/public/`, ignored and not intended for Git.

## Architecture/interface changes and deviations

`ProfileProvider` exposes `begin_session`, `save_display_name`, `enter_menu`, `clear_local_data` and typed identity/menu/error/reset signals. M10/M12 can replace the local provider without presenting preview data as server-authenticated history. It is a small seam, not an HTTP client implementation or future injection framework. No server endpoint, custom authentication, matchmaking, game round, chat, bot, functional submenu or progression exists.

The local profile starts with zero points, zero streak and no history, so Win Ratio is N/A. The daily-quest position states that the feature is unavailable. The allegiance icon is explicitly temporary; final human-head/hybrid/devil/angel assets were not identified in the inspected Graphics filenames. No claim is made that allegiance variants or nonzero statistics have been exercised.

Two real browser findings were repaired: (1) the autoload UID could not resolve in the filtered package, corrected to its actual resource path; (2) the SDK emitted the unsupported web OS unique-ID error despite successfully connecting, corrected with a web guard. A native layout overflow was also reduced. Only affected M01 checks were repeated.

## Development fixtures versus real services/players

Preview identity and display name live only in `user://devils_rps_preview_v1.cfg`. A random `preview-` identifier is local fixture identity, not an anonymous backend credential. The zero-history menu profile is local development data; it is not downloaded from MongoDB or GD-Sync. No preview history is uploaded.

GD-Sync **actually connected** in native editor execution and in the single-threaded release browser. `ServiceConnection` subscribes to SDK `connected`, `connection_failed`, and `disconnected`; only `connected` sets the connected display and increments the signal count. Logs explicitly identify receipt of the actual SDK signal. Failure/disconnect presentation and an explicit retry are implemented, but deliberate failure injection was not performed. No actual service failure signal occurred in this scoped session. SDK-unavailable display was naturally observed during the first export-reference failure.

This is service/networking evidence only. No lobby, human peer, multiplayer game, backend account authentication or server persistence has been proven. The account's enforced quota/tier and service-side software version were not independently inspected; no paid plan was selected.

## Mechanical verification

Date: 2026-10-22, Asia/Jakarta (UTC+7). Evidence JSON uses its original UTC timestamps.

Environment:

- macOS 26.3.1, build 25D2128.
- Executable `/Applications/Godot.app/Contents/MacOS/Godot`: `4.7.stable.official.5b4e0cb0f`; engine full commit observed: `5b4e0cb0fd279832bbdd69fed5354d4e5ad26f88`.
- Export templates: installed `4.7.stable`, single-threaded release template; exported HTML explicitly contains `GODOT_THREADS_ENABLED = false`.
- GD-Sync 1.0.2, official release revision `620e45281f2ee4b96c701cf232f97aad30e43d2a`, plus the documented single-file web guard. MCP toolkit declares 1.0.0.
- Browser: Codex in-app Chromium. Runtime user agent reports `Chrome/155.0.0.0`, AppleWebKit/537.36; a more precise Chromium patch number is not exposed by the recorded evidence. This UA's compatibility OS string is not the host OS version.

| Action | Observed result / evidence |
| --- | --- |
| MCP scene inspection and focused checks of all seven new scripts | Main scene tree inspected; `script_check` returned valid with empty diagnostics for each changed game script. The patched SDK RequestProcessor also passed. No editor errors were reported at the initial game check. |
| Normal editor entry/menu | Entered `Editor Preview`, saved name, continued; real SDK connected signal logged, expected center/side layout inspected in runtime screenshots. Five destination feedback callbacks observed. Temporary transition finished and `changing_screen` read false. The found overflow was repaired and the corrected portrait layout observed. |
| Release-browser normal entry/menu | Named local preview, continued, inspected portrait layout, pressed Play and all four side buttons; temporary feedback appeared and all five events logged. Menu transition-completed event observed. Final repaired runtime produced no browser console errors in the checked interval. |
| One ordinary identity reload | Returned to `Welcome, B` and continue without naming again. Continued to the same zero-history menu. The final smoke name is B: automation's bulk typing routed remaining characters into a browser input proxy, so the actually saved name is reported rather than claiming the requested test string was saved. No malformed-input session was run. |
| One ordinary Clear Data | Deleted the single owned preview file, returned through pending to the first-entry naming prompt with blank input. Actual SDK remained connected. Source inspection confirms exactly one file-removal path and no HTTP/account mutation call. Local static-server requests did not show an API mutation. There is no backend, so backend-profile preservation was not empirically tested. |
| Export content and assertions | Parsed the actual PCK directory and shipped script text. 41 entries; 379,732 bytes; SHA-256 `32b4b9c5f709a5ba89b8f45e4f8f39dcde7d8beea04ee76badbaa42e041ba95f`. No toolkit code, docs, learner profile, unused/source art, editor UI, or future scenes. No assertions in shipped scripts. The SDK source's PropertySynchronizer assertion is a pure null check in an unshipped type; no required state change is inside an assertion. |

Evidence:

- [Browser menu](M01_evidence/browser_menu.png)
- [Ordinary reload](M01_evidence/browser_reload.png)
- [Clear Data returns to naming](M01_evidence/browser_clear_data.png)
- [Actual browser event log](M01_evidence/browser_events.json)
- [PCK directory and assertion findings](M01_PackManifest.txt)
- [SDK provenance and patch](M01_SDK_Provenance.json)

The creator explicitly limited this assignment to basic M01 verification. **No full suite, broad regression, stress/race testing, malformed-input checks, deliberate disconnect/failure/timeout injection, or browser/device matrix was performed.** Safari, Android Chrome and iOS Safari remain untested. Failure/retry behavior, rapid navigation/reset, unusual names/storage failures, mobile keyboards and other edge checks are deferred to a dedicated later session. No deferred check is marked passed.

## Learner check / checkpoint

**Creator feedback received on 2026-10-22:** “Yes, it works perfectly”. This was the direct answer to the complete hands-on prompt covering entry/menu, Play plus Leaderboard/Record/Detailed Stats/Quests, portrait readability/basic motion, the real GD-Sync connection indicator and local-only Clear Data at `http://localhost:3000/`. No adjustment was requested. This completes the required early M01 creator check in fast mode; it does not complete later review checkpoints or deferred edge checks.

Actual creator input so far: fast mode; no strict preview naming rules; existing GD-Sync account access supplied locally; explicit approval for localhost-only serving after disclosure that the official SDK export embeds both connection keys. The creator reiterated smoke/connectivity scope and asked about editor tests; they were told that editor connectivity had already worked and M01 additionally needs its specific web transport/single-threaded proof. The subsequent hands-on reply above accepts the M01 result.

## Godot MCP operations and limitations

Discovered the `godot_rock_paper_scissor` tools and confirmed the **actual connected project root** through its existing MCP server's ProjectPaths/ProjectKey helper: `/users/karinauval/godot-projects/devpost-madewithai-jam/devpost-rockpaperscissor/rock-paper-scissor` (canonical macOS case-normalized path). Confirmation preceded project mutations. No other connected project was mutated.

Used editor plugin enablement, project settings, autoload registration, resource assignment/save, scene open/tree inspection, focused script diagnostics, game start/stop, normal input simulation, screenshots, runtime variable observation and logs. On-demand discovery advertised editor refresh and LSP groups, but their callables were not exposed in this tool session. Used the supported editor expression tool to invoke the existing resource filesystem scan, and the exposed `script_check` tool for diagnostics. One playtest launch readiness response timed out; subsequent input and screenshot calls reached the running game normally.

Command-line export succeeded and produced runnable artifacts, but sandbox restrictions caused host certificate/editor-settings/registry-write diagnostics. The SDK's editor teardown also reports a nonexistent `editor_script_saved` signal on Godot 4.7; this is an editor shutdown limitation, not an error observed in the final release game. The SDK editor-only code has not been refactored to conceal it. An initial isolated pack helper could not create its default user log directory; final content inspection uses a read-only Python PCK parser instead. These host/editor diagnostics are not described as clean checks.

## Web/export checks and limitations

Build command, from the Godot project folder:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --export-release Web ../backend/public/index.html
python3 tools/inspect_m01_pack.py
python3 tools/serve_m01.py
```

Then open [http://localhost:3000/](http://localhost:3000/). The static server binds only 127.0.0.1 and is currently running for the checkpoint. Ctrl+C stops it. It serves the prepared sibling `backend/public/`; it does not implement the future `npm run dev`/Vercel API. No Vercel/public deployment occurred.

The PCK includes the SDK controllers instantiated at startup, the required typed MatchmakingRequest and path-loaded NodeInstantiator scripts, game scripts, compiled scenes/motion resource and two actually used textures plus the project icon. Unused SDK synchronization/voice/art/editor types are excluded. The imported/compiled `.godot` entries in the PCK are runtime resources, not the project's editor cache directory. PWA is disabled; no game service-worker cache or origin-wide cache deletion is introduced. Clear Data removes owned profile data, not unrelated origin storage or ordinary browser HTTP asset caches.

**SDK configuration exposure:** the official exporter injects `addons/GD-Sync/keys.cfg`, containing both SDK connection keys, into the PCK. One is vendor-labelled private; it must not be mistaken for a server-only backend secret. Automatic approval review initially rejected localhost serving for this exposure. The creator explicitly approved localhost-only smoke/checkpoint serving after the mechanism was explained; the retry was approved and started. Key values are absent from this report, screenshots, evidence logs and intended commits. The generated export and local key file are ignored. This approval does not authorize public hosting of the credential-bearing package.

## Commits and checklist slice update

Planned implementation commit: `feat(menu): add preview menu and GD-Sync connection`.

Creator feedback is accepted. The implementation commit is being prepared using explicit intended files and staged-diff inspection. The SDK release dependency is included intentionally; local keys, generated exports, private learner profile, `.godot`, system metadata, pre-existing planning files other than the changed checklist, and unrelated sibling work are excluded. Slice/checkpoint completion will be recorded only after the implementation commit succeeds.

The existing parent repository contained modified `.DS_Store` files and untracked planning/SDK/backend work at entry. These were preserved. The learner profile remains ignored/untracked. No other slice or later checkpoint was changed.

## Unresolved issues and creator inputs

- Required early M01 hands-on feedback is accepted; no requested adjustment remains.
- Final allegiance assets and final opening choreography remain creator-owned. The current icon is expressly labelled temporary; Stats/Record UI ownership is untouched.
- SDK editor teardown diagnostic and host sandbox export diagnostics remain documented above; final browser game checks passed within the stated scope.
- Account quota, precise service deployment version, mobile input behavior and deferred failures/devices are unverified. No support destination or production naming rules have been invented.

## Handoff notes for the next assigned milestone

Stop at M01. Do not begin M02 until separately assigned. Preserve the local-provider/real-connection distinction, `.tres` motion tuning, explicit autoload resource path, filtered export dependencies and the SDK web guard. A future public release needs an explicit decision about the SDK's shipped connection configuration. Re-export only when an assigned milestone or a concrete affected web/export failure requires it; this session does not establish a feature-by-feature build-check policy.
