# Devil’s Rock Paper Scissor

**Rock Paper Scissor meets Werewolf. No downloads, no meta, no builds—just honesty and bluffing.**

A portrait multiplayer browser game about reading an opponent and deciding when to tell the truth. The familiar three cards stay simple; the claims, changing intentions and final reveal add room for deception.

[Open the browser game](https://devpost-rps-builds.vercel.app/)

## How to play

1. Enter with an anonymous profile and choose a display name on your first visit.
2. Find an opponent. A fallback bot can fill an unsuccessful search.
3. **Option:** choose your initial Rock, Paper or Scissor card.
4. **Claim:** tell your opponent which card you chose. You can tell the truth or bluff.
5. **Change Claim:** announce whether you intend to keep or switch your card.
6. **Change:** submit your final card. Your action can contradict your announcement.
7. Watch the narrated reveal, see the result and return to the menu.

The arena condition changes the reward for a winning or drawn hand: **Devil’s Seduction** favors deception, **Angel’s Confession** favors honesty, and **no modifier** uses base rewards. Opponent tendencies and visible decision revisions give you more information to second-guess.

## Features

- Four decision phases that separate actual cards, spoken claims and final actions.
- Human multiplayer, fallback opponents and in-arena chat.
- A cinematic reveal that recounts the choices behind the result.
- Saved anonymous profiles, match records, statistics and leaderboards.
- Daily and weekly quests with rewards granted on menu entry.
- Portrait presentation and a single-threaded Godot web export.

## Built with

| Part | Technology |
| --- | --- |
| Game client | Godot 4.7, GDScript, Compatibility renderer |
| Multiplayer transport | GD-Sync |
| Backend | TypeScript, Node.js 24.x, Vercel Functions |
| Persistence | MongoDB with the official Node.js driver |
| Development | Codex and the Devpost Learn Skill Pack |

## Repository layout

```text
rock-paper-scissor/  Godot project, scenes, scripts, Resources and artwork
backend/            API functions, server source and generated configuration
builds/             Exported frontend runtime files
LICENSE             MIT license for original source
LICENSING.md        License scope and third-party/asset terms
```

Planning documents: [scope](rock-paper-scissor/devpost/scope.md), [product requirements](rock-paper-scissor/devpost/prd.md) and [technical spec](rock-paper-scissor/devpost/spec.md).

## Open the source project

1. Install Godot 4.7 and import `rock-paper-scissor/project.godot`.
2. Use the Compatibility renderer. The main scene is `scenes/main.tscn`, with a 540 × 960 portrait viewport.
3. Configure your own GD-Sync project locally. The private `addons/GD-Sync/keys.cfg` file is excluded from Git.
4. Set `resources/backend/api_settings.tres` to the backend you intend to use. The checked-in setting points to the creator’s deployed service; use your own service for independent development.

Profiles are remembered in the current browser’s game storage. Clearing that identity creates a new anonymous account; there is no cross-device recovery or abandoned-match resume flow.

### Backend

Use Node.js 24.x. In a fresh checkout, create a private `backend/.env` from `backend/.env.example` and set your own `MONGODB_URI`, `MONGODB_DB` and local port. The example database name comes from an earlier development environment; choose your intended database explicitly.

From `backend/`:

```sh
npm ci
npm run typecheck
npm run build
npm run dev
```

The default local API address is `http://127.0.0.1:3100`. Set the client API origin accordingly when using a local backend. See the [backend setup documentation](backend/README.md) for database initialization and API contracts; its historical exercises create persistent test data and are not required merely to view the game.

MongoDB credentials belong only on the server. Never commit real `.env` files, anonymous-account credentials or local test state.

### Web hosting

The existing Godot Web preset exports to `builds/index.html` with thread support disabled. Serve web exports over HTTP(S) in a WebGL 2-capable browser. The backend allows the local frontend origins `http://localhost:8125` and `http://127.0.0.1:8125`; other frontend origins need explicit backend configuration.

Backend and frontend use **separate Vercel projects/repositories**. The backend uses Root Directory `backend` and Output Directory `static-api-only`; it builds from its committed configuration artifact without Godot installed and must not require or upload the game export.

## Verification notes

The [release report](rock-paper-scissor/docs/reports/AGY_Polishing_report.md) records corrected package inspection, an earlier local browser fallback journey and separate native checks. Evidence applies to the builds and paths named there. It does not establish every human-peer, takeover, hosted or mobile behavior; later changed builds do not inherit an earlier build’s complete gameplay pass.

## License

Original source code, scene/resource definitions and technical documentation are covered by the [MIT License](LICENSE). Artwork, music, sound effects, fonts and branding are excluded from that grant. Third-party components retain their own terms. See [LICENSING.md](LICENSING.md) for the full scope.
