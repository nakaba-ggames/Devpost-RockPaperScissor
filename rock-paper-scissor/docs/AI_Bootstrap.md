---
doc: ai-bootstrap
status: approved
updated: 2026-10-24
---

# Project AI Bootstrap

## Collaboration and Authority

The creator owns product decisions and approves consequential changes. Agents act as concise, candid collaborators: clarify contradictions, identify consequential gaps, and distinguish proposals from decisions and observed results from unverified claims. Do not invent missing intentions or fill gaps with assumptions. Ask for clarification when a requirement or intended behavior is unclear; record it as unresolved until answered. The creator explicitly delegates animation and transition choices within the constraints below, subject to their revision.

The combined Vision/HUB chat handles vision, requirements, technical planning, milestone preparation, and audits the creator explicitly requests. Implementation belongs in separate milestone chats. The HUB may inspect the project and write planning/workflow documents, but must not write gameplay code, modify scenes or project settings, or execute milestones. Do not automatically create or message other chats. Keep setup and instructions scoped to this project.

## Interviews and Approvals

- Use the official project-local Devpost Learn skills in `.agents/skills/` in sequence.
- Keep explanations concise; ask up to two or three closely related open questions when useful. Carry answers forward.
- Draft once enough is known. Record proposals and unresolved issues honestly.
- Display planning documents for review before marking them approved. Silence is not approval. Clear approval of the displayed document needs no second sign-off.
- Use `5-build` in the HUB only to prepare/review the build checklist and align it with milestones. Stop before implementation even after checklist approval.

## Document Ownership

- `docs/Game_Vision.md`: premise, identity, emotional direction, overall flow, and longer-term ambitions; align it with the approved submission documents.
- `devpost/scope.md`: submission audience, purpose, distinctive idea, deliverable boundary, definition of working, and exclusions.
- `devpost/prd.md`: detailed player-facing behavior, screens, rules, feedback, states, edge cases, and acceptance criteria.
- `devpost/spec.md`: agreed technical responsibilities, interfaces, state/data ownership, dependencies, runtime/export approach, and important uncertainties. Leave routine implementation choices to executors.
- `docs/AI_Bootstrap.md`: project agent constraints, authority, workflow, reporting, and audits.
- `docs/Milestones.md`: ordered milestone briefs, dependencies, completion criteria, verification, report locations, and handoffs. The creator's proposed build order must be preserved unless a change is agreed.
- `devpost/checklist.md`: official slice/progress contract, mapped explicitly to milestones. Preserve the official template's field names and required review/wrap-up sections. Do not mark unperformed checks complete.
- `devpost/learner-profile.md`: personal learning context. Keep it ignored and excluded from commits; do not copy personal reflections into public planning or reports.

Give detailed decisions one owning location and reference them elsewhere. During intake, behavior may be captured in the vision document; move detailed behavior into the PRD when it exists rather than maintaining duplicate rule definitions.

## Game Jam Approach

Treat this development as a game jam, including its time constraints, even though the event uses app/hackathon language. The creator describes joining with nine days until submission; the exact deadline has not been established here. Prefer simple, readable, compatible solutions over elaborate abstractions or fashionable techniques. The curriculum's proof-of-concept framing does not override the creator's agreed game scope or authorize silent cuts.

## Godot and Coding Constraints

The applicable inherited instructions currently require Godot 4.x and GDScript, Inspector-exposed tuning with `@export`, simple modular scripts, and Custom Resources rather than JSON for game data. Use Godot 4 syntax, including `@onready`, `PackedScene.instantiate()`, and `change_scene_to_file()`. Do not introduce complex state machines unless explicitly requested. Use animation nodes appropriate to the agreed visuals.

The inherited GDScript constraint governs the Godot game client. The creator explicitly selected TypeScript on Node.js for Vercel Functions with the official MongoDB driver; see `devpost/spec.md` for backend responsibilities and identity contracts. Do not apply the client language restriction to the separately agreed backend. Apply these additional explicit project requirements:

- **Readable code first:** prefer straightforward control flow and clear names. Avoid ternary expressions and clever compact code; use readable `if`/`else` statements.
- **Tune through `.tres`:** store designer-adjustable values in custom Resource `.tres` files, including delays, tween durations, transition durations, easing choices, and other gameplay/presentation tuning. Resources may be centralized or distributed. Expose their fields in the Inspector; do not scatter tuning literals through scripts. Resource ownership and grouping will be established in the spec rather than invented here.
- **Base scenes and inherited scenes:** use shared base scenes and inherited scenes for related variants, keeping common structure/behavior in the base and variant-specific differences in the inherited scene. Establish the concrete scene families in the spec; avoid duplicating common scenes or building an elaborate inheritance hierarchy.
- **Compatibility first:** proposed dependencies and techniques must fit the target web export. Do not adopt a feature that requires changing the agreed runtime constraints without discussion.

## Web Export and Build Verification

- **Required target:** a single-threaded Godot web/WebGL export, with a portrait, mobile-ready presentation. Do not introduce game code, client plugins, or service integrations that require the game client to use threads. Exact export settings and browser/device verification targets belong in the spec; this document does not claim the project is already configured or verified for them.
- **Export only what is needed:** do not export all project assets by default. Verify the export includes the actual game scenes and their required resources, including any required assets loaded by path at runtime. Exclude unused artwork, source art, and development-only content. Confirm the resulting package rather than assuming the export preset filtered it correctly.
- **Audit assertions:** inspect `assert` usage before export. Required work, state changes, and validation needed for release behavior must run outside assertion expressions. Assertions are evaluated in debug/editor execution, not release exports; side effects inside them can cause differing behavior. See the [official GDScript assertion reference](https://docs.godotengine.org/en/stable/classes/class_%40gdscript.html#class-gdscript-method-assert).
- **Check the real build:** verify the exported release game in a browser through the affected journey, including phase transitions and animation completion. Investigate stalls using observable state and console errors; do not presume an assertion caused a stall merely because the creator encountered similar failures previously. Passing an editor playtest alone is insufficient evidence of export correctness.

Milestone handoffs must include relevant export constraints and checks. The milestone plan will establish when exports are produced and which checks apply; this HUB does not execute a build milestone.

## Technical Planning Carry-Forward

The creator prefers backend-maintained aggregate statistics that the game can fetch, mentioning a stored win-rate field, rather than repeatedly recalculating raw history. The PRD owns the product requirement to reflect all relevant past matches and show N/A for missing opponent history. `4-spec` must establish aggregate definitions, data ownership, update responsibilities, and interfaces; the preference does not prove an existing MongoDB field/schema or backend implementation. Move detailed technical decisions to the spec once agreed.

## Placeholder Assets

Do not create geometric shapes as placeholder artwork, whether through procedural generation, drawing code, or newly authored shape assets. Use existing project artwork:

1. Prefer assets in `res://Graphics/Simple Shapes/`.
2. The creator also permits `res://addons/godot_mcp_toolkit/icon.svg`.

Both locations were confirmed present during this planning update. Their presence does not verify export inclusion or runtime appearance. Do not use MCP placeholder-generation tools to bypass this restriction. Ask if the available assets cannot serve a needed placeholder.

## Animation from the Start

Visible interactions and state changes should be intentionally animated from their first implementation. Do not leave a static implementation with animation deferred to a final polish milestone. Cover card selection/movement, overlays, bubbles, phase feedback, reveal, and result transitions as those behaviors are introduced.

The creator delegates judgment about suitable motion, timing, easing, transitions, and emphasis using game/animation principles. Use tweens or appropriate authored animation for almost all visible changes; do not force a tween onto an operation where animation has no purpose. The creator may revise the choices or adjust them directly. Keep adjustable animation parameters in `.tres` resources as specified above.

Respect creator-reserved presentation work: the title/menu transition direction, matchmaking card animation, and final outcome animation configuration are reserved to the creator, as recorded in `devpost/prd.md > Look and Feel` and **Phase 5 — Narration, Reveal, and Result**. Do not replace these with agent-selected final animations without their agreement; coordinate their delivery in the relevant milestone handoff. The creator will also choose dimmed versus fully black cinematic treatment after seeing it; do not treat that open visual choice as a missing gameplay rule.

The creator will add the half-angel/half-demon and human-head allegiance icons. Track their delivery in the relevant handoff and confirm their asset paths before relying on them; their presence has not been verified. The approved existing placeholder-asset restriction above continues to apply.

The creator also reserves the UI design of Detailed Stats and Record. Their required data fields belong in `devpost/prd.md > Detailed Statistics and Records`; preserve those responsibilities while coordinating the final modal/page form and layout with the creator.

## Godot MCP

Discover the available tools and confirm the connected project before relying on them; a tool namespace alone is not project verification. During planning, use read-only inspection when useful. Do not use editor mutation tools from the HUB.

Milestone handoffs must direct executors to use MCP for supported editor operations, scene inspection, game execution, and runtime verification within their assigned scope. Record tool/connection limitations explicitly. Running a command, seeing a successful response, and observing the intended player behavior are different evidence; report what was actually verified.

Player-facing bot anonymity is a product choice, not a reporting rule. Verification and audit reports must distinguish actual human peers, fallback bots, and takeover bots. A working bot match does not establish that human-to-human networking or live matchmaking has been verified. Refer to `devpost/prd.md` for bot gameplay and identity rules.

When the creator explicitly requests a HUB audit, inspect the relevant project state and perform appropriate MCP runtime checks against the milestone report. Report findings and limitations; an audit request does not itself authorize implementing fixes.

Disconnected players have no reconnect, restoration, or live-match resume flow. The PRD now owns the explicit commitment boundary: the server receives the result before the cinematic and later cinematic departures do not undo it. Keep any internal handoff needed for the remaining player's previously required bot continuation separate from returning-player recovery. The full-spec review on 2026-10-22 explicitly approved the remaining-player hidden-field handoff and pre-cinematic acknowledgement/error handling; it never authorizes reconnection of the departed player.

## Milestone Handoffs and Reports

Each handoff must identify its assigned milestone, approved document references, allowed scope, dependencies, completion criteria, mechanical verification, learner checks, MCP expectations, and report location. Reference the applicable coding, Resource, scene inheritance, placeholder, animation, and web-export constraints above. Executors must report changed files, verification performed, results, and unresolved issues, including deviations from the approved plan. Clearly distinguish editor verification from exported-browser verification.

The approved milestone/checklist mapping, assignment boundary, report template/paths and commit/checkpoint workflow are in `docs/Milestones.md` and `devpost/checklist.md`. Reports use `docs/reports/MNN_Report.md` and are created by executors after actual work, never as placeholder evidence. Creator-requested M13 exception: `docs/reports/AGY_Polishing_report.md` is a prepared unfilled template; it must be populated with actual evidence before supporting completion and is not itself an execution claim. One milestone maps to the same-numbered official slice. Execute only the human-assigned milestone and stop, even if the generic build skill would continue its loop. Establish learn/fast mode in the first implementation chat and carry it forward. Do not invent completed milestones, reports, learner checks or audits.

## Current Status

**Current workflow revision, creator-authorized 2026-10-24:** the checklist owns actual progress; the original dated planning observations below are historical. M12 is now **Backend deployment preparation**, complete using existing commits and creator-confirmed successful Vercel deployment/build. M12.5 is the explicitly approved follow-on: finish/reuse integration, editor/native COM against deployed functions first, then one locally served web export against those same functions, plus actual creator feedback. The original M12 hosted-game exploration is unperformed; its integration checkpoint moves to editor/local M12.5. Backend and frontend use separate Vercel projects/repositories; backend `backend` / `static-api-only` must not require/upload the game export. Creator handles frontend deployment/testing afterward, outside the M12.5 completion gate. Preserve existing Resource/configuration approvals, current Atlas `m12_` separation and participant/revision/chunk/departure contracts. Do not infer human/takeover verification from COM. Full brief is in `Milestones.md`; no M12.5 implementation is authorized in this HUB. Polish/SFX/music belong to another agent; Final Review, learning wrap-up/app map and prior pending checkboxes stay open until actually completed.

**Historical planning baseline (2026-10-20–22):**

`1-start`, `2-scope`, `3-prd`, and `4-spec` are complete. The original scope was approved on 2026-10-20, the amended scope/PRD together on 2026-10-21, and the displayed technical spec on 2026-10-22 (“Yeah i approve, let's move quick”). `devpost/spec.md` owns the approved architecture, service baseline, interfaces, file layout, and verification expectations, including the labelled remaining-player handoff and pre-cinematic save-error proposals. External accounts, exact installed versions, quotas, deployment, and runtime behavior remain unverified; approval is not implementation evidence.

The HUB's `5-build` checklist preparation/review is complete. On 2026-10-22 the creator explicitly approved the displayed `docs/Milestones.md`, `devpost/checklist.md`, this bootstrap and `docs/Game_Vision.md` together (“Sure”), including the 12-milestone mapping with three gameplay and two submenu milestones in their flow-first group order. All slices/checkpoints remain unchecked. Clear Data is settled as a local-only browser cache/data reset for testing, with behavior owned by the PRD. The official checklist field labels are preserved. The implementation, final review and learning wrap-up portions of `5-build` remain unperformed; no implementation, automatic chat creation, or chat messaging is authorized in this HUB.

Read-only inspection on 2026-10-20 confirmed a sibling `../backend/` directory within the parent Git repository. It contained an image and a Finder metadata file; no backend source or configuration was observed. This is a workspace observation, not a working backend or permission for the HUB to implement one. Backend implementation and any needed write access must be handled in its assigned milestone chat.

Read-only planning inspection on 2026-10-22 found a GD-Sync package declaring 1.0.2; local settings do not list it as enabled. M01 must verify/configure the existing candidate and its actual web service connection. Do not report this observation as installation/configuration performed by the HUB or as verified runtime compatibility.

**Subsequent creator addition, 2026-10-24:** M13 — Polishing is now a separate planned milestone after M12.5, likely using AGY at the creator's discretion. Its detailed brief is in docs/Milestones.md and its pending slice is in devpost/checklist.md (paths relative to the Godot project). The requested docs/reports/AGY_Polishing_report.md is an unfilled template, not completed work. No implementation/dispatch occurs in the HUB; Final Review and learning wrap-up/app map remain separate and open.
