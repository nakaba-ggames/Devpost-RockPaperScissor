---
doc: spec
status: approved
updated: 2026-10-24
---

# Devil's Rock Paper Scissor — Technical Spec

Approved technical blueprint. The creator explicitly approved the displayed plan on 2026-10-22, including its labelled remaining-player handoff and pre-cinematic save-error proposals. All structures, commands, routes, and checks below remain planned unless explicitly identified as observations; approval establishes the intended design, not implementation or runtime compatibility.

## How This Works, In Plain Language

Godot presents the game. For a human match, one participating Godot client acts as host and coordinates phase deadlines, round progression, and bots. GD-Sync carries live decisions, announcements, chat, and synchronization between players.

The host submits the match history to the Vercel API. The backend checks that history against the game rules, calculates rewards, and prevents duplicate result processing. MongoDB retains profiles, records, aggregate statistics, and quest progress. Returning players retrieve their saved data through the API.

The creator accepted this trusted-host approach on 2026-10-21. The host can inspect hidden match information; validating submitted history does not prove a modified client reported it truthfully. A backend referee for every hidden decision is not the selected architecture. Cheat detection remains outside the approved product scope.

## The Core Journey Through the System

Implements `prd.md > The Core Journey`.

1. Godot displays the opening/title and contacts the API for anonymous entry. The API issues a random anonymous credential associated with a permanent player ID. Browser storage remembers the credential for returning requests.
2. The API retrieves saved profile, statistics, and quest information from MongoDB for the menu. First-login naming follows the PRD.
3. Ranked matchmaking connects two human players through GD-Sync, or starts the required fallback bot match. New human profiles start at 0 Overall Points, and that saved total is their matchmaking rating. Plugin integration, rating-gap values, and fallback-bot allocation remain to be specified.
4. The Godot host coordinates the arena condition, decision phases, defaults, and progression. Clients render their own animated presentation and send live messages through GD-Sync.
5. Once the final decisions are locked, Godot submits the actual match history. The backend checks and commits the result once, and returns its receipt before the cinematic starts. Godot narrates that committed history. Departing during the cinematic does not forfeit or undo the result; no player reconnection/resume is introduced.
6. Menu entry retrieves current data and grants eligible quest rewards once. Each newly appearing quest starts its own zero counter and counts subsequent qualifying play; a previously finished match is not replayed into it. Exact persistence/retry contracts remain to be completed.

## Stack

| Responsibility | Direction | Status |
| --- | --- | --- |
| Game client | Godot 4.x, GDScript, single-threaded portrait web export | Creator requirement; local configuration lists 4.7 and GL Compatibility, not a verified engine/export version |
| Live networking | GD-Sync, Free plan; local candidate declares 1.0.2 | Approved latest-compatible-stable policy; local package presence observed on 2026-10-22, activation/provenance/connection not verified |
| API hosting | Vercel Functions, TypeScript on Node.js | Creator agreed on 2026-10-21; runtime/driver versions and deployed configuration remain unverified |
| Persistent storage | MongoDB Atlas Free with the official Node.js driver | MongoDB/driver and managed Free hosting approved on 2026-10-22; deployed configuration and exact driver version unverified |
| Browser distribution | Vercel | Creator-selected; deployment layout and export setup unresolved |

Godot's HTTP request facilities are a candidate for API communication, separate from GD-Sync's live messaging. TypeScript/Node.js and the official MongoDB driver were explicitly accepted by the creator on 2026-10-21. GDScript remains the game-client language; the backend has its separately agreed TypeScript stack.

### Service Selection and Version Policy

On 2026-10-22 the creator requested AI guidance for service setup and expressed a preference for the latest versions. The following baseline was accepted in the full-spec review on 2026-10-22; this does not claim that accounts/resources exist:
- **GD-Sync Free:** covers two-player lobbies within its documented four-player lobby allowance. The official Asset Library currently lists **1.0**, updated 2026-09-11. At installation, check the current stable listing against the actual Godot engine and pin the package/revision tested. Avoid prereleases and unreviewed mid-build updates.
- **MongoDB Atlas Free:** a managed database avoids adding database-server administration to this jam. Its documentation currently specifies MongoDB **8.0**, managed upgrades, 0.5 GB storage, and a maximum of 500 connections. The tier controls the server version; “latest” does not mean forcing a different server release onto it. Choose an available region close to the Vercel API region.
- Pin a Vercel-supported Node.js LTS runtime and a compatible stable official MongoDB driver during backend setup; commit the package lockfile. Exact runtime/driver versions have not yet been selected or installed.
- Use GD-Sync for live networking. Keep the agreed custom anonymous profiles, records, statistics, quests, and leaderboards in MongoDB through Vercel; do not introduce a second account/save system merely because GD-Sync offers one.

**Capacity uncertainty:** GD-Sync's current pricing page conflicts internally: the Free card says 5 GB/month, while its comparison table/FAQ and 1.0 release notes say 200 MB/day. Confirm the account's enforced allowance before the public test. Its service is capacity-limited; no unlimited-capacity promise is adopted. Measure actual two-player traffic before estimating supported match volume or proposing a paid upgrade. No paid plan is selected by this plan.

**Updated local observation, 2026-10-22:** `addons/GD-Sync/plugin.cfg` is now present and declares **1.0.2**. The local project plugin list still contains only the MCP toolkit and the main scene remains unset. The earlier Asset Library 1.0 observation is retained as dated external evidence, not a reason to downgrade this candidate. M01 must verify package provenance/compatibility, configuration and a real service connection; presence alone proves none of those.

References: [GD-Sync Asset Library listing](https://godotengine.org/asset-library/asset/2347), [GD-Sync plans](https://www.gd-sync.com/plans), [1.0 release notes](https://www.gd-sync.com/patch-notes/patch-notes-1-0), [Atlas Free deployment](https://www.mongodb.com/docs/atlas/tutorial/deploy-free-tier-cluster/), [Atlas limits](https://www.mongodb.com/docs/atlas/reference/free-shared-limitations/).

## Where It Runs and How Someone Tries It

The player target remains a portrait, mobile-ready, single-threaded browser game. Resource filtering, assertion review, animation and release-browser checks follow [AI_Bootstrap.md](../docs/AI_Bootstrap.md). Initial planning observations are historical; the checklist/reports own actual implementation evidence.

**Creator-approved architecture revision, 2026-10-24:** use **two separate Vercel projects/repositories**. The backend deploys API functions connected to Atlas with Root Directory **`backend`** and Output Directory **`static-api-only`**; it must not require/upload the Godot export. The creator separately deploys/tests the Godot frontend. This supersedes the original combined `backend/public` + API same-origin plan. Existing ignored exports may be retained for historical/local purposes, never as a backend deployment dependency. The generated `.tres`-derived configuration artifact lets backend-only builds run without Godot installed.

Revised M12 closes **Backend deployment preparation** on existing commits and the creator's successful Vercel deployment/build confirmation. This does not verify hosted API runtime, Atlas access from functions, or the Godot-to-hosted-backend journey. M12.5 finishes the existing adapters with the following ordered interface:

1. Confirm the exact already-deployed backend HTTPS base URL, deployment/config revision and server-only environment; do not infer a hostname from the chosen project name. Keep MongoDB credentials and anonymous credentials private.
2. Configure Godot's native/editor and web API adapters explicitly for that backend. The current native loopback/web `window.location.origin` behavior is unfinished integration under the new architecture. Add appropriate backend CORS/preflight for actual local and eventual separate frontend origins and used Authorization/JSON methods; document the actual origin policy. Do not use the frontend's `/api` or a local API as a hidden substitute.
3. **A:** open the Godot project in the editor and run the native client against those deployed functions. Complete real versus-COM gameplay and every applicable backend-powered feature with actual bot identities and saved data. Resolve integration failures before web acceptance.
4. **B:** export the filtered single-threaded Web release once to an ignored local frontend-test destination, serve it over local HTTP, and repeat applicable gameplay/features against the **same deployed functions**. Verify real browser CORS, storage/reload and saved progress; record a failed candidate as incomplete acceptance rather than starting a repeated-export campaign. No backend deployment receives this package.
5. Obtain the required creator editor/local hands-on feedback, resolve in-scope integration failures, write local-test/endpoint evidence and complete M12.5. Say “Ready for your frontend deployment/testing” and stop. The creator performs hosted frontend deployment/testing separately; it is not an M12.5 completion gate.

Do not expand M12.5 into hosted-frontend verification, device matrices, exhaustive campaigns or earlier-suite repetition. Record human-only/unexercised endpoints and limitations honestly; COM is not evidence for human matchmaking, peer binding/chat or takeover. Later presentation/polish/SFX/music, Final Review, learning wrap-up/app map and submission work remain open and outside this assignment. The full product boundary remains in the PRD; this revision changes milestone acceptance and deployment ownership, not gameplay requirements.

## Look and Feel

Implements `prd.md > Look and Feel`. Carry forward the casino table, premium portrait UI, suspenseful cinematic reveal, and animation from initial implementation. Follow the `.tres` tuning, base/inherited scene, existing-placeholder-asset, and creator-reserved authoring constraints in [AI_Bootstrap.md](../docs/AI_Bootstrap.md). Planned scene families and Resource grouping are described below; no new visual direction is chosen here.

## Components

### Godot Presentation

Displays entry, menu, arena, chat, statistics, records, leaderboard, quests, and cinematic/result views. It presents data from the match coordinator and API rather than independently awarding persisted points. Implements `prd.md > Screens and Layout`, **Look and Feel**, and **Phase 5 — Narration, Reveal, and Result**.

### Shared Scenes and Tuning Resources

Implements `prd.md > Look and Feel`, **Screens and Layout**, and all phase presentations. Use a small number of useful base/inherited scene families: a common card scene with RPS and Keep/Switch variants, and a common modal shell with Stats, Records, Leaderboard, and Quests variants. Exact node composition and routine filenames remain executor choices; meaningful shared structure belongs in the base, not duplicated across variants.

Group adjustable Resource `.tres` data by responsibility: round/scoring rules, matchmaking, bot personalities, quest definitions, UI motion, and narrative/presentation pacing. Preserve the PRD's agreed numeric values; do not treat unconfigured balancing fields as permission to invent creator decisions. Creator-authored content/values must be supplied or agreed before the affected behavior is implemented.

**Approved configuration boundary:** keep designer-authored tuning in `.tres`. Export the backend-relevant rule/quest fields into a generated, versioned deployment artifact. The Node backend reads that artifact; it does not independently hand-maintain a competing set of point/quest constants or trust payout values submitted by the client. Match registration/finalization carries the known rules revision. JSON is permissible as API wire format or generated backend deployment data; it is not the authored Godot game-data source.

### HTTP API Client

Implements `prd.md > Opening and Anonymous Entry`, **Main Menu and Player Information**, **Detailed Statistics and Records**, **Opponent Statistics and Saved Records**, **Leaderboard**, and **Daily and Weekly Quests**. Use Godot HTTPRequest asynchronously with client threading disabled. Keep request scheduling, authentication headers, response parsing, cancellation, and error signals in one small adapter; gameplay/presentation scripts consume typed results/signals. Configure the deployed backend HTTPS origin explicitly for native and web through Inspector-exposed Resource settings; separate frontend/local web origins require appropriate backend CORS/OPTIONS, including Authorization/Content-Type and applicable success/error responses.

Return empty-history states from actual data, and distinguish transport/server errors from invalid-account errors. Never replace remembered credentials merely because a request timed out. Keep the anonymous credential local to API calls; no MongoDB connection string is shipped in the game.

### Godot Match Coordinator

The host coordinates phase deadlines, arena progression, and bots. It maintains the actual initial/final decisions and claims needed for reveal and result submission. Implements `prd.md > Arena Intro and Conditions`, **Decision Announcements and Phase Progression**, **Phase 1 — Option** through **Phase 4 — Change**, and **Disconnect and Bot Takeover**.

Before result commitment, the remaining player's existing bot-takeover requirement needs the accepted phase/claim history even when the departed player held the host role. GD-Sync host selection alone does not establish that this history survives. This is continuation for the still-connected opponent, not reconnection or restoration of the departed player. The departed player's displayed identity is retained. Only the remaining human receives saved result updates; neither the departed human nor a takeover-bot profile is credited for that pre-commit departure.

**No player recovery:** the creator explicitly reiterated on 2026-10-22 that a disconnected player loses participation and cannot reconnect or resume. Do not create reconnect endpoints, restoration screens, resume tickets, or a grace period.

**Approved remaining-player handoff:** replicate the minimal complete accepted match state needed for the original bot-takeover requirement to the still-connected peer. The implementation retains hidden choices in that peer's memory but never exposes them early in normal UI or to bot decision policy. A modified client could inspect that state. The creator explicitly approved this labelled proposal in the full-spec review on 2026-10-22. This supports the remaining player's bot continuation and never permits a departed player to reconnect or resume.

### Result Commitment Before the Cinematic

Implements `prd.md > Disconnect and Bot Takeover`, **Points and Match Classification**, and **Phase 5 — Narration, Reveal, and Result**. The creator explicitly specified on 2026-10-22 that the server receives the result before the cinematic is triggered and a departure during the cinematic does not forfeit it.

Approved technical contract:
1. Close the last decision phase, freeze the accepted history and pre-commit departure eligibility, and submit finalization under the registered match ID.
2. The backend validates that history/rules revision, calculates the eligible results, commits the result/aggregate/quest-progress writes once, and records `committedAt` plus a stable receipt. Do not pay quest rewards here; the PRD still requires menu-entry payment before their expiry.
3. A server acknowledgement establishes that the result is known and stored. Merely starting an HTTP request does not prove receipt. Gate cinematic start on the committed receipt; both clients can read it independently if the host leaves after commitment.
4. The cinematic and outcome display read the committed history/result. A later disconnect cannot rewrite eligibility, award a forfeit, or undo either participant's already-committed result.
5. A pre-commit departure remains subject to the agreed forfeiture/no-save and bot-continuation rules. For an uncertain HTTP response, query/retry the same match ID to establish whether commitment already happened; never infer loss or success solely from a client-side timeout.

**Approved save-failure presentation:** hold at an animated pre-cinematic waiting/error state while acknowledgement is unavailable. Retry/query the same operation, expose a clear retry/error presentation, and never fabricate saved points. Retry timing belongs in `.tres`; final copy/layout is authoring work. This is delivery of an already-finished round's result, not reconnection to an abandoned live match. The ordering and this labelled error-handling proposal were accepted in the full-spec review on 2026-10-22. Final copy/layout remains creator authoring work.

### Bot Controller and Personality Resources

Implements `prd.md > Ranked Matchmaking` and **Disconnect and Bot Takeover**. The creator accepted configurable bot personality profiles on 2026-10-21 and reiterated that `.tres`-driven development applies throughout the game.

Use custom Resource `.tres` profiles for RPS preferences, lying/switching tendencies, and hesitation/revision timing. Bot decisions use their own choices/history and public information; the bot policy must not read the human opponent's hidden card, even though the trusted host can technically inspect it. Concrete weights, timing values, and selection policy remain authoring/configuration work, not invented defaults.

A pre-commit takeover continues the existing side's phase/claim history rather than resetting the round. Preserve the departed player's displayed identity for the remainder of that match without a replacement notice. Display identity, personality Resource, and persistent leaderboard account are distinct concerns. As clarified by the creator on 2026-10-21, a takeover side receives no saved result updates: no win/loss/draw entry, point award, statistics, or quest progress is credited to a takeover-bot profile or the departed human. The remaining human receives normal result processing. An ordinary fallback bot participating from the start still receives its own normal competitive updates.

### GD-Sync Integration

Carries live decisions, announcements, chat, and synchronization between human participants. Implements `prd.md > Ranked Matchmaking`, **Decision Announcements and Phase Progression**, and **Arena Chat**. Bot policy is game logic, not supplied by choosing a networking plugin. Exact messages, ordering, visibility, matchmaking configuration, and cancellation handling remain to be specified.

### Ranked Matchmaking Coordinator

Implements `prd.md > Ranked Matchmaking`, **Points and Match Classification**, and **Leaderboard**. Agreed on 2026-10-21:
- New human profiles start at **0 Overall Points**.
- Their saved **Overall Points** total is used as the matchmaking rating.
- Losses award **0** points; there are no match-loss deductions. The point balance never goes below **0**. Arena and quest rewards follow their owning PRD sections.
- The allowed rating gap, maximum gap, and widening rate during search are tunable custom Resource `.tres` fields. Exact values remain creator-controlled configuration, not invented defaults.

GD-Sync documents skill matching for its matchmaking queue; public-lobby searches do not apply that skill filter. Use a queue path that enforces the requested rating policy rather than an unfiltered public-lobby shortcut, subject to verifying the installed plugin API. The required randomized 30–45-second fallback, cancellation handling, and single-match reservation must be coordinated; an exact cancellation/reservation protocol is still to be specified.

### Vercel API and MongoDB Persistence

Handles saved profiles/data and backend calculation of results, aggregates, and quest progress. Implements `prd.md > Opening and Anonymous Entry`, **Main Menu and Player Information**, **Detailed Statistics and Records**, **Points and Match Classification**, **Opponent Statistics and Saved Records**, **Leaderboard**, and **Daily and Weekly Quests**.

Rule checks and duplicate prevention apply to reported history; they do not convert a trusted-host match into independently verified server gameplay. Exact routes, payloads, schemas, indexes, and atomic update/retry design remain to be specified. Anonymous credential ownership is defined below; detailed request contracts remain to be completed. The departed-human no-save rule must apply to records, points, counters, and quests alike.

### Daily and Weekly Quest Coordinator

Implements `prd.md > Daily and Weekly Quests`. The backend owns persisted quest progress and once-only reward processing; the menu displays the returned current quest/history and eligible grants.

The creator specified the daily reset as **05:00 GMT+7** on 2026-10-22; player-facing calendar behavior is owned by the PRD. This corresponds to 22:00 UTC on the preceding UTC date. Use the specified fixed offset and cutoff when identifying daily quest periods, rather than the browser's local midnight. This is a planned contract, not verified backend behavior.

Weekly refresh is **Monday at 05:00 GMT+7**, explicitly confirmed on 2026-10-22. The creator confirmed that both unfinished progress and completed but unpaid rewards expire at the applicable reset. A completion at 04:59 followed by menu entry at 05:01 receives no quest reward. Apply the reset cutoff before determining which pending rewards can be paid; make expiry and payment mutually exclusive under concurrent requests. This does not subtract rewards already paid before reset.

The creator clarified on 2026-10-22 that each newly appearing quest starts a fresh progress counter and counts qualifying play after it appears. Previous match records are not entry counters, even if that quest appeared earlier. In “Play Scissors → Win 3 matches → Play Scissors,” the second Scissors quest requires a new Scissors play. This supersedes the earlier same-finished-match interpretation and removes the need for the proposed per-template replay rule.

Give each assigned quest instance its own ID, zero starting counter, and activation boundary. Update it only from eligible subsequent match events; make each event contribution and reward grant idempotent. Do not initialize progress from lifetime statistics, reuse an earlier instance's counter, or replay a finished/retried match into the newly assigned daily quest. A qualifying match can still advance multiple quests that were already active, such as the current daily and weekly objectives. These are planned persistence responsibilities, not verified backend behavior. Reward values, general quest selection/repetition, and exact API contracts remain to be completed.

## Data Ownership

| Data | Agreed responsibility | Contract still needed |
| --- | --- | --- |
| Live phase progression, choices, claims, bot control | Godot host, synchronized through GD-Sync as appropriate | Visibility, revision/deadline protocol, migration and takeover |
| Saved profile and browser identity association | Backend owns the permanent player ID and anonymous credential association; browser stores the issued credential | Request contract, recreation, name validation |
| Persisted rewards and aggregates | Backend calculates; MongoDB stores; client displays | Metric definitions agreed below; idempotent writes and retry contract still needed |
| Match records and quest progress | Backend/MongoDB; survivor-only updates for takeover matches | Schema, quest calendar/event order |
| Match chat | Live delivery through GD-Sync | Message contract and retention/disposal policy; no post-match player access |
| Designer-adjustable game/presentation tuning | Godot `.tres` Resources | Grouping and authoritative backend rule/configuration alignment |

### Anonymous Identity and Credentials

Implements `prd.md > Opening and Anonymous Entry`. Agreed on 2026-10-21:
- The backend issues a random anonymous credential associated with a permanent database player ID.
- Browser storage retains the credential; returning API requests use it without a password prompt.
- Clearing the remembered browser data means creating a new anonymous account for this jam. Account recovery/cross-device transfer is not added by this design.
- A permanent player ID identifies a profile; the credential authorizes its API access. Do not transmit this credential as opponent-visible GD-Sync player/lobby data or include it in match history/reports.
- The backend keeps database credentials on the server. The game accesses saved data through the API rather than connecting directly to MongoDB.

The existing PRD recovery distinction remains: server failure leads to wait/support; account error offers explicit recreation without silently migrating or deleting the previous profile. Endpoint shapes are defined under **Backend API**. Credential storage/network behavior must be verified during implementation; name constraints and final entry copy remain creator-controlled authoring inputs before the affected UI/API work.

### Lifetime Statistics and Derived Percentages

Implements `prd.md > Main Menu and Player Information`, **Detailed Statistics and Records**, **Opponent Statistics and Saved Records**, and **Leaderboard**. The creator explicitly accepted these definitions on 2026-10-21.

Let `N` be the number of completed matches credited to the profile under the agreed result-attribution policy; `W`, `L`, and `D` are its wins, losses, and draws, so `N = W + L + D`. Pre-commit departed-human matches excluded by the PRD do not enter that human's counters or denominators. A departure during the cinematic does not remove an already-committed match from those counters. The takeover-bot side is excluded from saved results and denominators as agreed; the remaining human's normal result is included.

| Displayed metric | Definition |
| --- | --- |
| Win rate | `100 × W / N`; draws are included in the denominator |
| Winning Rock/Paper/Scissor percentage | `100 × wins with that final card / W`; each win contributes its Phase 4 final card |
| Lying win percentage | `100 × lying wins / W` |
| Honest win percentage | `100 × honest wins / W` |
| Opponent initial-card tendency | `100 × initial choices of that card / N`; uses Phase 1 |
| Opponent lie tendency | `100 × matches containing at least one false claim / N` |
| Opponent switch tendency | `100 × matches where final card differs from initial card / N` |

Show **N/A** when the relevant denominator is zero. Match-level lying/honesty classification follows `prd.md > Points and Match Classification` and **Leaderboard**; two false claims still count once. Intermediate revisions do not count as an actual switch if the final card equals the initial card.

The backend maintains lifetime counters and their derived percentage fields when eligible results are saved. Clients fetch the stored aggregates rather than downloading and recalculating all raw matches. These are planned fields and update responsibilities, not an observed MongoDB schema or verified persistence implementation.

## Data Model

Planned structures derived from the approved ownership; these are not existing collections. Names may change within a milestone if the contracts remain intact.

| Structure | Important fields and lifecycle |
| --- | --- |
| Player profile | Stable `playerId`, human/bot kind, `displayName`, human credential hash, `overallPoints`, W/L/D counts, win streak, initial/final card counters, lying/honest match and win counters, switch count, derived percentage fields, revision/timestamps. New humans use the agreed zero-point start. Bot identity and personality Resource ID are separate. |
| Match registration/result | Unique `matchId`/registration nonce, known rules revision, participant bindings, displayed-name snapshots, initial control kinds, departure/takeover facts, `RoundLog`, eligible saved-result recipients, calculated outcomes/rewards, finalization status, `committedAt`, and a stable receipt. A shared record for the remaining human may include the opponent's displayed identity/choices without becoming a saved match entry for the departed human. |
| Quest instance | Unique `questInstanceId`, owner, definition ID, daily/weekly period, activation boundary, target/current counter, completion time, expiry, reward amount from the known definition, paid/expired status, and contribution identifiers. New instances start at zero; paid/expired status is mutually exclusive. |
| Client session | Browser-stored anonymous credential; current profile/menu snapshot; current networking/match context. Display caches are replaceable and are not authoritative saved progress. No abandoned-match resume is offered. |
| Chat session | Ordered in-memory messages for the current match, disposed when leaving it. No backend chat archive or bot replies are introduced. |

`RoundLog` separates each actor's `initialCard`, `identityClaim`, `switchClaim` (`keep`/`switch`), and `finalCard`, plus starting card order and phase decision/revision events. Events identify phase, actor, sequence/revision, and host-relative timing so accepted decisions can drive announcements and narration. Keep actual choices separate from claims and do not infer hidden choices from table position.

Use unique identifiers for profiles, registrations/results, and quest instances; index records by eligible saved-result recipient and completion time, quests by owner/period, and each leaderboard's sort fields. Avoid unbounded match/daily-history arrays inside a player document. Return only the authenticated player's eligible records and the requested current quest periods.

Approved backend write strategy: a short MongoDB transaction finalizes a result once and applies eligible profile/quest updates together. Replays return the original calculated outcome; a conflicting second history is rejected. Menu-entry reward settlement similarly checks period expiry and pays each eligible quest instance once. Reuse a bounded MongoClient pool across warm function invocations. Validate this on the chosen Atlas deployment; neither transactions nor pooling are verified here. See [MongoDB transactions](https://www.mongodb.com/docs/drivers/node/current/crud/transactions/) and [Atlas/Vercel integration](https://www.mongodb.com/docs/atlas/reference/partner-integrations/vercel/).

## Interfaces

### Backend API

Approved application contracts, derived from the agreed stack. Use HTTPS in deployment and JSON request/response bodies. Except for new anonymous-account creation, authenticate private operations with the remembered anonymous credential in an Authorization header. Do not authorize private access from a supplied player ID alone. Error bodies use a stable code/message plus retryability; response shape details below can be expressed as shared backend types during implementation.

| Endpoint | Request | Response/responsibility |
| --- | --- | --- |
| `POST /api/anonymous` | `{mode: create|resume}`; resume includes the credential header | `{playerId, profile, needsDisplayName}`; creation also returns the new credential. Invalid resume produces an account error; creation after failure requires the PRD's explicit recreation action. |
| `PATCH /api/profile` | `{displayName}` | Validated public profile. Name constraints/copy must be agreed for the entry UI; never interpret names as markup. |
| `POST /api/menu` | `{requestId}` for a genuine menu entry | `{profile, stats, dailyQuest, weeklyQuests, dailyHistory, grants, serverTime, periods, rulesRevision}` after expiry and once-only reward settlement. Do not use client wall-clock time to decide eligibility. |
| `POST /api/matches/register` | `{matchNonce, lobbyId?, peerPlayerId?, fallbackRequested, rulesRevision}` | `{matchId, participantBindings, opponentPublicProfile, botPersonalityId?, rulesRevision}`. Bind the authenticated initiating human; allocate a fallback bot through backend-owned profiles when requested. Human peer binding must finish before arena start. Exact bot-selection tuning remains authoring work. |
| `POST /api/matches/join` | `{matchId, matchNonce}` from the other human's own credential | Confirmed participant bindings/public opponent snapshots. Prevent another account from overwriting an already-bound participant. Bot matches need no second human join. |
| `POST /api/matches/finalize` | `{matchId, roundLog, departures, rulesRevision}` from a bound eligible human | `{matchId, status, savedResult}` calculated by the backend; never accept a client-supplied final point balance. Apply the departed-human/takeover exclusions. Finalize once before cinematic start and return its committed receipt; later cinematic departures do not alter eligibility or the result. |
| `GET /api/matches/result?matchId=…` | Registered participant credential | Committed receipt/result for that participant, or explicit not-yet-committed status. Supports acknowledgement after an uncertain response and the connected peer's cinematic gate; it does not rejoin or resume a live match. |
| `GET /api/player?playerId=…` | Public player ID | Public display information and lifetime aggregates; no credential, private quest state, or private record history. |
| `GET /api/leaderboard?metric=…&cursor=…&limit=…` | One of `overallPoints`, `winRate`, `lieCount`, `honestCount`; bounded page size | `{entries, nextCursor}` using stored profile aggregates. No extra rank category, fabricated personal history, or player-facing bot labels. |
| `GET /api/records?cursor=…&limit=…` | Authenticated owner, bounded page size | `{records, nextCursor}` with opponent display snapshot, initial and final cards for both sides, and result. Exclude entries not eligible for this owner's saved history. |
| `GET /api/quests` | Authenticated owner | Active daily/weekly instances and current-period daily history after applying reset boundaries. Reading the quest view does not add a manual claim button or replay old match events. |

The backend service uses MongoDB's official driver rather than a separate public database HTTP API. Store its connection URI and database credentials in server environment configuration. Exact account/network configuration is a setup dependency; the native Atlas/Vercel integration's connectivity behavior must be reviewed against the selected account setup rather than assumed already provisioned.

### Staged Development Providers

The creator supplied a flow-first implementation order on 2026-10-22: rough menu, simulated matchmaking, gameplay in 2–3 milestones, cinematic/result, submenus in 2–3 milestones, full GD-Sync integration, two backend-development milestones, then one backend-integration milestone. They subsequently explicitly approved the displayed 12-milestone distribution in `../docs/Milestones.md`, with one-to-one progress slices in `checklist.md`, as part of the four-document workflow review on that date (“Sure”).

Use thin identity/profile, match lifecycle/events, data-query/menu-entry and result-finalization/receipt contracts. The early development providers return the same shapes/events the real integrations will supply; routine class/file choices remain for executors. Do not build a generic injection framework or a second account system.

- M01 proves an actual GD-Sync SDK service connection while the custom backend authentication uses a labelled development provider. A service connection is not MongoDB/Vercel account authentication.
- M02–M08 use controlled development matchmaking/opponent/data/result adapters. Their simulated receipts can drive the pre-cinematic acknowledgement contract but never establish real server persistence.
- M09 uses actual GD-Sync peer/match/chat transport, including ordinary fallback and remaining-player takeover, while profile/rating/bot roster data and result persistence are still development providers.
- M10–M11 provide independently runnable real API evidence in the requested backend stage. Revised M12 preserves deployment preparation and substantial initial client integration; M12.5 reuses/finishes it and verifies editor/native then locally served web COM gameplay against deployed functions. Separate hosted frontend testing belongs to the creator afterward. Earlier localhost human/takeover evidence is not deployed-function evidence.

Development fixtures must be isolated and identified in evidence, never imported as real personal match history or left as production fallbacks. The final game still requires the approved anonymous backend identity, live human matchmaking, real result commitment before cinematic start, persistent data, quests and submission presentation. Early rough UI retains basic tweens and `.tres` tuning; creator-authored opening/matchmaking/outcome choreography can follow its functional foundations.

Clear Data follows `prd.md > Main Menu and Player Information`: reset only this game's local browser cache/data for testing, with no backend account mutation or deletion. No backend deletion endpoint is required. Clearing the remembered anonymous credential follows the existing identity contract; the old backend profile remains.

### Live Match Messages

Planned message envelope: `{matchId, phase, actorId, sequence, revision, payload}`. Reject messages for another match/phase, an unexpected actor, an old revision, or a phase whose host deadline has passed. Do not let a presentation tween determine the authoritative deadline.

- **Decision update:** actual choice/claim submitted to the host; the host orders revisions. Public updates drive the PRD's decided/changed announcements and reveal only phase-permitted presentation.
- **Phase start/lock:** host supplies the phase/deadline and final accepted/defaulted phase values. Both clients retain the fixed 15-second windows and agreed defaults; both deciding never advances early.
- **Remaining-player handoff state:** phase, deadline, accepted history, actor control/departure status, and rules revision, solely to support the already-required bot continuation. Hidden-field replication follows the approved boundary under **Godot Match Coordinator**; no departed-player reconnect/resume protocol is added.
- **Chat:** sender, sequence, and plain message text, available only in the PRD's permitted arena window. Keep it out of saved match/quest payloads.
- **Result readiness/receipt:** committed final history and the backend receipt before cinematic start. After commitment, peer departure does not roll back the result; the connected client can obtain its receipt directly from the API.

GD-Sync wrapper integration should use its documented connection/lobby signals, MatchmakingRequest skill queue, `call_func_on`/host-targeted calls, and `host_changed` notifications, checking exact signatures against the pinned package. Keep the game-facing adapter independent of plugin-specific details. This is a small explicit phase controller, not an elaborate state-machine framework.

For cancellation versus a late human match/fallback timeout, keep one active search generation and a single committed match reservation. Ignore stale callbacks, await relevant GD-Sync cancellation/leave confirmation before starting a bot match, and never register both outcomes as active matches. Verify the race with actual delayed callbacks; no successful verification is claimed.

## File Structure

Approved planned source layout, not existing implementation. The parent repository contains the Godot project and sibling backend folder; the latter needs its own milestone workspace/write authorization when implemented. Routine filenames may be adjusted while retaining the documented component boundaries.

```text
Devpost-RockPaperScissor/
├── rock-paper-scissor/
│   ├── project.godot
│   ├── scenes/
│   │   ├── main.tscn                 # Entry and screen ownership
│   │   ├── screens/                  # Title, menu, matchmaking, arena/reveal
│   │   └── ui/                       # Base cards/modal shells + inherited variants
│   ├── scripts/
│   │   ├── app/                      # Session/profile context and navigation
│   │   ├── api/                      # Asynchronous HTTP adapter and response handling
│   │   ├── networking/               # GD-Sync adapter and search lifecycle
│   │   ├── game/                     # Round rules, phase coordinator, bot controller
│   │   └── resources/                # Typed custom Resource definitions
│   ├── resources/
│   │   ├── rules/                    # .tres round/scoring and matchmaking tuning
│   │   ├── bots/                     # .tres personality definitions
│   │   ├── quests/                   # .tres objectives/targets/rewards
│   │   └── presentation/             # .tres motion, transitions, narrative pacing
│   ├── Graphics/                     # Existing art; export only required assets
│   ├── addons/                       # Existing MCP; pinned GD-Sync when installed
│   ├── tools/                        # Planned Resource-to-backend config exporter
│   ├── docs/                         # Vision, bootstrap, later milestone plan/reports
│   └── devpost/                      # Scope, PRD, spec, later checklist; profile ignored
└── backend/
    ├── api/                          # Named TypeScript routes in Backend API
    ├── src/
    │   ├── auth/                     # Anonymous credentials and profile validation
    │   ├── matches/                  # Registration, result checking, once-only writes
    │   ├── quests/                   # Fresh counters, period expiry, reward settlement
    │   ├── stats/                    # Aggregate updates, leaderboard/record queries
    │   └── db/                       # MongoClient reuse and typed stored structures
    ├── config/backend-config.json    # Versioned deployment data derived from .tres
    ├── static-api-only/              # Empty static output; API-only backend deployment
    ├── public/                       # Historical ignored local exports; excluded from deployment
    ├── package.json                  # Planned dev/build/typecheck scripts
    ├── package-lock.json             # Exact dependency resolution
    ├── vercel.json                   # API-only backend; frontend deployed separately by creator
    └── .env.example                  # Variable names only, no real credentials
```

## Important Failure Modes

- **Login/API unavailable:** preserve the remembered identity and show the PRD's server wait/support state. An invalid account exposes explicit recreation. Final support destination and retry presentation remain creator authoring decisions.
- **Networking cancellation, peer loss, or quota failure:** do not create duplicate human/bot matches or reconnect an abandoned participant. Continue with takeover only when a remaining connected human can maintain the required match history. Quota-wide failure is not proof of a working takeover; the remaining-player state handoff must be verified. Do not invent lost choices or restore a departed player.
- **Repeated/partial backend writes:** stable match/quest IDs, transaction boundaries, and expiry checks prevent double points or stale reward payments. A network timeout is not evidence that a write failed. Retry the same operation ID and fetch its prior result; never invent local persisted credit.

Before cinematic start, unavailable or uncertain persistence follows the approved acknowledgement/retry contract in **Result Commitment Before the Cinematic**. After commitment, disconnecting or closing the presentation does not revoke the result. No returning-player recovery feature is introduced.

## Verification Expectations

These are project-wide verification expectations, not checks performed by this HUB. **M12.5 scope override (creator-approved 2026-10-24):** follow the ordered editor/native COM → one local web export checks and actual hands-on feedback in `docs/Milestones.md > M12.5`. Preserve inherited binding/revision/chunk/departure contracts and report COM-unexercised endpoints; broader human/takeover, edge, hosted frontend and device evidence below is not an M12.5 gate and must not be claimed from COM tests. Reuse prior reset-boundary evidence and do not repeat earlier suites. Final Review remains open.

Project-wide expectations retained for their owning checks:
- First entry, returning browser identity, invalid identity, server failure, and explicit recreation; verify credentials stay outside shared match/public data.
- Two distinct human accounts through live skill matchmaking, full phase windows/revisions/defaults, and real backend saves. Separately verify fallback bots and takeover when either host or non-host disconnects. Report each category honestly.
- Host/peer timing, stale messages, cancellation at human-match arrival, and result-submit retries; confirm no duplicate match or point writes. Verify receipt-before-cinematic ordering, uncertain responses, and departures on each side of commitment: pre-commit forfeiture rules versus an unchanged committed result during the cinematic.
- Scoring/classification/aggregate rules using meaningful examples from the PRD, including mixed claims, draws, default-induced lies, initial versus final cards, and the nonnegative point floor.
- Daily 04:59/05:00/05:01 and Monday boundaries; fresh quest counters; repeated objectives needing new play; unpaid reward expiry; no double grant on menu revisits. Use a controlled backend clock in checks rather than the browser's date.
- Single-threaded release export: actual two-browser GD-Sync connection, no threads required by the chosen plugin paths, only required assets packaged, assertions free of required side effects, and no stuck phase/animation/result path. Record browser/device versions, logs and observed behavior, plus limits in GD-Sync traffic and Atlas connections.
- MCP-supported scene/editor/runtime inspection within each assigned milestone; an explicitly requested HUB audit may verify a report. Do not execute a build or audit just because these checks are documented.

## External Services and Dependencies

Official references inspected during planning on 2026-10-21 and 2026-10-22:
- [GD-Sync architecture and setup](https://www.gd-sync.com/docs/getting-started): peer/host gameplay; not a hosted game-rule referee.
- [GD-Sync clients and host selection](https://www.gd-sync.com/docs/clients): host reassignment is documented; application history transfer still needs a game design.
- [GD-Sync matchmaking](https://www.gd-sync.com/docs/matchmaking): skill matching is documented for its queue; integration remains unverified.
- [GD-Sync platform support and transfer limits](https://www.gd-sync.com/docs/general-information): HTML5 support is documented, with transfer allowances; no unlimited-capacity claim is adopted.
- [Godot HTTP requests](https://docs.godotengine.org/en/stable/tutorials/networking/http_request_class.html).
- [Godot web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html).
- [Vercel Node.js runtime](https://vercel.com/docs/functions/runtimes/node-js) and [MongoDB Node.js driver](https://www.mongodb.com/docs/drivers/node/current/): the creator accepted TypeScript/Node.js with the official MongoDB driver; these references do not establish a deployed integration.

The approved Free-service baseline and its documentation limits are owned by **Service Selection and Version Policy**. Atlas capacity and GD-Sync transfer must be measured against real use. Accounts, credentials, exact installed version pins, and deployed routing/network configuration remain unverified. Never put service credentials into this document. Documentation support is not proof that this project's single-threaded export works.

## What Was Simplified and Why

The creator accepted Godot host coordination with backend result calculation rather than backend control of every live decision. This fits the intended jam approach and accepts client trust. No required product capability was removed.

## Decisions and Open Issues

- **Agreed, 2026-10-21:** the creator accepted the proposed Godot host / GD-Sync messaging / Vercel result processing / MongoDB persistence responsibilities: “the recommendation is literally what i'm thinking.” That exchange established the architecture direction; the full document was subsequently approved on 2026-10-22.
- **Learning topic discussed:** the difference between a networking service, a game host, and the persistent backend. The recommendation explained who coordinates the live match and why backend history checks cannot establish truthful client reporting. The creator confirmed it matched their intended approach; no hands-on implementation or learning verification is claimed.
- **Agreed, 2026-10-21:** TypeScript on Node.js for Vercel Functions with the official MongoDB driver, and a server-issued anonymous credential stored in the browser and tied to a permanent player ID. The creator accepted that clearing the remembered browser data leads to a new account for this jam.
- **Agreed, 2026-10-21:** bot personality, choice/lie/switch tendencies, and decision timing are custom Resource `.tres` configuration. Bot policy uses its own choices and public information rather than the human's hidden card. Silent takeover retains the departed player's displayed identity. The creator subsequently clarified survivor-only saved result updates; takeover does not create a saved bot-side win/loss/draw result.
- **Delegated technical guidance, 2026-10-22:** the creator requested AI service-selection guidance and prefers the latest versions. The full-spec review accepted GD-Sync Free with the current compatible stable package and MongoDB Atlas Free; version evidence and pinning policy are owned by **Service Selection and Version Policy**. Exact installed pins/account provisioning remain unverified. Do not ask the creator to supply expertise they explicitly said they lack.
- **Observed documentation issue:** GD-Sync Free transfer allowances conflict within the current pricing page; confirm the actual account quota and measure two-player traffic before a public-test capacity claim. The earlier “fill unlimited” phrase establishes no capacity guarantee.
- **Agreed, 2026-10-21:** lifetime percentage formulas in **Lifetime Statistics and Derived Percentages**, including draws in the win-rate denominator and final-card selection for winning-card statistics.
- **Agreed, 2026-10-21:** new human profiles start at 0 Overall Points, that total drives matchmaking, rating-gap widening is `.tres` tuning, and points have no loss deductions and a floor of 0.
- **Agreed, 2026-10-21:** takeover saves only the remaining human's result updates. The creator clarified their earlier “a win is a win” response: takeover does not enter saved bot-side win/loss/draw calculations. Ordinary fallback bots retain normal competitive result processing.
- **Agreed, 2026-10-22:** daily reset at 05:00 GMT+7 and weekly reset Monday at 05:00 GMT+7.
- **Clarified, 2026-10-22:** a newly appearing quest starts a fresh counter and counts subsequent qualifying play. Prior match records and earlier occurrences of the same quest do not contribute. This replaces the earlier interpretation that a finished match advances the next daily quest.
- **Agreed, 2026-10-22:** unfinished progress and completed unpaid quest rewards both expire at the applicable reset; the creator explicitly confirmed expiry in the 04:59 completion / 05:01 menu-entry example.
- **Creator authoring inputs:** general quest selection/repetition policy and authoring values. Reset times, fresh counters, and expiry of unfinished progress/completed unpaid rewards are settled. No extra per-template progression cap is agreed or required by this plan.
- **Implementation validation:** verify the approved handoff/submission/search contracts, credential persistence, service limits, and runtime behavior in the assigned milestones. Configuration values and creator-authored content remain inputs before their affected implementation; do not reopen settled calendar/result rules.
- **Approved derived details, 2026-10-22:** API/message contracts, data structures, annotated file layout, run/export/deployment interface, shared Resource configuration boundary, and verification expectations. These are planned design, not verified implementation. Routine implementation details remain for milestone executors.
- **Agreed, 2026-10-22:** no disconnected-player reconnection, restoration, or live-match resumption. The server receives/commits the result before the cinematic is triggered; departure during the cinematic does not forfeit or undo it.
- **Full-spec approval, 2026-10-22:** the creator approved the displayed plan, including the explicitly labelled hidden-field replication for remaining-player bot continuation and animated pre-cinematic acknowledgement/error handling, plus the service/layout recommendations. No returning-player recovery is introduced.
- **Configuration and authoring:** exact rating-gap values, arena probability weights, bot personality/selection values, quest selection/targets/rewards, and the PRD's reserved presentation must be supplied or agreed before their affected implementation. Do not hide unset values behind invented product defaults.
- **Workflow:** this HUB prepares documents only. The original 12-milestone distribution was approved on 2026-10-22. The creator explicitly revised M12 and added M12.5 on 2026-10-24; `docs/Milestones.md` owns scope and `devpost/checklist.md` owns progress. `5-build` is limited here to planning/workflow, never its implementation loop.
- **Explicit revision, 2026-10-24:** separate frontend/backend Vercel projects/repositories; backend `backend` / `static-api-only`, no game upload. Revised M12 closes on deployment preparation/build confirmation. M12.5 reuses existing implementation and preserves provisional Resource approvals, current Atlas `m12_` separation, immutable history chunks/paged reads and departure arbitration. Creator deploys/tests frontend after editor/local evidence and feedback pass; no reopening settled configuration decisions.

## Review Status

The creator explicitly approved the displayed technical plan on 2026-10-22: “Yeah i approve, let's move quick”. `4-spec` is complete. Approval covers the listed technical proposals, including remaining-player state handoff and pre-cinematic acknowledgement/error presentation. The creator subsequently supplied their group order and explicitly approved the displayed vision, bootstrap, Milestones and checklist together on 2026-10-22 (“Sure”), including the 12-milestone distribution. The HUB's `5-build` checklist preparation/review is complete; implementation, final review and learning wrap-up remain unperformed. No approval claims implementation or verification. This HUB never enters the implementation loop.

The 2026-10-24 scope/deployment revision above is explicitly authorized by the creator. It does not mark original hosted-game exploration, earlier pending boxes, Final Review or learning wrap-up complete. Polishing, SFX/music and subsequent work belong to another agent.

**Subsequent creator addition, 2026-10-24:** M13 — Polishing is now a separate planned milestone after M12.5, likely using AGY at the creator's discretion. Its detailed brief is in docs/Milestones.md and its pending slice is in devpost/checklist.md (paths relative to the Godot project). The requested docs/reports/AGY_Polishing_report.md is an unfilled template, not completed work. No implementation/dispatch occurs in the HUB; Final Review and learning wrap-up/app map remain separate and open.
