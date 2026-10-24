# M13 — Antigravity polishing handoff

Status: **prepared for creator-assigned takeover; polishing not performed by this HUB**. Date: 2026-10-24. Intended executor: **Antigravity using the creator-specified Gemini 3.8 Flash**. No agent/chat is created or contacted by this document. Execute only the presentation work the creator assigns.

## Read only this handoff and relevant scene/source context first

Project: `/Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor`.

Update your actual work/evidence in **[AGY_Polishing_report.md](reports/AGY_Polishing_report.md)**, at:
`/Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/rock-paper-scissor/docs/reports/AGY_Polishing_report.md`.

Do not create a competing report. It is currently an unfilled template, not proof that polish or tests occurred. No Devpost skills/SKILL.md, learner profile, curriculum, submission or learning/shipping workflow. Do not load the full planning/report bundle. Read relevant scripts for references before changing a scene; read permission is not write permission.

## Exact scene-edit boundary — creator instruction

**FIRST: work in `scenes/development/presentation.tscn`.** Open it and press **F6** for the offline presentation sandbox. Begin presentation iteration there; do not start by editing the live entry scene. Inspect and preserve the existing offline wiring. Do not duplicate the shared UI into a replacement tree.

**THEN: shared visual changes belong in `scenes/ui/game_ui.tscn`.** The creator explicitly permits editing this shared scene for the assigned presentation work after starting in the sandbox. Both the sandbox and live root instance it, so shared UI changes naturally appear in `scenes/main.tscn` without editing that file. Keep reusable layout/visual changes in the shared scene rather than leaving them only as preview-instance overrides. Preserve node paths, unique names, signals and bindings consumed by existing scripts. If an intended visual change requires a structural or script change outside the allowed files, present the concrete change and obtain a scoped command before editing it.

**PROTECTED: do not directly edit `scenes/main.tscn` unless the creator gives BOTH explicit confirmation AND an explicit command to make that specific change.** General M13/polish approval, “make the UI look good,” approval of a sandbox result, or existing older edits to main do not provide that permission. Before a necessary main-scene change, show the intended modification and reason, then wait for the creator's specific confirmation and command. Until received, continue useful work inside the permitted scenes and leave main untouched.

This restriction includes indirect file writes: no scene re-save, formatter, regeneration, script/tool operation or broad replacement that rewrites `main.tscn`. The live scene is not banned forever; its direct modification is deliberately permission-gated. Automatic visual propagation through its existing `game_ui.tscn` instance is approved and does not require a direct main-scene write.

**Initial write allowlist:**
- `scenes/development/presentation.tscn` — start here.
- `scenes/ui/game_ui.tscn` — shared presentation mutations after starting in the sandbox.
- `docs/reports/AGY_Polishing_report.md` — your actual work/report.

All other scenes, scripts, Resources, assets, project/export settings, networking/backend files and service configuration are read-only for this initial takeover unless the creator explicitly expands the file/task scope. In particular, do not bypass the main-scene boundary by changing its startup script, connection controller or dependencies. Existing project requirements about Resource-owned tuning remain: if a polish task needs a Resource/script edit, obtain the specific scope expansion rather than hardcode around the restriction.

## Existing composition — source inspected by HUB, not newly playtested

```text
scenes/development/presentation.tscn
  UI -> scenes/ui/game_ui.tscn
  ProfileProvider -> memory-only presentation provider
  development overrides -> local session/coordinator/receipt/chat adapters

scenes/main.tscn
  UI -> the SAME scenes/ui/game_ui.tscn
  ConnectionRequirement -> live-only identity/API/SDK/opening controller
```

The sandbox is prepared to show **Test-Human** immediately, without intro/name/network gates. Use **Play bot now** and its condition selector for presentation iteration. It uses simulated identity/statistics/quests/results only in memory; reset is preview-only. Preserve offline labelling and simulated receipt guards. Do not connect it to Atlas, start SDK/HTTP calls, access real credentials, or turn preview progress into saved history. This is authoring evidence only, never a live-game/backend verification.

The shared UI owns presentation and interactions; the live root/controller owns real connection/readiness and account lifecycle. Do not move network/account initialization into the shared UI or sandbox.

## What is closed and what remains unverified

The creator explicitly says M13-pre is done and requests closure. It is now **closed by creator instruction**, not an independent HUB audit or a claim that every vendor issue was fixed.

Its executor reported real backend settlement improvement **17.351s → 2.084s** and initial menu **8.963s → 0.968s**, with a creator-approved Singapore backend deployment/query repair and preserved durable results. These are small reported observations, not a guarantee. Intermittent GD-Sync connection/matchmaking behavior and supported routing override remain unresolved/unverified and are outside your polish scope. Do not restart network investigation or replace the service.

The latest shared-UI/source composition was checked offline by the previous executor; actual online startup after that refactor and a new web export were not verified. The existing web export predates the shared-UI refactor. Do not compare old-web/new-native human sessions as compatible builds: the SDK-exposed session node path changed. No claim of hosted frontend readiness or human-network verification follows from successful sandbox polish.

Existing source, including `main.tscn`, backend repairs and new shared/offline scene files, is uncommitted. Preserve it. Snapshot/read the initial Git state and protected-file content before edits. Do not reset, clean, blanket-stage, commit or deploy automatically. Never overwrite unsaved editor buffers or save unrelated scenes.

## Presentation constraints and review

Follow the creator's actual visual direction; do not invent a wholesale redesign. The creator retains final title/menu, matchmaking and outcome choreography, Stats/Record composition, icons/art/copy and audio decisions. Reuse approved existing artwork; no new generated art or automatically selected music/SFX. Missing assets/direction are explicit inputs, not permission to improvise consequential changes.

Keep Godot 4, portrait/single-threaded-web compatibility, readable modular behavior, inherited/shared scene structure and existing animation hooks. Adjustable timings/easing belong in Inspector-exposed `.tres` Resources when specifically authorized to edit them. Keep required work outside assertion expressions.

Preserve all four full 15-second choice windows, normal live 30–45-second fallback, complete claims/history, chat layering, live durable receipt-before-cinematic, identity/participant/departure contracts and server-calculated rewards. No balance changes, fake live receipts, backend/data resets or production preview fallback.

Discover Godot MCP and confirm the exact connected project through supported evidence before relying on scene/runtime tools. Record limitations; do not probe credential-like internal state. Initial verification is limited to affected scene parsing and normal **offline F6** presentation/menu/bot/reveal paths needed for the assigned change. No live `main.tscn` run, backend calls, export, deployment, broad/edge suites or device matrix in this initial takeover without a further creator assignment.

Show the creator the actual affected sandbox presentation, gather feedback and record it in the polishing report. Record which allowed files changed and explicitly whether protected main stayed unchanged; if permission is later granted, record its exact scope and resulting changes. Keep unperformed web/live/audio checks unverified. M13 remains pending until its actual assigned scope and creator acceptance are complete; M13-pre closure does not approve M13 results. Final Review, app map/wrap-up and shipping stay open.

Stop at the assigned polishing boundary. No other-chat creation/messaging/delegation, automatic network fixes, frontend deployment or submission work.
