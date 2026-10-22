# M08 — Submenus II: daily and weekly quests

Status: **verified — implementation commit and completion recording follow**. Assigned M08/slice 8 only, recorded fast mode. M07 feature `40b0cc2`, completion `9f60234` and creator-approved rough Stats/Record composition are preserved. No new HUB audit, planned checkpoint, M09, Final Review or learning wrap-up is claimed.

## Scope and approved references

`docs/AI_Bootstrap.md`; Milestones universal requirements, Development Adapters and Evidence, Handoff and Completion Protocol, complete M08 brief; checklist slice 8, mode and Revisions; M07 report; PRD Daily and Weekly Quests / Main Menu and Player Information; spec Daily and Weekly Quest Coordinator, Data Model, Backend API, Shared Scenes and Tuning Resources, Staged Development Providers; project-local `5-build`. Private learner context was read without copying it into evidence.

## Creator catalogue decision

No later catalogue was recorded in the handoff or checklist. In this chat the creator answered **“Sure”** to the explicit development-only proposal:

- Daily ordered cycle, indefinitely repeating: Phase 1 Play Scissors, target 1, +1 point → Win 3 matches, target 3, +3 points → repeat. A reset starts the cycle again at Scissors.
- Three simultaneous weekly objectives: Play 5 matches, +5; Switch initial card 3 times, +3; Lie in 3 matches, +3. Lying counts once per match even with two false claims.

This agrees a runnable **preview** catalogue, revision `m08-creator-approved-preview-v1`. It does not approve production balancing, the earlier +2–5 suggestion, additional random selection, or a production catalogue. Exact content, targets, rewards, ordered repetition policy and weekly list live in Inspector-exposed `.tres` Resources. A later production catalogue remains creator-owned.

## Changed files and why

- `scripts/quests/quest_definition.gd`, `quest_catalogue.gd`, `resources/quests/*.tres`: content/objective/target/reward and selection configuration. Objective families read initial/final cards, claims and outcome directly.
- `scripts/quests/quest_instance.gd`, `preview_quest_coordinator.gd`, `preview_clock.gd`: fresh session instances, activation/contribution boundaries, sequential dailies, fixed calendar periods, expiry, reward eligibility and injectable time.
- `scripts/api/profile_provider.gd`, `local_preview_provider.gd`: API-shaped quest/menu read snapshots and menu-entry settlement through the existing preview provider; normal stats/records/points attribution remains at the existing once-only acknowledged-result boundary.
- `scripts/app/main.gd`, `scenes/main.tscn`: real Quests destination, daily strip above the summary, provider snapshot refresh and match activation notification.
- `scripts/ui/data_modal.gd`, `scenes/ui/quests.tscn`: inherited modal, read/loading/error/retry conventions, scrolling, progress/history/state labels, animated opening/closing/content, Back/Escape and clearly labelled development clock buttons. M07 Resource-owned insets and independent Back caption are preserved. No Stats/Record redesign or art.
- `export_presets.cfg`: explicitly include the required shared `data_view_tuning.tres` after the first release omitted that inherited dependency.
- `tools/m08_quest_checks.gd`, UID companions, report, pack manifest, `.gdignore`-protected `M08_evidence/`, checklist Revisions: authorized basic verification and completion record.

## Definition / instance / event / clock / provider contracts

Definitions have separate `definition_id`, objective, optional card, title, target and reward. Catalogue owns the daily ordered cycle and concurrent weekly list. Each assignment has a random session instance ID, owner, definition, period kind/start/expiry, activation time/event boundary, zero progress, completion time, payment time, expired flag and contribution IDs. Repeated definitions create independent instances; lifetime stats and retained records are never queried for quest progress.

At ordinary arena entry, `begin_preview_match(matchId)` captures IDs of quests already active before choice play. An eligible newly acknowledged result passes the existing simulated receipt validation, persistent-credit exclusion, recipient/departure/takeover checks and credited-result-ID guard before normal counters/history and quest advancement. The coordinator reads the frozen actor's actual `initialCard`, `finalCard`, `identityClaim`, `switchClaim` and resolved outcome. It advances only captured active IDs, once per contribution. One event can advance daily and weekly objectives already active. The next daily is assigned **after** the active set is processed, so the finishing event cannot enter its fresh counter. Captured IDs also prevent a pre-reset match from crediting newly assigned post-reset quests. Broader boundary/attribution replay injection is deferred.

Lying is one match-level boolean: identity mismatch OR switch-claim mismatch. Loss/draw objectives have no win-only gate. The approved daily Scissors objective uses Phase 1's initial card; switching/final-card objectives use separate structured fields.

`PreviewQuestClock.now_unix()` normally uses system Unix time; `set_development_time()` injects controlled preview time. It never changes the OS clock. Period arithmetic uses a fixed offset: `floor((unix + 2 hours) / 86400)`, then subtracts the shift for the 05:00 GMT+7 cutoff. Weekly start is the preceding Monday cutoff. Period refresh occurs on reads, menu entry, match activation and acknowledged events. Old instances expire before payment decisions; completed unpaid and unfinished assignments expire. Paid instances never become expired and paid points remain. Previous daily history is removed from player-facing snapshots; weekly objectives retain progress across ordinary daily resets.

`request_quests()` returns detached API-shaped snapshots: `dailyQuest`, `weeklyQuests`, current `dailyHistory`, `serverTime`, `periods`, `rulesRevision`, development/time-authority labels and profile/stats data. It refreshes periods but never pays. `enter_menu()` refreshes/expires first, settles eligible completions once, mutates points inside the provider, then emits the compatible existing profile signal plus a consistent menu snapshot including `grants`. Stats and leaderboard query the same updated balance. Main UI only displays snapshots; it never writes reward counters. Closing an overlay alone is not another menu settlement.

Development buttons advance directly to the next daily cutoff or next Monday cutoff and refresh read state with animation; they do not settle rewards. The injected time stays fixed until another advance or session restart. New session and Clear Data discard quest instances, contributions, tracked match IDs, clock overrides and snapshots alongside existing preview counters/history. Only existing name/identity storage persists.

## Development fixtures versus real services/players

All quest state, points and history remain session-only, development-only data. The catalogue is an approved preview example. The isolated runner uses labelled synthetic frozen submissions and direct rule/clock checks; it is never imported on normal launch. No fixtures or preview history are uploaded. No backend/API/database or production persistence was added. M11/M12 must replace local quest calculation, clock and reward authority with server-authoritative services; client time must never authorize production rewards.

The ordinary browser flow uses the existing scripted/local-policy Velvet opponent and simulated acknowledgement, not a human peer or persisted server result. The existing GD-Sync connection may connect, but it is not evidence of live match networking or backend persistence.

## Mechanical verification

Environment: 2026-10-23 Asia/Jakarta; Godot **4.7.stable.official.5b4e0cb0f**, GD-Sync **1.0.2**, MCP toolkit **1.0.0**; native portrait 540×960; release Codex in-app Chromium **155.0.0.0**, 625×827 viewport. Basic M08 only.

- Focused MCP `script_check`: all nine changed/new game scripts and scoped runner valid with empty diagnostics. New global-class cache initially produced stale-name failures; explicit script preloads resolved them. CLI headless import registered classes. No broad project diagnostics or full regression.
- MCP Quests inherited scene inspection confirmed shell/header/Back/scroll/read controls and two development clock buttons. Native ordinary open produced seven rows, `moving=false`, Back caption `Back`, scroll max 472. [Native observations](M08_evidence/native_observations.json).
- Isolated runner: nine synthetic acknowledged fixtures plus direct objective checks; exit 0, `M08_BASIC {failures: [], fixtureMatches: 9, sequenceReward: 10}`. Scissors loss completed the initial-card daily and advanced weekly play. Three wins led to a distinct fresh Scissors instance at zero, including a finishing Scissors win that did not replay. A subsequent Scissors draw completed it. Two false claims advanced weekly lie by one. Separate direct loss/draw coordinator checks advanced both already-active daily/weekly objectives, then assigned fresh zero-counter next dailies.
- Quest reads left completions unpaid. Menu entry added exactly daily 1+3+1 plus weekly 5 = **10** quest points to normal **38** match points; repeated entry kept **48** and returned no new grants. Normal W/L/D/statistics remained 5 matches, 3 wins, 1 loss, 1 draw, one lying match. Profile/menu/leaderboard balances agreed.
- Controlled UTC timestamps were advanced directly through GMT+7 **04:59 → 05:00 → 05:01** and **Monday 05:00**. Unfinished and completed-unpaid instances expired; new instances had new IDs/zero counters; daily history contained only the new period. Daily-only reset retained weekly progress/reward eligibility. Monday expired both weekly unfinished/unpaid and daily unpaid; 05:01 paid nothing for expired assignments. Separate paid completions retained their points and never became expired. [Rule/clock snapshots](M08_evidence/quest_checks.json).
- Final v2 release browser: explicitly chose Scissor during Option, then completed an ordinary honest draw against scripted/local-policy Velvet with simulated acknowledgement. Result showed **+3 normal match points**. Genuine menu return showed **4 Overall Points**, confirming **+1 automatic quest reward**, and the new **Win 3 matches 0/3** daily. Quests showed Scissors **1/1 Paid**, the fresh daily **0/3 Active**, and weekly play **1/5**. The shared header Back caption, opening/content/closing animations and navigation completed. [Menu](M08_evidence/browser_menu.png), [Quests/history](M08_evidence/browser_quests.png).
- In the same browser session, **Dev: next day** displayed **2026-10-24 05:00 GMT+7**, removed the paid prior-day entry and unfinished Win-3 history, started Scissors **0/1**, and retained weekly play **1/5**. **Dev: next Monday** displayed **2026-10-26 05:00 GMT+7**, with all three weekly counters at zero and fresh daily history. Back closed normally. The final browser session had **zero console errors**. [Monday reset](M08_evidence/browser_reset.png), [smoke observations/log](M08_evidence/browser_smoke.json).

## Godot MCP and browser/export limitations

Discovered the project-specific MCP tools and verified `MCPRuntimeServer.RegistryClient._ProjectKey.current()` exactly matches this project's root after macOS case normalization. Used script checks, scene open/tree, main game start/stop and scoped runtime reads/calls. No other project was mutated. Advanced refresh activation advertised tools unavailable to this harness; focused CLI import plus explicit preloads were the fallback. Existing host certificate, toolkit registry/port/editor-settings permission messages and SDK teardown/no-debugger messages remain tooling limitations, not a clean-editor claim. The scoped rule runs exited 0.

First release export exited 0 but browser logged the omitted `resources/presentation/data_view_tuning.tres`. Added that exact required Resource to the include filter. Second release export exited 0; opening Quests then rendered proper insets, visible Back text, all objectives/history and both clock controls. The first idle trial selected Paper by default and was restarted before acknowledgement to explicitly select Scissors for the reward smoke; it is not another completed-result test.

Final export is single-threaded, no GDExtension support. Explicit `res://` SDK autoload and existing web guard remain unchanged. PCK has **152 files, 566,072 bytes**, SHA-256 **`eeef03365d487dcce8eaec50fb2d744ef802e390db7c98a7ed16e9b0ec698f9d`**; localhost-served pack hash matched. Required Quests scene, all six catalogue/definition Resources, shared tuning, scripts and reused art are included. No shipped script assertions, private documents, tools, toolkit or unused source artwork. Required state changes run outside asserts. [Pack manifest](M08_PackManifest.txt).

The SDK export plugin still injects its client configuration despite the source exclusion, so this is an **SDK-bearing, ignored, localhost-only** export. Its values were not printed/copied into evidence or commits. Public distribution remains unresolved; no new exposure or publishing was performed. Shell localhost retrieval needed sandbox escalation; the approved read fetched only this local pack. Browser verification covers one in-app Chromium viewport, not a device/browser matrix.

## Learner check / checkpoint / actual feedback

Actual feedback: creator approved the exact development catalogue with “Sure.” No M08 playthrough feedback or final presentation acceptance has been received. Fast mode remains selected; M08 is not a planned hands-on checkpoint. No unperformed checkpoint is checked.

Native launch:

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor
/Applications/Godot.app/Contents/MacOS/Godot --editor --path .
```

Press **F5**, continue the preview (or enter a name), leave search on **Scripted opponent found**, then Play. Select **Scissor during OPTION / initial choice**, finish the ordinary round and return from the result to the menu. Expect the extra **+1 quest point**, the new **Win 3 matches 0/3** strip, and weekly play progress **1/5**. Open **Quests**, inspect the paid Scissors entry and current daily/weekly objectives; scroll as needed. Use **Dev: next day** to jump to the next 05:00 and see only the new day's fresh daily history, then **Dev: next Monday** to refresh weeklies. Reload/F5 or Clear Data removes the clock override/session state; Clear Data also removes remembered name/identity.

Browser: [M08 localhost](http://localhost:3000/m08.html?build=m08-20261023-v2). Existing static localhost server is reused; if stopped, run `python3 tools/serve_m01.py` from the project, then open that URL. No backend service is required.

## Commit(s) and checklist slice update

All scoped checks passed; explicit intended-file/staged-diff review and implementation commit follow. Slice 8 remains unchecked until the feature commit succeeds. Planned message: `feat(quests): add fresh progress resets and reward views`. Only explicit M08 files will be staged after reviewing their diff; private learner profile remains ignored/untracked. Unrelated Finder metadata, sibling artwork and pre-existing untracked planning files remain outside M08.

## Deferred checks and M09 handoff

Creator authorized **basic M08 only**, recorded in checklist Revisions. No full suite, broad regression, stress/race/concurrent requests, malformed input, deliberate service failure, receipt/attribution replay injection, live networking, full cinematic/data-category coverage, randomized 30–45-second search wait or device/browser matrix. Deferred behavior remains **unverified**, never passed. Implemented loading/error/retry UI was not deliberately failed.

Stop after M08. Preserve the provider read/acknowledged-result seam, once-only result IDs, attribution exclusions, session boundary, inherited modal family, M07 insets/Back fix, gameplay/receipt/cinematic navigation and creator presentation ownership. A separately assigned M09 may replace match transport; it must still activate quest instances before local choice play and deliver only eligible acknowledged events. M11/M12 replace preview profile/quest/time authority with real services, reusing snapshot contracts without uploading fixtures. Production catalogue and final art/layout remain creator-owned. No M09 implementation is authorized here.
