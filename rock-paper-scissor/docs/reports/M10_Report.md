# M10 — Backend I: anonymous identity and saved-profile APIs

Status: **partial / awaiting input and real Atlas evidence**. Fast mode, slice 10 only. Runnable independent backend implementation prepared and typechecked; no feature commit and slice 10 remains unchecked. No M11 or client integration. Updated 2026-10-23.

## Scope and approved references

Read `docs/AI_Bootstrap.md`, universal requirements/development adapters/completion protocol and M10 in `docs/Milestones.md`; slice 10, fast mode and Revisions in `devpost/checklist.md`; the assigned PRD entry/menu/stats/records/leaderboard sections and spec identity/API/data/Resource/runtime/service/aggregate/staged-provider sections; project-local `5-build`; and private learner context without reproducing it. Inspected M09 report/current Git boundary. The approved TypeScript backend exception applies; Godot gameplay/network/presentation/providers/scenes/settings remain unchanged.

M09's supplied creator feedback is “M09 done, and tried, it works.” At this assignment's start its report still awaited retry acceptance, its slice/checkpoint remained unchecked and **25 files were staged**, with latest commit `c26cce5` (M08 completion). Creator was told that M09's own chat must record supplied acceptance and finish its commit/completion workflow. No other chat was created/messaged, no delegation occurred, and M09 was not finalized here. Its staged binary diff was captured privately for comparison; the index was preserved byte-for-byte through this work. Only M10 Revisions were appended to the working checklist, unstaged.

## Changed files and why

All implementation paths below are under sibling `backend/`:

- `.gitignore`: preserve `/public/`; add backend-specific secret/local/build exclusions. `.env.example`: variable names and safe defaults. A separate blank `.env` was created locally with mode **0600**, verified ignored/untracked, and is excluded from intended files. No secret was created or printed by the agent.
- `package.json`, `package-lock.json`, `.nvmrc`, `tsconfig.json`: exact dependency resolution, supported Node major, reproducible build/typecheck/dev/exercise scripts.
- `api/anonymous.ts`, `api/profile.ts`, `api/player.ts`, `api/leaderboard.ts`, `api/records.ts`: the five M10 routes only.
- `src/auth.ts`, `src/db.ts`, `src/model.ts`, `src/http.ts`, `src/errors.ts`, `src/pagination.ts`, `src/config.ts`: credential ownership, bounded pool, zero-history model/public allowlists, stable sanitized errors/validation, bounded keyset pagination and known configuration revision.
- `scripts/dev.ts`, `scripts/setup-db.ts`, `scripts/exercise.mjs`: localhost-only API adapter using the actual handlers, index/version/reuse setup, scoped two-identity exercise with protected credential storage and later resume. No mock or result writer.
- `scripts/export-config.gd`, `scripts/export-config.mjs`, `scripts/check-config.mjs`, `config/backend-config.json`: native Resource allowlist export, generated revision/source hashes and stale/integrity checks.
- `.vercelignore`, `vercel.json`, `static-api-only/.gitkeep`: backend-only upload allowlist, empty static output, function artifact inclusion and explicit game/secret exclusion. No Vercel deployment/link or upload.
- `README.md`: exact setup/launch/API/exercise/Atlas instructions, naming policy, configuration labels, pool limits and deployment boundaries.

**29 intended backend files**, plus this report and an unstaged M10-only checklist appendix. Existing backend artwork, metadata and generated exports were preserved. No art or client files were created/changed.

## Versions and service compatibility

Observed locally: **Node 24.15.0**, **npm 11.12.1**, installed stable official **mongodb 7.7.0**, **TypeScript 7.0.2**, **@types/node 24.19.2**. `npm ls --depth=0` confirms these pins. Existing Vercel CLI reports **59.17.0**; it was not used to link/deploy/run Vercel. Native Resource exporter: **Godot 4.7.stable.official.5b4e0cb0f**. Vercel uses `engines.node:24.x`; its patch is managed by Vercel and is not claimed equal to the local patch.

Official checks on 2026-10-23: [Vercel supports Node 24.x LTS](https://vercel.com/docs/functions/runtimes/node-js/node-js-versions); [MongoDB's compatibility table](https://www.mongodb.com/docs/drivers/compatibility/?driver-language=javascript&javascript-driver-framework=nodejs) explicitly lists driver 7.0–7.7 for Node 24 and 7.6–7.7 for MongoDB 8.0. npm registry confirmed stable current package versions and driver minimum Node >=20.19.0 before pinning/installing. Sandbox npm lookup failed with ENOTFOUND; authorized elevated npm access succeeded. No alternate stack or paid plan selected.

Published [Atlas Free limits](https://www.mongodb.com/docs/atlas/reference/free-shared-limitations/): managed MongoDB **8.0**, **0.5 GB** data/index storage, **500 connections**, one Free cluster/project, rolling seven-day **10 GB inbound / 10 GB outbound**. These are documentation values, **not observed creator account limits**. Creator explicitly says no cluster exists yet. Actual server patch, account tier/region/usage/headroom remain pending. `npm run db:setup` is ready to record server version plus reuse/pool configuration after access exists.

## Identity, authentication and public/private contracts

- `POST /api/anonymous` takes only `{mode:"create"|"resume"}`. Create issues a permanent UUID v4 and 32 cryptographically random bytes (256 bits), `anon_` base64url credential. HTTP 201 returns raw credential once. Database stores only SHA-256 with an application domain prefix, appropriate for random high-entropy credentials. No password system, recovery, deletion or implicit replacement/migration.
- Resume and private requests use `Authorization: Bearer <credential>`. Auth looks up the human owner by hash. Missing header is 401 `CREDENTIAL_MISSING`; malformed/unknown credential is 401 `CREDENTIAL_INVALID`; server/configuration failure is separately retryable 503. No credential or driver error is serialized/logged. Creation after a timeout is never automatically retried/recreated by the exercise.
- `PATCH /api/profile` accepts only `{displayName}` and writes the authenticated owner. Names trim outside whitespace, use 1–24 Unicode code points, reject controls/invisible formatting/surrogates/line separators, allow duplicates, and remain literal text. A supplied player ID cannot redirect the write. Creator agreed the proposed constraints with “yeah sure”; no broader preview naming rule was promoted implicitly.
- `GET /api/player?playerId=…` returns `{profile}` through explicit inclusion projection and DTO allowlists. Public display fields and lifetime aggregates only; no credential/hash, bot kind, quests or history.
- `GET /api/leaderboard?metric=…&limit=…&cursor=…` supports exactly `overallPoints`, `winRate`, `lieCount`, `honestCount`, default page 20 / maximum 50. Descending metric with permanent-ID ascending tie break; N/A win rates last. Metric-bound opaque keyset cursor. No bot label or invented aggregates.
- `GET /api/records` derives owner from credential and filters `ownerPlayerId` plus `eligible:true`, newest commitment then record ID. Same bounded page size; cursor tied to owner. An optional different `playerId` is explicitly denied with 403. Projections retain separate self/opponent initial and final cards, opponent display snapshot and result. No records are manufactured/written by M10.
- Bodies bounded to 8 KiB; explicit methods, JSON, query/body field validation; stable `{error:{code,message,retryable}}`; no-store responses. These implemented guards are not described as exhaustively security-tested.

New humans have **0 Overall Points**, zero W/L/D/streak/lie/honest/switch/card counters and `null` percentages for N/A. Stored aggregate definitions preserve draws in the win-rate denominator, final winning cards divided by wins, lying/honest wins divided by wins and initial-card/lie/switch tendencies divided by eligible completed matches. M11 must atomically maintain these stored fields from real eligible results. It must not import preview history or peer-memory receipts.

## Pool and configuration contracts

One module-scoped connection promise is reused during warm invocations and concurrent initialization. Initial failure closes the pending client and clears the promise for a later retry. No function closes its pool per request. Per-server pool: max **5**, min **0**, maxConnecting **2**, idle **60,000 ms**, selection/connect/wait **5,000 ms**, socket/operation **10,000 ms**. Topology monitoring adds sockets; cold instances multiply pools. This is not a claim of an account-wide five-connection limit. Source inspected; actual connected reuse/usage remains pending.

Generated `config/backend-config.json` revision:

`sha256:d0e9b971b245891addf9a13e056bec263c5e5a18b3cd07e6935e8a3a9637edf3`

Native ResourceLoader reads explicit relevant fields from `resources/arena/option_rules.tres`, `resources/quests/development_catalogue.tres` and its five referenced definitions. The exporter uses exact copies of these files and their three Resource scripts in a temporary Resource-only project, which is removed afterwards. No separately authored JSON tuning or game export. Payload/source digests determine revision; build verifies integrity and rejects stale sources when sibling Godot sources are present. API reads/verifies the versioned artifact. Client-supplied payout fields are not accepted.

Rule revision remains `m05-round-v1`; quest revision remains `m08-creator-approved-preview-v1`, `development_only:true`; production arena weights remain unconfigured, `productionReady:false`. Export is not production-balance approval. No M11 scoring, settlement, quest allocation or menu rewards are implemented. Production configuration inputs remain M11 dependencies.

## Mechanical verification and actual evidence

Environment: local macOS, backend workspace commands. **Local Node adapter, not deployed Vercel. No Atlas-backed success and no mock persistence claim.**

| Scoped action | Observed result |
| --- | --- |
| Exact dependency install/lockfile | Completed; `npm ls --depth=0` reports the pins above. |
| `npm run typecheck` / `npm run build` | Passed. Build also verified generated configuration/source hashes. |
| `npm run config:export` | Passed with native Resource loading and the revision above; productionReady=false. |
| `npm start` | Actual handlers listening only on `http://127.0.0.1:3100`. Sandbox initially denied bind (EPERM); authorized elevated local bind succeeded. |
| `npm run exercise` | First create request reached real API and returned **HTTP 503 SERVICE_NOT_CONFIGURED**, because protected URI was blank. Exercise stopped before identity creation; no credential file or saved profile was fabricated. |
| Two real identities/name/resume/restart | **Pending Atlas input/access**, not passed. |
| Missing/invalid credential, cross-owner isolation, public/leaderboard/records/pagination | Implemented and exercise prepared; **real API/Atlas verification pending**. Nonempty records are intentionally unavailable until actual eligible M11 results. |
| Connection reuse/server/account limits | Pool source inspected; live connection-promise reuse, server patch and account observations pending. |
| Secret/commit/upload boundary | `.env` mode 0600; Git ignore verified for `.env`, `.env.test`, node_modules, .vercel, .local and public. No tracked/staged backend secrets/exports. All 29 intended backend paths exclude forbidden inputs. Scratch Git-ignore semantics check of `.vercelignore` excluded public/m09.html, env files, local credential file and artwork; included API/src/config/build/package inputs. This checks prepared filtering, not an actual upload/deployment. |
| M09 staged boundary | Full staged binary diff compared unchanged to entry snapshot; no M10 files staged or committed. |

Scoped verification contract, also recorded under checklist Revisions: only build/typecheck/actual API launch; two Atlas-backed identities, normal name and resume, restart persistence; one missing/invalid credential each; minimum owner isolation/public checks; four leaderboard categories/owner records/ordinary pagination; pool/config/input review. **Deferred, not passed:** full suite, load/stress/races/fuzzing, deliberate outages, browser/device matrix, earlier gameplay and broad security audit. Repeat affected checks only after relevant fixes.

## Creator try-out, decisions and remaining inputs

Creator agreed proposed name policy (“yeah sure”). The combined answer did not establish a bot seed source or Atlas availability. Follow-up established no Atlas cluster yet; creator requested instructions and an ignored `.env` to fill locally. Both were supplied, with [official Atlas Free setup](https://www.mongodb.com/docs/atlas/tutorial/deploy-free-tier-cluster/), database-scoped readWrite user, current-IP network entry and private connection-string input. No URI/password was requested in chat.

Bot source/identities remain **unresolved**; no bots have been seeded. Starting empty while waiting is not a recorded approval to remove required competitive bots from the submission. Preview bot identities/statistics remain development fixtures. No creator API try-out or successful M10 feedback has been received.

Exact commands are in `backend/README.md`: from backend, `npm ci`, `npm run typecheck`, `npm run build`, `npm run db:setup`, `npm run dev`. In another backend terminal, `npm run exercise`; stop/restart API with `npm start`, then `npm run exercise -- resume`. Credentials stay only in ignored `.local/m10-identities.json` (0600). The later command retrieves the same saved name/player. Atlas Data Explorer public-field inspection can follow the saved profile without displaying credentials/hashes. M10 is not a planned fast-mode hands-on checkpoint; no extra acceptance gate is invented.

## Godot MCP operations and limitations

Discovered exact namespace tools and confirmed connected project through editor read expression `get_node('/root/MCPRuntimeServer').get('RegistryClient').get('_ProjectKey').current()`: returned this exact Godot root after case normalization. `resource_io` discovery advertises `resource_load`, but the callable is absent from this harness (`is not a function`). Used saved Resource/script reads and native headless ResourceLoader as fallback.

Initial native export hit a sandbox user-log failure/crash; explicit temporary log path fixed it. Running in the original project also triggered existing MCP/GD-Sync autoload errors in a custom SceneTree. The final exporter uses the temporary Resource-only project and avoids these autoloads. Successful final export retains the existing macOS certificate diagnostic `get_system_ca_certificates`; it is not reported as a clean editor run. No client gameplay test, scene mutation, settings change or new browser export was authorized/performed.

## Web/export checks and limitations

Existing `backend/public/` remains excluded, untouched and unresolved for SDK-bearing public distribution. No publishing/upload/deletion/overwrite. Prepared `.vercelignore` allowlists API/backend inputs; functions exclude exports and secrets; empty static output prevents serving the existing game package. No linked project, deployed Node patch, Vercel routing, external egress/Atlas connectivity or hosted API has been verified. Combined game deployment belongs to M12. No game-client threads, new art or assertion side effects were introduced.

## Commit/checklist and M11 handoff

Planned implementation commit remains `feat(backend): add anonymous identity and profile APIs`. **Not made:** essential Atlas/authentication/persistence/query evidence, real bot seed decision and M09 prerequisite bookkeeping/safe commit boundary are pending. No M09 staged files were absorbed, and no checklist box changed. M10-only implementation/report/checklist appendix remain available for continuation; do not blanket-stage.

Resume only M10: obtain protected Atlas input and seed decision, observe actual Free account/version limits, run the stated basic checks against actual Atlas, restart/retrieve saved profile, review exact intended diffs/secret/export boundaries, resolve M09's own completion boundary, then commit and check only slice 10 as applicable. Do not fabricate evidence or finalize M09 here.

For a later separately assigned M11: use permanent credential owners, stored aggregate definitions, eligible-owner record schema/indexes and known Resource revision. Resolve production catalogue/weights and seed identity inputs. Registration/finalization/receipts/atomic quest/menu settlement are not implemented here. Keep unrestricted jam matchmaking; never restore a rating filter or upload preview progress. **Stop at M10.**
