# Devil’s Rock Paper Scissor — Godot source

See the [repository README](../README.md) for the game overview, how to play, technology stack, setup and hosting instructions.

## Project entry points

- Import `project.godot` with Godot 4.7 and the Compatibility renderer.
- Main scene: `scenes/main.tscn`.
- Portrait viewport: 540 × 960.
- Backend origin: `resources/backend/api_settings.tres`.
- Single-threaded Web export destination: sibling `builds/index.html`.

The private GD-Sync configuration at `addons/GD-Sync/keys.cfg` is excluded from Git. Keep actual environment files, anonymous-account credentials and `devpost/learner-profile.md` private.

## Documentation

- [How I used the Devpost Learn skills (Markdown)](../ai-development-process.md)
- [Download the searchable PDF](../ai-development-process.pdf)
- [Scope](devpost/scope.md)
- [Product requirements](devpost/prd.md)
- [Technical spec](devpost/spec.md)
- [Backend setup](../backend/README.md)
- [Release evidence and its limitations](docs/reports/AGY_Polishing_report.md)

Original source is covered by the [root MIT license](../LICENSE). Asset exclusions and third-party terms are documented in [LICENSING.md](../LICENSING.md).
