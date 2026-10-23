---
doc: game-vision
status: approved
updated: 2026-10-24
---

# Devil's Rock Paper Scissor

## Premise and Distinctive Idea

A portrait, mobile-ready rock paper scissor game presented as a casino-like card duel. The player sits at the bottom of the table and the opponent at the top. Cards represent rock, paper, and scissor.

The distinctive experience is lies and deceit: players choose a real card, claim what they chose, announce whether they intend to change it, and then act. Opponent statistics and a session modifier influence the player's judgment. The reveal narrates what happened to build suspense before a dramatic result.

The creator wants to demonstrate that AI-assisted development can produce a game for the Devpost challenge. This motivation is recorded without making a claim about current submission eligibility.

## Core Experience and Emotional Direction

The intended audience, return motivation, submission boundary, and quality goals are captured in `../devpost/scope.md`. The amended scope and consolidated PRD were explicitly approved together on 2026-10-21; the original scope approval is preserved in its review history. **Who It's For** and **Inspiration & Identity** carry the creator's direction: familiar rules, deception-driven doubt and “what ifs,” encounters with different personalities, and informative, premium presentation without text overload.

- A face-down commitment gives each player something to conceal.
- Claims and declared intentions create opportunities for honesty and deception.
- Opponent tendencies provide information the player can interpret.
- Devil/angel imagery frames the temptation to lie or tell the truth.
- Narration delays the final reveal and builds suspense.
- Tweened transitions, prominent phase-end feedback, particles, and a dramatic finish are part of the desired feel. Concrete quality checks will be established in the PRD and hands-on review.

## Overall Flow

The current journey runs from opening/title and anonymous entry through the main menu, ranked matchmaking, the arena intro, Option, Claim, Change Claim, Change, and narrated reveal/result. The player tries to read the opponent while concealing the difference between actual choices and stated intentions.

Detailed round rules and the opening/menu flow have moved into `../devpost/prd.md`, approved on 2026-10-21. Use its **Arena Intro and Conditions**, **Phase 1 — Option** through **Phase 5 — Narration, Reveal, and Result**, **Opening and Anonymous Entry**, and **Screens and Layout** headings rather than maintaining duplicate behavior here.

The creator's requested leaderboard, quest, competitive bot fallback, and bot takeover features are included in the amended scope and consolidated PRD approved on 2026-10-21. Bots are intended to look like other players rather than being identified in the player-facing presentation. Detailed behavior, including no saved result for a pre-commit departed human, no reconnection to that match, and retention of results already established before the cinematic, belongs in the PRD; approval records the intended behavior and does not establish implementation or verification.

## Multiplayer and Proposed Delivery

The intended game is multiplayer. The confirmed output target is a single-threaded web/WebGL build with a portrait, mobile-ready presentation; detailed development and export constraints are owned by `AI_Bootstrap.md`. The creator has chosen MongoDB for the database and Vercel functions for APIs. GD-Sync and Vercel build distribution remain the stated multiplayer/delivery direction. The creator agreed on Godot host coordination, GD-Sync live messaging, and backend result processing/persistence; see `../devpost/spec.md` for the accepted trust tradeoff and remaining agreements. Service compatibility, capacity, and exact export setup have not been verified.

Ranked matchmaking, arena coverage, and pre-cinematic chat are submission capabilities captured in `../devpost/scope.md`. The canonical boundary and exclusions are in the scope. Anonymous entry is selected; its player-facing flow is owned by `prd.md > Opening and Anonymous Entry`. Chat's trigger/layering, scoring, and main journey are recorded in the PRD; remaining technical and presentation agreements are listed under its **Open Questions**.

Service capacity is not assumed unlimited. The creator requested AI setup guidance; the researched service baseline, version policy, and remaining quota/compatibility checks are owned by `../devpost/spec.md > Service Selection and Version Policy`.

## Submission and Longer-Term Ambitions

The creator requires the described game functionality in the submission. See `../devpost/scope.md > The POC Boundary`, **Later**, and **Explicitly Cut** for the amended boundary, exclusions, and post-playtest balancing candidates. No previously required game capability has been deferred. The amended scope, consolidated PRD and this vision are approved.

## Decisions Still Needed

The approved technical plan and its implementation-validation requirements live in `../devpost/spec.md`. Remaining creator-authored content/tuning and presentation decisions are recorded there and in `../devpost/prd.md > Open Questions`. The established gameplay rules are in the owning behavior sections. Do not fill an unresolved consequential choice with an assumption before the affected work.

The spec was explicitly approved on 2026-10-22 and establishes technical responsibilities. The creator subsequently supplied a flow-first implementation order and approved its detailed distribution in `Milestones.md` and the official checklist.

## Build Sequence

The creator supplied their flow-first build order on 2026-10-22: rough menu with an early real SDK connection, simulated matchmaking, gameplay, cinematic/result, submenus, full live GD-Sync integration, backend development, and final backend integration. `Milestones.md` owns the approved distribution and handoffs; `../devpost/checklist.md` owns progress. The original approved plan has 12 milestones, with three for gameplay and two for submenus. On 2026-10-24 the creator explicitly revised M12 to backend deployment preparation and added M12.5 to finish integration and verify editor/native then local web COM gameplay against deployed functions. Backend and frontend are separate Vercel projects/repositories; backend uses `backend` / `static-api-only` without uploading the export. Creator deploys/tests the frontend after M12.5. This revision preserves product scope and existing approvals; local integration completion is not hosted exploration, human/takeover verification, final presentation or shipping readiness. Polishing/SFX/music and subsequent work belong to another agent; Final Review and learning wrap-up remain open. Preserve that supplied group order unless a change is agreed. Rough development retains basic animation; final creator-authored choreography can follow the functional foundations.

## Approval

The creator explicitly approved this displayed vision together with AI_Bootstrap, Milestones and the checklist on 2026-10-22 (“Sure”), including the 12-milestone distribution. The original scope approval and the combined approval of the amended scope and consolidated PRD on 2026-10-21 are recorded in `../devpost/scope.md`; the technical spec was explicitly approved on 2026-10-22. Planning approval does not establish implementation or verification.

**Subsequent creator addition, 2026-10-24:** M13 — Polishing is now a separate planned milestone after M12.5, likely using AGY at the creator's discretion. Its detailed brief is in docs/Milestones.md and its pending slice is in devpost/checklist.md (paths relative to the Godot project). The requested docs/reports/AGY_Polishing_report.md is an unfilled template, not completed work. No implementation/dispatch occurs in the HUB; Final Review and learning wrap-up/app map remain separate and open.
