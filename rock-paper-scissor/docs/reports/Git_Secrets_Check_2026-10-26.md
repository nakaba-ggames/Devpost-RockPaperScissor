# Git and credential check — 2026-10-26

Requested by the creator alongside M13 closure. Read-only Git/filesystem inspection; no staging, commit, push, history rewrite, credential changes or publication. Findings below do not expose secret values.

## Results

- Shared repository: parent `Devpost-RockPaperScissor`, covering both Godot and backend workspaces. Current branch `main`, HEAD `2d7d843` (`BEfore m13`); cached origin/main also points there. No staged files.
- Inspected **1,057 tracked paths** and filenames throughout **29 locally available commits/all local refs** (**1,059 historical paths**). No real `.env`, `.env.local` or similar private environment file was tracked or found in those historical filenames. The only environment-named tracked/history file is **`backend/.env.example`**.
- The example has an **empty MONGODB_URI** and ordinary database-name/port defaults, not a real database credential. The actual local `backend/.env` exists but is ignored/untracked; its contents were not displayed or read for this check.
- Verified ignore rules for backend/Godot `.env` variants, backend `.local`, Godot learner profile, Godot `export/`, backend `public/`, backend `.vercel` and GD-Sync local keys configuration. The learner profile is not tracked or present in available history; the similarly named tracked skill template is a generic template, not the private profile.
- Selected high-confidence content patterns found **no matches** in current tracked text or matching changes throughout available Git history: credential-bearing MongoDB URIs, PEM/OpenSSH private keys, standard AWS/GitHub/OpenAI token formats and issued anonymous-account credentials. A separate nonempty key-literal location check found no matching literals in current tracked text. Scanned **101 untracked text candidates** (nonignored, up to 2 MB each) with the same selected token patterns: no matches. No secret values or matching source lines were printed.
- Existing approved GD-Sync client configuration exposure in browser packages is a separate deliberate distribution decision; this check does not revoke that approval. Generated local exports remain ignored and are not treated as Git uploads.

## Remote and scan limitations

Live `git ls-remote --heads origin` could not list server branches, including a retry outside the initial sandbox. The connected GitHub repository metadata lookup returned 404, which can mean unavailable repository/access; it does not establish public/private visibility. The configured remote identity is `github.com/nakaba-ggames/Devpost-RockPaperScissor.git`.

Therefore **remote contents, current visibility, remote-only branches/history, deleted server objects, forks, GitHub Actions artifacts and deployment uploads were not independently verified**. Cached local origin/main is not a fresh server confirmation. No claim is made that a remote-only secret could never have been uploaded.

The content checks were selected regex-based checks, not an exhaustive credential detector: arbitrary passwords, unknown token formats, binaries, encoded material and large files can evade them. Working text scanning skipped binaries/files over 2 MB; filename/history tracking checks still covered all listed paths. Ignore rules prevent ordinary future additions but do not remove previously tracked history; no such private environment history was found here.

## Release follow-up

No real .env exposure requiring rotation/history remediation was identified in the checked local Git evidence. Do not rotate/rewrite history without an actual finding and creator direction. Before any public publication, verify remote access/visibility and review the exact intended additions, current history and actual filtered export. M13's known package-content failure/browser gap remains in Final Review; this source/Git check is not a passed release or hosting audit.
