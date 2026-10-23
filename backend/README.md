# M10 backend

Independent anonymous identity/profile API. Godot still uses its existing preview providers. M11 settlement/quests and M12 client integration are not implemented here. No preview history, sample aggregates, receipts or bot roster are imported.

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
5. A blank, ignored `.env` has been prepared with file mode 0600. Fill its existing `MONGODB_URI=` line, and keep `MONGODB_DB=devils_rps_m10` and `PORT=3100`. For a new checkout, copy `.env.example` to `.env` and run `chmod 600 .env`.
6. Run:

```sh
npm ci
npm run typecheck
npm run build
npm run db:setup
npm run dev
```

`db:setup` creates unique identity/hash/record indexes and the four leaderboard/owner-record query indexes. It prints only the server version, bounded pool options and whether the connection promise was reused. It does not seed profiles, history or quest progress. Run it before exercising the API. No password/URI is printed on failure.

`dev` compiles and starts **a local Node HTTP adapter**, bound only to `127.0.0.1:3100`, using the same handlers as the Vercel functions. It serves no game exports or artwork. This is a local API check, not a deployed Vercel check. `npm start` starts the compiled adapter without rebuilding. Ctrl-C stops it.

## Creator try-out and basic exercise

Keep the API running. In a second terminal in this backend folder:

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

Profiles store separate initial/final card counters and winning-final-card counts. `completedMatches = wins + losses + draws`; win rate includes draws. Winning-card and lying/honest-winning percentages divide by wins; initial-card, lie and switch tendencies divide by completed matches. Zero denominators are stored as `null` (display N/A), not fabricated percentages. M11 must update counters and derived fields atomically. Records have separate `self.initialCard`, `self.finalCard`, `opponent.initialCard`, `opponent.finalCard`, opponent display-name snapshot, result and commitment time. No record writer exists in M10.

Credentials contain 32 cryptographically random bytes (256 bits), encoded as `anon_` plus base64url. SHA-256 with a fixed domain prefix is stored, never plaintext. Fast hashing is appropriate for high-entropy random credentials; this is not a password system. The unique partial hash index excludes future bots without credentials. There is no cross-device recovery, password login, deletion or abandoned-match resume.

## Resource deployment artifact

The sole authoring sources remain custom Godot Resources: `resources/arena/option_rules.tres`, `resources/quests/development_catalogue.tres` and its referenced quest definitions. From this backend folder:

```sh
npm run config:export
npm run build
```

`GODOT_BIN` can select another compatible Godot executable. The exporter copies only the Resource files and their three schema scripts into a temporary Resource-only project, then uses native `ResourceLoader` through `scripts/export-config.gd`. It never runs the game's autoloads, changes scenes/settings or creates a game export. Explicit relevant field allowlists exclude unrelated configuration. No tuning value is hand-maintained in Node.

`config/backend-config.json` is a versioned generated deployment input. Its revision hashes the complete payload and source-file digests. Build checks integrity and, when the sibling Godot sources are available, rejects stale exports. Vercel can build from the committed artifact without Godot installed. The API reads and verifies this known revision; the client never supplies payout constants.

The current quest catalogue remains `development_only:true`, and production arena weights remain unconfigured; `productionReady:false`. Exporting these fields does **not** approve production balance. M11 must resolve production catalogue/weight inputs before enabling settlement. There are no seeded real bots; identity source/agreement is still pending. The preview roster and synthetic history are not production seeds.

## Connections, limits and future Vercel environment

`src/db.ts` shares a single in-flight/connected MongoClient promise across warm requests. Each server pool has maximum 5, minimum 0, maxConnecting 2; idle timeout 60s, selection/connect/wait bounds 5s, socket/operation bounds 10s. Functions never close per request. A failed initial connection is closed/reset so a later request can retry without creating an account. Monitoring adds sockets; multiple cold instances multiply pools, so 5 is not an account-wide cap.

Official [Atlas Free limits](https://www.mongodb.com/docs/atlas/reference/free-shared-limitations/) currently document MongoDB 8.0 managed updates, 0.5 GB including indexes, 500 connections, one Free cluster per project, and rolling seven-day transfer allowances of 10 GB in and 10 GB out. These are published limits; account tier, exact patch version, actual consumption and headroom must be observed on the creator's cluster. `db:setup` records the actual server version once accessible. No paid plan is selected.

No deployment is required for the independent local persistence proof. For a later backend-only Vercel preview, root the project at `backend`, select Node 24.x, and set `MONGODB_URI`/`MONGODB_DB` as server-only Preview environment values. Review Atlas network access for that deployment's egress; the local IP entry alone does not configure Vercel connectivity. Do not place the URI in public/client environment variables.

`.vercelignore` is an explicit source upload allowlist. `vercel.json` selects an empty static output and excludes `public/**`, `.env*` and `.local/**` from functions. Existing `public/` SDK-bearing game exports must remain untouched and excluded. No Vercel project/link/build/deployment has been performed by this milestone; these deployment settings are prepared inputs, not deployed evidence. Combined game deployment belongs to M12 and requires resolving SDK distribution first.

## Verification boundary

M10 runs only build/typecheck, the above two-identity real-Atlas exercise, restart/resume, pool/config inspection and secret/export input review. Deferred: full suite, load/stress/races/fuzzing, outages, browser/device matrix, earlier gameplay, match settlement and quest rewards. Missing service access means pending evidence, never a mock pass. M09's staged feature/completion boundary must also be resolved before committing M10.
