# Devil’s Rock Paper Scissor

A portrait rock paper scissor card game built around hidden choices, claims, changed intentions and a narrated reveal. The client uses Godot/GDScript with GD-Sync; the separate TypeScript/Node.js backend uses MongoDB and Vercel Functions.

This is technical source documentation prepared for creator review. Submission wording and publication are separately approved by the creator.

## Source layout

The current local Git repository contains three sibling directories:

- `rock-paper-scissor/`: this Godot project; `project.godot`, scenes, scripts, Resources and artwork.
- `backend/`: API functions, server source, lockfile and generated configuration artifact.
- `builds/`: generated frontend runtime files, currently tracked. These are not a backend deployment input.

Approved planning documents: [scope](devpost/scope.md), [PRD](devpost/prd.md), [technical spec](devpost/spec.md). Their original planning/status statements are not current verification claims.

## Open the client

1. Use Godot 4.7 with the Compatibility renderer, as recorded in this project's configuration.
2. Import this directory's `project.godot`. The configured main scene is `scenes/main.tscn`; the portrait viewport is 540 × 960.
3. Supply your own GD-Sync client configuration privately. The local `addons/GD-Sync/keys.cfg` is excluded from Git; never copy service credentials into source documentation.
4. Review `resources/backend/api_settings.tres` for the backend API origin. A browser frontend needs its exact origin accepted by the backend. No MongoDB credential belongs in the client.

The intended web target is single-threaded WebGL 2. The existing export preset writes to sibling `builds/index.html`; this shipping session does not export or run it.

## Backend setup

Use Node 24.x and the committed lockfile. From sibling `backend/`, install with `npm ci`, copy `.env.example` to a private `.env`, restrict its permissions, and set your own server-only database URI/database name. The example's database name is historical; choose your intended environment explicitly.

`npm run typecheck`, `npm run build` and `npm run dev` are the existing local commands. The local API adapter binds to `127.0.0.1:3100`. Database setup/seed/exercise commands can write persistent data; use the [backend README](../backend/README.md) for their documented context. This shipping session does not execute them.

Backend and frontend deployments use separate Vercel projects/repositories. Backend Root Directory: `backend`; Output Directory: `static-api-only`. The backend builds from its committed generated configuration and must not require or upload a Godot export. Frontend deployment/testing belongs to the creator.

## Evidence boundary

The [polishing report](docs/reports/AGY_Polishing_report.md) records corrected package inspection and a passing local browser fallback-bot journey for an earlier candidate. Later native timing flows and package inspections are separate evidence; the latest title/UI changes are explicitly recorded as untested. Those reports do not establish human-peer, takeover, hosted or mobile behavior for the current revision.

No playtest, export, video review or deployment was performed in this shipping session. The creator confirms the release issue is resolved and owns further testing.

## Publication

Public repository access, demo URL and final submission are tracked in the [shipping checklist](devpost/shipping-checklist.md). Keep real environment files, anonymous-account credentials, local test state and `devpost/learner-profile.md` private. The creator has made the repository public and authorized a project license. MIT and scope notes are prepared for original source; publication of those files is pending GitHub authentication. Retain bundled third-party license notices. Returning a repository to private later does not withdraw permissions already granted for the released code.
