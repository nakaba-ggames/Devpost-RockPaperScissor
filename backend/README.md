# M12 live integration — functionality build, in progress

Current authored configuration uses equal arena weights, the approved provisional quest catalogue and operational Ember policy. `resources/backend/release_settings.tres` selects **m12_ collections within the existing database**. Earlier M10/M11 collections/accounts/exercise history are preserved and excluded from M12 standings; old exercise commands below are historical evidence, not M12 game inputs.

From backend, `npm run build`, then `PORT=3101 npm start` serves the game and API together at `http://localhost:3101/`. Export the selected single-threaded Web preset to `public/m12/index.html`. Use distinct browser storage identities; the backend credential stays only in this game’s owned browser-local save and Authorization headers.

`POST /api/matches/history` uploads immutable `{matchId,uploadId,index,encodedEvents}` pages. `encodedEvents` is JSON tuples `[actorIndex,phaseIndex,sequence,revision,elapsedMsec,valueIndex,kindIndex]`: four phases in gameplay order; RPS index Rock/Paper/Scissor, intention keep/switch, kind decision/default. Maximum encoded page 48 KiB, request 64 KiB, no total revision-count cap. Finalize accepts `{matchId,rulesRevision,headerJson,uploadId,chunkCount,departures}`; it validates every page/event, then atomically saves eligible updates and a small receipt referencing the complete history. `GET /api/matches/history?matchId=UUID&index=N` reads one committed page for a bound human. Existing small named-history finalization remains compatible.

`POST /api/matches/result` with `{matchId,departedPlayerId}` records a bound human departure in a transaction serialized against commitment. If commitment wins, return it unchanged. If departure records first, finalization uses those exclusion facts, including an already in-flight request after transaction retry. GET on the same route resolves status. Clients preserve history/upload/match identity; a timeout never fabricates progress or a replacement match.

The generated artifact revision identifies the deployment configuration; `configuration.rules.revision` separately identifies authored round rules. Real registration/join uses permanent API IDs and captures current quest instances before arena. Both humans query the receipt themselves. Only a matching durable result gates narration and server-calculated rewards.

Vercel is prepared to serve filtered `public/m12` plus twelve nested API functions, including the generated config artifact. `.vercelignore` excludes earlier exports, private local exercise files, tools, env and private source documents. Public distribution of the SDK’s recoverable two-field client configuration is explicitly approved by the creator for the current game-specific pair. No keys belong in Git/reports. Hosted URL and final release evidence are still pending; see the M12 report in the Godot workspace.

For Vercel setup: complete CLI login, link/create `devils-rps` rooted at backend with Node 24.x/Hobby, then set `MONGODB_URI` and existing `MONGODB_DB` as protected server environment variables in the chosen environment. Never put either value in client code or chat. Atlas egress/network access and HTTPS/nested/static routes must be observed after deployment. No paid service selected. Do not infer hosted checks from localhost evidence.

---

# M10–M11 backend API

Independent anonymous identity/profile, match settlement and authoritative quest API. Godot still uses its existing preview providers; client integration remains M12. No preview history, simulated receipts or preview bot roster are imported. M11 is verified through localhost HTTP against real Atlas using explicitly approved nonproduction configuration.

## Setup

Run every command below from:

```sh
cd /Users/karinauval/Godot-Projects/Devpost-MadeWIthAI-Jam/Devpost-RockPaperScissor/backend
```

Node **24.15.0** was used locally (`.nvmrc`); Vercel selects the supported **24.x** LTS major and manages its patches. Direct dependencies are exact and `package-lock.json` records the dependency graph: MongoDB **7.7.0**, TypeScript **7.0.2**, Node types **24.19.2**. Use `npm ci` to reproduce it. Current official compatibility: [Vercel Node versions](https://vercel.com/docs/functions/runtimes/node-js/node-js-versions), [MongoDB Node/Server compatibility](https://www.mongodb.com/docs/drivers/compatibility/?driver-language=javascript&javascript-driver-framework=nodejs).

1. Create a project and **Free / M0** cluster in [Atlas](https://www.mongodb.com/docs/atlas/tutorial/deploy-free-tier-cluster/). Choose an available nearby region (Singapore if offered). Do not enable paid options or import sample data.
2. Create a database user with `readWrite` on `devils_rps_m10`. Database users are separate from your Atlas login. Save its generated password privately.
3. In Network Access, add your current public IP. If that IP changes, update this entry.
4. Connect → Drivers → Node.js gives the connection URI. Replace its username/password placeholders locally, URL-encoding special characters. Do not paste it into chat, shell arguments, Git, screenshots or reports.
5. An ignored `.env` has been prepared with file mode 0600. Fill its existing `MONGODB_URI=` line, and keep `MONGODB_DB=devils_rps_m10` and `PORT=3100`. For a new checkout, copy `.env.example` to `.env` and run `chmod 600 .env`.
6. Run:

```sh
npm ci
npm run typecheck
npm run build
npm run db:setup
npm run db:seed
npm run dev
```

`db:setup` creates unique identity/hash/record indexes and the four leaderboard/owner-record query indexes. It prints only the server version, bounded pool options and whether the connection promise was reused. It does not seed profiles, history or quest progress. After setup, `npm run db:seed` creates the explicitly approved Ember identity only. That separate command adds a unique seed-key index and uses insert-only data: rerunning it preserves its permanent ID and any future earned progress. Run it before exercising the API. No password/URI is printed on failure.

`dev` compiles and starts **a local Node HTTP adapter**, bound only to `127.0.0.1:3100`, using the same handlers as the Vercel functions. It serves no game exports or artwork. This is a local API check, not a deployed Vercel check. `npm start` starts the compiled adapter without rebuilding. Ctrl-C stops it.

## Creator try-out and basic exercise

The prepared workspace has now passed the basic exercise against actual Atlas MongoDB **8.0.34**, including a real API restart/resume. Its two credentials are already saved privately: run `npm run exercise -- resume` to try retrieving that existing profile. Do not rerun the initial creation exercise over that file.

For a fresh checkout without exercise credentials, keep the API running. In a second terminal in this backend folder:

```sh
npm run exercise
```

This creates two real Atlas-backed test identities, saves `M10 Player`, resumes it, checks missing/invalid authentication, verifies owner isolation/public projections and reads empty records and all four leaderboards with ordinary pagination. It creates no matches. Issued credentials are saved only to ignored `.local/m10-identities.json` with file mode 0600; never display/share that file. Test profiles remain real zero-history profiles in this test database.

Stop the API with Ctrl-C, then run `npm start` again. In the second terminal:

```sh
npm run exercise -- resume
```

This must retrieve the same player ID and saved name after the process restart. A later run of this command follows the same account without revealing its credential. In Atlas Data Explorer, open `devils_rps_m10.players`, filter `{displayName: "M10 Player"}`, and inspect only public fields/name/zero counters; avoid opening or capturing the private credential-hash field. The path through code is `api/anonymous.ts` → `src/auth.ts` → `src/db.ts`; the read returns the public projection of the saved profile.

The initial exercise refuses to overwrite an existing credential file or silently create replacement accounts. If an exercise partially fails, preserve that file and investigate the affected operation. Never treat failure/timeout as permission to recreate, migrate or delete the account. A timeout during create may leave an unreachable profile because the credential response was lost; no recovery mechanism is added for this jam.

## HTTP contracts

All responses are JSON with `Cache-Control: no-store`. Names are plain data, never HTML/markup. In deployment use HTTPS. Private requests carry `Authorization: Bearer <credential>`; no supplied player ID authorizes an operation.

| Endpoint | Contract |
| --- | --- |
| `POST /api/anonymous` | JSON `{mode:"create"}` explicitly creates a human with 0 points, zero history and N/A percentages. HTTP 201 returns `{playerId, credential, profile, needsDisplayName:true, rulesRevision}`. Raw credential is returned only here. `{mode:"resume"}` requires the header and returns the same saved account without its credential. No implicit recreation. |
| `PATCH /api/profile` | Owner header + JSON `{displayName}` only. Returns `{profile}`. Trims surrounding whitespace, accepts 1–24 Unicode code points, rejects controls, invisible formatting, invalid surrogate characters and line/paragraph separators. Duplicates allowed; punctuation/markup-like text remains literal. Creator agreed this policy in this M10 chat. |
| `GET /api/player?playerId=UUID` | Public `{profile}`. No credentials/hash, bot label, private quest state or records. Unknown player: 404. |
| `GET /api/leaderboard?metric=overallPoints&limit=20&cursor=…` | Exactly `overallPoints`, `winRate`, `lieCount`, `honestCount`. `{entries,nextCursor}`; opaque cursor is tied to metric. Default 20, allowed 1–50. Descending metric, ascending permanent player ID breaks ties. N/A (`null`) win rates sort last. This is ordinary keyset pagination, not a snapshot while standings change. |
| `GET /api/records?limit=20&cursor=…` | Owner header; `{records,nextCursor}` only for `ownerPlayerId` derived from auth and `eligible:true`. Optional `playerId` must match the caller or returns 403. Default 20, allowed 1–50. Newest commitment first; record ID breaks ties; cursor tied to owner. Empty array until M11 writes actual eligible records. |

Errors: `{error:{code,message,retryable}}`. Missing header: 401 `CREDENTIAL_MISSING`; malformed/unknown credential: 401 `CREDENTIAL_INVALID`; caller ID mismatch: 403; invalid fields/pagination: 400; unavailable/unconfigured database: 503 with retryable server error. Never expose raw driver exceptions. Requests are bounded to 8 KiB. Unexpected body/query fields are rejected.

Profiles store separate initial/final card counters and winning-final-card counts. `completedMatches = wins + losses + draws`; win rate includes draws. Winning-card and lying/honest-winning percentages divide by wins; initial-card, lie and switch tendencies divide by completed matches. Zero denominators are stored as `null` (display N/A). M11 updates counters, derived fields, owner records and quest contributions atomically with the result. Records preserve separate initial/final cards for both sides, name snapshots, result and commitment time.

Credentials contain 32 cryptographically random bytes (256 bits), encoded as `anon_` plus base64url. SHA-256 with a fixed domain prefix is stored, never plaintext. Fast hashing is appropriate for high-entropy random credentials; this is not a password system. The unique partial hash index excludes future bots without credentials. There is no cross-device recovery, password login, deletion or abandoned-match resume.

## Resource deployment artifact

The sole authoring sources remain custom Godot Resources: `resources/arena/option_rules.tres`, `resources/quests/development_catalogue.tres` and its referenced quest definitions. From this backend folder:

```sh
npm run config:export
npm run build
```

`GODOT_BIN` can select another compatible Godot executable. The exporter copies only the Resource files and their three schema scripts into a temporary Resource-only project, then uses native `ResourceLoader` through `scripts/export-config.gd`. It never runs the game's autoloads, changes scenes/settings or creates a game export. Explicit relevant field allowlists exclude unrelated configuration. No tuning value is hand-maintained in Node.

`config/backend-config.json` is a versioned generated deployment input. Its revision hashes the complete payload and source-file digests. Build checks integrity and, when the sibling Godot sources are available, rejects stale exports. Vercel can build from the committed artifact without Godot installed. The API reads and verifies this known revision; the client never supplies payout constants.

The current quest catalogue remains `development_only:true`, and production arena weights remain unconfigured; `productionReady:false`. Exporting these fields does **not** approve production balance. The creator explicitly approved this exact development configuration and existing Ember selection for isolated nonproduction M11 API/Atlas exercises on 2026-10-23. Ordinary/deployed handlers retain the readiness gate. The M10 seed inserted **Ember** with a permanent UUID, 0 points/no history, no credential/hash and private seed key `m10-ember-v1`. The M11 controlled fallback exercise subsequently credited that same profile +10 points/one win/one owner record through the actual API. No preview identity/statistics/personality were imported. Production balance, arena weights and bot policy/selection remain creator inputs.

## Connections, limits and future Vercel environment

`src/db.ts` shares a single in-flight/connected MongoClient promise across warm requests. Each server pool has maximum 5, minimum 0, maxConnecting 2; idle timeout 60s, selection/connect/wait bounds 5s, socket/operation bounds 10s. Functions never close per request. A failed initial connection is closed/reset so a later request can retry without creating an account. Monitoring adds sockets; multiple cold instances multiply pools, so 5 is not an account-wide cap.

Official [Atlas Free limits](https://www.mongodb.com/docs/atlas/reference/free-shared-limitations/) currently document MongoDB 8.0 managed updates, 0.5 GB including indexes, 500 connections, one Free cluster per project, and rolling seven-day transfer allowances of 10 GB in and 10 GB out. These are published limits; account tier, exact patch version, actual consumption and headroom must be observed on the creator's cluster. `db:setup` observed server **8.0.34**, created the required indexes and confirmed connection-promise reuse in this workspace. Creator confirmed **M0**, **AWS / Singapore (`ap-southeast-1`)**. Total account usage and enforced quota consumption have not been independently observed; published Free limits above are not measured load/capacity evidence. No paid plan is selected.

No deployment is required for the independent local persistence proof. For a later backend-only Vercel preview, root the project at `backend`, select Node 24.x, and set `MONGODB_URI`/`MONGODB_DB` as server-only Preview environment values. Review Atlas network access for that deployment's egress; the local IP entry alone does not configure Vercel connectivity. Do not place the URI in public/client environment variables.

`.vercelignore` is an explicit source upload allowlist. `vercel.json` selects an empty static output and excludes `public/**`, `.env*` and `.local/**` from functions. Existing `public/` SDK-bearing game exports must remain untouched and excluded. No Vercel project/link/build/deployment has been performed by this milestone; these deployment settings are prepared inputs, not deployed evidence. Combined game deployment belongs to M12 and requires resolving SDK distribution first.

## Verification boundary

M10's recorded checks cover identity/authentication/query/restart persistence. M11's basic local HTTP/Atlas checks cover actual once-only result/profile/record/quest transactions, scoring/classification, separate fallback/takeover attribution, quest sequencing/menu payment and controlled reset boundaries. These use submitted controlled histories, not live Godot games. Concurrent duplicates, uncertain-network races, deliberate rollback/failure injection, full suites, load/stress/fuzzing/outages and browser/device/gameplay checks remain deferred/unverified. No Vercel deployment is claimed. Preserve existing external snapshots `e8bb537` and `0d4d7bb`; the M11 report records the creator's checkpoint confirmation and the stale predecessor document status without finalizing it here.

## M11 settlement, quests and creator exercise

Configuration stays at `sha256:d0e9b971b245891addf9a13e056bec263c5e5a18b3cd07e6935e8a3a9637edf3`: `m05-round-v1` rules and `m08-creator-approved-preview-v1` development catalogue. No Node-authored payout constants. `npm start` now mounts M11 routes, but its normal/deployed handlers reject settlement/quest assignment/payment with `503 CONFIGURATION_NOT_APPROVED` until production authoring is agreed. Existing committed-result reads remain available to their bound participants. The explicit localhost exercise adapter accepts only the approved artifact revision; it is excluded from deployment uploads.

| Endpoint | Contract |
| --- | --- |
| `POST /api/matches/register` | Owner credential + `{matchNonce,lobbyId?,peerPlayerId?,fallbackRequested,rulesRevision}`; stable UUID nonce, immutable human/bot bindings, public opponent profile. No rating filter or automatic bot scheduling. |
| `POST /api/matches/join` | Peer credential + `{matchId,matchNonce}`; cannot overwrite another participant. Both humans must bind before play. |
| `POST /api/matches/finalize` | Bound eligible human + `{matchId,rulesRevision,roundLog,departures:[]}`; at most one departed human ID for takeover. The backend calculates rewards/eligibility, commits atomically, then returns `{matchId,status:"committed",savedResult}`. Identical replay returns the receipt; conflicting replay is 409. |
| `GET /api/matches/result?matchId=UUID` | Bound human credential; `{matchId,status,savedResult}`. Pending status has `savedResult:null`; a committed result has stable receipt/result identity and `committedAt`. No reconnect or live-match resume. |
| `POST /api/menu` | Owner + `{requestId:UUID}` for menu entry; expiry before once-only payment. Returns profile/stats, daily/weekly/history, grants, periods, server time and rules revision. Retry the same ID for the same entry; new entry uses a new ID. |
| `GET /api/quests?historyBefore=NUMBER` | Owner; same current quest state without payment. Daily history pages contain at most 100 entries with `dailyHistoryNextBefore`; no daily completion cap. |

`roundLog` is a compact API wire shape: `matchId`, full artifact `rulesRevision`, condition `devil|angel|none`, four `{phase,started,deadline,locked}` entries, and two actors. Actors contain `actorId`, `startingOrder`, `initialCard`, `identityClaim`, `switchClaim:keep|switch`, `finalCard`, and bounded `{phase,sequence,revision,elapsedMsec,value}` events. Phases are `option`, `identity_claim`, `switch_claim`, `final_choice`. Examples are generated in `scripts/try-m11.mjs`; M12 must map the richer Godot history. The trusted host reports conditions/history/departures; validation is not independently verified gameplay or cheat detection. Client reward totals/classification/payout values are not accepted.

The short majority-write/snapshot transaction includes result/receipt, eligible profile aggregates, owner records and captured quest contributions. Menu payment has its own transaction. Unique match/nonce/receipt, owner-record, quest-instance/contribution/grant and menu-entry indexes guard once-only storage; install them before running the routes. Existing warm MongoClient reuse/pool bounds remain unchanged. A timeout is not success: query/retry the same match. Later cinematic departure cannot rewrite commitment. A precommit departed human and its takeover side receive no saved credit; a remaining human and ordinary fallback profile receive eligible competitive credit.

For the creator try-out, run these commands in **backend/**:

```sh
npm run typecheck
npm run build
npm run db:setup:m11
node --env-file-if-exists=.env dist/scripts/m11-local-server.js sha256:d0e9b971b245891addf9a13e056bec263c5e5a18b3cd07e6935e8a3a9637edf3 --approved-ember
```

The adapter prints an exact `export API_BASE=...` line. Copy that line into a second backend terminal, then run:

```sh
node scripts/try-m11.mjs prepare
node scripts/try-m11.mjs play
node scripts/try-m11.mjs inspect
node scripts/try-m11.mjs replay
```

`prepare` creates two dedicated try-out identities, saves credentials immediately in ignored `.local/m11-tryout.json` (0600) and refuses to overwrite that file. Preserve it after any failure; do not recreate M10/exercise accounts. `play` registers/binds both identities and submits a controlled honest Scissor→Rock win versus Scissor. Expected first result for A: +10 points, one win/record, completed initial-Scissors daily, next Win-3 daily at zero, weekly play +1/switch +1. `inspect` shows the receipt and saved points/stats/quest contribution. `replay` repeats that finalization, checks the same receipt and unchanged API-visible credit. These requests use the real server clock. Ctrl-C closes only this adapter.

The separate `npm run exercise:m11` is the scoped verification harness, **already executed** in this workspace. Its five identities/operations are preserved in ignored `.local/m11-contract.json`, sanitized observations in ignored `.local/m11-evidence.json` (both 0600). Completed steps are skipped on a rerun; preserved evidence is not a new pass. The harness clock is a private in-process function and never accepts time from clients, headers, fields, public routes or normal environment settings. Its fixtures advance through 2026-10-26; use the separate real-clock try-out identities above. No production time is changed, and old test identities/data are not reset/deleted.

Recorded basic evidence: seven scoring histories produced 76 match points plus 13 once-only menu points; A ended with 114 points/nine eligible matches after fallback/takeover cases. Replay storage remained identical; conflict 409/unauthorized read 403 caused no writes. Daily 04:59/05:00/05:01 and Monday boundaries expired unfinished/unpaid instances while preserving paid points. A focused finishing-event case proved that an initial-Scissors third win did not advance the next Scissors instance. Actual Atlas reported 8.0.34; acknowledged driver commits and stored before/after observations are recorded in `../rock-paper-scissor/docs/reports/M11_Report.md`.
