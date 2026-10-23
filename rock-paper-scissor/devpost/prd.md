---
doc: prd
status: approved
updated: 2026-10-22
---

# Devil's Rock Paper Scissor — Product Requirements

A portrait multiplayer RPS card duel about deception, doubt, and reading an opponent. Audience and submission boundary: [scope.md](scope.md), especially **Who It's For**, **The Unique Kernel**, and **The POC Boundary**.

These approved product requirements record the creator's decisions. Open technical agreements and creator-authored content remain explicit at the end; no implementation is claimed.

## The Core Journey

Source: scope.md > The Core Loop and What "Working" Looks Like.

1. Watch an opening UI sequence and reach the title while automatic anonymous login runs.
2. On first successful login, receive a display-name prompt. Successful entry exposes “Tap anywhere to continue”; tapping transitions into the menu.
3. See the central player summary, side menus, Play, and the current daily quest. Eligible quest rewards are granted automatically on entering this menu.
4. Play enters ranked matchmaking. A human opponent is preferred; a bot fills an unsuccessful search after a randomized 30–45 seconds.
5. The intro announces the randomly selected arena condition.
6. Complete Option, Claim, Change Claim, and Change. Each selection phase lasts the full 15 seconds, with decisions revisable until expiry. Chat can be opened before the cinematic.
7. Send the completed result to the server before triggering the cinematic. Watch the story of the actual decisions, followed by the creator-authored outcome sequence; leaving during this presentation does not forfeit the already-submitted result.
8. “Tap To Continue” returns to the main menu. This complete loop is one match; required results/progress persist.

## Screens and Layout

- **Title/entry:** opening UI, title, login states, first-login naming, and continue prompt.
- **Main menu:** Win Ratio, Win Streak, and allegiance icon at center; daily quest above; Play below. Left entries: Leaderboard and Record. Right entries: Detailed Stats and Quests.
- **Matchmaking:** animated card, “Looking for Opponent” with animated dots, and a leave-search button.
- **Arena:** player below, opponent above, face-down representative cards, central submission area, speech bubbles, opponent information, and dimmed selection presentations.
- **Chat:** a vertically long right-center button opens a frontmost modal/overlay.
- **Detailed Stats/Record/Quests/Leaderboard:** dedicated views. Final modal/page form and composition remain for UI authoring.
- **Cinematic/result:** the arena's narrative reveal and outcome sequence, followed by return to the menu.

## Look and Feel

Source: scope.md > Inspiration & Identity.

Casino-like, premium, suspenseful, satisfying, and informative without excessive text. Devil/angel imagery and hidden cards support the deception theme. Animate visible interactions from their initial implementation. Film-projector light/filter effects, curtains, fading narrative text, and a juicy result provide the payoff.

The creator reserves the title/menu transition direction, matchmaking card animation, final outcome sequence, and Detailed Stats/Record UI design. They will supply the hybrid allegiance and human-head icons. Dimmer versus fully black treatment, final copy, visual assets, typography/colors, sound, and exact animation timing can be refined during authoring. Agent/asset/tuning constraints are owned by [AI_Bootstrap.md](../docs/AI_Bootstrap.md).

## Features and Behavior

### Opening and Anonymous Entry

Source: scope.md > What "Working" Looks Like.

Attempt automatic anonymous login using an identity remembered in the current browser. As agreed during technical planning on 2026-10-21, clearing that remembered browser data requires a new anonymous account for this jam; cross-device transfer/recovery is not added. The credential contract is owned by `spec.md > Anonymous Identity and Credentials`. While pending, show no buttons/instructions. After success show “Tap anywhere to continue”; the first successful login also prompts for a display name. The creator will determine the title/menu transition.

Failure recovery:
- Server error: wait or contact support; support destination and final copy remain to be supplied.
- Account error: offer “Sign me up again” to create a new anonymous account. Do not silently migrate or delete the previous profile.

Acceptance:
- [ ] Pending login does not expose continue/menu actions; successful login exposes the continue prompt.
- [ ] First successful login prompts for a display name; a returning player with remembered identity sees saved progress.
- [ ] The two error causes expose their specified recovery paths.

### Main Menu and Player Information

Source: scope.md > The Core Loop and The POC Boundary.

Center indicators:
- **Win Ratio:** player win-rate information.
- **Win Streak:** wins add one; draws leave it unchanged; a loss resets it.
- **Allegiance:** Devil if deceptive wins outnumber honest wins; Angel for the opposite. Tied nonzero winning counts use the hybrid icon. No wins uses the human-head icon. Compare wins, not all Lie/Honest match counts.

**Clear Data** resets this game's local browser cache/data for testing. It does not delete or modify the backend account. If clearing remembered identity removes the anonymous credential, the established new-account behavior applies; the previous backend profile remains. Implementation staging and the eventual real authentication/data providers are owned by `spec.md > Staged Development Providers`.

Acceptance:
- [ ] The specified fields and menu entries occupy their intended positions.
- [ ] A draw neither breaks nor increases Win Streak.
- [ ] The icon distinguishes deceptive dominance, honest dominance, tied wins, and no wins.
- [ ] Clear Data clears only this game's local browser cache/data; backend account data remains unchanged.

### Detailed Statistics and Records

Source: scope.md > The POC Boundary.

Detailed Stats shows the percentage breakdown of cards the player won with, plus winning lie and winning honest percentages. “Rock 30%, Paper 50%, Scissor 20%” is illustrative data, not defaults.

Record preserves both players' Phase 1 initial choices and Phase 4 final choices as separate data. It shows the opponent display name. **Result** replaces the earlier “Win By” heading: show both final cards and dim the losing card. A draw has no losing card to dim. The creator will design the UI.

Acceptance:
- [ ] Stats use player data rather than the illustrative percentages.
- [ ] Initial and final choices remain distinct, even if their values match.
- [ ] Result compares the final cards and dims only a losing card.

### Ranked Matchmaking

Source: scope.md > The Core Loop and The POC Boundary.

Show the creator-authored card animation and “Looking for Opponent” with animated dots. A button allows leaving the search. If no human match is found, use a randomized 30–45-second wait before bot fallback.

As agreed during technical planning on 2026-10-21, new human profiles start at 0 Overall Points and that total is the matchmaking rating. Rating-gap configuration is owned by `spec.md > Ranked Matchmaking Coordinator`.

Bots are required competitive opponents, with names from bot leaderboard entries. They can climb ranks through participation, but do not autonomously search for matches. Players receive no bot label. Completed human-versus-bot matches receive ordinary competitive credit. Human multiplayer remains required.

Acceptance:
- [ ] Search and its exit control work.
- [ ] An unsuccessful human search fills with a bot after a wait in the specified range.
- [ ] The bot uses its leaderboard identity without a player-facing bot label.
- [ ] Bot participation does not create a reduced-credit practice mode.

### Disconnect and Bot Takeover

Source: scope.md > What "Working" Looks Like.

Before result submission is accepted by the server, a departed human forfeits, cannot reconnect to that match, and receives no saved match result, points, counters, or quest progress from it. The remaining player's match continues with bot control on the departed side, without a replacement notice, and receives normal competitive credit.

As clarified on 2026-10-22, the server receives the result before the cinematic is triggered. Once that result is committed, disconnecting or leaving during the cinematic/result presentation does not forfeit or undo it. There is no reconnection, session restoration, or replay/resume flow for a departed player; keeping an already-committed result is separate from rejoining a match.

As explicitly confirmed during technical planning on 2026-10-21, retain the departed player's displayed identity for the remainder of this match. Only the remaining human receives saved result updates. The takeover side does not create a saved bot-profile win/loss/draw result or other match-derived updates; ordinary fallback bots still receive normal competitive updates. The internal attribution contract is owned by `spec.md > Bot Controller and Personality Resources`.

“Disconnection means losing” describes forfeiting participation; the creator explicitly requested no saved result for the departed human. Do not turn that into a persistent loss write or assign the bot's result to that human. Preserve live phase/claim history needed for continuation. A connected but inactive player uses timed defaults instead.

Acceptance:
- [ ] Bot takeover continues the existing match without a player-facing notice.
- [ ] A human who departs before result commitment cannot resume the match and receives no saved match-derived updates.
- [ ] Leaving during the cinematic does not erase, reverse, or convert the already-committed result into a forfeit.
- [ ] The remaining human receives ordinary scoring/stat/progress treatment.

### Arena Intro and Conditions

Source: scope.md > The Unique Kernel and The POC Boundary.

Randomly determine and announce one of:
- **Devil's Seduction:** fulfilled if the player lies at least once.
- **Angel's Confession:** fulfilled only if the player never lies in either claim.
- **No modifier:** base rewards.

Acceptance:
- [ ] The intro announces the selected condition before Option.
- [ ] A mixed honest/false match qualifies as lying, not fully honest.

### Points and Match Classification

Source: scope.md > The Unique Kernel and The POC Boundary.

| Outcome | Base points |
| --- | ---: |
| Win | +10 |
| Draw | +3 |
| Loss | 0 |

| Condition fulfilled | Extra win | Extra draw | Total win | Total draw |
| --- | ---: | ---: | ---: | ---: |
| Devil's Seduction | +10 | +5 | 20 | 8 |
| Angel's Confession | +15 | +7 | 25 | 10 |

These are fixed additions; the earlier multiplier is superseded. Non-qualifying outcomes retain the base reward. Losses deduct no points and receive no arena bonus. Quest rewards are separate.

A false identity claim is a lie even if the card is ultimately kept. Compare the change-intention claim with the actual change. One false claim makes the match a lying match. The larger Angel bonus is the creator's intended incentive; its relative difficulty needs playtesting.

Acceptance:
- [ ] Base, qualifying, and non-qualifying outcomes produce the totals above.
- [ ] Neither an honest nor deceptive losing hand earns arena points.
- [ ] Both claims must be honest for Angel qualification.

### Decision Announcements and Phase Progression

Source: scope.md > The Unique Kernel and Inspiration & Identity.

Every selection phase lasts the full **15 seconds**, even after both players decide. Players can revise decisions during that window. Announce “[Player X] decided…” on deciding and “[Player X] Changed their mind” on revision. Timing is deliberate information about hesitation.

| Phase | No-input default |
| --- | --- |
| 1 — Option | Leftmost card in the shuffled starting order. |
| 2 — Claim | Truthfully claim the Phase 1 card. |
| 3 — Change Claim | Keep, first option/index 0. |
| 4 — Change | Leftmost card in the unchanged order. |

A fully idle player keeps the same card and makes honest claims. An active non-leftmost initial choice followed by Keep/leftmost defaults makes the Keep claim false; the creator explicitly accepts that. Consistent defaults take priority over ensuring honesty.

Acceptance:
- [ ] Both players deciding never skips the remaining timer.
- [ ] Decisions remain revisable with visible announcements.
- [ ] Expiry applies the stated defaults, including the accepted false-Keep case.

### Phase 1 — Option

Show three face-down representative cards per side. Shuffle RPS order at the start and do not reshuffle afterward. Selected position must not identify the hidden card to the opponent.

Dim the screen for Rock/Paper/Scissor selection. Move the selected representative card toward the central area. Show the opponent's initial-choice tendency, e.g. “Rock 70%,” and animated center “Phase Ends” feedback.

Acceptance:
- [ ] All three choices work; the card visibly advances.
- [ ] Starting order is shuffled and remains stable afterward.
- [ ] Visible position does not disclose the opponent's identity choice.

### Phase 2 — Claim

The two unused cards disappear and give way to speech bubbles. Dim the screen, offer all three identity claims, and remind the player of the modifier. Show selected claims in the bubbles and the opponent's lie tendency/modifier information. The claim does not itself change the actual card.

Acceptance:
- [ ] The player can truthfully claim or lie about their Phase 1 choice.
- [ ] With no input, the claim matches their Phase 1 card.
- [ ] Bubbles, modifier reminder, and opponent information reflect the phase.

### Phase 3 — Change Claim

Offer Keep first/index 0 and Switch second/index 1, with bubbles:
- Keep: “I'll keep my choosing”.
- Switch: “I'll switch my choosing”.

This is intention; the actual action follows in Phase 4. Show lie-tendency/modifier information.

Acceptance:
- [ ] Both declarations update the bubble without themselves changing the actual card.

### Phase 4 — Change

Dim the screen, remind the player of the earlier choice, and offer the same RPS order. Selecting a card and pressing the bottom Switch button changes the submitted choice. Keeping is allowed. Without input, use the leftmost card, including when that contradicts Keep.

Show the opponent's switching tendency. Apply a particle effect to the still-face-down submitted card whether it changed or not, so the effect does not disclose the action.

Acceptance:
- [ ] A final card can differ from the initial card and claims.
- [ ] No-input handling stays consistent with the default table.
- [ ] The face-down card receives the effect regardless of actual switching.

### Phase 5 — Narration, Reveal, and Result

The server receives the completed result before this cinematic starts, as explicitly specified on 2026-10-22. Presentation reveals an already-established result. A departure during the cinematic/result sequence does not change that result. The request/acknowledgement and once-only persistence contract is owned by `spec.md > Result Commitment Before the Cinematic`.

1. Tween both cards back toward their respective sides.
2. Show a dimmer or fully black treatment, to be chosen during authoring.
3. Play the film-projector light effect/filter.
4. Fade narrative text in/out, with curtains opening as part of the presentation.
5. Recount actual events phase by phase: initial choices, claims, honesty/deception, and subsequent actions. The creator's angelic/deceitful-heart examples establish tone, not a fixed script.
6. Remove the dimming treatment and show the creator-configured juicy outcome sequence.
7. Show “Tap To Continue”; tapping returns to the main menu.

Acceptance:
- [ ] The result is sent to and accepted by the server before the cinematic starts.
- [ ] Card retreat precedes the cinematic presentation.
- [ ] Narrative text describes real match events and distinguishes claims from actions.
- [ ] Dimming ends before the outcome sequence.
- [ ] The final tap returns to the main menu.

### Opponent Statistics and Saved Records

Source: scope.md > The POC Boundary.

Opponent choice/lie/switch percentages represent all relevant past matches. Without relevant history, show **N/A**. Example percentages are not default/fabricated player history. Preserve required player data and match records; the departed-human exception is owned by Disconnect and Bot Takeover.

Exact metric definitions were agreed during technical planning on 2026-10-21 and are owned by `spec.md > Lifetime Statistics and Derived Percentages`. Stored aggregates and their update/fetch contracts belong in the spec. This does not claim a verified database schema or require client-side retrieval of every raw match.

Acceptance:
- [ ] No-history percentages show N/A.
- [ ] Relevant lifetime history, rather than an arbitrary recent window, informs the percentages.

### Arena Chat

Source: scope.md > The POC Boundary and Explicitly Cut.

The tall right-center button opens a frontmost chat modal/overlay before the cinematic, including over card selection. It cannot be newly opened during the cinematic. Conversation is not accessible after the battle.

Bots do not respond to messages. Do not add bot chat replies. The creator's intent is an opponent who may simply be quiet.

Acceptance:
- [ ] The trigger opens chat above selection/dimming UI.
- [ ] Opening chat is unavailable during the cinematic.
- [ ] Messaging a bot produces no reply.

### Requested Scope Additions

The approved amended scope incorporates the creator's requested leaderboard, quests, competitive bot fallback, and takeover. Its original approval is preserved in review history; the creator approved the amended scope and this PRD together on 2026-10-21. Required human multiplayer has not been removed.

### Leaderboard

Four categories: **Overall Points, Win Rate, Lie Count, Honest Count**. Overall Rank was corrected to Overall Points, not a separate category.

Each match contributes at most one Lie or Honest count. Any false claim gives one Lie count; both truthful gives one Honest count. Two false claims still count once and advance a relevant lie quest once. Bot profiles populate the leaderboard and can gain rank through play; players see no bot label.

Acceptance:
- [ ] Exactly the four requested categories are available.
- [ ] Match-level lie/honest counting is mutually exclusive and does not double-count claims.

### Daily and Weekly Quests

Source: scope.md > The POC Boundary.

Daily quests appear above the central menu summary. Clearing one leads to another indefinitely, without a fixed daily cap. The quest view shows weekly quests and the current day's daily history; previous-day quests are no longer shown the next day. As specified by the creator on 2026-10-22, the daily reset is **05:00 GMT+7**, not midnight. Weekly refresh is **Monday at 05:00 GMT+7**, as explicitly confirmed by the creator on 2026-10-22.

Each newly appearing quest starts a fresh progress counter. Only qualifying play after that quest appears advances it; previous match records do not provide starting progress. Repeating a quest does not reuse progress from its earlier occurrence. The creator clarified the sequence “Play Scissors → Win 3 matches → Play Scissors”: the second Scissors quest requires a new Scissors play after it appears. This clarification on 2026-10-22 supersedes the earlier same-finished-match interpretation.

At the applicable reset, unfinished quest progress and completed but unpaid quest rewards both expire, as explicitly confirmed on 2026-10-22. Completing a quest at 04:59 and entering the menu at 05:01 does not grant its expired reward. Already-paid points are not part of this expiry rule.

Simple supplied objective families: play a specified RPS option a number of times; win; lose; draw; win by lying; win honestly; switch the initial card. “Lie 3x” and choosing Scissor in Phase 1 are supplied examples. Exact targets/content remain designer authoring.

Progress follows each objective. Losses/draws can count when relevant; there is no blanket win-only restriction. Rewards are extra ranking points, **automatically granted on entering the main menu**, once per completion. The suggested +2–5 remains provisional balancing, not a chosen range/default. No shop.

Acceptance:
- [ ] Cleared daily quests lead to further quests with no fixed cap.
- [ ] A new quest starts at zero and counts qualifying play after it appears. In “Play Scissors → Win 3 matches → Play Scissors,” the final quest requires a new Scissors play.
- [ ] Returning to the menu or retrying result processing does not replay past matches into a newly appearing quest.
- [ ] Current-day history and Monday weekly refresh follow the agreed calendar boundary.
- [ ] Relevant losses/draws advance their objectives.
- [ ] Menu entry automatically grants eligible rewards once; another visit alone does not grant them again.
- [ ] A reward completed at 04:59 but unpaid at the 05:00 reset expires and is not paid on a 05:01 menu visit.

## States and Boundaries

- **First entry/return:** automatic anonymous entry, first-login naming, saved progress for the remembered identity.
- **Login failure:** cause-specific wait/support or account-recreation recovery.
- **Search:** leave control and required timed bot fallback.
- **Selection inactivity:** full timers and explicit defaults; distinguish this from disconnection.
- **Disconnect before result commitment:** no saved departed-human result or reconnection; hidden bot takeover continues play.
- **Departure during cinematic/result:** retain the already-committed result; no match rejoin or presentation-resume feature is added.
- **Result:** cinematic story, outcome, and tap returning to menu.
- **Quest completion:** objective-specific progress and automatic menu-entry rewards.
- **Chat:** pre-cinematic opening only; inaccessible after the match.

## Product Decisions

- Deception concerns claims versus actions; timing/revisions provide deliberate information.
- Consistent defaults may produce a lie; they do not guarantee honesty.
- Fixed arena rewards replace multipliers; honest qualification receives the larger incentive.
- Anonymous browser-based identity, undisclosed competitive bots, silent bot chat, and no abandoned-match reconnection are intentional jam choices.
- The creator authors the reserved UI/animation/content; exact tuning is not invented here.

## What We're Building

The full submission boundary in scope.md: human multiplayer plus required fallback/takeover bots, ranked matchmaking, all arena/claim/change/reveal behavior, backend-held data/records, statistics/leaderboards, pre-cinematic chat, daily/weekly quests, and the specified presentation.

## Deferred From the POC

No previously required capability has been silently deferred. Content/tuning and technical agreements below remain pending, not permission to omit features.

## Possible Later Enhancements

An honesty safety net or additional raw lying rewards may be considered after playtesting. Their implementation/release placement is undecided. Extra quest content does not imply an administration tool.

## Non-Goals

- Post-battle conversation access.
- Cheat/game-throwing detection.
- Shop.
- Reconnection/resumption of an abandoned match.
- Bot chat replies.

## Open Questions

### Agreements for 4-spec

Percentage formulas, final-card mapping for winning-card statistics, and inclusion of draws in the win-rate denominator were agreed on 2026-10-21; see `spec.md > Lifetime Statistics and Derived Percentages`.

The technical spec was explicitly approved on 2026-10-22. Carry its interfaces and ownership forward; the remaining authoring inputs and implementation checks below do not reopen settled product rules:
- Exact rating-gap tuning, bot profile values/selection, and arena randomization parameters; starting human points, matchmaking metric, `.tres` bot approach, and retained takeover identity have been agreed in the spec.
- Verify the approved remaining-player state handoff and submission contracts in the spec. A pre-commit departure excludes that human and the takeover-bot side from saved updates. Result commitment is before cinematic start; cinematic departures do not forfeit it. No disconnected-player reconnection or restoration is in scope.
- Quest target/reward configuration, selection/repetition policy, and persistence responsibilities. Daily reset is agreed as 05:00 GMT+7; weekly reset is Monday at the same time. Each newly appearing quest starts a fresh counter and does not count prior match records, including previous occurrences of the same quest. Unfinished progress and completed unpaid rewards expire at the applicable reset.
- Creator input for final name-validation/support presentation. Identity, search-race and result-retry contracts are defined in the approved spec and must be verified during their assigned implementation.

These are not verified architecture, invented defaults, or permission for executors to decide consequential behavior silently.

### Creator Authoring and Remaining Presentation Decisions

Before affected presentation is implemented/verified, settle:
- First-login naming/continue staging; chat close behavior when the cinematic starts; final card disclosure/pacing and any skip behavior.
- Reserved animations/UI, final outcome/reward display, support destination/copy, visual assets, typography/colors, sound, and narrative wording.
- Exact daily/weekly quest content/targets and reward tuning within the agreed simple objective families.

Record creator choices in the owning document and resolve a consequential gap before implementing it. Routine implementation details remain for milestone executors within the agreed plan.

## Review Status

The creator explicitly approved the displayed consolidated PRD and amended scope together on 2026-10-21 (“Yep i approve”). `3-prd` is complete; the technical spec was subsequently approved on 2026-10-22. `5-build` checklist/milestone preparation is next, subject to the HUB's no-implementation boundary. Remaining technical agreements and creator authoring decisions above stay unresolved until agreed; approval does not imply implementation or verification.
