---
doc: scope
status: approved
updated: 2026-10-22
---

# Devil's Rock Paper Scissor

A portrait multiplayer rock paper scissor card game about deception, doubt, and discovering what an opponent actually chose.

## The Unique Kernel

Actual cards, identity claims, change intentions, and final submissions can differ. Opponent tendencies and visible hesitation/revisions inform decisions, while arena conditions reward honesty or deception. The narrated reveal exposes what happened. The appeal is the creator's “illusion of choice” and deception-driven “what ifs.”

## Who It's For

Men and women approximately 17–40 who recognize RPS and want to read, deceive, and second-guess an opponent. Different personalities and uncertainty about alternative choices should encourage another match. Bots also participate in the intended competitive experience.

## The Core Loop

Open the portrait web game, enter anonymously, and name the profile on first login. From the menu, enter ranked matchmaking. Meet a human or fallback bot; play the modifier, Option, Claim, Change Claim, and Change phases. Chat can be opened before the cinematic. Watch the narrative reveal/outcome, then tap back to the menu, where eligible quest rewards are granted.

## Inspiration & Identity

Casino-like table, player below and opponent above, hidden cards, speech bubbles, devil/angel/human imagery, suspenseful film-style reveal, and satisfying animated interactions. Premium and informative without overwhelming text. Presentation is part of initial implementation. Detailed workflow/asset constraints: [AI_Bootstrap.md](../docs/AI_Bootstrap.md).

## Why This Matters to the Learner

Demonstrate AI-assisted game development, with the creator authoring the feel and refining the result. Personal learning context remains in the ignored learner profile.

## What "Working" Looks Like

Players enter, match, complete the entire deception/reveal loop, and return to the menu with the correct result/progress. Narration makes the relationship between claims and actions clear. Required data persists, returning browser identities recover saved progress, and empty human matchmaking can still produce a competitive bot match.

The creator reviews the feel, clarity, suspense, and premium presentation hands-on. Product criteria are owned by [prd.md](prd.md); human, bot-fallback, and bot-takeover verification must be distinguished.

## The POC Boundary

All requested submission capabilities remain in:
- Human multiplayer and ranked matchmaking.
- Required bot fallback after a randomized 30–45 seconds, competitive bot leaderboard identities, and no player-facing bot label.
- Hidden bot takeover after a pre-result human disconnects; the departed human receives no saved match result and cannot reconnect to that match. The server receives the result before the cinematic, and leaving during that presentation does not forfeit the established result.
- Devil's Seduction, Angel's Confession, and no modifier; the complete selection/claim/change/narrative-result flow.
- Backend-held player data, lifetime opponent information, initial/final choice records, central/detailed statistics, and four-category leaderboard.
- Frontmost in-arena chat, opened before the cinematic; bots do not reply and past conversations are inaccessible.
- Sequential daily quests without a fixed daily cap, current-day history, weekly quests refreshing Monday, and automatic point rewards on menu entry.
- Portrait, single-threaded web output and the intended animated presentation.
- MongoDB and Vercel functions as creator-selected backend direction; GD-Sync and Vercel distribution remain the stated multiplayer/delivery direction, with compatibility/responsibilities for technical planning.

Detailed behavior has one owning location in prd.md. No service capability, architecture, or implementation is verified by this scope.

## Later

No required submission capability is deferred. An honesty safety net or additional raw lying rewards may be considered after playtesting; release placement is undecided. The creator expects ongoing authoring and refinement, not automatic agent scope changes.

## Explicitly Cut

- Player access to previous arena conversations.
- Cheat/game-throwing detection.
- Shop.
- Reconnection/resumption of an abandoned match.
- Bot chat replies.

## Remaining Planning Work

The approved PRD/spec own the detailed behavior, metric/calendar definitions, state/data contracts and verification expectations. Creator-authored tuning/content must still be supplied or agreed before affected implementation. The creator supplied a flow-first implementation order on 2026-10-22; `../docs/Milestones.md` and `checklist.md` contain the detailed draft distribution for review. No milestone has been executed by this planning work.

## Review Status

The original scope was explicitly approved on 2026-10-20. The amended scope incorporates subsequent creator-requested leaderboard, quest, bot-fallback/takeover, and exclusion decisions. The creator explicitly approved the displayed amended scope and consolidated PRD together on 2026-10-21 (“Yep i approve”). This approval does not extend to the separate vision/bootstrap drafts or to unresolved technical and authoring decisions.
